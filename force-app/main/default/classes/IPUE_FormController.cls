/*
    @Author:        Advanced Technology Group
    @Created Date:  October 2021
    @Description:   This is the Controller for the ipueEstimatorHost LWC. This Apex Controller fetches and builds the
    Form Data, processes User inputs, and makes a call to the IPU Integration. This class is covered by IPUE_FormControllerTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                 Tag

    Colton Kloppel        October 2021  IPUE-53         Initial Create
    Chandana Gowda        10-Mar-2022   IPUE-156        Check if the user has read only access to the Estimator       <T1>
    Chandana Gowda        10-Mar-2022   IPUE-220        Move the consumption schedule query to helper class           <T2>
    Saurabh Khandelwal    10-Mar-2022   IPUE-160        Added internal user check .                                   <T3>
    Chandana Gowda        22-Mar-2022   IPUE-161        Added Status check to set wrapper.hasReadOnlyAccess           <T4>
    Chandana Gowda       11/Jan/2022    SALESRT-14808   Enhance IPU calculation performance                           <T05>
    ********************************************************************************************************************************************
*/

public with sharing class IPUE_FormController {

    public class FetchFormDataException extends Exception {}

    /*
     * method fetchFormData
     * @param recordId: Id of the Estimation Summary the LWC was called from
     * @description: Query out all Form related data and put into a map structure equivalent to the
     *               sObject Model, but more flexible and ready to use in the LWC.
     */
    @AuraEnabled
    public static IPUE_FormControllerModels.DataWrapper fetchFormData(Id recordId){
        try {

            IPUE_FormControllerModels.DataWrapper wrapper = new IPUE_FormControllerModels.DataWrapper();

            // Find the Estimation Summary passed from the LWC
            //Added Feed_Internal_User__c,Feed_External_User__c for chatter functionality.
            Estimation_Summary__c summary = [
                SELECT Id, Form__c, Account__c, Opportunity__c, Total_Required_IPUs__c,Feed_Internal_User__c,Feed_External_User__c,Status__c
                FROM Estimation_Summary__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            if (summary.Form__c != null) {

                // Set fields on wrapper
                wrapper.accountModel = new IPUE_FormControllerModels.AccountDataModel(summary.Account__c);
                wrapper.oppModel = new IPUE_FormControllerModels.OppDataModel(summary.Opportunity__c);
                wrapper.totalEstimation = summary.Total_Required_IPUs__c;

                //checking if user is internal
                wrapper.isUserInternal=UserInfo.getUserType()=='Standard' ? true : false;

                //checking if logged in user is internal or external and
                //setting custom class for the chatter icon
                if(UserInfo.getUserType()=='Standard' && summary.Feed_Internal_User__c){
                    wrapper.chatterIconClass='svgClass';
                }else{
                    //checking for external user.
                    if(summary.Feed_External_User__c){
                        wrapper.chatterIconClass='svgClass';
                    }
                }

                //Checking if the user has read only access 
                //-------------------------------------------<T1>
                UserRecordAccess recordAccess = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
                //Added status check to check make the estimator read only when status != drfat for external users
                if((!wrapper.isUserInternal && ((summary.Status__c == 'Draft' && !recordAccess.HasEditAccess) || (summary.Status__c != 'Draft'))) || summary.Status__c == 'Finalized Agreement' || wrapper.oppModel.isClosed){
                    wrapper.hasReadOnlyAccess = true;
                }
                //------------------------------------------<T1/>                

                // Query Form__c records, create Form model, and add Form to wrapper
                IPUE_FormControllerHelper.createForm(summary, wrapper);

                // Query Page__c records, create Page models, and return Map of PageWrapper by Page Ids
                Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById = IPUE_FormControllerHelper.createPages(wrapper.form.id);       

                // Query SDoc_Template__c records, create SDocButton models, and add to pagesById variable
                IPUE_FormControllerHelper.createSDocTemplates(pagesById);

                // Query Page_Frame__c records, create Frame models, add to pagesById variable and return Map of Frames by Frame Ids
                Map<Id, IPUE_FormControllerModels.Frame> pageFramesById = IPUE_FormControllerHelper.createPageFrames(pagesById);        

                // Query Page_Section__c records, create Page Section models, add to pageFramesById and return Map of Page Sections by Section Ids
                Map<Id, IPUE_FormControllerModels.PageSection> pageSectionsById = IPUE_FormControllerHelper.createPageSections(pageFramesById, wrapper);

                // If the related Opportunity is not closed, create any new Estimation Outputs and Estimation Summary Lines that are needed
                if (!wrapper.oppModel.isClosed) {
                    IPUE_FormControllerHelper.createMissingOutputsAndSummaryLines(pageSectionsById.keySet(), summary);
                }

                // Query out Consumption Schedule Records related to Estimation Summary <T2>
                Map<Id, ConsumptionSchedule> scheduleMap = IPUE_FormControllerHelper.getEstimationSchedules(summary.Id,pageSectionsById.keySet());

                // Query Table_Cell__c records and build Table model and add to the wrapper to be used in createSectionItems()
                // IPUE_FormControllerHelper.createTables(scheduleMap, wrapper);
                IPUE_FormControllerHelper.buildTableFromConsumptionSchedules(scheduleMap, wrapper, wrapper.oppModel.isClosed);
                IPUE_FormControllerHelper.sortTableRowsAndCells(wrapper);

                // For each Consumption Schedule, create EstimationSchedule or Table models
                // Query out Lightning_Service_Template__c records, create LightningServiceTemplate models
                // Create Section Items for Estimation Schedules, Lightning Service Template and Table, sort, and add them to pageSectionsByIds
                IPUE_FormControllerHelper.createSectionItems(pageSectionsById, scheduleMap, wrapper);

                // Remove values that are no longer needed
                wrapper.tableCellSchedules = null;
                wrapper.tableByParentEstimationSchedule = null;

                // Add the Page object (and all child objects) to the Form
                wrapper.form.pages = pagesById.values();
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

    /*
     * method processInput
     * @param formInputJSON: JSON string containing the Page Section that was updated in the LWC
     * @param formId: Form record Id
     * @param estimationId: Estimation Summary record Id
     * @description: This method is called from the LWC after the User enters values on the Estimation Output records.
     *               This method will call logic to dynamically calculate the User's input into Estimation Output records
     *               that have the "Calculated" type. In addition, these values will be rolled up to the Estimation Summary Line and
     *               Estimation summary objects.
     */
    @AuraEnabled
    public static IPUE_FormControllerModels.DataWrapper processInput(String formInputJSON, Id formId, Id estimationId){

        IPUE_FormControllerModels.DataWrapper wrapper = new IPUE_FormControllerModels.DataWrapper();
        Map<Id, Integer> pageSectionTotalMap = new Map<Id, Integer>();

        Map<Id, Estimation_Output__c> updatedAndCalculatedOutputs = IPUE_FormInputHelper.processInput(formInputJSON, formId, estimationId);

        for (Estimation_Output__c output : updatedAndCalculatedOutputs.values()) {

            if (output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.CALCULATED && output.Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c) {
                Integer total = 0;

                if (pageSectionTotalMap.containsKey(output.Page_Section__c)) {
                    total = pageSectionTotalMap.get(output.Page_Section__c);
                } 
                
                // If the calculation is from an unfilled section, default the value to 0 - <T05>
                total += output.User_Value__c != null ? Integer.valueOf(output.User_Value__c) : 0;
                pageSectionTotalMap.put(output.Page_Section__c, total);
            } 

        }

        wrapper.pageSectionTotalMap = pageSectionTotalMap;

        // Requery the Estimation Summary after triggers have run and rolled up the values
        Estimation_Summary__c summary = [
            SELECT Id, Total_Required_IPUs__c
            FROM Estimation_Summary__c
            WHERE Id = :estimationId
            LIMIT 1
        ];

        wrapper.totalEstimation = summary.Total_Required_IPUs__c;

        if(!updatedAndCalculatedOutputs.isEmpty()){
            wrapper.outputMap = updatedAndCalculatedOutputs;
        } else {
            System.debug('Error occured during processing of formInputJSON');
        }

        return wrapper;
    }

    /*
     * method callIntegrations
     * @param estimationId: Estimation Summary record Id
     * @param formId: Form record Id
     * @description: This method is called from the LWC when an Integration call should be made.
     */
    @AuraEnabled
    public static Map<Id,IPUE_FormControllerModels.LightningServiceTemplate> callIntegrations(Id estimationId, Id formId, List<Id> pageSectionIds){

        // Build JSON Request using API Field Mapping records related to the Form
        // Return a Map where the key = API Information Id, value = JSON Request String
        Map<Id, String> jsonRequestByApiHeaderMap = IPUE_IntegrationRequestBuilder.buildRequest(estimationId);
        Map<Id, String> jsonResponseByApiHeaderMap = new Map<Id, String>();

        // For each API, call IPU Integration API using the dynamically build JSON Request
        for (Id apiHeader : jsonRequestByApiHeaderMap.keySet()) {

            if (!Test.isRunningTest()) {
                String jsonResponseString = IPUE_IntegrationService.makeCallout(jsonRequestByApiHeaderMap.get(apiHeader), apiHeader);

                // Create map where key = API Information Id, value = JSON Response String
                jsonResponseByApiHeaderMap.put(apiHeader, jsonResponseString);
            }

        }

        // Using the Lightning Template Section and API Field Mapping records, dynamically parse the JSON Response and pass back to LWC to show to user
        // Return a Map where the key = Lightning Service Template Id, value = LigtningServiceTemplate (inner class)
        return IPUE_IntegrationResponseParser.formatTemplate(new Set<Id>(pageSectionIds), jsonResponseByApiHeaderMap.values());

    }

    /*
     * method updateElasticTableRows
     * @param tableId: Estimation Schedule record Id
     * @param action: Add or Remove Rows
     * @description: This method is called from the LWC when the User adds or removes a row in the elastic table
     */
    @AuraEnabled
    public static IPUE_FormControllerModels.Table updateElasticTableRows(Id estimationSummaryId, Id tableId, String action, Integer numRows, Integer numColumns, Integer rowIndex){

        if (action == 'Add Row') {
            return IPUE_FormControllerHelper.createOutputsAndAddTableRow(estimationSummaryId, tableId, numRows, numColumns);
        } else if (action == 'Remove Row') {
            return IPUE_FormControllerHelper.deleteOutputs(estimationSummaryId, tableId, rowIndex);
        } else {
            throw new AuraHandledException('Row action \'' + action + '\' is not a valid action.');
        }
        
    }
    /*
     * method checkForFeedItemExist
     * @param estimationId: Estimation Summary or Estimation output record Id
     * @param ObjectName: object api name
     * @description: This method is called to check for feed items.
     */
    @AuraEnabled
    public static Boolean checkForFeedItemExist(String recordId,String objectName){
 
        String query='SELECT Feed_External_User__c,Feed_Internal_User__c FROM '+objectName+' WHERE Id=:recordId LIMIT 1';

        sObject obj=Database.query(query);

        //if logged in user is standard salesforce user;
        if(UserInfo.getUserType()=='Standard'){
            if(obj.get('Feed_Internal_User__c')==true){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            if(obj.get('Feed_External_User__c')==true){
                return true;
            }
            else{
                return false;
            }
        }

    }


}