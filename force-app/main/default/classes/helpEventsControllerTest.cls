@isTest
public class helpEventsControllerTest {
    Static testmethod void testmethod1(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            collaborationGroup g = new collaborationgroup();
            g.Name = 'Test Grpup';
            g.CollaborationType = 'Private';
            insert g;
            
            Event e = new Event();
            e.WhatId=a.id;
            e.Description = 'Test event';
            e.StartDateTime=system.today();
            e.EndDateTime=system.today()+5;
            e.ActivityDate = System.today();
            e.Type='Meeting';
            e.Event_Type__c = 'User Group';
            e.Subject = 'Lorem ipsiuk jsddhjdhj';
            e.IsVisibleInSelfService = true;
            e.User_Group_Id__c = g.Id;
            insert e;
            
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = userinfo.getUserId();
            com.Type__c = 'Event';
            insert com;
                      
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            helpEventsController.getUserGroups();
            helpEventsController.getAllEvents('Desc',' ');
            helpEventsController.getMyEvents(user2.Id,'Desc',' ');
            helpEventsController.returnUsersWhoJoinedEvents(userinfo.getUserId());            
            try{
                helpEventsController.sendMail(Userinfo.getUserId(),e.id);
            }
            Catch(Exception ex){}
            
            helpEventsController.getEvents();
            test.stopTest();
            
        }
        
    }

    Static testmethod void testmethod2(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            collaborationGroup g = new collaborationgroup();
            g.Name = 'Test Grpup';
            g.CollaborationType = 'Public';
            insert g;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.Description = 'Test event';
            e.StartDateTime=system.today();
            e.EndDateTime=system.today()+5;
            e.ActivityDate = System.today();
            e.Type='Meeting';
            e.Event_Type__c = 'User Group';
            e.Subject = 'Lorem ipsiuk jsddhjdhj';
            e.IsVisibleInSelfService = true;
            e.User_Group_Id__c = g.Id;
            insert e;
            
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = userinfo.getUserId();
            com.Type__c = 'Event';
            insert com;
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            helpEventsController.getUserGroups();
            helpEventsController.getAllEvents('Desc',' ');
            helpEventsController.getMyEvents(user2.Id,'Desc',' ');
            helpEventsController.returnUsersWhoJoinedEvents(userinfo.getUserId());            
            try{
                helpEventsController.sendMail(Userinfo.getUserId(),e.id);
            }
            Catch(Exception ex){}
            helpEventsController.getEventsById(e.Id);
            test.stopTest();
            
        }
        
    }

    static testmethod void testmethod3(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            list<event> eventList = new list<event>();
            Event e = new Event();
            e.WhatId=a.id;
            e.Subject = 'Test Meeting';
            e.StartDateTime=date.newInstance(2022,4,12);
            e.EndDateTime=date.newInstance(2022,4,12);
            e.ActivityDate = date.newInstance(2022,4,12);
            e.Type='Meeting';
            e.Event_Type__c = 'External';
            e.ActivityDateTime = date.newInstance(2022,4,12);
            e.IsVisibleInSelfService = true;
            eventList.add(e);
            
            Event e1 = new Event();
            e1.WhatId=a.id;
            e1.Subject = 'Test Meeting';
            e1.StartDateTime=date.newInstance(2022,4,10);
            e1.EndDateTime=date.newInstance(2022,4,20);
            e1.ActivityDate = date.newInstance(2022,4,10);
            e1.Type='Meeting';
            e1.Event_Type__c = 'External';
            e1.ActivityDateTime = date.newInstance(2022,4,10);
            e1.IsVisibleInSelfService = true;
			eventList.add(e1);           
            insert eventList;
            
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = userinfo.getUserId();
            com.Type__c = 'Event';
            insert com;
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.RelationId = user2.Id;
            er.Status='Accepted';
            
            EventRelation er1 = new EventRelation();
            er1.Eventid = e1.Id;
            er1.RelationId = user2.Id;
            er1.Status='Accepted';
            
            evlist.add(er);
            evlist.add(er1);
            insert evlist;
            
            test.startTest();
            helpEventsController.getEventTypePicklistValues();
            Date today = date.today();
            String selectedDate = String.valueOf(date.newInstance(today.year(),today.month(),today.day()));
            List<String> eventTitleString = new List<String>(); 
            eventTitleString.add('Test Meeting'); 
            helpEventsController.getUpcomingEventsByTitle(JSON.serialize(eventTitleString), user2.Id, '2022-04-12');
            test.stopTest();
        }
        
    }
    
    
    static testmethod void testmethod9(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            collaborationGroup g = new collaborationgroup();
            g.Name = 'Test Grpup';
            g.CollaborationType = 'Public';
            insert g;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.StartDateTime=date.newInstance(2030,5,2);
            e.EndDateTime=date.newInstance(2030,5,10);
            e.ActivityDate = date.newInstance(2030,5,2);
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            e.User_Group_Id__c = g.id;
            insert e;
            
            Event e2 = new Event();
            e2.WhatId=a.id;
            e2.StartDateTime=date.newInstance(2030,5,2);
            e2.EndDateTime=date.newInstance(2030,5,10);
            e2.ActivityDate = date.newInstance(2020,5,2);
            e2.Type='Meeting';
            e2.IsVisibleInSelfService = true;
            insert e2;
            
            Event e3 = new Event();
            e3.WhatId=a.id;
            e3.StartDateTime=date.newInstance(2020,5,2);
            e3.EndDateTime=date.newInstance(2020,5,10);
            e3.ActivityDate = date.newInstance(2020,5,2);
            e3.Type='Meeting';
            e3.IsVisibleInSelfService = true;
            insert e3;
            
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = userinfo.getUserId();
            com.Type__c = 'Event';
            insert com;
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            helpEventsController.addUserToEvent(e.Id,user2.Id);   
            helpEventsController.addUserToEvent(e2.Id,user2.Id); 
            helpEventsController.addUserToEvent(e3.Id,user2.Id); 
            test.stopTest();
        }
        
    }
    
    
    static testmethod void testmethod5(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.StartDateTime=date.newInstance(2030,5,2);
            e.EndDateTime=date.newInstance(2030,5,10);
            e.ActivityDate = date.newInstance(2030,5,2);
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            insert e;
            
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            //er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            try{
                helpEventsController.DeclineEvent(e.Id,user2.Id);
            }
            Catch(Exception ex){}
            
            test.stopTest();
        }
        
    }
    
    static testmethod void testmethod6(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.Subject = 'testfgdhhdhj';
            e.StartDateTime=date.newInstance(2030,5,2);
            e.EndDateTime=date.newInstance(2030,5,10);
            e.ActivityDate = date.newInstance(2030,5,2);
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            insert e;
                        
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            //er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            try{
                datetime starttime = system.now();
                datetime endtime = System.now() + 1;
                helpEventsController.ModifyEvent(e.Id);                
            }
            Catch(Exception ex){}
            
            test.stopTest();
        }
        
    }
    
    
       static testmethod void testmethod7(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            collaborationGroup g = new collaborationgroup();
            g.Name = 'Test Grpup';
            g.CollaborationType = 'Public';
            insert g;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.Subject = 'testfgdhhdhj';
            e.StartDateTime=date.newInstance(2030,5,2);
            e.EndDateTime=date.newInstance(2030,5,10);
            e.ActivityDate = date.newInstance(2030,5,2);
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            e.User_Group_Id__c = g.Id;
            insert e;
            
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            //er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            try{
                datetime starttime = system.now();
                datetime endtime = System.now() + 1;
                helpEventsController.saveModifiedEvent('test1','test2',starttime,endtime,'India','Meeting',e.Id,true);
            }
            Catch(Exception ex){}
            
            test.stopTest();
        }
        
    }
    
    static testmethod void testmethod8(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.Subject = 'testfgdhhdhj';
            e.StartDateTime=date.newInstance(2030,5,2);
            e.EndDateTime=date.newInstance(2030,5,10);
            e.ActivityDate = date.newInstance(2030,5,2);
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            insert e;
            
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            //er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            try{                
                helpEventsController.deleteEvent(e.Id);
            }
            Catch(Exception ex){}
            
            test.stopTest();
        }
        
    }
    
    static testmethod void grouprelatedevts(){
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            
            Event e = new Event();
            e.WhatId=a.id;
            e.Subject = 'testtttt';
            e.StartDateTime=date.newInstance(2030,5,2);
            e.EndDateTime=date.newInstance(2030,5,10);
            e.ActivityDate = date.newInstance(2030,5,2);
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            e.Event_Type__c = 'External';
            insert e;
            
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = userinfo.getUserId();
            com.Type__c = 'Event';
            insert com;
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            test.startTest();
            helpEventsController.getRelatedEvents(e.Id);
            helpEventsController.fetchFilterAfterTabSwitch();
            test.stopTest();
        }
        
    }
     
    static testmethod  void grouprelatedevts1(){
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
        string userGroupId;
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
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
            collaborationGroup g = new collaborationgroup();
            g.Name = 'Test Grpup';
            g.CollaborationType = 'Public';
            insert g;
        
            List<Event> evntList = new List<Event>();
            Event e = new Event();
            //e.OwnerId =a.id;
            e.Subject = 'testtttt';
            e.StartDateTime=date.newInstance(2030,4,12);
            e.EndDateTime=date.newInstance(2030,4,12);
            e.ActivityDate = date.newInstance(2030,4,12);
            e.Event_Type__c = 'User Group';
            e.Type='Meeting';
            e.IsVisibleInSelfService = true;
            e.User_Group_Id__c = g.Id;
            
            
            Event e4 = new Event();
            e4.Subject = 'testtttt';
            e4.StartDateTime=date.newInstance(2030,4,12);
            e4.EndDateTime=date.newInstance(2030,4,12);
            e4.ActivityDate = date.newInstance(2030,4,12);
            e4.Event_Type__c = 'External';
            e4.Type='Meeting';
            e4.IsVisibleInSelfService = true;
            e4.User_Group_Id__c = g.Id;
            
            
            Event e1 = new Event();
            e1.whatId= a.Id;            
            e1.Subject = 'upcoming event';
            e1.StartDateTime=date.newInstance(2022,4,12);
            e1.EndDateTime=date.newInstance(2022,4,12);
            e1.ActivityDate = date.newInstance(2022,4,12);
            e1.Event_Type__c = 'External';
            e1.Type='Meeting';
            Event e2 = new Event();
            e2.whatId= a.Id;            
            e2.Subject = 'upcoming event';
            e2.StartDateTime=date.newInstance(2022,4,12);
            e2.EndDateTime=date.newInstance(2022,4,12);
            e2.ActivityDate = date.newInstance(2022,4,12);
            e2.Event_Type__c = 'External';
            e2.Type='Meeting';
            evntList.add(e);
        	evntList.add(e1);
            evntList.add(e2);
        	evntList.add(e4);
            insert evntList;
            userGroupId = e.User_Group_Id__c;
            Community_Interactions__c com = new Community_Interactions__c();
            com.Id__c= e.Id;
            com.User__c = userinfo.getUserId();
            com.Type__c = 'Event';
            insert com;
     		
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.Status = 'Accepted';
            er.RelationId = User2.Id;
            evlist.add(er);
            EventRelation er1 = new EventRelation();
            er1.Eventid = e1.Id;
            er1.Status = 'Accepted';
            er1.RelationId = User2.Id;
            evlist.add(er1);        
            insert evlist;
                      
            
            String con = contact.Id;
        
            
            test.startTest();
            helpEventsController.getGroupRelatedEvents(userGroupId);
            helpEventsController.getGroupRelatedEvents('');
            helpEventsController.getUpcomingEventsByUser(user2.Id,'asc','2022-04-12 00:00:00','2022-04-30 00:00:00',true);
            helpEventsController.getUpcomingEvents();
            helpEventsController.fetchJoinedEvents(user2.Id);
            test.stopTest();
        
        }
    }
    
    
        
    
}