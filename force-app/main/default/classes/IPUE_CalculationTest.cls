/*
******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                             Tag
Anusha Akella       07/15/2022  KKA                 Implement FLOOR, CEIL & ROUND functions for IPU Calculations <T14064>
*******************************************************************************************************************
*/
@isTest
public class IPUE_CalculationTest {

    // Formula 1: Example formula given on IPU-52
    private static final String validFormulaNoRanges = '$A * IF( COUNT ( $B, $C, $D ) >= 10, 12 * $E, 10 * $F )';
    private static final String validFormulaNoRangesPostfix = '$A~$B~$C~$D~3~count~10~>=~12~$E~*~10~$F~*~if~*';
    private static final Decimal noRangesCorrectAnswer = 260;

    // Formula 2: The same formula, but with extra functions and minus signs added
    // T14064
    private static final String validFormula = '  -rangeupper($A, $A) * IF( COUNT (  -(rangelower(if($B = 0,0,$B), $B)), rangeoutput($C, $C) , progressiveoutcome(if($D <= 1,0,$D) * CEIL(1.001,1), $D)) >=   ROUND(10.001,0), -12 * - $E, FLOOR(10.001,0) * volumeOutcome($F, $F) )   ';
    private static final String validFormulaPostfix = '-1~$A~$A~rangeupper~-1~$B~0~=~0~$B~if~$B~rangelower~*~$C~$C~rangeoutput~$D~1~<=~0~$D~if~1.001~1~ceil~*~$D~progressiveoutcome~3~count~10.001~0~round~>=~-12~-1~$E~*~*~10.001~0~floor~$F~$F~volumeoutcome~*~if~*~*';
    private static final Decimal validFormulaCorrectAnswer = -130000;

    @TestSetup
    static void setup(){

        List<String> csNames = new List<String>{'A', 'B', 'C', 'D', 'E', 'F'};

        // ConsumptionScheduleTrigger defaults Matching Attribute on insert
        // Can't update ConsumptionSchedules in bulk when updating the Matching Attribute
        for (Integer i = 0; i < csNames.size(); i++) {
            ConsumptionSchedule consumptionSchedule = IPUE_TestUtils.createConsumptionSchedule(false, csNames[i], null);
            insert consumptionSchedule;
        }
    }

    @IsTest
    static void testCompileValid(){
        Test.startTest();
        String compiledFormula = IPUE_CalculationUtils.compileFormula(validFormula);
        Test.stopTest();
        System.assertEquals(validFormulaPostfix, compiledFormula, 'Failed to compile valid formula');
    }

    // Parsing errors
    private static final String formulaWithBadNumber = '- 3 - 1.2.3';
    private static final String formulaMissingOpenParen = 'if 1 2 3';
    private static final String formulaWithBadFunctionName = '1 + Conut($A)';
    private static final String formulaWithBadCharacter = ' 1 = -(3) / %';
    private static final String truncatedFormula = 'if ( $A >';
    private static final String formulaWithBadMinusPost = '- +';

