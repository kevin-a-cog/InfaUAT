/*
    Class:          CSMUpdateSuccessPortfolioBatch
    @Author:        Karthi Gurusamy
    @Created Date:  24/02/2023
    @Description:   Batch class to update Account Success Portfolio based on latest Territory assignment 
    @Test Class :   CSMUpdateSuccessPortfolioBatchTest

Change History
*******************************************************************************************************************************************************
ModifiedBy            Date          Requested By             Description                                                           Tag
*******************************************************************************************************************************************************
Karthi G             24-Feb-2023    AR-3107             Batch class to update Success Portfolio based on Territory changes      Initial version                        
Karthi G             11-Sep-2023    AR-3155             Logic changes to include accounts changed to Customer Account for 
                                                        Success portfolio population                                            <T1>                       
*******************************************************************************************************************************************************
*/
global class CSMUpdateSuccessPortfolioBatch  implements Database.Batchable<sObject>, Database.Stateful{
    global static globalApexManager GAM = new globalApexManager();
    Datetime startTime = System.now();
    CSM_Static_Values__c lastExecution;    
    Datetime lastExecTime;

    public Database.QueryLocator start(Database.BatchableContext bc){
        
        lastExecution = CSM_Static_Values__c.getInstance('Success Portfolio Last Batch Execution');

        if(lastExecution==null || lastExecution.Value__c==null || lastExecution.Value__c==''){
            lastExecution=new CSM_Static_Values__c(Name='Success Portfolio Last Batch Execution');
            lastExecTime=Datetime.valueOf('2017-01-09 00:00:00');
        }
        else{
            lastExecTime=Datetime.valueOf(lastExecution?.Value__c);
        }

        //<T1>
        Set<Id> setConvertedAccounts = new Set<Id>();
        //Identify the record type changed accounts by querying Account history
        for(AccountHistory objAH : [select Id, NewValue, AccountId from AccountHistory where Field ='RecordType' AND Account.RecordType.Name = 'Customer Account' AND CreatedDate >=:lastExecTime LIMIT 10000]){
            if(objAH.NewValue!=null && objAH.NewValue =='Customer Account'){
                setConvertedAccounts.add(objAH.AccountId );
            }
        }
        //</T1>

        CSM_Static_Value__mdt mc = [Select Id,Value_Long_text__c from CSM_Static_Value__mdt WHERE developerName ='CSMUpdateSuccessPortfolioBatch_Query' LIMIT 1];
        String query = mc?.Value_Long_text__c;
        system.debug(query);
        if(query==null || query ==''){
            query='SELECT Id,AssociationCause, ObjectId, SobjectType, Territory2.Region__c,LastModifiedDate, Object.RecordType.Name from ObjectTerritory2Association where Object.RecordType.Name =\'Customer Account\' AND (LastModifiedDate >=:lastExecTime OR ObjectId IN :setConvertedAccounts) order by LastModifiedDate desc';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<ObjectTerritory2Association> scope){
        Map<String, String>  spmMapping = new Map<String, String>();
        List<Account> accUpdateList = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        
        for(Success_Portfolio_and_Region_Mapping__mdt spm : [select Id,Region__c, Success_Portfolio__r.Success_Portfolio__c from Success_Portfolio_and_Region_Mapping__mdt]){
            spmMapping.put(spm.Region__c, spm.Success_Portfolio__r.Success_Portfolio__c);
        }

        for(ObjectTerritory2Association ota : scope){
            if(!accIdSet.contains(ota.ObjectId)){
                Account acc=new Account(Id=ota.ObjectId);
                acc.Success_Portfolio__c = spmMapping.get(ota.Territory2.Region__c);
                system.debug(acc.Success_Portfolio__c);
                accUpdateList.add(acc);
                accIdSet.add(ota.ObjectId);
            }
        
        }
        system.debug(accUpdateList);
        if(!accUpdateList.isEmpty()){
            try{
                Database.SaveResult[] saveResult = Database.update(accUpdateList, false);         
                for (Database.SaveResult sr : saveResult) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            GAM.CreateExceptionRecords('CSMUpdateSuccessPortfolioBatch.execute', 'Error while updating Account success portfolio: ','Id: '+ sr.getId() + err.getStatusCode() + ': ' + err.getMessage()+ ': ' +err.getFields());
                        }
                    }
                }    
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('CSMUpdateSuccessPortfolioBatch.execute', 'Error while updating Account success portfolio: ', e.getMessage());
            } 
        }
    }
    
    public void finish(Database.BatchableContext bc){
        Set<String> portfolioSet = new Set<String>();
        for(Success_Portfolio_Manager_Mappings__mdt spm:[Select Id, Success_Portfolio__c, Manager_Email__c from Success_Portfolio_Manager_Mappings__mdt where SystemModStamp >=:lastExecTime]){
            portfolioSet.add(spm.Success_Portfolio__c);
        }

        if(Test.isRunningTest()){
            portfolioSet.add('APAC');
        }

        if(!portfolioSet.isEmpty()){            
            CSMUpdateSuccessPortfolioManagerBatch btch= new CSMUpdateSuccessPortfolioManagerBatch(portfolioSet);
            Database.executeBatch(btch);
        }

        lastExecution.Value__c=String.valueof(startTime);
        upsert lastExecution;
        gam.CreateLogs('CreateSubscriptionLineBatch--> finish','timestamp:' + System.now());
        gam.InsertDebugLogs();
    }
     
}