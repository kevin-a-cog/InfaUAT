/*Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
Ramya Ravi     01/04/2021       Prasanth			Rhapsody 															<T01>
****************************************************************************************************************************
*/


@isTest
public with sharing class PSA_AdoptionEventTriggerTest {
    private static List<Schema.SObjectType> sObjects =
        new Schema.SObjectType[] {
            Bypass_Trigger_Settings__c.SobjectType,
            User_Exemptions__c.SobjectType,
            Account.SobjectType,
            Opportunity.SobjectType,
            pse__Proj__c.SobjectType,
            Adoption_Event__c.SobjectType
        };
 
    @testSetup
    static void initializeData(){
        UnitOfWork uow = new UnitOfWork(sObjects);
        //Bypass Trigger Setting
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Adoption_Event_Trigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        uow.registerNew(trigSetting);

        //Skip Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        uow.registerUpsert(settings);
        
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

        Account acc2 = new Account();
        acc2.Name='Test Account 2';
        acc2.RecordTypeId=accRecType;
        acc2.Geo__c='NA';
        acc2.Signature_Success__c = true;
        acc2.CSM_Segment__c='Digital Touch';
        acc2.Contract_Company_Group__c='Prospect';
        acc2.Payment_Terms__c='Net 30';
        acc2.BillingCountry='India';
        uow.registerNew(acc2);
        

        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               RecordTypeId = opptyRecType,
                                               StageName='Validate',
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
                                                StageName='Validate',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
                                               );
        uow.registerNew(opty2, Opportunity.AccountId, acc2); 
        
        // Create Project
        pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     Name = 'Test Project 1',
                                                     pse__Start_Date__c=currentDate,
                                                     pse__End_Date__c=System.today().addDays(2),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
        uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, acc1);
        uow.registerNew(projRec1, pse__Proj__c.pse__Opportunity__c,opty);

        pse__Proj__c projRec2 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     Name = 'Test Project 2',
                                                     pse__Start_Date__c=currentDate,
                                                     pse__End_Date__c=System.today().addDays(2),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
        uow.registerRelationship(projRec2, pse__Proj__c.pse__Account__c, acc2);
        uow.registerNew(projRec2, pse__Proj__c.pse__Opportunity__c,opty2);

        Adoption_Event__c adoptionEventRec1 = new Adoption_Event__c(PSA_PM_Start_Date__c=currentDate,
                                                                    PSA_PM_Adoption_Event_Type__c = 'First Value',
                                                                    PSA_PM_Adoption_Event_Status__c = 'Forecasted',
                                                                    PSA_PM_Project_Team_Size__c='1-10 Team Members',
                                                                    PSA_PM_Adoption_Event_Date__c = currentDate.addDays(1),
                                                                    PSA_PM_PS_Project_Activities__c='Testing Sample activities',
                                                                    PSA_PM_Adoption_Event_Author__c=userinfo.getuserid(),
                                                                    Customer_PM_Project_Status__c = 'Planning',
                                                                    PSA_PM_Reporting_Manager__c=userinfo.getuserid());
        uow.registerNew(adoptionEventRec1,Adoption_Event__c.PSA_PM_Project__c,projRec1);
        Adoption_Event__c adoptionEventRec2 = new Adoption_Event__c(PSA_PM_Start_Date__c=currentDate,
                                                                    PSA_PM_Adoption_Event_Type__c = 'First Value',
                                                                    PSA_PM_Adoption_Event_Status__c = 'Forecasted',
                                                                    PSA_PM_Project_Team_Size__c='1-10 Team Members',
                                                                    PSA_PM_Adoption_Event_Date__c = currentDate.addDays(1),
                                                                    PSA_PM_PS_Project_Activities__c='Testing Sample activities',
                                                                    PSA_PM_Adoption_Event_Author__c=userinfo.getuserid(),
                                                                    Customer_PM_Project_Status__c = 'Planning',
                                                                    PSA_PM_Reporting_Manager__c=userinfo.getuserid());
        uow.registerNew(adoptionEventRec2,Adoption_Event__c.PSA_PM_Project__c,projRec2);
        Test.startTest();
        uow.commitWork();                                         
        Test.stopTest();

}
    
    @isTest
    public static void defaultAdoptionEvtFieldsValOnInsertTest(){
   	
       pse__Proj__c projRec = [Select Id,Name,pse__Account__c from pse__Proj__c  Limit 1];
        Adoption_Event__c adoptEvt = [select Id,Adoption_Event_Name__c, PSA_PM_Project__c, PSA_PM_Customer__c
                                      from Adoption_Event__c where PSA_PM_Project__c=:projRec.Id];
       system.assertEquals(projRec.pse__Account__c, adoptEvt.PSA_PM_Customer__c);
       system.assertEquals(projRec.Name, adoptEvt.Adoption_Event_Name__c);
        
        
    }
}