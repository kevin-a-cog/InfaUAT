/*
@created by       : SONIYA CHOUHAN
@created on       : 01/25/2021
@Purpose          : Test class for UserTriggerHandler

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public with sharing class UserTriggerHandlerTestTemp {
    
    @testSetup
    static void testSetup() {
        //Create Account with Name = Informatica LLC PSA
        SObject sObj;
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Informatica LLC PSA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);         
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});        
    }
    
    @isTest 
    public static void testAfterInsert() {
        set<string> setProfiles = new set<string>();
        set<string> setUserRoles = new set<string>();
        
        Profile adminProfile;
        Profile sogProfile;
        UserRole ur;
        UserRole urContractor;
        setProfiles.add('System Administrator');
        setProfiles.add('Employee');
        setUserRoles.add('PS_Administrator');
        //setUserRoles.add('PS_Sub_Contractor');
        setUserRoles.add('PS_Operations');
        
        for(Profile oProfile:[SELECT Id, Name FROM Profile WHERE Name in :setProfiles]){
            if(oProfile.Name=='System Administrator'){
                adminProfile = oProfile;
            }
            else if(oProfile.Name=='Employee'){
                sogProfile = oProfile;
            }
        }
        
        for(UserRole oUserRole:[SELECT Id,DeveloperName FROM UserRole Where DeveloperName in :setUserRoles]){
            if(oUserRole.DeveloperName=='PS_Administrator'){
                ur = oUserRole;
            }
            else if(oUserRole.DeveloperName=='PS_Operations'){
                urContractor = oUserRole;
            }
        }
        
        //create manager user
        UtilityTestData.mUserData.put('ProfileId',adminProfile.id+'');
        UtilityTestData.mUserData.put('ContactId',NULL); 
        UtilityTestData.mUserData.put('Username','prmTestMgrAdmn@m.t');
        UtilityTestData.mUserData.put('Email','prmTestMgrAdmn@m.t');
        UtilityTestData.mUserData.put('Alias','mngr');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('LastName','user');
        UtilityTestData.mUserData.put('FirstName','Manager');
        UtilityTestData.mUserData.put('CommunityNickname','madmnmngr');
        sObject mngrUser = new User();
        mngrUser = UtilityTest.putFieldRecord(mngrUser, UtilityTestData.mUserData);        
        List<User> mngrList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{mngrUser});
        
        //create admin user
        UtilityTestData.mUserData.put('Username','prmTestAdmn@m.t');
        UtilityTestData.mUserData.put('Manager ',mngrList[0].id+'');
        UtilityTestData.mUserData.put('Email','prmTestAdmn@m.t');
        UtilityTestData.mUserData.put('Alias','admin');
        UtilityTestData.mUserData.put('FirstName','Admin');
        UtilityTestData.mUserData.put('UserRoleId',ur.Id);
        UtilityTestData.mUserData.put('CommunityNickname','madmn');
        sObject adminUser = new User();
        test.startTest();
        adminUser = UtilityTest.putFieldRecord(adminUser, UtilityTestData.mUserData);
        
        UtilityTestData.mUserData.put('Username','prmTestAdmn2@m.t');
        UtilityTestData.mUserData.put('Manager ',mngrList[0].id+'');
        UtilityTestData.mUserData.put('Email','prmTestAdmn2@m.t');
        UtilityTestData.mUserData.put('Alias','admin2');
        UtilityTestData.mUserData.put('FirstName','Admin2');
        UtilityTestData.mUserData.put('UserRoleId',urContractor.Id);
        UtilityTestData.mUserData.put('CommunityNickname','madmn2');
        sObject ContractorUser = new User();
        
        ContractorUser = UtilityTest.putFieldRecord(ContractorUser, UtilityTestData.mUserData);
        
        
        UtilityTestData.mUserData.put('ProfileId',sogProfile.id+'');
        UtilityTestData.mUserData.put('ContactId',NULL); 
        UtilityTestData.mUserData.put('Username','prmTestSog@m.t');
        UtilityTestData.mUserData.put('Manager ',mngrList[0].id+'');
        UtilityTestData.mUserData.put('CommunityNickname','sogUser');
        
        sObject SOGuserSobj = new User();
        SOGuserSobj = UtilityTest.putFieldRecord(SOGuserSobj, UtilityTestData.mUserData);
        User sogUser = (User)SOGuserSobj;
        
        
        List<User> adminUserList = new List<User>();
        adminUserList.add((user)adminUser);
        adminUserList.add((user)ContractorUser);
        adminUserList.add(sogUser);
        insert adminUserList;
        
        adminUserList[0].IsActive = false;
        update adminUserList[0];
        adminUserList[0].IsActive = true;
        update adminUserList[0];
        adminUserList[0].UserRoleId = urContractor.Id;
        update adminUserList[0];
        test.stopTest();

    }

}