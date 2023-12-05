/*********************************************************************************************************************************************
*  @Class Name: PartnerDistributorTriggerHandlerTest
*  @Author: Deloitte
*  @Date: 2017-11-20
*  @Description:This is a test class for PartnerDistributorTriggerHandler
*********************************************************************************************************************************************
Change History      
*********************************************************************************************************************************************/


@isTest
public class PartnerDistributorTriggerHandlerTest {
    
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Product Request').getRecordTypeId();
       
    
    @testSetup
    static void setupObjectTestData() 
    {
        List<Account> accList;
        
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        

        system.runAs(adminUser){
            //create SR & SI partner account
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
            
            //create Distributor partner account
            UtilityTestData.mAccountData.put('Name','Distributor');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('Partner_Type__c','Distributor');
            sObject partnerAcc2 = new Account();
            partnerAcc2 = UtilityTest.putFieldRecord(partnerAcc2, UtilityTestData.mAccountData);
            
            //create SR & SI partner account
            UtilityTestData.mAccountData.put('Name','Software reseller and SI updt');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
            sObject partnerAcc3 = new Account();
            partnerAcc3 = UtilityTest.putFieldRecord(partnerAcc3, UtilityTestData.mAccountData);
            
            
            //create Distributor partner account
            UtilityTestData.mAccountData.put('Name','Distributor updt');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('Partner_Type__c','Distributor');
            sObject partnerAcc4 = new Account();
            partnerAcc4 = UtilityTest.putFieldRecord(partnerAcc4, UtilityTestData.mAccountData);
            
            
            //Add all accounts to acclist
            accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1,partnerAcc2,partnerAcc3,partnerAcc4});
        }
        
        List<User> prtnrUserList = new List<User>();
        List<Contact> contactList = new List<Contact>();        
        
            
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
        
        //create partner contact
        UtilityTestData.mContactData.put('AccountId',accList[2].id + '');
        UtilityTestData.mContactData.put('Email','Contactx@test.com');
        sObject contactSobjx = new Contact();
        contactSobjx = UtilityTest.putFieldRecord(contactSobjx, UtilityTestData.mContactData);
        
        //create partner contact
        UtilityTestData.mContactData.put('AccountId',accList[2].id + '');
        UtilityTestData.mContactData.put('Email','Contacty@test.com');
        sObject contactSobjy = new Contact();
        contactSobjy = UtilityTest.putFieldRecord(contactSobjy, UtilityTestData.mContactData);
        
        //create partner contact
        UtilityTestData.mContactData.put('AccountId',accList[2].id + '');
        UtilityTestData.mContactData.put('Email','Contacty@test.com');
        sObject contactSobjz = new Contact();
        contactSobjz = UtilityTest.putFieldRecord(contactSobjz, UtilityTestData.mContactData);
        
        //create partner contact
        UtilityTestData.mContactData.put('AccountId',accList[3].id + '');
        UtilityTestData.mContactData.put('Email','Contacti@test.com');
        sObject contactSobji = new Contact();
        contactSobji = UtilityTest.putFieldRecord(contactSobji, UtilityTestData.mContactData);
        
        //create partner contact
        UtilityTestData.mContactData.put('AccountId',accList[3].id + '');
        UtilityTestData.mContactData.put('Email','Contactii@test.com');
        sObject contactSobjii = new Contact();
        contactSobjii = UtilityTest.putFieldRecord(contactSobjii, UtilityTestData.mContactData);
        
        //create partner contact
        UtilityTestData.mContactData.put('AccountId',accList[3].id + '');
        UtilityTestData.mContactData.put('Email','Contactiii@test.com');
        sObject contactSobjiii = new Contact();
        contactSobjiii = UtilityTest.putFieldRecord(contactSobjiii, UtilityTestData.mContactData);
        
        system.runAs(adminUser){
            contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobjb,contactSobj2,contactSobj3,contactSobja,contactSobjc,contactSobjx,contactSobjy,contactSobjz,contactSobji,contactSobjii,contactSobjiii});
        }

        Map<Id,Id> userRoleMap = new Map<Id,Id>();
        for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
            userRoleMap.put(role.PortalAccountId, role.Id);
        }
            
            
        system.runAs(adminUser){
            
            Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];
            
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
            // Initialize a user sobject
            sObject prtnrUser2 = new User();
            prtnrUser2 = UtilityTest.putFieldRecord(prtnrUser2, UtilityTestData.mUserData);

            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp3@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp3');
            UtilityTestData.mUserData.put('ContactId',contactList[2].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp3@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp3');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));    
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
            // Initialize a user sobject
            sObject prtnrUser6 = new User();
            prtnrUser6 = UtilityTest.putFieldRecord(prtnrUser6, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp7@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp7');
            UtilityTestData.mUserData.put('ContactId',contactList[6].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp7@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp7');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[2].id)); 
            // Initialize a user sobject
            sObject prtnrUser7 = new User();
            prtnrUser7 = UtilityTest.putFieldRecord(prtnrUser7, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp8@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp8');
            UtilityTestData.mUserData.put('ContactId',contactList[7].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp8@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp8');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[2].id));          
            // Initialize a user sobject
            sObject prtnrUser8 = new User();
            prtnrUser8 = UtilityTest.putFieldRecord(prtnrUser8, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp9@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp9');
            UtilityTestData.mUserData.put('ContactId',contactList[8].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp9@m.t');
            UtilityTestData.mUserData.put('Alias','mtestpp9');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[2].id));    
            // Initialize a user sobject
            sObject prtnrUser9 = new User();
            prtnrUser9 = UtilityTest.putFieldRecord(prtnrUser9, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp10@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp10');
            UtilityTestData.mUserData.put('ContactId',contactList[9].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp10@m.t');
            UtilityTestData.mUserData.put('Alias','mtestppx');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[3].id));    
            // Initialize a user sobject
            sObject prtnrUser10 = new User();
            prtnrUser10 = UtilityTest.putFieldRecord(prtnrUser10, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp11@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp11');
            UtilityTestData.mUserData.put('ContactId',contactList[10].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp11@m.t');
            UtilityTestData.mUserData.put('Alias','mtestppy');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[3].id));    
            // Initialize a user sobject
            sObject prtnrUser11 = new User();
            prtnrUser11 = UtilityTest.putFieldRecord(prtnrUser11, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ProfileId',ppProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtestpp12@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtestpp12');
            UtilityTestData.mUserData.put('ContactId',contactList[11].id+'');
            UtilityTestData.mUserData.put('Email','mtestpp12@m.t');
            UtilityTestData.mUserData.put('Alias','mtestppz');
            UtilityTestData.mUserData.put('LastName','user2');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[3].id));    
            // Initialize a user sobject
            sObject prtnrUser12 = new User();
            prtnrUser12 = UtilityTest.putFieldRecord(prtnrUser12, UtilityTestData.mUserData);
            
            prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{prtnrUser1,prtnrUser2,prtnrUser3,prtnrUser4,prtnrUser5,prtnrUser6,prtnrUser7,prtnrUser8,prtnrUser9,prtnrUser10,prtnrUser11,prtnrUser12});

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
            
            PermissionSet psb6 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[6].id, PermissionSetId = psb6.Id );
            PermissionSet psb7 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[7].id, PermissionSetId = psb7.Id );
            PermissionSet psb8 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[8].id, PermissionSetId = psb8.Id );
            
            PermissionSet psb9 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[9].id, PermissionSetId = psb9.Id );
            PermissionSet psb10 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[10].id, PermissionSetId = psb10.Id );
            PermissionSet psb11 = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];
                insert new PermissionSetAssignment(AssigneeId = prtnrUserList[11].id, PermissionSetId = psb11.Id );
        }
    }
    
    @isTest
    public static void testPartnerDistributorAll() {
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        List<Account> accList = [select id,Name from Account];
        List<Partner_Distributor__c> prtnrDistiList = new List<Partner_Distributor__c>();
        system.runAs(sogUser){
            
            Test.startTest();
        
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[0].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','India');
       
            sObject prtnrDist1 = new Partner_Distributor__c();
            prtnrDist1 = UtilityTest.putFieldRecord(prtnrDist1, UtilityTestData.mPartnerDistributorData);
            
            prtnrDistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{prtnrDist1});
            system.assertEquals(prtnrDistiList.size(),1);
            
            //fetch the share records
            list<Partner_Distributor__Share> pd_shareList = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share];
            system.assertEquals(pd_shareList.size(), 7);
            //fetch any user from reseller account that will have access to the partner distributor
            User partnerUser = [select id from User where Username = 'mtestpp3@m.t'];
            list<Partner_Distributor__Share> pd_shareListforPartnerUsr = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share where userorgroupid = :partnerUser.Id];
            system.assertEquals(pd_shareListforPartnerUsr.size(), 1);
            
            
            prtnrDistiList[0].Reseller_Account__c = accList[2].id;
            prtnrDistiList[0].Distributor__c = accList[3].id;
            
            List<Partner_Distributor__c> upPrtnrDistiList = (List<Partner_Distributor__c>) UtilityTest.makeUpdate(prtnrDistiList);
            //fetch the share records
            list<Partner_Distributor__Share> pd_shareListUpdated = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share];
            system.assertEquals(pd_shareListUpdated.size(), 7);
            //the Partner user from previous reseller account will lose access to the record
            list<Partner_Distributor__Share> pd_shareListforPartnerUsrUpdated = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share where userorgroupid = :partnerUser.Id and parentid = :upPrtnrDistiList[0].id];
            //system.assertEquals(pd_shareListforPartnerUsrUpdated.size(), 0);
            Test.stopTest();
        
        }
    }
    
      @isTest
    public static void PartnerDistributorAfterInsert() {
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        List<Account> accList = [select id,Name from Account];
        List<Partner_Distributor__c> prtnrDistiList = new List<Partner_Distributor__c>();
        system.runAs(sogUser){
            
            Test.startTest();
        
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[0].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','India');
       
            sObject prtnrDist1 = new Partner_Distributor__c();
            prtnrDist1 = UtilityTest.putFieldRecord(prtnrDist1, UtilityTestData.mPartnerDistributorData);
             globalApexManager.avoidRecursion(Label.PartnerDistributorAfterInsert);
            prtnrDistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{prtnrDist1});
            
            Test.stopTest();
        
        }
    }
    
      @isTest
    public static void PartnerDistributorAfterUpdate() {
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        List<Account> accList = [select id,Name from Account];
        List<Partner_Distributor__c> prtnrDistiList = new List<Partner_Distributor__c>();
        system.runAs(sogUser){
            
            Test.startTest();
        
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[0].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','India');
       
            sObject prtnrDist1 = new Partner_Distributor__c();
            prtnrDist1 = UtilityTest.putFieldRecord(prtnrDist1, UtilityTestData.mPartnerDistributorData);
            
            prtnrDistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{prtnrDist1});
            system.assertEquals(prtnrDistiList.size(),1);
            
            //fetch the share records
            list<Partner_Distributor__Share> pd_shareList = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share];
            system.assertEquals(pd_shareList.size(), 7);
            //fetch any user from reseller account that will have access to the partner distributor
            User partnerUser = [select id from User where Username = 'mtestpp3@m.t'];
            list<Partner_Distributor__Share> pd_shareListforPartnerUsr = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share where userorgroupid = :partnerUser.Id];
            system.assertEquals(pd_shareListforPartnerUsr.size(), 1);
            
            
            prtnrDistiList[0].Reseller_Account__c = accList[2].id;
            prtnrDistiList[0].Distributor__c = accList[3].id;
            globalApexManager.avoidRecursion(Label.PartnerDistributorAfterUpdate);
            List<Partner_Distributor__c> upPrtnrDistiList = (List<Partner_Distributor__c>) UtilityTest.makeUpdate(prtnrDistiList);
           
            Test.stopTest();
        
        }
    }
}