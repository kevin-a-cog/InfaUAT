/*
    @created by       : Sandeep D
    @created on       : 11/10/2022
    @Purpose          : This call will a list of case records with weightages in ascending order 
    @Testclass        : CaseTriggerHelperTest.testForSort
    @JIRA             : I2RT- 6980
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 */
global  class SortCasesWithWeightages implements Comparable {
    public Case cs {get; set;}
    public Decimal weightage {get; set;}
    public SortCasesWithWeightages(Case cs, Decimal weightage) {
        this.cs = cs;
        this.weightage = weightage;
        
    }
    global Integer compareTo(Object compareTo) {
        // Casting  argument to casewrapper
        SortCasesWithWeightages compareToCase = (SortCasesWithWeightages)compareTo;
        Integer returnValue = 0;
        if (weightage < compareToCase.weightage) {
            returnValue = 1;
        } else if (weightage > compareToCase.weightage) {
            returnValue = -1;
        }
        return returnValue;       
    }
}