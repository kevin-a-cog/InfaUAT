/*
@created by       : RANJAN KISHORE
@created on       : 05/27/2021
@Purpose          : This Test class provides code coverages to the trigger PSA_SolutionTypeTrigger 
and its handler and helper classes.
Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |       Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/
@isTest
public class PSA_SolutionTypeTriggerTest {
    private static List<Schema.SObjectType> sObjects =
        new Schema.SObjectType[] {
            Bypass_Trigger_Settings__c.SobjectType,
            User_Exemptions__c.SobjectType,
            Account.SobjectType,
            User.SobjectType,
            pse__Region__c.SobjectType,
            Contact.SobjectType,
            Opportunity.SobjectType,
            pse__Proj__c.SobjectType,
            psa_pm_Solution_Type__c.SobjectType
        };
    
    @testSetup
    static void initializeData(){
        UnitOfWork uow = new UnitOfWork(sObjects);
        //Bypass Trigger Setting
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Solution_Type_Trigger__c  = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        uow.registerNew(trigSetting);

        //Skip Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        uow.registerUpsert(settings);

    
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
        //Create Account;
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
        
        // Create user/Resource 
        Profile prof = [select Name from Profile where Name = 'Employee'];
        
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

        pse__Region__c reg1 = new pse__Region__c(Name='Test Region 1',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-1->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg1);
        
        Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00);
        uow.registerRelationship(con1, Contact.pse__Salesforce_User__c,user1);                               
        uow.registerRelationship(con1, Contact.AccountId,acc1);
        uow.registerNew(con1, Contact.pse__Region__c, reg1);
        
        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               RecordTypeId = opptyRecType,
                                               StageName='Validate',
                                               Name = 'Test opportunity 1',
                                               psa_om_Start_Date__c=currentDate,
                                               CloseDate = System.today().addDays(2),
                                               psa_om_End_Date__c=currentDate.addDays(10),
                                               psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                               PSA_OM_Project_Type__c='JumpStart'
                                               );                                 
        uow.registerNew(opty, Opportunity.AccountId, acc1);
        
        pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Project_Type__c = 'Customer Project',
                                                     psa_pm_Time_Approval_Method__c = 'Auto-Approve',
                                                     psa_pm_Require_Milestone_on_Timecards__c = false,
                                                     psa_pm_Require_Product_On_Timecards__c =false,
                                                     psa_pm_Require_Location_On_Timecards__c = false,
                                                     Name = 'Test Project 1',
                                                     pse__Stage__c='Completed',
                                                     pse__Start_Date__c=currentDate.addDays(-6),
                                                     pse__End_Date__c=currentDate.addDays(10),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, acc1);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Project_Manager__c,con1);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Opportunity__c,opty);
        uow.registerNew(projRec1,pse__Proj__c.pse__Region__c ,reg1);
        
        psa_pm_Solution_Type__c solnRec1= new psa_pm_Solution_Type__c(PSA_PM_Product_Family__c = 'MDM',
                                                                        PSA_PM_Product_Split__c = 20,
                                                                        PSA_PM_Forecast_Family__c ='On-Premise Perpetual',
                                                                        PSA_PM_Pricing_Business_Model__c ='Perpetual',
                                                                        PSA_PM_Processing_Engine__c='Big Data DB',
                                                                        PSA_PM_Delivery_Method__c ='Hosted Other');
        uow.registerNew(solnRec1,psa_pm_Solution_Type__c.Opportunity__c,opty);

        psa_pm_Solution_Type__c solnRec2= new psa_pm_Solution_Type__c(PSA_PM_Product_Family__c = 'MDM',
                                                                        PSA_PM_Product_Split__c = 20,
                                                                        PSA_PM_Forecast_Family__c ='On-Premise Perpetual',
                                                                        PSA_PM_Pricing_Business_Model__c ='Perpetual',
                                                                        PSA_PM_Processing_Engine__c='Big Data DB',
                                                                        PSA_PM_Delivery_Method__c ='Hosted Other');
        uow.registerNew(solnRec2,psa_pm_Solution_Type__c.Opportunity__c,opty);
        psa_pm_Solution_Type__c solnRec3= new psa_pm_Solution_Type__c(PSA_PM_Product_Family__c = 'MDM',
                                                                        PSA_PM_Product_Split__c = 20,
                                                                        PSA_PM_Forecast_Family__c ='On-Premise Perpetual',
                                                                        PSA_PM_Pricing_Business_Model__c ='Perpetual',
                                                                        PSA_PM_Processing_Engine__c='Big Data DB',
                                                                        PSA_PM_Delivery_Method__c ='Hosted Other');
        uow.registerNew(solnRec3,psa_pm_Solution_Type__c.Opportunity__c,opty);
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
    }
    @isTest
    private static void prepopulateFieldsOnInsertTest(){
        
        Test.startTest();
        List<pse__Proj__c> projList = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        List<psa_pm_Solution_Type__c> solnTypeList = [Select Id,psa_pm_Project__c from psa_pm_Solution_Type__c 
                                                      where Opportunity__c=:projList[0].pse__Opportunity__c Limit 3];
        solnTypeList[0].PSA_PM_Product_Split__c=null;
        solnTypeList[1].PSA_PM_Product_Split__c=null;
        solnTypeList[2].PSA_PM_Product_Split__c=40;
        update solnTypeList;
        delete solnTypeList;
        Test.stopTest();
        
        system.assertEquals(projList[0].Id, solnTypeList[0].psa_pm_Project__c);
    }
    @isTest
    static void validateProductSplitPercentageOnInsertTest(){
        Test.startTest();
        List<pse__Proj__c> projList = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        try{
            psa_pm_Solution_Type__c solnRec = new psa_pm_Solution_Type__c();
            solnRec.Opportunity__c = projList[0].pse__Opportunity__c;
            solnRec.PSA_PM_Product_Split__c = 70;
            solnRec.PSA_PM_Product_Family__c = 'MDM';
            solnRec.PSA_PM_Forecast_Family__c ='On-Premise Perpetual';
            solnRec.PSA_PM_Pricing_Business_Model__c ='Perpetual';
            solnRec.PSA_PM_Processing_Engine__c='Big Data DB';
            solnRec.PSA_PM_Delivery_Method__c ='Hosted Other';
            insert solnRec;
            Test.stopTest();
        }catch(exception ex){
            String errorMsg ='Product Split % total for all lines is reaching more than 100%, current total Product Split% is 60%.';
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
        }
    }
    @isTest
    static void validateProductSplitPercentageOnUpdateTest(){
        Test.startTest();
        List<pse__Proj__c> projList = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        try{
            
            List<psa_pm_Solution_Type__c> solnTypeList = [Select Id,psa_pm_Project__c,PSA_PM_Product_Split__c from psa_pm_Solution_Type__c 
                                                          where Opportunity__c=:projList[0].pse__Opportunity__c Limit 1];
            solnTypeList[0].PSA_PM_Product_Split__c = 80;
            update solnTypeList;
            Test.stopTest();
        }catch(exception ex){
            String errorMsg ='Product Allocation % total for all lines is reaching more than 100%, current total Product Allocation % is 40%.';
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            //System.assertEquals(true,expectedExceptionThrown);
        }
    }
}