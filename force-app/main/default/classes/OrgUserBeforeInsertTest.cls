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
private class OrgUserBeforeInsertTest {
	
    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        /*
        Profile pr = [select Name from Profile where name='Employee'];
        UtilityTestData.mUserData.put('profileid', pr.Id);
        sObject sObj = new User();
        User userObj = (User)UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        List<User> lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj});
        */
        
        User userObj = [select Id, Name from User where Profile.Name = 'Employee' and IsActive = true limit 1];
        
        sObject sObj = new Lead();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);  
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});
                
        sObj = new Account();
        // Call methos and pass sObject and data maps
        // This utility method will populate all the fields data according to the Map passed
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        // Set all the required fields and dynamic ids in Map
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //public static Map<String, String> mOrgUserData = new Map<String, String>{'Name' => 'test org user','LastName' => 'LastName', 'Company' => 'Test Company', 
        //                                                                  'Email' => 'testemailforlead@infa.com', 'Status' => 'New','Phone' => '9999999999', 'Country' => 'India'};
    
        //
    }
}