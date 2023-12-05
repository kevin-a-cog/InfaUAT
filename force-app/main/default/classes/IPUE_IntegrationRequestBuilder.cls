/*
    @Author:        Stephanie Viereckl
    @Created Date:  Nov 4 2021
    @Description:   This builds the JSON Request string that is used in the IPUE_IntegrationService. The JSON Request is built
                    based off of the API Field Mapping records and Estimation Output records related to the Estimation Schedules
                    associated to a single Estimation Summary. This class is covered by IPUE_IntegrationRequestBuilderTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Description                                                 Tag

    Stephanie Viereckl Nov 2021     IPUE-105      Initial Create                     
    Evan Strohm        Nov 2021                   Refactored to handle variety of request data models
    Chandana Gowda     10-Mar-22    IPUE-220      Changed to without Sharing
    ********************************************************************************************************************************************
*/
public without sharing class IPUE_IntegrationRequestBuilder {

    public class ParsingException extends Exception {}

    public static Map<Id, String> buildRequest(Id estimationSummaryId){

        Set<Id> estimationScheduleIds = new Set<Id>();
        Set<Id> apiInformationIds = new Set<Id>();
        Map<Id, Estimation_Output__c> outputByScheduleIdMap = new Map<Id, Estimation_Output__c>();

        // Query out all Estimation Outputs related to an Estimation Summary
        List<Estimation_Output__c> estimationOutputs = [
            SELECT Id, Estimation_Schedule__c, User_Value__c, Estimation_Summary__r.Form__c
            FROM Estimation_Output__c
            WHERE Estimation_Summary__c = :estimationSummaryId
        ];

        Id formId;

        // Build a Map where the Key = Estimation Schedule Id, Value = Estimation Output
        for (Estimation_Output__c output : estimationOutputs) {
            outputByScheduleIdMap.put(output.Estimation_Schedule__c, output);
            formId = output.Estimation_Summary__r.Form__c;
        }

        // Query out all API Field Mapping records related to applicable Estimation Schedules
        List<API_Field_Mapping__c> relatedMappingList = [
            SELECT Id, API_Field_Name__c, Estimation_Schedule__c, API_Header__c
            FROM API_Field_Mapping__c
            WHERE Estimation_Schedule__c IN :outputByScheduleIdMap.keySet()
            AND Form__c = :formId
        ];

        // Using applicable Estimation Schedules, find all API Information Ids
        for (API_Field_Mapping__c fieldMapping : relatedMappingList) {
            apiInformationIds.add(fieldMapping.API_Header__c);
        }

        // Find all API Field Mapping records related to the API Information records that are "Request" Type
        List<API_Information__c> apiInformationList = [
            SELECT Id,
                (
                    SELECT Id, API_Field_Name__c, Estimation_Schedule__c, API_Header__c, Name, Value__c
                    FROM API_Field_Mappings__r
                    WHERE API_Field_Type__c = 'Request'
                )    
            FROM API_Information__c
            WHERE Id IN :apiInformationIds
        ];        

        // // Find all API Field Mapping records related to the API Information records that are "Request" Type
        // List<API_Field_Mapping__c> completeMappingList = [
        //     SELECT Id, API_Field_Name__c, Estimation_Schedule__c, API_Header__c, Name, Value__c
        //     FROM API_Field_Mapping__c
        //     WHERE API_Header__c IN :apiInformationIds
        //     AND API_Field_Type__c = 'Request'
        // ];

        Map<Id, String> jsonRequestByApiHeaderMap = new Map<Id, String>();

        for (API_Information__c apiInformation : apiInformationList) {

            Map<String, Object> jsonRequest = new Map<String, Object>();

            // Loop through every API Field Mapping and populate JSON Request Map
            for (API_Field_Mapping__c fieldMapping : apiInformation.API_Field_Mappings__r) {

                try {

                    decimal fieldValue = 0; // Default

                    // Find the User Value entered in the applicable Estimation Output
                    if (outputByScheduleIdMap.containsKey(fieldMapping.Estimation_Schedule__c) &&
                        outputByScheduleIdMap.get(fieldMapping.Estimation_Schedule__c).User_Value__c != null
                    ) {
                        fieldValue = Decimal.ValueOf(outputByScheduleIdMap.get(fieldMapping.Estimation_Schedule__c).User_Value__c);

                    // Otherwise, use the Field Mapping's default Value
                    } else if (fieldMapping.Value__c != null) {
                        fieldValue = Decimal.ValueOf(fieldMapping.Value__c);
                    }

                    // API Field Name should have complete object path (i.e. "data.ipu_cloud_peak"), therefore need to seperate by "."
                    List<String> keyList = fieldMapping.API_Field_Name__c.split('\\.');
                    Map<String, Object> currentMap = jsonRequest;

                    for (Integer i = 0; i < keyList.size() - 1; i++) {
                        if (!currentMap.containsKey(keyList[i])) {
                            currentMap.put(keyList[i], new Map<String, Object>());
                        }
                        currentMap = (Map<String, Object>) currentMap.get(keyList[i]);
                    }
                    currentMap.put(keyList[keyList.size() - 1], fieldValue);

                } catch (Exception ex) {

                    System.debug('Exception: ' + ex);
                    System.debug('Exception message: ' + ex.getMessage());
                    System.debug('Exception stack trace: ' + ex.getStackTraceString());
                    System.debug('Exception cause: ' + ex.getCause());

                    throw new ParsingException('API Field Mapping \'' + fieldMapping.Name + ' has an invalid API Field Name: ' + fieldMapping.API_Field_Name__c +
                                            '. Additional error details: ' + ex.getMessage());
                }

            }

            jsonRequestByApiHeaderMap.put(apiInformation.Id, JSON.serialize(jsonRequest));
        }

        return jsonRequestByApiHeaderMap;

    }

}