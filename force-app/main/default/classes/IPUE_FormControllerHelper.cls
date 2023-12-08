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
    Kevin Antonioli     22 OCT 2023   PNP-512:          Enhance performance and UX                                                              <T03>  
    Kevin Antonioli     11 NOV 2023   PNP-512:          Add logic to support table lock functionality and progress ring accuracy                <T04>                                                                                     
    ********************************************************************************************************************************************
*/
public without sharing class IPUE_FormControllerHelper {
    public class IPU_Estimator_Exception extends Exception {
    }
    public IPUE_FormControllerHelper() {
    }

    /**
     * Query Form__c records, create Form model, and add to wrapper
     * @param estimationSummary     the Estimation Summary record that the user is on
     * @param wrapper               the data wrapper for the Estimation Summary
     * @return void
     */
    public static void createForm(Estimation_Summary__c estimationSummary, IPUE_FormControllerModels.DataWrapper wrapper) {
        Form__c form = [SELECT Id FROM Form__c WHERE Id = :estimationSummary.Form__c LIMIT 1];
        wrapper.form = new IPUE_FormControllerModels.Form(form);
        wrapper.form.estimationSummaryId = estimationSummary.Id;
    }

    /**
     * Query Page__c records, create Page models, and return Map of PageWrapper by Page Ids
     * @param formId            the Id of the Form the system is querying/assimilating pages for
     * @param specificPageId    per <T03>, this is the Id of the Page containing the section for the user-toggled section scenario
     */
    public static Map<Id, IPUE_FormControllerModels.PageWrapper> createPages(Id formId, Id specificPageId) {
        Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById = new Map<Id, IPUE_FormControllerModels.PageWrapper>();

        // Per <T03>, when the page initially loads, for every Page related to the Form, create a Page Data Model and relate it to the Form
        //  However, after the page has initially loaded, if the user selected a previously unselected section, only query necessary data for that section
        for (
            Page__c page : (specificPageId == null ||
                String.valueOf(specificPageId) == 'undefined')
                ? [
                      SELECT Id, Page_Number__c, Parent_Form__c, Name, Page_Name__c
                      FROM Page__c
                      WHERE Parent_Form__c = :formId AND Page_Number__c != NULL
                      ORDER BY Page_Number__c ASC
                  ]
                : [
                      SELECT Id, Page_Number__c, Parent_Form__c, Name, Page_Name__c
                      FROM Page__c
                      WHERE Parent_Form__c = :formId AND Page_Number__c != NULL AND Id = :specificPageId
                      ORDER BY Page_Number__c ASC
                  ]
        ) {
            IPUE_FormControllerModels.PageWrapper pageWrapper = new IPUE_FormControllerModels.PageWrapper(page);
            pagesById.put(page.Id, pageWrapper);
        }
        return pagesById;
    }

    /**
     * Query Page_Frame__c records, create Frame models, add to pagesById variable and return Map of Frames by Frame Ids
     * @param pagesById                 Map of Page Id to PageWrapper
     * @param specificFrameRecordId     Id for specific frame to process
     * @param estimationSummaryRecord   queried Estimation Summary Record for form
     * @return map of Frame Id to Frame
     */
    public static Map<Id, IPUE_FormControllerModels.Frame> createPageFrames(
        Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById,
        Id specificFrameRecordId, // added for <T03>
        Estimation_Summary__c estimationSummaryRecord
    ) {
        Map<Id, IPUE_FormControllerModels.Frame> pageFramesById = new Map<Id, IPUE_FormControllerModels.Frame>();

        // Per <T03>, when the page initially loads, for every Page Frame related to a Page, create a Frame Data Model and relate it to the Page
        //  However, after the page has initially loaded, if the user selected a previously unselected section, only query necessary data for that section
        for (
            Page_Frame__c pageFrame : (specificFrameRecordId == null ||
                String.valueOf(specificFrameRecordId) == 'undefined')
                ? [
                      SELECT Id, Row_Sequence__c, Page__c, Name, Frame_Type__c, Column_Percentage__c, Column_Sequence__c
                      FROM Page_Frame__c
                      WHERE Page__c IN :pagesById.keySet()
                      ORDER BY Column_Sequence__c ASC
                  ]
                : [
                      SELECT Id, Row_Sequence__c, Page__c, Name, Frame_Type__c, Column_Percentage__c, Column_Sequence__c
                      FROM Page_Frame__c
                      WHERE Page__c IN :pagesById.keySet() AND Id = :specificFrameRecordId
                      ORDER BY Column_Sequence__c ASC
                  ]
        ) {
            IPUE_FormControllerModels.Frame frameWrapper = new IPUE_FormControllerModels.Frame(pageFrame, estimationSummaryRecord);
            pagesById.get(pageFrame.Page__c).frames.add(frameWrapper);
            pageFramesById.put(pageFrame.Id, frameWrapper);
        }

        return pageFramesById;
    }

    /**
     * Query Page_Section__c records, create Page Section models, add to pageFramesById and return Map of Page Sections by Section Ids
     *  Updated per <T03> to improve performance
     * @param pageFramesById            map of Page Frame Id to Page Frame
     * @param wrapper                   data wrapper applicable to the Estimation Summary record that the user is on
     * @param estimationSummaryId       The Estimation Summary id record for the Estmation Summary Record the user is on
     * @param estimationSummaryId       The Estimation Summary id record for the Estmation Summary Record the user is on
     * @param estimationSummaryFormId   <T03>: this is the Estimation summary's form id
     * @param newlyCheckedOnceBefore    <T03>: this is whether or not an initially unchecked page section was checked, unchecked, then rechecked
     * @param pageNumber                <T03>: this is the page number of the page the section belongs to
     */
    public static Map<Id, IPUE_FormControllerModels.PageSection> createPageSections(
        Map<Id, IPUE_FormControllerModels.Frame> pageFramesById,
        IPUE_FormControllerModels.DataWrapper wrapper,
        Id estimationSummaryId,
        Id estimationSummaryFormId,
        Page_Section__c toggledPageSectionRecord,
        Boolean newlyCheckedOnceBefore,
        Decimal pageNumber
    ) {
        Map<Id, IPUE_FormControllerModels.PageSection> pageSectionsById = new Map<Id, IPUE_FormControllerModels.PageSection>();

        // When the page initially loads, for every Page Section related to a Page Frame, create a Page Section Data Model and relate it to the Frame
        //   Per <T03>, when the page initially loads, only query the page sections for the first page
        //   Also, if the user selected a previously unselected section, only query necessary data for that section
        //   Also, if the user has checked a previously unselected page section that was unselected on page load, then unchecked it, then checked it again,
        //    don't query the data at all, but just use the Page_Section__c parameter that's been cached in the LWC JS
        List<Page_Section__c> pageSectionRecords;
        if (!newlyCheckedOnceBefore) {
            pageSectionRecords = toggledPageSectionRecord == null
                ? [
                      SELECT
                          Id,
                          Name,
                          Parent_Page_Frame__c,
                          Parent_Page_Frame__r.Page__c,
                          Parent_Page_Frame__r.Page__r.Page_Number__c,
                          Sequence__c,
                          Progress__c,
                          Title_Visibility__c,
                          Display_Estimation_Summary_Total__c,
                          Display_Label__c,
                          Display_Page_Section_Total_Inline__c,
                          Display_Label_Rich_Text__c,
                          Page_Sections_Name__c,
                          Expansion_By_Default__c,
                          Cross_Dependent_On_Other_Sections__c,
                          Weighted_Average_Applicable__c,
                          /* Added subquery for <T03> to remember user's selections */
                          (
                              SELECT Id, Selected_By_User__c, Page_Section__r.Expansion_By_Default__c, Required_IPUs__c
                              FROM Estimation_Summary_Lines__r
                              WHERE Estimation_Summary__c = :estimationSummaryId
                          )
                      FROM Page_Section__c
                      WHERE
                          Parent_Page_Frame__c IN :pageFramesById.keySet()
                          AND Sequence__c > 0
                          /* Added for <T03>, only query the page sections for the current Page__c the user is on */
                          AND Parent_Page_Frame__r.Page__r.Page_Number__c = :pageNumber
                      ORDER BY Sequence__c ASC
                  ]
                : [
                      SELECT
                          Id,
                          Name,
                          Parent_Page_Frame__c,
                          Parent_Page_Frame__r.Page__c,
                          Parent_Page_Frame__r.Page__r.Page_Number__c,
                          Sequence__c,
                          Progress__c,
                          Title_Visibility__c,
                          Display_Estimation_Summary_Total__c,
                          Display_Label__c,
                          Display_Page_Section_Total_Inline__c,
                          Display_Label_Rich_Text__c,
                          Page_Sections_Name__c,
                          Expansion_By_Default__c,
                          Cross_Dependent_On_Other_Sections__c,
                          Weighted_Average_Applicable__c,
                          /* Added subquery for <T03> to remember user's selections */
                          (
                              SELECT Id, Selected_By_User__c, Page_Section__r.Expansion_By_Default__c, Required_IPUs__c
                              FROM Estimation_Summary_Lines__r
                              WHERE Estimation_Summary__c = :estimationSummaryId
                          )
                      FROM Page_Section__c
                      WHERE
                          Parent_Page_Frame__c IN :pageFramesById.keySet()
                          AND Sequence__c > 0
                          /* Added for <T03>, only query the page sections for the current Page__c the user is on */
                          AND Parent_Page_Frame__r.Page__r.Page_Number__c = :pageNumber
                          /* Added next filter for <T03>, for the user-toggling of sections scenario */
                          AND Id = :toggledPageSectionRecord.Id
                      ORDER BY Sequence__c ASC
                  ];
        } else {
            pageSectionRecords = new List<Page_Section__c>{ toggledPageSectionRecord };
        }

        for (Page_Section__c pageSectionRecord : pageSectionRecords) {
            IPUE_FormControllerModels.PageSection sectionWrapper = new IPUE_FormControllerModels.PageSection(pageSectionRecord);
            sectionWrapper.estimationSummaryFormId = estimationSummaryFormId;

            // Add the condition check for <T03>, do not show the page section at all if it contains no summary lines and is set to show title,
            //  and showTotalIpuSection is false
            //if (!(sectionWrapper.noEstSummaryLines && sectionWrapper.showTitle && !sectionWrapper.showTotalIpuSection)) { // TODO: remove comment
            pageFramesById.get(pageSectionRecord.Parent_Page_Frame__c).pageSections.add(sectionWrapper);
            pageSectionsById.put(pageSectionRecord.Id, sectionWrapper);

            // Compile Page Section Ids to be used later when calling integrations
            wrapper.pageSectionIds.add(pageSectionRecord.Id);
            //}
        }
        return pageSectionsById;
    }

    /**
     * When the Form loads, check to see if any Estimation Schedule records don't have any Estimation Outputs associated to them
     *  If no Outputs are found, create an Estimation Output and Estimation Summary line
     * @param pageSectionIds        page section ids to use in schedule query filter
     * @param estimationSummary     estimation summary record for form
     */
    public static void createMissingOutputsAndSummaryLines(Set<Id> pageSectionIds, Estimation_Summary__c estimationSummary) {
        Set<Id> elasticEstimationScheduleIds = new Set<Id>();
        List<ConsumptionSchedule> schedulesWithoutEstimationOutputs = new List<ConsumptionSchedule>();
        //set of filled page section Ids - <T02>
        Set<Id> setFilledSections = new Set<Id>();

        // Query out all active Estimation Schedules related to the Page Sections
        List<ConsumptionSchedule> scheduleList = [
            SELECT
                Id,
                Name,
                Page_Section__c,
                Page_Section__r.Parent_Page__r.Id,
                Rollup_Into_Estimation_Summary_Lines__c,
                Default__c,
                Consumption_Description__c,
                Data_Type__c,
                (
                    SELECT
                        Name,
                        Estimation_Schedule__c,
                        Estimation_Summary__c,
                        User_Value__c,
                        Original_Data_Type__c,
                        Feed_External_User__c,
                        Feed_Internal_User__c,
                        Section_filled__c
                    FROM Estimation_Outputs__r
                    WHERE Estimation_Summary__c = :estimationSummary.Id
                ),
                (
                    SELECT ProductId
                    FROM ProductConsumptionSchedules
                    LIMIT 1
                ),
                (
                    SELECT Id
                    FROM Table_Cell_Members__r
                )
            FROM ConsumptionSchedule
            WHERE
                Page_Section__c IN :pageSectionIds
                // AND Active__c = true
                AND RecordType.DeveloperName = :IPUE_CONSTANTS.ESTIMATION_SCHEDULE_DEV_NAME
        ];

        // Find all Table Cells that are included in an elastic table, and
        // Populate list of Estimation Schedules that are part of the static table
        for (Table_Cell__c tableCell : [
            SELECT Id, Child_Estimation_Schedule__c, Parent_Estimation_Schedule__c, Row_Number__c, Column_Number__c
            FROM Table_Cell__c
            WHERE
                Parent_Estimation_Schedule__c IN :scheduleList
                AND Parent_Estimation_Schedule__r.Data_Type__c = :IPUE_CONSTANTS.TABLE_ELASTIC
        ]) {
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
            for (Estimation_Output__c output : schedule.Estimation_Outputs__r) {
                if (output.Section_filled__c) {
                    setFilledSections.add(schedule.Page_Section__c);
                }
            }
        }

        if (!schedulesWithoutEstimationOutputs.isEmpty()) {
            // Create a new Estimation Output for every Estimation Schedule without one
            Set<Id> product2Ids = IPUE_EstimationModelHelper.createNewEstimationOutputs(
                estimationSummary,
                schedulesWithoutEstimationOutputs,
                setFilledSections
            );
            // Create a new Estimation Summary Line for every Estimation Output and associate the applicalbe Product2 record
            IPUE_EstimationModelHelper.createNewEstimationSummaryLines(estimationSummary.Id, scheduleList);
        }
    }

    /**
     * Query Consumption Schedule <T1>
     *  Updated per <T03> for performance optimization
     * @param estimationSummary         Estimation Summary record
     * @param setPageSectionsId         Id set of page sections we want to query data for, depending nn use case
     * @param estSummaryLines           Added for <T03>, these are Estimation Summary Line records (will be empty on initial page load, non-empty on useer section toggle)
     * @param toggledPageSectionRecord  Added for <T03>, if the user toggles a page section, this will be the Page Section record for that particular section. Only applies to page section toggle
     * @param sectionChecked            Added for <T03>, if the user toggles a page section, this will be the value of the checkbox for that section. Only applies to page section toggle
     * @param pageSectionsWithoutLines  Added for <T03>, this denotes whether a page section has Estimation Summary Lines or not
     */
    public static Map<Id, ConsumptionSchedule> getEstimationSchedules(
        Estimation_Summary__c estimationSummary,
        Set<Id> setPageSectionsId,
        List<Estimation_Summary_line__c> estSummaryLines,
        Page_Section__c toggledPageSectionRecord,
        Boolean sectionChecked,
        Set<Id> pageSectionsWithoutLines
    ) {
        Set<Id> prevSelectedPageSectionIds = new Set<Id>();
        Set<Id> justSelectedSectionIds = new Set<Id>();

        List<Estimation_Summary_Line__c> estSummaryLinesToUpdate = new List<Estimation_Summary_Line__c>();
        // on initial page load, estSummaryLines variable will be null or empty:
        if (estSummaryLines == null || estSummaryLines.isEmpty()) {
            for (Estimation_Summary_line__c estSummaryLine : [
                SELECT Id, Selected_By_User__c, Page_Section__c, Page_Section__r.Expansion_By_Default__c
                FROM Estimation_Summary_line__c
                WHERE Estimation_Summary__c = :estimationSummary.Id AND Page_Section__c IN :setPageSectionsId
            ]) {
                // <T03>:
                if (estSummaryLine.Selected_By_User__c) {
                    prevSelectedPageSectionIds.add(estSummaryLine.Page_Section__c);
                    // accommodate pre-existing data created before <T03> deployment:
                } else if (estSummaryLine.Page_Section__r.Expansion_By_Default__c && !estSummaryLine.Selected_By_User__c) {
                    estSummaryLine.Selected_By_User__c = true;
                    estSummaryLinesToUpdate.add(estSummaryLine);
                }
            }
        } else {
            // <T03>: page has loaded, user has just selected a section:
            if (sectionChecked) {
                for (Estimation_Summary_Line__c estSummaryLine : estSummaryLines) {
                    if (estSummaryLine.Page_Section__c == toggledPageSectionRecord.Id) {
                        justSelectedSectionIds.add(toggledPageSectionRecord.Id);
                    }
                }
            }
        }
        if (!estSummaryLinesToUpdate.isEmpty()) {
            update estSummaryLinesToUpdate; // added for <T03>, mainly to accommodate backfilling on pre-existing data
        }

        // Query out Consumption Schedule Records related to Estimation Summary
        // Per <T03>, this query has been modified to only query the necessary data on an as-need-basis
        Map<Id, ConsumptionSchedule> scheduleMap = new Map<Id, ConsumptionSchedule>(
            [
                SELECT
                    Id,
                    Page_Section__c,
                    Sequence__c,
                    Consumption_Description__c,
                    Rollup_Into_Estimation_Summary_Lines__c,
                    Picklist_Values__c,
                    Data_Type__c,
                    Required__c,
                    Default__c,
                    (
                        SELECT
                            Name,
                            Estimation_Schedule__c,
                            Estimation_Summary__c,
                            User_Value__c,
                            Original_Data_Type__c,
                            Notes__c,
                            Table_Cell__c,
                            Row_Number__c,
                            Column_Number__c,
                            Estimation_Schedule__r.Data_Type__c,
                            Estimation_Schedule__r.Default__c,
                            Estimation_Schedule__r.Consumption_Description__c,
                            Parent_Estimation_Schedule__c,
                            Parent_Estimation_Schedule__r.Sequence__c,
                            Parent_Estimation_Schedule__r.Data_Type__c,
                            Estimation_Schedule__r.Name,
                            Feed_External_User__c,
                            Feed_Internal_User__c
                        FROM Estimation_Outputs__r
                        WHERE Estimation_Summary__c = :estimationSummary.Id
                    )
                FROM ConsumptionSchedule
                WHERE
                    Page_Section__c IN :setPageSectionsId
                    AND Active__c = TRUE
                    // AND Sequence__c > 0
                    AND RecordType.DeveloperName = :IPUE_CONSTANTS.ESTIMATION_SCHEDULE_DEV_NAME
                    AND Page_Section__r.Parent_Page__r.Parent_Form__r.Id = :estimationSummary.Form__c
                    // <T03> additional query filters:
                    AND (Page_Section__r.Expansion_By_Default__c = TRUE
                    OR Page_Section__c IN :prevSelectedPageSectionIds
                    OR Page_Section__c IN :justSelectedSectionIds
                    OR Page_Section__c IN :pageSectionsWithoutLines
                    OR Sequence__c = 1)
                ORDER BY Sequence__c ASC
            ]
        );

        System.debug('scheduleMap.size(): ' + scheduleMap.size());

        return scheduleMap;
    }

    /**
     * Query SDoc_Template__c records, create SDocButton models, and add to pagesById variable
     * @param pagesById   PageWrapper models by page id
     * @return void
     */
    public static void createSDocTemplates(Map<Id, IPUE_FormControllerModels.PageWrapper> pagesById) {
        List<SDoc_Template__c> sDocTemplates = [
            SELECT Id, Sequence__c, Default__c, Template_Id__c, Button_Label__c, Page__c
            FROM SDoc_Template__c
            WHERE Page__c IN :pagesById.keySet() AND Sequence__c != NULL
            ORDER BY Sequence__c ASC
        ];

        // For every SDoc Template related to a Page, create a SDocButton Model and relate it to the Page
        for (SDoc_Template__c sDocTemplate : sDocTemplates) {
            IPUE_FormControllerModels.SDocButton sDocButton = new IPUE_FormControllerModels.SDocButton(sDocTemplate);
            pagesById.get(sDocTemplate.Page__c).sDocButtons.add(sDocButton);
        }
    }

    /**
     * Query Table_Cell__c records and build Table model and add to the wrapper to be used in createSectionItems()
     * @param scheduleMap   Consumption Schedule Map to use to help build table
     * @param wrapper       Data Wrapper to use to help build table
     * @param isClosed      whether associated Opportunity is closed or not
     * @return IPUE_FormControllerModels.DataWrapper
     */
    public static IPUE_FormControllerModels.DataWrapper buildTableFromConsumptionSchedules(
        Map<Id, ConsumptionSchedule> scheduleMap,
        IPUE_FormControllerModels.DataWrapper wrapper,
        Boolean isClosed
    ) {
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
                    IPUE_FormControllerModels.TableRow tableRow = new IPUE_FormControllerModels.TableRow();
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

    /**
     * Sort table rows and cells for a given data wrapper
     * @param wrapper   Data Wrapper to use to aid in sorting table rows and cells
     * @return IPUE_FormControllerModels.DataWrapper    the wrapper morphed by the method
     */
    public static IPUE_FormControllerModels.DataWrapper sortTableRowsAndCells(IPUE_FormControllerModels.DataWrapper wrapper) {
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

    /**
     * Create the section items for all prechecked sections when the page initially loads
     * Per <T03>, when user checks the checkbox on a section that wasn't initially checked, section items will only get created for that particular section.
     * @param pageSectionsById          sections to assimilate section items for
     * @param scheduleMap               consumption schedules whose data will be used to assimilate the section items
     * @param wrapper                   wrapper object containing the form data
     * @param newlyCheckedOnceBefore    <T03>: this is whether or not an initially unchecked page section was checked, unchecked, then rechecked
     * @return void
     */
    public static void createSectionItems(
        Map<Id, IPUE_FormControllerModels.PageSection> pageSectionsById,
        Map<Id, ConsumptionSchedule> scheduleMap,
        IPUE_FormControllerModels.DataWrapper wrapper,
        Boolean newlyCheckedOnceBefore
    ) {
        Map<Id, List<IPUE_FormControllerModels.EstimationSchedule>> schedulesBySectionId = new Map<Id, List<IPUE_FormControllerModels.EstimationSchedule>>();
        Map<Id, List<IPUE_FormControllerModels.Table>> tablesBySectionId = new Map<Id, List<IPUE_FormControllerModels.Table>>();
        Map<Id, List<IPUE_FormControllerModels.LightningServiceTemplate>> templatesBySectionId = new Map<Id, List<IPUE_FormControllerModels.LightningServiceTemplate>>();

        // For Every Consumption Schedule, create an EstimationSchedule or Table and add it to the applicable Map
        for (ConsumptionSchedule schedule : scheduleMap.values()) {
            if (schedule.Sequence__c > 0) {
                IPUE_FormControllerModels.PageSection pageSection = pageSectionsById.get(schedule.Page_Section__c);

                // If the Estimation Schedule has a Data Type of "Table" - Add Table to Page Section
                if (schedule.Data_Type__c == IPUE_CONSTANTS.TABLE_FIXED || schedule.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
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
                    IPUE_FormControllerModels.EstimationSchedule scheduleWrapper = new IPUE_FormControllerModels.EstimationSchedule(
                        schedule,
                        wrapper.oppModel.isClosed
                    );

                    if (scheduleWrapper.output != null) {
                        // If the Estimation Schedule is not "Calculated", calculate the numerator and denominator for progress ring
                        if (!scheduleWrapper.isCalculated) {
                            // added condition check for <T04>
                            if (!pageSection.greyOutProgressRingOnPageLoad && !pageSection.tableProgressRingsAssembled) {
                                pageSection.denominator += 1;
                                if (scheduleWrapper.output.value != null) {
                                    pageSection.numerator += 1;
                                }

                                if (pageSection.numerator > 0) {
                                    pageSection.progress = (pageSection.numerator / pageSection.denominator) * 100;
                                } else {
                                    pageSection.progress = 0;
                                }
                            }

                            // Otherise, Check to see if Estimation Schedule should be rolled up into Page Section Total
                        } else if (
                            schedule.Rollup_Into_Estimation_Summary_Lines__c &&
                            scheduleWrapper.output.value != null &&
                            pageSection.sectionTotalFromLine == 0 // added check for <T03>
                        ) {
                            // <T03>: no need for try/catch block. Just check if the output value is numeric:
                            if (scheduleWrapper.output.value != null && scheduleWrapper.output.value.isNumeric()) {
                                pageSection.sectionTotal += Integer.valueOf(scheduleWrapper.output.value);
                            }
                        } else {
                            // <T03>: in some cases, rollup to summary line is not active but we still need to get the IPUS for the section.
                            //  In that case, get the section total from the required IPUs value on the associated estimation summary line.
                            pageSection.sectionTotal = pageSection.sectionTotalFromLine;
                        }

                        List<IPUE_FormControllerModels.EstimationSchedule> estSchedules = schedulesBySectionId.get(pageSection.Id) == null
                            ? new List<IPUE_FormControllerModels.EstimationSchedule>()
                            : schedulesBySectionId.get(pageSection.Id);
                        estSchedules.add(scheduleWrapper);
                        schedulesBySectionId.put(pageSection.Id, estSchedules);
                    }
                }
            }
        }

        // <T03>: get additional properties for sections with tables
        if (!newlyCheckedOnceBefore) {
            for (Id sectionIdForTables : tablesBySectionId.keySet()) {
                if (pageSectionsById.containsKey(sectionIdForTables)) {
                    IPUE_FormControllerModels.PageSection pageSection = pageSectionsById.get(sectionIdForTables);
                    if (pageSection.preChecked) {
                        for (IPUE_FormControllerModels.Table table : tablesBySectionId.get(sectionIdForTables)) {
                            setAdditionalAtributesForLockableTables(pageSection, table, wrapper);
                        }
                    }
                }
            }
        }

        List<Lightning_Service_Template__c> templateList = [
            SELECT
                Id,
                Name,
                Content__c,
                Page_Section__c,
                Sequence__c,
                (
                    SELECT Id
                    FROM Lightning_Service_Members__r
                )
            FROM Lightning_Service_Template__c
            WHERE Page_Section__c IN :pageSectionsById.keySet() AND Sequence__c > 0
            ORDER BY Sequence__c ASC
        ];

        // For every Lightning Service Template record, create a Lightning Service Template model and add to the applicable Map
        for (Lightning_Service_Template__c template : templateList) {
            IPUE_FormControllerModels.PageSection pageSection = pageSectionsById.get(template.Page_Section__c);
            IPUE_FormControllerModels.LightningServiceTemplate templateWrapper = new IPUE_FormControllerModels.LightningServiceTemplate(
                template.Name,
                template.Id,
                template.Page_Section__c,
                null,
                template.Content__c,
                template.Sequence__c
            );
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
            List<IPUE_FormControllerModels.EstimationSchedule> schedules = schedulesBySectionId.containsKey(section.Id)
                ? schedulesBySectionId.get(section.Id)
                : new List<IPUE_FormControllerModels.EstimationSchedule>();
            List<IPUE_FormControllerModels.LightningServiceTemplate> templates = templatesBySectionId.containsKey(section.Id)
                ? templatesBySectionId.get(section.Id)
                : new List<IPUE_FormControllerModels.LightningServiceTemplate>();
            List<IPUE_FormControllerModels.Table> tables = tablesBySectionId.containsKey(section.Id)
                ? tablesBySectionId.get(section.Id)
                : new List<IPUE_FormControllerModels.Table>();

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
                IPUE_FormControllerModels.SectionItem sectionItem = new IPUE_FormControllerModels.SectionItem(table, section); // add section param for <T03>
                section.hasTables = true;
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
                // section.showSection = true; // commenting out for <T03>
                // section.showTitle = false; // commenting out for <T03>
                // section.disableCheckbox = true; // commenting out for <T03>
                // section.showProgress = false; // commenting out for <T03>
            }
        }
    }

    /**
     * <T04>: get the progress attributes (numerator, denom) for fixed or elastic tables
     * @param pageSection   the page section to get progress
     * @param table         a table within the page section
     * @param pageSection   the page section to get progress
     */
    private static void setAdditionalAtributesForLockableTables(
        IPUE_FormControllerModels.PageSection pageSection,
        IPUE_FormControllerModels.Table table,
        IPUE_FormControllerModels.DataWrapper wrapper
    ) {
        Map<Integer, IPUE_FormControllerModels.TableCell> tableCellMap = table?.rowsByRowNumber?.get(0).cellsByColumnNumber;
        String firstHeaderCellDescription = tableCellMap?.get(1)?.description;
        // only target tables that will have the lock toggle:
        if (firstHeaderCellDescription == null || firstHeaderCellDescription == '') {
            pageSection.denominator += tableCellMap.size() - 1;
            for (IPUE_FormControllerModels.TableRow row : table.rowsByRowNumber.values()) {
                // skip header row:
                if (row.rowNumber > 0) {
                    for (IPUE_FormControllerModels.TableCell cell : row.cellsByColumnNumber.values()) {
                        if (!cell.isPerpetualReadOnlyInput && cell.output.value != null && cell.output.value != '') {
                            pageSection.numerator += 1;
                        }
                    }
                }
            }

            if (pageSection.numerator > 0) {
                pageSection.progress = (pageSection.numerator / pageSection.denominator) * 100;
            } else {
                pageSection.progress = 0;
            }
            pageSection.tableProgressRingsAssembled = true;
        }
    }

    /**
     * Assimilate and add outputs to a given table
     * @param estimationSummaryId   the Id of Estimation Summary to which the table row is being added to
     * @param tableId               the Id of the parent Estimation Schedule
     * @param numRows               number of rows for a given table
     * @param numColumns            number of columns for a given table
     * @return IPUE_FormControllerModels.Table    table with added outputs
     */
    public static IPUE_FormControllerModels.Table createOutputsAndAddTableRow(
        Id estimationSummaryId,
        Id tableId,
        Integer numRows,
        Integer numColumns
    ) {
        Map<Decimal, Estimation_Output__c> outputsToInsertByColumn = new Map<Decimal, Estimation_Output__c>();
        Set<Id> estimationScheduleIds = new Set<Id>();

        // Create a new row to hold the new Table Cells/Estimation Outputs
        IPUE_FormControllerModels.TableRow newRow = new IPUE_FormControllerModels.TableRow();
        newRow.rowNumber = numRows;

        // Find all Table Cell metadata with the Row = 1 that is associated to the table
        List<Table_Cell__c> row1TableCells = [
            SELECT
                Id,
                Child_Estimation_Schedule__c,
                Parent_Estimation_Schedule__c,
                Row_Number__c,
                Column_Number__c,
                Child_Estimation_Schedule__r.Name,
                Parent_Estimation_Schedule__r.Name
            FROM Table_Cell__c
            WHERE Parent_Estimation_Schedule__c = :tableId AND Child_Estimation_Schedule__r.Active__c = TRUE AND Row_Number__c = 1
        ];

        // Get Estimation Schedule Ids for all Child Schedules related to a Cell
        for (Table_Cell__c tableCell : row1TableCells) {
            estimationScheduleIds.add(tableCell.Child_Estimation_Schedule__c);
        }

        // Query out Estimation Schedule data
        Map<Id, ConsumptionSchedule> estimationScheduleMap = new Map<Id, ConsumptionSchedule>(
            [
                SELECT
                    Id,
                    Consumption_Description__c,
                    Data_Type__c,
                    Default__c,
                    Picklist_Values__c,
                    Page_Section__r.Parent_Page__r.Id,
                    Rollup_Into_Estimation_Summary_Lines__c,
                    Page_Section__r.Parent_Page__r.Parent_Form__c,
                    Page_Section__r.Parent_Page__c,
                    Page_Section__c,
                    (
                        SELECT ProductId
                        FROM ProductConsumptionSchedules
                        LIMIT 1
                    )
                FROM ConsumptionSchedule
                WHERE Id IN :estimationScheduleIds
            ]
        );

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
            newOutput.Name =
                'Elastic Output Row ' +
                newOutput.Row_Number__c +
                ' Column ' +
                newOutput.Column_Number__c +
                ' (' +
                cell.Parent_Estimation_Schedule__r.Name +
                ')';

            // If the Estimation Schedule has an associated Product, populate the Product lookup field
            if (
                !estimationSchedule.ProductConsumptionSchedules.isEmpty() &&
                estimationSchedule.ProductConsumptionSchedules[0].productId != null
            ) {
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

    public static IPUE_FormControllerModels.Table deleteOutputs(Id estimationSummaryId, Id tableId, Integer rowIndex) {
        List<Estimation_Output__c> outputsToDelete = new List<Estimation_Output__c>();
        List<Estimation_Output__c> outputsToUpdate = new List<Estimation_Output__c>();
        Set<Id> childEstimationScheduleIds = new Set<Id>();

        // Find all Estimation Outputs related to the Elastic Table
        List<Estimation_Output__c> estimationOutputs = [
            SELECT
                Id,
                Name,
                Row_Number__c,
                Column_Number__c,
                Original_Data_Type__c,
                User_Value__c,
                Form__c,
                Page_Section__c,
                Estimation_Schedule__r.Default__c,
                Estimation_Schedule__c,
                Estimation_Summary__c,
                Parent_Estimation_Schedule__c,
                Notes__c,
                Parent_Estimation_Schedule__r.Name,
                Feed_Internal_User__c,
                Feed_External_User__c
            FROM Estimation_Output__c
            WHERE Parent_Estimation_Schedule__c = :tableId AND Estimation_Schedule__r.Active__c = TRUE
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
                    output.Name =
                        'Elastic Output Row ' +
                        output.Row_Number__c +
                        ' Column ' +
                        output.Column_Number__c +
                        ' (' +
                        output.Parent_Estimation_Schedule__r.Name +
                        ')';
                    outputsToUpdate.add(output);
                }
            }
        }

        delete outputsToDelete; // Delete Outputs related to row to delete
        update outputsToUpdate; // Update new Row Number in existing Outputs

        // Query out Consumption Schedule Records related to updated Estimation Outputs
        Map<Id, ConsumptionSchedule> scheduleMap = new Map<Id, ConsumptionSchedule>(
            [
                SELECT
                    Id,
                    Page_Section__c,
                    Sequence__c,
                    Consumption_Description__c,
                    Rollup_Into_Estimation_Summary_Lines__c,
                    Picklist_Values__c,
                    Data_Type__c,
                    Required__c,
                    Default__c,
                    (
                        SELECT
                            Name,
                            Estimation_Schedule__c,
                            Estimation_Summary__c,
                            User_Value__c,
                            Original_Data_Type__c,
                            Notes__c,
                            Table_Cell__c,
                            Row_Number__c,
                            Column_Number__c,
                            Estimation_Schedule__r.Data_Type__c,
                            Estimation_Schedule__r.Default__c,
                            Estimation_Schedule__r.Consumption_Description__c,
                            Parent_Estimation_Schedule__c,
                            Parent_Estimation_Schedule__r.Sequence__c,
                            Parent_Estimation_Schedule__r.Data_Type__c,
                            Feed_Internal_User__c,
                            Feed_External_User__c
                        FROM Estimation_Outputs__r
                        WHERE Estimation_Summary__c = :estimationSummaryId
                    )
                FROM ConsumptionSchedule
                WHERE Id IN :childEstimationScheduleIds
            ]
        );

        IPUE_FormControllerModels.DataWrapper wrapper = buildTableFromConsumptionSchedules(
            scheduleMap,
            new IPUE_FormControllerModels.DataWrapper(),
            false
        );
        wrapper = sortTableRowsAndCells(wrapper);

        return wrapper.tableByParentEstimationSchedule.get(tableId);
    }
}
