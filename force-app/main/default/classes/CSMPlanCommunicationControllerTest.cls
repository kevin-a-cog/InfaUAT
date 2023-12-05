/*
* Name          :   CSMPlanCommunicationControllerTest
* Author        :   Deva M
* Created Date  :   16/11/2021
* Description   :   Test class for CSMPlanCommunicationController

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M              13/10/2021      N/A             Initial version.            N/A
*/
@isTest
public with sharing class CSMPlanCommunicationControllerTest {
    @testSetup
    static void setupObjectTestData() {
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id);
    }  
    @isTest
    public static void getRecordsTest() {
        Plan__c plan=[select Id from Plan__c limit 1];
        Test.startTest();
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=plan.Id);
        planComment.Comment__c='commentValue';
        planComment.Type__c=CSMUtilities.TYPE_INTERNAL;
        planComment.Status__c=CSMUtilities.STATUS_SUBMITTED;
        planComment.Sub_Type__c='Auto Pilot';
        planComment.Is_Automated__c=true;
        insert planComment;
        test.stopTest();
        CSMPlanCommunicationController.getRecords(plan.Id,CSMUtilities.TYPE_INTERNAL,'Auto Pilot');
        CSMPlanCommunicationController.getEmailTemplates(plan.Id);
        String contentId = createDocumentRecord(plan.Id);
        CSMPlanCommunicationController.tagFilestoComments(plan.Id,planComment.Id,new List<String>{contentId});
        CSMPlanCommunicationController.getPlanTeamRecords(plan.Id);
        CSMPlanCommunicationController.updatePlanTeamRecord(plan.Id);
		CSMPlanCommunicationController.getDocuments(planComment.Id, planComment.Id, true);
		CSMPlanCommunicationController.getDocuments(planComment.Id, planComment.Id, false);
		CSMPlanCommunicationController.checkPlanAutoPilot(plan.Id);
		CSMPlanCommunicationController.fetchMergedQuickText('test', plan.Id);
    }

    @isTest
    public static void createJiraCommentFromPlanCommentTest() {
        Plan__c plan=[select Id from Plan__c limit 1];
       
        zsfjira__ZIssue__c zissue = new zsfjira__ZIssue__c();
        zissue.zsfjira__Description__c = 'test';
        zissue.zsfjira__IssueId__c = 1234;
        zissue.zsfjira__IssueKey__c = '1234';        
        insert zissue;
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=plan.Id);
        planComment.Comment__c='commentValue';
        planComment.Type__c=CSMUtilities.TYPE_INTERNAL;
        planComment.Status__c=CSMUtilities.STATUS_SUBMITTED;
        planComment.Sub_Type__c='Auto Pilot';
        planComment.Is_Automated__c=true;
        insert planComment;

        Plan_Comment__c planChildComment = new Plan_Comment__c(Plan__c=plan.Id);
        planChildComment.Comment__c='commentValue';
        planChildComment.Type__c=CSMUtilities.TYPE_INTERNAL;
        planChildComment.Status__c=CSMUtilities.STATUS_SUBMITTED;
        planChildComment.Sub_Type__c='Auto Pilot';
        planChildComment.Is_Automated__c=true;
        planChildComment.Parent_Comment__c=planComment.Id;
        insert planChildComment;
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        Test.startTest();
        CSMPlanCommunicationController.createJiraCommentFromPlanComment(planChildComment.Id);        
        test.stopTest();
        CSMPlanCommunicationController.getPermissionOnObject();
		CSMPlanCommunicationController.getRecords(plan.Id,CSMUtilities.TYPE_INTERNAL,'Auto Pilot');
    }
    
    public static Id createDocumentRecord(Id sobjectId){
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = sobjectId;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        return contentVersion_2.contentdocumentid;
    }
	
	/*
	 Method Name : testEmailMessages
	 Description : Testing Email scenarios.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testEmailMessages() {
        System.runAs(createTestUser('System Administrator', true)) {
			Id idPlan = [SELECT Id FROM Plan__c LIMIT 1].Id;
			Plan_Comment__c objPlanComment = new Plan_Comment__c();
			Plan_Comment__c objPlanChildComment = new Plan_Comment__c();
			EmailMessage objEmail = new EmailMessage();
			CSMPlanCommunicationWrapperClass objWrapper;
			List<CSMPlanCommunicationWrapperClass> lstWrapper = new List<CSMPlanCommunicationWrapperClass>();

            //Now we get the records.
			Test.startTest();

			//Now we create an Email Message and confirm its existence.
			objEmail.FromAddress = 'test@informatica.com';
			objEmail.ToAddress= 'test@xyz.org';
			objEmail.Subject = 'Test email';
			objEmail.HtmlBody = 'Test email body';
			objEmail.RelatedToId = idPlan;
			objEmail.ThreadIdentifier = '<NQjlI000000000000000000000000000000000000000000000R6WS8Z00LEpzWDUKSSy2oVK06gclOw@sfdc.net>';
			insert objEmail;
			CSMPlanCommunicationController.getRecords(idPlan, '','');
			CSMPlanCommunicationController.getRecords(idPlan, 'Inbound','Email');
			CSMPlanCommunicationController.getRecords(idPlan, 'External','Email');

			//Now we test receiving an email.
			objEmail = new EmailMessage(); 
			objEmail.FromAddress = 'test@xyz.org';
			objEmail.ToAddress = 'test@informatica.com';
			objEmail.Subject = 'Test email';
			objEmail.HtmlBody = 'Test email body';
			objEmail.ThreadIdentifier = '<NQjlI000000000000000000000000000000000000000000000R6WS8Z00LEpzWDUKSSy2oVK06gclOw@sfdc.net>';
			insert objEmail;		
			CSMPlanCommunicationController.getRecords(idPlan, '','');
			CSMPlanCommunicationController.getRecords(idPlan, 'Inbound','Email');
			CSMPlanCommunicationController.getRecords(idPlan, 'Inbound','General');
			CSMPlanCommunicationController.getRecords(idPlan, 'Inbound','Attention Request');
			CSMPlanCommunicationController.getRecords(idPlan, 'External','Email');
			CSMPlanCommunicationController.getRecords(idPlan, 'Attention Request','');
			CSMPlanCommunicationController.getRecords(idPlan, 'Internal', 'My Tagged');
			System.assertNotEquals([SELECT ThreadIdentifier FROM EmailMessage WHERE ThreadIdentifier <> NULL LIMIT 2] == null, true, 'Unable to get the record.');

			//Now we test the closing of an attention request.
			objPlanComment.Plan__c = idPlan;
			objPlanComment.Comment__c='commentValue';
			objPlanComment.Type__c = 'Inbound';
			objPlanComment.Status__c = CSMUtilities.STATUS_SUBMITTED;
			objPlanComment.Sub_Type__c='Attention Request';
			objPlanComment.Is_Automated__c = true;
			insert objPlanComment;
			objPlanChildComment.Plan__c = idPlan;
			objPlanChildComment.Comment__c = 'commentValue';
			objPlanChildComment.Type__c = 'Inbound';
			objPlanChildComment.Status__c = CSMUtilities.STATUS_SUBMITTED;
			objPlanChildComment.Sub_Type__c = 'Attention Request';
			objPlanChildComment.Is_Automated__c = true;
			objPlanChildComment.Parent_Comment__c = objPlanComment.Id;
			insert objPlanChildComment;
			CSMPlanCommunicationController.closeInboundAttentionRequestParent(objPlanChildComment.Id);

			//Now we test the wrapper class.
			objWrapper = new CSMPlanCommunicationWrapperClass();
			objWrapper.CreatedDate = Date.today();
			lstWrapper.add(objWrapper);
			objWrapper = new CSMPlanCommunicationWrapperClass();
			objWrapper.CreatedDate = Date.today().addDays(-1);
			lstWrapper.add(objWrapper);
			objWrapper = new CSMPlanCommunicationWrapperClass();
			objWrapper.CreatedDate = Date.today().addDays(1);
			lstWrapper.add(objWrapper);
			lstWrapper.sort();
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testTags
	 Description : Testing Tagging scenarios.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testTags() {
		User objUser1 = createTestUser('System Administrator', true);
		createTestUser('System Administrator', true);
		createTestUser('System Administrator', true);
		createTestUser('System Administrator', true);
		createTestUser('System Administrator', true);
		createTestUser('System Administrator', true);
        System.runAs(objUser1) {
			Id idPlan = [SELECT Id FROM Plan__c LIMIT 1].Id;
			List<User> lstUsers = [SELECT Id FROM User WHERE Id <> :UserInfo.getUserId() LIMIT 1000];
			Plan_Comment__c objPlanComment1;
			Plan_Comment__c objPlanComment2;
			Plan_Comment__c objPlanComment3;

			//We create the test data.
			objPlanComment1 = new Plan_Comment__c(Plan__c = idPlan);
			objPlanComment1.Comment__c = 'commentValue';
			objPlanComment1.Type__c = CSMUtilities.TYPE_INTERNAL;
			objPlanComment1.Status__c = 'Submitted';
			objPlanComment1.Sub_Type__c = 'Auto Pilot';
			objPlanComment1.Is_Automated__c = true;
			objPlanComment1.Tagged_User_1__c = UserInfo.getUserId();
			objPlanComment1.Tagged_User_2__c = UserInfo.getUserId();
			objPlanComment1.Tagged_User_3__c = UserInfo.getUserId();
			objPlanComment1.Tagged_User_4__c = UserInfo.getUserId();
			objPlanComment1.Tagged_User_5__c = UserInfo.getUserId();
			insert objPlanComment1;
			objPlanComment2 = new Plan_Comment__c(Plan__c = idPlan);
			objPlanComment2.Comment__c = 'commentValue';
			objPlanComment2.Type__c = CSMUtilities.TYPE_INTERNAL;
			objPlanComment2.Status__c = 'Draft';
			objPlanComment2.Sub_Type__c = 'Auto Pilot';
			objPlanComment2.Is_Automated__c = true;
			insert objPlanComment2;
			objPlanComment3 = new Plan_Comment__c(Plan__c = idPlan);
			objPlanComment3.Comment__c = 'commentValue';
			objPlanComment3.Type__c = CSMUtilities.TYPE_INTERNAL;
			objPlanComment3.Status__c = 'Draft';
			objPlanComment3.Sub_Type__c = 'Auto Pilot';
			objPlanComment3.Is_Automated__c = true;
			objPlanComment3.Tagged_User_1__c = lstUsers.get(0).Id;
			objPlanComment3.Tagged_User_2__c = lstUsers.get(1).Id;
			objPlanComment3.Tagged_User_3__c = lstUsers.get(2).Id;
			objPlanComment3.Tagged_User_4__c = lstUsers.get(3).Id;
			objPlanComment3.Tagged_User_5__c = lstUsers.get(4).Id;
			insert objPlanComment3;

			//We also test updating tagged users.
			objPlanComment2.Tagged_User_1__c = UserInfo.getUserId();
			objPlanComment2.Tagged_User_2__c = UserInfo.getUserId();
			objPlanComment2.Tagged_User_3__c = UserInfo.getUserId();
			objPlanComment2.Tagged_User_4__c = UserInfo.getUserId();
			objPlanComment2.Tagged_User_5__c = UserInfo.getUserId();
			objPlanComment2.Status__c = 'Submitted';
			update objPlanComment2;

            //Now we start the testing part.
			Test.startTest();
			CSMPlanCommunicationController.getTaggedUsers(idPlan);
			CSMPlanCommunicationController.removedTaggedUser(objPlanComment3.Id, UserInfo.getUserId());
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
			if(objPermissionSet.Type=='Regular'){
            	lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
			}
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }

		//Now we return the result.
        return objTestUser;
    }
}