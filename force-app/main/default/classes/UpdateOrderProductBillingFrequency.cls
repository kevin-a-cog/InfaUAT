/*
* @author : Ramya Ravi
* @date   : 12/02/2021 
* @purpose:   I2C-1072 : Enable 'Mass Update' Capability on the Order for Billing Frequency Changes
*
**********************************************************************************************************************************************************************************************************************
ChangeHistory

ModifiedBy                      Date                     Requested By                     Description                                                                                                     Tag 
RamEsh M S                      26-APR-2021              I2C-1220                         To include fields Bill Through Date Override, Next Billing Date and Next Charge Date in the update              <T01>
if mass update is done before Bill & Contract.
Nikhil Mane                     12-JAN-2022              I2C-1470                         To update the OrderItem fields when at lease one Order Product Billing Frequency = Invoice Plan                 <T02>
Nikhil Mane                     27-JAN-2022              I2C-1502                         To change the Billing Frequency from 'Invoice Plan' to selected Billing Frequency                               <T03>
options (Annual,Semi-Annual,Quarterly,& Monthly) 
Nikhil Mane                     07-FEB-2022                                                                                                                                                               <T04>
Nishit S                        15-JUN-2022              I2C-1620                         Enable "One Time" Billing on the "Mass Update of Billing Frequency" option on Order                             <I2C-1620>
Nishit S						19-SEP=2023				 I2C-2043						  Mass Update option on the Order to update 'Override Next Billing Date' & 'Bill Through Date Override'			  <I2C-2043>

**********************************************************************************************************************************************************************************************************************
*/
public class UpdateOrderProductBillingFrequency{    
    public static globalApexManager GAM = new globalApexManager();
    // <T02>
    //  Check at least one Order Product Billing Frequency equals Incoive plan if so return true else false
    @AuraEnabled
    public static Boolean CheckOrderProductBillingFreq(Id recordId){
        // Get the order items ID with BillingFrequency is Invoice Plan
        List<OrderItem> BlngFreqInvoicePlan = [Select id, SBQQ__BillingFrequency__c,SBQQ__ChargeType__c,blng__TotalBilling__c,SBQQ__BillingType__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__Quote__c  from OrderItem where OrderId =: recordId AND SBQQ__BillingFrequency__c = 'Invoice Plan'];
        if(BlngFreqInvoicePlan != null && BlngFreqInvoicePlan.size()>0)
        {             
            return true;
        }
        else
        {
            return false;
        }
        
    }
    // <T02>
    
