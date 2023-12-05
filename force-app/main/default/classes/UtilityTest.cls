/*	
Change History	
******************************************************************	
ModifiedBy          Date        Requested By        Description                         Tag	
Kiran G            15 Jan 2020                      Changed hte Role from APJ_PSM to 	
                                                    NA_PSM                                T01	
******************************************************************	
*/	
public class UtilityTest	
{	
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();	
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();	
    	
    //public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();	
    public static List<sObject> executeQuery(String query)	
    {       	
        return Database.query(query);	
    }	
    public static void makeDelete(List<sObject> records)	
    {       	
        Database.delete(records);	
    }	
    public static List<sObject> makeInsert(List<sObject> records)	
    {       	
        Database.insert(records);	
        return records;	
    }	
    	
     //Sumit : added the below method to cover the DML options database methods with extra parameter for insert.	
    public static List<sObject> makeInsertDMLOptions(List<sObject> records, Database.DMLOptions dmlOption)	
    {       	
        Database.insert(records, dmlOption);	
        return records;	
    }	
    public static List<sObject> makeUpdate(List<sObject> records)	
    {       	
        Database.update(records);	
        return records;	
    }	
    public static Map<String,String> getCreatableFields(Schema.sObjectType objName) {	
        //system.debug('objName: '+objName);	
        Map<String,String> mFieldType = new Map<String,String>();	
        Map<String, SObjectField> fields = new Map<String, SObjectField>{};	
        if(objName.getDescribe().fields.getMap().keyset().size() > 0)	
            fields = objName.getDescribe().fields.getMap();	
        //system.debug('fields: '+fields);	
        for(SObjectField fieldtoken : fields.values()) {	
            DescribeFieldResult dfr = fieldtoken.getDescribe();	
           // system.debug('---------->'+dfr);	
            //system.debug('dfr.getLocalName(), String.valueOf(dfr.getSoapType()): '+dfr.getLocalName()+'  '+ String.valueOf(dfr.getSoapType()));	
            if(dfr.isCreateable())	
            {	
                mFieldType.put(dfr.getLocalName(), String.valueOf(dfr.getSoapType()));   	
                //system.debug('isCreateable::dfr.getLocalName(), String.valueOf(dfr.getSoapType()): '+dfr.getLocalName()+'  '+ String.valueOf(dfr.getSoapType()));	
            }	
                	
        }	
        return mFieldType;	
    }	
     public static sObject putFieldRecord(sObject sObj, Map<String, String> mData)	
    {	
        Map<String,String> mFieldType = getCreatableFields(sObj.getSObjectType());	
        system.debug('creatablefieldsmap**'+mFieldType);	
        for(String sField : mData.keySet())	
        {	
            system.debug('------sField->'+sField);	
            system.debug('------43->'+mFieldType.get(sField));	
            	
            if(mFieldType.get(sField) != null)	
            {	
                String sFieldType = mFieldType.get(sField);	
                system.debug('------sFieldType->'+sFieldType);	
                system.debug('------sFielddata->'+mData.get(sField));	
                if(sFieldType == 'Date')	
                {	
                    sObj.put(sField, null);	
                    if(String.isNotBlank(mData.get(sField)))	
                        sObj.put(sField, Date.valueOf(mData.get(sField)));	
                }	
                else if(sFieldType == 'DateTime')                	
                {	
                    sObj.put(sField, null);	
                    if(String.isNotBlank(mData.get(sField)))	
                        sObj.put(sField, Datetime.valueOf(mData.get(sField)));	
                }	
                else if(sFieldType == 'STRING')             	
                {	
                    sObj.put(sField, '');	
                    if(String.isNotBlank(mData.get(sField)))	
                        sObj.put(sField, String.valueOf(mData.get(sField)));	
                }	
                else if(sFieldType == 'ID')	
                    sObj.put(sField, (ID)mData.get(sField));	
                else if(sFieldType == 'Double')             	
                {	
                    sObj.put(sField, null);	
                    if(String.isNotBlank(mData.get(sField)))	
                        sObj.put(sField, DOUBLE.valueOf(mData.get(sField)));	
                }	
                else if(sFieldType == 'Boolean')             	
                {	
                    sObj.put(sField, null);	
                    if(String.isNotBlank(mData.get(sField)))	
                        sObj.put(sField, BOOLEAN.valueOf(mData.get(sField)));	
                }	
                else if(sFieldType == 'INTEGER')             	
                {	
                    sObj.put(sField, null);	
                    if(String.isNotBlank(mData.get(sField)))	
                        sObj.put(sField, INTEGER.valueOf(mData.get(sField)));	
                }else if(sFieldType == 'TIME')	
                {	
                    sObj.put(sField, null);	
                    if(String.isNotBlank(mData.get(sField)))	
                    {	
                        DateTime dt=system.today()+2;	
                        Time t=Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());	
                        sObj.put(sField, t);	
                    }	
                        	
                }	
            }	
        }	
        return sObj;	
    }	
    	
    public static void insertSetupObjectTestData() {	
        /*	
            Create all the Supporting Test Data.	
            In case you want to create test data in your own test methods please copy this section to your methods Accordingly	
        */	
        List<Territory2Model> lTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];	
        List<Territory2Type> lTerritoryType   = [SELECT Id, DeveloperName from Territory2Type limit 1];	
        User userObj = [select Id, Name from User where Profile.Name = 'Employee' and IsActive = true limit 1];	
        	
        // Set the Account Name	
        UtilityTestData.mTerritoryData.put('Territory2ModelId', lTerritoryModel[0].Id + '');	
        UtilityTestData.mTerritoryData.put('Territory2TypeId', lTerritoryType[0].Id + '');	
        // Initialize a sObject	
        sObject sObj = new Territory2();	
        // Call methos and pass sObject and data maps	
        // This utility method will populate all the fields data according to the Map passed	
        sObj = putFieldRecord(sObj, UtilityTestData.mTerritoryData);	
        List<Territory2> lTerritory = (List<Territory2>) makeInsert(new List<sObject>{sObj});	
        	
        // Set the Account Name	
        UtilityTestData.mUserTerritory2AssociationData.put('UserId', userObj.Id + '');	
        UtilityTestData.mUserTerritory2AssociationData.put('Territory2Id', lTerritory[0].Id + '');	
        // Initialize a sObject	
        sObj = new UserTerritory2Association();	
        // Call methos and pass sObject and data maps	
        // This utility method will populate all the fields data according to the Map passed	
        sObj = putFieldRecord(sObj, UtilityTestData.mUserTerritory2AssociationData);	
        List<UserTerritory2Association> lUserTerritory2Association = (List<UserTerritory2Association>) makeInsert(new List<sObject>{sObj});	
                	
    }//END static void insertSetupObjectTestData()	
    	
    public static List<sObject> createUsersforPRM()	
    {	
        List<User> userList = new List<User>();	
        	
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];	
        Profile sogProfile = [SELECT Id, Name FROM Profile WHERE Name='Employee'];	
        UserRole ur = [SELECT Id FROM UserRole Where DeveloperName = 'NA_PSM'];//T01	
        	
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
        mngrUser = putFieldRecord(mngrUser, UtilityTestData.mUserData);        	
        List<User> mngrList = (List<USer>) makeInsert(new List<sObject>{mngrUser});	
        	
        //create admin user	
        UtilityTestData.mUserData.put('Username','prmTestAdmn@m.t');	
        UtilityTestData.mUserData.put('Manager ',mngrList[0].id+'');	
        UtilityTestData.mUserData.put('Email','prmTestAdmn@m.t');	
        UtilityTestData.mUserData.put('Alias','admin');	
        UtilityTestData.mUserData.put('FirstName','Admin');	
        UtilityTestData.mUserData.put('UserRoleId',ur.Id);	
        UtilityTestData.mUserData.put('CommunityNickname','madmn');	
        sObject adminUser = new User();	
        	
        adminUser = putFieldRecord(adminUser, UtilityTestData.mUserData);	
        List<User> adminUserList = (List<User>) makeInsert(new List<sObject>{adminUser});	
        userList.add(adminUserList[0]);	
        	
        //create SOG user	
        UtilityTestData.mUserData.put('ProfileId',sogProfile.id+'');	
        UtilityTestData.mUserData.put('ContactId',NULL); 	
        UtilityTestData.mUserData.put('Username','prmTestSog@m.t');	
        UtilityTestData.mUserData.put('Manager ',mngrList[0].id+'');	
        UtilityTestData.mUserData.put('CommunityNickname','sogUser');	
        	
        sObject SOGuserSobj = new User();	
        SOGuserSobj = putFieldRecord(SOGuserSobj, UtilityTestData.mUserData);	
        List<User> sogUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{SOGuserSobj});	
        userList.add(sogUserList[0]);	
        	
        //create PSM user	
        UtilityTestData.mUserData.put('ProfileId',sogProfile.id+'');	
        UtilityTestData.mUserData.put('ContactId',NULL); 	
        UtilityTestData.mUserData.put('Username','mtestpsm@m.t');	
        UtilityTestData.mUserData.put('Manager ',mngrList[0].id+'');	
        UtilityTestData.mUserData.put('CommunityNickname','psmUser12');	
        	
        sObject PSMuserSobj = new User();	
        PSMuserSobj = UtilityTest.putFieldRecord(PSMuserSobj, UtilityTestData.mUserData);	
        List<User> psmUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{PSMuserSobj});	
        userList.add(psmUserList[0]);	
        	
        //create PSG user	
        UtilityTestData.mUserData.put('ProfileId',sogProfile.id+'');	
        UtilityTestData.mUserData.put('ContactId',NULL);	
        UtilityTestData.mUserData.put('Username','mtestpsg@m.t');	
        UtilityTestData.mUserData.put('CommunityNickname','psgUser');	
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');	
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');	
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');	
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US'); 	
        UtilityTestData.mUserData.put('LastName','mtest200');	
        UtilityTestData.mUserData.put('Email','testemailforpsg@infa.com');	
        UtilityTestData.mUserData.put('Alias','psg');	
        	
        sObject PSGuserSobj = new User();	
        PSGuserSobj = UtilityTest.putFieldRecord(PSGuserSobj, UtilityTestData.mUserData);	
        List<User> psgUserList = (List<User>) UtilityTest.makeInsert(new List<sObject>{PSGuserSobj});	
        userList.add(psgUserList[0]);	
        	
        system.runAs(adminUserList[0])	
        {	
            PermissionSetLicense cpqPSL = [SELECT DeveloperName,MasterLabel FROM PermissionSetLicense WHERE DeveloperName ='SalesforceCPQ_CPQStandardPerm'];	
            insert new PermissionSetLicenseAssign(AssigneeId = sogUserList[0].id,PermissionSetLicenseId = cpqPSL.Id);	
            	
            PermissionSet Intrnladmin = [SELECT ID From PermissionSet WHERE Name = 'Modify_All'];	
            insert new PermissionSetAssignment(AssigneeId = adminUserList[0].id, PermissionSetId = Intrnladmin.Id );	
            	
            PermissionSet Intrnladmin1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_System_Admin'];	
            insert new PermissionSetAssignment(AssigneeId = adminUserList[0].id, PermissionSetId = Intrnladmin1.Id );	
            	
            PermissionSet Intrnladmin2 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Super_User'];	
            insert new PermissionSetAssignment(AssigneeId = adminUserList[0].id, PermissionSetId = Intrnladmin2.Id );	
            	
            PermissionSet Intrnlps = [SELECT ID From PermissionSet WHERE Name = 'PRM_Super_User'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps.Id );	
            	
            PermissionSet Intrnlps1 = [SELECT ID From PermissionSet WHERE Name = 'Super_User'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps1.Id );	
            	
            PermissionSet Intrnlps2 = [SELECT ID From PermissionSet WHERE Name = 'SalesforceBillingAdminCloned'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps2.Id );	
            	
            PermissionSet Intrnlps3 = [SELECT ID From PermissionSet WHERE Name = 'Modify_All'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps3.Id );	
                	
            PermissionSet Intrnlps4 = [SELECT ID From PermissionSet WHERE Name = 'SalesforceBillingAdmin'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps4.Id );	
            	
            PermissionSet Intrnlps5 = [SELECT ID From PermissionSet WHERE Name = 'SteelBrickCPQAdmin'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps5.Id );	
            	
            PermissionSet Intrnlps6 = [SELECT ID From PermissionSet WHERE Name = 'SteelBrickCPQAdminCloned'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps6.Id );	
            	
            PermissionSet Intrnlps7 = [SELECT ID From PermissionSet WHERE Name = 'APEX_Permissions'];	
            insert new PermissionSetAssignment(AssigneeId = sogUserList[0].id, PermissionSetId = Intrnlps7.Id );   	
            	
            PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Super_User'];	
            insert new PermissionSetAssignment(AssigneeId = psgUserList[0].id, PermissionSetId = ps1.Id ); 	
        }	
        	
        return userList;	
    }	
    	
    public static List<sObject> createAccountforPRM()	
    {	
        List<Account> accList = new List<Account>();	
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];	
        	
        system.runAs(adminUser)	
        {	
            //create Customer Account	
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_CustAccnt);	
            sObject custAcc = new Account();	
            custAcc = putFieldRecord(custAcc, UtilityTestData.mAccountData);	
        	
            //create reselller partner account	
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);	
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');	
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');	
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');	
            UtilityTestData.mAccountData.put('FCPA_Status__c','Compliant');	
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');	
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');	
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');	
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');	
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');	
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');	
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller');	
            sObject partnerAcc = new Account();	
            partnerAcc = putFieldRecord(partnerAcc, UtilityTestData.mAccountData);	
            	
            //create distributor partner account	
            UtilityTestData.mAccountData.put('Partner_Type__c','Distributor');	
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);	
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');	
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');	
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');	
            UtilityTestData.mAccountData.put('FCPA_Status__c','Compliant');	
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');	
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');	
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');	
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');	
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');	
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');	
            sObject partnerDistiAcc = new Account();	
            partnerDistiAcc = putFieldRecord(partnerDistiAcc, UtilityTestData.mAccountData);	
            	
            //create CSI partner account	
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');	
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);	
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');	
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');	
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');	
            UtilityTestData.mAccountData.put('FCPA_Status__c','Compliant');	
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');	
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');	
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');	
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');	
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');	
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');	
            sObject partnerAcc1 = new Account();	
            partnerAcc1 = putFieldRecord(partnerAcc1, UtilityTestData.mAccountData);	
            	
            //Add all accounts to acclist	
            accList = (List<Account>) makeInsert(new List<sObject>{custAcc,partnerAcc,partnerDistiAcc,partnerAcc1});    	
        }	
        return accList;	
    }	
    	
    public static List<sObject> createPartnerUsersforPRM()	
    {	
        List<User> prtnrUserList = new List<User>();	
        Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();	
        	
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];	
        List<Account> AccList = [Select id,Name,Partner_Type__c from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt];	
        	
        system.runAs(adminUser)	
        {	
            //create partner contact of type Reseller	
            UtilityTestData.mContactData.put('AccountId',AccList[0].id + '');	
            sObject contactSobj1 = new Contact();	
            contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);	
            	
            //create partner contact of type Disti	
            UtilityTestData.mContactData.put('AccountId',AccList[1].id + '');	
            sObject contactSobj2 = new Contact();	
            contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);	
            	
            //create partner contact of type Software Reseller and SI	
            UtilityTestData.mContactData.put('AccountId',AccList[2].id + '');	
            sObject contactSobj3 = new Contact();	
            contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);	
            	
            List<Contact> contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobj2,contactSobj3});	
            	
            Map<Id,Id> userRoleMap = new Map<Id,Id>();	
            	
            for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){	
                userRoleMap.put(role.PortalAccountId, role.Id);	
            }	
            	
            //create partner user(reseller)	
            Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'];	
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');	
            UtilityTestData.mUserData.put('Username','mtest@m.t');	
            UtilityTestData.mUserData.put('Email','testemailforleadm1@infa.com');	
            UtilityTestData.mUserData.put('Alias','mtest');	
            UtilityTestData.mUserData.put('CommunityNickname','mtest');	
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');	
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');	
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');	
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');	
            UtilityTestData.mUserData.put('ContactId',contactList[0].id+''); 	
            UtilityTestData.mUserData.put('LastName','mtest');	
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));	
            UtilityTestData.mUserData.put('UserType','PowerPartner');	
            sObject userSobj = new User();	
            userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);	
            	
            //create partner user(disti)	
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');	
            UtilityTestData.mUserData.put('Username','mtest2@m.t');	
            UtilityTestData.mUserData.put('Email','testemailforleadm2@infa.com');	
            UtilityTestData.mUserData.put('Alias','mtest');	
            UtilityTestData.mUserData.put('CommunityNickname','mtest2');	
            UtilityTestData.mUserData.put('ContactId',contactList[1].id+''); 	
            UtilityTestData.mUserData.put('LastName','mtest2');	
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id));	
            sObject userSobj2 = new User();	
            userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);	
            	
            //create partner user(software reseller and SI)	
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');	
            UtilityTestData.mUserData.put('Username','mtest3@m.t');	
            UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');	
            UtilityTestData.mUserData.put('Alias','mtest3');	
            UtilityTestData.mUserData.put('CommunityNickname','mtest3');	
            UtilityTestData.mUserData.put('ContactId',contactList[2].id+''); 	
            UtilityTestData.mUserData.put('LastName','mtest3');	
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[2].id));	
            sObject userSobj3 = new User();	
            userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);	
            	
            prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj,userSobj2,userSobj3});	
            	
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Admin_Permissions'];	
            insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps.Id );	
            	
            PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];	
            insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps1.Id );	
                	
            PermissionSet psa = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];	
            insert new PermissionSetAssignment(AssigneeId = prtnrUserList[1].id, PermissionSetId = psa.Id );	
            	
            PermissionSet psb = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];	
            insert new PermissionSetAssignment(AssigneeId = prtnrUserList[2].id, PermissionSetId = psb.Id );	
        }	
        	
        return prtnrUserList;	
    }	
}