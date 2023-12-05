/*
Class:          ProjectRegTriggerHandlerTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for ProjectRegistrationTriggerHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest(SeeAllData=false)
public class ProjectRegTriggerHandlerTest {
    
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeId1 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('VAD').RecordTypeId;
    static Id PartnerProgramRecTypeId2 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    static Id ChannelProgramLevelRecTypeId = Schema.SObjectType.ChannelProgramLevel.RecordTypeInfosByName.get('AIR').RecordTypeId;
    
    @testSetup
    static void setupObjectTestData() 
	{
		List<User> userList = UtilityTest.createUsersforPRM();
		User adminUser = userList[0];
		User sogUser = userList[1];
		User psmUser = userList[2];
    	
        List<Account> accList = new List<Account>();
        system.runAs(adminUser)
		{
        	//create reseller partner account
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
        	UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
        	sObject partnerAcc1 = new Account();
        	partnerAcc1 = UtilityTest.putFieldRecord(partnerAcc1, UtilityTestData.mAccountData);
        	
        	//create another reseller partner account
        	UtilityTestData.mAccountData.put('Name','Software reseller and SI2');
        	UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
        	sObject partnerAcc2 = new Account();
        	partnerAcc2 = UtilityTest.putFieldRecord(partnerAcc2, UtilityTestData.mAccountData);
        	
        	//Add all accounts to acclist
        	accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1,partnerAcc2});
			
			UtilityTestData.mAccountTeamMember.put('AccountId',accList[0].id);
			UtilityTestData.mAccountTeamMember.put('UserId',psmUser.id);
			UtilityTestData.mAccountTeamMember.put('TeamMemberRole','PSM');
	
			sObject Teammemberad=new AccountTeamMember();
			Teammemberad = UtilityTest.putFieldRecord(Teammemberad, UtilityTestData.mAccountTeamMember);
			List<AccountTeamMember> accTeamList = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{Teammemberad});		
			
		}
      
        List<User> prtnrUserList = new List<User>();	
        system.runAs(adminUser)
		{
        	//create partner contact of type Reseller
        	UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
        	UtilityTestData.mContactData.put('Is_Primary__c','true');
        	UtilityTestData.mContactData.put('Is_Active__c','true');
        	UtilityTestData.mContactData.put('FirstName','Contact');
        	UtilityTestData.mContactData.put('Email','Contact1@test.com');
        	sObject contactSobj1 = new Contact();
        	contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
        	
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
        	UtilityTestData.mContactData.put('Email','Contact2@test.com');
        	sObject contactSobj2 = new Contact();
        	contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
        	UtilityTestData.mContactData.put('Email','Contact3@test.com');
        	sObject contactSobj3 = new Contact();
        	contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
            
            //create partner contact of type Reseller
        	UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        	UtilityTestData.mContactData.put('Email','Contacta@test.com');
        	sObject contactSobja = new Contact();
        	contactSobja = UtilityTest.putFieldRecord(contactSobja, UtilityTestData.mContactData);
            
            //create partner contact of type Reseller
        	UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        	UtilityTestData.mContactData.put('Email','Contactb@test.com');
        	sObject contactSobjb = new Contact();
        	contactSobjb = UtilityTest.putFieldRecord(contactSobjb, UtilityTestData.mContactData);
            
            //create partner contact of type Reseller
        	UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        	UtilityTestData.mContactData.put('Email','Contactc@test.com');
        	sObject contactSobjc = new Contact();
        	contactSobjc = UtilityTest.putFieldRecord(contactSobjc, UtilityTestData.mContactData);
            
        	List<Contact> contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobj2,contactSobj3,contactSobja,contactSobjb,contactSobjc});
		
        	Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
        	
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
        	
			for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
				userRoleMap.put(role.PortalAccountId, role.Id);
			}
            
        	UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp1@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp1');
        	UtilityTestData.mUserData.put('ContactId',contactList[0].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp1@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp1');
        	UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        	UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        	UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        	UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
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
        	// Initialize a employee user sobject
        	sObject prtnrUser2 = new User();
        	prtnrUser2 = UtilityTest.putFieldRecord(prtnrUser2, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestpp3@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestpp3');
        	UtilityTestData.mUserData.put('ContactId',contactList[2].id+'');
        	UtilityTestData.mUserData.put('Email','mtestpp3@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestpp3');
        	UtilityTestData.mUserData.put('LastName','user3');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
        	// Initialize a employee user sobject
        	sObject prtnrUser3 = new User();
        	prtnrUser3 = UtilityTest.putFieldRecord(prtnrUser3, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestppa@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestppa');
        	UtilityTestData.mUserData.put('ContactId',contactList[3].id+'');
        	UtilityTestData.mUserData.put('Email','mtestppa@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestppa');
        	UtilityTestData.mUserData.put('LastName','usera');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
        	// Initialize a employee user sobject
        	sObject prtnrUsera = new User();
        	prtnrUsera = UtilityTest.putFieldRecord(prtnrUsera, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestppb@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestppb');
        	UtilityTestData.mUserData.put('ContactId',contactList[4].id+'');
        	UtilityTestData.mUserData.put('Email','mtestppb@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestppb');
        	UtilityTestData.mUserData.put('LastName','userb');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
        	// Initialize a employee user sobject
        	sObject prtnrUserb = new User();
        	prtnrUserb = UtilityTest.putFieldRecord(prtnrUserb, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
        	UtilityTestData.mUserData.put('Username','mtestppc@m.t');
        	UtilityTestData.mUserData.put('CommunityNickname','mtestppc');
        	UtilityTestData.mUserData.put('ContactId',contactList[5].id+'');
        	UtilityTestData.mUserData.put('Email','mtestppc@m.t');
        	UtilityTestData.mUserData.put('Alias','mtestppc');
        	UtilityTestData.mUserData.put('LastName','userc');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));
        	// Initialize a employee user sobject
        	sObject prtnrUserc = new User();
        	prtnrUserc = UtilityTest.putFieldRecord(prtnrUserc, UtilityTestData.mUserData);
            
        	prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{prtnrUser1,prtnrUser2,prtnrUser3,prtnrUsera,prtnrUserb,prtnrUserc});
            
            
			PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
			insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps.Id );
			PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
			insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps1.Id );
                
			PermissionSet psa = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
			insert new PermissionSetAssignment(AssigneeId = prtnrUserList[3].id, PermissionSetId = psa.Id );
			
			PermissionSet psb = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
			insert new PermissionSetAssignment(AssigneeId = prtnrUserList[3].id, PermissionSetId = psb.Id );
        
    	
			//Create partnerProgObj1 for accList[0].id      
			UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
			UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
			UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
			UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
			UtilityTestData.mPartnerProgramData.put('Partner__c',accList[0].id + '');
			UtilityTestData.mPartnerProgramData.put('Country__c','United States');
			UtilityTestData.mPartnerProgramData.put('Program_Status__c','Active');
			sObject partnerProgObj1 = new Partner_Program__c();
			partnerProgObj1 = UtilityTest.putFieldRecord(partnerProgObj1, UtilityTestData.mPartnerProgramData);
			
			
			UtilityTestData.mPartnerProgramData.put('Program_Status__c','Inactive');
			sObject partnerProgObj2 = new Partner_Program__c();
			partnerProgObj2 = UtilityTest.putFieldRecord(partnerProgObj2, UtilityTestData.mPartnerProgramData);
			
			
			UtilityTestData.mPartnerProgramData.put('Country__c','Rest of World');
			UtilityTestData.mPartnerProgramData.put('Program_Status__c','Active');
			sObject partnerProgObj3 = new Partner_Program__c();
			partnerProgObj3 = UtilityTest.putFieldRecord(partnerProgObj3, UtilityTestData.mPartnerProgramData);
        
			List<Partner_Program__c> partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj1,partnerProgObj2,partnerProgObj3});
        }
        system.runAs(prtnrUserList[0])
		{
        	UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg1');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','Complete - Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()+'');
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        	
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg2'); 
        	sObject ProjRegObj1 = new Project_Registration__c();
        	ProjRegObj1 = UtilityTest.putFieldRecord(ProjRegObj1, UtilityTestData.mProjectRegistrationData);
            
        	//Add all Project Registrations to ProjRegList
        	List<Project_Registration__c> ProjRegList1 = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            
            List<Project_Registration__c> ProjRegList2 = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj1});
        }
    }
    // This test method populates the status to complete send survey on update 
    @isTest 
    public static void testMethodProjectRegProgramPopulator()
	{
        Test.startTest();
        //Admin - prmTestAdmn@m.t
        //PP - mtestpp1@m.t
        List<User> userList = [select id from user where username = 'mtestpp1@m.t' limit 1];
        List<Account> accList = [Select Id from Account Limit 10];
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg1');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','In Progress');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()+'');
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        
        	//Add all Project Registrations to ProjRegList
        	List<Project_Registration__c> ProjRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            ProjRegList[0].Status__c = 'Complete - Send Survey';
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);
            List<Project_Registration__c> assertProjRegList = [Select Id,Partner_Account__c From Project_Registration__c Where Id =:upProjRegList[0].Id];

            system.assertEquals(assertProjRegList[0].Partner_Account__c , acclist[0].Id);

        }
         Test.stopTest();
    }
    
    // This test method is there to implement managed sharing of the Project Reg for all partner users of the account on after update
    @isTest 
    public static void testMethodapexSharingAfterUpdate()
	{
        Test.startTest();
        //Admin - prmTestAdmn@m.t
        //PP - mtestpp1@m.t
        List<User> userList = [select id from user where username = 'mtestpp1@m.t' limit 1];
        List<User> adminUserList = [select id,profile.Name from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [select id,Name from Account];
        
        List<Project_Registration__c> ProjRegList = new List<Project_Registration__c>();
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg1');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','In Progress');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()+'');
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        
        	//Add all Project Registrations to ProjRegList
        	ProjRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            List<Project_Registration__Share> insertedPR_shareList = [select id,userorgroupid,AccessLevel from Project_Registration__Share where parentid = :ProjRegList[0].id];
            system.assertEquals(insertedPR_shareList.size(), 3);
        }
        system.runAs(adminUserList[0])
        {   
            ProjRegList[0].Partner_Account__c = accList[1].Id;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);

            List<Project_Registration__Share> updatedPR_shareList = [select id,userorgroupid,AccessLevel from Project_Registration__Share where parentid = :upProjRegList[0].id];
            system.assertEquals(updatedPR_shareList.size(), 6);
        }
    	Test.stopTest();
    }
    
    //This test method autopopulates the partner program if an active version is available and if it's left blank when Partner's close a Project Registration
    
    @isTest 
    public static void testMethodProjectRegProgramPopulator1()
	{
        //Admin - prmTestAdmn@m.t
        //PP - mtestpp1@m.t
        List<User> userList = [select id from user where username = 'mtestpp1@m.t' limit 1];
        List<User> adminUserList = [select id,profile.Name from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [select id,Name from Account];
        List<Partner_Program__c> prtnrPrgrmList = [select id,Name from Partner_Program__c];
        
        List<Project_Registration__c> ProjRegList = new List<Project_Registration__c>();
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg1');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','Complete - Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Partner_Program__c',prtnrPrgrmList[1].Id+'');
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        
        	//Add all Project Registrations to ProjRegList
        	ProjRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            system.assert(ProjRegList[0].Id!=null,'The record not inserted');
            List<Project_Registration__c> assertProjRegList = [Select Id,Partner_Program__c From Project_Registration__c Where Id =:ProjRegList[0].Id];
            system.assertEquals(assertProjRegList[0].Partner_Program__c , prtnrPrgrmList[1].Id);
        }
        
    }

    //This test method is used to update partner program on a project reg
    @isTest 
    public static void testMethodProjRegUpdatePP()
	{
        
        List<User> userList = [select id,contact.accountid from user where username = 'mtestppa@m.t' limit 1];
        List<User> adminUserList = [select id,profile.Name from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Project_Registration__c> ProjRegList = new List<Project_Registration__c>();
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg without PP');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','Complete - Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()+'');
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        
        	//Add all Project Registrations to ProjRegList
        	ProjRegList = UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            system.assert(ProjRegList[0].Id!=null,'The record not inserted');
        }
        Test.startTest();
        system.runAs(adminUserList[0])
        {
            UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
        	UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
        	UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
        	UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
        	UtilityTestData.mPartnerProgramData.put('Partner__c',userList[0].contact.accountid + '');
        	UtilityTestData.mPartnerProgramData.put('Country__c','United States');
        	UtilityTestData.mPartnerProgramData.put('Program_Status__c','Active');
        	sObject partnerProgObj1 = new Partner_Program__c();
        	partnerProgObj1 = UtilityTest.putFieldRecord(partnerProgObj1, UtilityTestData.mPartnerProgramData);
            List<Partner_Program__c> partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj1});
            system.assert(partnerProgList[0].Id!=null,'The record not inserted');
            
            ProjRegList[0].Partner_Program__c = partnerProgList[0].Id;
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);
            
            List<Project_Registration__c> assertProjRegList = [Select Id,Partner_Program__c From Project_Registration__c Where Id =:upProjRegList[0].Id];

            system.assertEquals(assertProjRegList[0].Partner_Program__c , partnerProgList[0].Id);
        }
        Test.stopTest();
    }
    
    //This method is for Checking if the Partner Program on the Project Registration is unchanged(not null) but the Project is completed
    @isTest 
    public static void testMethodPPcheck()
	{
        List<User> userList = [select id,contact.accountid from user where username = 'mtestpp1@m.t' limit 1];
        List<Partner_Program__c> prtnrPrgrmList = [select id,Name,Program_Status__c,No_of_projects_registered__c from Partner_Program__c Where Program_Status__c =: Label.PRM_Program_Status_Active_Value And Partner__c=:userList[0].contact.accountid];
        List<Project_Registration__c> ProjRegList = new List<Project_Registration__c>();
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg without PP');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','In Progress');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()+'');
            UtilityTestData.mProjectRegistrationData.put('Partner_Program__c',prtnrPrgrmList[0].ID);
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        	Test.startTest();
        	//Add all Project Registrations to ProjRegList
        	ProjRegList = UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
			system.assertEquals(ProjRegList[0].Partner_Program__c , prtnrPrgrmList[0].Id);
            
            ProjRegList[0].Status__c = 'Complete - Send Survey';
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);
			List<Project_Registration__c> assertProjRegList = [Select Id,Partner_Program__c From Project_Registration__c Where Id =:upProjRegList[0].Id];
            system.assertEquals(assertProjRegList[0].Partner_Program__c , prtnrPrgrmList[0].Id);
            Test.stopTest();
        }
    }
    
    //This test method is used to update the status and CSAT program  of a sent survey
    @isTest 
    public static void testMethodProjRegUpdate2()
    {
        List<User> userList = [select id,contact.accountid from user where username = 'mtestpp1@m.t' limit 1];
        List<User> adminUserList = [select id,profile.Name from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Project_Registration__c> ProjRegList = new List<Project_Registration__c>();
        List<Partner_Program__c> prtnrPrgrmList = [select id,Name,Program_Status__c,No_of_projects_registered__c from Partner_Program__c Where Partner__c=:userList[0].contact.accountid];
        Test.startTest();
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg without PP');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','Complete - Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()-3+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()-2+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()-1+'');
            sObject ProjRegObj = new Project_Registration__c();
            ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
            
            //Add all Project Registrations to ProjRegList
            ProjRegList = UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            List<Project_Registration__c> assertProjRegList1 = [Select Id,Partner_Program__c From Project_Registration__c Where Id =:ProjRegList[0].Id];
            system.assertEquals(assertProjRegList1[0].Partner_Program__c , prtnrPrgrmList[0].Id);
        }
        system.runAs(adminUserList[0])
        {            
            UtilityTestData.mEvaluationData.put('Status__c','Survey Sent');
            UtilityTestData.mEvaluationData.put('Project_Registration__c',ProjRegList[0].id);
            UtilityTestData.mEvaluationData.put('DEV_Survey_Sent_Date__c',system.today()+'');
            sObject EvaObj = new Evaluation__c();
            EvaObj = UtilityTest.putFieldRecord(EvaObj, UtilityTestData.mEvaluationData);
            List<Evaluation__c> EvaList = (List<Evaluation__c>) UtilityTest.makeInsert(new List<sObject>{EvaObj});
            EvaList[0].Dev_Survey_Received_Date__c = system.today();
            ProjRegList[0].Status__c = 'Complete - Survey Completed';
            ProjRegList[0].Dev_CSAT_Completed_Date__c = system.today();
            
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);
            upProjRegList[0].CSAT_Program__c = prtnrPrgrmList[1].Id;        	
            List<Project_Registration__c> reUpProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(upProjRegList);
            List<Project_Registration__c> assertProjRegList2 = [Select Id,CSAT_Program__c From Project_Registration__c Where Id =:ProjRegList[0].Id];
            system.assertEquals(assertProjRegList2[0].CSAT_Program__c , prtnrPrgrmList[1].Id);
        }        
        Test.stopTest();
    }
    
    // This test method autopopulates the CSAT partner program if an active version is available and also roll up the no. of Evaluation Score greater than 85 towards the active partner program
    @isTest 
    public static void testMethodProjRegUpdate3()
	{
        List<User> userList = [select id,contact.accountid from user where username = 'mtestpp1@m.t' limit 1];
        List<User> adminUserList = [select id,profile.Name from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Project_Registration__c> ProjRegList = new List<Project_Registration__c>();
        List<Partner_Program__c> prtnrPrgrmList = [select id,Name,Program_Status__c,No_of_projects_registered__c from Partner_Program__c Where Partner__c=:userList[0].contact.accountid];
        Test.startTest();
        system.runAs(userList[0])
        {
            UtilityTestData.mProjectRegistrationData.put('Project_Name__c','Project Reg without PP');
            UtilityTestData.mProjectRegistrationData.put('Project_Type__c','Related to an in-progress opportunity');
            UtilityTestData.mProjectRegistrationData.put('Status__c','Complete - Send Survey');
            UtilityTestData.mProjectRegistrationData.put('Project_Start_Date__c',system.today()-3+'');
            UtilityTestData.mProjectRegistrationData.put('Project_End_Date__c',system.today()-2+'');
            UtilityTestData.mProjectRegistrationData.put('Project_Go_Live_Date__c',system.today()-1+'');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_Country__c','India');
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','');
        	sObject ProjRegObj = new Project_Registration__c();
        	ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
        
        	//Add all Project Registrations to ProjRegList
        	ProjRegList = UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
           	
        }
        system.runAs(adminUserList[0])
        {
            UtilityTestData.mEvaluationData.put('Status__c','Survey Sent');
            UtilityTestData.mEvaluationData.put('Project_Registration__c',ProjRegList[0].id);        
            UtilityTestData.mEvaluationData.put('DEV_Survey_Sent_Date__c',system.today()+'');
            sObject EvaObj = new Evaluation__c();
        	EvaObj = UtilityTest.putFieldRecord(EvaObj, UtilityTestData.mEvaluationData);
        	List<Evaluation__c> EvaList = (List<Evaluation__c>) UtilityTest.makeInsert(new List<sObject>{EvaObj});
        	EvaList[0].Dev_Survey_Received_Date__c = system.today();
            
        	ProjRegList[0].Status__c = 'Complete - Survey Completed';
            ProjRegList[0].Dev_CSAT_Completed_Date__c = system.today();
            
            List<Project_Registration__c> upProjRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);        	
			List<Project_Registration__c> assertProjRegList = [Select Id,CSAT_Program__c From Project_Registration__c Where Id =:upProjRegList[0].Id];
            system.assertEquals(assertProjRegList[0].CSAT_Program__c , prtnrPrgrmList[2].Id);
        }        
        	Test.stopTest();
    }
}