/*
@created by       : RANJAN KISHORE
@created on       : 05/27/2021
@Purpose          : This Test class provides code coverages to aura controller class psa_CreateSolutionTypeController.
Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |       Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/

@isTest
public with sharing class PSA_CreateSolutionTypeControllerTest {
    private static List<Schema.SObjectType> sObjects = 
        new Schema.SObjectType[]{
                                    Bypass_Trigger_Settings__c.SobjectType,
                                    User_Exemptions__c.SobjectType,
                                    Account.SobjectType,
                                    pse__Region__c.SobjectType,
                                    User.SobjectType,
                                    pse__Work_Calendar__c.SobjectType,
                                    Contact.SobjectType,
                                    Product2.SobjectType,
                                    Pricebook2.SobjectType,
                                    pricebookEntry.SobjectType,
                                    Opportunity.SobjectType,
                                    OpportunityLineItem.SobjectType,
                                    pse__Proj__c.SobjectType,
                                    psa_pm_Solution_Type__c.SobjectType
        };
    
    
    @testSetup
    static void initializeData(){
        UnitOfWork uow = new UnitOfWork(sObjects);

        //Skip Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        uow.registerUpsert(settings);

        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        // Create Account
        Account acc1 = new Account();
        acc1.Name='Test Account 1';
        acc1.RecordTypeId=accRecType;
        acc1.Geo__c='NA';
        acc1.Signature_Success__c = true;
        acc1.CSM_Segment__c='Digital Touch';
        acc1.Contract_Company_Group__c='Prospect';
        acc1.Payment_Terms__c='Net 30';
        acc1.BillingCountry='India';
        uow.registerNew(acc1);  
        
        // Create Region
        pse__Region__c reg1 = new pse__Region__c(Name='Test Region 1',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-1->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg1);
        
        // Create user/Resource 
        Profile prof = [SELECT Name FROM Profile WHERE Name = 'IPS Profile'];
    
        User user1 = new User(CommunityNickname='communityuser',
                                  ProfileId=prof.Id,
                                  LastName='Testing1',
                                  Alias='userTep1',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8',
                                  Email='usr_temp1@testorg.com',
                                  UserName='usr_temp1@testorg.com');
        uow.registerNew(user1);
        
        // Create work calendar 
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar',
                                                                              pse__Sunday_Hours__c= 8,
                                                                              pse__Monday_Hours__c=8,
                                                                              pse__Tuesday_Hours__c=8,
                                                                              pse__Wednesday_Hours__c=8,
                                                                              pse__Thursday_Hours__c=8,
                                                                              pse__Friday_Hours__c=8,
                                                                              pse__Saturday_Hours__c=8);
        uow.registerNew(defaultWorkCalendar); 
        
        // Create Contact
        String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
    
        Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00);
        uow.registerRelationship(con1, Contact.pse__Salesforce_User__c,user1);                               
        uow.registerRelationship(con1, Contact.AccountId,acc1);
        uow.registerRelationship(con1, Contact.pse__Region__c, reg1);
        uow.registerNew(con1, Contact.pse__Work_Calendar__c,defaultWorkCalendar);

        //Create Product2
        Product2 prodRec1 = new Product2(Name='Test Product 1',
        Offering_Type__c='Professional Services',
        Product_Family__c='DI',
        Family = 'On-Premise Subscription',
        Forecast_Product__c ='Active VOS',
        Pricing_Business_Model__c ='Perpetual',
        Processing_Engine__c ='NA',
        Delivery_Method__c = 'On Premise');
        uow.registerNew(prodRec1);

        Product2 prodRec2 = new Product2(Name='Test Product 2',
        Offering_Type__c='Professional Services',
        Product_Family__c='DI',
        Family = 'Cloud Subscription',
        Forecast_Product__c = 'Cloud Data Integration',
        Pricing_Business_Model__c = 'Subscription',
        Processing_Engine__c = 'Traditional DB',
        Delivery_Method__c = 'Hosted Multi Tenant');
        uow.registerNew(prodRec2);

        
        // Get the Standard price book Id and create active pricebook.
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create Pricebook
        Pricebook2 priceBookRec = new Pricebook2(Id = pricebookId,IsActive = True);
        uow.registerDirty(priceBookRec);
        
        // Create Pricebook Entry
        pricebookEntry pbEntry1 = new pricebookEntry(
            UnitPrice=100,
            CurrencyIsoCode='USD',
            IsActive=true
        );
        uow.registerRelationship(pbEntry1, pricebookEntry.Product2Id, prodRec1);
        uow.registerNew(pbEntry1,pricebookEntry.Pricebook2Id,priceBookRec);

        pricebookEntry pbEntry2 = new pricebookEntry(
            UnitPrice=100,
            CurrencyIsoCode='USD',
            IsActive=true
        );
        uow.registerRelationship(pbEntry2, pricebookEntry.Product2Id, prodRec2);
        uow.registerNew(pbEntry2,pricebookEntry.Pricebook2Id,priceBookRec);

        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 

       Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               StageName='Validate',
                                               RecordTypeId = opptyRecType,
                                               Name = 'Test opportunity 1',
                                               psa_om_Start_Date__c=System.today(),
                                               CloseDate = System.today().addDays(2),
                                               psa_om_End_Date__c=System.today()+10,
                                               psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                               PSA_OM_Project_Type__c='JumpStart'
                                               );                                 
        uow.registerNew(opty, Opportunity.AccountId, acc1);

        Opportunity opty2 = new Opportunity(Name = 'Test opportunity 2',
                                                Type='Direct',
                                                CurrencyIsoCode='USD',
                                                RecordTypeId = opptyRecType,
                                                StageName='Validate',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
                                               );
        uow.registerRelationShip(opty2,opportunity.Related_Opportunity__c,opty);
        uow.registerNew(opty2, Opportunity.AccountId, acc1);

        Opportunity opty3 = new Opportunity(Name = 'Test opportunity 3',
                                                Type='Direct',
                                                CurrencyIsoCode='USD',
                                                RecordTypeId = opptyRecType,
                                                StageName='Validate',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
                                               );
        uow.registerNew(opty3, Opportunity.AccountId, acc1);

        pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Project_Type__c = 'Customer Project',
                                                     psa_pm_Time_Approval_Method__c = 'Auto-Approve',
                                                     psa_pm_Require_Milestone_on_Timecards__c = false,
                                                     psa_pm_Require_Product_On_Timecards__c =false,
                                                     psa_pm_Require_Location_On_Timecards__c = false,
                                                     Name = 'Test Project 1',
                                                     pse__Stage__c='Completed',
                                                     pse__Is_Billable__c=true,
                                                     pse__Start_Date__c=System.today().addDays(1),
                                                     pse__End_Date__c=System.today().addDays(10),
                                                     pse__Is_Active__c=true,
                                                     pse__Billings__c=10,
                                                     pse__Bookings__c=100,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, acc1);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Project_Manager__c,con1);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Opportunity__c,opty);
        uow.registerNew(projRec1,pse__Proj__c.pse__Region__c ,reg1);
        
        // Create solution type
        psa_pm_Solution_Type__c solnRec1= new psa_pm_Solution_Type__c(PSA_PM_Product_Family__c = 'MDM',
                                                                        PSA_PM_Forecast_Family__c ='On-Premise Perpetual',
                                                                        PSA_PM_Pricing_Business_Model__c ='Perpetual',
                                                                        PSA_PM_Processing_Engine__c='Big Data DB',
                                                                        PSA_PM_Delivery_Method__c ='Hosted Other');
        uow.registerNew(solnRec1,psa_pm_Solution_Type__c.Opportunity__c,opty);

        psa_pm_Solution_Type__c solnRec2= new psa_pm_Solution_Type__c(PSA_PM_Product_Family__c = 'MDM',
                                                                        PSA_PM_Forecast_Family__c ='On-Premise Perpetual',
                                                                        PSA_PM_Pricing_Business_Model__c ='Perpetual',
                                                                        PSA_PM_Processing_Engine__c='Big Data DB',
                                                                        PSA_PM_Delivery_Method__c ='Hosted Other');
        uow.registerNew(solnRec2,psa_pm_Solution_Type__c.Opportunity__c,opty);

        Test.startTest();
        uow.commitWork();
        Test.stopTest();

    }
    @isTest
    public static void createSolutionTypeRecsTest1(){
        
        Test.startTest();
        PriceBookEntry pbe = [SELECT Id, Pricebook2Id FROM PriceBookEntry LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c,pse__Opportunity__r.Related_Opportunity__c from pse__Proj__c  Limit 1];
        List<psa_pm_Solution_Type__c> solnTypeListBefore = [Select Id from psa_pm_Solution_Type__c where Opportunity__c=:projRec.pse__Opportunity__c];
        //Update Pricebook on Opportunity
        oppty.Pricebook2Id = pbe.Pricebook2Id;
        update oppty;

        OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityId = oppty.Id);
        insert oppLine;
        
        psa_CreateSolutionTypeController.createSolutionTypeRecs(projRec.pse__Opportunity__c);
        
        List<psa_pm_Solution_Type__c> solnTypeListAfter = [Select Id from psa_pm_Solution_Type__c where Opportunity__c=:projRec.pse__Opportunity__c];
        
        Test.stopTest();
        
    }
    @isTest
    public static void createSolutionTypeRecsTest2(){
        
        Test.startTest();
        PriceBookEntry pbe = [SELECT Id, Pricebook2Id FROM PriceBookEntry LIMIT 1];

            List<Opportunity> opptyRec = [Select Id from Opportunity Limit 1];
            Opportunity optyRec = [SELECT Id FROM opportunity WHERE name='Test Opportunity 2' LIMIT 1];

        	// optyRec.Related_Opportunity__c=opptyRec[0].Id;
            optyRec.Pricebook2Id = pbe.Pricebook2Id;
            update optyRec;

            //Create Opportunity Product
        OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityId = optyRec.Id);
        insert oppLine;
            psa_CreateSolutionTypeController.createSolutionTypeRecs(optyRec.Id);
            
            Test.stopTest();
    }
    @isTest
    public static void createSolutionTypeRecsTest3(){
        try{
            Test.startTest();
            
            Opportunity opptyRec = [Select Id from Opportunity where name ='Test opportunity 2' Limit 1];
            
            psa_CreateSolutionTypeController.createSolutionTypeRecs(opptyRec.Id);
            
            Test.stopTest();
        }catch (exception ex){
            String errorMsg ='Error: No Opportunity Products exist';
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
        }
        
        
    }
    
}