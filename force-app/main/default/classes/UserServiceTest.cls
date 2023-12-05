/*
@created by       : balajip
@created on       : 03/31/2023
@Purpose          : Test class for the class UserService
@JIRA             : I2RT-7839
    
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
Isha Bansal   06/09/2023                      Coverage increased 
*/
@isTest(SeeAllData=false)
public class UserServiceTest {

    @testSetup
    static void setupObjectTestData() {

        SObject accobj = new Account(); //for UAT error from psa class
        UtilityTestData.mAccountData.put('Name', 'Informatica LLC PSA');       
        accobj = UtilityTest.putFieldRecord(accobj, UtilityTestData.mAccountData);
        List<Account> lAccountList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accobj});

        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name='Employee'];	        
        //create user	
        UtilityTestData.mUserData.put('ProfileId', userProfile.id + '');	
        UtilityTestData.mUserData.put('Username', 'ftouser@informatica.com');	
        UtilityTestData.mUserData.put('CommunityNickname', 'ftoUser');	
        UtilityTestData.mUserData.put('TimeZoneSidKey', 'America/Los_Angeles');	
        UtilityTestData.mUserData.put('LocaleSidKey', 'en_US');	
        UtilityTestData.mUserData.put('EmailEncodingKey', 'ISO-8859-1');	
        UtilityTestData.mUserData.put('LanguageLocaleKey', 'en_US'); 	
        UtilityTestData.mUserData.put('LastName', 'fto user');	
        UtilityTestData.mUserData.put('Email', 'ftouser@infa.com');	
        UtilityTestData.mUserData.put('Alias', 'ftouser');	
        UtilityTestData.mUserData.put('IsActive', 'TRUE');	

        SObject usr = new User();
        usr = UtilityTest.putFieldRecord(usr, UtilityTestData.mUserData);
        List<User> lstUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{usr});

        UtilityTestData.mEventData.put('Subject', 'FTO');
        UtilityTestData.mEventData.put('Type', 'FTO');
        UtilityTestData.mEventData.put('OwnerId', lstUser[0].Id);
      UtilityTestData.mEventData.put('ActivityDateTime', String.valueOf(System.now()-2));
        UtilityTestData.mEventData.put('StartDateTime', String.valueOf(System.now() -2));
        UtilityTestData.mEventData.put('EndDateTime', String.valueOf(System.now() +2));
        
        UtilityTestData.mEventData.put('IsAllDayEvent__c', 'TRUE');
        UtilityTestData.mEventData.put('IsAllDayEvent', 'TRUE');
       UtilityTestData.mEventData.put('DurationInMinutes', '7200');

        SObject sObj = new Event();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEventData);
        List<Event> lEvent = (List<Event>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }

    @isTest 
    public static void testAll(){

        Account acc=[select ID,name from account where Name='Informatica LLC PSA'];
        system.debug(acc);
        UserService.updateFTO();
    }
}