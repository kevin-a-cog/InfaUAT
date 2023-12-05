/****************************************************************************************************************
Class:          installBaseLookupControllerTest
@Author:        chandana gowda
@Created Date:  9/4/2019.
@Description:   Class for Testing the controller of the lightning component installBaseLookup
******************************************************************************************************************
Change History 
*******************************************************************************************************************/
@isTest
public with sharing class installBaseLookupControllerTest {
    
    //Setting up the data necessary for testing
    @testSetup
    static void setupObjectTestData() {

        sObject sObj1 = new InstallBase__c();
        sObject sObj2 = new InstallBase__c();
        //UtilityTestData.mInstallBase.put('Name', 'Test Install Base 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mInstallBase);
        UtilityTestData.mInstallBase.put('Name', 'Test Install Base 2');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mInstallBase);
        List<InstallBase__c> lAccount = (List<InstallBase__c>) UtilityTest.makeInsert(new List<sObject>{sObj1,sObj2});
    }

    //method for testing the retrival of installBase records to display in Lookup field
    static @IsTest void testFetchLookUpValues(){
        
        Test.startTest();
            List<InstallBase__c> lstInstallBase=installBaseLookupController.fetchLookUpValues('test','InstallBase__c',null);
        Test.stopTest();

        System.assertEquals(2, lstInstallBase.size());
        
    }
}