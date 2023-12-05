/*
    @Author:        Jiju N
    @Created Date:  May 2023
    @Description:   This is the Controller for the IpueEstimatorHostDoc LWC. This Apex Controller builds the
    Form Data. This class is covered by IPUE_FormControllerDocTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.             Description                                                 Tag
    Jiju N              May 2023      SALESRT-14807        Model class for Document generation
    ********************************************************************************************************************************************
*/
public class IPUE_FormControllerDoc {
    /*
     * method fetchDocFormData
     * @param recordId: Id of the Estimation Summary the LWC was called from
     * @description: Query out all Form related data and put into a map structure equivalent to the
     *               sObject Model, but more flexible and ready to use in the LWC.
     */
    @AuraEnabled
    public static IPUE_FormControllerDocModels.DataWrapper fetchDocFormData(Id recordId) {
        try {
            IPUE_FormControllerDocModels.DataWrapper wrapper = new IPUE_FormControllerDocModels.DataWrapper();
            Estimation_Summary__c summary = [
                SELECT Id, Form__c, Account__r.name, Opportunity__c, Opportunity__r.Owner.name,Opportunity__r.StageName, Total_Required_IPUs__c, Name
                FROM Estimation_Summary__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            if (summary.Form__c != null) {
                wrapper.accountName = summary.Account__r.name;
                wrapper.ownerName = summary.Opportunity__r.Owner.name;
                wrapper.estimationName = summary.Name;
                wrapper.totalIPUs = String.valueOf(summary.Total_Required_IPUs__c);
                wrapper.estimationLines = [SELECT Id, Service_Name__c, Required_IPUs__c FROM Estimation_Summary_Line__c WHERE Estimation_Summary__c =:recordId AND Required_IPUs__c != 0 AND Required_IPUs__c !=null];
                String stageName = summary.Opportunity__r.StageName;
                wrapper.formWrapper.oppModel = new IPUE_FormControllerModels.OppDataModel(summary.Opportunity__c);
                

                
                // Query Form__c records, create Form model, and add Form to wrapper
                IPUE_FormControllerHelper.createForm(summary, wrapper.formWrapper);

                // Query Page__c records, create Page models, and return Map of PageWrapper by Page Ids
                Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById = IPUE_FormControllerHelper.createPages(wrapper.formWrapper.form.id);       

                // Query SDoc_Template__c records, create SDocButton models, and add to pagesById variable
                IPUE_FormControllerHelper.createSDocTemplates(pagesById);

                // Query Page_Frame__c records, create Frame models, add to pagesById variable and return Map of Frames by Frame Ids
                Map<Id, IPUE_FormControllerModels.Frame> pageFramesById = IPUE_FormControllerHelper.createPageFrames(pagesById);        

                // Query Page_Section__c records, create Page Section models, add to pageFramesById and return Map of Page Sections by Section Ids
                Map<Id, IPUE_FormControllerModels.PageSection> pageSectionsById = IPUE_FormControllerHelper.createPageSections(pageFramesById, wrapper.formWrapper);

                // If the related Opportunity is not closed, create any new Estimation Outputs and Estimation Summary Lines that are needed
                if (!wrapper.formWrapper.oppModel.isClosed) {
                    IPUE_FormControllerHelper.createMissingOutputsAndSummaryLines(pageSectionsById.keySet(), summary);
                }

                // Query out Consumption Schedule Records related to Estimation Summary <T2>
                Map<Id, ConsumptionSchedule> scheduleMap = IPUE_FormControllerHelper.getEstimationSchedules(summary.Id,pageSectionsById.keySet());

                // Query Table_Cell__c records and build Table model and add to the wrapper to be used in createSectionItems()
                // IPUE_FormControllerHelper.createTables(scheduleMap, wrapper);
                IPUE_FormControllerHelper.buildTableFromConsumptionSchedules(scheduleMap, wrapper.formWrapper, wrapper.formWrapper.oppModel.isClosed);
                IPUE_FormControllerHelper.sortTableRowsAndCells(wrapper.formWrapper);

                // For each Consumption Schedule, create EstimationSchedule or Table models
                // Query out Lightning_Service_Template__c records, create LightningServiceTemplate models
                // Create Section Items for Estimation Schedules, Lightning Service Template and Table, sort, and add them to pageSectionsByIds
                IPUE_FormControllerHelper.createSectionItems(pageSectionsById, scheduleMap, wrapper.formWrapper);

                // Remove values that are no longer needed
                wrapper.tableCellSchedules = null;
                wrapper.tableByParentEstimationSchedule = null;

                // Add the Page object (and all child objects) to the Form
                wrapper.formWrapper.form.pages = pagesById.values();
                
               

                return wrapper;
            } else {
                return null;
            }
         } catch (Exception ex) {
            System.debug('Exception: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());
            throw new AuraHandledException('Error fetching Form data: ' + ex.getMessage());
        }
    }
}