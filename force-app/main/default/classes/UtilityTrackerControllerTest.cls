@isTest(seeAllData = false)
public with sharing class UtilityTrackerControllerTest {	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
        //Now we create an Account.
		Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'US';
		insert objAccount;

		//Now we create an Opportunity.
		Opportunity objOpportunity = new Opportunity();
		objOpportunity.Name = 'Test';
		objOpportunity.AccountId = objAccount.Id;
		objOpportunity.StageName = 'Lead';
		objOpportunity.CloseDate = System.today().addDays(1);
		objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
		insert objOpportunity;
                 
        //Now we create a Plan.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'TestNew';
		objPlan.Is_Template__c = false;
		objPlan.Account__c = objAccount.Id;
		insert objPlan;
		objPlan = new Plan__c();
		objPlan.Name = 'Test';
		objPlan.Is_Template__c = true;
		objPlan.Account__c = objAccount.Id;
		insert objPlan;
        
        //Now we create the Interlock.
		Related_Opportunity_Plan__c objInterlock = new Related_Opportunity_Plan__c();
		objInterlock.Account__c = objAccount.Id;
		objInterlock.Opportunity__c = objOpportunity.Id;
		objInterlock.Plan__c = objPlan.Id;
		objInterlock.Is_Template__c = true;
		objInterlock.RecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Related Opportunity Plan').getRecordTypeId();
		insert objInterlock;
        
        Tracked_Details__c trackdetails = new Tracked_Details__c();
		trackdetails.sObjectAPI__c = 'Opportunity';
		trackdetails.Parent_Record_Id__c = objOpportunity.Id;
		trackdetails.Object_Name__c ='Opportunity' ;
		trackdetails.Field_Name__c = 'Test';
		trackdetails.New_Value__c = 'Test 12333';
        trackdetails.Old_Value__c = 'Test 2345';

		insert trackdetails;
   

    }
 
    @isTest
    public static void testgetOptyRecordID() {
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        System.runAs(adminUser) {
            String relatredoptyid; 
            List<Related_Opportunity_Plan__c> lstopty = [Select id from Related_Opportunity_Plan__c limit 1];
            system.debug('lstopty'+lstopty.size());
            if(lstopty.size()>0){
                system.debug('lstopty'+lstopty[0].id);
                relatredoptyid = lstopty[0].id;
            }
            UtilityTrackerController.getOptyRecordID(relatredoptyid);

        }        
    }
        
    @isTest
    public static void testgetTrackedRecord() 
    {
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        System.runAs(adminUser) {
            String trackdetailsid; 
            Integer offSetCount = 5;
            List<Tracked_Details__c> lsttrack = [Select id from Tracked_Details__c limit 1];
            system.debug('lsttrack'+lsttrack.size());
            if(lsttrack.size()>0){
                system.debug('lsttrack'+lsttrack[0].id);
                trackdetailsid = lsttrack[0].id;
            }
            UtilityTrackerController.getTrackedRecord(trackdetailsid,offSetCount);
			
        }
    }
		
}