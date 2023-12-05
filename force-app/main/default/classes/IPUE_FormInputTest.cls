@isTest
public with sharing class IPUE_FormInputTest {
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();

        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        insert testSummary;

        List<Page_Section__c> pageSections = [SELECT Id FROM Page_Section__c];

        // Create Tables
        ConsumptionSchedule fixedTable = IPUE_TestUtils.createTable(true, pageSections[0].Id, IPUE_CONSTANTS.TABLE_FIXED);
        IPUE_TestUtils.createSchedulesAndTableCells(fixedTable.Id, pageSections[0].Id, 3, 3, 'Fixed_Schedule_');

        ConsumptionSchedule elasticTable = IPUE_TestUtils.createTable(true, pageSections[0].Id, IPUE_CONSTANTS.TABLE_ELASTIC);
        IPUE_TestUtils.createSchedulesAndTableCells(elasticTable.Id, pageSections[0].Id, 2, 3, 'Elastic_Schedule_');
        
        

        // calculation.IPU_Calculation__c = calculation.Id;
        // update calculation;

        List<CalculationScheduleMember__c> calcMemberList = new List<CalculationScheduleMember__c>([
            SELECT Id, Consumption_Schedule__c, Calculation__c, Calculation__r.Formula__c, Calculation__r.IPUE_PostfixFormula__c, Calculation__r.Name
            FROM CalculationScheduleMember__c
        ]);

        System.debug('calcMemberList: ' + calcMemberList);
        System.debug('calcMemberList.size(): ' + calcMemberList.size());
    }
    
    @isTest
    private static void testProcessInput(){

        List<ConsumptionSchedule> scheduleList = [SELECT Id, Name FROM ConsumptionSchedule];
        Map<String, ConsumptionSchedule> schedulesByName = new Map<String, ConsumptionSchedule>();

        for (ConsumptionSchedule schedule : scheduleList) {
            schedulesByName.put(schedule.Name, schedule);
        }

        List<CalculationScheduleMember__c> membersToInsert = new List<CalculationScheduleMember__c>();

        System.debug('+++ Before Add');

        String formula = '$Elastic_Schedule_3 + $Elastic_Schedule_4';

        Calculation__c calculation = new Calculation__c();
        calculation.Name = 'Elastic_Table_Calc';
        calculation.Formula__c = formula;
        insert calculation;

        // CalculationScheduleMember__c member_3 = new CalculationScheduleMember__c();
        // member_3.Consumption_Schedule__c = schedulesByName.get('Elastic_Schedule_3').Id;
        // member_3.Calculation__c = calculation.Id;
        // membersToInsert.add(member_3);

        // CalculationScheduleMember__c member_4 = new CalculationScheduleMember__c();
        // member_4.Consumption_Schedule__c = schedulesByName.get('Elastic_Schedule_4').Id;
        // member_4.Calculation__c = calculation.Id;
        // membersToInsert.add(member_4);

        // insert membersToInsert;

        System.debug('+++ ADD CALCULATION: ' + calculation);

        ConsumptionSchedule scheduleToUpdate = new ConsumptionSchedule();
        scheduleToUpdate.Id = schedulesByName.get('Elastic_Schedule_5').Id;
        scheduleToUpdate.IPU_Calculation__c = calculation.Id;
        update scheduleToUpdate;


        Test.startTest();

        Estimation_Summary__c summary = [SELECT Id, Form__c FROM Estimation_Summary__c LIMIT 1];
        String jsonPayload = IPUE_TestUtils.setupEstimationSchedulePayload(summary);
        System.debug('JSON Payload: ' + jsonPayload);

        List<ConsumptionSchedule> cs = [
            SELECT Id, Name
            FROM ConsumptionSchedule
        ];



        IPUE_FormController.processInput(jsonPayload, summary.Form__c, summary.Id);

        Test.stopTest();
    
    }
}