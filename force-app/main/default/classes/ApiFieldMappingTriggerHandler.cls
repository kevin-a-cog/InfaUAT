/*
        Trigger:        ApiFieldMappingTrigger
        @Author:        Stephanie Viereckl
        @Created Date:  Nov 9 2021
        @Description:   Delete related Lightning Service Member records if API Field Mapping record is deleted.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Nov 9 2021  IPUE-110                        Initial Create                     
    ********************************************************************************************************************************************

   
*/

public with sharing class ApiFieldMappingTriggerHandler {

    public static void beforeDelete(List<API_Field_Mapping__c> oldList){
        deleteLightningServiceMembers(oldList);
    }

    /************* Helper Methods *************/

    private static void deleteLightningServiceMembers(List<API_Field_Mapping__c> oldList){

        List<Lightning_Service_Member__c> membersToDelete = [
            SELECT Id
            FROM Lightning_Service_Member__c
            WHERE API_Field_Mapping__c IN :oldList
        ];

        delete membersToDelete;

    }

}