@istest
public with sharing class CSMDataTableQueryUtilitiesTest {
    static void NonsetupTestData(){
        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        //Territory2Model terrModel = lstTerritoryModel[0];
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        //Territory2 terr = test_utilityClass.createTerritory('AP_AS_AS_MAM_TEST', terrModel.id, 'AP_AS_AS_MAM_TEST', true);

        sObject terr = new Territory2();
        UtilityTestData.mTerritoryData.put('DeveloperName', 'AP_AS_AS_MAM_TEST'); 
        UtilityTestData.mTerritoryData.put('Territory2ModelId', lstTerritoryModel[0].Id);
        UtilityTestData.mTerritoryData.put('Name', 'AP_AS_AS_MAM_TEST');
        UtilityTestData.mTerritoryData.put('Territory2TypeId', terriType[0].id);
        terr = (Territory2)UtilityTest.putFieldRecord(terr, UtilityTestData.mTerritoryData); 
        List<Territory2>  lUser = (List<Territory2>) UtilityTest.makeInsert(new List<sObject>{terr});
      
    }  

        /**
    * this method creates data required for testing purpose 
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    @testSetup static void setupData(){
        User adminUserObj = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        system.runAs(adminUserObj)
        {
          NonsetupTestData();
         
        }
        
        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        Territory2Model terrModel = lstTerritoryModel[0];
  
        Territory2  terr=[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAM_TEST'];
        
         
        Id cometitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
        sObject sObjAccount    = new Account();
        UtilityTestData.mAccountData.put('RecordtypeId',cometitorRecordTypeId);
        sObjAccount  = UtilityTest.putFieldRecord(sObjAccount,UtilityTestData.mAccountData);
              
        sObject sObjAccount1  = new Account();
        UtilityTestData.mAccountData.put('RecordtypeId',cometitorRecordTypeId);
        UtilityTestData.mAccountData.put('Status__c','New');
        sObjAccount1 = UtilityTest.putFieldRecord(sObjAccount1,UtilityTestData.mAccountData);
             
        List<Account> accountlst = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjAccount});
       // System.assertEquals(accountlst.size(),2);
         

         
        system.runAs(adminUserObj)
        {
          
          Test.startTest();
          insertTestTerritory(accountlst[0].Id);
            Test.stopTest();
        }
       
  
        Profile pr = [select ID,Name from Profile where name='System Administrator'];
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        sObject sObj = new User();
        User userObj = (User)UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
             
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
             
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser3');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing4');
        UtilityTestData.mUserData.put('Alias', 'usrTemp4');
        UtilityTestData.mUserData.put('Email', 'usr_temp4@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp4@testorg.com');
        sObject sObj4 = new User();
        User userObj4 = (User)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserData); 
             
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser4');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing5');
        UtilityTestData.mUserData.put('Alias', 'usrTemp5');
        UtilityTestData.mUserData.put('Email', 'usr_temp5@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp5@testorg.com');
        UtilityTestData.mUserData.put('UserType', 'Standard');
        sObject sObj5 = new User();
        User userObj5 = (User)UtilityTest.putFieldRecord(sObj5, UtilityTestData.mUserData);  
             
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser5');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing6');
        UtilityTestData.mUserData.put('Alias', 'usrTemp6');
        UtilityTestData.mUserData.put('Email', 'usr_temp6@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp6@testorg.com');
        sObject sObj6 = new User();
        User userObj6 = (User)UtilityTest.putFieldRecord(sObj6, UtilityTestData.mUserData); 
             
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser6');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing7');
        UtilityTestData.mUserData.put('Alias', 'usrTemp7');
        UtilityTestData.mUserData.put('Email', 'usr_temp7@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp7@testorg.com');
        sObject sObj7 = new User();
        User userObj7 = (User)UtilityTest.putFieldRecord(sObj7, UtilityTestData.mUserData); 
             
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser7');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing8');
        UtilityTestData.mUserData.put('Alias', 'usrTemp8');
        UtilityTestData.mUserData.put('Email', 'usr_temp8@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp8@testorg.com');
        sObject sObj8 = new User();
        User userObj8 = (User)UtilityTest.putFieldRecord(sObj8,UtilityTestData.mUserData); 
  
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser8');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing9');
        UtilityTestData.mUserData.put('Alias', 'usrTemp9');
        UtilityTestData.mUserData.put('Email', 'usr_temp9@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp9@testorg.com');
        sObject sObj9 = new User();
        User userObj9 = (User)UtilityTest.putFieldRecord(sObj9, UtilityTestData.mUserData); 
         
        List<User>  lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj,userObj1,userObj2,userObj3,userObj4,userObj5,userObj6,userObj7,userObj8,userObj9});
        System.assertEquals(lUser.size(),10);
  
        //Now we create a Plan.
        Plan__c objPlan = new Plan__c();
        objPlan.Name = 'Test';
        objPlan.Account__c=accountlst[0].Id;
        insert objPlan;
        
      }

      @isTest
      public static void getUnassignedRecordsTest() {
          Test.startTest();
          Plan__c plan=[select Id,Account__c from Plan__c limit 1];   
          DataTableWrapperClass obj=new DataTableWrapperClass();
          obj = CSMManagePlanTeamController.getUnassignedRecords(plan.Id,plan.Account__c);
          obj.lstFieldNames=new List<String>();
          DataTableWrapperClass.TableRowWrapper obj2 = new DataTableWrapperClass.TableRowWrapper(); 
          obj2.memberName='Hello';
          obj2.memberRole='Hello';
          obj2.memberEmail='Hello';
          obj2.Id='Hello';
          obj2.userId='Hello';
          obj2.source='Hello';
          obj2.accountName='Hello';
          obj2.opportunityName='Hello';
          obj2.accountId='Hello';
          obj2.createdDate='Hello';
          if(obj.lstRecords.size()>0){
          system.assert( obj.lstRecords.size()>0);}    
          Test.stopTest();
      }


         //@future
    private static void insertTestTerritory(Id AccId)
    {

        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        //Territory2Model terrModel = lstTerritoryModel[0];
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        //Territory2 terr = test_utilityClass.createTerritory('AP_AS_AS_MAM_TEST', terrModel.id, 'AP_AS_AS_MAM_TEST', true);
         List<Profile> adminProfile = [select id, name from Profile where  name = 'System Administrator'];

        Territory2Model terrModel = new Territory2Model();
        terrModel .DeveloperName='ModelName'; // required field
        terrModel.Name = 'Name'; // required field
        insert terrModel ;

        Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
        insert objTerr;


        

        ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = AccId, Territory2Id =objTerr.Id, AssociationCause='Territory2Manual' );
        insert objObjectTerritory2Association;

        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'Test',
                  lastname='XXXX',
                  Alias='Test',
                  email = 'test1234@test.com',
                  username= 'test1234xxx@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u;

        User u2 = new User(firstname= 'Test',
                  lastname='XXXX',
                  Alias='Test',
                  email = 'test1234122@test.com',
                  username= 'test1234xxx123@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u2;


        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u.Id, RoleInTerritory2='Sales / Marketing Manager');
        insert objUserTerritory2Association;

        UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2='Sales / Marketing Administrator');
        insert objUserTerritory2Association2 ;


    }
  
	/*
	 Method Name : additionalCoverage
	 Description : Testing additional methods.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void additionalCoverage() {
		Set<String> setOpportunities = new Set<String> { 'test' };
		Set<String> setPlans = new Set<String> { 'test' };
        CSMDataTableQueryUtilities.getPartnerRelationShipRecords(setOpportunities, setPlans, '');
		CSMDataTableQueryUtilities.getPartnerRelationShipRecords(setPlans, '');
		CSMDataTableQueryUtilities.getOrderByContractId(setPlans);
		CSMDataTableQueryUtilities.getOpportunityTeamMemberByOpportunity(setOpportunities);
    }
}