/*
* Name          :   CSMCreateProjectfromEngagementTest
* Author        :   Pavithra V
* Created Date  :   13/10/2021
* Description   :   Test class for CSMCreateProjectfromEngagement

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
*/
@isTest
public class CSMCreateProjectfromEngagementTest { 
        
    static void nonSetupTestData(){
        
        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        
        List<Territory2Type> territoryType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        Territory2 territoryRec = new Territory2();
        territoryRec.DeveloperName ='AP_AS_AS_MAM_TEST';
        territoryRec.Territory2ModelId = lstTerritoryModel[0].Id;
        territoryRec.Name = 'AP_AS_AS_MAM_TEST';
        territoryRec.Territory2TypeId =territoryType[0].Id;
        territoryRec.Area__c = 'EMEA LATAM';
        territoryRec.Geo__c = 'EMEA';
        insert territoryRec;
         Territory2 territoryRec1 = new Territory2();
        territoryRec1.DeveloperName ='AP_AS_AS_MAN_TEST';
        territoryRec1.Territory2ModelId = lstTerritoryModel[0].Id;
        territoryRec1.Name = 'AP_AS_AS_MAN_TEST';
        territoryRec1.Territory2TypeId =territoryType[0].Id;
        territoryRec1.Geo__c = 'EMEA';
        insert territoryRec1;
        
    }
    
    @testSetup
    static void initializeData(){
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        
        // call nonSetupTestData
        system.runAs(userObj){
            nonSetupTestData();
        }
        
        Territory2 terr =[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAM_TEST'];
        Territory2 terr1 =[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAN_TEST'];
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
            usrTerrAssocRec.RoleInTerritory2 = 'IPS Delivery'; // 'IPS Sales';////'IPS Sales Rep';
            if(i!=2){
             usrTerrAssocRec.Territory2Id = terr.Id;
            }
            else{
             usrTerrAssocRec.Territory2Id = terr1.Id;
            }
            
            usrTerrAssocRec.UserId =userList[i].Id;
            usrTerriAssocList.add(usrTerrAssocRec);
        } 
        
        //usrTerriAssocList[1].RoleInTerritory2 = 'CFR';
       // usrTerriAssocList[2].RoleInTerritory2 = null;
        system.runAs(userObj){
            insert usrTerriAssocList; 
        }
        system.debug('@developer usrTerriAssocList==========>' + usrTerriAssocList);
        
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
            acc.Geo__c ='EMEA';
            acc.Area__c='EMEA LATAM';
            acc.Health_Score__c =10+i;
            acc.Territory_Name__c =(String)terr.Id;
            acc.Peoplesoft_External_ID__c='1234'+i;
            accList.add(acc);
            
        }
        //accList[0].Geo__c ='NA';//!String.isBlank(label)?label:'NA';
        insert accList;   
        
        // Create Object Territory Association
        List<ObjectTerritory2Association> objTerrAssocList = new List<ObjectTerritory2Association>();
        for(integer i=0;i<accList.size();i++){
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
        for(integer i=0;i<=1;i++){
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
        system.debug('conList===>' + conList);
        // Different user role set assigned to the user Territory
        conList[0].firstName = !String.isBlank(contactName1)?contactName1.split(' ')[0]:conList[1].firstName;
        conList[0].LastName = !String.isBlank(contactName1)?contactName1.split(' ')[1]:conList[1].LastName;
        // Blank User Role assigned to the user Territory
       // conList[2].firstName = !String.isBlank(contactName)?contactName.split(' ')[0]:conList[2].firstName;
        //conList[2].LastName = !String.isBlank(contactName)?contactName.split(' ')[1]:conList[2].LastName;
        insert conList;
        
        // Create Plan
        // 
       
        List<Plan__c> planList = new List<Plan__c>();
        for(integer i=0;i<3;i++){
            Plan__c planRec = new Plan__c();
            planRec.Name = 'Test Plan '+i;
            planRec.Line_of_Business__c = accLOBList[i].Id;
            planRec.Account__c = accList[i].Id;
            planRec.Status__c ='Active';
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
        /*String interlockRecTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();  
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
        
        insert interlockList;*/

          //Engagement
          Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
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
          UtilityTestData.mEngagementData.put('Account__c',accList[1].Id);
          UtilityTestData.mEngagementData.put('Name','Test Engagment1');//
          UtilityTestData.mEngagementData.put('Plan__c',planList[1].Id);
          UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
          UtilityTestData.mEngagementData.put('Opportunity__c',renewalOpptyList[1].Id);
          UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
          UtilityTestData.mEngagementData.put('Estimated_Start_Date__c',system.today()+'');
          engagement = UtilityTest.putFieldRecord(engagement1, UtilityTestData.mEngagementData); 
                 
          List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
      }
     }
    
   
    
     @isTest
    public static void testEngagementCtrlV1() {
        Test.startTest();
       // List<Account> lAccount = [Select Id from Account];
        //List<Plan__c> lPlan = [Select Id from Plan__c];
        //List<Opportunity> lOpportunity = [Select Id from Opportunity];
        List<Engagement__c> lEngagement = [Select Id from Engagement__c limit 1];
        
        if(lEngagement !=null){
        CSMCreateProjectfromEngagement.createIPSProject(new Set<Id>{lEngagement[0].Id});}
        
        // Turn on the Status Report Trigger via Custom Settings.
        /*Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Status_Report_Trigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        insert trigSetting;*/
        
        List<pse__Proj__c> lProject = [Select Id from pse__Proj__c limit 1];
        Status_Report__c statRep = new Status_Report__c();
        statRep.PSA_PM_Project__c = lProject[0].Id;
        statRep.Status_Report_Name__c ='Test Status Report ';
        statRep.PSA_PM_Key_Accomplishments__c='Test Key Accomplishments ';
        statRep.PSA_PM_Next_Steps__c ='Test Next Steps ';
        statRep.PSA_PM_Cost__c='Green';
        statRep.PSA_PM_Resources__c='Yellow';
        statRep.PSA_PM_Schedule__c='Red';
        statRep.PSA_PM_Technical__c='Green';
        statRep.PSA_PM_Scope__c='Yellow';
        statRep.PSA_PM_Status_Report_Week__c=system.today().toStartofWeek().addDays(1);
        
        insert statRep;    
        
        statRep.Status_Report_Name__c ='Test Status Report - 1';
        update statRep;
        
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
    

}