    @isTest
    static void testBadNumber() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithBadNumber);
            System.assert(false, 'Parsed with invalid number: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Invalid number: "1.2.3"', pe.getMessage(), 'Incorrect error message for invalid number: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testMissingOpenParen() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaMissingOpenParen);
            System.assert(false, 'Parsed with missing open paren: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Function "if" must be followed by parenthesis', pe.getMessage(), 'Incorrect error message for missing open paren: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testBadFunctionName() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithBadFunctionName);
            System.assert(false, 'Parsed with bad function name: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Unknown function: "Conut"', pe.getMessage(), 'Incorrect error message for bad function name: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testBadCharacter() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithBadCharacter);
            System.assert(false, 'Parsed with bad character: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Unknown character encountered during parsing: "%"', pe.getMessage(), 'Incorrect error message for bad character: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testEarlyEnd() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(truncatedFormula);
            System.assert(false, 'Parsed with early formula end: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Unexpected end of input', pe.getMessage(), 'Incorrect error message for end of input: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @IsTest
    static void testBadMinusPost(){
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithBadMinusPost);
            System.assert(false, 'Parsed with bad minus post: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Unexpected character after "-": "+"', pe.getMessage(), 'Incorrect error message for bad minus post: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    // Converting errors
    private static final String formulaWithExtraCloseParen = '1 + 2)';
    private static final String formulaWithExtraOpenParen = '( 1 + 4.3';
    private static final String formulaWithTooManyIfParams = 'iF($A < 0, $B, $C, $D)';
    private static final String formulaWithTooFewIfParams = 'If($A <= 0)';

    @isTest
    static void testExtraCloseParen() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithExtraCloseParen);
            System.assert(false, 'Parsed with extra close paren: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Mismatched parenthesis', pe.getMessage(), 'Incorrect error message for extra close paren: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testExtraOpenParen() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithExtraOpenParen);
            System.assert(false, 'Parsed with extra open paren: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Mismatched parenthesis', pe.getMessage(), 'Incorrect error message for extra open paren: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testTooManyIfParams() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithTooManyIfParams);
            System.assert(false, 'Parsed with extra if param: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Function "if" expects 3 parameters, received 4', pe.getMessage(), 'Incorrect error message for extra if param: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    @isTest
    static void testTooFewIfParams() {
        try {
            String compiledFormula = IPUE_CalculationUtils.compileFormula(formulaWithTooFewIfParams);
            System.assert(false, 'Parsed with missing if param: ' + compiledFormula);
        } catch (IPUE_CalculationUtils.ParsingException pe) {
            System.assertEquals('Function "if" expects 3 parameters, received 1', pe.getMessage(), 'Incorrect error message for missing if param: ' + pe.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
    }

    //////////////////////////////////////////////
    // Auto-calculation on record save
    //////////////////////////////////////////////

    @IsTest
    static void testInsert(){

        Calculation__c newCalc = new Calculation__c(
            Formula__c = validFormula
        );

        Test.startTest();
        insert newCalc;
        Test.stopTest();

        newCalc = [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name, 
            (
            	SELECT Id
                FROM Calculation_Schedule_Members__r
            )
            FROM Calculation__c
            WHERE Id = :newCalc.Id
            LIMIT 1
        ];
        System.assert(!String.isBlank(newCalc.IPUE_PostfixFormula__c), 'Postfix formula not populated');
        System.assertEquals(validFormulaPostfix, newCalc.IPUE_PostfixFormula__c, 'Postfix formula not computed properly: ' + newCalc.IPUE_PostfixFormula__c);
    }

    @IsTest
    static void testUpdate(){

        // Create the new record
        Calculation__c newCalc = new Calculation__c(
            Formula__c = validFormula
        );
        insert newCalc;
        // Requery for auto-calculated field
        newCalc = [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name
            FROM Calculation__c
            WHERE Id = :newCalc.Id
            LIMIT 1
        ];

        Test.startTest();
        // Update the formula
        newCalc.Formula__c = '';
        update newCalc;
        Test.stopTest();

        // Requery
        newCalc = [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name,(
            	SELECT Id
                FROM Calculation_Schedule_Members__r
            )
            FROM Calculation__c
            WHERE Id = :newCalc.Id
            LIMIT 1
        ];
        // Validate
        System.assert(String.isBlank(newCalc.IPUE_PostfixFormula__c), 'Postfix formula incorrectly populated');
    }

    @IsTest
    static void testSObjectError(){
        
        Calculation__c newCalc = new Calculation__c(
            Formula__c = formulaWithBadNumber
        );
        Test.startTest();
        try {
            insert newCalc;
            System.assert(false, 'Compiled invalid formula: ' + newCalc.IPUE_PostfixFormula__c);
        } catch(DmlException e) {
            System.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Formula compilation error: Invalid number: "1.2.3": [Formula__c]', e.getMessage(), 'Incorrect message: ' + e.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Incorrect exception type: ' + e.getTypeName() + '; '+ e.getMessage() + '; ' + e.getStackTraceString());
        }
        Test.stopTest();

    }

    ////////////////////////////////////////
    // Evaluation
    ////////////////////////////////////////

    private static final Id scheduleRecordTypeId = ConsumptionSchedule.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Estimation_Schedule').getRecordTypeId();

    @IsTest
    static void testEvalNoRanges(){

        List<ConsumptionSchedule> schedules = [SELECT Id, Name FROM ConsumptionSchedule];

        // Mark Consumption Schedule as inactive (since we don't need CPQ functionality for these)
        for (ConsumptionSchedule cs : schedules) {
            cs.IsActive = false;
            update cs;
        }

        // Delete auto-created consumption rates so that we can add new ones
        delete [SELECT Id FROM ConsumptionRate];

        // Consumption Rates; 3 per schedule
        List<ConsumptionRate> rates = new List<ConsumptionRate>();
        Integer processingOrder = 1;
        for (ConsumptionSchedule cs : schedules) {
            rates.add(IPUE_TestUtils.createConsumptionRate(false, cs.Id, 0, 10, 5, processingOrder++));
            rates.add(IPUE_TestUtils.createConsumptionRate(false, cs.Id, 10, 20, 15, processingOrder++));
            rates.add(IPUE_TestUtils.createConsumptionRate(false, cs.Id, 20, null, 50, processingOrder++));
        }

        insert rates;

        // Estimation outputs
        List<Estimation_Output__c> outputs = new List<Estimation_Output__c>();
        for (Integer i = 0; i < schedules.size(); i++) {
            ConsumptionSchedule cs = schedules[i];
            outputs.add(IPUE_TestUtils.createEstimationOutput(false, 'test output ' + cs.name, cs.Id, 5*i+1));
        }
        insert outputs;
        // Requery for formula field
        outputs = [
            SELECT Id, Name, Estimation_Summary__c, Estimation_Schedule__c, User_Value__c, Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__c, Estimation_Schedule__r.Name, Estimation_Schedule__r.Active__c, IPUE_ScheduleName__c, 
            Page_Section__c, Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c, Column_Number__c, Row_Number__c, 
            Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Name, Parent_Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__r.IPUE_PostfixFormula__c, Estimation_Schedule__r.IPU_Calculation__r.Name,
            Estimation_Schedule__r.IPU_Calculation__r.Formula__c
            FROM Estimation_Output__c
        ];

        // Calculation
        Calculation__c calc = IPUE_TestUtils.createCalculation(true, 'test calc', validFormulaNoRanges);
        calc = [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name
            FROM Calculation__c
            WHERE Id = :calc.Id
            LIMIT 1
        ];

        Map<Id, Map<String, Decimal>> unfilledSectionCalculation = new Map<Id, Map<String, Decimal>>();

        Test.startTest();
        Map<Id, Map<String, Decimal>> answerMap = IPUE_CalculationUtils.evaluateCalculation(calc, outputs, unfilledSectionCalculation);
        Map<String, Decimal> answers = answerMap.get(calc.Id);
        Test.stopTest();

        System.debug(answers);
        System.assert(answerMap.containsKey(calc.Id), 'Did not evaluate passed calculation');
        // System.assertEquals(1, answers.size(), 'Evaluated incorrect number of calculations');
        Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
        System.assertEquals(noRangesCorrectAnswer, answer, 'Incorrect answer');

    }

    @IsTest
    static void testEvalWithRanges(){

        List<ConsumptionSchedule> schedules = [SELECT Id, Name FROM ConsumptionSchedule];
        
        // Mark Consumption Schedule as inactive (since we don't need CPQ functionality for these)
        for (ConsumptionSchedule cs : schedules) {
            cs.IsActive = false;
            update cs;
        }

        // Delete auto-created consumption rates so that we can add new ones
        delete [SELECT Id FROM ConsumptionRate];

        // Consumption Rates; 3 per schedule
        List<ConsumptionRate> rates = new List<ConsumptionRate>();
        Integer processingOrder = 1;
        for (ConsumptionSchedule cs : schedules) {
            rates.add(IPUE_TestUtils.createConsumptionRate(false, cs.Id, 0, 10, 5, processingOrder++));
            rates.add(IPUE_TestUtils.createConsumptionRate(false, cs.Id, 10, 20, 15, processingOrder++));
            rates.add(IPUE_TestUtils.createConsumptionRate(false, cs.Id, 20, null, 50, processingOrder++));
        }
        insert rates;

        // Estimation outputs
        List<Estimation_Output__c> outputs = new List<Estimation_Output__c>();
        for (Integer i = 0; i < schedules.size(); i++) {
            ConsumptionSchedule cs = schedules[i];
            outputs.add(IPUE_TestUtils.createEstimationOutput(false, 'test output ' + cs.name, cs.Id, 5*i+1));
        }
        insert outputs;
        // Requery for formula field
        outputs = [
            SELECT Id, Name, Estimation_Summary__c, Estimation_Schedule__c, User_Value__c, Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__c, Estimation_Schedule__r.Name, Estimation_Schedule__r.Active__c, IPUE_ScheduleName__c, 
            Page_Section__c, Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c, Column_Number__c, Row_Number__c, 
            Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Name, Parent_Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__r.IPUE_PostfixFormula__c, Estimation_Schedule__r.IPU_Calculation__r.Name,
            Estimation_Schedule__r.IPU_Calculation__r.Formula__c
            FROM Estimation_Output__c
        ];

        // Calculation
        Calculation__c calc = IPUE_TestUtils.createCalculation(true, 'test calc', validFormula);
        calc = [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name
            FROM Calculation__c
            WHERE Id = :calc.Id
            LIMIT 1
        ];

        Map<Id, Map<String, Decimal>> unfilledSectionCalculation = new Map<Id, Map<String, Decimal>>();

        Test.startTest();
        Map<Id, Map<String, Decimal>> answerMap = IPUE_CalculationUtils.evaluateCalculation(calc, outputs, unfilledSectionCalculation);
        Map<String, Decimal> answers = answerMap.get(calc.Id); 
        Test.stopTest();

        System.debug(answers);
        System.assert(answerMap.containsKey(calc.Id), 'Did not evaluate passed calculation');
        // System.assertEquals(1, answers.size(), 'Evaluated incorrect number of calculations');
        Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
        System.assertEquals(validFormulaCorrectAnswer, answer, 'Incorrect answer');

    }

    @IsTest
    static void testArithmeticFunctions(){

        List<Estimation_Output__c> outputList = new List<Estimation_Output__c>();
        List<ConsumptionSchedule> schedules = [SELECT Id, Name FROM ConsumptionSchedule];

        // If((5 + 10) > 1, 20/5, -1) + 1
        String formula = 'IF(($A + $B) < $C, $D/$E, 1) + $F';
        Decimal expectedResult = 6;
        Map<String, Decimal> scheduleByValue = new Map<String, Decimal>{
            'A' => 5,
            'B' => 10,
            'C' => 1,
            'D' => 20,
            'E' => 5,
            'F' => 5
        };

        Test.startTest();

        for (ConsumptionSchedule schedule : schedules ) {
            Estimation_Output__c output = IPUE_TestUtils.createEstimationOutput(false, schedule.Name, schedule.Id, scheduleByValue.get(schedule.Name));
            outputList.add(output);
        }

        insert outputList;

        Calculation__c calc = IPUE_TestUtils.createCalculation(false, 'Test Calculation', formula);
        insert calc;

        // Requery to get PostFix Formula
        calc =  [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name
            FROM Calculation__c
            WHERE Id = :calc.Id
            LIMIT 1
        ];

        outputList = [
            SELECT Id, Name, Estimation_Summary__c, Estimation_Schedule__c, User_Value__c, Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__c, Estimation_Schedule__r.Name, Estimation_Schedule__r.Active__c, IPUE_ScheduleName__c, 
            Page_Section__c, Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c, Column_Number__c, Row_Number__c, 
            Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Name, Parent_Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__r.IPUE_PostfixFormula__c, Estimation_Schedule__r.IPU_Calculation__r.Name,
            Estimation_Schedule__r.IPU_Calculation__r.Formula__c
            FROM Estimation_Output__c
            WHERE Id IN :outputList
        ];

        Map<Id, Map<String, Decimal>> unfilledSectionCalculation = new Map<Id, Map<String, Decimal>>();

        Map<Id, Map<String, Decimal>> answerMap = IPUE_CalculationUtils.evaluateCalculation(calc, outputList, unfilledSectionCalculation);
        Map<String, Decimal> answers = answerMap.get(calc.Id);
        System.assertEquals(expectedResult, answers.values()[0], 'Answer was not expected.');

        Test.stopTest();


    }

    @IsTest
    static void testAggregateFunctions(){

        List<Estimation_Output__c> outputList = new List<Estimation_Output__c>();
        List<Estimation_Output__c> newOutputList = new List<Estimation_Output__c>();
        List<Calculation__c> calculationList = new List<Calculation__c>();        

        String tableName = 'ELASTIC_TABLE';
        Set<String> aggregateFunctions = new Set<String>{
            'sumall',
            'min',
            'max',
            'average',
            'countcolumn',
            'counta'
        };

        Test.startTest();

        // Create Elastic Table
        ConsumptionSchedule table = IPUE_TestUtils.createTable(false, null, IPUE_CONSTANTS.TABLE_ELASTIC);
        table.Name = tableName;
        insert table;

        // Add Consumption Schedules and Table Cells to Table (2 Rows, 3 columns)
        IPUE_TestUtils.createSchedulesAndTableCells(table.Id, null, 2, 3, '');

        List<Table_Cell__c> schedules = [
            SELECT Id, Child_Estimation_Schedule__c, Row_Number__c, Column_Number__c, Parent_Estimation_Schedule__c
            FROM Table_Cell__c
        ];

        // Create Estimation Outputs for all the newly created Consumption Schedules
        for (Table_Cell__c cell : schedules) {
            Estimation_Output__c output = IPUE_TestUtils.createEstimationOutput(false, 'Test', cell.Child_Estimation_Schedule__c, 100);
            output.Row_Number__c = cell.Row_Number__c;
            output.Column_Number__c = cell.Column_Number__c;
            output.Parent_Estimation_Schedule__c = cell.Parent_Estimation_Schedule__c;
            outputList.add(output);
        }

        insert outputList;

        // Create extra Row of outputs based on the previously created Outputs
        for (Estimation_Output__c output : outputList) {
            if (output.Row_Number__c == 1) {
                Estimation_Output__c newOutput = IPUE_TestUtils.createEstimationOutput(false, 'Test', output.Estimation_Schedule__c, 200);
                newOutput.Row_Number__c = output.Row_Number__c + 1;
                newOutput.Column_Number__c = output.Column_Number__c;                
                newOutput.Parent_Estimation_Schedule__c = output.Parent_Estimation_Schedule__c;
                newOutputList.add(newOutput);
            }
        }

        insert newOutputList;

        // Create a Calculation Record for each Aggregate Function
        for (String function : aggregateFunctions) {
            String formula = function + '($' + tableName + ',1)';
            Calculation__c calc = IPUE_TestUtils.createCalculation(false, function, formula);
            calculationList.add(calc);
        }

        insert calculationList;

        // Query the Calculations to get the Post Fix Formula
        calculationList =  [
            SELECT Id, Formula__c, IPUE_PostfixFormula__c, Name
            FROM Calculation__c
            WHERE Id IN :calculationList
        ];

        outputList = [
            SELECT Id, Name, Estimation_Summary__c, Estimation_Schedule__c, User_Value__c, Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__c, Estimation_Schedule__r.Name, Estimation_Schedule__r.Active__c, IPUE_ScheduleName__c, 
            Page_Section__c, Estimation_Schedule__r.Rollup_Into_Estimation_Summary_Lines__c, Column_Number__c, Row_Number__c, 
            Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Name, Parent_Estimation_Schedule__r.Data_Type__c,
            Estimation_Schedule__r.IPU_Calculation__r.IPUE_PostfixFormula__c, Estimation_Schedule__r.IPU_Calculation__r.Name,
            Estimation_Schedule__r.IPU_Calculation__r.Formula__c
            FROM Estimation_Output__c
            WHERE Id IN :outputList OR Id IN :newOutputList
        ];

        Map<Id, Map<String, Decimal>> unfilledSectionCalculation = new Map<Id, Map<String, Decimal>>();

        // Test Each Calculations
        for (Calculation__c calc : calculationList) {
            Map<Id, Map<String, Decimal>> answerMap = IPUE_CalculationUtils.evaluateCalculation(calc, outputList, unfilledSectionCalculation);
            Map<String, Decimal> answers = answerMap.get(calc.Id);
            
            switch on calc.Name {
                when 'sumall' {
                    Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
                    System.assertEquals(300, answer, 'Error with sumall function');
                } when 'min' {
                    Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
                    System.assertEquals(100, answer, 'Error with min function');
                } when 'max' {
                    Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
                    System.assertEquals(200, answer, 'Error with max function');
                } when 'average' {
                    Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
                    System.assertEquals(150, answer, 'Error with average function');
                } when 'countcolumn' {
                    Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
                    System.assertEquals(2, answer, 'Error with countcolumn function');
                } when 'counta' {
                    Decimal answer = answers.get(IPUE_CONSTANTS.DEFAULT_KEY);
                    System.assertEquals(2, answer, 'Error with counta function');
                }
            }
        }

        Test.stopTest();

    }

}