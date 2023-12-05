/*
* Name : IdeaTriggerHandlerTest
* Author : Deeksha Shetty
* Created Date : February 1,2022
* Description : Test Class for IdeaTriggerHandler
Change History
*********************************************************************************************************************************
Modified By              Date               Jira No.                Description                                           Tag
Deeksha Shetty         7/7/2022             I2RT-6502            Notification email for CRT/User group/Events/Ideas       T1
**********************************************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

@isTest
public class IdeaTriggerHandlerTest {
    
    static testmethod void testmethod1(){
        Map<Id,String> olmap = new  Map<Id,String>();
        Map<Id,String> newmap = new  Map<Id,String>();
        
        String NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;                              
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = '<table border="1" cellpadding="5" cellspacing="0" style="width: 100%;"><tbody><tr><td colspan="2" rowspan="1" style="color: black; font-weight: bold;">Change Request Information</td></tr><tr valign="bottom"><td colspan="1" rowspan="1"><strong>Bug / Enhancement Number</strong></td><td colspan="1" rowspan="1">AXON-11975</td></tr><tr valign="top"><td colspan="1" rowspan="1" style=""><strong>Title</strong></td><td colspan="1" rowspan="1">Add additional columns to the Data Quality Export</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Product</strong></td><td colspan="1" rowspan="1">Axon (Data Governance)</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Reported Version</strong></td><td colspan="1" rowspan="1">6.1</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Current Status</strong></td><td colspan="1" rowspan="1">Assigned</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>To be Fixed in version</strong></td><td colspan="1" rowspan="1">Future Release</td></tr></tbody></table>';
        id1.Status = 'New';
        id1.Categories = 'Change Request';
        insert id1;
        olmap.put(id1.Id,id1.Status);
        
        Feed_Meta__c feed = new Feed_Meta__c();
        //feed.Name = 'Test';
        feed.Reference__c = id1.Id;
        
        insert feed;

        id1.Status = 'In Progress';
        update id1;
        newmap.put(id1.Id,id1.Status);
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'Status changed From'+' '+olmap.get(id1.Id) +' '+ 'to'+ ' '+newmap.get(id1.Id)  ;
        insert com1;                    
        
    }
    
    static testmethod void testmethod2(){
        Map<Id,String> olmap = new  Map<Id,String>();
        Map<Id,String> newmap = new  Map<Id,String>();
        
        String NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;                              
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = '<table border="1" cellpadding="5" cellspacing="0" style="width: 100%;"><tbody><tr><td colspan="2" rowspan="1" style="color: black; font-weight: bold;">Change Request Information</td></tr><tr valign="bottom"><td colspan="1" rowspan="1"><strong>Bug / Enhancement Number</strong></td><td colspan="1" rowspan="1">AXON-11975</td></tr><tr valign="top"><td colspan="1" rowspan="1" style=""><strong>Title</strong></td><td colspan="1" rowspan="1">Add additional columns to the Data Quality Export</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Product</strong></td><td colspan="1" rowspan="1">Axon (Data Governance)</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Reported Version</strong></td><td colspan="1" rowspan="1">6.1</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Current Status</strong></td><td colspan="1" rowspan="1">Assigned</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>To be Fixed in version</strong></td><td colspan="1" rowspan="1">Future Release</td></tr></tbody></table>';
        id1.Status = 'Draft';
        id1.Categories = 'Data Integration';
        insert id1;
        olmap.put(id1.Id,id1.Status);
        
         Feed_Meta__c feed = new Feed_Meta__c();
        //feed.Name = 'Test';
        feed.Reference__c = id1.Id;
        insert feed;
        
        id1.Status = 'New';
        update id1;
        newmap.put(id1.Id,id1.Status);
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'Status changed From'+' '+olmap.get(id1.Id) +' '+ 'to'+ ' '+newmap.get(id1.Id)  ;
        insert com1;                    
        
    }
    
    
    static testmethod void testmethod3(){
        Map<Id,String> olmap = new  Map<Id,String>();
        Map<Id,String> newmap = new  Map<Id,String>();
        
        String NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;                              
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = '<table border="1" cellpadding="5" cellspacing="0" style="width: 100%;"><tbody><tr><td colspan="2" rowspan="1" style="color: black; font-weight: bold;">Change Request Information</td></tr><tr valign="bottom"><td colspan="1" rowspan="1"><strong>Bug / Enhancement Number</strong></td><td colspan="1" rowspan="1">AXON-11975</td></tr><tr valign="top"><td colspan="1" rowspan="1" style=""><strong>Title</strong></td><td colspan="1" rowspan="1">Add additional columns to the Data Quality Export</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Product</strong></td><td colspan="1" rowspan="1">Axon (Data Governance)</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Reported Version</strong></td><td colspan="1" rowspan="1">6.1</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Current Status</strong></td><td colspan="1" rowspan="1">Assigned</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>To be Fixed in version</strong></td><td colspan="1" rowspan="1">Future Release</td></tr></tbody></table>';
        id1.Status = 'Completed';
        id1.Categories = 'Data Integration';
        insert id1;
        olmap.put(id1.Id,id1.Status);
        
         Feed_Meta__c feed = new Feed_Meta__c();
        //feed.Name = 'Test';
        feed.Reference__c = id1.Id;
        insert feed;
        
        Community_Interactions__c com = new Community_Interactions__c();
        com.Id__c = id1.Id;
        com.Type__c = 'Idea';
        com.User__c = userinfo.getUserId();
        insert com;
        
        id1.Status = 'In Progress';
        update id1;
        newmap.put(id1.Id,id1.Status);
        
        
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'Status changed From'+' '+olmap.get(id1.Id) +' '+ 'to'+ ' '+newmap.get(id1.Id)  ;
        insert com1;                    
        
    }
    
    static testmethod void testmethod4(){
        Map<Id,String> olmap = new  Map<Id,String>();
        Map<Id,String> newmap = new  Map<Id,String>();
       
        String NetworkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;                              
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = '<table border="1" cellpadding="5" cellspacing="0" style="width: 100%;"><tbody><tr><td colspan="2" rowspan="1" style="color: black; font-weight: bold;">Change Request Information</td></tr><tr valign="bottom"><td colspan="1" rowspan="1"><strong>Bug / Enhancement Number</strong></td><td colspan="1" rowspan="1">AXON-11975</td></tr><tr valign="top"><td colspan="1" rowspan="1" style=""><strong>Title</strong></td><td colspan="1" rowspan="1">Add additional columns to the Data Quality Export</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Product</strong></td><td colspan="1" rowspan="1">Axon (Data Governance)</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Reported Version</strong></td><td colspan="1" rowspan="1">6.1</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Current Status</strong></td><td colspan="1" rowspan="1">Assigned</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>To be Fixed in version</strong></td><td colspan="1" rowspan="1">Future Release</td></tr></tbody></table>';
        id1.Status = 'New';
        id1.Categories = 'Change Request';
        insert id1;
        olmap.put(id1.Id,id1.Status);
        
        
        id1.Status = 'In Progress';
        update id1;
        newmap.put(id1.Id,id1.Status);
        
        IdeaComment com1 = new IdeaComment();
        com1.IdeaId= id1.Id ;
        com1.CommentBody = 'Status changed From'+' '+olmap.get(id1.Id) +' '+ 'to'+ ' '+newmap.get(id1.Id)  ;
        insert com1;                    
        
    }
    
    
    static testmethod void testmethod5(){
        Map<Id,String> olmap = new  Map<Id,String>();
        Map<Id,String> newmap = new  Map<Id,String>();    
        
        //T1 Starts
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
            id1.Body = '<table border="1" cellpadding="5" cellspacing="0" style="width: 100%;"><tbody><tr><td colspan="2" rowspan="1" style="color: black; font-weight: bold;">Change Request Information</td></tr><tr valign="bottom"><td colspan="1" rowspan="1"><strong>Bug / Enhancement Number</strong></td><td colspan="1" rowspan="1">AXON-11975</td></tr><tr valign="top"><td colspan="1" rowspan="1" style=""><strong>Title</strong></td><td colspan="1" rowspan="1">Add additional columns to the Data Quality Export</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Product</strong></td><td colspan="1" rowspan="1">Axon (Data Governance)</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Reported Version</strong></td><td colspan="1" rowspan="1">6.1</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>Current Status</strong></td><td colspan="1" rowspan="1">Assigned</td></tr><tr valign="top"><td colspan="1" rowspan="1"><strong>To be Fixed in version</strong></td><td colspan="1" rowspan="1">Future Release</td></tr></tbody></table>';
            id1.Status = 'New';
            id1.Categories = 'Change Request;CloudIntegration';
            id1.Bug_Enhancement_Number__c = 'test';
            id1.Reported_Version__c = 'test';
            id1.To_be_Fixed_in_version__c = 'Test';         
            insert id1;
            
            Community_Interactions__c cin = new Community_Interactions__c();
            cin.Id__c = id1.Id;
            cin.Follow__c = true;
            cin.Vote__c = 'Upvote';
            cin.IsLiked__c = true;
            cin.Type__c='CRT';
            cin.User__c = user2.Id;
            insert cin;
            
            olmap.put(id1.Id,id1.Status);
            
            //T1 ends
            id1.Status = 'Active';
            update id1;
            newmap.put(id1.Id,id1.Status);
            
            IdeaComment com1 = new IdeaComment();
            com1.IdeaId= id1.Id ;
            com1.CommentBody = 'Status changed From'+' '+olmap.get(id1.Id) +' '+ 'to'+ ' '+newmap.get(id1.Id)  ;
            insert com1;                    
            
        }
    }

}