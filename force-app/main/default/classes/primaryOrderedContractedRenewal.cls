/****************************************************************************************************************************
 *  @Class Name: primaryOrderedContractedRenewal
 *  @Author: Ramesh M S
 *  @Date: 28 Jan 2020
 *  @Description: Class to process Large Quotes/Order/Contracts. 
 *****************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy                Date              Requested By              Description                                  Tag   
 
 RamEsh M S                28 Jan 2020       RamEsh M S                Processing the Quote to Primary, Submit for Approval, Create Order, 
                                                                       Contract the Order, Create Renewal Opportunity/Quote from Contract, 
                                                                       Amend the Contract.    T01
 RamEsh M S                2 Jun 2020        Karthik                   SALESRT-12104 - Create record on Exception Log object for audit  <T02>   
 RamEsh M S                28-JUN-2020       Keerthana                 SALESRT-12187 - Added Order activation.
 Anil   Solanki            9-AUG -2020        Kiran A                   I2C-726 : Updated Order Activation Stage.
 Anil   Solanki            30-NOV-2020        Kiran A                   I2C-1150 : Added Sub Type = Full Debook.<T03>
 RamEsh M S                05-JAN-2021        I2C-1109            Finance                      Update the logic to create/update Booking when RA is moved to Allocation Validated  <T04>
 RamEsh M S                28-JAN-2021        SALESRT-12761             Order Products activation when Direct Order is activated.   <T05>
Ramya Ravi                 01-APR-2021        SalesRT-11918             To fix the issue for the debook order - POT lines were not getting calculated. <T06>
RamEsh M S                 12-MAY-2021        I2C-897                   Delete Bookings of Revenue Agreement that is Cancelled-Merged <T07>
RamEsh M S                 15-MAY-2021        I2C-1022                  Amendment Order activation with Custom Billing, Billing Frequency = Invoice Plan of amended lines <T08>
Wasim                      27-JAN-2022        CPQ Upgrade '22           Removed the logic to activate the order products <T09>
****************************************************************************************************************************/
public class primaryOrderedContractedRenewal implements Queueable{
    
    private String actionType;
    private String objectType;
    private Id recordId;
    
    public primaryOrderedContractedRenewal (String actionType, String objectType, Id id) {
    
        this.actionType = actionType;
        this.objectType = objectType;
        this.recordId = id;
        
    }
    
     
     public void execute(QueueableContext context) {
    
        if(objectType == 'Order' && actionType == 'Activation')
        {
            system.debug('Inside Queueable Execute');
            List<Order> orderList = new List<Order> ();
            for(Order o : [Select Id,Status from Order where Id =:recordId  AND Status != 'Activated'])
            {
                o.Status = 'Activated';
                orderList.add(o);
            }
            try{
            update orderList;
            }
            catch(Exception e)
            {
                system.debug('Exit Queueable Execute'+ e);
            } 
        }

    }
    
    @AuraEnabled
    public static String currentUser()
    {
        String userType = 'User';
        if(FeatureManagement.checkPermission('CustomInvoicingCreate')) 
            userType = 'Finance';
        if(FeatureManagement.checkPermission('SOG_Admin_Button'))
            userType = 'SOG';
        return userType;
    }
    
