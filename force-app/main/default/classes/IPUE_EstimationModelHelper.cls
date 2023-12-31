/*
    @Author:        Advanced Technology Group
    @Created Date:  February 2022
    @Description:   This is the Controller for the ipueCreateEstimation LWC. This Apex Controller creates/clones the Estimation Summary,
                    Estimation Output and Estimation Summary line records.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.          Description                                                                             Tag

    Colton Kloppel    October 2021     IPUE-53          Initial Create
    Chandana Gowda    10-Mar-2022      IPUE-156         Added logic to clone Estimator collaborators and changed the class to without           <T1>
                                                        Sharing
    Saurabh Khandelwal  25-Mar-2022    IPUE-156         Added field for row number and column number and link Parent_Estimation_Schedule__c     <T2>
                                                        for the cloned est output in method cloneEstimationOutputLines.
    Chandana Gowda      8-dec-2022     PNP-448          Added check for existing Service Id before creating new Estimation summary line         <T3>
    Chandana Gowda      11/Jan/2022    SALESRT-14808    Enhance IPU calculation performance                                                     <T04>                                                   
    nibansal          07/03/2023     SALESRT-14945   Added Product Family and forecast product fields to update at the time of insertion of lines
    ********************************************************************************************************************************************
*/

public without sharing class IPUE_EstimationModelHelper {
    
    public class IPUE_EstimatorException extends Exception {}

    public static void createEstimationModel(Estimation_Summary__c newSummary){

        if(newSummary.Form__c != null){

            //Form based summaries need to be handled differently than Phase 1 Manual Upload summaries.
            updateRecordTypeForFormBasedSummary(newSummary);
            
            //Prepare Estimation_Outputs
            List<ConsumptionSchedule> consumptionScheduleList = ([
                SELECT Id, Name, Page_Section__c,
                Page_Section__r.Parent_Page__r.Id, Page_Section__r.Parent_Page__r.Parent_Form__r.Id, Rollup_Into_Estimation_Summary_Lines__c,
                Default__c, Consumption_Description__c,  Data_Type__c,
                    (
                        SELECT ProductId
                        FROM ProductConsumptionSchedules
                        LIMIT 1
                    )
                FROM ConsumptionSchedule
                WHERE Page_Section__r.Parent_Page__r.Parent_Form__r.Id = :newSummary.Form__c
                AND Active__c = true
            ]);
        
            if(!consumptionScheduleList.isEmpty()){
                //On inital created setFilledSections is null, all the sections are considered to be unfilled - <T04>
                Set<Id> product2Ids = createNewEstimationOutputs(newSummary, consumptionScheduleList,null);
                createNewEstimationSummaryLines(newSummary.Id, product2Ids);
            }
        }
    }
    /**
     * Added the parameter setFilledSections - holds the page sections that are already filled - <T04>
     */
    public static Set<Id> createNewEstimationOutputs(Estimation_Summary__c newSummary, List<ConsumptionSchedule> questionsOnFormList,Set<Id> setFilledSections){
        
        Set<Id> product2Ids = new Set<Id>();
        List<Estimation_Output__c> outputsToInsert = new List<Estimation_Output__c>();
        List<String> schedulesWithoutProducts = new List<String>();
        Map<Id, Table_Cell__c> tableCellByEstimationScheduleId = new Map<Id, Table_Cell__c>();
                
        Map<Id, Table_Cell__c> tableCellMap = new Map<Id, Table_Cell__c>([
            SELECT Id, Row_Number__c, Column_Number__c, Child_Estimation_Schedule__c,
            Child_Estimation_Schedule__r.Consumption_Description__c, Child_Estimation_Schedule__r.Data_Type__c,
            Child_Estimation_Schedule__r.Default__c, Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Active__c,

            Parent_Estimation_Schedule__r.Sequence__c
            FROM Table_Cell__c 
            WHERE Parent_Estimation_Schedule__c IN :questionsOnFormList
            OR Child_Estimation_Schedule__c IN :questionsOnFormList
        ]);


        // Populate Map where key = Child Estimation Schedule, value = table cell
        for (Table_Cell__c tableCell : tableCellMap.values()) {
            tableCellByEstimationScheduleId.put(tableCell.Child_Estimation_Schedule__c, tableCell);
        }

        //-------------------------------------------------------------------------------------<T3>
        Set<Id> setExistingServiceIds = new Set<Id>();
        for(Estimation_Summary_Line__c summaryLine:[SELECT Product__c FROM Estimation_Summary_Line__c WHERE Estimation_Summary__c =: newSummary.Id]){
            setExistingServiceIds.add(summaryLine.Product__c);
        }
        //-------------------------------------------------------------------------------------<T3/>
        

        // For every Consumption Schedule, create an Estimation Output record
        for(ConsumptionSchedule schedule : questionsOnFormList){
            
            Estimation_Output__c newOutput = new Estimation_Output__c();
            newOutput.Estimation_Summary__c = newSummary.Id;
            newOutput.Estimation_Schedule__c = schedule.Id;
            newOutput.Name = schedule.Name;
            newOutput.Form__c = newSummary.Form__c;
            newoutput.Page__c = schedule.Page_Section__r.Parent_Page__r.Id;
            newOutput.Page_Section__c = schedule.Page_Section__c;
            newOutput.Rollup_Into_Estimation_Summary_Lines__c = schedule.Rollup_Into_Estimation_Summary_Lines__c; 
            newOutput.User_Value__c = schedule.Default__c;
            newOutput.Original_Data_Type__c = schedule.Data_Type__c;
            
            //If the section is filled, update the checkbox field on new output record  - <T04>
            if(setFilledSections != null && setFilledSections.contains(schedule.Page_Section__c)){
                newOutput.Section_filled__c = true;
            }
    
            // If the Estimation Schedule is part of a table, populate fields from Table Cell record
            if (tableCellByEstimationScheduleId.containsKey(schedule.Id)) {

                Table_Cell__c tableCell = tableCellByEstimationScheduleId.get(schedule.Id);
                newOutput.Table_Cell__c = tableCell.Id;

                // Only populate the following fields for Estimation Outputs that represent Table Cells within the Table
                if (schedule.Data_Type__c != IPUE_CONSTANTS.TABLE_FIXED && schedule.Data_Type__c != IPUE_CONSTANTS.TABLE_ELASTIC) {
                    newOutput.Parent_Estimation_Schedule__c = tableCell.Parent_Estimation_Schedule__c;
                    newOutput.Column_Number__c = tableCell.Column_Number__c;
                    newOutput.Row_Number__c = tableCell.Row_Number__c;
                }

            }

            // Populate ProductIds to create Estimation Summary Lines
            if (!schedule.ProductConsumptionSchedules.isEmpty() && schedule.ProductConsumptionSchedules[0].productId != null) {
                Id prodId = schedule.ProductConsumptionSchedules[0].productId;
                //<T3> - Added ExistingServiceIds check
                if(!setExistingServiceIds.contains(schedule.ProductConsumptionSchedules[0].productId)){
                    product2Ids.add(prodId);
                }
                newOutput.Product__c = prodId;
            } else if (schedule.Rollup_Into_Estimation_Summary_Lines__c && schedule.ProductConsumptionSchedules.isEmpty()) {
                schedulesWithoutProducts.add(schedule.Name);
            }
            
            outputsToInsert.add(newOutput);

        }   

        if (!schedulesWithoutProducts.isEmpty()) {
            String message = 'The following Estimation Schedule(s) do not have an associated Product Consumption Schedule: ' + String.join(schedulesWithoutProducts, ', ');
            throw new IPUE_EstimatorException(message);
        }

        insert outputsToInsert;
        return product2Ids;

    }

    public static void createNewEstimationSummaryLines(Id newSummaryId, Set<Id> product2Ids){
        
        List<Estimation_Summary_line__c> summaryLinesToInsert = new List<Estimation_Summary_line__c>();
        List<Product2> productList = [SELECT Id, Name, External_Id__c, Forecast_Product__c, Product_Family__c From Product2 WHERE Id IN: product2Ids];

        for (Product2 prod : productList){

            Estimation_Summary_Line__c newLine = new Estimation_Summary_Line__c();
            newLine.Service_ID__c = prod.External_Id__c;
            newLine.Product__c = prod.Id;
            newLine.Service_Name__c = prod.Name;
            newLine.Estimation_Summary__c = newSummaryId;            
            newLine.Forecast_Product__c = prod.Forecast_Product__c;
            newLine.Product_Family__c = prod.Product_Family__c;
            summaryLinesToInsert.add(newLine);

        }

        insert summaryLinesToInsert;

    }

    public static void updateRecordTypeForFormBasedSummary(Estimation_Summary__c newSummary){
        
        Id formBasedRecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Form Based').getRecordTypeId();
        newSummary.RecordTypeId = formBasedRecordTypeId;

        update newSummary;
    }

    /********************* Clone Functionality ************************/

    public static void cloneEstimationModel(Id newSummaryId, Id originalSummaryId, Boolean cloneCollaborators){
        
        matchEstimationSummaryRecordType(newSummaryId, originalSummaryId);
        cloneEstimationOutputLines(newSummaryId, originalSummaryId);
        cloneEstimationSummaryLines(newSummaryId, originalSummaryId);
        //------------------------------------------------------------<T1>
        if(cloneCollaborators){
            cloneEstimatorCollaborators(newSummaryId,originalSummaryId);
        }
        //------------------------------------------------------------</T1>

    }

    //------------------------------------------------------------<T1>
    //Copies Estimator collaborators to new Estimation Summary record    
    private static void cloneEstimatorCollaborators(Id newSummaryId, Id originalSummaryId){
        List<Estimator_Collaborator__c> lstEstimatorCollabsToInsert = new List<Estimator_Collaborator__c>();
        List<Estimator_Collaborator__c> existingEstimatorCollabs = [SELECT Id,Access__c,Contact__c,Dev_Community_User__c,Primary_Contact__c FROM Estimator_Collaborator__c WHERE Estimation_Summary__c = :originalSummaryId AND Active__c = true];

        for(Estimator_Collaborator__c collab:existingEstimatorCollabs){
            Estimator_Collaborator__c clonedCollab = collab.clone(false,true,false,false);
            clonedCollab.Estimation_Summary__c = newSummaryId;
            //removing user reference to allow call to ICRT
            clonedCollab.Dev_Community_User__c = null;
            lstEstimatorCollabsToInsert.add(clonedCollab);
        }

        if(!lstEstimatorCollabsToInsert.isEmpty()){
            insert lstEstimatorCollabsToInsert;
        }
    }
    //------------------------------------------------------------</T1>

    private static void cloneEstimationOutputLines(Id newSummaryId, Id originalSummaryId){
       
        List<Estimation_Output__c> outputLinesToInsert = new List<Estimation_Output__c>();

        // Query out the original Estimation Output Lines
        List<Estimation_Output__c> originalOutputLines = [
            SELECT Id, Estimation_Summary__c, Estimation_Schedule__c,Parent_Estimation_Schedule__c,Name, Form__c, Page__c, Page_Section__c, 
            Rollup_Into_Estimation_Summary_Lines__c, User_Value__c, Original_Question__c, Original_Data_Type__c, Product__c,Row_Number__c,
            Column_Number__c,Section_filled__c /**Added Section_filled__c to clone */
            FROM Estimation_Output__c
            WHERE Estimation_Summary__c = :originalSummaryId
        ];

        // For each Estimation Output Line, create a clone and associate it with the new Estimation Summary
        for (Estimation_Output__c originalLine : originalOutputLines) {
            
            Estimation_Output__c clonedLine = originalLine.clone(
                false,      // Preserve Id?
                true,       // Is Deep Clone?
                false,      // Preserve Read Only Time Stamps?
                false       // Perserve Auto-Number?
            );

            // Overwrite Cloned Fields
            clonedLine.Estimation_Summary__c = newSummaryId;
            clonedLine.Parent_Estimation_Schedule__c=originalLine.Parent_Estimation_Schedule__c;
            outputLinesToInsert.add(clonedLine);
        }

        insert outputLinesToInsert;
    }

    private static void cloneEstimationSummaryLines(Id newSummaryId, Id originalSummaryId){
        
        List<Estimation_Summary_Line__c> summaryLinesToInsert = new List<Estimation_Summary_Line__c>();
        
        // Query out the original Estimation Summary Lines
        List<Estimation_Summary_Line__c> originalSummaryLines = [
            SELECT Id, Name, Estimated_Quantity__c, Estimation_Summary__c,
            RecordTypeId, Required_IPUs__c, Service_ID__c, Service_Name__c,
            Unit_of_Measure__c, Product__c, Forecast_Product__c, Product_Family__c
            FROM Estimation_Summary_Line__c
            WHERE Estimation_Summary__c = :originalSummaryId
        ];

        // For each Estimation Summary Line, create a clone and associate it with the new Estimation Summary
        for (Estimation_Summary_Line__c originalLine : originalSummaryLines) {
            
            Estimation_Summary_Line__c clonedLine = originalLine.clone(
                false,      // Preserve Id?
                true,       // Is Deep Clone?
                false,      // Preserve Read Only Time Stamps?
                false       // Perserve Auto-Number?
            );

            // Overwrite Cloned Fields
            clonedLine.Estimation_Summary__c = newSummaryId;

            summaryLinesToInsert.add(clonedLine);
        }

        insert summaryLinesToInsert;
    }

    private static void matchEstimationSummaryRecordType(Id newSummaryId, Id originalSummaryid){
        Estimation_Summary__c oldSummary = [SELECT Id, RecordTypeId FROM Estimation_Summary__c WHERE Id = :originalSummaryid];
        Id originalRecordTypeId = oldSummary.RecordTypeId;
        Estimation_Summary__c newSummary = new Estimation_Summary__c(Id = newSummaryId, RecordTypeId = originalRecordTypeId);

        update newSummary; 
    }

}