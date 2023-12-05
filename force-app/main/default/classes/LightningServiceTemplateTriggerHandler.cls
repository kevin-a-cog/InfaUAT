/*
        Trigger:        Lightning_Service_Template__c
        @Author:        Stephanie Viereckl
        @Created Date:  Nov 3 2021
        @Description:   Create and/or delete related Lightning Service Member records depending on the changes
        to the "Content" field. 

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Nov 3 2021  IPUE-110                        Initial Create                     
    ********************************************************************************************************************************************

   
*/

public with sharing class LightningServiceTemplateTriggerHandler {

    public static void afterInsert(List<Lightning_Service_Template__c> newList){
        reconcileLightningServiceMembers(newList, null);
    }

    public static void afterUpdate(List<Lightning_Service_Template__c> newList, Map<Id, Lightning_Service_Template__c> oldMap){
        reconcileLightningServiceMembers(newList, oldMap);
    }

    public static void beforeDelete(List<Lightning_Service_Template__c> oldList){
        deleteLightningServiceMembers(oldList);
    }

    /************* Helper Methods *************/

    private static void reconcileLightningServiceMembers(List<Lightning_Service_Template__c> newList,  Map<Id, Lightning_Service_Template__c> oldMap){

        Map<Id, Set<String>> fieldNamesByTemplateId = new Map<Id, Set<String>>();
        Set<String> allApiFieldMappingNames = new Set<String>();

        // Loop through triggered Lightning Service Templates and determine if changes to child Lightning Service Members are needed
        for (Lightning_Service_Template__c template : newList) {

            if (oldMap == null || template.Content__c != oldMap.get(template.Id).Content__c) {

                Set<String> names = new Set<String>();

                if (template.Content__c != null) {

                    // Strip any html formatting from rich text field
                    String contentWithoutHTML = template.Content__c.replaceAll('<[^>]+>',' ');
                    // Remove any special characters except the "$" and "_" which are both used in the Name
                    contentWithoutHTML = contentWithoutHTML.replaceAll('[^a-zA-Z0-9_$\\s+]',' ');

                    for (String splitString : contentWithoutHTML.split(' ')) {
                        if (splitString.startsWith('$')) {
                            names.add(splitString.substringAfterLast('$'));  // Get String after last "$" in case a $ prefixes the template content
                        }
                    }
    
                }

                // Create a Map where Key = Template Id, Value is List of Field Names parsed from the "Content"
                fieldNamesByTemplateId.put(template.Id, names);
                // Add all Names to Set in order to query out the Field API Mapping records later
                allApiFieldMappingNames.addAll(names);

            }


        }

        if (!fieldNamesByTemplateId.isEmpty()) {

            Map<String, API_Field_Mapping__c> fieldMappingByName = new Map<String, API_Field_Mapping__c>();
            Set<String> duplicateNames = new Set<String>();
            List<Lightning_Service_Member__c> lightningMembersToInsert = new List<Lightning_Service_Member__c>();
            Map<String, Lightning_Service_Member__c> existingLightningMemberMap = new Map<String, Lightning_Service_Member__c>();
            Set<Id> existingLightningMemberIds = new Set<Id>();

            List<API_Field_Mapping__c> fieldMappingList = [
                SELECT Id, Name,
                    (
                        SELECT Id, Name, API_Field_Mapping__c, Lightning_Service_Template__c
                        FROM Lightning_Service_Members__r
                    )
                FROM API_Field_Mapping__c
                WHERE Name IN :allApiFieldMappingNames
                AND API_Field_Type__c = 'Response'
            ];
    
            for (API_Field_Mapping__c fieldMapping : fieldMappingList) {
    
                // If the API Field Name has already been added, update duplicateName list
                if (fieldMappingByName.containsKey(fieldMapping.Name)) {
                    duplicateNames.add(fieldMapping.Name);
                }   
    
                // Update Map where Key = Field Mapping Name and Value = Field Mapping sObject
                fieldMappingByName.put(fieldMapping.Name, fieldMapping);

                // Create Map where Key = API Field Mapping Id + Lightning Service Id, value = Service Member
                for (Lightning_Service_Member__c member : fieldMapping.Lightning_Service_Members__r) {
                    String key = member.API_Field_Mapping__c + '|' + member.Lightning_Service_Template__c;
                    existingLightningMemberMap.put(key, member);
                }
    
            }

            // Loop through triggered records and determine if any changes are needed to Lightning Service Members
            for (Lightning_Service_Template__c template : newList) {

                if (fieldNamesByTemplateId.containsKey(template.Id)) {

                    List<String> fieldNameList = new List<String>(fieldNamesByTemplateId.get(template.Id));

                    for (String fieldName : fieldNameList) {
    
                        if (duplicateNames.contains(fieldName)) {
    
                            template.addError('Reference error: Multiple API Field Mapping records found for "' + fieldName + '"');
    
                        } else if (!template.hasErrors() && fieldMappingByName.containsKey(fieldName)) {

                            String key = fieldMappingByName.get(fieldName).Id + '|' + template.Id;
                            
                            // If a Lightning Service Member doesn't already exist, create one
                            if (!existingLightningMemberMap.containsKey(key)) {

                                Lightning_Service_Member__c member = new Lightning_Service_Member__c();
                                member.Name = template.Name + ' | ' + fieldName; 
                                member.API_Field_Mapping__c = fieldMappingByName.get(fieldName).Id;
                                member.Lightning_Service_Template__c = template.Id;
            
                                lightningMembersToInsert.add(member);

                            // Otherwise, add this Lightning Service Member to a Set of already existing ids
                            } else {
                                existingLightningMemberIds.add(existingLightningMemberMap.get(key).Id);
                            }

                        }
                    }
                }

            }

            Set<Id> templatesWithoutErrors = new Set<Id>();

            for (Lightning_Service_Template__c template : newList) {
                if (!template.hasErrors()) {
                    templatesWithoutErrors.add(template.Id);
                }
            }

            if (!templatesWithoutErrors.isEmpty()) {

                // Find all Lightning Service Members that do not have an error and aren't in the existing list
                List<Lightning_Service_Member__c> oldLightningMemberList = [
                    SELECT Id
                    FROM Lightning_Service_Member__c
                    WHERE Lightning_Service_Template__c IN :templatesWithoutErrors
                    AND Id NOT IN :existingLightningMemberIds
                ];

                // Delete the 
                if (!oldLightningMemberList.isEmpty()) {
                    delete oldLightningMemberList;
                }

                if (!lightningMembersToInsert.isEmpty()) {
                    insert lightningMembersToInsert;
                }

            }

        }

    }

    private static void deleteLightningServiceMembers(List<Lightning_Service_Template__c> oldList){

        List<Lightning_Service_Member__c> membersToDelete = [
            SELECT Id
            FROM Lightning_Service_Member__c
            WHERE Lightning_Service_Template__c IN :oldList
        ];

        delete membersToDelete;

    }

}