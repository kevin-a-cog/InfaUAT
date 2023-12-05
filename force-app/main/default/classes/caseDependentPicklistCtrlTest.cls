/*
    @created by       : Pavithra V
    @created on       : 09/03/2021
    @Purpose          : Controller class for caseDependentPicklist LWC
    @Testclass        : caseDependentPicklistCtrlTest
    @JIRA             : I2RT-672
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
Pavithra V 		27-09-2021                      To increase test class coverage
 */
@isTest
public class caseDependentPicklistCtrlTest {

    @testSetup
    static void setupObjectTestData() {
        
        //create an Account record
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create Technical Product Lines
        sObj = new Technical_Product_Line__c();
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mTechnicalProdLines);
		UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }
    
    @isTest
    static void testcaseDependentPicklistController(){

        Case cse = [Select Id From Case Limit 1];
        String caseId = cse.Id;
        
        Map<String, Map<String, List<String>>> componentsMap = new Map<String, Map<String, List<String>>>();
        Map<String, List<String>> versionsMap = new Map<String, List<String>>();

        Test.startTest();
        caseDependentPicklistController.getProductAttributes(cse.Id);
        caseDependentPicklistController.saveProductDetails(caseId ,'Active VOS','ActiveVOS Console', 'Error','Installation' , '1' ,componentsMap , versionsMap, true);
        caseDependentPicklistController.getCaseDetails(cse.Id);
        caseDependentPicklistController.checkExistingValues(caseId ,'ActiveVOS Console', 'ActiveVOS Console','Error' , '1');

        Test.stopTest();
        
    }

    @isTest
    static void testFulfillmentComponents(){

        Id fulfillmentCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();
        Test.startTest();

        sObject sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('RecordTypeId', fulfillmentCaseRecType);
        List<Case> caseList = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

        caseDependentPicklistController.getProductAttributes(caseList[0].Id);
        Test.stopTest();
        
    }
}