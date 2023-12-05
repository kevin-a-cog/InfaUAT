/*
Class:          mergeRevAgreeController
@Author:        RamEsh M S
@Created Date:  30-Apr-2021
@Description:   I2C-897 - Class merge Revenue Agreement.

Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                             Tag
**********************************************************************************************************************************************************
**********************************************************************************************************************************************************
*/

global class mergeRevAgreeController
{

public static globalApexManager GAM = new globalApexManager();

  
    @AuraEnabled
    public static String onLoad(Id orderId)
    {

        String message = 'NO_MESSAGE';
        List<Related_Order_and_Contract__c> ROCList = new List<Related_Order_and_Contract__c> ();
        Related_Order_and_Contract__c ROC = new Related_Order_and_Contract__c ();
        
        ROCList = [Select Id,Order__c, Order__r.Status,Revenue_Agreement__c, Revenue_Agreement__r.Stage__c 
                                                from Related_Order_and_Contract__c where Order__c =: orderId LIMIT 1];
        if(ROCList == null || ROCList.isEmpty())
            message = 'You can merge the Order to the Revenue Agreement after Draft Revenue Agreement is created for the current oder, wait for the batch to create Draft RA and then try again.';
            
        if(ROCList != null && !ROCList.isEmpty())
        {
            ROC = ROCList[0];
            if(ROC.Revenue_Agreement__c == null)
                message = 'You can merge the Order to the Revenue Agreement after Draft Revenue Agreement is created for the current oder, wait for the batch to create Draft RA and then try again.';
            else if(ROC.Revenue_Agreement__r.Stage__c != 'Ready' && ROC.Revenue_Agreement__r.Stage__c != 'Sent to RMCS')
                message = 'Proceed to Merge Screen';
            else
                message = 'The Revenue Agreement for the order is already processed and stage is set as ' + ROC.Revenue_Agreement__r.Stage__c + '. So this order cannot be merged to another Revenue Agreement.';
        }
        
        return message;        
    }
    
    @AuraEnabled
    public static RAROCWrapper SearchRA(Id orderId,String SearchNumber)
    {
    
        List<Revenue_Agreement__c> RAList = new List<Revenue_Agreement__c> ();
        List<Related_Order_and_Contract__c> ROCList = new List<Related_Order_and_Contract__c> ();
        List<Order> OrdList = new List<Order> ();
        Related_Order_and_Contract__c ROC = new Related_Order_and_Contract__c();
        Revenue_Agreement__c RA = new Revenue_Agreement__c ();
        Order ordSearch = new Order();
        Order ordCurr = new Order();
        
        String message = 'NULL_MESSAGE';
        boolean hasNoAmend = true;
        RAROCWrapper ra_roc_Wrapper = new RAROCWrapper();
        
        
        if(SearchNumber != null)
        {
            if(!SearchNumber.startsWithIgnoreCase('RA'))
            {
                ROCList = [Select Id,Order__c, Order__r.Status,Order__r.AccountId,Revenue_Agreement__c,Revenue_Agreement__r.Name, Revenue_Agreement__r.Stage__c 
                                                from Related_Order_and_Contract__c where Order__r.OrderNumber =: SearchNumber LIMIT 1];
                
                for(Order ORD : [Select Id,OrderNumber,AccountId from Order where OrderNumber =: SearchNumber OR Id =: orderId])
                {
                    if(ORD.Id == orderId)
                        ordCurr = ORD;
                    if(ORD.OrderNumber == SearchNumber)
                        ordSearch = ORD;
                }
                
                
                if(ordSearch.Id == null)
                    message = 'There is no Order in the system for the Order Number "' + SearchNumber + '" in the search input.';
                
                else if(ordSearch.Id == orderId)
                    message = 'The Order Number "' + SearchNumber + '" in the search input is same as the current order. It should be different Order to merge.';
                
                else if(ordSearch.AccountId != ordCurr.AccountId)
                    message = 'The Account of current order is not same as of searched Order. You can merge only to the orders of same account';
                    
                else if(ROCList == null || ROCList.isEmpty())
                {
                    message = 'There is no Revenue Agreement created yet for the Order Number "' + SearchNumber + '" in the search input.';
                }
                else if(ROCList != null && !ROCList.isEmpty())
                {
                    ROC = ROCList[0];
                    
                    
                    if(ROC.Revenue_Agreement__c == null)
                    {
                        message = 'There is no Revenue Agreement created yet for the Order Number "' + SearchNumber + '" in the search input.';    
                    }
                    else if(ROC.Revenue_Agreement__r.Stage__c == 'Ready' || ROC.Revenue_Agreement__r.Stage__c == 'Sent to RMCS')
                    {
                        message = 'The Revenue Agreement <b>' + ROC.Revenue_Agreement__r.Name + '</b> of the order searched is set as : <b>' + ROC.Revenue_Agreement__r.Stage__c + '</b> . So you cannot merge.';
                    }
                    else
                    {
                        RAList = [Select Id,Account__c, Business_Model__c, CurrencyIsoCode, Customer_Type__c, Legal_Entity__r.Name,Name, 
                                    RMCS_Contract_Number__c, Stage__c, Sum_of_Allocated_Booking__c, Sum_of_Total_Amount__c 
                                    from Revenue_Agreement__c where Id =: ROC.Revenue_Agreement__c];
                        
                        ROCList = new List<Related_Order_and_Contract__c> ();
                        
                        for(Related_Order_and_Contract__c ROCIterate : [Select Id,Order__c, Order__r.OrderNumber, Original_Order__c,Order__r.Type, Order__r.Business_Model__c, Order__r.Legal_Entity__r.Name,Order__r.TotalAmount, Order__r.blng__TotalBilling__c, Order__r.Status
                                    from Related_Order_and_Contract__c where Revenue_Agreement__c =: ROC.Revenue_Agreement__c])
                        {
                            ROCList.add(ROCIterate);
                            
                            if(ROCIterate.Order__r.Type == 'Amendment')
                                hasNoAmend = false;
                        }            
                    }
                }
                
                
            }
            else if(SearchNumber.startsWithIgnoreCase('RA'))
            {
                RAList = [Select Id,Name,Stage__c from Revenue_Agreement__c where Name =: SearchNumber LIMIT 1];
                ordCurr = [Select Id,AccountId from Order where Id =: orderId LIMIT 1];
               
                if(RAList == null || RAList.isEmpty())
                {
                    message = 'There is no Revenue Agreement for the RA Name "' + SearchNumber + '" in the search input.';
                }
                else if(RAList != null && !RAList.isEmpty())
                {
                    RA = RAList[0];
                    RAList = [Select Id,Account__c, Business_Model__c, CurrencyIsoCode, Customer_Type__c, Legal_Entity__r.Name,Name, 
                                    RMCS_Contract_Number__c, Stage__c, Sum_of_Allocated_Booking__c, Sum_of_Total_Amount__c 
                                    from Revenue_Agreement__c where Id =: RA.Id];
                        
                    ROCList = [Select Id,Order__c,Order__r.AccountId, Order__r.OrderNumber,Original_Order__c, Order__r.Type, Order__r.Business_Model__c, 
                                Order__r.CurrencyIsoCode,Order__r.Legal_Entity__r.Name,Order__r.TotalAmount, Order__r.blng__TotalBilling__c, 
                                Order__r.Status,Revenue_Agreement__r.Name
                                    from Related_Order_and_Contract__c where Revenue_Agreement__c =: RA.Id];
                    
                    if(RA.Stage__c == 'Ready' || RA.Stage__c == 'Sent to RMCS')
                        message = 'The Revenue Agreement <b>' + RA.Name + '</b> is set as : <b>' + RA.Stage__c + '</b> . So you cannot merge.';
                    
                    for(Related_Order_and_Contract__c RC : ROCList)
                    {
                        message = RC.Order__c == orderId ? 'This Revenue Agreement "' + SearchNumber + '" from the search input is already associated with the current order. It should be different Revenue Agreement to merge.' : message;
                        message = RC.Order__r.AccountId != ordCurr.AccountId ? ' The account of the Revenue Agreement searched is not same as Order Account. You can merge only to the Revenue Agreement of same account' : message; 
                        
                        if(RC.Order__r.Type == 'Amendment')
                            hasNoAmend = false;
                    }
                    
                }
            }
            
            ra_roc_Wrapper.RAList = RAList;
            ra_roc_Wrapper.ROCList = ROCList;
            ra_roc_Wrapper.searchresultsmessage = message;
            ra_roc_Wrapper.hasNoAmendment = hasNoAmend;
            
    
        }
        
        return ra_roc_Wrapper;
    }
    
    @AuraEnabled
    public static String mergeRSAndCancelRA (Id orderId, RAROCWrapper wrapperData)
    {
        String message = 'NO_MESSAGE';
        List<Revenue_Agreement__c> RAList = new List<Revenue_Agreement__c> ();
        List<Related_Order_and_Contract__c> ROCList = new List<Related_Order_and_Contract__c> ();
        Related_Order_and_Contract__c ROC = new Related_Order_and_Contract__c();
        Revenue_Agreement__c RA = new Revenue_Agreement__c ();
        RAROCWrapper ra_roc_Wrapper = new RAROCWrapper();
        List<blng__RevenueSchedule__c> RSListToUpdate = new List<blng__RevenueSchedule__c> ();
        Order ORD = new Order ();
        Id RAToCancel;
         Id cancelRecordTypeId = Schema.SObjectType.Revenue_Agreement__c.getRecordTypeInfosByName().get('Cancelled').getRecordTypeId();
         Id activeRecordTypeId = Schema.SObjectType.Revenue_Agreement__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();

        
        if(wrapperData != null)
        {
            RAList = wrapperData.RAList;
            ROCList = wrapperData.ROCList; 
        }   
        
        if(RAList != null && !RAList.isEmpty())
        {
            RA = RAList[0];
            
            if(orderId != null)
                 ORD = [Select Id,OrderNumber from Order where Id =: orderId LIMIT 1];
            
            for(blng__RevenueSchedule__c RS : [Select Id,Revenue_Agreement__c,Sent_to_RMCS__c from blng__RevenueSchedule__c where Order_Number__c =: ORD.OrderNumber AND Sent_to_RMCS__c = FALSE])
            {
                RS.Revenue_Agreement__c = RA.Id;
                RSListToUpdate.add(RS);
            }
            
            ROCList = [Select Id,Order__c,Original_Order__c, Order__r.Status,Revenue_Agreement__c, Revenue_Agreement__r.Stage__c 
                                                from Related_Order_and_Contract__c where Order__c =: orderId LIMIT 1];
            
            if(ROCList != null & !ROCList.isEmpty()) 
            {                                   
                ROCList[0].Original_Order__c = FALSE;
                RAToCancel = ROCList[0].Revenue_Agreement__c;
                ROCList[0].Revenue_Agreement__c = RA.Id;
                 
            }
            
            if(RSListToUpdate.size() > 0)
            {
                try{
                    
                    SBQQ.TriggerControl.disable();
                        
                        
                        RA.Stage__c = 'Draft';
                        RA.Reset__c = TRUE;
                        RA.RecordTypeId = activeRecordTypeId;
                        RAList.add(new Revenue_Agreement__c(Id = RAToCancel,Stage__c = 'Cancelled-Merged',RecordTypeId = cancelRecordTypeId,Reset__c = TRUE));
                        update RAList;
                        
                        RA.Reset__c = FALSE;    
                        update RA;
                        
                        update ROCList;
                        
                        update RSListToUpdate;
                        
                        
                        ContentNote cn = new ContentNote();
                        cn.Title = 'Merge Details';
                        String body = 'This Revenue Agreement was created for Order : ' + ORD.OrderNumber + ' and then the order is merged into ' + RA.Name;
                        cn.Content = Blob.valueOf(body.escapeHTML4());
                        insert cn;
                        
                        ContentDocumentLink link2 = new ContentDocumentLink();
                        link2.ContentDocumentId = cn.id;
                        link2.LinkedEntityId = RAToCancel;
                        link2.ShareType = 'V';
                        link2.Visibility = 'AllUsers';
                        
                        primaryOrderedContractedRenewal.doJob('Cancel_Bookings','RevenueAgreement_Merge',RAToCancel);
                        
                        insert(link2);
                         
                    SBQQ.TriggerControl.enable();
                    message = 'REVENUE SCHEDULES OF THE ORDER "' + ORD.OrderNumber + '" ARE MOVED TO REVENUE AGREEMENT : ' + RA.Name;
                }
                catch(Exception e){
                    GAM.CreateExceptionRecords('merge Revenue Agreement', e.getMessage(), 'error from mergeRevAgreeController');
                    throw new AuraHandledException(e.getMessage());
                }
            }
            else
                message = 'NO REVENUE SCHEDULES TO UPDATE';
        }
   
        return message;
    }
    
    public class RAROCWrapper {
      @AuraEnabled
      public list<Revenue_Agreement__c> RAList {get;set;}
      
      @AuraEnabled
      public list<Related_Order_and_Contract__c> ROCList {get;set;}
      
       @AuraEnabled
       public string searchresultsmessage {get;set;}
       
       @AuraEnabled
       public boolean hasNoAmendment {get;set;}
      
      public RAROCWrapper(){
          this.RAList = new list<Revenue_Agreement__c>();
          this.ROCList = new list<Related_Order_and_Contract__c>();
          
      }
    }
    
}