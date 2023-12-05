/*
* Name         :   helpGroupsControllerTest
* Author       :   Narpavi Prabu
* Created Date :   28-FEB-2022
* Description  :   Test class for helpGroupsController class.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Narpavi Prabu        28-FEB-2022    Utopia-ph-3         Initial version.                                               NA
Deeksha Shetty       19 July,2022   I2RT-6706           Notification criteria - Events                                 T1
Deeksha Shetty       08 May 2023    I2RT-8345           Ask a Question - Email Notification - Issue observed in        T2
                                                        New and Update   Notification email template           
                                                      

*/

@IsTest(SeeAllData=true)
public with sharing class helpGroupsControllerTest {
    
    static testmethod void getGroupLandingDisplaymygrouptest()
    {          
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
            
            EmailTemplate e = [SELECT Id FROM EmailTemplate WHERE DeveloperName='help_Welcome_To_UG'];
            
            Alerts_Announcements__c anc = new Alerts_Announcements__c();
            anc.AnnouncementDescription__c = 'Description';
            anc.Name = 'Title';
            anc.Start_Date__c = Date.valueOf(System.today());
            anc.End_Date__c = Date.valueOf(System.today()+10);
            anc.User_Group__c = grp.id;
            anc.RecordTypeId= Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            insert anc;
            
            List<helpGroupsController.GroupWrapper> GrpWrap = new List<helpGroupsController.GroupWrapper>();
            helpGroupsController.GroupWrapper GrpWrap1 = new helpGroupsController.GroupWrapper();
            GrpWrap1.groupid = grp.id;
            GrpWrap1.networkid = networkId;
            GrpWrap1.grouptype = '';
            GrpWrap1.MemberId = user2.id;
            GrpWrap1.EmailTemplate = 'help_Welcome_To_UG';
            GrpWrap.add(GrpWrap1);
            CollaborationGroup colGrpoup = new CollaborationGroup();
            colGrpoup.name = 'tesbnbbat1';
            colGrpoup.NetworkId = networkId;
            colGrpoup.CollaborationType  = 'Public';
            insert colGrpoup;
            test.startTest(); 
            helpGroupsController.getGroupLandingDisplay(networkId,user2.Id,'mygroup'); 
            try{
                helpGroupsController.getGroupLandingDisplay('',user2.Id,'mygroup'); 
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsController.getsortbygroup(networkId,user2.Id,'Ascending','mygroup');
            try{
                helpGroupsController.getsortbygroup('',user2.Id,'Ascending','mygroup');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsCOntroller.createGroup(networkId,'Title','Public','Description');
            try{
                helpGroupsCOntroller.createGroup('','Title','Public','Description');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsCOntroller.updateAnnouncement(anc.id,'Test','Description','2022-12-9','2023-12-10',grp.id);
            try{
                helpGroupsCOntroller.updateAnnouncement(anc.id,'Test','Description','2022-12-9','2023-12-10', null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            try{
                helpGroupsCOntroller.sendMail(grp.id,Userinfo.getUserId());
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }                        
            try{
                helpGroupsCOntroller.sendMail(grp.id,'');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsCOntroller.getUserGroupId('testabc',networkId);
            try{
                helpGroupsCOntroller.getUserGroupId('test', '');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            try{
                helpGroupsCOntroller.sendmailtouser(GrpWrap);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            //  helpGroupsCOntroller.getUserGroupId('*','tyya');
            
            
            test.stopTest();             
            
        }                                                                                             
    }  
    
    static testmethod void getGroupLandingDisplayallgrouptest()
    {          
        
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
            
            CollaborationGroup grp= new CollaborationGroup();
            grp.Name='testabc';
            grp.NetworkId=networkId;
            grp.Description='abcd';
            grp.CollaborationType = 'Public';
            insert grp;
            
            
            test.startTest();    
            helpGroupsController.getGroupLandingDisplay(networkId,user2.Id,'allgroup');
            update grp; //to get the lastVieweddate
            helpGroupsController.getGroupLandingDisplay(networkId,user2.Id,'allgroup');
            helpGroupsController.getsortbygroup(networkId,user2.Id,'Descending','allgroup');
            helpGroupsController.getTypePicklistValues();
            helpGroupsController.fetchFilterValues();
            
            helpGroupsController.leadUserGroup();
            helpGroupsController.startausergroup();
            helpGroupsController.joinGroup(grp.id,user2.Id,NetworkId);
            try{
                helpGroupsController.joinGroup(grp.id,user2.Id, '');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsController.getJoinGroupLanding(networkId,'allgroup');
            helpGroupsController.createAnnouncement('Test','Description','2022-12-9','2023-12-10',grp.id);
            test.stopTest();  
            
        }                                                                                          
    }
    
    static testmethod void unfollowgrouptestmethod()
    {          
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
            
            Account uacc = new Account();
            uacc.Name = 'Test Account';
            uacc.BillingCountry='USA';
            insert uacc;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = uacc.Id;
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
            
            
            Topic a = new Topic(Name='test39493',
                                NetworkId=networkId,
                                Description='abcde');
            insert a;
            FeedItem feedData = new FeedItem();
            feedData.Title='title';
            feedData.ParentId=a.Id;
            feedData.Body= 'body comment';
            feedData.NetworkScope=networkId;
            feedData.Type='QuestionPost';
            feedData.IsRichText=true;
            insert feedData;
            List<string> choice = new List<string>();
            choice.add('test');
            choice.add('notest');
            
            
            String tempString = 'Some test';
            Blob tempBlob = Blob.valueOf(tempString);
            String textBase64 = EncodingUtil.base64Encode(tempBlob);
            List<helpQuestions.attachmentToList> attachmentList = new List<helpQuestions.attachmentToList>();
            helpQuestions.attachmentToList attachmentObj = new helpQuestions.attachmentToList();
            attachmentObj.filename = 'testFilename.jpg';
            attachmentObj.base64 = textBase64;
            attachmentList.add(attachmentObj);
            String fileListStr = JSON.serialize(attachmentList);
            
            test.startTest();  
            //  helpGroupsController.feedelement('test',choice,grp.id);
            helpGroupsController.unfollowgroup(grp.id,networkId,user2.Id);
            try{
                helpGroupsController.unfollowgroup(grp.id, '',user2.Id);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsController.getfollowingGroup(grp.id,user2.Id,networkId);
            try{
                helpGroupsController.getfollowingGroup(grp.id,user2.Id, '');
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsController.getgroupType(grp.id);
            try{
                helpGroupsController.getgroupType(null);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsController.getgroupmember(user2.Id,grp.id);
            try{
                helpGroupsController.getgroupmember(null, grp.id);
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
            helpGroupsController.getUserType(user2.Id);
            helpGroupsController.getgroupAdmin(user2.Id,grp.id);
            helpGroupsController.getGroupName(grp.id);
            try{
                /*T2 starts */
                Test.setMock(HttpCalloutMock.class, new helpQuestionCalloutMock());
                helpGroupsController.saveQuestionPost('test','body <p><img src="Test"></p> <br> <span></span> <strong></strong> <em></em> <strike></strike>',uacc.id,fileListStr);
                /*T2 ends */
            }catch(Exception ex ){
                System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            test.stopTest();             
            
        }       
    }
    
    static testmethod void creategroupeventestmethod()
    {
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
            
            Account uacc = new Account();
            uacc.Name = 'Test Account';
            uacc.BillingCountry='USA';
            insert uacc;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = uacc.Id;
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
            
            CollaborationGroup grp = new CollaborationGroup ();
            grp.Name='testabc';
            grp.NetworkId=networkId;
            grp.Description='abcd';
            grp.CollaborationType = 'Public';
            insert grp;
            
            Event e1 = new Event();
            e1.WhatId=uacc.id;
            e1.StartDateTime=system.today();
            e1.EndDateTime=system.today()+5;
            e1.ActivityDate = System.today();
            e1.User_Group_Id__c=grp.id;
            insert e1;
            
            Event e = new Event();
            e.WhatId=uacc.id;
            e.StartDateTime=system.today();
            e.EndDateTime=system.today()+5;
            e.ActivityDate = System.today();
            e.User_Group_Id__c=grp.id;
            //insert e;
            string eventJSON = JSON.Serialize(e);
            //'[{"ConvertedDate":null,"scheduledAt":"2020-11-09","id":'+' "' + contactRecord.Id +'" ' +' ,"email": ' +' "'+ contactRecord.Email + '" '+ ',"name":' + ' "' + contactRecord.LastName + '" ' + '}]';
            
            string strevent='[{ "Subject": "Test Event","Description": "Description","StartDateTime": Datetime.now(),"EndDateTime": Datetime.now()+10,"Location": "Test","Type": "User Group"}]' ;           
            system.debug('jsonInput'+strevent);
            
            List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e1.Id;
            er.Status = 'Accepted';
            er.RelationId = user2.Id;
            evlist.add(er);        
            insert evlist;
            
            
            test.startTest();
            try
            {
                System.debug('eventJSON > ' + eventJSON);
                helpGroupsController.createGroupEvent(eventJSON,grp.id);
                helpGroupsController.getGroupLandingDisplay(networkId,user2.Id,'mygroup');
            }
            Catch(EXception ex){}
            
            test.stopTest();
        }       
    }
    
    static testmethod void createPoll()
    {  
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
            NetworkMember membership = [SELECT NetworkID, MemberID FROM NetworkMember
                                        WHERE memberID = :user2.id limit 1];
            CollaborationGroup grp= new CollaborationGroup();
            grp.Name='testabc';
            grp.NetworkId=networkId;
            grp.Description='abcd';
            grp.CollaborationType = 'Public';
            insert grp;
            string jsonOfListOfChoice = '[{"index": 1, "label": "Choice2", "Choice": null, "ChoiceBody":"B"},{"index": 2, "label": "Choice3", "Choice": null}]';
            object obj = JSON.deserializeUntyped(jsonOfListOfChoice);
            System.runAs(user2){
                System.debug('network Id > ' + Network.getNetworkId());
                System.debug('membership > ' + membership.NetworkId);
                
                test.startTest();
            try
            {
                helpGroupsController.createPoll(grp.id,'test','test bodyy',obj);
            }
            Catch(EXception ex){}          
            }
            test.stopTest();
        }
    }
    
    
    static testmethod void feedelement()
    {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        CollaborationGroup grp= new CollaborationGroup();
        grp.Name='testabc';
        grp.NetworkId=networkId;
        grp.Description='abcd';
        grp.CollaborationType = 'Public';
        insert grp;
        list<string> finalchoice = new list<string>();
        finalchoice.add('B');
        finalchoice.add('Test');
        test.startTest();
        helpGroupsController.feedelement('Test', finalchoice, grp.id);
        test.stopTest();
    }
    @isTest(seealldata=true)
    static void feedelement1()
    {
        Account uacc= new Account();
        uacc.Name='userAccount';
        uacc.BillingCountry='USA';
        insert uacc;
        test.startTest();
        helpGroupsController.feedelement1('Test', 'Test', uacc.id);
        test.stopTest();
    }
    
    static testmethod void createGroupEvent()
    {       
        test.startTest();
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        CollaborationGroup grp= new CollaborationGroup();
        grp.Name='testabbn';  
        grp.NetworkId=networkId;
        grp.Description='abcd';
        grp.CollaborationType = 'Public';
        insert grp;
        
        helpGroupsController.createGroupEvent(null , grp.id);
        test.stopTest();
        
    }
    
    static testmethod void test_sendemailpostEvent(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        CollaborationGroup grp= new CollaborationGroup();
        grp.Name='testabc';
        grp.NetworkId=networkId;
        grp.Description='abcd';
        grp.CollaborationType = 'Public';
        insert grp;
        
        Event e1 = new Event();
        e1.StartDateTime=system.today();
        e1.EndDateTime=system.today()+5;
        e1.Subject = 'test';
        e1.ActivityDate = System.today();
        e1.User_Group_Id__c=grp.id;
        e1.Description = 'abcd';
        e1.Location='Bangalore';
        insert e1;
        
        test.startTest();
        try{
            helpGroupsController.sendMailPostEventCreation(grp.Id, e1.Id,'Insert');
        }
        Catch(Exception ex){}
        
        test.stoptest();
    }
    
    static testmethod void test_sendemailpostEvent1(){
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        
        CollaborationGroup grp= new CollaborationGroup();
        grp.Name='testabc';
        grp.NetworkId=networkId;
        grp.Description='abcd';
        grp.CollaborationType = 'Public';
        insert grp;
        
        Event e1 = new Event();
        e1.StartDateTime=system.today();
        e1.EndDateTime=system.today()+5;
        e1.ActivityDate = System.today();
        e1.User_Group_Id__c=grp.id;
        e1.Location='Bangalore';
        e1.Description = 'abcd';
        e1.Subject = 'test';
        insert e1;
        
        test.startTest();
        try{
            helpGroupsController.sendMailPostEventCreation(grp.Id, e1.Id,'Modify');
        }
        Catch(Exception ex){}
        
        test.stoptest();
    }
    
}