/*
 * Name			:	GlobalCustomChatterTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/29/2022
 * Description	:	Custom Chatter test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/29/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalCustomChatterTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		Id idContentDocument;

		//Now we create an Account.
		Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'US';
		insert objAccount;

        //Now we create a Contact.
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
		objContact.AccountId = objAccount.Id;
        insert objContact;

		//Now we create a Content Version.
		ContentVersion objContentVersion = new ContentVersion();
		objContentVersion.Title = 'Test';
		objContentVersion.PathOnClient = 'test';
		objContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
		insert objContentVersion;

		//Now we query the Content Document Id.
		idContentDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id LIMIT 1].Id;

		//Now we create a Feed Item.
		FeedItem objFeedItem = new FeedItem();
        objFeedItem.Body = 'legal /' + objAccount.Id + ' /' + objContact.Id + ' src="sfdc://' + idContentDocument + '"';
        objFeedItem.ParentID = objContact.Id;
		insert objFeedItem;
 
		//Create a Feed Comment.
		FeedComment objFeedComment = new FeedComment();
		objFeedComment.FeedItemId = objFeedItem.Id;
		objFeedComment.CommentBody = 'Test Comment /' + objAccount.Id + ' /' + objContact.Id + ' /' + objFeedItem.Id + ' src="sfdc://' + idContentDocument + '"';
		insert objFeedComment;
		objFeedComment = new FeedComment();
		objFeedComment.FeedItemId = objFeedItem.Id;
		objFeedComment.RelatedRecordId = objContentVersion.Id;
		objFeedComment.CommentType = 'ContentComment';
		objFeedComment.CommentBody = 'Test Comment /' + objAccount.Id + ' /' + objContact.Id + ' /' + objFeedItem.Id + ' src="sfdc://' + idContentDocument + '"';
		insert objFeedComment;

		//Now we create Feed Item Attachment.
		FeedAttachment objFeedAttachment = new FeedAttachment();
		objFeedAttachment.FeedEntityId = objFeedItem.Id;
		objFeedAttachment.RecordId = objContentVersion.Id;
		objFeedAttachment.Type = 'Content';
		insert objFeedAttachment;
    }
	
	/*
	 Method Name : testFetchingRecords
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFetchingRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			Boolean boolValue;
			Integer intValue;
			String strValue;
			ConnectApi.TextSegment objText;
			ConnectApi.EntityLinkSegment objLink;
			ConnectApi.MarkupBeginSegment objLineBegin;
			ConnectApi.MarkupEndSegment objLineEnd;
			GlobalCustomChatterWrapperClass objWrapper = new GlobalCustomChatterWrapperClass();
			GlobalCustomChatterWrapperClass.AttachmentWrapperClass objAttachment = new GlobalCustomChatterWrapperClass.AttachmentWrapperClass();
			List<String> lstFieldPaths = new List<String>();
			List<String> lstQueries = new List<String>();

			//We set the values.
			lstFieldPaths.add('Account.Id');
			lstQueries.add('SELECT Id FROM Contact WHERE AccountId = {recordId}');

			//We test the wrapper class.
			objAttachment.idContentVersion = [SELECT Id FROM User LIMIT 1].Id;
			strValue = objAttachment.strURL;
			objWrapper.lstAttachments = new List<GlobalCustomChatterWrapperClass.AttachmentWrapperClass>();
			objWrapper.lstAttachments.add(new GlobalCustomChatterWrapperClass.AttachmentWrapperClass());
			objWrapper.lstAttachments.add(new GlobalCustomChatterWrapperClass.AttachmentWrapperClass());
			objWrapper.lstAttachments.add(new GlobalCustomChatterWrapperClass.AttachmentWrapperClass());
			objWrapper.lstAttachments.add(new GlobalCustomChatterWrapperClass.AttachmentWrapperClass());
			objAttachment = objWrapper.objThirdAttachment;
			intValue = objWrapper.intExtraAttachments;
			objWrapper.lstReplies = new List<GlobalCustomChatterWrapperClass>();
			objWrapper.lstReplies.add(new GlobalCustomChatterWrapperClass());
			objWrapper.lstReplies.add(new GlobalCustomChatterWrapperClass());
			boolValue = objWrapper.boolHasMoreThant3Attachments;
			boolValue = objWrapper.boolHasMoreThanOneReply;
			strValue = objWrapper.strAttachmentIds;

			//We test the ConnectAPI.
			objText = new ConnectApi.TextSegment();
			objText.text = 'Test';
			GlobalCustomChatterController.processBody(objText);
			objText.text = 'Test\n';
			GlobalCustomChatterController.processBody(objText);
			objLink = new ConnectApi.EntityLinkSegment();
			objLink.reference = new ConnectApi.Reference();
			GlobalCustomChatterController.processBody(objLink);
			objLineBegin = new ConnectApi.MarkupBeginSegment();
			objLineBegin.htmlTag = 'a';
			GlobalCustomChatterController.processBody(objLineBegin);
			objLineEnd = new ConnectApi.MarkupEndSegment();
			objLineEnd.htmlTag = 'a';
			GlobalCustomChatterController.processBody(objLineEnd);

            //Now we get the records.
			Test.startTest();
            System.assertNotEquals(GlobalCustomChatterController.getFeeds(true, [SELECT Id FROM Account LIMIT 1].Id, null, lstQueries) == null, true, 'Unable to get records.');
			System.assertNotEquals(GlobalCustomChatterController.getFeeds(true, [SELECT Id FROM Contact LIMIT 1].Id, lstFieldPaths, null) == null, true, 'Unable to get records.');
			System.assertNotEquals(GlobalCustomChatterController.getFeeds(true, [SELECT Id FROM Contact LIMIT 1].Id, lstFieldPaths, lstQueries) == null, true, 'Unable to get records.');
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
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet objPermissionSet :[SELECT Id,Type FROM PermissionSet WHERE Name LIKE 'CSM_Success%']) {
			if(objPermissionSet.Type=='Regular'){
            	PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id);
            	psAssignList.add(psAssign);
			}
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}