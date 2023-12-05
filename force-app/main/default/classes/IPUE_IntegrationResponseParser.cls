/**
 * Name         : IPUE_IntegrationResponseParser
 * Author       : Evan Strohm | ATG, Cognizant | evan.strohm@cognizant.com
 * Created Date : November 1, 2021
 * Description  : Handles processes for turning responses from integration endpoints into text to be displayed by front-end
 *
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Evan Strohm              11-01-2021      IPUE-52     Initial create
 * Chandana Gowda           10-Mar-22       IPUE-220    Changed to Without Sharing
 */
public without sharing class IPUE_IntegrationResponseParser {

    public static Map< /*Lightning_Service_Template*/ Id, IPUE_FormControllerModels.LightningServiceTemplate> formatTemplate(Set</*Page_Section__c*/ Id> sectionIds, List<String> jsonResponseList) {

        Map<Id, IPUE_FormControllerModels.LightningServiceTemplate> returnMap = new Map<Id, IPUE_FormControllerModels.LightningServiceTemplate>();

        // Find all Lightning Service Templates that are shown in the Page Sections and their child Lightning Service member records
        List<Lightning_Service_Template__c> lightningServiceTemplates = [
            SELECT Id, Name, Content__c, Page_Section__c,
                (
                    SELECT Id, Lightning_Service_Template__c, API_Field_Mapping__c, API_Field_Mapping__r.Id, API_Field_Mapping__r.Name,
                    API_Field_Mapping__r.API_Field_Name__c, API_Field_Mapping__r.API_Field_Type__c, API_Field_Mapping__r.Value__c
                    FROM Lightning_Service_Members__r
                    WHERE API_Field_Mapping__r.API_Field_Type__c = 'Response'
                )
            FROM Lightning_Service_Template__c
            WHERE Page_Section__c IN :sectionIds
            AND Sequence__c != null
        ];

		Map<String, Object> responseMapOriginal = new Map<String, Object>();
        Map<String, Object> responseMap = new Map<String, Object>();
        // Parse the response into a generic map for ease of access
        for (String jsonResponse : jsonResponseList) {
            responseMapOriginal.putAll((Map<String, Object>) JSON.deserializeUntyped(jsonResponse));
        }
        for (String jsonResponse : responseMapOriginal.keyset()) {
            if(jsonResponse == 'prediction'){
				responseMap = (Map<String, Object>) responseMapOriginal.get(jsonResponse);
            } else {
                responseMap = responseMapOriginal.clone();
            }
        }
        // For each Template, substitute the Content placeholders (i.e. $data.Account) with the value from the JSON Response
        for (Lightning_Service_Template__c serviceTemplate : lightningServiceTemplates) {

            Map<String, API_Field_Mapping__c> mappingsByName = new Map<String, API_Field_Mapping__c>();

            for (Lightning_Service_Member__c member : serviceTemplate.Lightning_Service_Members__r) {
                // Create a map where the key = API Field Mapping Name and the value is the API Field Mapping
                mappingsByName.put(member.API_Field_Mapping__r.Name, member.API_Field_Mapping__r);
            }

            String friendlyTemplate = serviceTemplate.Content__c.replaceAll('(\\p{Punct})', ' $1 ')    // Escape all punctuation marks
                                                                .replaceAll(' \\$ ', '\\$')            // Delete the spaces around $'s we just added
                                                                .replaceAll(' _ ', '_');               // Delete the spaces around _'s we just added

            List<String> words = friendlyTemplate.split(' ');

            // Do the substitution
            for (Integer i = 0; i < words.size(); i++) {
                String word = words[i];

                // If the word starts with a $, then find the replacement
                if (!String.isBlank(word) && word.startsWith('$')) {

                    // Find the value from the response with the key described in the corresponding field mapping
                    word = word.substring(1);    // Cut off the leading '$'
                    API_Field_Mapping__c mapping = mappingsByName.get(word);

                    // Ignore variables without a mapping, they're most likely "$" literals
                    if (mapping != null) {
                        String mappedName = mapping.API_Field_Name__c;    // Fetch the API name associated with that name
                        Object objValue = getValueFromJSON(responseMap, mappedName);
                        String value = objValue == null ? null : String.valueOf(objValue);

                        // If there wasn't a value in the response, and the mapping has a default value, use that instead
                        if (String.isBlank(value) && !String.isBlank(mapping.Value__c)) {
                            value = mapping.Value__c;
                        }

                        // Update the array with the value
                        words[i] = value;
                    }
                }
            }

            words.add(' ');

            // Update the return object
            String joined = String.join(words, ' ');

            // Recreate LightningServiceTemplate class to be used in LWC
            IPUE_FormControllerModels.LightningServiceTemplate returnTemplate = new IPUE_FormControllerModels.LightningServiceTemplate(
                serviceTemplate.Name,
                serviceTemplate.Id,
                serviceTemplate.Page_Section__c,
                null,
                null
            );

            returnTemplate.content = joined.replaceAll('\\$', ' \\$ ')          // Add spaces back around any remaining $'s
                                           .replaceAll('_', ' _ ')              // Add spaces back around any remaining _'s
                                           .replaceAll(' (\\p{Punct}) ', '$1')  // Remove all spaces we added around punctuation
                                           .trim();                             // Remove any extra spaces on the ends

            returnTemplate.contentFound = true;

            returnMap.put(serviceTemplate.Id, returnTemplate);

        }

        return returnMap;
    }

    // Traverse the JSON structure from the keys
    // Stores final results for better average performance
    public static Object getValueFromJSON(Map<String, Object> jsonMap, String key) {

        // Base cases
        String hash = JSON.serialize(jsonMap) + '|' + key;
        if (String.isBlank(key) || jsonMap == null || jsonMap.isEmpty()) {
            return null;
        } else if (preQueriedValues.containsKey(hash)) {
            return preQueriedValues.get(hash);
        }

        // Navigate the map
        List<String> keys = key?.split('\\.');

        Map<String, Object> currentMap = jsonMap;
        List<Object> currentList = null;
        for (Integer i = 0; i < keys?.size() - 1 && !(currentList == null && currentMap == null); i++) {

            Object obj = null;

            System.debug('currentList: ' + currentList);
            System.debug('currentMap: ' + currentMap);
            System.debug('keys[i]: ' + keys[i]);

            if (currentMap != null) {
                obj = currentMap.get(keys[i]);
            } else if (keys[i] != null && keys[i].isNumeric()) {    // currentList != null by loop condition
                Integer index = Integer.valueOf(keys[i]);
                if (index < currentList.size()) {
                    obj = currentList.get(index);
                }
            }

            if (obj instanceOf Map<String, Object>) {
                    currentMap = (Map<String,Object>) obj;
                    currentList = null;
            } else if (obj instanceOf List<Object>) {
                    currentList = (List<Object>) obj;
                    currentMap = null;
            } else {
                currentMap = null;
                currentList = null;
            }
        }

        Object value = null;
        String finalKey = keys[keys.size() - 1];
        if (currentMap != null) {
            value = currentMap.get(finalKey);
        } else if (currentList != null) {
            Integer index = Integer.valueOf(finalKey);
            if (currentList.size() > index) {
                value = currentList.get(index);
            }
        }
        preQueriedValues.put(hash, value);   // Note the value for future queries
        return value;
    }

    private static Map<String, Object> preQueriedValues = new Map<String, Object>();

}