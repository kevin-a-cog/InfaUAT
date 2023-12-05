/*
* Name : helpIdeasControllerTest
* Author : Deeksha Shetty
* Created Date : Jan 29,2022
* Description : It is a Common test class for helpIdeasController,helpChangeRequestController and helpInternalIdeaDetails
Change History
**********************************************************************************************************
Modified By       Date            Jira No.                 Description                       Tag
**********************************************************************************************************
Deeksha Shetty    10/02/2022     I2RT- Initial version.                                       N/A
Deeksha Shetty    11/09/2023     I2RT-9054               Change request - enhancement          T1
Deeksha Shetty    25/10/2023     I2RT-9269               CR enhancement on list/tile view -    T2
                                                         Introducing Product/Reported version
                                                        /Fixed version/Current status
*/

@isTest
public class helpIdeasControllerTest {
    
    static testmethod void testmethod1(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Cloud Integration';
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;
            
            List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.Vote__c = 'Upvote';
            cin.IsLiked__c = true;
            cin.User__c = user2.Id;
            comlist.add(cin);
            
            Community_Interactions__c cin2 = new Community_Interactions__c();
            cin2.Id__c = id1.Id;
            cin2.Follow__c = false;
            cin2.Vote__c = 'Downvote';
            cin2.IsLiked__c = false;
            cin2.User__c = user2.Id;
            comlist.add(cin2);            
            insert comlist;
            
            helpIdeasController.ideasDisplay(id1.Id, user2.Id);
            helpIdeasController.addComments(com1.CommentBody,id1.Id);
            helpIdeasController.SaveEditedComment(com1.Id,id1.Id,com1.commentBody);
            helpIdeasController.deleteComment(com1.Id);
            helpIdeasController.showRelatedIdeas(NetworkId, id1.Id);
            helpIdeasController.likeCountUpdate(id1.Id,'IdeaLike','Like',user2.Id);
            helpIdeasController.likeCountUpdate(id1.Id,'IdeaLike','Dislike',user2.Id);
            helpIdeasController.likeCountUpdateforComment(id1.Id,'Dislike');
            helpIdeasController.returnUser(id1.Id,user2.Id);
            helpIdeasController.handleUpvoteCount(id1.Id,user2.Id);
            helpIdeasController.handleDownvoteCount(id1.Id,user2.Id);
            helpIdeasController.handleFollow(id1.Id,'Follow', user2.Id);
            helpIdeasController.handleFollow(id1.Id,'Unfollow', user2.Id);
            helpIdeasController.IdeasLandingDisplay(networkId, user2.Id, 'allIdeas');
            helpIdeasController.sortbyFilterIdeas(networkId, user2.Id, 'Latest', 'allIdeas');
            //helpInternalIdeaDetails.ideasDisplay();
            test.stopTest();
            
        }        
    }
    
    static testmethod void testmethod2(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Cloud Integration';
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;                    
            
            helpIdeasController.likeCountUpdate(id1.Id,'IdeaLike','Like',user2.Id);
            helpIdeasController.likeCountUpdateforComment(id1.Id,'Like');
            helpIdeasController.handleDownvoteCount(id1.Id,user2.Id);
            helpIdeasController.handleFollow(id1.Id,'Follow', user2.Id);
            helpInternalIdeaDetails.ideadisplayOnId(id1.Id);        
            test.stopTest();            
        }        
    }
    
    
    static testmethod void testmethod3(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Cloud Integration';
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;
            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.IsLiked__c = true;
            cin.Vote__c = 'Downvote';
            cin.User__c = user2.Id;
            insert cin;
            
            
            try{
                helpIdeasController.handleUpvoteCount(id1.Id,user2.Id);
                helpIdeasController.getUserType(Userinfo.getUserId());
                helpIdeasController.sortbyFilterIdeas(networkId, user2.Id, 'Latest', 'myIdeas');
                List<String> categorylist = new List<String>{'Cloud Integration','Data Integration'};
                    helpInternalIdeaDetails.createIdea('title',categorylist,'body body');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }            
            test.stopTest();
            
        }        
    }
    
    
    static testmethod void testmethod4(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;                    
            List<String> selectedFilter = new List<String>();
            
            helpIdeasController.likeCountUpdate(id1.Id,'IdeaLike','Like',user2.Id);
            helpIdeasController.handleUpvoteCount(id1.Id,user2.Id);
            helpIdeasController.handleDownvoteCount(id1.Id,user2.Id);
            helpIdeasController.handleFollow(id1.Id,'Follow', user2.Id);
            helpChangeRequestController.CRTsLandingDisplay(NetworkId,user2.Id,'allIdeas', null);
            try{
                helpChangeRequestController.CRTsLandingDisplay('',user2.Id,'allIdeas', null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.sortbyFilterCRTs(NetworkId,user2.Id,'Latest','allCrs', null, selectedFilter);
                helpChangeRequestController.sortbyFilterCRTs(NetworkId,user2.Id,'Old','allCrs', null, selectedFilter);                
            }
            catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            try{
                helpChangeRequestController.sortbyFilterCRTs('',null,'','', null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod5(){
        test.startTest();
        try{
            String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
            Test.setMock(HttpCalloutMock.class, new helpIdeasCalloutMock());
            String token = 'ancd1234';
            helpIdeasController.recommendedIdeasDisplay(networkId,token);
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
    static testmethod void testmethod6(){
        test.startTest();
        try{
            String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
            Test.setMock(HttpCalloutMock.class, new helpIdeasCalloutMock());
            String token = 'ancd1234';
            helpIdeasController.sortRecommendedIdeas(networkId,'Latest',token);
        }
        Catch(Exception ex){} 
        test.stopTest();
    }
    
    
    static testmethod void testmethod7(){                              
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
        id1.Status = 'New';
        id1.Categories = 'Cloud Integration';
        insert id1;
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'commnt commnt commnt commnt';
        insert com1;
        
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = id1.Id;
        cin.Follow__c = true;
        cin.IsLiked__c = true;
        cin.Vote__c = 'Downvote';
        cin.User__c = userinfo.getUserId();
        insert cin;
        
        test.startTest();            
        helpIdeasController.handleUpvoteCount(id1.Id,userinfo.getUserId());
        Topic tp = new Topic (Name='XYZ');
        insert tp;
        helpInternalIdeaDetails.getSelectedIdea(tp.Id);
        helpInternalIdeaDetails.fetchFilterValues();
        test.stopTest();
        
    }
    
    
    static testmethod void testmethod8(){                
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;
            
            List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.Vote__c = 'Upvote';
            cin.IsLiked__c = true;
            cin.User__c = user2.Id;
            comlist.add(cin);
            
            Community_Interactions__c cin2 = new Community_Interactions__c();
            cin2.Id__c = id1.Id;
            cin2.Follow__c = false;
            cin2.Vote__c = 'Downvote';
            cin2.IsLiked__c = false;
            cin2.User__c = user2.Id;
            comlist.add(cin2);            
            insert comlist;
            
            helpIdeasController.handleUpvoteCount(id1.Id,user2.Id);       
            test.stopTest();
            
        }        
    }
    
    static testmethod void testmethod9(){        
        test.startTest();
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
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;
            
            List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.Vote__c = 'Upvote';
            cin.IsLiked__c = true;
            cin.User__c = user2.Id;
            comlist.add(cin);
            
            Community_Interactions__c cin2 = new Community_Interactions__c();
            cin2.Id__c = id1.Id;
            cin2.Follow__c = false;
            cin2.Vote__c = 'Downvote';
            cin2.IsLiked__c = false;
            cin2.User__c = user2.Id;
            comlist.add(cin2);            
            insert comlist;
            
            helpIdeasController.handleDownvoteCount(id1.Id,user2.Id);       
            test.stopTest();
            
        }        
    }
    
    static testmethod void testmethod10(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Cloud Integration';
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;
            
            List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.Vote__c = 'Upvote';
            cin.IsLiked__c = true;
            cin.User__c = user2.Id;
            comlist.add(cin);
            
            Community_Interactions__c cin2 = new Community_Interactions__c();
            cin2.Id__c = id1.Id;
            cin2.Follow__c = false;
            cin2.Vote__c = 'Downvote';
            cin2.IsLiked__c = false;
            cin2.User__c = user2.Id;
            comlist.add(cin2);            
            insert comlist;
            
            
            helpIdeasController.handleDownvoteCount(id1.Id,user2.Id);
            helpIdeasController.IdeasLandingDisplay(networkId, user2.Id, 'myideas');
            helpIdeasController.sortbyFilterIdeas(networkId, user2.Id, 'Latest', 'myideas');            
            test.stopTest();
            
        }        
    }
    
    
    
    static testmethod void testmethod11(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'commnt commnt commnt commnt';
            insert com1;                    
            
            List<String> selectedFilter = new List<String>();
            
            helpChangeRequestController.getmetadatarecords();            
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'mySupportAccountideas', null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    
    static testmethod void testmethod14(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Latest','myCrs',null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod19(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Old','myCrs',null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod16(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Latest','mySupportAccountideas','dummytoken', selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod18(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            Test.setMock(HttpCalloutMock.class, new helpIdeasCalloutMock());
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Old','mySupportAccountideas','dummytoken', selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
        }
        test.stopTest();        
    }
    static testmethod void testmethod141(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            selectedFilter.add('Latest');                      
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Latest','myCrs',null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    static testmethod void testmethod142(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            selectedFilter.add('Latest');
            
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Latest','allCrs',null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    static testmethod void testmethod143(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration';//T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            selectedFilter.add('Latest');
            
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Old','allCrs',null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod191(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            selectedFilter.add('Latest');
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Old','myCrs',null, selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod161(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            selectedFilter.add('Latest');
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Latest','mySupportAccountideas','dummytoken', selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    
    static testmethod void testmethod181(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        test.startTest();
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
        
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();
            selectedFilter.add('Latest');
            
            try{
                helpChangeRequestController.sortbyFilterCRTs(networkId,user2.Id,'Old','mySupportAccountideas','dummytoken', selectedFilter);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpChangeRequestController.CRTsLandingDisplay(networkId,user2.Id,'myideas', null); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    static testmethod void testgetSearchedCRs(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        test.startTest();
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
            
            try{
                helpChangeRequestController.getSearchedCRs('Test', networkId);
                helpChangeRequestController.getSearchedCRs('', null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();            
        }        
    }
    static testmethod void testmethod12(){
        
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
        id1.Status = 'Draft';
        id1.Categories = 'Cloud Integration';
        insert id1;
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'commnt commnt commnt commnt';
        insert com1;
        
        List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = id1.Id;
        cin.Follow__c = true;
        cin.Vote__c = 'Upvote';
        cin.IsLiked__c = true;
        cin.User__c = userinfo.getUserId();
        comlist.add(cin);                  
        insert comlist;
        
        test.startTest();
        helpIdeasController.IdeasLandingDisplay(networkId, userinfo.getUserId(), 'myideas');
        test.stopTest();
        
    }
    
    static testmethod void testmethod13(){
        
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
        id1.Status = 'Draft';
        id1.Categories = 'Cloud Integration';
        insert id1;
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'commnt commnt commnt commnt';
        insert com1;
        
        List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = id1.Id;
        cin.Follow__c = true;
        cin.Vote__c = 'Upvote';
        cin.IsLiked__c = true;
        cin.User__c = userinfo.getUserId();
        comlist.add(cin);                  
        insert comlist;
        
        test.startTest();
        helpIdeasController.sortbyFilterIdeas(networkId,userinfo.getUserId(), 'Latest', 'myideas'); 
        test.stopTest();                
    }
    
    static testmethod void testmethod15(){
        test.startTest();
        try{
            String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
            Test.setMock(HttpCalloutMock.class, new helpIdeasCalloutMock());
            String token = 'ancd1234';
            helpIdeasController.sortRecommendedIdeas(networkId,'Old',token);
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
    static testmethod void testmethod17(){       
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Community communityinfo =[SELECT Id,Name FROM Community where NetworkId =:NetworkId];
        Id communityid = communityinfo.Id;
        
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
        id1.Status = 'New';
        id1.Categories = 'Change Request;Cloud Integration'; //T2
        id1.CommunityId = communityid;
        insert id1;
        
        
        List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = id1.Id;
        cin.Follow__c = true;
        cin.Vote__c = 'Upvote';
        cin.IsLiked__c = true;
        cin.User__c = userinfo.getUserId();
        comlist.add(cin);
        
        Community_Interactions__c cin2 = new Community_Interactions__c();
        cin2.Id__c = id1.Id;
        cin2.Follow__c = false;
        cin2.Vote__c = 'Downvote';
        cin2.IsLiked__c = false;
        cin2.User__c = userinfo.getUserId();
        comlist.add(cin2);            
        insert comlist;
        
        test.startTest();
        helpIdeasController.showRelatedIdeas(networkId, id1.Id);
        helpInternalIdeaDetails.ideasDisplay();
        test.stopTest();
        
    }
    
    //T1 - test method to cover getSupportAccNamesCoveo
    static testmethod void testmethod20(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        test.startTest();
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
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Idea id1 = new Idea();
            id1.Title = 'Testt idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'Draft';
            id1.Categories = 'Change Request;Cloud Integration'; //T2
            insert id1;
            
            List<String> selectedFilter = new List<String>();            
            
            try{
                Test.setMock(HttpCalloutMock.class, new helpIdeasCalloutMock());
                helpChangeRequestController.getSupportAccNamesCoveo(null);
            }
            catch(Exception ex ){}
            
        }
        test.stopTest();        
    }
    
}