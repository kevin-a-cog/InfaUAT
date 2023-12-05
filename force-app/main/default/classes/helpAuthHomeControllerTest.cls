@isTest
public class helpAuthHomeControllerTest {
    
    static testmethod void testmethod1(){
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
            
            List<Idea> idealist = new List<Idea>();                 
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum1';
            id1.Status = 'New';
            id1.Categories = 'Cloud Integration;Data Integration';
            id1.Upvote_Count__c = 5;
            idealist.add(id1);
            
            Idea id2 = new Idea();
            id2.Title = 'new idea2';
            id2.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id2.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum2';
            id2.Status = 'New';
            id2.Upvote_Count__c = 5;
            id2.Categories = 'Data Integration';
            idealist.add(id2);
            
            Idea id3 = new Idea();
            id3.Title = 'new idea3';
            id3.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id3.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum3';
            id3.Status = 'New';
            id3.Upvote_Count__c = 5;
            id3.Categories = 'Data Integration';
            idealist.add(id3);
            
            Idea id4 = new Idea();
            id4.Title = 'new idea4';
            id4.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id4.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsummm4';
            id4.Status = 'New';
            id4.Upvote_Count__c = 5;
            id4.Categories = 'Data Integration';
            idealist.add(id4);
            
            insert idealist;
            
            
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
           
            test.startTest();
            helpAuthHomeController.ideasDisplay(NetworkId, userinfo.getUserId());            
            test.stopTest();
            
        }        
    }
    
    static testmethod void testmethod2(){
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
            
            List<Idea> idealist = new List<Idea>();                 
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum1';
            id1.Status = 'New';
            id1.Upvote_Count__c = 5;
            id1.Categories = 'Cloud Integration';
            idealist.add(id1);
                        
            insert idealist;           
            
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
           
            test.startTest();
            helpAuthHomeController.ideasDisplay(NetworkId, userinfo.getUserId());            
            test.stopTest();
            
        }        
    }
    
    
    static testmethod void testmethod3(){
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
            
            topic tp = new Topic();
            tp.Name = 'XYZ';
            insert tp;
            
            EntitySubscription entiti = new EntitySubscription();
            entiti.NetworkId = NetworkId;
            entiti.ParentId = tp.Id;
            entiti.SubscriberId = user2.Id;
            insert entiti;

                                              
            test.startTest();
            helpAuthHomeController.ideasDisplay(NetworkId, user2.Id);            
            test.stopTest();
            
        }        
    }
    
    static testmethod void testmethod4(){
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
        }
        System.runAs(user2){
            List<Idea> idealist = new List<Idea>();                 
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum1';
            id1.Status = 'New';
            id1.Upvote_Count__c = 5;
            id1.Categories = 'Cloud Integration;Data Integration';
            idealist.add(id1);
            
            Idea id2 = new Idea();
            id2.Title = 'new idea2';
            id2.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id2.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum2';
            id2.Status = 'New';
            id2.Upvote_Count__c = 5;
            id2.Categories = 'Data Integration';
            idealist.add(id2);
        
            insert idealist;
            
         
            List<Community_Interactions__c> comlist = new List<Community_Interactions__c>();            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.Vote__c = 'Upvote';
            cin.IsLiked__c = true;
            cin.User__c = user2.Id;
            comlist.add(cin);
            
            Community_Interactions__c cin2 = new Community_Interactions__c();
            cin2.Id__c = id2.Id;
            cin2.Follow__c = false;
            cin2.Vote__c = 'Downvote';
            cin2.IsLiked__c = false;
            cin2.User__c = user2.Id;
            comlist.add(cin2);            
            insert comlist;
           
            test.startTest();
            //helpAuthHomeController.ideasDisplay(NetworkId, userinfo.getUserId()); 
            helpAuthHomeController.ideasDisplay(NetworkId, user2.Id);
            test.stopTest();
            
        }        
    }
    
    static testmethod void testIncrement() {
        helpAuthHomeController.justIncrement();
    }

}