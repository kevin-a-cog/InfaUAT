/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for CaseService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        07/13/2022  I2RT-6153   T01     To replace GCS_Segment__c field with Segment__c field in the notifications

 */
@isTest
public with sharing class CaseServiceTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        //create an Account record
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }
    
    @isTest
    static void testAllMethods(){

        Case cse = [Select Id, CaseNumber, Subject, IsEscalated, Forecast_Product__c, 
                            AccountId, OwnerId, Owner_Name__c, Attention_Request__c,
                            Priority, Support_Level__c, Version__c, GCS_Segment__c, Segment__c, Acc__c, //T01
                            Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                            Account.Name, Account.New_Org_Account_Number__c, Escalation_Attention__c,
                            Business_Impact__c,Estimated_Date_for_Milestone__c  
                        From Case Limit 1];
    
        Test.startTest();

        CaseController controller = new CaseController();
        CaseService service = new CaseService();
        CaseCommentService commentService = new CaseCommentService();
        CaseCommentService.createComment(cse.Id, UserInfo.getUserId(),'Test comments','Test type', 'Test status',true,'Internal', true);
        CaseCommentService.createClonedCaseComment(cse.Id,'Test comment');
            
        CaseController.escalateCase(cse.Id, 'Quality Of Service', 'Test comment');
        try{
            CaseController.escalateCase(cse.Id, '', 'Test comment');
        }catch(Exception ex){}

        try{
            //I2RT-4421
            CaseController.requestAttn(cse.Id, 'Revise Priority', 'Test comment','Critical Development Blocker',System.today());
        }catch(Exception ex){}

        try{
            //I2RT-4421
            CaseController.requestAttn('', 'aaaaaaaaa', 'Test comment','Critical Development Blocker',System.today());
        }catch(Exception ex){}
        
        CaseController.switchOwner(cse.Id, UserInfo.getUserId());
        try{
            CaseController.switchOwner(cse.Id, null);
        }catch(Exception ex){}

        CaseController.getCoOwners(cse.Id);
		CaseService.notifyCaseTeamCaseUpdate(cse,'test');
        Test.stopTest();
    }
}