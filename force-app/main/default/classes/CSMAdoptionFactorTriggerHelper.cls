public with sharing class CSMAdoptionFactorTriggerHelper {
     /*
    Method Name : process after Update
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Adoption_Factor__c> newList,Map<Id,Adoption_Factor__c> oldMap){
        NotificationService.notify(newList, oldMap);
    }
     /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
    public void processAfterInsert(List<Adoption_Factor__c> newList,Map<Id, Adoption_Factor__c> oldMap){
        NotificationService.notify(newList, oldMap);
    }
}