public with sharing class EC_AEMWrapper {
    
    /*@AuraEnabled
    public String actionId {get; set;}
    @AuraEnabled
    public String infaJourneyId {get; set;}
    @AuraEnabled
    public String title {get; set;}
    @AuraEnabled
    public String EngagementDetailUrl {get; set;}
    @AuraEnabled
    public Integer engagementUnit {get; set;}
    @AuraEnabled
    public String engagementTypeTag {get; set;}
    @AuraEnabled
    public String engagementId {get; set;}
    @AuraEnabled
    public Boolean isInternalEngagement {get; set;}*/

    @AuraEnabled
    public String engagementActionId {get; set;}
    @AuraEnabled
    public String title {get; set;}
    @AuraEnabled
    public List<String> adoptionStageTag {get; set;}
    @AuraEnabled
    public List<String> engagementProductTag {get; set;}
    @AuraEnabled
    public String URL {get; set;}
    @AuraEnabled
    public List<String> tags {get; set;}
    @AuraEnabled
    public String engagementUnit {get; set;}
    @AuraEnabled
    public String infaJourneyId {get; set;}
    @AuraEnabled
    public List<String> infaJourneyValue {get; set;}
    @AuraEnabled
    public List<String> engagementFocusAreaTag {get; set;}
    @AuraEnabled
    public String engagementOverview {get; set;}
    @AuraEnabled
    public List<String> engagementUseCaseTag {get; set;}
    @AuraEnabled
    public List<String> engagementTypeTag {get; set;}
    @AuraEnabled
    public List<String> engagementCategoryTag {get; set;}
    @AuraEnabled
    public String engagementId {get; set;}
    @AuraEnabled
    public String isInternalEngagement {get; set;}

}