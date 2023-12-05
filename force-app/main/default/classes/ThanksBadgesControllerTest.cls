/*
* Name			:	ThanksBadgesControllerTest
* Author		:	Deva M
* Created Date	: 	28/09/2021
* Description	:	Test class for ThanksBadgesController

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				28/09/2021		N/A				Initial version.			N/A
*/
@isTest
public class ThanksBadgesControllerTest {
    @testSetup
    static void setupObjectTestData() {
        id userId=UserInfo.getUserId();
        Profile prof=[SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = new User(Alias = 'sys', Email='systemadmin@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='sysadmintest234test@sstest.com');
        System.runAs(usr) {
            Document document;
            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'image/png';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = 'My Document';
            document.FolderId = [select id from folder where name = 'DocuSign Images'].id;
            insert document;
            WorkBadgeDefinition  wrkDef=new WorkBadgeDefinition();
            wrkDef.Name             = 'Test Badge';
            wrkDef.Description     = 'Test Badge';
            wrkDef.ImageUrl        = '/servlet/servlet.FileDownload?file='+document.Id; 
            wrkDef.IsActive         = True;
            Insert wrkDef;
            
            WorkThanks  wrkThanks  = new WorkThanks();
            wrkThanks.GiverId       = UserInfo.getUserId();
            wrkThanks.Message    = 'Test Thanks';
            wrkThanks.OwnerId     = UserInfo.getUserId();
            Insert wrkThanks;
            
            WorkBadge  wrkBadge = new WorkBadge ();
            wrkBadge.DefinitionId     = wrkDef.Id;
            wrkBadge.RecipientId      = userId;
            wrkBadge.SourceId         = wrkThanks.Id;
            Insert wrkBadge;
        }
    }
    
    @isTest
    public static void fgetAllBadgesGivenToMeTest() {
        ThanksBadgesController.getAllBadgesGivenToMe([Select Id from user where  UserName='sysadmintest234test@sstest.com'].Id);
    }
}