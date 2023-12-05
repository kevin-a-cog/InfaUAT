/***************************************************************************************************************************************************************
 *  @Class Name: revenueAgreementCancelFulfillDate
 *  @Author: Ramesh M S
 *  @Date: 05 AUG 2020
 *  @Description: I2C-789 - Class to handle Cancel and Debook of Orders and update Revenue Agreement & Revenue Schedules accordingly  
                            
 ****************************************************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy                    Date                       Requested By                     Description                                                                                           Tag   
 
RamEsh M S                     10-AUG-2020                                                  Class to update Ship Date and Def Rev Acc Date on Revenue Schedules from Order
                                                                                            Product and Order      
RamEsh M S                     10-NOV-2020                F2A-309                           Sync Ship Date and Deferred Revenue Acc Date on RS from Order Product                                <T01> 
RamEsh M S                     03-MAR-2021                SALESRT-12911                     Disabling CPQ and Billing Triggers on DML operation for Revenue Schedules                            <T02>          
Nishit S                        7-JUN-2021                  I2C-1267                        Revenue Schedules for Royalty Fees are not populated with Ship Dates                                 <T03>
Wasim                          20-SEP-2021                  SALESRT-13309                   Moving the logic to update Substage to Booked from OrderTriggerHandler to                            <T04>
                                                                                            revenueAgreementBatch
Narpavi Prabu                  28-SEP-2022                   F2A-471                        Replace the provisionable formula field ('Provisionable__c) with new checkbox 
                                                                                            field in Product ('Provisionable_New__c')               
Nishit S                       03-MAY-2023                  I2C-1908                        Revenue Agreement Status is not getting updated when Amendment Order is Cancelled                    <I2C-1908>
***************************************************************************************************************************************************************/
global class revenueAgreementCancelFulfillDate implements Queueable{
    
    public static globalApexManager GAM = new globalApexManager();
    public Set<Id> Ids;
    public String actionType;
    
    
    global revenueAgreementCancelFulfillDate(Set<Id> Ids,String actionType)
    {
        this.Ids = Ids;
        this.actionType = actionType;
    }
    
    global void execute(QueueableContext context)
    {
        if(actionType == 'Cancel_Debook')
            handleCancelDebook(Ids);
        if(actionType == 'Ship_Prov_Date')
            handleShipDate(Ids);
        /* Commented for <T04>
        if(actionType == 'Oppty_Booked')
            handleOpptyBook(Ids);
        */
    }
    
    public static void handleCancelDebook(Set<Id> orderIds)
    {
        List<Revenue_Agreement__c> RAList = new List<Revenue_Agreement__c> ();
        List<Revenue_Agreement__c> RAUpdateList = new List<Revenue_Agreement__c> ();
        List<blng__RevenueSchedule__c> RSList = new List<blng__RevenueSchedule__c> ();
        List<blng__RevenueSchedule__c> RSUpdateList = new List<blng__RevenueSchedule__c> ();
        Map<Id,Order> orderMap = new Map<Id,Order> ();
        Map<Id,Id> orderRAMap = new Map<Id,Id> ();
        Id orderId;
        String orderType;
        String orderStatus;
        Map<Id,Id> revAgrIds = new Map<Id,Id> ();
        Map<Id,Id> revAgrIdsDraft = new Map<Id,Id> ();
        Map<Id,Id> revAgrIdsReady = new Map<Id,Id> ();
        
        for(Related_Order_and_Contract__c ROC : [Select Id,Order__c,Revenue_Agreement__c from Related_Order_and_Contract__c where Order__c =: orderIds])
        {
            orderRAMap.put(ROC.Revenue_Agreement__c,ROC.Order__c);
        }

        RAList = [Select Id,Stage__c,RecordTypeId from Revenue_Agreement__c where Id =: orderRAMap.keyset()];
        RSList = [Select Id,blng__OrderProduct__c,Sent_to_RMCS__c,Status__c,Revenue_Agreement__c from blng__RevenueSchedule__c where Revenue_Agreement__c  =: orderRAMap.keyset() AND (blng__OrderProduct__r.Order.Status =: 'Cancelled' OR Parent_RS__r.blng__OrderProduct__r.Order.Status =: 'Cancelled')];
        
        orderMap = new Map<Id,Order> ([Select Id,Type,Status from Order where Id =: orderIds]);
        
        for(AggregateResult AR : [SELECT Revenue_Agreement__r.Id revId,COUNT(Id)IdCount FROM blng__RevenueSchedule__c WHERE Revenue_Agreement__c =: orderRAMap.keyset() AND Sent_to_RMCS__c = TRUE GROUP BY Revenue_Agreement__r.Id ])
        {
            Id revAgrrId = (Id) AR.get('revId');
            revAgrIds.put(revAgrrId,revAgrrId);
        }
        
        for(AggregateResult AR : [SELECT Revenue_Agreement__r.Id revId,COUNT(Id)IdCount FROM blng__RevenueSchedule__c WHERE Revenue_Agreement__c =: orderRAMap.keyset() AND Sent_to_RMCS__c = FALSE AND Status__c = 'Active' AND blng__orderProduct__c != NULL AND blng__orderProduct__r.Order.Revenue_Agreement_Processed__c = FALSE AND blng__orderProduct__r.OrderId !=: orderIds GROUP BY Revenue_Agreement__r.Id ])
        {
            Id revAgrrId = (Id) AR.get('revId');
            revAgrIdsDraft.put(revAgrrId,revAgrrId);
        }
        
        for(AggregateResult AR : [SELECT Revenue_Agreement__r.Id revId,COUNT(Id)IdCount FROM blng__RevenueSchedule__c WHERE Revenue_Agreement__c =: orderRAMap.keyset() AND Sent_to_RMCS__c = FALSE AND Status__c = 'Active' AND blng__orderProduct__c != NULL AND blng__orderProduct__r.Order.Revenue_Agreement_Processed__c = TRUE AND blng__orderProduct__r.OrderId !=: orderIds GROUP BY Revenue_Agreement__r.Id ])
        {
            Id revAgrrId = (Id) AR.get('revId');
            revAgrIdsReady.put(revAgrrId,revAgrrId);
        }
        
        for(Revenue_Agreement__c RA : RAList)
        {
            orderId = orderRAMap.get(RA.Id);
            orderType = orderMap.get(orderId).Type;
            orderStatus = orderMap.get(orderId).Status;
            if((orderType == 'New' || orderType == 'Renewal' || (orderType == 'Amendment' && revAgrIds.get(RA.Id) == null && revAgrIdsReady.get(RA.Id) == null && revAgrIdsDraft.get(RA.Id) == null)) && orderStatus == 'Cancelled')
            {
                RA.Stage__c = 'Cancelled';
                Schema.DescribeSObjectResult d = Schema.SObjectType.Revenue_Agreement__c; 
                Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
                Schema.RecordTypeInfo rtByName =  rtMapByName.get('Cancelled');
                RA.RecordTypeId = rtByName.getRecordTypeId();
                RA.Reset__c = TRUE;
                RAUpdateList.add(RA);
            }
            if(orderType == 'Amendment')
            {
                /*if(revAgrIds.get(RA.Id) != null) // Commented the if block part of <I2C-1908>
                {
                    RA.Stage__c = 'Draft'; 
                    RA.Reset__c = TRUE;
                    RAUpdateList.add(RA);
                }*/
                //<I2C-1908> preventing the RA stage from getting overridden to DRAFT on amendment scenarios
                if(revAgrIdsDraft.get(RA.Id) == null && revAgrIdsReady.get(RA.Id) == null && revAgrIds.get(RA.Id) != null)
                {
                    RA.Stage__c = 'Sent to RMCS';
                    RA.Reset__c = TRUE;
                    RAUpdateList.add(RA);
                }
                else if(revAgrIdsDraft.get(RA.Id) == null && revAgrIdsReady.get(RA.Id) != null)
                {
                    RA.Stage__c = 'Ready';
                    RA.Reset__c = TRUE;
                    RAUpdateList.add(RA);
                }
                
            }
        }
                
          
         for(blng__RevenueSchedule__c RS : RSList)
         {
                RS.Status__c = 'Cancelled';
                RSUpdateList.add(RS);
         }
        
        
        try
        {
            if(RAUpdateList.size() > 0)
            update RAUpdateList;
            
            if(RSUpdateList.size() > 0)
            {
                SBQQ.TriggerControl.disable();//<T02>
                update RSUpdateList;
                SBQQ.TriggerControl.enable();
            }
            
            if(RAUpdateList.size() > 0)
            {
                for(Revenue_Agreement__c RA : RAUpdateList)
                    RA.Reset__c = FALSE;
                update RAUpdateList;
            }
        }
        catch(Exception e)
        {
            GAM.CreateExceptionRecords('Handle Cancel_Debook of Order on Revenue Agreement', e.getMessage(), 'error from revenueAgreementCancelFulfillDate');
        } 
        
       
    }
    public static void handleShipDate(Set<Id> orderIds)
    {
        Map<Id,Id> OrderFulNotComp = new Map<Id,Id> ();
        List<blng__RevenueSchedule__c> RSUpdateList = new List<blng__RevenueSchedule__c> ();
        
        for(blng__RevenueSchedule__c RS : [Select Id,Ship_Date__c,Deferred_Revenue_Acct_Date__c,blng__OrderProduct__c,blng__OrderProduct__r.OrderId,blng__OrderProduct__r.Ship_Date__c,Parent_RS__c,
                                            Parent_RS__r.blng__OrderProduct__c,Parent_RS__r.blng__OrderProduct__r.OrderId,Parent_RS__r.blng__OrderProduct__r.Ship_Date__c,
                                            blng__OrderProduct__r.Order.Provisioning_Complete_Date__c,Parent_RS__r.blng__OrderProduct__r.Order.Provisioning_Complete_Date__c,Status__c,Revenue_Agreement__r.Stage__c,Product__r.Provisionable_New__c,Parent_RS__r.Product__r.Provisionable_New__c
                                            from blng__RevenueSchedule__c where blng__OrderProduct__r.OrderId =: orderIds OR Parent_RS__r.blng__OrderProduct__r.OrderId =: orderIds])
        {
            if(RS.blng__OrderProduct__c != null)
            {
                RS.Deferred_Revenue_Acct_Date__c = RS.blng__OrderProduct__r.Order.Provisioning_Complete_Date__c;
            }
            
            if(RS.blng__OrderProduct__c == null && RS.Parent_RS__c != null)
            {
                RS.Deferred_Revenue_Acct_Date__c = RS.Parent_RS__r.blng__OrderProduct__r.Order.Provisioning_Complete_Date__c; 
            }
            
            RSUpdateList.add(RS);
        }
        
        if(RSUpdateList.size () > 0)
        {
            try
            {
                SBQQ.TriggerControl.disable();//<T02>
                update RSUpdateList;
                SBQQ.TriggerControl.enable();
            }
            catch(Exception e)
            {
                GAM.CreateExceptionRecords('ShipDate_Update_from_OP to RS', e.getMessage(), 'error from revenueAgreementCancelFulfillDate');
            }
            
        }
                                                              
        
    }
    
}