    @AuraEnabled
    public static String UpdateOrderProductBillingFreq(Id recordId,String ExpectedBlngFreq,Boolean ChargeTypeStatus){
        //<T03>  2nd parameter String ExpectedBlngFreq
        //<T04>  3nd parameter Boolean ChargeTypeStatus, value=true when Charge Type is equal to One-Time else false. 
        System.debug('Inside UpdateOrderProductBillingFreq method, ExpectedBlngFreq:'+ExpectedBlngFreq+' ChargeTypeStatus :'+ChargeTypeStatus);
        String OrderId;
        List<Id> OrderItemID = new List<Id>(); //<I2C-1620>
        List<blng__InvoiceLine__c> InvoiceLines = new List<blng__InvoiceLine__c>();
        List<OrderItem> OrderItemList;// = new List<OrderItem> ();
        Integer count = 0; 
        Id quoteId;
        Set<Id> billTransId = new Set<Id> ();
        List<blng__BillingTransaction__c> BTList = new List<blng__BillingTransaction__c> ();
       
        // Get the order items ID
        // <T02>
        List<OrderItem> orderLI = [Select id, SBQQ__BillingFrequency__c,Product2.SBQQ__HasConsumptionSchedule__c, SBQQ__ChargeType__c, blng__TotalBilling__c ,blng__NextBillingDate__c,blng__NextChargeDate__c,blng__OverrideNextBillingDate__c,CreatedDate ,ServiceDate,TotalPrice,SBQQ__BillingType__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__Quote__c,Product2Id,Product2.SBQQ__BillingFrequency__c,Product2.SBQQ__BillingType__c,Product2.SBQQ__ChargeType__c, EndDate  from OrderItem where OrderId =: recordId AND Product2.SBQQ__HasConsumptionSchedule__c = FALSE];
        // <T02>
        // If there is no order product
        if(orderLI == null || orderLI.size() == 0)
        {
            OrderId ='Empty';
            return OrderId;
        }
        
       /* for(OrderItem li:orderLI)
        {
            // Check if the order products are not billed 
            If(li.blng__TotalBilling__c != 0)
            {
                OrderId ='Billed';
                return OrderId;
            }             
        }   */     
        
        //<I2C-1620> START
        if(ExpectedBlngFreq == 'One-Time/Accelerate')
        {
            OrderItemList = new List<OrderItem> ();
            for(OrderItem li:orderLI)
            {
                if(li.SBQQ__ChargeType__c == 'Recurring' && li.SBQQ__BillingFrequency__c != 'Invoice Plan')
                {
                    li.blng__BillThroughDateOverride__c  = li.EndDate;
                    OrderItemList.add(li);
                }
                if(li.SBQQ__ChargeType__c == 'Recurring' && li.SBQQ__BillingFrequency__c == 'Invoice Plan')
                    billTransId.add(li.Id);
            }//End of FOR
           
            try
            {
                if(OrderItemList.size() > 0)
                {
                    SBQQ.TriggerControl.disable();
                        update OrderItemList; // CPQ-Billing Triggers are not required for this DML.
                    SBQQ.TriggerControl.enable();
                }
                if(billTransId.size() > 0)
                {
                    for(blng__BillingTransaction__c BT : [Select Id,blng__OverrideBillingTargetDate__c from blng__BillingTransaction__c where Order_Product__c =: billTransId AND blng__Status__c = 'Pending' AND blng__OverrideStatus__c != 'Cancelled'])
                    {
                        BT.blng__OverrideBillingTargetDate__c = Date.Today();
                        BTList.add(BT);
                    }
                    if(BTList.size() > 0)
                        update BTList;
                }
                OrderId = recordId;
                return OrderId; 
                    
            }//End of TRY 
            catch(DmlException e)
            {
                 GAM.CreateExceptionRecords('UpdateOrderProductBillingFrequency --> UpdateOrderProductBillingFreq', e.getMessage(), 'error from UpdateOrderProductBillingFreq');
                 throw new AuraHandledException(e.getMessage());
            }
        }//End of ID
        //<I2C-1620> ENDS
        
        // <T02>
        // ifthe billing frequency is Invoice Plan for the order products update the fields with product field values
        if(ExpectedBlngFreq != 'One-Time/Accelerate' && ExpectedBlngFreq != 'Invoice Plan' && ExpectedBlngFreq != 'Invoice_Plan_OnActivation')
        {
            try{
                OrderItemList = new List<OrderItem> ();
                for(OrderItem li:orderLI)
                {   //<T04>
                    if(ChargeTypeStatus == true && li.product2.SBQQ__ChargeType__c == 'One-Time')
                    {
                        
                        li.SBQQ__BillingFrequency__c = 'Invoice Plan';
                        li.blng__OverrideNextBillingDate__c = null;
                        li.blng__NextBillingDate__c = null;
                        li.blng__BillThroughDateOverride__c = null;
                        li.blng__NextChargeDate__c = null;
                        li.SBQQ__ChargeType__c = 'Recurring';
                        li.SBQQ__BillingType__c = 'Advance'; 
                    }
                        
                    //<T04>
                    else {
                        li.SBQQ__BillingFrequency__c = li.Product2.SBQQ__BillingFrequency__c;
                        li.SBQQ__BillingType__c = li.Product2.SBQQ__BillingType__c;
                        li.SBQQ__ChargeType__c = li.Product2.SBQQ__ChargeType__c;
                        li.blng__OverrideNextBillingDate__c = (li.CreatedDate).date();
                        li.blng__NextChargeDate__c = li.ServiceDate;
                        li.blng__NextBillingDate__c = li.ServiceDate ;
                        li.blng__PendingBillings__c = li.TotalPrice;
                        li.blng__InvoiceRunProcessingStatus__c = 'Pending Billing';
                        li.blng__InvoiceRunStatusIndex__c = 'Pending Billing';
                        li.blng__BillThroughDateOverride__c = null;
                    }
                    if(li.SBQQ__ChargeType__c == 'Recurring' && li.Product2.SBQQ__ChargeType__c != 'One-Time'){
                        OrderItem oi = new OrderItem ();
                        oi.Id = li.Id;
                        oi.SBQQ__BillingFrequency__c = ExpectedBlngFreq;       //<T03>
                        li.SBQQ__BillingFrequency__c = ExpectedBlngFreq;       //<T03>
                        OrderItemList.add(oi);
                    }  
                }
                if(OrderItemList.size() > 0)
                    update OrderItemList; // CPQ Triggers to run to calculate Billable Unit Price and other date fields
                
                SBQQ.TriggerControl.disable();
                    update orderLI; // Update done with CPQ Triggers disabled so that Pending Billing, Charge Type can be updated.
                SBQQ.TriggerControl.enable();
                
                OrderId = recordId;
                return OrderId;   
            }
            catch(DmlException e){
                // GAM.CreateExceptionRecords('UpdateOrderProductBillingFrequency --> UpdateOrderProductBillingFreq', e.getMessage(), 'error from UpdateOrderProductBillingFreq');
                throw new AuraHandledException(e.getMessage());
            }
        }
        // <T02> 
        
        // Update the Order products
        if(ExpectedBlngFreq == 'Invoice Plan' || ExpectedBlngFreq == 'Invoice_Plan_OnActivation')
        {
            for(OrderItem li:orderLI)
            {
                li.SBQQ__BillingFrequency__c = 'Invoice Plan';
                li.blng__OverrideNextBillingDate__c = null;
                //<T01>
                li.blng__NextBillingDate__c = null;
                li.blng__BillThroughDateOverride__c = null;
                li.blng__NextChargeDate__c = null;
                //</T01>
            
                if(li.SBQQ__ChargeType__c != 'Recurring') 
                {
                    li.SBQQ__ChargeType__c = 'Recurring';
                }    
            
                if(li.SBQQ__BillingType__c != 'Advance')
                {
                    li.SBQQ__BillingType__c = 'Advance'; 
                }
            
                quoteId = li.SBQQ__QuoteLine__r.SBQQ__Quote__c;
            }
        
        
            if(orderLI != null && orderLI.size() > 0)
            {
                try
                {
                    SBQQ.TriggerControl.disable();
                        Database.SaveResult[] srList = Database.update(orderLI,false);
                        if(quoteId != null)
                            update new SBQQ__Quote__c(Id=quoteId,SBQQ__BillingFrequency__c = 'Invoice Plan');
                    SBQQ.TriggerControl.enable();
                
                    for(Database.SaveResult result:srList)
                    {
                        if(result.isSuccess() ) 
                            OrderId = recordId;
                    }
                    return OrderId;
                } 
                catch(DmlException e)
                {
                    GAM.CreateExceptionRecords('UpdateOrderProductBillingFrequency --> UpdateOrderProductBillingFreq', e.getMessage(), 'error from UpdateOrderProductBillingFreq');
                    throw new AuraHandledException(e.getMessage());
                }
            }
        }
        
        return OrderId;
    }
    
