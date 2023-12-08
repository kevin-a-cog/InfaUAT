/**
 * Name         : IPUE_FormInputHelper
 * Author       : Colton Kloppel | ATG, Cognizant | Colton.Kloppel@atginfo.com
 * Created Date : October 01, 2021
 * Description  : This test class covers IPUE_FileUploadController
 *
 * Change History
 **********************************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description                             Tag
 **********************************************************************************************************
 * Colton Kloppel       10-01-2021      IPUE-52      Initial create
 * Stephanie Viereckl   Feb 2022        IPUE-153/193    Refactor to support Tables
 * Chandana Gowda       11/Jan/2022     SALESRT-14808   Enhance IPU calculation performance     <T02>
 * Kevin Antonioli      15/Nov/2022     PNP-515         Enhance IPU calculation performance     <T03>
 **********************************************************************************************************
 */
public without sharing class IPUE_FormInputHelper {
    private static Boolean entitlementFieldExists = false;

    public class CalculationException extends Exception {
    }

    // <T03>: added wrapper class so IPUE_FormController can read the summary lines as well
    public class CalcReturnWrapper {
        @AuraEnabled
        public Map<Id, Estimation_Output__c> outputsToReturnMap;
        @AuraEnabled
        public List<Estimation_Summary_Line__c> calculatedSummaryLines;
        @AuraEnabled
        public Decimal totalRequiredIpus = 0;
    }

    /**
     * Process user inputs to the Estimator Summary form
     * @param JSONPayload                       payload containing the section the user edited inputs within
     * @param estimationId                      id of the estimation summary the user edited inputs within
     * @param selectedSectionIds                <T03>: list of ids for all selected/expanded sections
     * @param concurrentCalcTriggeredSectionIds <T03>: accrued list of ids for sections that triggered calculation (for when user triggered a calc before another calc completed)
     * @return map of updated estimation outputs applicable to the calculation
     */
    public static CalcReturnWrapper processInput(
        String JSONPayload,
        Id estimationId,
        List<Id> selectedSectionIds,
        List<Id> concurrentCalcTriggeredSectionIds
    ) {
        System.debug('IPUE_FormInputHelper selectedSectionIds: ' + selectedSectionIds);
        System.debug('IPUE_FormInputHelper concurrentCalcTriggeredSectionIds: ' + concurrentCalcTriggeredSectionIds);

        List<IPUE_FormControllerModels.EstimationOutput> outputModelList = new List<IPUE_FormControllerModels.EstimationOutput>();
        Map<Id, Estimation_Output__c> outputsToReturnMap = new Map<Id, Estimation_Output__c>();

        // Deserialize the JSON Payload into the InputSectionWrapper
        Type pageSectionClassType = Type.forName('IPUE_FormControllerModels.PageSection');
        IPUE_FormControllerModels.PageSection sectionWrapper = (IPUE_FormControllerModels.PageSection) JSON.deserialize(
            JSONPayload,
            pageSectionClassType
        );

        /***********************************************************
         * Find and Save User's Input into Estimation Output records
         ***********************************************************/

        Decimal entitlementValue = 0; // <T03>
        Set<Id> entitlementSectionIdsThatTriggerCalc = new Set<Id>(); // <T03>: entitlement section id(s) that triggered the calc

        // Loop through every Section Item and build map of Outputs needed Calculations, and Outputs needing to be updated
        for (IPUE_FormControllerModels.SectionItem sectionItem : sectionWrapper.sectionItems) {
            // For Section Items that are regular Estimation Schedules (i.e. Questions)
            if (sectionItem.isSchedule) {
                IPUE_FormControllerModels.EstimationOutput output = sectionItem.schedule.output;
                outputModelList.add(output);

                // <T03>:
                if (
                    sectionItem.schedule.description != null &&
                    sectionItem.schedule.description.toLowerCase().contains(IPUE_CONSTANTS.CURRENT_IPU_ENTITLEMENT_STR)
                ) {
                    if (sectionItem.schedule.output.value != null && sectionItem.schedule.output.value.isNumeric()) {
                        entitlementValue = Decimal.valueOf(sectionItem.schedule.output.value);
                        entitlementSectionIdsThatTriggerCalc.add(sectionWrapper.Id);
                    }
                }

                // For Section Items that are Tables
            } else if (sectionItem.isTable) {
                // Loop through all Table Cells within the Table Rows & Cells
                for (IPUE_FormControllerModels.TableRow row : sectionItem.table.rows) {
                    for (IPUE_FormControllerModels.TableCell cell : row.cells) {
                        // If the cell has an output (i.e. is not a placeholder) get the Output
                        if (cell.output != null) {
                            IPUE_FormControllerModels.EstimationOutput output = cell.output;
                            outputModelList.add(output);
                        }
                    }
                }
            }
        }

        System.debug('IPUE_FormInputHelper entitlementValue: ' + entitlementValue);
        System.debug('IPUE_FormInputHelper entitlementSectionIdsThatTriggerCalc: ' + entitlementSectionIdsThatTriggerCalc);

        // Prepare list for update for ONLY outputs that do not need to be calculated
        List<Estimation_Output__c> outputRecordsToUpdateList = new List<Estimation_Output__c>();

        // All Estimation Output Records are created on insert of the Estimation Summary.
        Map<Id, Estimation_Output__c> applicableOutputRecordsMap = new Map<Id, Estimation_Output__c>(
            [
                SELECT
                    Id,
                    Name,
                    Product__c,
                    Estimation_Summary__c,
                    Estimation_Schedule__c,
                    User_Value__c,
                    Estimation_Schedule__r.Data_Type__c,
                    Section_filled__c,
                    Estimation_Schedule__r.IPU_Calculation__c,
                    Estimation_Schedule__r.Name,
                    Estimation_Schedule__r.Active__c,
                    IPUE_ScheduleName__c,
                    Page_Section__c,
                    Page_Section__r.Title_Visibility__c,
                    Page_Section__r.Cross_Dependent_On_Other_Sections__c,
                    Page_Section__r.Parent_Page__r.Parent_Form__c,
                    Page_Section__r.Parent_Page__r.Page_Number__c,
                    Page_Section__r.Weighted_Average_Applicable__c,
                    Rollup_Into_Estimation_Summary_Lines__c,
                    Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c,
                    Column_Number__c,
                    Row_Number__c,
                    Parent_Estimation_Schedule__c,
                    Parent_Estimation_Schedule__r.Name,
                    Parent_Estimation_Schedule__r.Data_Type__c,
                    Estimation_Schedule__r.IPU_Calculation__r.IPUE_PostfixFormula__c,
                    Estimation_Schedule__r.IPU_Calculation__r.Name,
                    Estimation_Schedule__r.IPU_Calculation__r.Formula__c,
                    Estimation_Schedule__r.Sequence__c,
                    Estimation_Schedule__r.Consumption_Description__c
                FROM Estimation_Output__c
                WHERE
                    Estimation_Summary__c = :estimationId
                    AND Page_Section__c IN :selectedSectionIds /* <T03: add selectedSectionIds filter */
                ORDER BY Page_Section__r.Sequence__c
            ]
        );

        for (IPUE_FormControllerModels.EstimationOutput outputModel : outputModelList) {
            //Utilize the allFromOutputRecordsMap to find the Output to update.
            if (applicableOutputRecordsMap.containsKey(outputModel.Id)) {
                //Update the value with what was recieved from the LWC.  The applicableOutputRecordsMap will be reused Later.
                applicableOutputRecordsMap.get(outputModel.Id).User_Value__c = outputModel.value;

                applicableOutputRecordsMap.get(outputModel.Id).Section_filled__c = true; //check the section filled to true - <T02>

                // Add Estimation Output to List to be updated
                outputRecordsToUpdateList.add(applicableOutputRecordsMap.get(outputModel.Id));
            }
        }

        try {
            update outputRecordsToUpdateList;
            outputsToReturnMap.putall(outputRecordsToUpdateList);
        } catch (Exception ex) {
            System.debug('Exception occurred during update of uncalculated Outputs: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());
            throw new CalculationException('Exception thrown while updating uncalculated Estimation Outputs: ' + ex.getMessage());
        }

        /**********************************
         * Begin Preparing for Calculations
         **********************************/

        // Create Calculation Groups to hold Estimation Outputs by their Id and a List of Estimation Outputs by Calculations Ids

        // Group #1: Calculated Estimation Outputs that live within Elastic Tables
        Map<Id, Estimation_Output__c> outputsUsedInElasticCalculations = new Map<Id, Estimation_Output__c>();
        Map<Id, List<Estimation_Output__c>> elasticCalcOutputCalcsByCalcId = new Map<Id, List<Estimation_Output__c>>();

        // Group #2: Calculated Estimation Outputs that contain aggregate functions
        Map<Id, Estimation_Output__c> outputsUsedInAggregateFunctions = new Map<Id, Estimation_Output__c>();
        Map<Id, List<Estimation_Output__c>> aggregateCalcOutputCalcsByCalcId = new Map<Id, List<Estimation_Output__c>>();

        // Group #3: All other Calculated Estimation Output records
        Map<Id, Estimation_Output__c> remainingOutputsToCalculate = new Map<Id, Estimation_Output__c>();
        Map<Id, List<Estimation_Output__c>> calcOutputListByCalculationId = new Map<Id, List<Estimation_Output__c>>();

        //All the calcualtion estimation outputs in the unfilled sections, these map members are not evaluated and always defaluted to 0 - <T02>
        Map<Id, Map<String, Decimal>> avoidRecursionCalculation = new Map<Id, Map<String, Decimal>>();

        // <T03>: only update relevant values, skip calcs if the values will not end up changing for their associated outputs
        Set<Id> outputsNotToUpdate = new Set<Id>();
        Set<Id> calcIdsToSkip = new Set<Id>();

        // <T03>: don't use formulas to calculate page subtotals and additional ipus needed
        //  Instead, use more simplistic summations to help avoid CPU timeout
        List<Id> crossDependentSectionIds = new List<Id>();

        // Loop through all Estimation Output records associated to the Estimation Summary and determine which "Calculation Group" they should be in
        for (Estimation_Output__c output : applicableOutputRecordsMap.values()) {
            String consumptionDescription = output.Estimation_Schedule__r.Consumption_Description__c;
            // <T03>: if user updated the entitlement value to trigger calculation, skip
            if (!entitlementSectionIdsThatTriggerCalc.contains(output.Page_Section__c)) {
                Decimal calculatedValue;
                if (String.isBlank(output.User_Value__c)) {
                    calculatedValue = 0;
                } else if (output.User_Value__c.isNumeric()) {
                    calculatedValue = Decimal.valueOf(output.User_Value__c);
                }
                Id calculationId = output.Estimation_Schedule__r.IPU_Calculation__c;

                // Populate Group #1 Data: If the Outputs is in an elastic table, populate collections to use in Elastic Table Calculations (i.e. row by row calculations)
                if (output.Parent_Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
                    // Ignore Headers completely
                    if (output.Row_Number__c > 0) {
                        // Populate Map of all Elastic Table Cells to be used in elastic table cell calculations
                        outputsUsedInElasticCalculations.put(output.Id, output);

                        // In addition, if value is calculated, add to Map of calculated Ids
                        //Add the estimation output for calcualtion only if the section filled checkbox is checked or it is an by default expanded section - <T02>
                        if (
                            output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.CALCULATED &&
                            calculationId != null &&
                            output.Estimation_Schedule__r.Active__c &&
                            (output.Section_filled__c ||
                            output.Page_Section__r.Title_Visibility__c != 'Visible' ||
                            output.Estimation_Schedule__r.Sequence__c <= 0)
                        ) {
                            List<Estimation_Output__c> elasticCalculationOutputs = new List<Estimation_Output__c>();
                            if (elasticCalcOutputCalcsByCalcId.containsKey(calculationId)) {
                                elasticCalculationOutputs = elasticCalcOutputCalcsByCalcId.get(calculationId);
                            }
                            elasticCalculationOutputs.add(output);
                            elasticCalcOutputCalcsByCalcId.put(calculationId, elasticCalculationOutputs);
                        } else {
                            //Decimal calculatedValue = String.isBlank(output.User_Value__c) ? 0 : Decimal.valueOf(output.User_Value__c);
                            avoidRecursionCalculation.put(
                                calculationId,
                                new Map<String, Decimal>{ output.Estimation_Schedule__r.Name => calculatedValue }
                            );
                        }
                    }

                    // Populate Group #2 Data: If the output is an elastic table itself, add output to map to be used in aggregate functions
                } else if (output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
                    outputsUsedInAggregateFunctions.put(output.Id, output);
                    // If the output is a Calculated Value...
                } else if (
                    output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.CALCULATED &&
                    calculationId != null &&
                    output.Estimation_Schedule__r.Active__c
                ) {
                    // Populate Group #2 Data: If the output is a table function, add to collections to be used in aggregate function calculations (i.e. sum column 1 of elastic table row)
                    if (IPUE_CalculationUtils.containsTableFunction(output.Estimation_Schedule__r.IPU_Calculation__r.Formula__c + '(')) {
                        // Populate map of outputs to be used in aggregate functions
                        outputsUsedInAggregateFunctions.put(output.Id, output);

                        //Add the estimation output for calculation only if the section filled checkbox is checked or it is a by-default expanded section - <T02>
                        if (
                            output.Section_filled__c ||
                            output.Page_Section__r.Title_Visibility__c != 'Visible' ||
                            output.Estimation_Schedule__r.Sequence__c <= 0
                        ) {
                            List<Estimation_Output__c> aggregateCalculationOutputs = new List<Estimation_Output__c>();
                            if (aggregateCalcOutputCalcsByCalcId.containsKey(calculationId)) {
                                aggregateCalculationOutputs = aggregateCalcOutputCalcsByCalcId.get(calculationId);
                            }
                            aggregateCalculationOutputs.add(output);
                            aggregateCalcOutputCalcsByCalcId.put(calculationId, aggregateCalculationOutputs);
                        } else {
                            //Decimal calculatedValue = String.isBlank(output.User_Value__c) ? 0 : Decimal.valueOf(output.User_Value__c);
                            avoidRecursionCalculation.put(
                                calculationId,
                                new Map<String, Decimal>{ output.Estimation_Schedule__r.Name => calculatedValue }
                            );
                        }

                        // Populate Group #3 Data: Otherwise, it is a normal calculation and should be added to all other calculations
                    } else {
                        // Populate Map of outputs unrelated to tables
                        remainingOutputsToCalculate.put(output.Id, output);
                        //Perform the calculation only for records where the section is filled
                        if (
                            output.Section_filled__c ||
                            output.Page_Section__r.Title_Visibility__c != 'Visible' ||
                            output.Estimation_Schedule__r.Sequence__c <= 0
                        ) {
                            List<Estimation_Output__c> calculationOutputs = new List<Estimation_Output__c>();
                            if (calcOutputListByCalculationId.containsKey(calculationId)) {
                                calculationOutputs = calcOutputListByCalculationId.get(calculationId);
                            }
                            calculationOutputs.add(output);
                            calcOutputListByCalculationId.put(calculationId, calculationOutputs);
                        } else {
                            //Decimal calculatedValue = String.isBlank(output.User_Value__c) ? 0 : Decimal.valueOf(output.User_Value__c);
                            avoidRecursionCalculation.put(
                                calculationId,
                                new Map<String, Decimal>{ output.Estimation_Schedule__r.Name => calculatedValue }
                            );
                        }
                    }

                    // Populate Group #3 Data: Otherwise, this output is POTENTENTIALLY related to a table and is not calculated (therefore it is an input)
                } else {
                    // Populate Map of outputs potentially related to tables
                    // <T03>: avoid calculating outputs that meet both of the following criteria:
                    //   None of the parent section's outputs will end up changing as a result of the calculation.
                    //   None of the parent section's outputs will affect the outputs of other sections
                    if (!sectionWrapper.showTitle) {
                        if (
                            (output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.NUM ||
                            output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.PICKLIST) &&
                            output.Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c ||
                            output.Page_Section__c == sectionWrapper.Id ||
                            output.Page_Section__r.Weighted_Average_Applicable__c
                        ) {
                            remainingOutputsToCalculate.put(output.Id, output);
                        }
                    } else if (
                        (output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.NUM ||
                        output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.PICKLIST) &&
                        (output.Page_Section__c == sectionWrapper.Id ||
                        output.Page_Section__r.Title_Visibility__c == 'Hide' ||
                        output.Page_Section__r.Cross_Dependent_On_Other_Sections__c ||
                        output.Page_Section__r.Weighted_Average_Applicable__c)
                    ) {
                        remainingOutputsToCalculate.put(output.Id, output);
                    } else if (concurrentCalcTriggeredSectionIds.contains(output.Page_Section__c)) {
                        remainingOutputsToCalculate.put(output.Id, output);
                    }
                }

                // <T03>: similar to above, ensure only the necessary outputs are evaluated/calculated
                if (calculatedValue != null) {
                    if (!sectionWrapper.showTitle) {
                        if (
                            output.Estimation_Schedule__r.Data_Type__c != IPUE_CONSTANTS.CALCULATED ||
                            (!concurrentCalcTriggeredSectionIds.contains(output.Page_Section__c) &&
                            !output.Page_Section__r.Weighted_Average_Applicable__c &&
                            !output.Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c &&
                            output.Page_Section__c != sectionWrapper.Id)
                        ) {
                            outputsNotToUpdate.add(output.Id);
                            calcIdsToSkip.add(output.Estimation_Schedule__r.IPU_Calculation__c);
                            avoidRecursionCalculation.put(
                                calculationId,
                                new Map<String, Decimal>{ output.Estimation_Schedule__r.Name => calculatedValue }
                            );
                        }
                    } else if (
                        output.Estimation_Schedule__r.Data_Type__c != IPUE_CONSTANTS.CALCULATED ||
                        (!concurrentCalcTriggeredSectionIds.contains(output.Page_Section__c) &&
                        !output.Page_Section__r.Weighted_Average_Applicable__c &&
                        output.Page_Section__c != sectionWrapper.Id &&
                        output.Page_Section__r.Title_Visibility__c != 'Hide' &&
                        !output.Page_Section__r.Cross_Dependent_On_Other_Sections__c)
                    ) {
                        outputsNotToUpdate.add(output.Id);
                        calcIdsToSkip.add(output.Estimation_Schedule__r.IPU_Calculation__c);
                        avoidRecursionCalculation.put(
                            calculationId,
                            new Map<String, Decimal>{ output.Estimation_Schedule__r.Name => calculatedValue }
                        );
                    }
                }

                // <T03>: skip current page subtotal and additional ipus needed outputs and sum up the totals for those further down

                if (
                    consumptionDescription != null &&
                    (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.CURRENT_PAGE_IPU_SUBTOTAL_STR) ||
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.NEXT_PAGE_IPU_SUBTOTAL_STR) ||
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.PREV_PAGE_IPU_SUBTOTAL_STR) ||
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.ADDITIONAL_IPUS_NEEDED_STR))
                ) {
                    outputsNotToUpdate.add(output.Id);
                    calcIdsToSkip.add(output.Estimation_Schedule__r.IPU_Calculation__c);
                    avoidRecursionCalculation.put(
                        calculationId,
                        new Map<String, Decimal>{ output.Estimation_Schedule__r.Name => calculatedValue }
                    );
                }
            }
            // <T03>: assign entitlement variables
            if (
                consumptionDescription != null &&
                entitlementSectionIdsThatTriggerCalc.isEmpty() &&
                consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.CURRENT_IPU_ENTITLEMENT_STR)
            ) {
                entitlementFieldExists = true;
                if (output.User_Value__c != null && output.User_Value__c.isNumeric()) {
                    entitlementValue = Decimal.valueOf(output.User_Value__c);
                }
            }
            // <T03>: gather cross dependent section ids
            if (output.Page_Section__r.Cross_Dependent_On_Other_Sections__c) {
                crossDependentSectionIds.add(output.Page_Section__c);
            }
        }

        System.debug('IPUE_FormInputHelper remainingOutputsToCalculate.size()' + remainingOutputsToCalculate.size());
        System.debug('IPUE_FormInputHelper avoidRecursionCalculation.size()' + avoidRecursionCalculation.size());
        System.debug('IPUE_FormInputHelper outputsNotToUpdate.size()' + outputsNotToUpdate.size());
        System.debug('IPUE_FormInputHelper calcIdsToSkip.size()' + calcIdsToSkip.size());

        /**********************************
         * Get Calculation Record Data
         **********************************/

        List<CalculationScheduleMember__c> calcMemberList;

        // <T03> for forms with entitlements/weighted average, limit the calc member query further
        //   We will calculate the entitlement outputs more simplistically when entitlement is changed
        List<Id> sectionIdsForCalcMemberQuery = new List<Id>();
        if (entitlementSectionIdsThatTriggerCalc.isEmpty()) {
            sectionIdsForCalcMemberQuery = selectedSectionIds;
        } else {
            sectionIdsForCalcMemberQuery.add(sectionWrapper.Id);
            //sectionIdsForCalcMemberQuery.addAll(crossDependentSectionIds);
        }

        // <T03>: add condition check:
        //   Only query schedule members if the the field that kicked off the calc is not the entitlement field
        if (entitlementSectionIdsThatTriggerCalc.isEmpty()) {
            //Find all join records of Calculation and Consumption Schedule, where the schedule existed within the list of Consumption Schedules modified on the Page Section.
            calcMemberList = new List<CalculationScheduleMember__c>(
                [
                    SELECT
                        Id,
                        Consumption_Schedule__c,
                        Calculation__c,
                        Calculation__r.Formula__c,
                        Calculation__r.IPUE_PostfixFormula__c,
                        Calculation__r.Name
                    FROM CalculationScheduleMember__c
                    WHERE
                        Consumption_Schedule__r.Page_Section__c IN :sectionIdsForCalcMemberQuery /* <T03>: added filter to improve performance */
                        AND Calculation__c NOT IN :calcIdsToSkip /* <T03>: added filter to improve performance */
                        AND (Calculation__c IN :elasticCalcOutputCalcsByCalcId.keySet()
                        OR Calculation__c IN :aggregateCalcOutputCalcsByCalcId.keySet()
                        OR Calculation__c IN :calcOutputListByCalculationId.keySet())
                ]
            );
        } else {
            calcMemberList = new List<CalculationScheduleMember__c>();
        }

        System.debug('IPUE_FormInputHelper calcMemberList.size()' + calcMemberList.size());

        //Store Calculation in Map to easily pull when sending to Util class
        Map<Id, Calculation__c> calculationFromMemberMap = new Map<Id, Calculation__c>();
        //Instantiate list to be used and overwritten when building map
        List<ConsumptionSchedule> calculatedScheduleList;

        for (CalculationScheduleMember__c calcMember : calcMemberList) {
            // Create Calculation Record based on join object
            if (calculationFromMemberMap.get(calcMember.Calculation__c) == null) {
                Calculation__c queriedCalc = new Calculation__c();
                queriedCalc.Id = calcMember.Calculation__c;
                queriedCalc.IPUE_PostfixFormula__c = calcMember.Calculation__r.IPUE_PostfixFormula__c;
                queriedCalc.Formula__c = calcMember.Calculation__r.Formula__c;
                queriedCalc.Name = calcMember.Calculation__r.Name;
                // Build a Map where the key = Calculation Id, value = Calculation Record
                calculationFromMemberMap.put(queriedCalc.Id, queriedCalc);
            }
        }

        /**********************************
         * Begin Calculations
         **********************************/

        //Store the outputs that will need to be recalculated by their calculation Id.
        Map<Id, Estimation_Output__c> calculatedOutputByOutputId = new Map<Id, Estimation_Output__c>();

        /*************************************************************************************************
         * #1 Perform calculations on elastic row table cells (which should only ever reference cells within the same row)
         *************************************************************************************************/

        for (Id calcId : elasticCalcOutputCalcsByCalcId.keyset()) {
            Map<Id, Map<String, Decimal>> calculatedResultsByCalcId = IPUE_CalculationUtils.evaluateCalculation(
                calculationFromMemberMap.get(calcId), // Calculation Record
                outputsUsedInElasticCalculations.values(), // All Estimation Outputs related to Estimation Summary, where parent section is selected or showTitle = false
                avoidRecursionCalculation //Added the parameter avoidRecursionCalculation - <T02>
            );

            // Loop through results on Calculation Id Map
            for (Id resultCalcId : calculatedResultsByCalcId.keyset()) {
                if (elasticCalcOutputCalcsByCalcId.containsKey(resultCalcId)) {
                    Map<String, Decimal> answerMap = calculatedResultsByCalcId.get(resultCalcId);

                    for (Estimation_Output__c output : elasticCalcOutputCalcsByCalcId.get(resultCalcId)) {
                        Decimal result;

                        if (output.Row_Number__c != null && answerMap.containsKey(String.valueOf(output.Row_Number__c))) {
                            result = answerMap.get(String.valueOf(output.Row_Number__c));
                        } else {
                            result = answerMap.get(IPUE_CONSTANTS.DEFAULT_KEY);
                        }

                        output.User_Value__c = String.valueOf(result);
                        outputsUsedInElasticCalculations.put(output.Id, output); // Add updated table cell to list to be calculated next
                        calculatedOutputByOutputId.put(output.Id, output); // Add to map to be updated
                    }
                }
            }
        }

        // Add all elastic cells to output list to be used in column aggregations
        outputsUsedInAggregateFunctions.putAll(outputsUsedInElasticCalculations);

        /*************************************************************************************************
        * #2 Perform calculations on aggregate functions, which should only ever reference elastic table cells, which
        should have been calculated in the step before
        *************************************************************************************************/
        for (Id calcId : aggregateCalcOutputCalcsByCalcId.keyset()) {
            Map<Id, Map<String, Decimal>> calculatedResultsByCalcId = IPUE_CalculationUtils.evaluateCalculation(
                calculationFromMemberMap.get(calcId), // Calculation Record
                outputsUsedInAggregateFunctions.values(), // Elastic Table Cells
                avoidRecursionCalculation //Added the parameter avoidRecursionCalculation - <T02>
            );

            // Loop through results on Calculation Id Map
            for (Id resultCalcId : calculatedResultsByCalcId.keyset()) {
                if (aggregateCalcOutputCalcsByCalcId.containsKey(resultCalcId)) {
                    Map<String, Decimal> answerMap = calculatedResultsByCalcId.get(resultCalcId);

                    // Loop through list of Estimation Outputs associated to the same Calculation record
                    for (Estimation_Output__c output : aggregateCalcOutputCalcsByCalcId.get(resultCalcId)) {
                        Decimal result = answerMap.get(IPUE_CONSTANTS.DEFAULT_KEY);
                        output.User_Value__c = String.valueOf(result);

                        remainingOutputsToCalculate.put(output.Id, output); // Add updated table value to next list to be processed
                        calculatedOutputByOutputId.put(output.Id, output); // Add to map to be updated
                    }
                }
            }
        }

        /*************************************************************************************************
         * #3 Perform all other calculations (including those that reference previously calculated values)
         *************************************************************************************************/
        for (Id calcId : calcOutputListByCalculationId.keyset()) {
            if (calculationFromMemberMap.get(calcId) != null) {
                Map<Id, Map<String, Decimal>> calculatedResultsByCalcId = IPUE_CalculationUtils.evaluateCalculation(
                    calculationFromMemberMap.get(calcId), // Calculation Record
                    remainingOutputsToCalculate.values(), // All Estimation Outputs related to selected page sections within the Estimation Summary,
                    avoidRecursionCalculation // Added the parameter avoidRecursionCalculation - <T02>
                );

                // Loop through results on Calculation Id Map
                for (Id resultCalcId : calculatedResultsByCalcId.keyset()) {
                    if (calcOutputListByCalculationId.containsKey(resultCalcId)) {
                        Map<String, Decimal> answerMap = calculatedResultsByCalcId.get(resultCalcId);

                        // Loop through list of Estimation Outputs associated to the same Calculation record
                        for (Estimation_Output__c output : calcOutputListByCalculationId.get(resultCalcId)) {
                            Decimal result = answerMap.get(IPUE_CONSTANTS.DEFAULT_KEY);
                            output.User_Value__c = String.valueOf(result);
                            calculatedOutputByOutputId.put(output.Id, output); // Add to map to be updated
                        }
                    }
                }
            }
        }

        /**********************************
         * Updated Estimation Outputs with Calculated Values
         **********************************/

        // <T03>: variables to assist in simpistically calulating section totals and outputs within page subtotal sections
        Map<Id, Decimal> sectionIdToTotalIpus = new Map<Id, Decimal>(); // section Id to 'Total (IPUs)' read only input value
        Map<Id, Decimal> formIdToSectionTotalIpus = new Map<Id, Decimal>(); // form id to sum of 'Total (IPUs)' read only input value
        List<Estimation_Output__c> subTotalSectionOutputs = new List<Estimation_Output__c>(); // examples: Current Page IPU Subtotal, Additional IPUS needed

        try {
            // <T03>: sum up the page subtotals and additional ipus needed.
            //  This is a much quicker than using the formulas for those
            for (Estimation_Output__c output : applicableOutputRecordsMap.values()) {
                Decimal calculatedValue;
                if (String.isBlank(output.User_Value__c)) {
                    calculatedValue = 0;
                } else if (output.User_Value__c.isNumeric()) {
                    calculatedValue = Decimal.valueOf(output.User_Value__c);
                }

                String consumptionDescription = output.Estimation_Schedule__r.Consumption_Description__c;
                if (
                    // <T03>: sum the (Total (IPUs)) inputs in a much simpler fashion, instead of relying on formulas:
                    consumptionDescription != null && (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.SECTION_TOTAL_IPUS_STR))
                ) {
                    Decimal valueToAccrue = !formIdToSectionTotalIpus.containsKey(output.Page_Section__r.Parent_Page__r.Parent_Form__c)
                        ? 0
                        : formIdToSectionTotalIpus.get(output.Page_Section__r.Parent_Page__r.Parent_Form__c);

                    formIdToSectionTotalIpus.put(output.Page_Section__r.Parent_Page__r.Parent_Form__c, (calculatedValue + valueToAccrue));
                    sectionIdToTotalIpus.put(output.Page_Section__c, calculatedValue);
                }

                if (
                    consumptionDescription != null &&
                    (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.CURRENT_PAGE_IPU_SUBTOTAL_STR) ||
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.NEXT_PAGE_IPU_SUBTOTAL_STR) ||
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.PREV_PAGE_IPU_SUBTOTAL_STR) ||
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.ADDITIONAL_IPUS_NEEDED_STR))
                ) {
                    subTotalSectionOutputs.add(output);
                }
                if (
                    consumptionDescription != null &&
                    entitlementSectionIdsThatTriggerCalc.isEmpty() &&
                    consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.CURRENT_IPU_ENTITLEMENT_STR)
                ) {
                    if (output.User_Value__c != null && output.User_Value__c.isNumeric()) {
                        entitlementValue = Decimal.valueOf(output.User_Value__c);
                    }
                }
            }

            if (!calculatedOutputByOutputId.isEmpty()) {
                // <T03>: only update relevant outputs that actually changed from a calculation:
                Map<Id, Estimation_Output__c> outputsToUpdateMap = new Map<Id, Estimation_Output__c>();
                for (Id outputId : calculatedOutputByOutputId.keyset()) {
                    if (!outputsNotToUpdate.contains(outputId)) {
                        outputsToUpdateMap.put(outputId, calculatedOutputByOutputId.get(outputId));
                    }
                }
                update outputsToUpdateMap.values();

                //outputsToReturnMap.putall(calculatedOutputByOutputId);
                outputsToReturnMap.putall(outputsToUpdateMap);
            }
        } catch (Exception ex) {
            System.debug('Exception occurred updating User Value on Estimation Output with calculated value: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());

            throw new CalculationException(
                'Exception occurred updating User Value on Estimation Output with calculated value: ' + ex.getMessage()
            );
        }

        CalcReturnWrapper calcReturnWrapper = new CalcReturnWrapper(); // <T03>
        List<Estimation_Summary_Line__c> calculatedSummaryLines = calculateSummaryLines(
            estimationId,
            selectedSectionIds, // <T03>
            formIdToSectionTotalIpus, // <T03>
            sectionIdToTotalIpus, // <T03>
            entitlementValue, // <T03>
            calcReturnWrapper, // <T03>
            subTotalSectionOutputs, // <T03>
            outputsToReturnMap // <T03>
        );

        calcReturnWrapper.calculatedSummaryLines = calculatedSummaryLines;
        calcReturnWrapper.outputsToReturnMap = outputsToReturnMap;

        return calcReturnWrapper;
    }

    // method refactored for <T03>
    public static List<Estimation_Summary_Line__c> calculateSummaryLines(
        Id estimationSummaryId,
        List<Id> selectedSectionIds,
        Map<Id, Decimal> formIdToSectionTotalIpus,
        Map<Id, Decimal> sectionIdToTotalIpus,
        Decimal entitlementValue,
        CalcReturnWrapper calcReturnWrapper,
        List<Estimation_Output__c> subTotalSectionOutputs,
        Map<Id, Estimation_Output__c> outputsToReturnMap
    ) {
        try {
            Map<Id, List<Estimation_Output__c>> outputListBySectionIdMap = new Map<Id, List<Estimation_Output__c>>();
            Set<Id> pageSectionIds = new Set<Id>(); // <T03> renamed from product2Ids to support forms containing both non-expansion and expansion sections that share the same product
            List<Estimation_Summary_Line__c> linesToUpdate = new List<Estimation_Summary_Line__c>();

            Map<Id, Estimation_Summary_Line__c> summaryLineMap = new Map<Id, Estimation_Summary_Line__c>(
                [
                    SELECT
                        Id,
                        Estimation_Summary__c,
                        Service_ID__c,
                        Required_IPUs__c,
                        Product__c,
                        Page_Section__c,
                        Page_Section__r.Parent_Page__r.Parent_Form__c,
                        Page_Section__r.Parent_Page__r.Page_Number__c,
                        Page_Section__r.Weighted_Average_Applicable__c
                    FROM Estimation_Summary_Line__c
                    WHERE
                        Estimation_Summary__c = :estimationSummaryId
                        // <T03>: added next query filter to improve performance:
                        AND Page_Section__c IN :selectedSectionIds
                ]
            );

            Map<Id, Estimation_Output__c> outputMap = new Map<Id, Estimation_Output__c>(
                [
                    SELECT
                        Id,
                        Estimation_Summary__c,
                        Estimation_Schedule__r.Consumption_Description__c,
                        Product__c,
                        Product__r.Name,
                        User_Value__c,
                        Rollup_Into_Estimation_Summary_Lines__c,
                        Page_Section__c,
                        Page_Section__r.Weighted_Average_Applicable__c,
                        Page_Section__r.Parent_Page__r.Page_Number__c,
                        Page_Section__r.Parent_Page__r.Parent_Form__c,
                        Estimation_Schedule__r.Data_Type__c
                    FROM Estimation_Output__c
                    WHERE
                        Estimation_Summary__c = :estimationSummaryId
                        AND Rollup_Into_Estimation_Summary_Lines__c = TRUE
                        // <T03>: added next query filter to improve performance:
                        AND Page_Section__c IN :selectedSectionIds
                ]
            );

            Map<Integer, Integer> pageNumToSubTotal = new Map<Integer, Integer>();
            if (!outputMap.isEmpty() && !summaryLineMap.isEmpty()) {
                for (Estimation_Summary_Line__c line : summaryLineMap.values()) {
                    if (line.Page_Section__c != null) {
                        pageSectionIds.add(line.Page_Section__c);
                    }
                }

                if (!pageSectionIds.isEmpty()) {
                    for (Id sectionId : pageSectionIds) {
                        List<Estimation_Output__c> outputsBySectionIdList = new List<Estimation_Output__c>();
                        for (Estimation_Output__c output : outputMap.values()) {
                            if (output.Page_Section__c != null && output.Page_Section__c == sectionId) {
                                outputsBySectionIdList.add(output);
                            }
                        }

                        if (!outputsBySectionIdList.isEmpty()) {
                            outputListBySectionIdMap.put(sectionId, outputsBySectionIdList);
                        }
                    }
                }

                if (!outputListBySectionIdMap.isEmpty() && !summaryLineMap.isEmpty()) {
                    Decimal sumOfSectionTotalIpus = 0; // <T03>
                    Decimal sumOfTotalIpus = 0;
                    Map<Id, Decimal> productIdToUserValue = new Map<Id, Decimal>();
                    for (Estimation_Summary_Line__c line : summaryLineMap.values()) {
                        if (outputListBySectionIdMap.get(line.Page_Section__c) != null) {
                            // loop through all outputs in a section:
                            for (Estimation_Output__c output : outputListBySectionIdMap.get(line.Page_Section__c)) {
                                if (output.User_Value__c != null && output.User_Value__c.isNumeric()) {
                                    Decimal userValue = Decimal.valueOf(output.User_Value__c);
                                    productIdToUserValue.put(output.Product__c, userValue);
                                }
                            }
                        }

                        if (productIdToUserValue.get(line.Product__c) != null) {
                            Decimal productUserValue = productIdToUserValue.get(line.Product__c);

                            // <T03>: added condition check
                            if (!line.Page_Section__r.Weighted_Average_Applicable__c || entitlementValue == 0) {
                                line.Required_IPUs__c = productUserValue;
                            } else {
                                // <T03>: process entitlement values more simplistically
                                sumOfSectionTotalIpus = formIdToSectionTotalIpus.get(line.Page_Section__r.Parent_Page__r.Parent_Form__c);
                                line.Required_IPUs__c = Integer.valueOf(
                                    (productUserValue / sumOfSectionTotalIpus) * (sumOfSectionTotalIpus - entitlementValue)
                                );
                            }

                            Integer pageTotal = 0;
                            Integer pageNumber = Integer.valueOf(line.Page_Section__r.Parent_Page__r.Page_Number__c);
                            if (pageNumToSubTotal.containsKey(pageNumber)) {
                                pageTotal = pageNumToSubTotal.get(pageNumber);
                            }

                            if (sectionIdToTotalIpus.get(line.Page_Section__c) == null) {
                                pageTotal += Integer.valueOf(line.Required_IPUs__c);
                            } else {
                                pageTotal += Integer.valueOf(sectionIdToTotalIpus.get(line.Page_Section__c));
                            }

                            pageNumToSubTotal.put(pageNumber, pageTotal);
                            sumOfTotalIpus += pageTotal;

                            if (line.Required_IPUs__c != null) {
                                calcReturnWrapper.totalRequiredIpus += Integer.valueOf(line.Required_IPUs__c);
                            }
                            linesToUpdate.add(line);
                        }
                    }

                    // <T03>: update the 'Current Page Subtotal' output and 'Additional IPUS needed' output
                    //   This is much quicker than using the formulas for those outputs
                    if (!subTotalSectionOutputs.isEmpty()) {
                        for (Estimation_Output__c output : subTotalSectionOutputs) {
                            String consumptionDescription = output.Estimation_Schedule__r.Consumption_Description__c;
                            Integer pageNumber = Integer.valueOf(output.Page_Section__r.Parent_Page__r.Page_Number__c);

                            if (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.CURRENT_PAGE_IPU_SUBTOTAL_STR)) {
                                output.User_Value__c = String.valueOf(pageNumToSubTotal.get(pageNumber));
                            } else if (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.NEXT_PAGE_IPU_SUBTOTAL_STR)) {
                                output.User_Value__c = String.valueOf(pageNumToSubTotal.get(pageNumber + 1));
                            } else if (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.PREV_PAGE_IPU_SUBTOTAL_STR)) {
                                output.User_Value__c = String.valueOf(pageNumToSubTotal.get(pageNumber - 1));
                            } else if (consumptionDescription.toLowerCase().contains(IPUE_CONSTANTS.ADDITIONAL_IPUS_NEEDED_STR)) {
                                Decimal delta = pageNumToSubTotal.get(pageNumber) - entitlementValue;

                                if (delta < 0) {
                                    delta = 0;
                                }

                                output.User_Value__c = String.valueOf(delta);
                            }
                            outputsToReturnMap.put(output.Id, output.clone(true, false, false, false));
                        }
                        update subTotalSectionOutputs;
                    }
                }
            }

            update linesToUpdate;
            return linesToUpdate; // <T03>
        } catch (Exception ex) {
            System.debug('Exception occurred while trying to rollup Total Required IPUs on Estimation Summary Lines: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());

            throw new CalculationException(
                'Exception occurred while trying to rollup Total Required IPUs on Estimation Summary Lines: ' + ex.getMessage()
            );
        }
    }
}
