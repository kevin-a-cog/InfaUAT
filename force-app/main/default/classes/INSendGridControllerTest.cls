/*
* Name			:	INSendGridControllerTest
* Author		:	Deeksha Shetty
* Created Date	: 	21 Nov 2022
* Description	:	Test class for INSendGridController
Change History
********************************************************************************************************************************
Modified By			Date			Jira No.		Description					                               Tag
********************************************************************************************************************************
Deeksha Shetty		21/11/2022		    N/A				Initial version.			                                N/A
Deeksha Shetty      18/04/2023         I2RT-7440        Product community: New discussion notification email         1
Prashanth Bhat      09-08-2023         I2RT-9050        SendGrid IN Wrapper related data addition                    2
*/

@isTest
public class INSendGridControllerTest {
    
    static testmethod void test_sendEmailOnExternalEvents(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'testemail@infa.com';
        adminUser.UserName = 'testemail@infa.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId =[Select Id From UserRole Where DeveloperName = 'WW_Sales_EVP' Limit 1].Id;     
        insert adminUser;
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {            
            Account a = new Account();
            a.Name = 'Test Account';
            a.BillingCountry='USA';
            insert a;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = a.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'testemail2@infa.com';
            user2.UserName = 'testemail2@infa.com';
            user2.EmailEncodingKey = 'UTF-8';
            user2.LanguageLocaleKey = 'en_US';
            user2.LocaleSidKey = 'en_US';
            user2.TimezoneSidKey = 'America/Los_Angeles';
            user2.ContactId = contact.Id;
            user2.ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Customer Community Plus User'
            ].Id;
            
            insert user2;
            
            
            Event e = new Event();        
            e.Description = 'Test event';
            e.StartDateTime=system.today();
            e.EndDateTime=system.today()+5;
            e.ActivityDate = System.today();
            e.Type='Meeting';
            e.Event_Type__c = 'External';
            e.Subject = 'Lorem ipsiuk jsddhjdhj';
            e.IsVisibleInSelfService = true;       
            insert e;
            
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = user2.Id;
            com.Type__c = 'Event';
            com.follow__c =true;
            insert com;
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            list<account> acc = [select id,name from account limit 1];
            SendGridWrapper.Dynamictemplate objWrapper = new SendGridWrapper.Dynamictemplate();
            objWrapper.name = 'test case';
            objWrapper.casenumber= 'CS123345';
            objWrapper.EngineerName= 'test Eng Name';
            objWrapper.todaydate = system.today();
            objWrapper.emailbody = 'test Email body';
            objWrapper.timezone = 'US';
            objWrapper.subject = 'test Sub';
            objWrapper.priority = 'p3';
            objWrapper.product = 'test grid';
            objWrapper.sendersignature = 'test grid';
            objWrapper.accname = acc[0].name;
            objWrapper.primaryname = 'test primary name';
            objWrapper.responsetime = 'test res time';
            objWrapper.viewcaseurl = 'test view url';
            objWrapper.esupporturl = 'test eurl';
            objWrapper.acceptsolution = 'no';
            objWrapper.declinesolution = 'yes';
            objWrapper.needmoretime = 'no';
            objWrapper.version = '57.0';
            objWrapper.successoffering = 'test offering';
            objWrapper.sessiondetails = 'test details';
            objWrapper.productarea = 'test area';
            objWrapper.isaae = true;
            objWrapper.casetype = 'Email';
            objWrapper.showprodversion = false;            
            objWrapper.salutation = 'hi';
            objWrapper.primaryconname = 'test';
            objWrapper.alternatecontacts = 'test';
            objWrapper.showaccept = false;
            objWrapper.aaebooked = false;
            objWrapper.aaedelivered = false;
            objWrapper.aaecancelled = false;
            objWrapper.isnew = false;
            objWrapper.isassess = false;
            objWrapper.isclosed = false;
            objWrapper.isresearch = false;
            objWrapper.issolution = false;
            
            objWrapper.boolHasProfilePicture = false;
            objWrapper.boolIsStage1 = false;
            objWrapper.boolIsStage2 = false;
            objWrapper.boolIsStage3 = false;
            objWrapper.boolIsStage4 = false;
            
            objWrapper.strPlanComment = 'test';
            objWrapper.strPlanName = 'test';
            objWrapper.strAccountName = 'test';
            objWrapper.strPlanStage = 'test';
            objWrapper.strCSMPhotoURL = 'test';
            objWrapper.strCSMEmail = 'test';
            objWrapper.strCSMPhone = 'test';
            objWrapper.strMilestoneDescription = 'test';
            objWrapper.strMilestoneDueDate = 'test';
            objWrapper.strPlanCommentDate = 'test';
            objWrapper.strCSMName = 'test';
            objWrapper.strPlanURL = 'test';
            objWrapper.strRefId = 'test';
            objWrapper.strPlanOwnerName = 'test';
            
            test.startTest();         
            try{
                Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
                INSendGridController.sendEmailOnExternalEvents(e.Id);
            }
            Catch(Exception ex){}
            test.stopTest();
            
        }       
    }
    
    /* Tag 1 starts*/
    
    static testmethod void test_sendMailOnFeedCreationOrUpdation(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'testemail@infa.com';
        adminUser.UserName = 'testemail@infa.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId =[Select Id From UserRole Where DeveloperName = 'WW_Sales_EVP' Limit 1].Id;     
        insert adminUser;
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {            
            Account a = new Account();
            a.Name = 'Test Account';
            a.BillingCountry='USA';
            insert a;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = a.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'testemail2@infa.com';
            user2.UserName = 'testemail2@infa.com';
            user2.EmailEncodingKey = 'UTF-8';
            user2.LanguageLocaleKey = 'en_US';
            user2.LocaleSidKey = 'en_US';
            user2.TimezoneSidKey = 'America/Los_Angeles';
            user2.ContactId = contact.Id;
            user2.ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Customer Community Plus User'
            ].Id;
            
            insert user2;
            
            Topic tp = new Topic(Name='testxyz978',
                            NetworkId=networkId,
                            Description='abcd');
            insert tp;
            
            
            FeedItem feedData = new FeedItem();
            feedData.Title='title';
            feedData.ParentId=tp.Id;
            feedData.Body= 'body comment';
            feedData.NetworkScope=networkId;
            feedData.Type='QuestionPost';
            feedData.IsRichText=true;
            insert feedData;
            
            //Tag 2 Start
            ContentVersion objContentVersion = new ContentVersion(Title = 'Test Document',PathOnClient = 'TestDocument.pdf',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert objContentVersion;
            
            FeedAttachment feedAttach = new FeedAttachment(FeedEntityId = feedData.Id,Type = 'Content',RecordId = objContentVersion.Id);
            insert feedAttach;
            //Tag 2 End
            
            list<account> acc = [select id,name from account limit 1];
            SendGridINWrapper.Dynamictemplate objWrapper = new SendGridINWrapper.Dynamictemplate();
            //Tag 2 Start
            objWrapper.TopicOrUsrGrpName = 'ActiveVOS';
            objWrapper.DiscussionTitle = 'Test Question 12';
            objWrapper.DiscussionDesc = '<p>Test Description123</p>' ;
            objWrapper.DiscussionCreator = 'Pras.Bhat_64';
            objWrapper.DiscussionLink = 'https://infa--prashanthb.sandbox.my.site.com/informaticaNetwork/s/question/0D58N00000IVAYESA5';
            objWrapper.CreatorLink = 'https://infa--prashanthb.sandbox.my.site.com/informaticaNetwork/s/profile/0056S00000FMu4lQAD';
            objWrapper.DisSubject = 'New: [ActiveVOS] - Test Question 123';
            objWrapper.ProductOrUGLink = 'https://infa--prashanthb.sandbox.my.site.com/informaticaNetwork/s/topiccatalog';
            objWrapper.KBURL = 'https://knowledge.informatica.com' ;
            objWrapper.SuccessURL = 'https://success.informatica.com' ;
            objWrapper.isDiscussionCreated = true;
            objWrapper.currentYear = System.Today().year();
            //Tag 2 End
            test.startTest();         
            try{
                Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
                INSendGridController.sendMailOnFeedCreationOrUpdation(feedData.Id,null,tp.id,'https://network.informatica.com',
                                                                      'subject',true,'ActiveVOS',feedData.title, feedData.Body,'testuser',
                                                                      'https://network.informatica.com/s/topiccatalog',
                                                                      'https://network.informatica.com/s',false);
            }
            Catch(Exception ex){}
            test.stopTest();
            
        }
        
    }
    
    
    static testmethod void test_sendMailOnFeedCreationOrUpdation2(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'testemail@infa.com';
        adminUser.UserName = 'testemail@infa.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId =[Select Id From UserRole Where DeveloperName = 'WW_Sales_EVP' Limit 1].Id;     
        insert adminUser;
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {            
            Account a = new Account();
            a.Name = 'Test Account';
            a.BillingCountry='USA';
            insert a;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = a.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'testemail2@infa.com';
            user2.UserName = 'testemail2@infa.com';
            user2.EmailEncodingKey = 'UTF-8';
            user2.LanguageLocaleKey = 'en_US';
            user2.LocaleSidKey = 'en_US';
            user2.TimezoneSidKey = 'America/Los_Angeles';
            user2.ContactId = contact.Id;
            user2.ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Customer Community Plus User'
            ].Id;
            
            insert user2;
            
            CollaborationGroup grp= new CollaborationGroup();
            grp.Name='testabc';
            grp.NetworkId=networkId;
            grp.Description='abcd';
            grp.CollaborationType = 'Public';
            insert grp;
            
            CollaborationGroupMember grpmem=new CollaborationGroupMember();
            grpmem.MemberId=user2.id;
            grpmem.CollaborationGroupId=grp.id;
            insert grpmem;
            
            
            FeedItem feedData = new FeedItem();
            feedData.Title='title';
            feedData.ParentId=grp.Id;
            feedData.Body= 'body comment';
            feedData.NetworkScope=networkId;
            feedData.Type='QuestionPost';
            feedData.IsRichText=true;
            insert feedData;
            
            list<account> acc = [select id,name from account limit 1];
            SendGridWrapper.Dynamictemplate objWrapper = new SendGridWrapper.Dynamictemplate();
            objWrapper.name = 'test case';
            objWrapper.casenumber= 'CS123345';
            objWrapper.EngineerName= 'test Eng Name';
            objWrapper.todaydate = system.today();
            objWrapper.emailbody = 'test Email body';
            objWrapper.timezone = 'US';
            objWrapper.subject = 'test Sub';
            objWrapper.priority = 'p3';
            objWrapper.product = 'test grid';
            objWrapper.sendersignature = 'test grid';
            objWrapper.accname = acc[0].name;
            objWrapper.primaryname = 'test primary name';
            objWrapper.responsetime = 'test res time';
            objWrapper.viewcaseurl = 'test view url';
            objWrapper.esupporturl = 'test eurl';
            objWrapper.acceptsolution = 'no';
            objWrapper.declinesolution = 'yes';
            objWrapper.needmoretime = 'no';
            objWrapper.version = '57.0';
            objWrapper.successoffering = 'test offering';
            objWrapper.sessiondetails = 'test details';
            objWrapper.productarea = 'test area';
            objWrapper.isaae = true;
            objWrapper.casetype = 'Email';
            objWrapper.showprodversion = false;            
            objWrapper.salutation = 'hi';
            objWrapper.primaryconname = 'test';
            objWrapper.alternatecontacts = 'test';
            objWrapper.showaccept = false;
            objWrapper.aaebooked = false;
            objWrapper.aaedelivered = false;
            objWrapper.aaecancelled = false;
            objWrapper.isnew = false;
            objWrapper.isassess = false;
            objWrapper.isclosed = false;
            objWrapper.isresearch = false;
            objWrapper.issolution = false;
            
            objWrapper.boolHasProfilePicture = false;
            objWrapper.boolIsStage1 = false;
            objWrapper.boolIsStage2 = false;
            objWrapper.boolIsStage3 = false;
            objWrapper.boolIsStage4 = false;
            
            objWrapper.strPlanComment = 'test';
            objWrapper.strPlanName = 'test';
            objWrapper.strAccountName = 'test';
            objWrapper.strPlanStage = 'test';
            objWrapper.strCSMPhotoURL = 'test';
            objWrapper.strCSMEmail = 'test';
            objWrapper.strCSMPhone = 'test';
            objWrapper.strMilestoneDescription = 'test';
            objWrapper.strMilestoneDueDate = 'test';
            objWrapper.strPlanCommentDate = 'test';
            objWrapper.strCSMName = 'test';
            objWrapper.strPlanURL = 'test';
            objWrapper.strRefId = 'test';
            objWrapper.strPlanOwnerName = 'test';
            
            test.startTest();         
            try{
                Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
                INSendGridController.sendMailOnFeedCreationOrUpdation(feedData.Id,grp.Id,null,'https://network.informatica.com/s/topiccatalog',
                                                                      'subject',true,'ActiveVOS',feedData.title, feedData.Body,'testuser',
                                                                      'https://network.informatica.com/s/topiccatalog',
                                                                      'https://network.informatica.com/s',false);
            }
            Catch(Exception ex){}
            test.stopTest();
            
        }
        
    }
    /* Tag 1 ends*/
    
}