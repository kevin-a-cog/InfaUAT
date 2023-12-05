@isTest(SeeAllData=false)
private class NotifyMqlOnNewLeadTest {
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();

    static void NonsetupTestData(){

        List<Territory2Model> lstTerritoryModel = 
        [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        sObject terr = new Territory2();
        UtilityTestData.mTerritoryData.put('DeveloperName', 'AP_AS_AS_MAM_TEST'); 
        UtilityTestData.mTerritoryData.put('Territory2ModelId', lstTerritoryModel[0].Id);
        UtilityTestData.mTerritoryData.put('Name', 'AP_AS_AS_MAM_TEST');
        UtilityTestData.mTerritoryData.put('Territory2TypeId', terriType[0].id);
        terr = (Territory2)UtilityTest.putFieldRecord(terr, UtilityTestData.mTerritoryData); 
        List<Territory2>  lTerr = (List<Territory2>) UtilityTest.makeInsert(new List<sObject>{terr});
    }

    @testSetup
    static void setupObjectTestData() 
    {
        User adminUserObj = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        system.runAs(adminUserObj){
            NonsetupTestData();
        }
        Territory2  terr=[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAM_TEST'];

        //System.debug('$$$$$$$'+terr);

        Profile pr = [select ID,Name from Profile where name='System Administrator'];

        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser'); 
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing1');
        UtilityTestData.mUserData.put('Alias', 'usrTemp1');
        UtilityTestData.mUserData.put('Email', 'usr_temp1@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp1@testorg.com');
        sObject sObj1 = new User();
        User userObj1 = (User)UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData); 

        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser1');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing2');
        UtilityTestData.mUserData.put('Alias', 'usrTemp2');
        UtilityTestData.mUserData.put('Email', 'usr_temp2@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp2@testorg.com');
        sObject sObj2 = new User();
        User userObj2 = (User)UtilityTest.putFieldRecord(sObj2, UtilityTestData.mUserData); 
            
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser2');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing3');
        UtilityTestData.mUserData.put('Alias', 'usrTemp3');
        UtilityTestData.mUserData.put('Email', 'usr_temp3@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp3@testorg.com');
        sObject sObj3 = new User();
        User userObj3 = (User)UtilityTest.putFieldRecord(sObj3, UtilityTestData.mUserData);
        List<User> lUser = new List<User>();
        //system.runAs(adminUserObj){
            lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj1,userObj2,userObj3});
        //}
                
        //System.debug('$$$$$$$'+lUser);

        UtilityTestData.mUserTerritory2AssociationData.put('RoleInTerritory2','CFR');
        if(terr != null)
            UtilityTestData.mUserTerritory2AssociationData.put('Territory2Id',terr.Id);
        UtilityTestData.mUserTerritory2AssociationData.put('UserId',lUser[0].Id);
        UtilityTestData.mUserTerritory2AssociationData.put('IsActive ','true');
        sObject sObj4 = new UserTerritory2Association();
        UserTerritory2Association terrMem1 = (UserTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserTerritory2AssociationData);
        
        UtilityTestData.mUserTerritory2AssociationData.put('RoleInTerritory2','BDM');
        if(terr != null)
            UtilityTestData.mUserTerritory2AssociationData.put('Territory2Id',terr.Id);
        UtilityTestData.mUserTerritory2AssociationData.put('UserId',lUser[1].Id);
        UtilityTestData.mUserTerritory2AssociationData.put('IsActive ','true');
        sObj4 = new UserTerritory2Association();
        UserTerritory2Association terrMem2 = (UserTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserTerritory2AssociationData);

        system.runAs(adminUserObj){
            List<UserTerritory2Association>  lTerrMem = (List<UserTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{terrMem1,terrMem2});
        }
        
        
        sObject sObj = new Account();
        if(terr != null)
            UtilityTestData.mAccountData.put('Territory_Name__c',(String)terr.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        UtilityTestData.mObjectTerritory2AssociationData.put('AssociationCause','Territory2Manual');
        UtilityTestData.mObjectTerritory2AssociationData.put('ObjectId',lAccount[0].Id);
        UtilityTestData.mObjectTerritory2AssociationData.put('SobjectType','Account');
        if(terr != null)
            UtilityTestData.mObjectTerritory2AssociationData.put('Territory2Id',terr.Id);
        sObj4 = new ObjectTerritory2Association();
        ObjectTerritory2Association objTerrAssoc = (ObjectTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mObjectTerritory2AssociationData);
        
        System.debug('$$$$'+objTerrAssoc);
        List<ObjectTerritory2Association>  lObjTerrAssoc = (List<ObjectTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{objTerrAssoc});

        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('Account__c',lAccount[0].Id);
        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
        List<Account> lLead = (List<Account>) UtilityTest.makeInsert(new List<sObject>{lead});

        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact(Email = 'testingduplicate1Email@test.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});        
    }
    
    @isTest
    static void testNotificationForNewLeads()
    {   
        test.startTest();
            Map<Id,Lead> leads=new Map<Id,Lead>([Select Id,Name from Lead]);
            notifyMqlOnNewLead.notifyOnNewMql(new List<Id>(leads.keySet()));
        test.stopTest();
    } 
    
    @isTest
    static void testNotificationForNewContacts()
    {   
        test.startTest();
            Map<Id,Contact> con=new Map<Id,Contact>([Select Id,Name from Contact]);
            notifyMqlOnNewLead.notifyOnNewMql(new List<Id>(con.keySet()));
        test.stopTest();
    }     
}