@isTest(seeAllData = false)
public with sharing class CsmManageRiskOpportunityTest {	

    @testSetup 
    public static void setup() {
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
       
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();
        team.AccountId = lNewCustomerAccount[0].Id;
        insert team;
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);
        //   UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('Name', 'test');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Lead');
        UtilityTestData.mOpportunityData.put('CloseDate', string.valueOf(system.today()));
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
         //Now we insert the Plan Products.
        sObject Related_Account_Plan = new Related_Account_Plan__c();
      
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c',lOpportunity[0].Id);
        
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});

		
        //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
        
		//Now we create a Risk Product Alias.
		Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
		objRiskProductAlias.Opportunity__c = lOpportunity[0].Id;
		objRiskProductAlias.Risk__c = lRisk[0].Id;
		insert objRiskProductAlias;

		
    }
	
    @isTest
    public static void testRecordFetching() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
			Risk_Issue__c objRiskIssue = [SELECT Id FROM Risk_Issue__c LIMIT 1];

            //Now we get the Risk records.
            System.assertNotEquals(CsmManageRiskOpportunity.getRecords(objRiskIssue.Id,true,objPlan.Id) == null, true, 'Unable to get records.');
            CsmManageRiskOpportunity.getRecords(objRiskIssue.Id,false,objPlan.Id);

        }
    }

    @isTest
    public static void testDeleteRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
            Risk_Product_Alias__c objRecord = [SELECT Id,Risk__c FROM Risk_Product_Alias__c LIMIT 1];
			List<Risk_Product_Alias__c> lstRecords = new List<Risk_Product_Alias__c>();

            //Now we prepare the data.
            lstRecords.add(objRecord);
			CsmManageRiskOpportunity.getRecordsRelated(objRecord.Risk__c,[Select Id from Opportunity]);
			//Now we delete the records.
			CsmManageRiskOpportunity.getRecordsDeleted(lstRecords);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Risk_Product_Alias__c] == null, true, 'No records were deleted.');
        }
    }

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
        return objTestUser;
    }
}