@isTest
public class psa_ProjectFieldUpdatesHandlerTest {
    
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
            
            if(accTerrRec.Label=='Americas' && String.isBlank(contactName1)){
               contactName1 =accTerrRec.Default_Assignee__c;
            }
            if(String.isBlank(accTerrRec.User_Role__c)){
                if(String.isBlank(contactName)){
                   contactName = accTerrRec.Default_Assignee__c;
                   label = accTerrRec.Label;  
                }
                
            }
        }
        
        //UserRole r = new UserRole(DeveloperName = 'IPS_Delivery', Name = 'IPS Delivery');
        //insert r;
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
        usrTerriAssocList[2].RoleInTerritory2 = 'IPS Sales Rep';
        
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
            acc.Geo__c ='APJ';
            acc.Health_Score__c =10+i;
            acc.Territory_Name__c =(String)terr.Id;
            acc.Peoplesoft_External_ID__c='1234'+i;
            accList.add(acc);
            
        }
        accList[2].Geo__c =!String.isBlank(label)?label:'Americas';
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
        conList[1].firstName = !String.isBlank(contactName1)?contactName1.split(' ')[0]:conList[1].firstName;
        conList[1].LastName = !String.isBlank(contactName1)?contactName1.split(' ')[1]:conList[1].LastName;
        // Blank User Role assigned to the user Territory
        conList[2].firstName = !String.isBlank(contactName)?contactName.split(' ')[0]:conList[2].firstName;
        conList[2].LastName = !String.isBlank(contactName)?contactName.split(' ')[1]:conList[2].LastName;
        insert conList;
        
        // Create Plan
        // 
        String planRecordTypeId = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Outcome Based Success Plan').getRecordTypeId();
        List<Plan__c> planList = new List<Plan__c>();
        for(integer i=0;i<3;i++){
            Plan__c planRec = new Plan__c();
            planRec.Name = 'Test Plan '+i;
            planRec.Line_of_Business__c = accLOBList[i].Id;
            planRec.Account__c = accList[i].Id;
            planRec.Status__c ='Active';
            planRec.RecordTypeId = planRecordTypeId;
            planList.add(planRec);
            
        }
        insert planList;
        
        // Create New Sales Opportuntiy
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
        String interlockRecTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();  
        List<Related_Opportunity_Plan__c> interlockList = new List<Related_Opportunity_Plan__c>();
       
            Related_Opportunity_Plan__c interlockRec = new Related_Opportunity_Plan__c();
            interlockRec.Opportunity__c = renewalOpptyList[0].Id;
            interlockRec.Account__c = accList[0].Id;
            interlockRec.Plan__c = planList[0].Id;
            interlockRec.Contract__c=contractList[0].Id;
            interlockRec.Key_customer_contact__c = conList[0].Id;
            interlockRec.RecordTypeId = interlockRecTypeId;
            interlockRec.Implementation_Owner__c ='Customer';
            interlockRec.Partner_name_if_any__c ='IP TEST PARTNER NAME';
            interlockRec.Expected_Start_Date__c = currentDate;
            interlockRec.IPS_Package__c = 'Renewal Rescue';
            interlockRec.Comments__c ='Sample Testing Interlock';
            interlockRec.Partner_name_if_any__c = 'partner Name ';
            interlockRec.Interlock_Type__c = 'Renewal Rescue';
            interlockRec.Ignore_ABV__c=True;
            insert interlockRec;


             Related_Opportunity_Plan__c interlockRec1 = new Related_Opportunity_Plan__c();
            interlockRec1.Opportunity__c = renewalOpptyList[0].Id;
            interlockRec1.Contract__c=contractList[0].Id;
            interlockRec1.Key_customer_contact__c = conList[0].Id;
            interlockRec1.RecordTypeId = interlockRecTypeId;
            interlockRec1.Implementation_Owner__c ='Customer';
            interlockRec1.Partner_name_if_any__c ='IP TEST PARTNER NAME';
            interlockRec1.Expected_Start_Date__c = currentDate;
            interlockRec1.IPS_Package__c = 'Renewal Rescue';
            interlockRec1.Comments__c ='Sample Testing Interlock';
            interlockRec1.Partner_name_if_any__c = 'partner Name ';
            interlockRec1.Interlock_Type__c = 'Renewal Rescue';
            interlockRec1.Ignore_ABV__c=True;
            insert interlockRec1;        
        //interlockList.add(interlockRec);
        
        //interlockList[0].Interlock_Type__c = 'JumpStart';
        //interlockList[1].Interlock_Type__c = 'Renewal Rescue';
        //interlockList[2].Interlock_Type__c = 'Checkup';
        
        
    }
    
    @isTest
    static void createProjectsFromInterlockIdsTest(){
        
        Test.startTest();
        Set<Id> setAccount = new Set<Id>();
        Map<Id,Id> mapAccount = new Map<Id,Id>();
         List<Account> acctList = new List<Account>([Select Id,Geo__c from Account]);
   
        for(Account oAcc : acctList){
            setAccount.add(oAcc.Id);
            mapAccount.put(oAcc.Id,oAcc.Id);
            
        }
        
        
        List<pse__Practice__c> practiceLst = new List<pse__Practice__c>([Select Id,Name from pse__Practice__c where Name ='Consulting Services' Limit 1]);
        
        Related_Opportunity_Plan__c interLockRec = [Select Id,Expected_Start_Date__c,Account__c,Account__r.Health_Score__c,
                                                    CurrencyIsoCode,CreatedBy.Name,Partner_name_if_any__c,Comments__c,Original_Opportunity__c,Opportunity__c
                                                    from Related_Opportunity_Plan__c where Interlock_Type__c ='Renewal Rescue' Limit 1];
        
        List<pse__Proj__c> projList = new List<pse__Proj__c>([Select Id,psa_om_Interlock__c,pse__Start_Date__c,pse__End_Date__c,
                                                              pse__Stage__c,pse__Project_Status__c,pse__Account__c,CurrencyIsoCode,
                                                              pse__Project_Type__c,psa_pm_Project_Category__c,pse__Is_Active__c,
                                                              pse__Practice__c,psa_pm_Source__c,psa_pm_Project_Notes__c,psa_pm_Project_Sub_Type__c,pse__Opportunity__c
                                                              from pse__Proj__c]);
        system.debug('projRec'+projList.size());
        
        pse__Proj__c interLockProjRec = new pse__Proj__c();
        for(pse__Proj__c projRec :projList){
            
            if(projRec.psa_pm_Project_Sub_Type__c =='Renewal Rescue' && projRec.psa_om_Interlock__c==interLockRec.Id){
                interLockProjRec = projRec;
            }
        }
        system.debug('interLockRec'+interLockRec.id);
        psa_ProjectFieldUpdatesHandler.createProjectsFromInterlockIds(new set<Id>{interLockRec.Id});
        psa_ProjectFieldUpdatesHandler psaPFUH = new psa_ProjectFieldUpdatesHandler();
        psaPFUH.getAccountRecById(setAccount);

        Test.stopTest();
        String projectNotes = 'Health Score :'+interLockRec.Account__r.Health_Score__c+'; '+'Partner Name :'+interLockRec.Partner_name_if_any__c+'; '+'Comments:'+interLockRec.Comments__c+';'+'CSM: '+interLockRec.CreatedBy.Name;
        //system.assert(interLockProjRec.pse__Is_Active__c);
        //system.assertEquals(3, projList.size());
        //system.assertEquals(interLockRec.Account__c, interLockProjRec.pse__Account__c);
        //system.assertEquals(interLockRec.CurrencyIsoCode, interLockProjRec.CurrencyIsoCode);
        //system.assertEquals(interLockRec.Expected_Start_Date__c, interLockProjRec.pse__Start_Date__c);
        //system.assertEquals(interLockRec.Expected_Start_Date__c.addDays(90), interLockProjRec.pse__End_Date__c);
        //system.assertEquals(interLockRec.Opportunity__c, interLockProjRec.pse__Opportunity__c);
        //system.assertEquals('Customer Project', interLockProjRec.pse__Project_Type__c);
        //system.assertEquals('Non - Billable', interLockProjRec.psa_pm_Project_Category__c);
        //system.assertEquals(projectNotes, interLockProjRec.psa_pm_Project_Notes__c);
        //system.assertEquals('Interlock', interLockProjRec.psa_pm_Source__c);
        //system.assertEquals(practiceLst[0].Id, interLockProjRec.pse__Practice__c); 
        
    }
    
}