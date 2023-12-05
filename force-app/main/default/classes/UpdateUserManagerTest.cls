/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UpdateUserManagerTest {
    
    static testMethod void updateUserManagerOnInsert(){
        Profile p = [SELECT Id FROM Profile where name = 'Employee' limit 1]; 
        
        //insert ManagerUser         
        UtilityTestData.mUserData.put('ProfileId', p.id);
        UtilityTestData.mUserData.put('ManagerEmployeeNumber__c', '');
        UtilityTestData.mUserData.put('EmployeeNumber', '12345');
           
        sObject sObj = new User();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        List<User> managerUsr = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //insert User 
        UtilityTestData.mUserData.put('Email', 'test@test.com');
        UtilityTestData.mUserData.put('ManagerEmployeeNumber__c', '12345');
        UtilityTestData.mUserData.put('Username', 'usr_temp1@testorg.com');
        UtilityTestData.mUserData.put('CommunityNickname', 'abc');
        UtilityTestData.mUserData.put('EmployeeNumber', '123');
        
        sObject sObj1 = new User();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData);
        List<User> usr = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        System.assertEquals(usr.size(),1);
        
        System.runAs(usr[0]) {
            // The following code runs as user 'usr
        }
        User userManagerDetails = [select id, managerID from user where id =: usr ];
        //Assert to check if user's manager id is same as manager id. This comparison is based on manager employee number on user.
        //If manager user's employee number is same as user's employee number then add manager user's id to user's manager ID
        System.assertEquals(userManagerDetails.ManagerId, managerUsr[0].Id);  
   }
    
   static testMethod void updateUserManagerOnUpdate(){
        Profile p = [SELECT Id FROM Profile where name = 'Employee' limit 1]; 
        
        //insert ManagerUser
        UtilityTestData.mUserData.put('ProfileId', p.id);
        UtilityTestData.mUserData.put('ManagerEmployeeNumber__c', '');
        UtilityTestData.mUserData.put('EmployeeNumber', '12345');
           
        sObject sObj = new User();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        List<User> managerUsr = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //insert User
        UtilityTestData.mUserData.put('Email', 'test@test.com');
        UtilityTestData.mUserData.put('ManagerEmployeeNumber__c', '1234');
        UtilityTestData.mUserData.put('Username', 'usr_temp1@testorg.com');
        UtilityTestData.mUserData.put('CommunityNickname', 'abc');
        UtilityTestData.mUserData.put('EmployeeNumber', '');
         
        sObject sObj1 = new User();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData);
       
        List<User> usr = (List<User>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        //update user's manager employee number to existing manager's employee number
        usr[0].ManagerEmployeeNumber__c = '12345';
        update usr;
        
        System.assertEquals(usr.size(),1);
       
        System.runAs(usr[0]) {
            // The following code runs as user usr
        }
        User userManagerDetails = [select id, managerID from user where id =: usr];
        //Assert to check if user's manager id is same as manager id. This comparison is based on manager employee number on user.
        //If manager user's employee number is same as user's employee number then add manager user's id to user's manager ID
        System.assertEquals(userManagerDetails.ManagerId, managerUsr[0].Id);  
   }
   
}