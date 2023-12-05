@isTest
public class helpInternalIdeaDetailsTest {
    
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
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Cloud Integration';
            id1.Upvote_Count__c = 5;
            insert id1;
            
            List<String> catelist = new List<String>();
            catelist.add(id1.Categories);
            
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
            
            Topic tp = new Topic (Name='XYZ');
            insert tp;
            
            test.startTest();
            helpInternalIdeaDetails.ideasDisplay();
            helpInternalIdeaDetails.ideadisplayOnId(id1.Id);
            try{
                helpInternalIdeaDetails.ideadisplayOnId(null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            
            try{
                helpInternalIdeaDetails.ideadisplayPostEdit(null,null,id1.Status,id1.Title,id1.Body,5);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpInternalIdeaDetails.handleIdeaStatusChange('New',id1.Id);
            try{
                helpInternalIdeaDetails.handleIdeaStatusChange('',null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpInternalIdeaDetails.createIdea(id1.title,catelist, id1.body);
            
            helpInternalIdeaDetails.getCategoryPicklistValues();
            helpInternalIdeaDetails.getStatusPicklistValues();
            helpInternalIdeaDetails.getStatusValuesForFilter();
            helpInternalIdeaDetails.fetchFilterValues();
            helpInternalIdeaDetails.getSelectedIdea(tp.Id);
            test.stopTest();
            
        }        
    }
    
    
    
    static testmethod void testmethod5(){
        helpInternalIdeaDetails.fetchFilterAfterTabSwitch();
        helpInternalIdeaDetails.getStatusPicklistValuesForCRs();
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
            
            Idea id1 = new Idea();
            id1.Title = 'new idea';
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
            id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
            id1.Status = 'New';
            id1.Categories = 'Cloud Integration';
            id1.Upvote_Count__c = 5;
            insert id1;
            
            List<String> catelist = new List<String>();
            catelist.add(id1.Categories);
            
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
            
            Topic tp = new Topic (Name='xyz');
            insert tp;
            
            test.startTest();
            helpInternalIdeaDetails.getSelectedIdea(tp.Id);
            test.stopTest();            
        }        
    }
    
    
    static testmethod void testmethod3(){                    
        String NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
        id1.Status = 'New';
        id1.Categories = 'Cloud Integration';
        id1.Upvote_Count__c = 5;
        insert id1;
        
        List<String> CategoriesList = new List<String>();       
        CategoriesList.add(id1.Categories);
        
        test.startTest();
        helpInternalIdeaDetails.ideadisplayPostEdit(id1.Id,CategoriesList,id1.Status,id1.Title,id1.Body,5);
        test.stopTest();            
    }        
    
    
}