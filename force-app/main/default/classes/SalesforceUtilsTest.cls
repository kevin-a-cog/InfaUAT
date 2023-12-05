/*
Class:          SalesforceUtilsTest
@Author:        Sumitkumar Mittal
@Created Date:  05/11/2018
@Description:   test class for SalesforceUtils
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
private class SalesforceUtilsTest {
    
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {    
        
        //Insert Account setup data
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Birthdate',System.today() + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
    }//END static void setupTestData()
    
    
    /*
Below methods are covering the class
*/
    static testMethod void unitTestGetObjectId() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Set<Id> rt = SalesforceUtils.getIdSetFromList(lAccount, 'Id');
            System.assertEquals(lAccount.size(), rt.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestGetObjectIdException() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Set<Id> rt = SalesforceUtils.getIdSetFromList(lAccount, '');
            System.assertEquals(0, rt.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestGetMapListName() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id, Name from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Map<String, List<SObject>> rt = SalesforceUtils.getMapListsFromProp(lAccount, 'Name', 'Id');
            System.assertEquals(lAccount.size(), rt.size());
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestGetMapListBillingCity() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id, BillingCity from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Map<String, List<SObject>> rt = SalesforceUtils.getMapListsFromProp(lAccount, 'BillingCity', 'Id');
            System.assertEquals(lAccount.size(), rt.size());
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestGetMapListBillingCityException() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id, BillingCity from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Map<String, List<SObject>> rt = SalesforceUtils.getMapListsFromProp(lAccount, 'BillingCity', Null);
            System.assertEquals(0, rt.size());
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestGetFieldsFromFieldSet() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        System.runAs(userObj) { 
            Test.StartTest();
                List<String> fieldsInFieldSetList = SalesforceUtils.getFieldsFromFieldSet('Collaboration_Criteria_Fieldset', 'Case');
            Test.StopTest();
            System.assertNotEquals(0, fieldsInFieldSetList.size());
        }
    }

    static testMethod void unitTestMergeText() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id, BillingCountry, BillingCity from Account Limit 1');
        System.runAs(userObj) { 
            Test.StartTest();
                String mergedText = SalesforceUtils.mergeText('BillingCountry:{!Account.BillingCountry}', lAccount[0].Id).get(lAccount[0].Id);
            Test.StopTest();
            System.assertEquals('BillingCountry:India', mergedText);
        }
    }

    static testMethod void unitTestGetMapListNameException() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id, Name from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Map<String, List<SObject>> rt = SalesforceUtils.getMapListsFromProp(lAccount, '', 'Name');
            System.assertEquals(0, rt.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestgetStringSetFromListId() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, Account.Id from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Set<String> rt = SalesforceUtils.getStringSetFromList(contactList, 'Account.Id');        
            System.assert(rt != null);
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestgetStringSetFromListName() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, Name from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Set<String> rt = SalesforceUtils.getStringSetFromList(contactList, 'Account.Id');        
            System.assert(rt != null);
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestgetStringSetFromListException() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, Account.Id from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            Set<String> rt = SalesforceUtils.getStringSetFromList(contactList, '');        
            System.assertEquals(0, rt.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestgetMapFromSObjectListProp() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, Account.Id, FirstName, LastName from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Valid scenario
            Map<String, String> rt = SalesforceUtils.getMapFromSObjectListProp(contactList, 'FirstName', 'LastName');
            System.assert(rt != null);
            
            //Exception scenario
            Map<String, String> rt1 = SalesforceUtils.getMapFromSObjectListProp(contactList, '', '');        
            System.assertEquals(0, rt1.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestgetLargestOrSmallesDatetime() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, Birthdate from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            DateTime rt1 = SalesforceUtils.getLargestOrSmallesDatetime(contactList, 'Birthdate', false);        
            System.assertEquals(contactList[0].BirthDate, rt1);
            
            //Scenario 2
            DateTime rt = SalesforceUtils.getLargestOrSmallesDatetime(contactList, 'Birthdate', true);        
            System.assertEquals(contactList[contactList.size() - 1].BirthDate, rt);
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestgetMapFromSObjectListPropAny() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, FirstName, LastName from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            Map<String, Object> rt = SalesforceUtils.getMapFromSObjectListPropAny(contactList, 'FirstName', 'LastName');        
            System.assertEquals(1, rt.size());
            
            //Exception scenario
            Map<String, Object> rt1 = SalesforceUtils.getMapFromSObjectListPropAny(contactList, '', '');        
            System.assertEquals(0, rt1.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestgetMapByProp() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, FirstName, LastName from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            Map<String, SObject> rt = SalesforceUtils.getMapByProp(contactList, 'FirstName');        
            System.assertEquals(1, rt.size());
            
            //Exception scenario
            Map<String, SObject> rt1 = SalesforceUtils.getMapByProp(contactList, '');        
            System.assertEquals(0, rt1.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestfindRecsWithSpecificValue() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, FirstName, LastName from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            List<SObject> rt = SalesforceUtils.findRecsWithSpecificValue(contactList, 'FirstName', 'Test');        
            System.assertEquals(contactList.size(), rt.size());
            
            //Exception scenario
            List<SObject> rt1 = SalesforceUtils.findRecsWithSpecificValue(contactList, 'FirstName', '');        
            System.assertEquals(0, rt1.size());
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestfindRecsWithChangedValues() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Contact> contactList = (List<Contact>) UtilityTest.executeQuery('Select Id, FirstName, LastName from Contact Limit 1');
        system.assertEquals(contactList.size(),1);
        Map<Id, SObject> oldMap = new Map<Id, SObject>{contactList[0].Id => new Contact(Id = contactList[0].Id, FirstName = 'Hello')};
            
            System.runAs(userObj) { 
                Test.StartTest();
                
                //Scenario 1
                List<SObject> rt = SalesforceUtils.findRecsWithChangedValues(contactList, oldMap, 'FirstName');        
                System.assertEquals(1, rt.size());
                
                //scenario 2
                List<SObject> rt1 = SalesforceUtils.findRecsWithChangedValues(contactList, oldMap, '');        
                System.assertEquals(0, rt1.size());
                
                //Scenario 3
                List<SObject> rt2 = SalesforceUtils.findRecsWithChangedValues(contactList, oldMap, 'FirstName', 'Test');
                System.assertEquals(1, rt2.size());
                
                //Scenario 4
                List<SObject> rt3 = SalesforceUtils.findRecsWithChangedValues(contactList, oldMap, '', 'Test');
                System.assertEquals(0, rt3.size());
                
                Test.StopTest();
            }
    }
    
    
    static testMethod void unitTestprepareMultiSelectPicklistVals() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            String rt = SalesforceUtils.prepareMultiSelectPicklistVals(new List<String>{'Test0', 'Test1', 'Test2'});
            System.assertEquals('Test0; Test1; Test2', rt);
            
            //Scenario 2
            String rt1 = SalesforceUtils.prepareMultiSelectPicklistVals(new Set<String>{'Test0', 'Test1', 'Test2'});        
            System.assertEquals('Test0; Test1; Test2', rt1);
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestdateTimeToDate() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            Date rt = SalesforceUtils.dateTimeToDate(DateTime.newInstance(2017, 11, 20));
            Date dt = Date.newInstance(2017, 11, 20);        
            System.assertEquals(dt, rt);
            
            Test.StopTest();
        }
    }
    
    
    static testMethod void unitTestdateToDateTime() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            DateTime rt = SalesforceUtils.dateToDateTime(Date.newInstance(2017, 11, 20));
            DateTime dt = DateTime.newInstance(2017, 11, 20);        
            System.assertEquals(dt, rt);
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestgetFirstDayOfMonth() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            Date rt = SalesforceUtils.getFirstDayOfMonth(Date.newInstance(2017, 11, 20));
            Date dt = Date.newInstance(2017, 11, 1);        
            System.assertEquals(dt, rt);
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestgetLastDayOfMonth() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            Date rt = SalesforceUtils.getLastDayOfMonth(Date.newInstance(2017, 11, 20));
            Date dt = Date.newInstance(2017, 11, 30);        
            System.assertEquals(dt, rt);
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestgetFirstDayOfMonthDt() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            DateTime rt = SalesforceUtils.getFirstDayOfMonthDt(Date.newInstance(2017, 11, 20));
            DateTime dt = DateTime.newInstance(2017, 11, 1);        
            System.assertEquals(dt, rt);
            
            Test.StopTest();
        }
    }
    
    static testMethod void unitTestgetLastDayOfMonthDt() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            //Scenario 1
            DateTime rt = SalesforceUtils.getLastDayOfMonthDt(Date.newInstance(2017, 11, 20));
            DateTime dt = DateTime.newInstance(2017, 11, 30);        
            System.assertEquals(dt, rt);
            
            Test.StopTest();
        }
    }
    
    
}