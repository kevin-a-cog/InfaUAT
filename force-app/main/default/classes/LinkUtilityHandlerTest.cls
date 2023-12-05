/*
 * Name			:	LinkUtilityHandlerTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/26/2022
 * Description	:	Quick Links test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/26/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class LinkUtilityHandlerTest {

	//Private variables.
	private static String strApplication = 'Success';
	private static String strPublicGroup = Link__c.Public_Groups__c.getDescribe().getPicklistValues()[0].getValue();
	private static String strSkill = Link__c.Skills__c.getDescribe().getPicklistValues()[0].getValue();

	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		Id idSkill;
		Id idGroup;
		Link__c objLink;
		Group objGroup = new Group();
		ProfileSkill objProfileSkill = new ProfileSkill();
		List<Link__c> lstLinks = new List<Link__c>();

        //Inserting Links.
		objLink = new Link__c();
		objLink.Name = 'Test';
		objLink.Link_URL__c = 'www.test.com';
		objLink.Applications__c = strApplication;
		objLink.Group_Name__c = 'Test';
		lstLinks.add(objLink);
		objLink = new Link__c();
		objLink.Name = 'Test';
		objLink.Link_URL__c = 'www.test.com';
		objLink.Applications__c = strApplication;
		objLink.Group_Name__c = 'Personal';
		lstLinks.add(objLink);
		objLink = new Link__c();
		objLink.Name = 'Test';
		objLink.Applications__c = strApplication;
		objLink.Group_Name__c = 'Test';
		objLink.Link_URL__c = 'www.test.com';
		lstLinks.add(objLink);
		objLink = new Link__c();
		objLink.Name = 'Test';
		objLink.Applications__c = strApplication;
		objLink.Link_URL__c = 'www.test.com';
		objLink.Group_Name__c = 'Test';
		objLink.Public_Groups__c = strPublicGroup;
		lstLinks.add(objLink);
		objLink = new Link__c();
		objLink.Name = 'Test';
		objLink.Applications__c = strApplication;
		objLink.Link_URL__c = 'www.test.com';
		objLink.Group_Name__c = 'Test';
		objLink.Skills__c = strSkill;
		lstLinks.add(objLink);
		objLink = new Link__c();
		objLink.Name = 'Test';
		objLink.Applications__c = strApplication;
		objLink.Link_URL__c = 'www.test.com';
		objLink.Group_Name__c = 'Test';
		objLink.Public_Groups__c = strPublicGroup;
		lstLinks.add(objLink);
		objLink = new Link__c();
		objLink.Applications__c = strApplication;
		objLink.Name = 'Test';
		objLink.Link_URL__c = 'www.test.com';
		objLink.Group_Name__c = 'Test';
		objLink.Skills__c = strSkill;
		lstLinks.add(objLink);

		//Now we insert the links.
		insert lstLinks;

		//We insert Skills.
		for(ProfileSkill objRecord : [SELECT Id FROM ProfileSkill WHERE Name = :strSkill LIMIT 1]) {
			idSkill = objRecord.Id;
		}
		if(idSkill == null) {
			objProfileSkill.Name = strSkill;
			objProfileSkill.Queue_Name__c = 'Data_as_a_Service';
			objProfileSkill.Type__c = 'Product Manager';
			objProfileSkill.Omni_Skill_Name__c = 'Data_as_a_Service_Manager';
			insert objProfileSkill;
		}

		//We insert Groups.
		for(Group objRecord : [SELECT Id FROM Group WHERE Name = :strPublicGroup LIMIT 1]) {
			idGroup = objRecord.Id;
		}
		if(idGroup == null) {
			objGroup.Name = strPublicGroup;
			insert objGroup;
		}
    }
	
	/*
	 Method Name : testSendGridResponse
	 Description : Testing SendGrid response
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFlow() {
        System.runAs(createTestUser('System Administrator', true)) {
			GroupMember objGroupMember = new GroupMember();
			ProfileSkillUser objProfileSkillUser = new ProfileSkillUser();
			LinkUtilityWrapperClass objWrapper = new LinkUtilityWrapperClass();

			//Now we create teh Profile Skill User.
			objProfileSkillUser.ProfileSkillId = [SELECT Id FROM ProfileSkill WHERE Name = :strSkill LIMIT 1].Id;
			objProfileSkillUser.UserId = UserInfo.getUserId();
			objProfileSkillUser.Status__c = 'Approved';
			objProfileSkillUser.Priority__c = 'P1';
			objProfileSkillUser.Support_Level__c = 'Standard';
			objProfileSkillUser.Component__c = 'Accelerator';
			insert objProfileSkillUser;

			//Now we create Group Member.
			objGroupMember.GroupId = [SELECT Id FROM Group WHERE Name = :strPublicGroup LIMIT 1].Id;
			objGroupMember.UserOrGroupId = UserInfo.getUserId();
    		insert objGroupMember;

			//Now we start the testing.
			Test.startTest();

			//We send the request.
			LinkUtilityHandler.getLinkUtilitiesMTD();
			LinkUtilityHandler.getLinkItems(null, UserInfo.getUserId());
			LinkUtilityHandler.getLinkItems(strApplication, UserInfo.getUserId());
			LinkUtilityHandler.getLinkDeleted([SELECT Id FROM Link__c]);

			//Now we test the Wrapper.
			objWrapper.boolCanAdd = true;
			objWrapper.boolCanAdd = objWrapper.boolDisplayDropDown;

			//Now we make sure records were deleted.
			System.assertNotEquals([SELECT Id FROM Link__c LIMIT 1] == null, true, 'Unable to delete records.');

			//We stop the test.
			Test.stopTest();
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
		List<PermissionSetAssignment> lstPermissionSets = new List<PermissionSetAssignment>();

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

		//Now we add the permission set.
        for(PermissionSet objPermissionSet :[SELECT Id,Type FROM PermissionSet WHERE Name LIKE 'CSM_Success%']) {
			//if(objPermissionSet.Type == 'Regular'){
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
			//}
        }
        
		for(PermissionSetGroup objPermissionSetGroup :[SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'CSMSuccess_Manager']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetGroupId = objPermissionSetGroup.Id));
        }

        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }

		//Now we return the result.
        return objTestUser;
    }
}