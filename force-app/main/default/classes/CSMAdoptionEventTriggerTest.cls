@istest
public class CSMAdoptionEventTriggerTest {
	  @testSetup
    static void initializeData(){
        
          Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Adoption_Event_Trigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        insert trigSetting;
         Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());

system.debug('bts'+bts.PSA_Adoption_Event_Trigger__c);       
        
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
        // Create Account
       List<Account> accList = new List<Account>(); 
        for(integer i=0;i<2;i++){
            Account acc = new Account();
        acc.RecordTypeId = accRecType;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            accList.add(acc);
            
        }
        insert accList;   
        
        
        // Create Opportuntiy
        // 
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        List<Opportunity> opptyList = new List<Opportunity>(); 
        for(integer i=0;i<2;i++){
            Opportunity oppty = new Opportunity();
        oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = accList[i].Id;
            oppty.Type='Direct';
            oppty.CloseDate =  currentDate.addDays(2);
            oppty.StageName='Identify';
            oppty.Sales_Play__c='Data Quality';
           	opptyList.add(oppty);
            
        }
        insert opptyList; 
        
        // Create Project
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        for(integer i=0;i<2;i++){
            pse__Proj__c projRec = new pse__Proj__c();
        	projRec.Name = 'Test Project '+i;
			projRec.pse__Account__c = accList[i].Id;  
            projRec.pse__Opportunity__c = opptyList[i].Id;  
            projRec.pse__Start_Date__c=currentDate;
            projRec.pse__End_Date__c=currentDate.addDays(2);
           	projList.add(projRec);
            
        }
        insert projList;
        // Create Adoption Events
        List<Adoption_Event__c> adoptEventLst = new List<Adoption_Event__c>();
        for(integer i=0;i<2;i++){
            Adoption_Event__c adoptEvt = new Adoption_Event__c();
            adoptEvt.PSA_PM_Project__c =projList[i].Id;
            adoptEvt.PSA_PM_Start_Date__c=currentDate;
            adoptEvt.PSA_PM_Adoption_Event_Type__c = 'In Production';
            adoptEvt.PSA_PM_Adoption_Event_Status__c = 'Draft';
            adoptEvt.PSA_PM_Project_Team_Size__c='1-10 Team Members';
            adoptEvt.PSA_PM_Adoption_Event_Date__c = currentDate.addDays(1);
            adoptEvt.PSA_PM_PS_Project_Activities__c='Testing Sample activities';
            adoptEvt.PSA_PM_Adoption_Event_Author__c=userinfo.getuserid();
            adoptEvt.Customer_PM_Project_Status__c = 'Planning';
            adoptEvt.PSA_PM_Reporting_Manager__c=userinfo.getuserid();
            adoptEventLst.add(adoptEvt);
        }
        insert adoptEventLst;
}
    
    @isTest
    static void defaultAdoptionEvtFieldsValOnInsertTest(){
   	
       pse__Proj__c projRec = [Select Id,Name,pse__Account__c from pse__Proj__c  Limit 1];
        Adoption_Event__c adoptEvt = [select Id,Adoption_Event_Name__c, PSA_PM_Project__c, PSA_PM_Customer__c
                                      from Adoption_Event__c where PSA_PM_Project__c=:projRec.Id];
       system.assertEquals(projRec.pse__Account__c, adoptEvt.PSA_PM_Customer__c);
       system.assertEquals(projRec.Name, adoptEvt.Adoption_Event_Name__c);
        
        
    }
}