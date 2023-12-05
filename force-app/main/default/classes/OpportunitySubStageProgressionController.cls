/*
 * Name			:	OpportunitySubStageProgressionController
 * Author		:	VENKATESH BALLA
 * Created Date	: 	10/24/2023
 * Description	:	This LWC allows developers to manage substage progression UI.
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description									Tag
 **********************************************************************************************************
  VENKATESH BALLA		10/20/2023		SALESRT-17407   Additional changes to support Opportunity  N/A
 														substage progression.
 */
public with sharing class OpportunitySubStageProgressionController {
    @AuraEnabled
    public static Map<String, String> fetchSubStageMapping(Id recordId, String selectedSubStage){
        Opportunity_SubStage_Progression__mdt subProg;
        String subStage;
        String progressionType;
        if(String.isBlank(selectedSubStage)){
            subStage = [Select SubStage__c from Opportunity where Id = :recordId LIMIT 1].SubStage__c ;
            progressionType = 'Linear';
        }else{
            subStage = selectedSubStage;
            progressionType = 'Dynamic';
        }
        subProg = [SELECT Next_Substages__c FROM Opportunity_SubStage_Progression__mdt WHERE API_Name__c = :subStage AND Active__c = TRUE AND Progression_Type__c = :progressionType];
        Map<String, String> nextSubStageMapping = new Map<String, String>();
        if(subProg <> NULL && String.isNotBlank(subProg.Next_Substages__c)){
            for(String keyVal : subProg.Next_Substages__c.split(',')){
                List<String> keyValsList = keyVal.split(':');
                nextSubStageMapping.put(keyValsList[0], 'Required fields for '+keyValsList[1]);
            }
        }
        return nextSubStageMapping;
    }

    @AuraEnabled
    public static String fetchSubStageName(Id recordId){
        String newSubStage = [Select Substage__c from Opportunity where Id =:recordId LIMIT 1].Substage__c;
        return newSubStage;
    }
    
    @AuraEnabled
    public static Boolean isSubStageChanged(Id recordId, String currentSubStageName){
        String newSubStage = [Select Substage__c from Opportunity where Id =:recordId LIMIT 1].Substage__c;
        if (String.isBlank(currentSubStageName) || currentSubStageName == newSubStage)
            return false;
        else
            return true;
    }
    @AuraEnabled
    public static Map<String, String> getSubStagePicklistVals(){
        try {
            Map<String, String> options = new Map<String, String>();
            for (Opportunity_SubStage_Progression__mdt osp : [SELECT Sorting_Order__c,Label, API_Name__c, Progression_Type__c, Active__c FROM Opportunity_SubStage_Progression__mdt 
                                                                WHERE Progression_Type__c = 'Dynamic' AND Active__c = TRUE ORDER BY Sorting_Order__c ASC]) {
                options.put(String.valueOf(osp.Sorting_Order__c)+osp.API_Name__c, osp.Label);
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}