    //<I2C-2043> START
    @AuraEnabled
    public static String updateBillingDates(Id recordId, Date billThroughDateOverride, Date overrideNextBillingDate){ 
        List<OrderItem> orderItemList = new List<OrderItem>();
        String OrderId;
        OrderItem orderitem = [Select Id, blng__OverrideNextBillingDate__c, blng__BillThroughDateOverride__c, orderId,
                                          SBQQ__BillingFrequency__c, SBQQ__ChargeType__c, blng__InvoiceRunProcessingStatus__c, blng__NextBillingDate__c
                                          from OrderItem LIMIT 1];
        system.debug('orderitem ' + orderitem);
        for(OrderItem oi : [Select id, blng__OverrideNextBillingDate__c, blng__BillThroughDateOverride__c from OrderItem where OrderId =: recordId AND SBQQ__BillingFrequency__c != 'Invoice Plan' AND SBQQ__ChargeType__c != 'Usage' AND blng__InvoiceRunProcessingStatus__c = 'Pending Billing' AND blng__NextBillingDate__c != NULL /*blng__PendingBillings__c != 0 AND TotalPrice !=0*/]){
            if(billThroughDateOverride != NULL){
                oi.blng__BillThroughDateOverride__c = billThroughDateOverride;
            }
            if(overrideNextBillingDate != NULL){
                oi.blng__OverrideNextBillingDate__c = overrideNextBillingDate;
            }
            orderItemList.add(oi); 
            
        }       
        if(orderItemList.size() > 0){
            try{
                SBQQ.TriggerControl.disable();
                update orderItemList; 
                SBQQ.TriggerControl.enable();
            }
            catch(DMLException ex){
                GAM.CreateExceptionRecords('UpdateOrderProductBillingFrequency --> updateBillingDates', ex.getMessage(), 'error from UpdateOrderProductBillingFrequency.updateBillingDates');
                return 'Exception: ' + ex.getDmlMessage(0);
            }
        }
        else
            return 'Empty';
        
        return recordId;
    }
    //<I2C-2043> ENDS
}