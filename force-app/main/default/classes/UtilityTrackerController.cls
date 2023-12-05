/*
Author Name   : Narpavi Prabu 
Class Name    : UtilityTrackerController
Created Date  : 4/04/2023
Description   : Class to display the lwc component

Change History
****************************************************************************************************
ModifiedBy      Date        Requested By        Description               Jira No.       Tag
*/

public with sharing class UtilityTrackerController {


    /*Method to get the opty id*/
    @AuraEnabled(cacheable=false)
    public static sObject getOptyRecordID(String strRecordId) {
        Id myRecordId =strRecordId ;
        String sObjName = myRecordId.getSObjectType().getDescribe().getName();
        sObject sObj = Schema.getGlobalDescribe().get(sObjName).newSObject() ;
        if(String.isNotBlank(strRecordId)) {
            String soql = 'Select Id,Opportunity__c From ' + String.escapeSingleQuotes(sObjName) +' ' +
            'WHERE Id = \'' + String.escapeSingleQuotes(strRecordId) + '\' '; 
            sObj = Database.query(soql);
            System.debug('sObj'+sObj);

        }
        return sObj;
    }

/*Method to get the related tracked record and display*/
@AuraEnabled(cacheable = true)
public static List<Tracked_Details__c> getTrackedRecord(String recordId, Integer offSetCount){
    try {
        System.debug('recordId--'+recordId);
        system.debug('offset--->'+offSetCount);
        List<Tracked_Details__c> tracklst = [SELECT Id,sObjectAPI__c,Parent_Record_Id__c,Old_Value__c,New_Value__c,Object_Name__c,Field_Name__c,LastModifiedBy.Name,LastModifiedDate,CreatedDate
        FROM Tracked_Details__c    
        WHERE Parent_Record_Id__c = :recordId  order by CreatedDate Desc    
        OFFSET :offSetCount];
       System.debug('tracklst'+tracklst);
            return tracklst;
            
    } 
    
    catch (Exception e) {
        throw new AuraHandledException(e.getMessage());

    }
    
}

}