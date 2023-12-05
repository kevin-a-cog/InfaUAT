/*
Class:  ActivityTriggerHandlerTest
        @Author:        Anil Solanki
        @Created Date:  24 April 2018
        @Description:   Test Class for ActivityTriggerHandler Class.
*/
@isTest
private class ActivityTriggerHandlerTest{

    @testSetup
    static void setupObjectTestData(){
        UtilityTest.insertSetupObjectTestData();
    }
    
    //Method to test Task Insert on Contact
    @isTest
    static void taskActivityCountWithContactTest() {
        sObject sObj = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
            UtilityTestData.mTaskData.put('WhoId', lContact[0].Id);
            sObj = new Task(TaskSubType= 'Email');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTaskData);
            List<Task> lTask = (List<Task>) UtilityTest.makeInsert(new List<sObject>{sObj});
            Contact con1 = [select id,email,No_of_Attempts__c from contact where id =: lContact[0].id limit 1];
            System.assertEquals(con1.No_of_Attempts__c,1);
        Test.stopTest();
    }
    
    //Method to test multiple Task Insert on Lead
    @isTest
    static void taskActivityCountwithLeadTest() {
        
        sObject sObj = new Account();
        sObject sObj1 = new Lead();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        User userObj = [select Id, Name from User where Profile.Name = 'Integration Profile' AND isActive=true limit 1];

        Test.startTest();
           // System.runAs(userObj){
                sObj = new Lead();
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);
                List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});

                UtilityTestData.mTaskData.put('WhoId', lLead[0].Id);
                sObj = new Task(TaskSubType= 'Email');
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTaskData);
                sObj1 = new Task(Subject = 'Testing',TaskSubType= 'Email');
                sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mTaskData);
                List<Task> lTask = (List<Task>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
                Lead l1 = [select id,email,No_of_Attempts__c from lead where id =:lLead[0].id limit 1];
                System.assertEquals(l1.No_of_Attempts__c,2);
            //}
        Test.stopTest();
    }

    //Method to test Event Insert on Contact
    @isTest
    static void eventActivityCountwithContactTest() {
        sObject sObj = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
            UtilityTestData.mEventData.put('WhoId', lContact[0].Id);
            sObj = new Event();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEventData);
            List<Event> lEvent = (List<Event>) UtilityTest.makeInsert(new List<sObject>{sObj});
            Contact con1 = [select id,email,No_of_Attempts__c from contact where id =: lContact[0].id limit 1];
            System.assertEquals(con1.No_of_Attempts__c,1);
        Test.stopTest();
        
    }

    //Method to test Event Insert on Lead
    @isTest
    static void eventActivityCountwithLeadTest() {
        sObject sObj = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Lead();
        UtilityTestData.mLeadData.put('LastName', 'Test LastName');
        UtilityTestData.mLeadData.put('Company', 'Test Company');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);     
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
            UtilityTestData.mEventData.put('WhoId', lLead[0].Id);
            sObj = new Event();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEventData);
            List<Event> lEvent = (List<Event>) UtilityTest.makeInsert(new List<sObject>{sObj});
            Lead l1 = [select id,email,No_of_Attempts__c from lead where id =:lLead[0].id limit 1];
            System.assertEquals(l1.No_of_Attempts__c,1);
        Test.stopTest();
    }

    //Method to test Task Insert 
    @isTest
    static void taskActivityIgnoreInsertTest() {
        sObject sObj = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
            UtilityTestData.mTaskData.put('WhoId', lContact[0].Id);
            sObj = new Task(TaskSubType= 'Email');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTaskData);
            globalApexManager.avoidRecursion('TaskAfterInsert');
            List<Task> lTask = (List<Task>) UtilityTest.makeInsert(new List<sObject>{sObj});
            List<Task> taskInserted = [select Id,TaskSubType from Task where id =: lTask[0].id limit 1];
            System.assertEquals(taskInserted.size(),1);
        Test.stopTest();
    }

    //Method to test Event Insert
    @isTest
    static void eventActivityIgnoreInsertTest() {
        sObject sObj = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Lead();
        UtilityTestData.mLeadData.put('LastName', 'Test LastName');
        UtilityTestData.mLeadData.put('Company', 'Test Company');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);     
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
            UtilityTestData.mEventData.put('WhoId', lLead[0].Id);
            sObj = new Event();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEventData);
            globalApexManager.avoidRecursion('TaskAfterInsert');
            List<Event> lEvent = (List<Event>) UtilityTest.makeInsert(new List<sObject>{sObj});
            List<Event> eventInserted = [select id from Event where id =:lEvent[0].id limit 1];
            System.assertEquals(eventInserted.size(),1);
        Test.stopTest();
    }
    
    //Method to test Task after update for altify tasks SALESRT#13807
    @isTest
    static void taskAfterUpdateAltifySource(){
        sObject sObj = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new ALTF__Account_Objective__c();
        UtilityTestData.mAltifyAccountObjectve.put('ALTF__Account__c', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAltifyAccountObjectve);  
        List<ALTF__Account_Objective__c> lAltiAccObjctv = (List<ALTF__Account_Objective__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
        sObj = new Task(TaskSubType= 'Email');
        //UtilityTestData.mTaskData.put('WhoId', UserInfo.getUserId());
        UtilityTestData.mTaskData.put('ALTF__Altify_Objective__c', lAltiAccObjctv[0].Id);
       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTaskData);
        
        globalApexManager.avoidRecursion('TaskAfterInsert');
        List<Task> lTask = (List<Task>) UtilityTest.makeInsert(new List<sObject>{sObj});
        List<Task> taskInserted = [select Id,TaskSubType, ALTF__Altify_Objective__c, source__c, Status from Task where id =: lTask[0].id limit 1];
        System.assertEquals(taskInserted[0].Source__c,'Altify');
        taskInserted[0].Status = 'Completed';
        update taskInserted;
        Test.stopTest();
    }
}