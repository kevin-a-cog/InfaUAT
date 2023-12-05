/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.      Description                                                 Tag
    
    KAPIL TILWANI       22 JUNE 2023  SALESRT-16718 Added Active Form Query.       
    
    ********************************************************************************************************************************************
*/
public with sharing class IPUE_CreateEstimationPageController {
    public IPUE_CreateEstimationPageController() {

    }
    public class EstimationDataModel{
        @AuraEnabled public sObject sourceObject;
        @AuraEnabled public string sObjectType;
        @AuraEnabled public Estimation_Summary__c estimationSummary;
    }

    @auraEnabled(cacheable=true)
    public static EstimationDataModel getExistingData(Id sObjectId){
        EstimationDataModel existingData = new EstimationDataModel();
        
        existingData.sObjectType = sObjectId.getSObjectType().getDescribe().getName();

        String dynamicQueryFields = '';
        String dynamicFilter = '';

        if(existingData.sObjectType == 'Account'){

        } else if(existingData.sObjectType == 'Opportunity'){
            dynamicQueryFields = ', New_Org_Opportunity_Number__c, AccountId ';
        } else if(existingData.sObjectType == 'SBQQ__Quote__c'){
            dynamicQueryFields = ', New_Org_Opportunity_Number__c, SBQQ__Account__c, SBQQ__Opportunity2__c ';
        } else if(existingData.sObjectType == 'Estimation_Summary__c'){
            dynamicQueryFields = ', Account__c, Opportunity__c, Quote__c, Form__c, Form__r.Active__c ';
        }

        String queryString = 'SELECT Id ' + dynamicQueryFields +
                            'FROM ' + existingData.sObjectType + ' ' +
                            'WHERE Id = \'' + sObjectId + '\' '
                            + dynamicFilter + 'LIMIT 1';

        existingData.sourceObject = Database.Query(queryString);

        return existingData;
    }

    @auraEnabled
    public static Boolean checkForValidForm(String formIdSignature){
        try{
            Id castFormId = (Id) formIdSignature;
            String recordTypeString = castFormId.getSObjectType().getDescribe().getName();

            if(recordTypeString == 'Form__c'){
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @auraEnabled //Added additional parameter to clone collaborators
    public static Id createEstimationModel(Id estimationId, Id previousEstimationId,Boolean cloneCollaborators){
        System.debug('previousEstimationId: ' + previousEstimationId);
        
        if (previousEstimationId != null) {
            IPUE_EstimationModelHelper.cloneEstimationModel(estimationId, previousEstimationId,cloneCollaborators);
        } else {
            Estimation_Summary__c newSummary = [SELECT Id, Name, Form__c, Account__c, Opportunity__c, Quote__c FROM Estimation_Summary__c WHERE Id = :estimationId];
            IPUE_EstimationModelHelper.createEstimationModel(newSummary);
        }
        
        return estimationId;
    }
}