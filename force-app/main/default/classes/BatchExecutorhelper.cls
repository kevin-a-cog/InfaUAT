public with sharing class BatchExecutorhelper {
    @AuraEnabled(cacheable=true)
    public static List<String> getApexClasses() {
        List<String> classList = new List<String>();
        Limit_Monitoring_Parameter__mdt mdt = Limit_Monitoring_Parameter__mdt.getInstance('BatchClassesforExecution');
        classList.addAll(mdt.Parameter_Value__c.split(';'));
        return classList;
    }

    @AuraEnabled(cacheable=false)
    public static id executeclass(String className){
        Type classType = Type.forName(className);
        ID batchprocessid = database.executeBatch((Database.Batchable<sObject>)classType.newInstance(), 200);
        return batchprocessid;
    }

    @AuraEnabled
    public static string getStatus(String batchId){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus,JobType  from AsyncApexJob where Id=:batchId LIMIT 1];
        String msg = 'Status : '+a.Status+'.\r\n The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.';
        if(a.ExtendedStatus!=null){
            msg+='\r\n ExtendedStatus: ' + a.ExtendedStatus;
        }

        return msg;
    }
}