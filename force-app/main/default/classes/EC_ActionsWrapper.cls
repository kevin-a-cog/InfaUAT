public with sharing class EC_ActionsWrapper {
    
    @AuraEnabled
    public String uniqueName {get; set;}
    @AuraEnabled
    public String label {get; set;}
    @AuraEnabled
    public String sobjectAPIName {get; set;}
    @AuraEnabled
    public String actionId {get; set;}
    @AuraEnabled
    public String recordType {get; set;}
    @AuraEnabled
    public String ownerQueue {get; set;}
    @AuraEnabled
    public List<EC_QuestionsWrapper> questions {get; set;}

    public class EC_QuestionsWrapper {

        @AuraEnabled
        public String Label {get; set;}
        @AuraEnabled
        public String Type {get; set;}
        @AuraEnabled
        public boolean Is_Required {get; set;}
        @AuraEnabled
        public String Type_Option {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public Integer Sort_Order {get; set;}
        @AuraEnabled
        public String Placeholder {get; set;}
        @AuraEnabled
        public String Tooltip {get; set;}
        @AuraEnabled
        public String FieldApiName {get; set;}
    }
}