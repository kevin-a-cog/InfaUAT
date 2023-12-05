/*
 * Name         :   CSMObjectivesAndMilestonesTest
 * Author       :   Monserrat Pedroza
 * Created Date :   9/10/2021
 * Description  :   Objectives and Milestones test class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      9/10/2021       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMObjectivesAndMilestonesTest {
    
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
      
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
		UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
    
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 

    
        
        // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});

      
        
         sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        
        sObject mstone1 = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        mstone1 = UtilityTest.putFieldRecord(mstone1, UtilityTestData.mPlanMilestone);       
        
        sObject mstone2 = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Technical Milestone');
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        mstone2 = UtilityTest.putFieldRecord(mstone2, UtilityTestData.mPlanMilestone);
     
        
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone,mstone1,mstone2});

      
         //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('Type__c','Adoption');
        UtilityTestData.mRiskIssue.put('Milestone__c',lMilestone[0].Id);        
        UtilityTestData.mRiskIssue.put('Risk_Reason__c','Acquisition');
        UtilityTestData.mRiskIssue.put('Status__c','Open');
         UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});

    

        //Now we insert the Plan Products.
        sObject Related_Account_Plan = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Active VOS');
        
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});
        
        //Now we create the Objective Products.
        Objective_Product__c objObjectiveProduct = new Objective_Product__c();
        objObjectiveProduct.Objective__c = lObjective[0].Id;
        objObjectiveProduct.Plan_Product__c = lPlanProd2[0].Id;
        insert objObjectiveProduct;

        //Now we create the Milestone Product.
        Milestone_Product__c objMilestoneProduct = new Milestone_Product__c();
        objMilestoneProduct.MIlestone__c = lMilestone[0].Id;
        objMilestoneProduct.Objective_Product__c = objObjectiveProduct.Id;
        insert objMilestoneProduct;

		//Now we create a Plan Product Alias.
		Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
		objPlanProductAlias.Plan__c = lPlan[0].Id;
		objPlanProductAlias.Forecast_Product__c = 'Active VOS';
		insert objPlanProductAlias;
		objObjectiveProduct.Plan_Product_Alias__c = objPlanProductAlias.Id;
		update objObjectiveProduct;
		objMilestoneProduct.Plan_Product_Alias__c = objPlanProductAlias.Id;
		update objMilestoneProduct;

		//We create an Engagement and Task for the Milestone.
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.Plan__c = Plan.Id;
		objEngagement.Milestone__c = mstone.Id;
		insert objEngagement;
		Task objTask = new Task();
		objTask.WhatId = mstone.Id;
		insert objTask;
		objTask = new Task();
		objTask.WhatId = mstone.Id;
		objTask.ActivityDate = System.today();
		insert objTask;
    }
    
    /*
     Method Name : testFetchingRecords
     Description : Testing fetching records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testFetchingRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
            Boolean boolResult;
            Integer intResult;
            String strResult;
            CSMObjectivesAndMilestonesWrapper.StatusWrapper objStatusWrapper = new CSMObjectivesAndMilestonesWrapper.StatusWrapper();
            CSMObjectivesAndMilestonesWrapper.ProductWrapper objProductWrapper = new CSMObjectivesAndMilestonesWrapper.ProductWrapper();
            CSMObjectivesAndMilestonesWrapper.ActionWrapper objActionWrapper = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
            CSMObjectivesAndMilestonesWrapper.IconWrapper objIconWrapper = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
            Plan__c objPlan = [SELECT Id FROM Plan__c];

            //Now we get the records.
            Test.startTest();
            System.assertNotEquals(CSMObjectivesAndMilestonesController.getRecords(objPlan.Id) == null, true, 'Unable to get records.');
			System.assertNotEquals(CSMObjectivesAndMilestonesController.isInternalUser(), true, 'Unable to get records.');
			System.assertNotEquals(CSMObjectivesAndMilestonesController.isCSMSuccessCommunity(), true, 'Unable to get records.');

            //We also cover the wrapper class.
            for(Schema.PicklistEntry objPicklistValue : Milestone__c.Status__c.getDescribe().getPicklistValues()) {
                objStatusWrapper.strValue = objPicklistValue.getValue();
                strResult = objStatusWrapper.strColor;
            }
            strResult = objProductWrapper.strClasses;
			strResult = objProductWrapper.strStyle;
            objActionWrapper.lstSubactions = new List<CSMObjectivesAndMilestonesWrapper.ActionWrapper> {
                new CSMObjectivesAndMilestonesWrapper.ActionWrapper()
            };
            boolResult = objActionWrapper.boolHasSubactions;
            boolResult = objActionWrapper.boolIsStaticResource;
            strResult = objActionWrapper.strURL;
            strResult = objActionWrapper.strInverseIcon;
            strResult = objActionWrapper.strInverseURL;
            strResult = objIconWrapper.strIcon;
            intResult = objActionWrapper.intWidth;
            Test.stopTest();
        }
    }

    /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        //Assign CSM permissions
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet objPermissionSet :[SELECT Id,Type FROM PermissionSet WHERE Name LIKE 'CSM_Success%']) {
			if(objPermissionSet.Type == 'Regular'){
               PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id);
               psAssignList.add(psAssign);
            }
        }
        if(psAssignList.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}