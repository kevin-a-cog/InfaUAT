/*
Class:          CreateSubscriptionLineBatch 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Batch class for creating subscriptin line from subscriptions
****************************************************************************
MODIFIED BY   JIRA          DESCRIPTION                                                                       TAG
Pavithra V    AR-1395		To exclude MR, DaaS and OEM Oppty renewal from plan product notification.		 <T01>

*/

global class CreateSubscriptionLineBatch implements Database.Batchable<sObject>{
    
    global static globalApexManager GAM = new globalApexManager();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query; 
        query = 'SELECT Id,SBQQ__QuoteLine__c, CurrencyIsoCode ,SBQQ__Contract__r.Renewal_Type__c,SBQQ__Contract__c,SBQQ__Contract__r.Account.CSM_Segment__c,SBQQ__Contract__r.SBQQ__Order__c,SBQQ__Contract__r.SBQQ__Order__r.Plan_Products_Created__c,SBQQ__Product__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,Original_Annual_Recurring_Revenue__c,SBQQ__QuoteLine__r.Annual_Recurring_Revenue__c ,Amendment_ARR__c FROM SBQQ__Subscription__c WHERE '+Label.A2RPlanProductsBatchFilter+ + ' order by SBQQ__Contract__c' ; 
        return Database.getQueryLocator(query); /**<T01>**/
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> scope)
    {
        set<Id> setContractIds = new set<Id>();
        set<Id> setOrderIds = new set<Id>();
        
        if (scope != null && scope.size() > 0) {
            
            //Create copy of Subscription as Subscription Line 
            CreateSubscriptionLines.CreateNewSubscriptionLines(scope);
            
            //To Notify CSMs about contract processed and Update Orders
            for(SBQQ__Subscription__c sub:scope){
                if(sub.SBQQ__Contract__r.SBQQ__Order__c!=null && !sub.SBQQ__Contract__r.SBQQ__Order__r.Plan_Products_Created__c){
                    setOrderIds.add(sub.SBQQ__Contract__r.SBQQ__Order__c);
                }
                if(Sub.SBQQ__Contract__c!=null && sub.SBQQ__Contract__r.Account.CSM_Segment__c!=null && sub.SBQQ__Contract__r.Account.CSM_Segment__c != 'No CSM Required' && sub.SBQQ__Contract__r.Renewal_Type__c == 'SMG'){ /**<T01>**/
                    setContractIds.add(sub.SBQQ__Contract__c);
                }
            }
            
            //Make Chatterpost for all contracts processed
            if(!Global_Config__c.getInstance().Mute_Notifications__c && setContractIds!=null && setContractIds.size()>0)
                ContractNotification.NotifyCSMs(new List<Id>(setContractIds));
            
            //Update Orders as Plan products created
            if(setOrderIds!=null && setOrderIds.size()>0)
                CreateSubscriptionLines.UpdateOrders(new List<Id>(setOrderIds));
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Insert debug Logs
        GAM.CreateLogs('CreateSubscriptionLineBatch--> finish','timestamp:' + System.now());
        GAM.InsertDebugLogs();
    }
    
}