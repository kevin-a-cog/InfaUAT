/*
* Name          :   CSMManageMilestoneProductsTest
* Author        :   Deva M
* Created Date  :   08/20/2021
* Description   :   Test class for CSMManageMilestoneProducts

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
*/
@isTest(seeAllData = false)
public class CSMManageMilestoneProductsTest {
    
  
    /*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
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
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        
       
      
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        //  UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
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

     
         //Milestone__c
        
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

		//Now we create the Technical Product Line.
		Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
		objTechnicalProductLine.Name = 'Address Verification';
		objTechnicalProductLine.Forecast_Product__c = 'Active VOS';
		objTechnicalProductLine.Status__c = 'Active';
		insert objTechnicalProductLine;

		//Now we create a Plan Product Alias.
		Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
		objPlanProductAlias.Plan__c = lPlan[0].Id;
		objPlanProductAlias.Forecast_Product__c = 'Active VOS';
		objPlanProductAlias.Technical_Product_Line__c = objTechnicalProductLine.Id;
		insert objPlanProductAlias;
		objObjectiveProduct.Plan_Product_Alias__c = objPlanProductAlias.Id;
		update objObjectiveProduct;
	
    }

    
    
    @isTest
    public static void testgetRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c plan=[select Id from Plan__c limit 1];
            Milestone__c milestone=[select Id from Milestone__c limit 1];        
            GlobalDataTableWrapperClass obj = new GlobalDataTableWrapperClass();      
            obj=CSMManageMilestoneProducts.getRecords(plan.Id,false,milestone.Id); 
            System.assert(obj.lstRecords.size()>0);
        }
    }
    @isTest
    public static void testgetRecordsRelated() {
        System.runAs(createTestUser('System Administrator', true)) {
        Plan__c plan=[select Id from Plan__c limit 1];
        Milestone__c milestone=[select Id from Milestone__c limit 1]; 
        List<String> lstRecords = new List<String>();
        for(Objective_Product__c op:[Select Id,Plan_Product_Alias__c from Objective_Product__c]){
            lstRecords.add(op.Id);
        }
        GlobalDataTableWrapperClass obj = new GlobalDataTableWrapperClass();
        CSMManageMilestoneProducts.getRecordsRelated(milestone.Id,lstRecords); 
        obj=CSMManageMilestoneProducts.getRecords(plan.Id,true,milestone.Id); 
        System.assert(obj.lstRecords.size()>0);  
        
        //Now test deleting Milestone_Product__c records
        List<Milestone_Product__c> mplist = new List<Milestone_Product__c>([select id from Milestone_Product__c]);
        CSMManageMilestoneProducts.getRecordsDeleted(mplist);
        List<Milestone_Product__c> checkafterdelete = new List<Milestone_Product__c>([select id from Milestone_Product__c]);
        System.assert(checkafterdelete.size()<=0);  
    }
    }
    
    
    /*
	 Method Name : createTestUser
	 Description : This method serves as a Utility method to create Test users.
	 Parameters	 : String, called from createTestUser, strProfileName Profile name.
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
        
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}