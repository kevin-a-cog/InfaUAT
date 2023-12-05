/*
* Name          :   CSMPlanEngagementControllerTest
* Author        :   Pavithra V
* Created Date  :   13/10/2021
* Description   :   Test class for CSMPlanEngagementController

Change History
********************************************************************************************************************
Modified By         Date            Jira No.        Description                                             Tag
Chaitanya T	    11/07/2023	        AR-3537	   Map Engagement Requested for values using metadata			T01    
********************************************************************************************************************
*/
@isTest
public class CSMPlanEngagementControllerTest {
    static void nonSetupTestData(){
        
        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        
        List<Territory2Type> territoryType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        Territory2 territoryRec = new Territory2();
        territoryRec.DeveloperName ='AP_AS_AS_MAM_TEST';
        territoryRec.Territory2ModelId = lstTerritoryModel[0].Id;
        territoryRec.Name = 'AP_AS_AS_MAM_TEST';
        territoryRec.Territory2TypeId =territoryType[0].Id;
        insert territoryRec;
        
    }
    @testSetup
    static void initializeData(){
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        Global_Config__c gl = new Global_Config__c(SetupOwnerId=UserInfo.getOrganizationId(),Ignore_All_Flows__c=true);
        insert gl;
        // call nonSetupTestData
        system.runAs(userObj){
            nonSetupTestData();
        }
        
        Territory2 terr =[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAM_TEST'];
        system.debug('terr'+terr);
        // Turn on the Project Trigger via Custom Settings.
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.Interlock_trigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        insert trigSetting;
        
        // Create Practice
        pse__Practice__c practiceRec = new pse__Practice__c();
        practiceRec.Name = 'Consulting Services';
        practiceRec.psa_pm_Allow_Customer_Project__c =true;
        insert practiceRec;
        
        // Create Region
        List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<3;i++){
            pse__Region__c regionRec = new pse__Region__c();
            regionRec.Name = 'Test Region '+i;
            regionRec.pse__Action_Update_Current_Time_Period__c = false;
            regionRec.psa_pm_Allow_Customer_Project__c = true;
            regionList.add(regionRec);
        }
        insert regionList;
        
        List<Account_Territory_Setting__mdt> accTerrList = [Select Id,Label,DeveloperName, Default_Assignee__c,User_Role__c 
                                                            FROM Account_Territory_Setting__mdt]; 
        String contactName;
        String label;
        String contactName1;
        
        
        for(Account_Territory_Setting__mdt accTerrRec:accTerrList){
            
            if(accTerrRec.Label=='NA' && String.isBlank(contactName1)){
               contactName1 =accTerrRec.Default_Assignee__c;
            }
            if(String.isBlank(accTerrRec.User_Role__c)){
                if(String.isBlank(contactName)){
                   contactName = accTerrRec.Default_Assignee__c;
                   label = accTerrRec.Label;  
                }
                
            }
        }
        // Create user/Resource 
        List<User> userList = new List<User>();
        for(integer i=0;i<3;i++){
            userList.add(new User(alias='testRes'+i,
                                  username='testResource'+i+'@abc123.com',
                                  lastname='User '+i,
                                  firstname='Test Resource',
                                  email='testResource'+i+'@abc123.com',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  ProfileId=prof.Id,
                                  isActive =true,
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8'));
        }
        insert userList;
        
        // Create User Territory AssociationData
        List<UserTerritory2Association> usrTerriAssocList = new List<UserTerritory2Association>();
        
        for(integer i=0;i<3;i++){
            UserTerritory2Association usrTerrAssocRec = new UserTerritory2Association();
            usrTerrAssocRec.RoleInTerritory2 ='IPS Delivery';
            usrTerrAssocRec.Territory2Id = terr.Id;
            usrTerrAssocRec.UserId =userList[i].Id;
            usrTerriAssocList.add(usrTerrAssocRec);
        } 
        usrTerriAssocList[1].RoleInTerritory2 = 'CFR';
        usrTerriAssocList[2].RoleInTerritory2 = null;
        system.runAs(userObj){
            insert usrTerriAssocList;
        }
        
        // Create Account
        List<Account> accList = new List<Account>(); 
        for(integer i=0;i<3;i++){
            Account acc = new Account();
            acc.RecordTypeId = accRecType;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            acc.Signature_Success__c = true;
            acc.Geo__c ='Americas';
            acc.Health_Score__c =10+i;
            acc.Territory_Name__c =(String)terr.Id;
            acc.Peoplesoft_External_ID__c='1234'+i;
            accList.add(acc);
            
        }
        accList[2].Geo__c =!String.isBlank(label)?label:'NA';
        insert accList;   
        
        // Create Object Territory Association
        List<ObjectTerritory2Association> objTerrAssocList = new List<ObjectTerritory2Association>();
        for(integer i=0;i<3;i++){
            ObjectTerritory2Association objTerrAssocRec = new ObjectTerritory2Association();
            objTerrAssocRec.AssociationCause ='Territory2Manual';
            objTerrAssocRec.ObjectId = accList[i].Id;
            objTerrAssocRec.Territory2Id=terr.Id;
            objTerrAssocList.add(objTerrAssocRec);
        }
        insert objTerrAssocList;
        // Create Account Line of Business
        // 
        List<Account_LOB__c> accLOBList = new List<Account_LOB__c>();
        for(integer i=0;i<3;i++){
            Account_LOB__c accLOBRec = new Account_LOB__c();
            accLOBRec.Account__c = accList[i].Id;
            accLOBList.add(accLOBRec);
        }
        insert accLOBList;
        
        List<Account> acctList = new List<Account>([Select Id, (SELECT Id,AccountId,RoleInTerritory2,Territory2Id,UserId
                                                                FROM AccountUserTerritory2Views) from Account where Id IN:accList]);
        system.debug('accList'+acctList);
        
        // Create work calendar 
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        defaultWorkCalendar.pse__Sunday_Hours__c= 8;
        defaultWorkCalendar.pse__Monday_Hours__c=8;
        defaultWorkCalendar.pse__Tuesday_Hours__c=8;
        defaultWorkCalendar.pse__Wednesday_Hours__c=8;
        defaultWorkCalendar.pse__Thursday_Hours__c=8;
        defaultWorkCalendar.pse__Friday_Hours__c=8;
        defaultWorkCalendar.pse__Saturday_Hours__c=8;                
        insert defaultWorkCalendar; 
        
        // Create Contact
        String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
        List<Contact> conList = new List<Contact>();
        for(integer i=0;i<3;i++){
            Contact con = new Contact();
            con.AccountId = accList[i].Id;
            con.LastName ='Contact '+i;
            con.FirstName = 'Test';
            con.Email='test'+i+'email@gmail.com';
            con.pse__Is_Resource__c =true;
            con.pse__Is_Resource_Active__c=true;
            con.CurrencyIsoCode='USD';
            con.pse__Resource_Role__c='Regional Manager';
            con.pse__Region__c = regionList[i].Id;
            con.pse__Default_Cost_Rate__c = 10;
            con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.Peoplesoft_External_ID__c='1234'+i;
            con.MailingCountry='India';
            con.pse__Salesforce_User__c = userList[i].Id;
            conList.add(con);
        }
        // Different user role set assigned to the user Territory
       /* conList[1].firstName = !String.isBlank(contactName1)?contactName1.split(' ')[0]:conList[1].firstName;
        conList[1].LastName = !String.isBlank(contactName1)?contactName1.split(' ')[1]:conList[1].LastName;
        // Blank User Role assigned to the user Territory
        conList[2].firstName = !String.isBlank(contactName)?contactName.split(' ')[0]:conList[2].firstName;
        conList[2].LastName = !String.isBlank(contactName)?contactName.split(' ')[1]:conList[2].LastName;*/
        insert conList;
        
        // Create Plan
        // 
       
        List<Plan__c> planList = new List<Plan__c>();
        for(integer i=0;i<3;i++){
            Plan__c planRec = new Plan__c();
            planRec.Name = 'Test Plan '+i;
            planRec.Line_of_Business__c = accLOBList[i].Id;
            if(i==1){
                planRec.Plan_Type__c='Modernization';
                planRec.COE_Group__c='PC2IICS';
            }
            planRec.Account__c = accList[i].Id;
            planRec.Status__c ='Active';
            planRec.Plan_Operational_Model__c ='Named CSM';
            planList.add(planRec);
            
        }
        insert planList;
        
        // Create New Sales Opportuntiy
        System.runAs(createTestUser('Employee', true)) {
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        List<Opportunity> opptyList = new List<Opportunity>(); 
        for(integer i=0;i<3;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = accList[i].Id;
            oppty.CurrencyIsoCode='USD';
            oppty.Type='Direct';
            oppty.CloseDate =  currentDate.addDays(2);
            oppty.StageName='Identity';
            oppty.psa_om_Start_Date__c = currentDate;
            oppty.psa_om_End_Date__c = currentDate.addDays(10);
            oppty.PSA_OM_Project_Type__c = 'JumpStart';
            oppty.psa_om_IPS_Package__c = 'JumpStart: Axon';
            oppty.Sales_Play__c='Data Quality';
            oppty.Sales_Journey__c ='Data Governance and Privacy';
            opptyList.add(oppty);
            
        }
        insert opptyList; 
        
        
        // Create Contract
        List<Contract> contractList = new List<Contract>();
        for(integer i=0;i<3;i++){
            Contract newContract = new Contract();
            newContract.Name = 'Test Contract '+i;
            newContract.AccountId=accList[i].Id;
            newContract.StartDate = currentDate;
            newContract.EndDate = currentDate.addDays(365);
            newContract.SBQQ__Opportunity__c = opptyList[i].Id;
            contractList.add(newContract);
        }
        insert contractList;
        
     Test.startTest();
        // Create Renewal Opportuntiy
        String renewalOpptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId(); 
        
        List<Opportunity> renewalOpptyList = new List<Opportunity>(); 
        for(integer i=0;i<3;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = renewalOpptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = accList[i].Id;
            oppty.CurrencyIsoCode='USD';
            oppty.Type='Direct';
            oppty.SBQQ__RenewedContract__c = contractList[i].Id;
            oppty.CloseDate =  currentDate.addDays(2);
            oppty.StageName='Identity';
            oppty.psa_om_Start_Date__c = currentDate;
            oppty.psa_om_End_Date__c = currentDate.addDays(10);
            oppty.PSA_OM_Project_Type__c = 'JumpStart';
            oppty.psa_om_IPS_Package__c = 'JumpStart: Axon';
            oppty.Sales_Play__c='Data Quality';
            oppty.Sales_Journey__c ='Data Governance and Privacy';
            renewalOpptyList.add(oppty);
            
        }
        insert renewalOpptyList; 
        
        
        // Create Interlock (Related opportunity Plan)
        String interlockRecTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Related Opportunity Plan').getRecordTypeId();  
        List<Related_Opportunity_Plan__c> interlockList = new List<Related_Opportunity_Plan__c>();
        for(integer i=0;i<3;i++){
            Related_Opportunity_Plan__c interlockRec = new Related_Opportunity_Plan__c();
            interlockRec.Opportunity__c = renewalOpptyList[i].Id;
            interlockRec.Account__c = accList[i].Id;
            interlockRec.Plan__c = planList[i].Id;
            interlockRec.Contract__c=contractList[i].Id;
            interlockRec.Key_customer_contact__c = conList[i].Id;
            interlockRec.RecordTypeId = interlockRecTypeId;
            interlockRec.Implementation_Owner__c ='Customer';
            interlockRec.Partner_name_if_any__c ='IP TEST PARTNER NAME';
            interlockRec.Expected_Start_Date__c = currentDate;
            interlockRec.IPS_Package__c = 'Renewal Rescue';
            interlockRec.Comments__c ='Sample Testing Interlock';
            interlockRec.Partner_name_if_any__c = 'partner Name '+i;
            interlockRec.Ignore_ABV__c=True;
            interlockList.add(interlockRec);
        }
        interlockList[0].Interlock_Type__c = 'JumpStart';
        interlockList[1].Interlock_Type__c = 'Renewal Rescue';
        interlockList[2].Interlock_Type__c = 'Checkup';
        
        insert interlockList;
        
        //Engagement
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        Id CSTEngagement = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
        sObject engagement = new Engagement__c();
          UtilityTestData.mEngagementData.put('Account__c',accList[0].Id);
          UtilityTestData.mEngagementData.put('Name','Test Engagment');//
          UtilityTestData.mEngagementData.put('Plan__c',planList[0].Id);
          UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
          UtilityTestData.mEngagementData.put('Opportunity__c',renewalOpptyList[0].Id);
          UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
          UtilityTestData.mEngagementData.put('Estimated_Start_Date__c',system.today()+'');
          engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData); 
            
           sObject engagement1 = new Engagement__c();
          UtilityTestData.mEngagementData.put('Account__c',accList[0].Id);
          UtilityTestData.mEngagementData.put('Name','Test Engagment');//
          UtilityTestData.mEngagementData.put('Plan__c',planList[0].Id);
          UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagement);
          UtilityTestData.mEngagementData.put('Opportunity__c',renewalOpptyList[0].Id);
          UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
          UtilityTestData.mEngagementData.put('Estimated_Start_Date__c',system.today()+'');
          engagement1 = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);     
          List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
        }
          Test.stopTest();
    }  
    
    @isTest
    public static void testEngagementCtrl() {
        List<Account> lAccount = [Select Id from Account];
        List<Plan__c> lPlan = [Select Id from Plan__c];
        List<Opportunity> lOpportunity = [Select Id from Opportunity];
        List<Engagement__c> lEngagement = [Select Id from Engagement__c];
        Test.startTest();
        //Create engagement Obj
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);
        
        CSMPlanEngagementController.getRecords(String.valueOf(lEngagement[0].Id));
        CSMPlanEngagementController.getRecordsDeleted(lEngagement);
        CSMPlanEngagementController.getRecordTypes();
        CSMPlanEngagementController.getRecordsInserted((Engagement__c)engagement);
        CSMPlanEngagementController.lookupSearch('opp', new List<String>(), 'Opportunity', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.lookupSearch('opp', new List<String>(), 'Contact', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.lookupSearch('opp', new List<String>(), 'Renewal_Opportunity__c', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.getDefaultRecords(String.valueOf(lPlan[0].Id),'Contact');
        CSMPlanEngagementController.getDefaultRecords(String.valueOf(lPlan[0].Id),'Opportunity');
        CSMPlanEngagementController.checkRenewalOppty(String.valueOf(lOpportunity[0].Id));
        Test.stopTest();
    }
    
    @isTest
    public static void testEngagementCtrl1() {
        List<Account> lAccount = [Select Id from Account];
        List<Plan__c> lPlan = [Select Id from Plan__c];
        List<Opportunity> lOpportunity = [Select Id from Opportunity];
        List<Engagement__c> lEngagement = [Select Id from Engagement__c];
        Test.startTest();
        //Create engagement Obj
        Id CSTEngagement = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagement);
        UtilityTestData.mEngagementData.put('RecType__c', 'CSA');
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);
        
        CSMPlanEngagementController.getRecords(String.valueOf(lEngagement[0].Id));
        CSMPlanEngagementController.getRecordsDeleted(lEngagement);
        CSMPlanEngagementController.getRecordTypes();
        CSMPlanEngagementController.getRecordsInserted((Engagement__c)engagement);
        
        sObject engagementMFA = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagement);
        UtilityTestData.mEngagementData.put('RecType__c', 'MFA');
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        engagementMFA = UtilityTest.putFieldRecord(engagementMFA, UtilityTestData.mEngagementData);
        CSMPlanEngagementController.getRecordsInserted((Engagement__c)engagementMFA);

        CSMPlanEngagementController.lookupSearch('opp', new List<String>(), 'Opportunity', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.lookupSearch('opp', new List<String>(), 'Contact', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.lookupSearch('opp', new List<String>(), 'Renewal_Opportunity__c', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.getDefaultRecords(String.valueOf(lPlan[0].Id),'Opportunity');
        CSMPlanEngagementController.getDefaultRecords(String.valueOf(lPlan[0].Id),'Contact');
        CSMPlanEngagementController.checkRenewalOppty(String.valueOf(lOpportunity[0].Id));
        Test.stopTest();
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
        return objTestUser;
        }
    
     @isTest
    public static void testEngagementCtrlPC2IICS() {
        List<Plan__c> lPlan = [Select Id,Account__c from Plan__c where COE_Group__c='PC2IICS'];        
        List<Contact> lContact = [Select Id from Contact where accountId=:lplan[0].Account__c];
        List<Related_Opportunity_Plan__c> lOpportunity = [Select Id,Opportunity__c from Related_Opportunity_Plan__c where Plan__c=:lPlan[0].Id];
        List<Engagement__c> lEngagement = [Select Id from Engagement__c];
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        Test.startTest();
       // CollaborationGroup cg= new CollaborationGroup(name='Adoption Services Approvers', CollaborationType = 'Public');
      //  insert cg;
        Sobject sObj = new pse__Proj__c();
        UtilityTestData.mProjectData.put('pse__Account__c',lplan[0].Account__c);
        UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Type__c','Internal');
        UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');//
        UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
        UtilityTestData.mProjectData.put('psa_pm_Require_Product_On_Timecards__c','false');
        UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Opportunity__c);
        UtilityTestData.mProjectData.put('CurrencyIsoCode','USD');
        UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(-6)+'');
        UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');//
        UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');  
        UtilityTestData.mProjectData.put('psa_pm_Project_Category__c','Billable');  
       // UtilityTestData.mProjectData.put('pse__Stage__c','In Progress');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
        List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create engagement Obj
        Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        sObject engagement = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lplan[0].Account__c);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Opportunity__c);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('IPS_Project__c',lProject[0].Id);
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);
        
        CSMPlanEngagementController.getRecordsInserted((Engagement__c)engagement);
        CSMPlanEngagementController.lookupSearch('acc', new List<String>(), 'pse__Proj__c', String.valueOf(lPlan[0].Id));
        CSMPlanEngagementController.getDefaultRecords(String.valueOf(lPlan[0].Id),'pse__Proj__c');
        CSMPlanEngagementController.emailNotification(new List<String>{[select Id from Engagement__c LIMIT 1]?.Id});

        String planId = lPlan[0].Id;
        CSMPlanEngagementController.logComment(planId,'Test comments');
        CSMPlanEngagementController.getPlanContacts(lPlan[0].Id);
        CSMPlanEngagementController.getPlanMilestones(lPlan[0].Id);
        CSMPlanEngagementController.getTimeZone('America/Los_Angeles');
        Test.stopTest();
    }

    //<T01> start
    @isTest
    public static void testEngRequestedForMetadataMappings(){
        List<String> engReqFor = new List<String>();
        engReqFor.add('Expansion (I)');
        String engReqForFromMetadata = CSMPlanEngagementController.getEngagementRequestedFor(engReqFor);
        Assert.areEqual('Upsell/Cross-sell', engReqForFromMetadata, 'Engagement Requested For value is not matching');
    }//</T01> end
}