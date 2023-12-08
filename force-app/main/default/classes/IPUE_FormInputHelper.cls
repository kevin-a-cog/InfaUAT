/**
* Name         : IPUE_FormInputHelper
* Author       : Colton Kloppel | ATG, Cognizant | Colton.Kloppel@atginfo.com
* Created Date : October 01, 2021
* Description  : This test class covers IPUE_FileUploadController
*
* Change History
**********************************************************************************************************
* ModifiedBy               Date            JIRA No.    Description                          Tag
**********************************************************************************************************
* Colton Kloppel       10-01-2021      IPUE-52      Initial create
* Stephanie Viereckl   Feb 2022        IPUE-153/193    Refactor to support Tables
* Chandana Gowda      11/Jan/2022      SALESRT-14808  Enhance IPU calculation performance    <T02>
**********************************************************************************************************
*/
public without sharing class IPUE_FormInputHelper {
    
    public class CalculationException extends Exception {}
    
    public static Map<Id, Estimation_Output__c> processInput(String JSONPayload, Id formId, Id estimationId){
        
        List<IPUE_FormControllerModels.EstimationOutput> outputModelList = new List<IPUE_FormControllerModels.EstimationOutput>();
        Map<Id, Estimation_Output__c> outputsToReturnMap = new Map<Id, Estimation_Output__c>();
        
        // Deserialize the JSON Payload into the InputSectionWrapper
        Type pageSectionClassType = Type.forName('IPUE_FormControllerModels.PageSection');
        IPUE_FormControllerModels.PageSection sectionWrapper = (IPUE_FormControllerModels.PageSection)JSON.deserialize(JSONPayload, pageSectionClassType);
        
        /***********************************************************
        * Find and Save User's Input into Estimation Output records
        ***********************************************************/
        
        // Loop through every Section Item and build map of Outputs needed Calculations, and Outputs needing to be updated
        for (IPUE_FormControllerModels.SectionItem sectionItem : sectionWrapper.sectionItems) {
            
            // For Section Items that are regular Estimation Schedules (i.e. Questions)
            if (sectionItem.isSchedule) {
                
                IPUE_FormControllerModels.EstimationOutput output = sectionItem.schedule.output;
                outputModelList.add(output);
                
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
        
        // Prepare list for update for ONLY outputs that do not need to be calculated
        List<Estimation_Output__c> outputRecordsToUpdateList = new List<Estimation_Output__c>();
        
        //All Estimation Output Records are created on insert of the Estimation Summary.
        Map<Id,Estimation_Output__c> allFormOutputRecordsMap = new Map<Id, Estimation_Output__c>([
            SELECT Id, Name, Estimation_Summary__c, Estimation_Schedule__c, User_Value__c, Estimation_Schedule__r.Data_Type__c, Section_filled__c,
            Estimation_Schedule__r.IPU_Calculation__c,Estimation_Schedule__r.Name,Estimation_Schedule__r.Active__c,IPUE_ScheduleName__c, 
            Page_Section__c, Page_Section__r.Title_Visibility__c,Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c, Column_Number__c, Row_Number__c, 
            Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Name, Parent_Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__r.IPUE_PostfixFormula__c, Estimation_Schedule__r.IPU_Calculation__r.Name,
            Estimation_Schedule__r.IPU_Calculation__r.Formula__c,Estimation_Schedule__r.Sequence__c
            FROM Estimation_Output__c
            WHERE Estimation_Summary__c = :estimationId
        ]);
        
        for(IPUE_FormControllerModels.EstimationOutput outputModel : outputModelList){
            
            //Utilize the allFromOutputRecordsMap to find the Output to update.
            if(allFormOutputRecordsMap.containsKey(outputModel.Id)){
                //Update the value with what was recieved from the LWC.  The allFormOutputRecordsMap will be reused Later.
                allFormOutputRecordsMap.get(outputModel.Id).User_Value__c = outputModel.value;

                allFormOutputRecordsMap.get(outputModel.Id).Section_filled__c = true; //check the section filled to true - <T02>

                // Add Estimation Output to List to be updated
                outputRecordsToUpdateList.add(allFormOutputRecordsMap.get(outputModel.Id));
            }
        }
        
        try{
            
            update outputRecordsToUpdateList;
            outputsToReturnMap.putall(outputRecordsToUpdateList);
            
        } catch(Exception ex){
            
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
        Map<Id, Map<String, Decimal>> unfilledSectionCalculation = new Map<Id, Map<String, Decimal>>();
        
        // Loop through all Estimation Output records associated to the Estimation Summary and determine which "Calculation Group" they should be in
        for(Estimation_Output__c output : allFormOutputRecordsMap.values()){
            
            Id calculationId = output.Estimation_Schedule__r.IPU_Calculation__c;
            
            // Populate Group #1 Data: If the Outputs is in an elastic table, populate collections to use in Elastic Table Calculations (i.e. row by row calculations)
            if(output.Parent_Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
                
                // Ignore Headers completely
                if (output.Row_Number__c > 0) {
                    
                    // Populate Map of all Elastic Table Cells to be used in elastic table cell calculations
                    outputsUsedInElasticCalculations.put(output.Id, output);
                    
                    // In addition, if value is calculated, add to Map of calculaetd Ids
                    //Add the estimation output for calcualtion only if the section filled checkbox is checked or it is an by default expanded section - <T02>
                    if (output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.CALCULATED && calculationId != null && output.Estimation_Schedule__r.Active__c && (output.Section_filled__c || output.Page_Section__r.Title_Visibility__c != 'Visible' || output.Estimation_Schedule__r.Sequence__c <= 0)) {
                        
                        List<Estimation_Output__c> elasticCalculationOutputs = new List<Estimation_Output__c>();
                        if (elasticCalcOutputCalcsByCalcId.containsKey(calculationId)) {
                            elasticCalculationOutputs = elasticCalcOutputCalcsByCalcId.get(calculationId);
                        }
                        elasticCalculationOutputs.add(output);
                        elasticCalcOutputCalcsByCalcId.put(calculationId, elasticCalculationOutputs);                        
                    }else{
                        Decimal calculatedValue = String.isBlank(output.User_Value__c) ? 0 : Decimal.valueOf(output.User_Value__c);
                        unfilledSectionCalculation.put(calculationId,new Map<String, Decimal>{output.Estimation_Schedule__r.Name => calculatedValue});
                    }
                }

            // Populate Group #2 Data: If the output is an elastic table itself, add output to map to be used in aggregate functions
            }else if(output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
                
                outputsUsedInAggregateFunctions.put(output.Id, output);

            // If the output is a Calculated Value...
            } else if (output.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.CALCULATED && calculationId != null && output.Estimation_Schedule__r.Active__c){
                          
                // Populate Group #2 Data: If the output is a table function, add to collections to be used in aggregate function calculations (i.e. sum column 1 of elastic table row)
                if(IPUE_CalculationUtils.containsTableFunction(output.Estimation_Schedule__r.IPU_Calculation__r.Formula__c + '(')) {
                    // Populate map of outputs to be used in aggregate functions
                    outputsUsedInAggregateFunctions.put(output.Id, output);

                    //Add the estimation output for calcualtion only if the section filled checkbox is checked or it is an by default expanded section - <T02>
                    if(output.Section_filled__c || output.Page_Section__r.Title_Visibility__c != 'Visible' || output.Estimation_Schedule__r.Sequence__c <= 0){
                        List<Estimation_Output__c> aggregateCalculationOutputs = new List<Estimation_Output__c>();
                        if (aggregateCalcOutputCalcsByCalcId.containsKey(calculationId)) {
                            aggregateCalculationOutputs = aggregateCalcOutputCalcsByCalcId.get(calculationId);
                        }                    
                        aggregateCalculationOutputs.add(output);
                        aggregateCalcOutputCalcsByCalcId.put(calculationId, aggregateCalculationOutputs);
                    }else{
                        Decimal calculatedValue = String.isBlank(output.User_Value__c) ? 0 : Decimal.valueOf(output.User_Value__c);
                        unfilledSectionCalculation.put(calculationId,new Map<String, Decimal>{output.Estimation_Schedule__r.Name => calculatedValue});
                    }
                              
                // Populate Group #3 Data: Otherwise, it is a normal calculation and should be added to all other calculations
                }else{
                              
                    // Populate Map of outputs unrelated to tables
                    remainingOutputsToCalculate.put(output.Id, output);
                    //Perform the calcualtion only for records where the section is filled
                    if(output.Section_filled__c || output.Page_Section__r.Title_Visibility__c != 'Visible' || output.Estimation_Schedule__r.Sequence__c <= 0){
                        List<Estimation_Output__c> calculationOutputs = new List<Estimation_Output__c>();
                        if (calcOutputListByCalculationId.containsKey(calculationId)) {
                            calculationOutputs = calcOutputListByCalculationId.get(calculationId);
                        }
                        calculationOutputs.add(output);
                        calcOutputListByCalculationId.put(calculationId, calculationOutputs);
                    }else{
                        Decimal calculatedValue = String.isBlank(output.User_Value__c) ? 0 : Decimal.valueOf(output.User_Value__c);
                        unfilledSectionCalculation.put(calculationId,new Map<String, Decimal>{output.Estimation_Schedule__r.Name => calculatedValue});
                    }
                }
                          
            // Populate Group #3 Data: Otherwise, this output is not related to a table and is not calculated (therefore it is an input)
            } else {
                    // Populate Map of outputs unrelated to tables
                    remainingOutputsToCalculate.put(output.Id, output);                          
            }            
        }        
        
        /**********************************
        * Get Calculation Record Data
        **********************************/
        
        //Find all join records of Calculation and Consumption Schedule, where the schedule existed within the list of Consumption Schedules modified on the Page Section.
        List<CalculationScheduleMember__c> calcMemberList = new List<CalculationScheduleMember__c>([
            SELECT Id, Consumption_Schedule__c, Calculation__c, Calculation__r.Formula__c, Calculation__r.IPUE_PostfixFormula__c, Calculation__r.Name
            FROM CalculationScheduleMember__c
            WHERE Calculation__c IN: elasticCalcOutputCalcsByCalcId.keySet()
            OR Calculation__c IN: aggregateCalcOutputCalcsByCalcId.keySet()
            OR Calculation__c IN: calcOutputListByCalculationId.keySet()
        ]);
        
        //Store Calculation in Map to easily pull when sending to Util class
        Map<Id, Calculation__c> calculationFromMemberMap = new Map<Id, Calculation__c>();
        //Instantiate list to be used and overwritten when building map
        List<ConsumptionSchedule> calculatedScheduleList;
        
        for(CalculationScheduleMember__c calcMember : calcMemberList){
            
            // Create Calculation Record based on join object
            if(calculationFromMemberMap.get(calcMember.Calculation__c) == null){
                
                Calculation__c queriedCalc = new Calculation__c();
                queriedCalc.Id = calcMember.Calculation__c;
                queriedCalc.IPUE_PostfixFormula__c = calcMember.Calculation__r.IPUE_PostfixFormula__c;
                queriedCalc.Formula__c = calcMember.Calculation__r.Formula__c;
                queriedCalc.Name = calcMember.Calculation__r.Name;
                // Build a Map where the key = Calculation Id, value = Calculation Record
                
                calculationFromMemberMap.put(queriedCalc.Id,queriedCalc);
            }
        }
        
        /**********************************
        * Begin Calculations
        **********************************/
        
        //Store the outputs that will need to be recalculated by their calculation Id.
        Map<Id, Estimation_Output__c> calculatedOutputByCalcId = new Map<Id, Estimation_Output__c>();
        
        /*************************************************************************************************
        * #1 Perform calculations on elastic row table cells (which should only ever reference cells within the same row)
        *************************************************************************************************/
        
        for (Id calcId : elasticCalcOutputCalcsByCalcId.keyset()){
            
            Map<Id, Map<String, Decimal>> calculatedResultsByCalcId = IPUE_CalculationUtils.evaluateCalculation(
                calculationFromMemberMap.get(calcId),           // Calculation Record
                outputsUsedInElasticCalculations.values(),       // All Estimation Outputs related to Estimation Summary
                unfilledSectionCalculation                  //Added the parameter unfilledSectionCalculation - <T02>
            );
            
            // Loop through results on Calculation Id Map
            for(Id resultCalcId : calculatedResultsByCalcId.keyset()){
                
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
                        calculatedOutputByCalcId.put(output.Id, output); // Add to map to be updated
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
        for (Id calcId : aggregateCalcOutputCalcsByCalcId.keyset()){
            
            Map<Id, Map<String, Decimal>> calculatedResultsByCalcId = IPUE_CalculationUtils.evaluateCalculation(
                calculationFromMemberMap.get(calcId),           // Calculation Record
                outputsUsedInAggregateFunctions.values(),       // Elastic Table Cells
                unfilledSectionCalculation                  //Added the parameter unfilledSectionCalculation - <T02>
            );
            
            // Loop through results on Calculation Id Map
            for(Id resultCalcId : calculatedResultsByCalcId.keyset()){
                
                if (aggregateCalcOutputCalcsByCalcId.containsKey(resultCalcId)) {
                    
                    Map<String, Decimal> answerMap = calculatedResultsByCalcId.get(resultCalcId);
                    
                    // Loop through list of Estimation Outputs associated to the same Calculation record
                    for (Estimation_Output__c output : aggregateCalcOutputCalcsByCalcId.get(resultCalcId)) {
                        
                        Decimal result = answerMap.get(IPUE_CONSTANTS.DEFAULT_KEY);      
                        output.User_Value__c = String.valueOf(result);
                        
                        remainingOutputsToCalculate.put(output.Id, output); // Add updated table value to next list to be processed
                        calculatedOutputByCalcId.put(output.Id, output);    // Add to map to be updated
                        
                    }
                }
                
            }
            
        }
        
        /*************************************************************************************************
        * #3 Perform all other calculations (including those that reference previously calculated values)
        *************************************************************************************************/
        for (Id calcId : calcOutputListByCalculationId.keyset()){
            
            Map<Id, Map<String, Decimal>> calculatedResultsByCalcId = IPUE_CalculationUtils.evaluateCalculation(
                calculationFromMemberMap.get(calcId),       // Calculation Record
                remainingOutputsToCalculate.values(),        // All Estimation Outputs related to Estimation Summary
                unfilledSectionCalculation                  //Added the parameter unfilledSectionCalculation - <T02>
            );
            
            // Loop through results on Calculation Id Map
            for(Id resultCalcId : calculatedResultsByCalcId.keyset()){
                
                if (calcOutputListByCalculationId.containsKey(resultCalcId)) {
                    
                    Map<String, Decimal> answerMap = calculatedResultsByCalcId.get(resultCalcId);
                    
                    // Loop through list of Estimation Outputs associated to the same Calculation record
                    for (Estimation_Output__c output : calcOutputListByCalculationId.get(resultCalcId)) {
                        Decimal result = answerMap.get(IPUE_CONSTANTS.DEFAULT_KEY);      
                        output.User_Value__c = String.valueOf(result);
                        calculatedOutputByCalcId.put(output.Id, output); // Add to map to be updated
                    }
                    
                }
                
            }
            
        }
        
        /**********************************
        * Updated Estimation Outputs with Calculated Values
        **********************************/
        
        try {
            
            if(!calculatedOutputByCalcId.isEmpty()){
                update calculatedOutputByCalcId.values();
                outputsToReturnMap.putall(calculatedOutputByCalcId);
            }
            
        } catch (Exception ex) {
            System.debug('Exception occurred updating User Value on Estimation Output with calculated value: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());
            
            throw new CalculationException('Exception occurred updating User Value on Estimation Output with calculated value: ' + ex.getMessage());
        }
        
        calculateSummaryLines(estimationId);
        
        return outputsToReturnMap;
    }
    
    public static void calculateSummaryLines(Id estimationSummaryId) {
        
        try{
            
            Map<Id, List<Estimation_Output__c>> outputListByProductIdMap = new Map<Id, List<Estimation_Output__c>>();
            Set<Id> product2Ids = new Set<Id>();
            List<Estimation_Summary_Line__c> linesToUpdate = new List<Estimation_Summary_Line__c>();
            
            Map<Id, Estimation_Summary_Line__c> summaryLineMap = new Map<Id, Estimation_Summary_Line__c>([
                SELECT Id, Estimation_Summary__c,Service_ID__c, Required_IPUs__c, Product__c
                FROM Estimation_Summary_Line__c
                WHERE Estimation_Summary__c = :estimationSummaryId
            ]);
            
            Map<Id, Estimation_Output__c> outputMap = new Map<Id, Estimation_Output__c>([
                SELECT Id, Estimation_Summary__c, Product__c, User_Value__c, Rollup_Into_Estimation_Summary_Lines__c
                FROM Estimation_Output__c
                WHERE Estimation_Summary__c = :estimationSummaryId
                AND Rollup_Into_Estimation_Summary_Lines__c = true
            ]);
            
            if(!outputMap.isEmpty() && !summaryLineMap.isEmpty()){
                for(Estimation_Summary_Line__c line : summaryLineMap.values()){
                    if(line.product__c != null){
                        product2Ids.add(line.product__c);
                    }
                }
                
                if(!product2Ids.isEmpty()){
                    for(Id prodId : product2Ids){
                        List<Estimation_Output__c> outputsByProductIdList = new List<Estimation_Output__c>();
                        for(Estimation_Output__c output : outputMap.values()){
                            if(output.product__c!= null && output.product__c == prodId){
                                outputsByProductIdList.add(output);
                            }
                        }
                        
                        if(!outputsByProductIdList.isEmpty()){
                            outputListByProductIdMap.put(prodId,outputsByProductIdList);
                        }
                    }
                }
                
                if(!outputListByProductIdMap.isEmpty() && !summaryLineMap.isEmpty()){
                    for(Estimation_Summary_Line__c line : summaryLineMap.values()){
                        Decimal sumOfUserValues;
                        
                        if(outputListByProductIdMap.get(line.product__c) != null){
                            
                            for(Estimation_Output__c output : outputListByProductIdMap.get(line.product__c)){
                                
                                if(output.User_Value__c != null ){
                                    if(sumOfUserValues == null){
                                        sumOfUserValues = 0;
                                    }
                                    try {
                                        	sumOfUserValues += Decimal.ValueOf(output.User_Value__c);
                                    } catch (Exception ex) {
                                        continue;
                                    }
                                }
                            }
                        }
                        if(sumOfUserValues != null){
                            line.Required_IPUs__c = sumOfUserValues;
                            linesToUpdate.add(line);
                        }
                    }
                }
            }
            
            update linesToUpdate;
            
        } catch (Exception ex) {
            
            System.debug('Exception occurred while trying to rollup Total Required IPUs on Estimation Summary Lines: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());
            
            throw new CalculationException('Exception occurred while trying to rollup Total Required IPUs on Estimation Summary Lines: ' + ex.getMessage());
            
        }
    }
}