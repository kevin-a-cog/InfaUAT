/*
 * Name			:	GlobalEmailComposerTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/06/2021
 * Description	:	Global Email Composer test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/06/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalEmailComposerTestClass {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

		//We create an engagement.
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
		insert objEngagement;

		//Now we create an Account.
		Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'US';
		insert objAccount;

		//Now we create a Plan.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'TestNew';
		objPlan.Is_Template__c = false;
		objPlan.Account__c = objAccount.Id;
		insert objPlan;

        //We create Email Messages.
        EmailMessage objEmail = new EmailMessage();
		objEmail.FromAddress = 'test@test.org';
		objEmail.ToAddress = 'test@test.com';
		objEmail.Subject = 'Test';
		objEmail.TextBody = 'Test';
		objEmail.RelatedToId = objEngagement.Id;
		insert objEmail;
		objEngagement = new Engagement__c();
		objEngagement.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Subscription Adoption').getRecordTypeId();
		insert objEngagement;
		objEmail = new EmailMessage();
		objEmail.FromAddress = 'test@test.org';
		objEmail.ToAddress = 'test@test.com';
		objEmail.Subject = 'Test';
		objEmail.TextBody = 'Test';
		objEmail.RelatedToId = objEngagement.Id;
		insert objEmail;
		objEmail = new EmailMessage();
		objEmail.FromAddress = 'test@test.org';
		objEmail.ToAddress = 'test@test.com';
		objEmail.Subject = 'Test';
		objEmail.TextBody = 'Test';
		insert objEmail;
		objEmail = new EmailMessage();
		objEmail.FromAddress = 'test@test.org';
		objEmail.ToAddress = 'test@test.com';
		objEmail.Subject = 'Test';
		objEmail.TextBody = 'Test';
		objEmail.RelatedToId = objAccount.Id;
		insert objEmail;
		objEmail = new EmailMessage();
		objEmail.FromAddress = 'test@test.org';
		objEmail.ToAddress = 'test@test.com';
		objEmail.Subject = 'Test';
		objEmail.TextBody = 'Test';
		objEmail.RelatedToId = objPlan.Id;
		insert objEmail;
    }
	
	/*
	 Method Name : testSendFlow
	 Description : Testing send flow.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testSendFlow() {
        System.runAs(createTestUser('System Administrator', true)) {
            Default_From_Address__mdt defaultFromAddress = [SELECT Id, Organization_Wide_Address_Name__c from Default_From_Address__mdt where Object_API_Name__c ='Plan__c' AND Active__c = TRUE LIMIT 1];
            OrgWideEmailAddress[] addresses = [SELECT Id,Address FROM OrgWideEmailAddress];
			GlobalEmailComposerController.AttachmentWrapper objAttachment = new GlobalEmailComposerController.AttachmentWrapper();
			Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];

			//We prepare the testing data.
			objAttachment.strName = 'Test.txt';
			objAttachment.strBody = 'VGVzdA==';
			objAttachment.strContentType = 'text/plain';

			//Now we start the testing.
			Test.startTest();
			System.assertNotEquals(GlobalEmailComposerController.getCurrentUserEmailAddress() == null, true, 'Unable to get records.');
			System.assertNotEquals(GlobalEmailComposerController.getOrganizationWideEmails(null) == null, true, 'Unable to get records.');
			System.assertNotEquals(GlobalEmailComposerController.getOrganizationWideEmails(null, true) == null, true, 'Unable to get records.');
			for(EmailMessage objEmailMessage : [SELECT Id FROM EmailMessage LIMIT 1000]) {
				System.assertNotEquals(GlobalEmailComposerController.getOrganizationWideEmails(objEmailMessage.Id) == null, true, 'Unable to get records.');
				System.assertNotEquals(GlobalEmailComposerController.getOrganizationWideEmails(objEmailMessage.Id, true) == null, true, 'Unable to get records.');
				System.assertNotEquals(GlobalEmailComposerController.getOriginalEmailDetails(objEmailMessage.Id) == null, true, 'Unable to get records.');
			}
			System.assertNotEquals(GlobalEmailComposerController.getEmailTemplates(null) == null, true, 'Unable to get records.');
			GlobalEmailComposerController.getEmailTemplates('test');
			GlobalEmailComposerController.sendEmail(GlobalEmailComposerController.getOrganizationWideEmails('')[0].Id, 'Subject', 'Body', null,
					new List<String> {'test@test.com'}, new List<String> {'test@test.com'}, new List<String> {'test@test.com'}, 
					new List<GlobalEmailComposerController.AttachmentWrapper> { objAttachment });
			GlobalEmailComposerController.sendEmail('', 'Subject', '', objPlan.Id, new List<String> {'test@test.com'}, null, new List<String> {'test@test.com'}, 
					new List<GlobalEmailComposerController.AttachmentWrapper> { objAttachment });
			
			//Now we test using other sobjects' ids.
			for(EmailMessage objEmailMessage : [SELECT RelatedToId FROM EmailMessage WHERE RelatedToId <> NULL LIMIT 1000]) {
				System.assertNotEquals(GlobalEmailComposerController.getOrganizationWideEmails(objEmailMessage.RelatedToId) == null, true, 'Unable to get records.');
				System.assertNotEquals(GlobalEmailComposerController.getOrganizationWideEmails(objEmailMessage.RelatedToId, true) == null, true, 'Unable to get records.');
			}
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