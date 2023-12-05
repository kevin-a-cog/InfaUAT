public with sharing class psa_SubconEvalController {

    @AuraEnabled(Cacheable = true)
    public static List<pse__Assignment__c> fetchAssignments(String recId) {
        return [SELECT Id, Name, pse__End_Date__c, pse__Project__r.Name, pse__Project__r.pse__Project_Manager__r.Name, psa_Subcon_Evaluation_Sent__c FROM pse__Assignment__c WHERE pse__Resource__c = :recId];
    }

    @AuraEnabled
    public static string updateAssignments(Object data){
        List<pse__Assignment__c> assignmentsForUpdate = (List<pse__Assignment__c>)JSON.deserialize(JSON.serialize(data),List<pse__Assignment__c>.class);
        try {
            if(assignmentsForUpdate.size() > 0){
                Database.SaveResult[] saveResultList = Database.update(assignmentsForUpdate);
                if (saveResultList[0].isSuccess()) {
                    update assignmentsForUpdate;
                }
                return 'SUCCESS';
            }
            else{
                return 'No assignment record to process';
            }
        } 
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
}