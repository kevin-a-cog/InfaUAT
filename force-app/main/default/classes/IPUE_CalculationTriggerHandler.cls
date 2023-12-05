/*
Class:  IPUE_CalculationTriggerHandler
@Author: ATG
@Description: Trigger Handler for Calculation__c object
@TestClass: IPUE_CalculationTest
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description                                                                               Tag
Chandana Gowda      16-May-22       SALESRT-13892     Update the members only if the formula field is updated                                   <T1>
*************************************************************************************************************************************************************
*/
public with sharing class IPUE_CalculationTriggerHandler extends TriggerHandler {

    private static Map<String, Set<Id>> csIdsByCalcName = new Map<String, Set<Id>>();

    public override void beforeInsert() {
        csIdsByCalcName = new Map<String, Set<Id>>();
        List<Calculation__c> newCalculations = new List<Calculation__c>();
        for (sObject calcSObject : newList) {
            Calculation__c calculation = (Calculation__c) calcSObject;
            if (!String.isBlank(calculation.Formula__c)) {
                newCalculations.add(calculation);
            }
        }
        if (!newCalculations.isEmpty()) {
            compileAll(newCalculations);
        }
    }

    public override void beforeUpdate() {
        List<Calculation__c> updatedCalculations = new List<Calculation__c>();
        for (sObject calcSObject : newList) {
            Calculation__c calculation = (Calculation__c) calcSObject;
            Calculation__c oldCalculation = (Calculation__c) oldMap.get(calculation.Id);
            if (calculation.Formula__c != oldCalculation.Formula__c) {
                updatedCalculations.add(calculation);
            }
        }
        if (!updatedCalculations.isEmpty()) {
            compileAll(updatedCalculations);
        }
    }

    private void compileAll(List<Calculation__c> calculations) {
        for (Calculation__c calculation : calculations) {
            try {
                calculation.IPUE_PostfixFormula__c = IPUE_CalculationUtils.compileFormula(calculation.Formula__c);
            } catch (Exception e) {
                System.debug(e);
                calculation.addError(Calculation__c.Formula__c, 'Formula compilation error: ' + e.getMessage(), true);
            }
        }
        createReferences(calculations);
        // No DML on the object in before trigger
    }

    private void createReferences(List<Calculation__c> calculations) {

        Set<String> allNames = new Set<String>();
        Map<Calculation__c, Set<String>> csNamesByCalc = new Map<Calculation__c, Set<String>>();

        for (Calculation__c calc : calculations) {
            // Call a util method to get a set of cs names for it
            if (!calc.hasErrors()) {
                Set<String> names = IPUE_CalculationUtils.extractVarNames(calc.IPUE_PostfixFormula__c);
                csNamesByCalc.put(calc, names);
                allNames.addAll(names);
            }
        }

        Map<String, ConsumptionSchedule> schedulesByName = new Map<String, ConsumptionSchedule>();
        Set<String> ambiguousNames = new Set<String>();
        Set<String> elasticSchedules = new Set<String>();

        for (ConsumptionSchedule cs : [
            SELECT Id, Name, Data_Type__c,
                (
                    SELECT Id, Parent_Estimation_Schedule__r.Data_Type__c
                    FROM Table_Cell_Members__r
                )
            FROM ConsumptionSchedule
            WHERE Name IN :allNames WITH SECURITY_ENFORCED
        ]) {

            // If the Set already contains the Name, mark it as a duplicate
            if (schedulesByName.containsKey(cs.Name)) {
                ambiguousNames.add(cs.Name);
            }

            // If the Consumption Schedule has child Table Cells
            if (!cs.Table_Cell_Members__r.isEmpty()) {

                for (Table_Cell__c tableCell : cs.Table_Cell_Members__r) {
                    // If the Table Cell is related to an Elastic Table, flag Consumption Schedule as non-referenceable
                    if (tableCell.Parent_Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
                        elasticSchedules.add(cs.Name);
                    }
                }

            }

            // Add Consumption Schedule to Map
            schedulesByName.put(cs.Name, cs);
        }

        for (Calculation__c calc : calculations) {

            List<String> names = new List<String>(csNamesByCalc.get(calc));
            for (String name : names) {
                if (ambiguousNames.contains(name)) {
                    calc.addError('Reference error: Multiple consumption schedules found for "' + name + '"');
                } else if (!schedulesByName.containsKey(name)) {
                    calc.addError('Reference error: No consumption schedule found for "' + name + '"');
                } else if (!calc.hasErrors()) {
                    // Note down the information for later to avoid dml in before trigger
                    if (!csIdsByCalcName.containsKey(calc.Name)) {
                        csIdsByCalcName.put(calc.Name, new Set<Id>());
                    }
                    csIdsByCalcName.get(calc.Name).add(schedulesByName.get(name).Id);
                }
            }
        }
    }

    // Records have already been checked; insert based on notes from before trigger
    public override void afterInsert() {
        updateMembers(newList);
    }

    public override void afterUpdate() {
        checkFormulaChange(oldMap,newMap); //<T1>
    }
    
    //------------------------------------------------------------------------------------<T1>
    /*Method Name : checkFormulaChange
    * @param mapNew - oldMap, newMap: From Trigger
    * @return return-void
    * @throws exception - NA
    * @description - checks if the formula field is updated, only then delete and insert the schedule members
    */ 
    private void checkFormulaChange(Map<Id,SObject> oldMap,Map<Id,SObject> newMap){
        List<Calculation__c> lstCalc = new List<Calculation__c>();
        for(SObject calcRec:newMap.values()){
            if(calcRec.get('Formula__c') != oldMap.get(calcRec.Id).get('Formula__c')){
                lstCalc.add((Calculation__c) calcRec);
            }
        }

        if(!lstCalc.isEmpty()){
            updateMembers(lstCalc);
        }
    }
    //------------------------------------------------------------------------------------<T1>

    private void updateMembers(List<SObject> calcs) {

        List<Calculation__c> newCalculations = new List<Calculation__c>();
        Set<Id> calcIds = new Set<Id>();
        for (sObject calcSObject : calcs) {
            newCalculations.add((Calculation__c) calcSObject);
            calcIds.add(calcSObject.Id);
        }
        List<CalculationScheduleMember__c> newMembers = new List<CalculationScheduleMember__c>();
        for (Calculation__c calc : newCalculations) {

            if (csIdsByCalcName.containsKey(calc.Name) && csIdsByCalcName.get(calc.Name) != null) {
                for (Id csId : csIdsByCalcName.get(calc.Name)) {

                    newMembers.add(new CalculationScheduleMember__c(
                        Calculation__c = calc.Id,
                        Name = calc.Name + '|' + csId,
                        Consumption_Schedule__c = csId
                    ));
                }
            }
        }
        if (isUpdate) {
            List<CalculationScheduleMember__c> existingMembers = [
                SELECT Id
                FROM CalculationScheduleMember__c
                WHERE Calculation__c IN :calcIds WITH SECURITY_ENFORCED
            ];
            if (!existingMembers.isEmpty() && CalculationScheduleMember__c.sObjectType.getDescribe().isDeletable()) {
                delete existingMembers;
            }
        }

        if (!newMembers.isEmpty() && CalculationScheduleMember__c.sObjectType.getDescribe().isCreateable()) {
            insert newMembers;
        }
    }
}