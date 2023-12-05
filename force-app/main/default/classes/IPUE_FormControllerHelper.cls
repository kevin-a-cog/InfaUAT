/*
    @Author:        Advanced Technology Group
    @Created Date:  February 2022
    @Description:   This is a helper class for the IPUE_FormController Class to organize logic. This class is covered by IPUE_FormControllerTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.          Description                                                                             Tag

    Stephanie Viereckl  Feb 2022      IPUE-153/193      Refactor into helper class for better organization
    Chandana Gowda      10-Mar-2022   IPUE-220          Added method getEstimationSchedules and changed the class to without sharing            <T1>
    Chandana Gowda      11/Jan/2022   SALESRT-14808     Enhance IPU calculation performance                                                     <T02> 
    KAPIL TILWANI       22 JUNE 2023  SALESRT-15017     Added Rich text fields the Query.
    ********************************************************************************************************************************************
*/
public without sharing class IPUE_FormControllerHelper {
    
    public class IPU_Estimator_Exception extends Exception {}

    //Query Consumption Schedule <T1>
    public static Map<Id, ConsumptionSchedule> getEstimationSchedules(Id summaryId,Set<Id> setPageSectionsId){                
        
        // Query out Consumption Schedule Records related to Estimation Summary
        Map<Id, ConsumptionSchedule> scheduleMap = new Map<Id, ConsumptionSchedule>([
            SELECT Id, Page_Section__c, Sequence__c, Consumption_Description__c, Rollup_Into_Estimation_Summary_Lines__c,
            Picklist_Values__c, Data_Type__c, Required__c, Default__c,
                (
                    SELECT Name, Estimation_Schedule__c, Estimation_Summary__c, User_Value__c, Original_Data_Type__c, Notes__c,
                    Table_Cell__c, Row_Number__c, Column_Number__c, Estimation_Schedule__r.Data_Type__c, 
                    Estimation_Schedule__r.Default__c, Estimation_Schedule__r.Consumption_Description__c,
                    Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Sequence__c, 
                    Parent_Estimation_Schedule__r.Data_Type__c, Estimation_Schedule__r.Name,
                    Feed_External_User__c,Feed_Internal_User__c
                    FROM Estimation_Outputs__r
                    WHERE Estimation_Summary__c = :summaryId
                )
            FROM ConsumptionSchedule
            WHERE Page_Section__c IN :setPageSectionsId
            AND Active__c = true
            // AND Sequence__c > 0 
            AND RecordType.DeveloperName = :IPUE_CONSTANTS.ESTIMATION_SCHEDULE_DEV_NAME
            ORDER BY Sequence__c ASC
        ]);

        return scheduleMap;
    }

    // Query Form__c records, create Form model, and add to wrapper
    public static void createForm(Estimation_Summary__c summary, IPUE_FormControllerModels.DataWrapper wrapper){

        Form__c form = [SELECT Id FROM Form__c WHERE Id = :summary.Form__c LIMIT 1];
        wrapper.form = new IPUE_FormControllerModels.Form(form);
        wrapper.form.estimationSummaryId = summary.Id;

    }

    // Query Page__c records, create Page models, and return Map of PageWrapper by Page Ids
    public static Map<Id, IPUE_FormControllerModels.PageWrapper> createPages(Id formId) {
                   
        Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById = new Map<Id, IPUE_FormControllerModels.PageWrapper>();

        List<Page__c> pages = [
            SELECT Id, Page_Number__c, Parent_Form__c, Name,Page_Name__c
            FROM Page__c
            WHERE Parent_Form__c = :formId
            AND Page_Number__c != null
            ORDER BY Page_Number__c ASC
        ];

        // For every Page related to the Form, create a Page Data Model and relate it to the Form
        for (Page__c page : pages) {

            IPUE_FormControllerModels.PageWrapper pageWrapper = new IPUE_FormControllerModels.PageWrapper(page);
            pagesById.put(page.Id, pageWrapper);

        }

        return pagesById;

    }

    // Query SDoc_Template__c records, create SDocButton models, and add to pagesById variable
    public static void createSDocTemplates(Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById){
                    
        List<SDoc_Template__c> sDocTemplates = [
            SELECT Id, Sequence__c, Default__c, Template_Id__c, Button_Label__c, Page__c
            FROM SDoc_Template__c
            WHERE Page__c IN :pagesById.keySet()
            AND Sequence__c != null
            ORDER BY Sequence__c ASC
        ];

        // For every SDoc Template related to a Page, create a SDocButton Model and relate it to the Page
        for (SDoc_Template__c sDocTemplate : sDocTemplates) {

            IPUE_FormControllerModels.SDocButton sDocButton = new IPUE_FormControllerModels.SDocButton(sDocTemplate);
            pagesById.get(sDocTemplate.Page__c).sDocButtons.add(sDocButton);

        }

    }

    // Query Page_Frame__c records, create Frame models, add to pagesById variable and return Map of Frames by Frame Ids
    public static Map<Id, IPUE_FormControllerModels.Frame> createPageFrames(Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById){
                    
        Map<Id, IPUE_FormControllerModels.Frame> pageFramesById = new Map<Id, IPUE_FormControllerModels.Frame>();
        List<Page_Frame__c> pageFrameList = [
            SELECT Id, Row_Sequence__c, Page__c, Name, Frame_Type__c, Column_Percentage__c, Column_Sequence__c
            FROM Page_Frame__c
            WHERE Page__c IN :pagesById.keySet()
            ORDER BY Column_Sequence__c ASC
        ];

        // For every Page Frame related to a Page, create a Frame Data Model and relate it to the Page
        for (Page_Frame__c pageFrame : pageFrameList) {

            IPUE_FormControllerModels.Frame frameWrapper = new IPUE_FormControllerModels.Frame(pageFrame);
            pagesById.get(pageFrame.Page__c).frames.add(frameWrapper);
            pageFramesById.put(pageFrame.Id, frameWrapper);

        }

        return pageFramesById;

    }

    // Query Page_Section__c records, create Page Section models, add to pageFramesById and return Map of Page Sections by Section Ids
    public static Map<Id, IPUE_FormControllerModels.PageSection> createPageSections(Map<Id, IPUE_FormControllerModels.Frame> pageFramesById, IPUE_FormControllerModels.DataWrapper wrapper){
    
        Map<Id, IPUE_FormControllerModels.PageSection> pageSectionsById = new Map<Id, IPUE_FormControllerModels.PageSection>();
        
        List<Page_Section__c> pageSectionList = [
            SELECT Id, Parent_Page_Frame__c, Sequence__c, Name, Parent_Page_Frame__r.Page__c, Progress__c,
            Title_Visibility__c, Display_Estimation_Summary_Total__c, Display_Label__c,
            Display_Page_Section_Total_Inline__c, Display_Label_Rich_Text__c, Page_Sections_Name__c
            FROM Page_Section__c
            WHERE Parent_Page_Frame__c IN :pageFramesById.keySet()
            AND Sequence__c > 0
            ORDER BY Sequence__c ASC
        ];

        // For every Page Section related to a Page Frame, create a Page Section Data Model and relate it to the Frame
        for (Page_Section__c section : pageSectionList) {

            IPUE_FormControllerModels.PageSection sectionWrapper = new IPUE_FormControllerModels.PageSection(section);
            pageFramesById.get(section.Parent_Page_Frame__c).pageSections.add(sectionWrapper);
            pageSectionsById.put(section.Id, sectionWrapper);

            // Compile Page Section Ids to be used later when calling integrations
            wrapper.pageSectionIds.add(section.Id);

        }
        return pageSectionsById;
    }

    // When the Form loads, check to see if any Estimation Schedule records don't have any Estimation Outputs associated to them
    // If no Outputs are found, create an Estimation Output and Estimation Summary line
    public static void createMissingOutputsAndSummaryLines(Set<Id> pageSectionIds, Estimation_Summary__c summary){

        Set<Id> elasticEstimationScheduleIds = new Set<Id>();
        List<Estimation_Output__c> outputsToInsert = new List<Estimation_Output__c>();
        List<Estimation_Summary_Line__c> summaryLinesToInsert = new List<Estimation_Summary_Line__c>();
        List<ConsumptionSchedule> schedulesWithoutEstimationOutputs = new List<ConsumptionSchedule>();
        //set of filled page section Ids - <T02>
        Set<Id> setFilledSections = new Set<Id>();

        // Query out all active Estimation Schedules related to the Page Sections
        List<ConsumptionSchedule> scheduleList = [
            SELECT Id, Name, Page_Section__r.Parent_Page__r.Id, Page_Section__c, Rollup_Into_Estimation_Summary_Lines__c,
            Default__c, Consumption_Description__c, Data_Type__c,
                (
                    SELECT Name, Estimation_Schedule__c, Estimation_Summary__c, User_Value__c, Original_Data_Type__c,Feed_External_User__c,Feed_Internal_User__c,Section_filled__c
                    FROM Estimation_Outputs__r
                    WHERE Estimation_Summary__c = :summary.Id
                ),
                (
                    SELECT ProductId
                    FROM ProductConsumptionSchedules
                ),
                (
                    SELECT Id
                    FROM Table_Cell_Members__r
                )
            FROM ConsumptionSchedule
            WHERE Page_Section__c IN :pageSectionIds
            // AND Active__c = true
            AND RecordType.DeveloperName = :IPUE_CONSTANTS.ESTIMATION_SCHEDULE_DEV_NAME
        ];

        // Find all Table Cells that are included in an elastic table
        List<Table_Cell__c> elasticTableCells = [
            SELECT Id, Child_Estimation_Schedule__c, Parent_Estimation_Schedule__c,
            Row_Number__c, Column_Number__c
            FROM Table_Cell__c
            WHERE Parent_Estimation_Schedule__c IN :scheduleList
            AND Parent_Estimation_Schedule__r.Data_Type__c = :IPUE_CONSTANTS.TABLE_ELASTIC
        ];

        // Populate list of Estimation Schedules that are part of the static table
        for (Table_Cell__c tableCell : elasticTableCells) {
            elasticEstimationScheduleIds.add(tableCell.Child_Estimation_Schedule__c);
        }

        // Loop through Estimation Schedules and determine if an Estimation Output/Summary Line should be created
        // This means the Schedule was added after the Estimation Summary was initially created
        for (ConsumptionSchedule schedule : scheduleList) {

            // Find Estimation Schedules that don't have Estimation Outputs and are not a part of an Elastic Table
            if (schedule.Estimation_Outputs__r.isEmpty() && !elasticEstimationScheduleIds.contains(schedule.Id)) {
                schedulesWithoutEstimationOutputs.add(schedule);
            }

            //Add the page section Id to the set if the section is filled - <T02>
            for(Estimation_Output__c output:schedule.Estimation_Outputs__r){
                if(output.Section_filled__c){
                    setFilledSections.add(schedule.Page_Section__c);
                }
            }
        }

        if (!schedulesWithoutEstimationOutputs.isEmpty()) {
            // Create a new Estimation Output for every Estimation Schedule without one
            Set<Id> product2Ids = IPUE_EstimationModelHelper.createNewEstimationOutputs(summary, schedulesWithoutEstimationOutputs,setFilledSections);
            // Create a new Estimation Summary Line for every Estimation Output and associate the applicalbe Product2 record
            IPUE_EstimationModelHelper.createNewEstimationSummaryLines(summary.Id, product2Ids);
        }
    }

    // Query Table_Cell__c records and build Table model and add to the wrapper to be used in createSectionItems()
    public static IPUE_FormControllerModels.DataWrapper buildTableFromConsumptionSchedules(Map<Id, ConsumptionSchedule> scheduleMap, IPUE_FormControllerModels.DataWrapper wrapper, Boolean isClosed){

        List<Estimation_Output__c> estimationOutputs = new List<Estimation_Output__c>();

        // For every Estimation Schedule, loop through child Estimation Output records
        for (ConsumptionSchedule schedule : scheduleMap.values()) {

            // Loop through Estimation Output records
            for (Estimation_Output__c output : schedule.Estimation_Outputs__r) {

                // If the Estimation Output is part of a Table (has Parent Estimation Schedule populated) and table is shown...
                // Create Table Cell for the Estimation Output record
                if (output.Parent_Estimation_Schedule__c != null && output.Parent_Estimation_Schedule__r.Sequence__c > 0) {

                    // Populate Set of Ids so we know which Estimation Schedules to avoid showing in UI
                    wrapper.tableCellSchedules.add(output.Estimation_Schedule__c);
                    
                    // Create a new Table Cell Model based off of queried Table Cell and Estimation Schedule
                    IPUE_FormControllerModels.TableCell tableCell = new IPUE_FormControllerModels.TableCell(schedule, isClosed, output);
                    
                    // Find or Create Table Model
                    IPUE_FormControllerModels.Table table = new IPUE_FormControllerModels.Table();
                    // If the Parent Estimation Schedule has already been added, find the related Table record
                    if (wrapper.tableByParentEstimationSchedule.containsKey(output.Parent_Estimation_Schedule__c)) {
                        table = wrapper.tableByParentEstimationSchedule.get(output.Parent_Estimation_Schedule__c);
                    // Otherwise, set default fields on the new table
                    } else {
                        table.sequence = Integer.valueOf(output.Parent_Estimation_Schedule__r.Sequence__c);
                        table.parentEstimationId = output.Parent_Estimation_Schedule__c;
                        table.isElastic = output.Parent_Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC ? true : false;
                        table.isFixed = output.Parent_Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_FIXED ? true : false;
                    }

                    // Capture highest Column Number so we create the correct number of placeholder cells, if needed
                    if (table.highestColumnNumber == null || tableCell.columnNumber > table.highestColumnNumber) {
                        table.highestColumnNumber = tableCell.columnNumber;
                    }

                    // Capture highest Row Number so we create the correct number of rows, if needed
                    if (table.highestRowNumber == null || tableCell.rowNumber > table.highestRowNumber) {
                        table.highestRowNumber = tableCell.rowNumber;
                    }

                    // Find or Create Table Row Model
                    IPUE_FormControllerModels.TableRow tableRow  = new IPUE_FormControllerModels.TableRow();
                    // If the Table Row has already been added, find the existing Row
                    if (table.rowsByRowNumber.containsKey(tableCell.rowNumber)) {
                        tableRow = table.rowsByRowNumber.get(tableCell.rowNumber);
                    // Otherwise, default Row Number of Table Row
                    } else {
                        tableRow.rowNumber = tableCell.rowNumber;
                    }

                    // Add Table Cell to Table Row, where key = Column Number and value = Table Cell (used to sort Table Cells by column)
                    tableRow.cellsByColumnNumber.put(tableCell.columnNumber, tableCell);
                    // Add Table Row to Table, where key = Row Number and value = Table Row (used to sort Table Rows by row number)
                    table.rowsByRowNumber.put(tableCell.rowNumber, tableRow);
                    // Add Table to Table Wrapper, where key = Parent Estimation Schedule Id, value = Table
                    wrapper.tableByParentEstimationSchedule.put(output.Parent_Estimation_Schedule__c, table);

                }
            }

        }

        return wrapper;

    } 

    public static IPUE_FormControllerModels.DataWrapper sortTableRowsAndCells(IPUE_FormControllerModels.DataWrapper wrapper){
    
        // Loop through each Table Model and sort Table Rows and Cells withing each Table
        for (IPUE_FormControllerModels.Table table : wrapper.tableByParentEstimationSchedule.values()) {

            Integer rowsToCreate = table.highestRowNumber + 1;

            // Iterate over Map of rows and sort the Table Rows and Table Cells into ordered Lists
            for (Integer i = 0; i < rowsToCreate; i++) {
                        
                // Create new Table Row Model
                IPUE_FormControllerModels.TableRow row = new IPUE_FormControllerModels.TableRow();
                // If the Table Row already exists, return it
                if (table.rowsByRowNumber.containsKey(i)) {
                    row = table.rowsByRowNumber.get(i);
                // Otherwise, create an empty Table Row
                } else {
                    row.rowNumber = i;
                }

                // Add Table Cells to Row sorted by column
                for (Integer j = 1; j <= table.highestColumnNumber; j++) {
                    
                    // Create new Table Cell Model
                    IPUE_FormControllerModels.TableCell cell = new IPUE_FormControllerModels.TableCell();

                    // If a Table Exists for this Column Number within a Table Row, return the Table Cell record
                    if (row.cellsByColumnNumber.containsKey(j)) {
                        cell = row.cellsByColumnNumber.get(j);
                    // Otherwise, there is no Table Cell record for this Column Number, therefore create a placeholder
                    } else {
                        cell.rowNumber = i;
                        cell.columnNumber = j;
                        cell.dataType = IPUE_CONSTANTS.STATIC_TEXT;
                    }                    
                    
                    // Add Table Cell to Table Row - this will be kept in sorted order
                    row.cells.add(cell);

                }

                // Add the first Table Row as the Header to the Table
                if (i == 0) {
                    table.header = row;
                // Add all other Table Rows to the Table - this will be kept in sorted order
                } else {
                    table.rows.add(row);
                }

            }

            // For Elastic tables, generate an empty placeholder row
            if (table.isElastic) {

                // Create extra row for Elastic Tables
                IPUE_FormControllerModels.TableRow emptyRow = new IPUE_FormControllerModels.TableRow();
                emptyRow.rowNumber = table.rowsByRowNumber.keySet().size(); // This should return 2

                // Create Table Cells for every column
                for (Integer i = 1; i <= table.highestColumnNumber; i++) {

                    IPUE_FormControllerModels.TableCell cell = new IPUE_FormControllerModels.TableCell();
                    cell.rowNumber = emptyRow.rowNumber;
                    cell.columnNumber = i;
                    cell.dataType = IPUE_CONSTANTS.STATIC_TEXT;
                    emptyRow.cells.add(cell);
                }

                // Add row to table
                table.rows.add(emptyRow);

            }

        }

        return wrapper;
        
    }

    public static void createSectionItems(Map<Id, IPUE_FormControllerModels.PageSection> pageSectionsById, Map<Id, ConsumptionSchedule> scheduleMap, IPUE_FormControllerModels.DataWrapper wrapper){
                               
        Map<Id, List<IPUE_FormControllerModels.EstimationSchedule>> schedulesBySectionId = new Map<Id, List<IPUE_FormControllerModels.EstimationSchedule>>();
        Map<Id, List<IPUE_FormControllerModels.Table>> tablesBySectionId = new Map<Id, List<IPUE_FormControllerModels.Table>>();
        Map<Id, List<IPUE_FormControllerModels.LightningServiceTemplate>> templatesBySectionId = new Map<Id, List<IPUE_FormControllerModels.LightningServiceTemplate>>();

        // For Every Consumption Schedule, create an EstimationSchedule or Table and add it to the applicable Map
        for (ConsumptionSchedule schedule : scheduleMap.values()) {

            if (schedule.Sequence__c > 0) {

                IPUE_FormControllerModels.PageSection pageSection = pageSectionsById.get(schedule.Page_Section__c);
               
                // If the Estimation Schedule has a Data Type of "Table" - Add Table to Page Section
                if (schedule.Data_Type__c == IPUE_CONSTANTS.TABLE_FIXED || schedule.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC){

                    if (wrapper.tableByParentEstimationSchedule.containsKey(schedule.Id)) {

                        IPUE_FormControllerModels.Table table = wrapper.tableByParentEstimationSchedule.get(schedule.Id);
                        // If Page Section has already been added, return the List of existing Tables
                        if (!tablesBySectionId.containsKey(pageSection.Id)) {
                            tablesBySectionId.put(pageSection.Id, new List<IPUE_FormControllerModels.Table>());
                        }
                        // Add current Table to Page Section
                        tablesBySectionId.get(pageSection.Id).add(table);

                    }

                // Don't add the Estimation Schedule to the Page Section as Table or Question
                } else if (wrapper.tableCellSchedules.contains(schedule.Id)) {
                    
                    continue;

                // Otherwise, if the Estimation Schedule is not a Table and not a Table Cell - Add to page as a Question
                } else {

                    IPUE_FormControllerModels.EstimationSchedule scheduleWrapper = new IPUE_FormControllerModels.EstimationSchedule(schedule, wrapper.oppModel.isClosed);

                    if (scheduleWrapper.output != null) {

                        // If the Estimation Schedule is not "Calculated", calculate the numerator and denominator for progress ring
                        if (!scheduleWrapper.isCalculated) {

                            pageSection.denominator += 1;

                            if (scheduleWrapper.output.value != null) {
                                pageSection.numerator += 1;
                            }

                            if (pageSection.numerator > 0) {
                                pageSection.progress = (pageSection.numerator/pageSection.denominator)*100;
                            } else {
                                pageSection.progress = 0;
                            }

                        // Otherise, Check to see if Estimation Schedule should be rolled up into Page Section Total
                        } else if (schedule.Rollup_Into_Estimation_Summary_Lines__c && scheduleWrapper.output.value != null) {

                            try {
                                pageSection.sectionTotal += Integer.valueOf(scheduleWrapper.output.value);                          
                            } catch (Exception ex) {
                                System.debug('Estimation Output value cannot be converted to an integer. Value: ' + scheduleWrapper.output.value);
                            }

                        }

                        // If Page Section has already been added, return the List of existing Estimation Schedules
                        if (!schedulesBySectionId.containsKey(pageSection.Id)) {
                            schedulesBySectionId.put(pageSection.Id, new List<IPUE_FormControllerModels.EstimationSchedule>());
                        }
                        // Add current Schedule Wrapper to Page Section
                        schedulesBySectionId.get(pageSection.Id).add(scheduleWrapper);
                    }
                }
            }
        }

        List<Lightning_Service_Template__c> templateList = [
            SELECT Id, Name, Content__c, Page_Section__c, Sequence__c,
                (
                    SELECT Id
                    FROM Lightning_Service_Members__r
                )
            FROM Lightning_Service_Template__c
            WHERE Page_Section__c IN :pageSectionsById.keySet()
            AND Sequence__c > 0
            ORDER BY Sequence__c ASC
        ];

        // For every Lightning Service Template record, create a Lightning Service Template model and add to the applicable Map
        for (Lightning_Service_Template__c template : templateList) {

            IPUE_FormControllerModels.PageSection pageSection = pageSectionsById.get(template.Page_Section__c);
            IPUE_FormControllerModels.LightningServiceTemplate templateWrapper = new IPUE_FormControllerModels.LightningServiceTemplate(template.Name, template.Id,template.Page_Section__c, null, template.Content__c, template.Sequence__c);
            templateWrapper.contentFound = false;

            // Only count as Integration if Lightning Service Members exist
            if (!template.Lightning_Service_Members__r.isEmpty()) {
                templateWrapper.hasIntegrations = true;
                wrapper.integrationCount++;
            }

            if (!templatesBySectionId.containsKey(pageSection.Id)) {
                templatesBySectionId.put(pageSection.Id, new List<IPUE_FormControllerModels.LightningServiceTemplate>());
            }
            templatesBySectionId.get(pageSection.Id).add(templateWrapper);
        }

        // Merge the EstimationSchedules, LightningServiceTemplates and Tables into a sorted list of SectionItems
        for (IPUE_FormControllerModels.PageSection section : pageSectionsById.values()) {

            List<IPUE_FormControllerModels.EstimationSchedule> schedules = schedulesBySectionId.containsKey(section.Id) ? schedulesBySectionId.get(section.Id) : new List<IPUE_FormControllerModels.EstimationSchedule>();
            List<IPUE_FormControllerModels.LightningServiceTemplate> templates = templatesBySectionId.containsKey(section.Id) ? templatesBySectionId.get(section.Id) : new List<IPUE_FormControllerModels.LightningServiceTemplate>();
            List<IPUE_FormControllerModels.Table> tables = tablesBySectionId.containsKey(section.Id) ? tablesBySectionId.get(section.Id) : new List<IPUE_FormControllerModels.Table>();

            List<IPUE_FormControllerModels.SectionItemComparable> listToSort = new List<IPUE_FormControllerModels.SectionItemComparable>();

            for (IPUE_FormControllerModels.EstimationSchedule schedule : schedules) {
                IPUE_FormControllerModels.SectionItem sectionItem = new IPUE_FormControllerModels.SectionItem(schedule);
                listToSort.add(new IPUE_FormControllerModels.SectionItemComparable(sectionItem));
            }

            for (IPUE_FormControllerModels.LightningServiceTemplate template : templates) {
                IPUE_FormControllerModels.SectionItem sectionItem = new IPUE_FormControllerModels.SectionItem(template);
                listToSort.add(new IPUE_FormControllerModels.SectionItemComparable(sectionItem));
            }

            for (IPUE_FormControllerModels.Table table : tables) {

                IPUE_FormControllerModels.SectionItem sectionItem = new IPUE_FormControllerModels.SectionItem(table);
                listToSort.add(new IPUE_FormControllerModels.SectionItemComparable(sectionItem));
                
                
            }

            // Sort section items by Sequence
            listToSort.sort();

            // Add sorted items to each Page Section's SectionItems
            for (IPUE_FormControllerModels.SectionItemComparable comparableItem : listToSort) {
                section.sectionItems.add(comparableItem.sectionItem);
            }

            // If there are no section items, default Page Section fields accordingly
            if (section.sectionItems.isEmpty()) {
                section.inputMissing = false;
                section.showSection = true;
                section.showTitle = false;
                section.disableCheckbox = true;
                section.showProgress = false;
            }
        }
    }

    public static IPUE_FormControllerModels.Table createOutputsAndAddTableRow(Id estimationSummaryId, Id tableId, Integer numRows, Integer numColumns){
    
        Map<Decimal, Estimation_Output__c> outputsToInsertByColumn = new Map<Decimal, Estimation_Output__c>();
        Set<Id> estimationScheduleIds = new Set<Id>();

        // Create a new row to hold the new Table Cells/Estimation Outputs
        IPUE_FormControllerModels.TableRow newRow = new IPUE_FormControllerModels.TableRow();
        newRow.rowNumber = numRows;

        // Find all Table Cell metadata with the Row = 1 that is associated to the table
        List<Table_Cell__c> row1TableCells = [
            SELECT Id, Child_Estimation_Schedule__c, Parent_Estimation_Schedule__c,
            Row_Number__c, Column_Number__c, Child_Estimation_Schedule__r.Name, Parent_Estimation_Schedule__r.Name
            FROM Table_Cell__c
            WHERE Parent_Estimation_Schedule__c = :tableId
            AND Child_Estimation_Schedule__r.Active__c = true
            AND Row_Number__c = 1
        ];

        // Get Estimation Schedule Ids for all Child Schedules related to a Cell
        for (Table_Cell__c tableCell : row1TableCells) {
            estimationScheduleIds.add(tableCell.Child_Estimation_Schedule__c);
        }

        // Query out Estimation Schedule data
        Map<Id, ConsumptionSchedule> estimationScheduleMap = new Map<Id, ConsumptionSchedule>([
            SELECT Id, Consumption_Description__c, Data_Type__c,
            Default__c, Picklist_Values__c, Page_Section__r.Parent_Page__r.Id,
            Rollup_Into_Estimation_Summary_Lines__c, Page_Section__r.Parent_Page__r.Parent_Form__c,
            Page_Section__r.Parent_Page__c, Page_Section__c,
            (
                SELECT ProductId
                FROM ProductConsumptionSchedules
                LIMIT 1
            )
            FROM ConsumptionSchedule
            WHERE Id IN :estimationScheduleIds
        ]);

        // For every Row 1 Table Cell, create a new Estimation Output record
        for (Table_Cell__c cell : row1TableCells) {

            ConsumptionSchedule estimationSchedule = estimationScheduleMap.get(cell.Child_Estimation_Schedule__c);

            Estimation_Output__c newOutput = new Estimation_Output__c();
            newOutput.Estimation_Summary__c = estimationSummaryId;
            newOutput.Estimation_Schedule__c = estimationSchedule.Id;
            newOutput.Parent_Estimation_Schedule__c = cell.Parent_Estimation_Schedule__c;
            newOutput.Form__c = estimationSchedule.Page_Section__r.Parent_Page__r.Parent_Form__c;
            newoutput.Page__c = estimationSchedule.Page_Section__r.Parent_Page__c;
            newOutput.Page_Section__c = estimationSchedule.Page_Section__c;
            newOutput.Rollup_Into_Estimation_Summary_Lines__c = estimationSchedule.Rollup_Into_Estimation_Summary_Lines__c;
            newOutput.User_Value__c = estimationSchedule.Default__c;
            newOutput.Original_Data_Type__c = estimationSchedule.Data_Type__c;
            newOutput.Table_Cell__c = cell.Id;
            newOutput.Row_Number__c = numRows;
            newOutput.Column_Number__c = cell.Column_Number__c;
            newOutput.Name = 'Elastic Output Row ' + newOutput.Row_Number__c + ' Column ' + newOutput.Column_Number__c + ' (' + cell.Parent_Estimation_Schedule__r.Name + ')';

            // If the Estimation Schedule has an associated Product, populate the Product lookup field
            if (!estimationSchedule.ProductConsumptionSchedules.isEmpty() && estimationSchedule.ProductConsumptionSchedules[0].productId != null) {
                newOutput.Product__c = estimationSchedule.ProductConsumptionSchedules[0].productId;
            }

            // Populate Map where key = column number and value = new Estimation Output record
            outputsToInsertByColumn.put(newOutput.Column_Number__c, newOutput);

        }

        if (outputsToInsertByColumn.isEmpty()) {
            throw new AuraHandledException('New Estimation Outputs were not created for the new row as expected.');
        }

        // Insert Estimation Outputs
        insert outputsToInsertByColumn.values();

        // Sort Table Cells into the correct column order and add to new Table Row
        for (Integer i = 1; i <= numColumns; i++) {

            Estimation_Output__c output = outputsToInsertByColumn.get(i);
            IPUE_FormControllerModels.TableCell tableCell;

            // If an Estimation Output is found, create Table Cell using Schedule and Output
            if (output != null) {

                ConsumptionSchedule estimationSchedule = estimationScheduleMap.get(output.Estimation_Schedule__c);
                tableCell = new IPUE_FormControllerModels.TableCell(estimationSchedule, false, output);

            // Otherwise, create a placeholder cell
            } else {
                tableCell = new IPUE_FormControllerModels.TableCell();
                tableCell.rowNumber = numRows;
                tableCell.columnNumber = i;
                tableCell.dataType = IPUE_CONSTANTS.STATIC_TEXT;
            }

            newRow.cells.add(tableCell);

        }

        IPUE_FormControllerModels.Table table = new IPUE_FormControllerModels.Table();
        table.rows.add(newRow);
        return table;
    
    }

    public static IPUE_FormControllerModels.Table deleteOutputs(Id estimationSummaryId, Id tableId, Integer rowIndex){
    
        List<Estimation_Output__c> outputsToDelete = new List<Estimation_Output__c>();
        List<Estimation_Output__c> outputsToUpdate = new List<Estimation_Output__c>();
        Set<Id> childEstimationScheduleIds = new Set<Id>();

        // Find all Estimation Outputs related to the Elastic Table
        List<Estimation_Output__c> estimationOutputs = [
            SELECT Id, Name, Row_Number__c, Column_Number__c, Original_Data_Type__c, User_Value__c, 
            Form__c, Page_Section__c, Estimation_Schedule__r.Default__c, Estimation_Schedule__c,
            Estimation_Summary__c, Parent_Estimation_Schedule__c, Notes__c, Parent_Estimation_Schedule__r.Name,
            Feed_Internal_User__c,Feed_External_User__c
            FROM Estimation_Output__c
            WHERE Parent_Estimation_Schedule__c = :tableId
            AND Estimation_Schedule__r.Active__c = true
        ];

        Integer rowToDelete = rowIndex + 1; // Add 1 to account for header row

        for (Estimation_Output__c output : estimationOutputs) {

            // If the Estimation Output is in the row to delete, add to list to delete
            if (output.Row_Number__c == rowToDelete) {
                outputsToDelete.add(output);
            } else {

                // Add all other Estimation Schedule Ids to existing Outputs to a set
                childEstimationScheduleIds.add(output.Estimation_Schedule__c);

                // If the Estimation Output is a future row, update the row number accordingly
                if (output.Row_Number__c > rowToDelete) {
                    output.Row_Number__c = output.Row_Number__c - 1;
                    output.Name = 'Elastic Output Row ' + output.Row_Number__c + ' Column ' + output.Column_Number__c + ' (' + output.Parent_Estimation_Schedule__r.Name + ')';
                    outputsToUpdate.add(output);
                }

            }

        }

        delete outputsToDelete; // Delete Outputs related to row to delete
        update outputsToUpdate; // Update new Row Number in existing Outputs
        
        // Query out Consumption Schedule Records related to updated Estimation Outputs
        Map<Id, ConsumptionSchedule> scheduleMap = new Map<Id, ConsumptionSchedule>([
            SELECT Id, Page_Section__c, Sequence__c, Consumption_Description__c, Rollup_Into_Estimation_Summary_Lines__c,
            Picklist_Values__c, Data_Type__c, Required__c, Default__c,
                (
                    SELECT Name, Estimation_Schedule__c, Estimation_Summary__c, User_Value__c, Original_Data_Type__c, Notes__c,
                    Table_Cell__c, Row_Number__c, Column_Number__c, Estimation_Schedule__r.Data_Type__c, 
                    Estimation_Schedule__r.Default__c, Estimation_Schedule__r.Consumption_Description__c,
                    Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Sequence__c, Parent_Estimation_Schedule__r.Data_Type__c,
                    Feed_Internal_User__c,Feed_External_User__c
                    FROM Estimation_Outputs__r
                    WHERE Estimation_Summary__c = :estimationSummaryId
                )
            FROM ConsumptionSchedule
            WHERE Id IN :childEstimationScheduleIds
        ]);

        IPUE_FormControllerModels.DataWrapper wrapper = buildTableFromConsumptionSchedules(scheduleMap, new IPUE_FormControllerModels.DataWrapper(), false);
        wrapper = sortTableRowsAndCells(wrapper);

        return wrapper.tableByParentEstimationSchedule.get(tableId);

    }
    
}