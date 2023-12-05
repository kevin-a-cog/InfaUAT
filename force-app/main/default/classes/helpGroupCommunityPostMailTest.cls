/*
* Name         :   helpGroupCommunityPostMailTest
* Author       :   Saumya Gaikwad
* Created Date :   09-AUG-2022
* Description  :   Test class for helpGroupCommunityPostMail class.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Saumya Gaikwad        09-AUG-2022      I2RT-6640         Initial version.                                             NA         
*/
@IsTest
public class helpGroupCommunityPostMailTest {
    static testmethod void getSendMail(){
        List<string> userIdList = new list<String>();
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        CollaborationGroup grp= new CollaborationGroup();
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
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
            
            User user = new User();
            user.FirstName = 'Test2';
            user.LastName = 'Test2';
            user.Alias = 'Test2';
            user.Email = 'email@email.com';
            user.UserName = 'email@email.com';
            user.EmailEncodingKey = 'UTF-8';
            user.LanguageLocaleKey = 'en_US';
            user.LocaleSidKey = 'en_US';
            user.TimezoneSidKey = 'America/Los_Angeles';
            user.ContactId = contact.Id; 
            user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'External Identity Community'].Id;
            //user.UserRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1].Id;
            insert user;
            
            grp.Name='testabc';
            grp.NetworkId=networkId;
            grp.Description='abcd';
            grp.CollaborationType = 'Public';
            insert grp;
            
            CollaborationGroupMember grpmem=new CollaborationGroupMember();
            grpmem.MemberId=user.Id;
            grpmem.CollaborationGroupId=grp.id;
            insert grpmem;
            
            userIdList.add(user.Id);
        }   
        List<helpGroupCommunityPostMail.EmailDetailsWrapper> GrpWrap = new List<helpGroupCommunityPostMail.EmailDetailsWrapper>();
        helpGroupCommunityPostMail.EmailDetailsWrapper GrpWrap1 = new helpGroupCommunityPostMail.EmailDetailsWrapper();
        GrpWrap1.UGId = grp.Id;
        GrpWrap1.Subject = '';
        GrpWrap1.networkscope = networkId;
        GrpWrap1.isDiscussionCreated = false;
        GrpWrap.add(GrpWrap1);
        
        try{
            Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
            helpGroupCommunityPostMail.getParamsFromFlow(GrpWrap);
        }catch(Exception ex ){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
    
    
    static testmethod void getSendMail2(){
        List<string> userIdList = new list<String>();
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
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
            
            User user = new User();
            user.FirstName = 'Test2';
            user.LastName = 'Test2';
            user.Alias = 'Test2';
            user.Email = 'email@email.com';
            user.UserName = 'email@email.com';
            user.EmailEncodingKey = 'UTF-8';
            user.LanguageLocaleKey = 'en_US';
            user.LocaleSidKey = 'en_US';
            user.TimezoneSidKey = 'America/Los_Angeles';
            user.ContactId = contact.Id; 
            user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'External Identity Community'].Id;
            //user.UserRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1].Id;
            insert user;
            userIdList.add(user.Id);
        }
        
        Topic a = new Topic(Name='cloud test integration',NetworkId=networkId,Description='abcd');
        insert a;
        
        List<helpGroupCommunityPostMail.EmailDetailsWrapper> GrpWrap = new List<helpGroupCommunityPostMail.EmailDetailsWrapper>();
        helpGroupCommunityPostMail.EmailDetailsWrapper GrpWrap1 = new helpGroupCommunityPostMail.EmailDetailsWrapper();
        GrpWrap1.TopicId = a.Id;
        GrpWrap1.Subject = '';
        GrpWrap1.networkscope = networkId;
        GrpWrap1.isDiscussionCreated = true;
        GrpWrap.add(GrpWrap1);
        
        try{
            Test.setMock(HttpCalloutMock.class, new INSendGridCalloutMock());
            helpGroupCommunityPostMail.getParamsFromFlow(GrpWrap);
        }catch(Exception ex ){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }
    
    /*static testmethod void getSendMailCatch(){
        List<helpGroupCommunityPostMail.EmailDetailsWrapper> GrpWrap = new List<helpGroupCommunityPostMail.EmailDetailsWrapper>();
        helpGroupCommunityPostMail.EmailDetailsWrapper GrpWrap1 = new helpGroupCommunityPostMail.EmailDetailsWrapper();
        GrpWrap1.UserIdList = null;
        GrpWrap1.Body = '';
        GrpWrap1.Subject = '';
        GrpWrap.add(GrpWrap1);
        try{
            helpGroupCommunityPostMail.sendMailToMembers(GrpWrap);
        }catch(Exception ex ){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }*/
}