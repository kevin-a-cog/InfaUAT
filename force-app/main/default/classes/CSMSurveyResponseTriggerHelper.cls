public with sharing class CSMSurveyResponseTriggerHelper {
     /*
    Method Name : process after Update
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Survey_Response__c> newList,Map<Id,Survey_Response__c> oldMap){
        NotificationService.notify(newList, oldMap);
    }
     /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
    public void processAfterInsert(List<Survey_Response__c> newList,Map<Id, Survey_Response__c> oldMap){
        NotificationService.notify(newList, oldMap);
    }
}