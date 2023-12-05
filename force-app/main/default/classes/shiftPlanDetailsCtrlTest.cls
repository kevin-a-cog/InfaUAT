@isTest
public with sharing class shiftPlanDetailsCtrlTest {
    
    @isTest public static void testMethod1(){
        Shift_Plan__c sp = new Shift_Plan__c(
            Name='Some Plan', 
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c =  Date.today().addDays(5)
        );
        insert sp;

        Shift_Request__c sr = new Shift_Request__c(
            Shift_Plan__c = sp.Id,
            Resource_Count__c = 5
        );
        insert sr;

        Shift_Allocation__c sa = new Shift_Allocation__c(
            Shift_Request__c = sr.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(3),
            Status__c = 'Pending'
        );
        insert sa;

        Test.startTest();
            shiftPlanDetailsCtrl ctrl = new shiftPlanDetailsCtrl();
            ctrl.shiftPlanId = sp.Id;
            //ctrl.getshiftRequest();
            List<Shift_Request__c> posToDisplay = ctrl.shiftRequest;
        Test.stopTest();
    }

}