    @AuraEnabled
    public static void fromLight(String actionType, String objectType, Id recordId)
    {
        if(objectType == 'Order' && actionType == 'Activation')
        {        
            primaryOrderedContractedRenewal updateJob = new primaryOrderedContractedRenewal (actionType, objectType, recordId);
            ID jobID = System.enqueueJob(updateJob);
        }
        //<T08> Added condition to handle amendment order activation with Custom Billing
        else if(objectType == 'Order' && actionType == 'ActivationAmendCustomBilling')
        {
            List<OrderItem> oiListToUpdate = new List<OrderItem> ();
            Set<Id> recordIds = new Set<Id> ();
            String ordNum;
            //Query Order Products that are amended from contract with Billing Frequeny  = Invoice Plan and Contract Action is Qty Increase/Qty Decrease
            for(OrderItem oi : [Select Id,order.OrderNumber from OrderItem where OrderId =: recordId AND Order.Type = 'Amendment' AND SBQQ__BillingFrequency__c = 'Invoice Plan' 
                                AND SBQQ__QuoteLine__c != null AND SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null AND (SBQQ__ContractAction__c = 'Quantity Increase' OR SBQQ__ContractAction__c = 'Quantity Decrease')])  
            {
                oi.SBQQ__BillingFrequency__c = 'Annual';
                oiListToUpdate.add(oi);
                ordNum = oi.Order.OrderNumber;
                recordIds.add(oi.Id);
            }
            if(oiListToUpdate.size() > 0)
            {
                //update order products
                SBQQ.TriggerControl.disable();
                update oiListToUpdate;
                SBQQ.TriggerControl.enable();
                
                //Activate the Order
                update new Order(Id=recordId, Status='Activated');
                
                DateTime newDateTime = DateTime.now().addMinutes(2);
                String hour = String.valueOf(newDateTime.hour());
                String min = String.valueOf(newDateTime.minute()); 
                String ss = String.valueOf(newDateTime.second());
                String month = String.valueOf(newDateTime.month());
                String day = String.valueOf(newDateTime.day());
                String year = String.valueOf(newDateTime.year());
                
                //parse to cron expression
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
                
                // schedule a job to revert the Billing Frequency to Invoice Plan to execute after two minutes as after order activation we have Revenue Schedule creation and other task
                primaryOrderedContRenewalSchedulable s = new primaryOrderedContRenewalSchedulable(actionType, objectType, recordIds); 
                System.schedule('CustomBilling_Amend_Order_Act_' + ordNum + ' @: ' + String.valueOf(newDateTime), nextFireTime, s);
                
            }

        }
         else if(objectType == 'Order' && actionType == 'RunBatchRevAgrr')
        {
            revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
            database.executebatch(revAgreeBatch,1);
        }
        else if(objectType == 'Order' && actionType == 'RunBatchPONum')
        {
            NotifyPONumberUpdateOnIGD notifyPOBatch = new NotifyPONumberUpdateOnIGD();
            database.executebatch(notifyPOBatch,1);
        }
        else
            doJob(actionType,objectType,recordId);
        
    }
    
    
    @future (callout=true)
     Public static void doJob(String actionType, String objectType, Id recordId)
     {
     
        globalApexManager GAM = new globalApexManager();
    
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c> ();
        List<Order> orderList = new List<Order> ();
        List<Contract> contractList = new List<Contract> ();
        List<Booking__c> bookList = new List<Booking__c> ();
        List<Booking_Line_Details__c> bookLineList = new List<Booking_Line_Details__c> ();
        Set<Id> bookIds = new Set<Id> ();
        
        
        if(objectType == 'Quote' && actionType == 'Primary')
        {
            for(SBQQ__Quote__c quote : [Select Id,SBQQ__Primary__c,SBQQ__Ordered__c from SBQQ__Quote__c where Id =:recordId AND SBQQ__Primary__c = FALSE AND SBQQ__Ordered__c = FALSE])
            {
                quote.SBQQ__Primary__c = TRUE;
                quoteList.add(quote);
            }
        }
        
        if(objectType == 'Quote' && actionType == 'Ordered')
        {
            for(SBQQ__Quote__c quote : [Select Id,SBQQ__Primary__c,SBQQ__Ordered__c from SBQQ__Quote__c where Id =:recordId AND SBQQ__Primary__c = TRUE AND SBQQ__Ordered__c = FALSE])
            {
                quote.SBQQ__Ordered__c = TRUE;
                quoteList.add(quote);
            }
        }
        
        if(objectType == 'Order' && actionType == 'Contracted')
        {
            for(Order o : [Select Id,SBQQ__Contracted__c from Order where Id =:recordId AND Status = 'Activated' AND Revenue_Agreement_Processed__c = TRUE])
            {
                System.debug('@@@@@INSIDE');
                o.SBQQ__Contracted__c = TRUE;
                orderList.add(o);
            }
        }
        
        if(objectType == 'Contract' && actionType == 'RenewalOppty')
        {
            for(Contract cont : [Select Id,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c from Contract where Id =:recordId])
            {
                cont.SBQQ__RenewalForecast__c = TRUE;
                contractList.add(cont);
            }
        }
        
        if(objectType == 'Contract' && actionType == 'RenewalQuote')
        {
            for(Contract cont : [Select Id,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c from Contract where Id =:recordId])
            {
                cont.SBQQ__RenewalQuoted__c = TRUE;
                contractList.add(cont);
            }
        }
        
        if(objectType == 'Contract' && actionType == 'Amend')
        {
            for(Contract cont : [Select Id,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c from Contract where Id =:recordId])
            {
                QuoteModel quote = load(cont.Id); 
            }
        }
        
        if(objectType == 'Quote' && actionType == 'Approval')
        {
            SBAA.ApprovalAPI.submit(recordId, SBAA__Approval__c.Quote__c);
        }
        
        if(objectType == 'Quote' && actionType == 'RecallApproval')
        {
            SBAA.ApprovalAPI.recall(recordId, SBAA__Approval__c.Quote__c);
        }
        
        //<T03>
        if(objectType == 'Quote' && actionType == 'FullDebook')
        {
            for(SBQQ__Quote__c quote : [Select Id,Sub_Type__c from SBQQ__Quote__c where Id =:recordId])
            {
                quote.Sub_Type__c = 'Full Debook';
                quoteList.add(quote);
            }
        }
        //<T04>
        if(objectType == 'Order_New_Renewal' && actionType == 'Cancel_Bookings')
        {
            for(Booking__c book : [Select Id from Booking__c where Revenue_Agreement__c IN (Select Revenue_Agreement__c from Related_Order_and_Contract__c where Order__c =: recordId)])
            {
                bookList.add(book);
            }
        }
        
        //<T04>
        if(objectType == 'Order_Amendment' && actionType == 'Cancel_Bookings')
        {
            for(Booking_Line_Details__c bookline : [Select Id,Booking__c from Booking_Line_Details__c where Revenue_Schedule__c IN (Select Id from blng__RevenueSchedule__c where blng__OrderProduct__r.OrderId =: recordId OR Parent_RS__r.blng__OrderProduct__r.OrderId =: recordId)])
            {
                bookLineList.add(bookline);
                bookIds.add(bookline.Booking__c);
            }
        }
        
        //<T07>
        if(objectType == 'RevenueAgreement_Merge' && actionType == 'Cancel_Bookings')
        {
            for(Booking__c book : [Select Id from Booking__c where Revenue_Agreement__c =: recordId])
            {
                bookList.add(book);
            }
        }
        
        
        try
        {
            if(quoteList != null && quoteList.size() > 0)
                update quoteList;
            
            if(orderList != null && orderList.size() > 0)
                update orderList;
                
            if(contractList != null && contractList.size() > 0)
                update contractList;
            //<T04>    
            if(bookList != null && bookList.size() > 0)
                delete bookList;
                
            if(bookLineList != null && bookLineList.size() > 0)
            {
                delete bookLineList;
                
                bookLineList = new List<Booking_Line_Details__c> ();
                bookLineList = [Select Id from Booking_Line_Details__c where Booking__c =: bookIds];
                if(bookLineList != null && bookLineList.size() > 0)
                {
                    for(Booking__c book : [Select Id,Reprocess_Booking__c from Booking__c where Id =: bookIds])
                    {
                        book.Reprocess_Booking__c = TRUE;
                        bookList.add(book);
                    }
                    if(bookList != null && bookList.size() > 0)
                        update bookList;
                        
                }
                else
                {
                    delete [Select Id from Booking__c where Id =: bookIds];
                }
                
            }//<T04>
                    
            
            GAM.CreateAudit('SOG Admin','primaryOrderedContractedRenewal class',Id.valueOf(recordId),objectType + ' to ' + actionType,'Audit'); //<T02>
        }
        catch(Exception e)
        {
            GAM.CreateExceptionRecords('primaryOrderedContractedRenewal --> make ' + objectType + ' to ' + actionType, e.getMessage(), 'error from future method of primaryOrderedContractedRenewal');
        } 
     }
     // CPQ API to amend the contract
     
