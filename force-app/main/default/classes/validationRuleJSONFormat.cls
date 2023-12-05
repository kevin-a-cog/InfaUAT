/*
Class:          validationRuleJSONFormat 
@Author:        Uday Gangula
@Created Date:  10/30/2023
@Description:   Supporting Class for ScheduleLimitsMonitoringAlerts 

Change History
*****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag
******************************************************************************************************************************
Uday Gangula		10/30/2023	Prasanth Sagar		SFPLAT-108; Automate Validation Rules to Clari on Oppty  <T01>
*/

public class validationRuleJSONFormat { //<T01>
    public Integer size;
    public Integer totalSize; 
    public boolean done;
    public QueryLocator queryLocator;
    public String entityTypeName;   //ValidationRule
    public ValidationRecordsResult[] records;
    
    class QueryLocator {
    }  
    
    public static validationRuleJSONFormat parse(String json){
        return (validationRuleJSONFormat) System.JSON.deserialize(json, validationRuleJSONFormat.class);
    }
    
    public class ValidationRecordsResult {
        public ValidationAttributes attributes;
        public String Id;
        public String ValidationName;
        public Validation_EntityDefinition EntityDefinition;
        public Validation_Metadata Metadata;
    }

    public class Validation_EntityDefinition {
        public ValidationAttributes attributes;
        public String DeveloperName;
    }

    public class Validation_Metadata {
        public String description;
        public String errorConditionFormula;      
        public String errorMessage;   
        public boolean active;
    }

    public class ValidationAttributes {
        public String type;
        public String url;
    }
}