/*
* Name			:	CSMOneClickActionControllerTest
* Author		:	Deva M
* Created Date	: 	17/09/2021
* Description	:	Test Class for CSMOneClickActionController.

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				17/09/2021		N/A				Initial version.			N/A
*/
@isTest
public with sharing class CSMOneClickActionControllerTest {
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    @testSetup
    static void setupObjectTestData() {  
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        system.runAs(adminUser){
            Id pbId = Test.getStandardPricebookId();
            //Insert Account setup data
            sObject sObj = new Account();
            sObject sObj1 = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Insert contact
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Inserting an Opportunity
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
            UtilityTestData.mOpportunityData.put('Name', 'Primary');
            UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
            UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
            UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
            UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
            UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
            UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            
            
            //Creating Secondary Opportunity
            sObj1 = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Secondary');
            UtilityTestData.mOpportunityData.put('Name', 'Secondary');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '70'); 
            UtilityTestData.mOpportunityData.put('Pricebook2Id ', pbId); 
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunity[0].Id, Pricebook2Id = pbId);
            sObj1 = new Opportunity(id = lOpportunity[1].Id, Pricebook2Id = pbId);
            lOpportunity = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj,sObj1});
            Test.startTest();
            //Insert Opportunity Contact Roles
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[0].Id);
            sObj = new OpportunityContactRole();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});    
            
            //Insert Opportunity Team members
            UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityTeamMemberData.put('UserId',sogUser.Id);
            sObj = new OpportunityTeamMember ();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
            List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});   
            
            
            UtilityTestData.mAccountTeamMember.put('AccountId',lAccount[0].id + '');
            UtilityTestData.mAccountTeamMember.put('UserId',psmUser.Id+ '');
            UtilityTestData.mAccountTeamMember.put('TeamMemberRole','PSM');
            
            sObject AccTeamMember1 = new AccountTeamMember();
            AccTeamMember1 = UtilityTest.putFieldRecord(AccTeamMember1, UtilityTestData.mAccountTeamMember);
            
            //Add all accounts team member to acclist
            List<AccountTeamMember> accTeamMemList = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{AccTeamMember1});
            
            //Now we create a Plan.
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'Test';
            objPlan.Plan_Operational_Model__c='Named CSM';
            objPlan.Account__c=lAccount[0].Id;
            insert objPlan;
            
            //Now we create a Plan Contract.
            Plan_Contract__c objPlanContract = new Plan_Contract__c();
            objPlanContract.Plan__c = objPlan.Id;
            objPlanContract.Opportunity__c=lOpportunity[0].Id;
            insert objPlanContract;
            
            //Plan Contacts
            sObject PlanContact = new Plan_Contact__c();
            UtilityTestData.mPlanContact.put('Plan__c',objPlan.Id);
            UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
            //UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
            PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
            List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact});
            
            Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
            /*sObject engagement = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Plan__c',objPlan.Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
            UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('RecType__c','MFA');
            //UtilityTestData.mEngagementData.put('Status__c','Submitted for Approval');
            engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);        
            List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});*/
            Engagement__c engagement = new Engagement__c();
            engagement.put('Account__c',lAccount[0].Id);
            engagement.put('Name','Test Engagment');
            engagement.put('Plan__c',objPlan.Id);
            engagement.put('RecordTypeId', CSTEngagementRT);
            engagement.put('Opportunity__c',lOpportunity[0].Id);
            engagement.put('Owner_Manager__c',UserInfo.getUserId());
            engagement.put('OwnerId',UserInfo.getUserId());
            engagement.put('RecType__c','CSA');
            engagement.put('Status__c','Submitted for Approval');
            insert engagement;
            Test.stopTest();
        }
    }


    @isTest
    public static void getPlanTeamRecordTest() {
         //System.runAs(createTestUser('System Administrator', true)) {
        Test.startTest();
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];
        Engagement__c eng=[select Id,Plan__c from Engagement__c limit 1];
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id, Role__c=CSMUtilities.ROLE_CSM,Primary__c=true);
        GlobalDataTableWrapperClass  obj=new GlobalDataTableWrapperClass ();
        obj =CSMManagePlanTeamController.getAssignedRecords(plan.Id, plan.Account__c); 
        system.assert( obj.lstRecords.size()>0);
        Plan_Team__c pTeam = CSMOneClickActionController.getPlanTeamRecord(plan.Id);
        system.assert( pTeam.User__c == UserInfo.getUserId());
        CSMOneClickActionController.getResendSurveyVisiblity(plan.Id,null);    
        CSMOneClickActionController.getResendSurveyVisiblity(eng.Plan__c,eng.Id);
        Test.stopTest();
    //}
    }
    

    @isTest
    public static void updatePlanTeamMemberTest() {
         //System.runAs(createTestUser('System Administrator', true)) {
        Test.startTest();
        Engagement__c eng = [Select Id from Engagement__c limit 1];
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id,CSM_Receive_Notifications__c=false,Role__c=CSMUtilities.ROLE_CSM,Primary__c=true);
        GlobalDataTableWrapperClass  obj=new GlobalDataTableWrapperClass ();
        obj =CSMManagePlanTeamController.getAssignedRecords(plan.Id, plan.Account__c); 
        system.assert( obj.lstRecords.size()>0);
        Plan_Team__c pTeam = CSMOneClickActionController.getPlanTeamRecord(plan.Id);
        system.assert( pTeam.User__c == UserInfo.getUserId());
        CSMOneClickActionController.updatePlanTeamMember(pTeam.Id,true);
        Plan_Team__c afterUpdateTeam =[SELECT Id,CSM_Receive_Notifications__c, User__c, Plan__c  FROM Plan_Team__c where Id=:pTeam.Id LIMIT 1];
        system.assert( afterUpdateTeam.CSM_Receive_Notifications__c);
        CSMOneClickActionController.getPlanRecordId(eng.Id);
        CSMOneClickActionController.getObjectName(plan.Id);
        CSMOneClickActionController.CheckPlanContactforCSASurvey(plan.Id);
        CSMOneClickActionController.CheckPlanContactforMFASurvey(plan.Id);
        Test.stopTest();
         //}
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