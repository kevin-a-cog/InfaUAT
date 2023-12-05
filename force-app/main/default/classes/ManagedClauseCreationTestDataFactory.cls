@isTest

public class ManagedClauseCreationTestDataFactory {

    private class PickListInfo {
        public List<String> values {get; set;}
        public String defaultValue {get; set;}

        public picklistInfo(List<String> picklistValues, String defValue) {
            values = picklistValues;
            defaultValue = defValue;
        }
    }    

    private static PickListInfo getPickListInfo(SObjectField field) {
        String defaultValue = null;        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (pickListVal.isDefaultValue()) defaultValue = pickListVal.getLabel();
            pickListValuesList.add(pickListVal.getLabel());
        }
        return new PickListInfo(pickListValuesList, defaultValue);
    }    

    /*
    @description Given a picklist, returns the default value for profile or the first value is no default value is found.
    */
    public static String getPickListDefaultOrFirstValue(SObjectField field) {

        PickListInfo plInfo = getPickListInfo(field);
        if (plInfo == null || (plInfo.defaultValue == null && plInfo.values.IsEmpty())) 
            return null;

        if (plInfo.defaultValue != null) 
            return plInfo.defaultValue;
        else
            return plInfo.values[0];
    }

    /*
    @description Given a object, returns a map of all record types available for that object.
    */
    public static Map<Id, RecordTypeInfo> getObjectActiveAvailableRecordTypesMap(DescribeSObjectResult objectResult) {
        Map<Id, RecordTypeInfo> recordTypeIdToRecordTypeInfoMap = new Map<Id, RecordTypeInfo>();
        List<Schema.RecordTypeInfo> recordTypeInfos = objectResult.getRecordTypeInfos();
        for (Schema.RecordTypeInfo rti : recordTypeInfos) {
            if (rti.isActive() && rti.isAvailable()) {
                recordTypeIdToRecordTypeInfoMap.put(rti.getRecordTypeId(), rti);
            }
        }
        return recordTypeIdToRecordTypeInfoMap;
    }

    /*
    @description Given an object, returns the default record type of that object for the user profile. If not found, null is returned.
    */
    public static Id getDefaultRecordTypeforObject(DescribeSObjectResult objectResult) {
        for (RecordTypeInfo rti : getObjectActiveAvailableRecordTypesMap(objectResult).values()) {
            if (rti.isDefaultRecordTypeMapping()) {
                return rti.getRecordTypeId();
            }
        }
        return null;
    }    

    /*
    @description Given an string value and a data type, returns the value converted to that data type.
    */
    public static Object convertValue(String value, Schema.DisplayType fieldDataType) {
        if (fieldDataType == Schema.DisplayType.String || 
            fieldDataType == Schema.DisplayType.Picklist || 
            fieldDataType == Schema.DisplayType.Combobox || 
            fieldDataType == Schema.DisplayType.Email || 
            fieldDataType == Schema.DisplayType.URL || 
            fieldDataType == Schema.DisplayType.Phone || 
            fieldDataType == Schema.DisplayType.MultiPicklist || 
            fieldDataType == Schema.DisplayType.TextArea) {
            return value;
        }
        else if (fieldDataType == Schema.DisplayType.Boolean) { 
            return Boolean.valueOf(value);
        }
        else if (fieldDataType == Schema.DisplayType.Id) {
            return Id.valueOf(value);
        }
        else if (fieldDataType == Schema.DisplayType.Double || fieldDataType == Schema.DisplayType.Currency || fieldDataType == Schema.DisplayType.Percent) {
            return Double.valueOf(value);
        }
        else if (fieldDataType == Schema.DisplayType.Time) {
            List<String> timeElements = value.split(':');
            Time configuredTimeValue;
            if (timeElements.size() == 1)
                configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), 0, 0, 0);
            else if (timeElements.size() == 2)
                configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), Integer.valueOf(timeElements[1]), 0, 0);            
            else if (timeElements.size() == 3)
                configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), Integer.valueOf(timeElements[1]), Integer.valueOf(timeElements[2]), 0);
            else if (timeElements.size() == 4)
                configuredTimeValue = Time.newInstance(Integer.valueOf(timeElements[0]), Integer.valueOf(timeElements[1]), Integer.valueOf(timeElements[2]), Integer.valueOf(timeElements[3]));            
            else
                return null;
            return configuredTimeValue;
        }
        else if (fieldDataType == Schema.DisplayType.Date) {
            return Date.valueOf(value);
        }
        else if (fieldDataType == Schema.DisplayType.DateTime) {
            return DateTime.valueOf(value);
        }
        else {
            return null;
        }       
    }

    /*
    @description Given the input parameters, creates a clause bundle for with that parameters.
    */
    public static void createClauseBundle(String cbName, String cbDescription, Integer numClausesPerBundle, ManagedClauseCreationService.MappingInfo clauseBundleMappingInfo) {

        if (numClausesPerBundle == 0) return;
        
        // Create clauses
        List<APXT_Redlining__Clause__c> clauses = new List<APXT_Redlining__Clause__c>();
        for (Integer i = 0; i < numClausesPerBundle; i++) {
            Integer j = i + 1;            
            APXT_Redlining__Clause__c clause = new APXT_Redlining__Clause__c(
                Name = 'Test Clause ' + j,
                APXT_Redlining__Text__c = 'Test Clause Text',
                APXT_Redlining__Text_Rich__c = 'Test Clause Text'
            );
            clauses.add(clause);
        }
        insert clauses;
        //Added for Test Class Fix - CPQ Upgrade - Start
        APXT_Redlining__Clause_Configuration__c clauseConfig = new APXT_Redlining__Clause_Configuration__c();
        clauseConfig.APXT_Redlining__Clause__c = clauses[0].Id;
        insert clauseConfig;
        //Added for Test Class Fix - CPQ Upgrade - End
        // Create clause bundle
        APXT_Redlining__Clause_Bundle__c clauseBundle = new APXT_Redlining__Clause_Bundle__c(Name = cbName, APXT_Redlining__Description__c = cbDescription);
        String targetObjectName = Schema.SOBjectType.APXT_Redlining__Clause_Bundle__c.getName();
        for (ManagedClauseCreationService.MappingParameter mp : clauseBundleMappingInfo.bundleSelectionCriterias) {
            if (mp.value != null) {
                Object fieldValue = convertValue(mp.value, ManagedClauseCreationService.getObjectFieldType(targetObjectName, mp.targetFieldName));
                clauseBundle.put(mp.targetFieldName, fieldValue);
            } 
            else if (mp.required) {
                if (ManagedClauseCreationService.getObjectFieldType(targetObjectName, mp.targetFieldName) == Schema.DisplayType.Boolean) {
                    clauseBundle.put(mp.targetFieldName, true);                
                }
            }
        }
        insert clauseBundle;
        
        // Create bundled clauses
        List<APXT_Redlining__Bundle_Clause__c> bundledClauses = new List<APXT_Redlining__Bundle_Clause__c>();
        Integer order = 0;
        
        for (APXT_Redlining__Clause__c clause : clauses) {
            APXT_Redlining__Bundle_Clause__c bc = new APXT_Redlining__Bundle_Clause__c(
                APXT_Redlining__Clause_Bundle__c = clauseBundle.Id, 
                APXT_Redlining__Clause__c = clause.Id,
                APXT_Redlining__Order__c = order++,
                //Added for Test Class Fix - CPQ Upgrade - Start
                APXT_Redlining__Clause_Configuration__c = clauseConfig.Id
                //Added for Test Class Fix - CPQ Upgrade - End
            );           
            
            bundledClauses.add(bc);
        }
        insert bundledClauses;
    }
}