global  class SupportAccountUpdateBatch implements Database.Batchable<sObject> {
    static final String BASIC_SUCCESS = 'Basic Success';

    global static globalApexManager GAM = new globalApexManager();

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Max_Number_of_Cases_Allowed__c,Success_Offering__c,Entitlement__c,Entitlement__r.StartDate,Entitlement__r.Enddate from Account where Success_Offering__c= :BASIC_SUCCESS and Entitlement__r.Enddate > TODAY';
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        //Update Case limit 
        if(Scope!= null&& scope.size()>0){
            SupportAccountService.updateSupportAccountBasicPack(scope);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        //Insert debug Logs
        GAM.CreateLogs('SupportAccountUpdateBatch--> finish','timestamp:' + System.now());
        GAM.InsertDebugLogs();
    }
   
}