     public static QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
           //<T06>
        QuoteCalculator calculator = new QuoteCalculator();
        calculator.calculate((QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class), 'MyCallback');  //</T06>
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }
    
    /*<T05>
    Query Order Products of the Direct Order and activate them
    
    */
    /* <T09> - Commenting this logic for Winter '22 CPQ Upgrade
    @future (callout=true)
    Public static void directOrderAct(String actionType, String objectType, Set<Id> orderIds)
    {
        List<OrderItem> oiList = new List<OrderItem> ();
        globalApexManager GAM = new globalApexManager();
        
        if(objectType == 'Order' && actionType == 'Direct_Order_Activation')
        {
            for(OrderItem oi : [Select Id,SBQQ__Status__c,SBQQ__Activated__c,blng__BillableUnitPrice__c from OrderItem where OrderId =: orderIds])
            {
                oi.SBQQ__Activated__c = TRUE;
                oi.SBQQ__Status__c = 'Activated';
                oi.blng__BillableUnitPrice__c = 0;
                oiList.add(oi);
            }
        }
        
        if(oiList != null && oiList.size() > 0)
        {
            try
            {
              update oiList;
            }
            catch(Exception e)
            {
                GAM.CreateExceptionRecords('OrderTriggerHandler_Direct Order Activation_primaryOrderedContractedRenewal', e.getMessage(),orderIds.toString());
            } 
        }
    }
    </T09>
    */
}