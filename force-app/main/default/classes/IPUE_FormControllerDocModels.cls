/*
    @Author:        Jiju N
    @Created Date:  May 2023
    @Description:   This is a helper class to hold all inner classes used in the IPUE_FormControllerDoc. 
                    This class is covered by IPUE_FormControllerDocTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.             Description                                                 Tag
    Jiju N              May 2023      SALESRT-14807        Model class for Document generation
    ********************************************************************************************************************************************
*/
public class IPUE_FormControllerDocModels {

    public class DataWrapper {
		@AuraEnabled public String accountName;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String estimationName;
        @AuraEnabled public String totalIPUs;
        @AuraEnabled public IPUE_FormControllerModels.Form form;
        @AuraEnabled public Decimal totalEstimation;
        @AuraEnabled public Map<Id, Estimation_Output__c> outputMap;
        @AuraEnabled public Map<Id, Integer> pageSectionTotalMap;
        @AuraEnabled public List<Id> pageSectionIds = new List<Id>();
        @AuraEnabled public List<Estimation_Summary_Line__c> estimationLines;
        @AuraEnabled public IPUE_FormControllerModels.DataWrapper formWrapper = new IPUE_FormControllerModels.DataWrapper();
        public Set<Id> tableCellSchedules = new Set<Id>();
        public Map<Id, IPUE_FormControllerModels.Table> tableByParentEstimationSchedule = new Map<Id, IPUE_FormControllerModels.Table>();
    }
}