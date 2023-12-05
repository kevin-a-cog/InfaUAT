/*
Change History
****************************************************************************************************
ModifiedBy	Date		Jira No.    Tag     Description                                         
****************************************************************************************************
balajip		02/03/2023	I2RT-7643   T01     added methods testSupportEngagement and createTestUser to improve coverage
*/

@IsTest 
public class EngagementTriggerHandlerTest {
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Product Request').getRecordTypeId();
    static Id gemsengRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() 
    {
		List<Account> accList = new List<Account>();
		List<User> userList = UtilityTest.createUsersforPRM();
		User adminUser = userList[0];
		User sogUser = userList[1];
		User psmUser = userList[2];
			
        system.runAs(adminUser){        
        	//create SI partner account
        	UtilityTestData.mAccountData.put('Name','Software reseller and SI');
        	UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
        	UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
        	UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
        	UtilityTestData.mAccountData.put('Contract_Signed__c','true');
        	UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
        	UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
        	UtilityTestData.mAccountData.put('Year_Founded__c','2017');
        	UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
        	UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
        	UtilityTestData.mAccountData.put('NumberOfEmployees','1');
        	UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
        	UtilityTestData.mAccountData.put('Partner_Type__c','Systems Integrator');
        	sObject partnerAcc1 = new Account();
        	partnerAcc1 = UtilityTest.putFieldRecord(partnerAcc1, UtilityTestData.mAccountData);
        
        	//create SI partner account
        	UtilityTestData.mAccountData.put('Name','Software reseller and SI 2');
        	sObject partnerAcc2 = new Account();
        	partnerAcc2 = UtilityTest.putFieldRecord(partnerAcc2, UtilityTestData.mAccountData);
        
        	//Add all accounts to acclist
        	accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1,partnerAcc2});
        }
        List<User> prtnrUserList = new List<User>();
        List<Contact> contactList = new List<Contact>();        
        system.runAs(adminUser){
            
            //create partner contact
        	UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
        	UtilityTestData.mContactData.put('Is_Primary__c','true');
        	UtilityTestData.mContactData.put('Is_Active__c','true');
        	UtilityTestData.mContactData.put('FirstName','Contact');
        	UtilityTestData.mContactData.put('Email','Contact1@test.com');
        	sObject contactSobj1 = new Contact();
        	contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
            
            //create partner contact
        	UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
        	UtilityTestData.mContactData.put('Email','Contact2@test.com');
        	sObject contactSobj2 = new Contact();
        	contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
            
            //create partner contact
        	UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
        	UtilityTestData.mContactData.put('Email','Contact3@test.com');
        	sObject contactSobj3 = new Contact();
        	contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
            
            //create partner contact
        	UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        	UtilityTestData.mContactData.put('Email','Contacta@test.com');
        	sObject contactSobja = new Contact();
        	contactSobja = UtilityTest.putFieldRecord(contactSobja, UtilityTestData.mContactData);
            
            //create partner contact
        	UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        	UtilityTestData.mContactData.put('Email','Contactb@test.com');
        	sObject contactSobjb = new Contact();
        	contactSobjb = UtilityTest.putFieldRecord(contactSobjb, UtilityTestData.mContactData);
            
            //create partner contact
        	UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        	UtilityTestData.mContactData.put('Email','Contactc@test.com');
        	sObject contactSobjc = new Contact();
        	contactSobjc = UtilityTest.putFieldRecord(contactSobjc, UtilityTestData.mContactData);
            
            
            system.runAs(adminUser){
            	contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobjb,contactSobj2,contactSobj3,contactSobja,contactSobjc});
            }
            
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
        	
			for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
				userRoleMap.put(role.PortalAccountId, role.Id);
			}
            
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
            
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp1@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp1');
        	UtilityTestData.mUserData.put('ContactId',contactList[0].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp1@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp1');
        	UtilityTestData.mUserData.put('LastName','user1');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
			UtilityTestData.mUserData.put('UserType','PowerPartner');
        	// Initialize a employee user sobject
        	sObject prtnrUser1 = new User();
        	prtnrUser1 = UtilityTest.putFieldRecord(prtnrUser1, UtilityTestData.mUserData);
            
			UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp2@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp2');
        	UtilityTestData.mUserData.put('ContactId',contactList[1].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp2@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp2');
        	UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
			UtilityTestData.mUserData.put('UserType','PowerPartner');
        	// Initialize a user sobject
        	sObject prtnrUser2 = new User();
        	prtnrUser2 = UtilityTest.putFieldRecord(prtnrUser2, UtilityTestData.mUserData);

            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp3@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp3');
        	UtilityTestData.mUserData.put('ContactId',contactList[2].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp3@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp3');
        	UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
			UtilityTestData.mUserData.put('UserType','PowerPartner');
        	// Initialize a employee user sobject
        	sObject prtnrUser3 = new User();
        	prtnrUser3 = UtilityTest.putFieldRecord(prtnrUser3, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp4@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp4');
        	UtilityTestData.mUserData.put('ContactId',contactList[3].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp4@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp4');
        	UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
			UtilityTestData.mUserData.put('UserType','PowerPartner');
        	// Initialize a user sobject
        	sObject prtnrUser4 = new User();
        	prtnrUser4 = UtilityTest.putFieldRecord(prtnrUser4, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp5@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp5');
        	UtilityTestData.mUserData.put('ContactId',contactList[4].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp5@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp5');
        	UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
			UtilityTestData.mUserData.put('UserType','PowerPartner');
        	// Initialize a user sobject
        	sObject prtnrUser5 = new User();
        	prtnrUser5 = UtilityTest.putFieldRecord(prtnrUser5, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp6@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp6');
        	UtilityTestData.mUserData.put('ContactId',contactList[5].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp6@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp6');
        	UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
			UtilityTestData.mUserData.put('UserType','PowerPartner');
        	// Initialize a user sobject
        	sObject prtnrUser6 = new User();
        	prtnrUser6 = UtilityTest.putFieldRecord(prtnrUser6, UtilityTestData.mUserData);
            
        
            
            prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{prtnrUser1,prtnrUser2,prtnrUser3,prtnrUser4,prtnrUser5,prtnrUser6});

			PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
           		insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps1.Id );
            PermissionSet psb = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
           		insert new PermissionSetAssignment(AssigneeId = prtnrUserList[1].id, PermissionSetId = psb.Id );
            PermissionSet psb2 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
           		insert new PermissionSetAssignment(AssigneeId = prtnrUserList[2].id, PermissionSetId = psb2.Id );
            PermissionSet psb3 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
           		insert new PermissionSetAssignment(AssigneeId = prtnrUserList[3].id, PermissionSetId = psb3.Id );
            PermissionSet psb4 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
           		insert new PermissionSetAssignment(AssigneeId = prtnrUserList[4].id, PermissionSetId = psb4.Id );
            PermissionSet psb5 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
           		insert new PermissionSetAssignment(AssigneeId = prtnrUserList[5].id, PermissionSetId = psb5.Id );
            
        }
    }
    //Covers Account populating when engagement is created by Partner user
    //and Apex sharing on insert and update of engagement object
    static testMethod void allPRMEngagmentTriggerMethods()
    {
        
        List<User> userList = [select id from user where username = 'mtestpp1@m.t' limit 1];
		User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [select id,Name from Account];
        system.assert(userList[0].Id!=null,'The record not queried');
        system.assert(adminUser.Id!=null,'The record not queried');
        system.assert(accList[0].Id!=null,'The record not queried');
        
       
        //Run as Partner user so that the Account is pre-populated.
        system.runAs(userList[0]){
            UtilityTestData.mEngagementData.put('Name','Test Engagement Partner');
       		UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId); 
        	sObject engmntPrtnr = new Engagement__c();
            List<Engagement__c> engmntListPrtnr = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmntPrtnr});
            System.assertNotEquals(engmntListPrtnr[0].Id,null);
        }
        Engagement__c insertedEngmnt = [select id,Account__c from Engagement__c];
		system.assertEquals(insertedEngmnt.Account__c, accList[0].id);
		
		//fetch the share records
		list<Engagement__Share> eng_shareList = [select id,userorgroupid,AccessLevel from Engagement__Share];
		system.assertEquals(eng_shareList.size(), 3);
		
        UtilityTestData.mEngagementData.put('Name','Test Engagement 1');
       	UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId);
        UtilityTestData.mEngagementData.put('Account__c',accList[0].id);   
        sObject engmnt = new Engagement__c();
        engmnt = UtilityTest.putFieldRecord(engmnt, UtilityTestData.mEngagementData);
        
        //Run as admin to update the account on engagement so that the apexSharingUpdate is covered.
		List<Engagement__c> upEngmntList = new List<Engagement__c>();
		system.runAs(adminUser){
        	List<Engagement__c> engmntList = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engmnt});
           	engmntList[0].Name = 'test sd';
           	engmntList[0].Account__c = accList[1].Id;
        	upEngmntList = (List<Engagement__c>) UtilityTest.makeUpdate(engmntList);
            System.assertEquals(upEngmntList[0].Account__c,accList[1].Id);
        }
		//fetch the share records
		list<Engagement__Share> updatedEng_shareList = [select id,userorgroupid,AccessLevel from Engagement__Share where parentid = :upEngmntList[0].id];
		system.assertEquals(updatedEng_shareList.size(), 3);
    }
    
    //T01
	static testMethod void testSupportEngagement(){
        //User usrObj = createTestUser('System Administrator', true);
        //System.runAs(usrObj) {
        Test.startTest();
        List<Account> lAccount = [select id,Name from Account limit 1];
        List<User> lUser = [Select Id from User limit 1];
        
        //Engagement
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('RecordTypeId', gemsengRecTypeId);
        UtilityTestData.mEngagementData.put('Status__c','Approved');
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);    
        
		List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
        lEngagement[0].CSM_Summary__c= 'Test';
         if(lUser[0] <> null){
             lEngagement[0].OwnerId = UserInfo.getUserId();
         }
        update lEngagement;
        
        Test.stopTest();
        //}
    }
   
    /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}