/*
* Name			:	CSMPlanTriggerHelperTest
* Author		:	Pavithra V
* Created Date	: 	08/20/2021
* Description	:	Test Class for CSMPlanTriggerHelper

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
*/
@isTest
public class CSMPlanTriggerHelperTest {

    @testSetup
    static void setupObjectTestData() {

        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});

        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
        
        sObject Contact2 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('Email','test145@test.com');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact2 = UtilityTest.putFieldRecord(Contact2, UtilityTestData.mContactData); 
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact, Contact2});

        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('AutoPilot_Status__c','Submitted for Approval');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',false+'');
        UtilityTestData.mPlan.put('Is_Internal__c',false+'');
        UtilityTestData.mPlan.put('Csm_Manager__c',UserInfo.getUserId()+'');
        UtilityTestData.mPlan.put('PAF_Frequency__c',30+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','Business Value');
        UtilityTestData.mPlan.put('Csm_Manager__c',UserInfo.getUserId()+'');
        UtilityTestData.mPlan.put('Is_Internal__c',false+'');
        UtilityTestData.mPlan.put('PAF_Frequency__c',30+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2}); 

        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Role__c','Business Owner');//
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        UtilityTestData.mPlanContact.put('Business_Outcome_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('Onboarding_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('CST_Survey_Sent__c','true');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        
        sObject PlanContact2 = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[1].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[1].Id);
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        UtilityTestData.mPlanContact.put('Role__c','Business Contributor');
        PlanContact2 = UtilityTest.putFieldRecord(PlanContact2, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact,PlanContact2}); 
        
        String OutcomeRecordTypeId = Schema.SObjectType.Survey_Response__c.getRecordTypeInfosByDeveloperName().get('CSP_Business_outcome').getRecordTypeId();
        String OnboardRecordTypeId = Schema.SObjectType.Survey_Response__c.getRecordTypeInfosByDeveloperName().get('CSP_Onboarding').getRecordTypeId();
	    String cstRecordTypeId = Schema.SObjectType.Survey_Response__c.getRecordTypeInfosByDeveloperName().get('CST_Survey').getRecordTypeId();
        sObject surveyResponse = new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[0].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OnboardRecordTypeId);
        surveyResponse = UtilityTest.putFieldRecord(surveyResponse, UtilityTestData.mSurveyResponse);


		sObject onboardSurveyResponse = new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[1].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[1].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OnboardRecordTypeId);
        onboardSurveyResponse = UtilityTest.putFieldRecord(onboardSurveyResponse, UtilityTestData.mSurveyResponse);
        
        
        sObject surveyResponse2 = new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[0].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OutcomeRecordTypeId);
        surveyResponse2 = UtilityTest.putFieldRecord(surveyResponse2, UtilityTestData.mSurveyResponse);
        
        sObject cstSurveyResponse= new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[0].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OutcomeRecordTypeId);
        cstSurveyResponse = UtilityTest.putFieldRecord(cstSurveyResponse, UtilityTestData.mSurveyResponse);
        List<Survey_Response__c> lsurveyResponse = (List<Survey_Response__c>) UtilityTest.makeInsert(new List<sObject>{surveyResponse,surveyResponse2,cstSurveyResponse,onboardSurveyResponse}); 
        CSMPlanTriggerHelper.createPlanTeamMember(new Set<Id>{lPlan[0].Id,lPlan[1].Id});
    }

    @isTest
    public static void checkOnboardSurveyFlag(){
        //System.runAs(createTestUser('System Administrator', true)) {
        List<String> planIdSet = new List<String>();
            List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c];
            for(Plan__c obPlan:plan){
                obPlan.Sub_Stage__c = 'Design';
                obPlan.OwnerId = UserInfo.getUserId();
                obPlan.Closing_Notes__c = 'Test';
                obPlan.Closing_Reason__c = 'Lost Opportunity';
                obPlan.Plan_Completeness_Status__c = 'Submitted for Approval';
                planIdSet.add(obPlan.Id);
            }
            update plan;
            
            //Resend ONboarding Survey
            CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(planIdSet, CSMSendSurveyToPlanContacts.ONBOARDING_SURVEY);
            
            
        //}
        
    }
    
    @isTest
    public static void checkManagerSignOffTest(){
        //System.runAs(createTestUser('System Administrator', true)) {
            Plan__c plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c,Is_Internal__c,PAF_Frequency__c  FROM Plan__c LIMIT 1];
            
            plan.Sub_Stage__c = 'Business Value';        	
            plan.Is_Internal__c=true;
            plan.PAF_Frequency__c=45;
            update plan;           
        //}
        
    }
   
    @isTest
    public static void checkOutcomeSurveyFlag(){
        //System.runAs(createTestUser('System Administrator', true)) {
            List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c,Closing_Reason__c,Closing_Notes__c,Status__c FROM Plan__c ];
            
            plan[1].Sub_Stage__c = 'Optimize';
            plan[1].Status__c = 'Complete';
            plan[1].Closing_Reason__c = 'Lost Opportunity';
            plan[1].Closing_Notes__c = 'Completed';
            update plan;
            CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(new List<String>{plan[0].Id}, CSMSendSurveyToPlanContacts.ONBOARDING_SURVEY); 
        //}
    }
    
    @isTest
    public static void checkCSTSurveyFlag(){
        //System.runAs(createTestUser('System Administrator', true)) {
            List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c ];
            
            //CST Survey 
            CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(new List<String>{plan[0].Id}, CSMSendSurveyToPlanContacts.CST_SURVEY);        
       // }
    }
    @isTest
    public static void approvedTest(){
        Plan__c plan=[select Id,AutoPilot_Status__c,CSM_isAutoPilot__c from Plan__c limit 1];
        plan.AutoPilot_Status__c='Approved';
        update plan;
    }
    
    @isTest
    public static void autoPilotApproveTest(){
        Plan__c plan=[select Id,AutoPilot_Status__c,CSM_isAutoPilot__c from Plan__c limit 1];
        plan.AutoPilot_Status__c='Submitted for Approval';
        update plan;
        Test.startTest();
         // Create an approval request for the plan
         Approval.ProcessSubmitRequest planApproval = new Approval.ProcessSubmitRequest();
         planApproval.setComments('Submitting request for approval.');
         planApproval.setObjectId(plan.Id);            
         // Submit on behalf of a specific submitter
         planApproval.setSubmitterId(UserInfo.getUserId());
         try{
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(planApproval);         
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals(
                'Pending', result.getInstanceStatus(), 
                'Instance Status'+result.getInstanceStatus());

                // Approve the submitted request
            // First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = 
                new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
            
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            
            // Verify the results
            System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
            
            System.assertEquals(
                'Approved', result2.getInstanceStatus(), 
                'Instance Status'+result2.getInstanceStatus());
         }catch(Exception e){

         }
        Test.stopTest();
    }

    
    @isTest
    public static void completePlanTest(){
        Plan__c plan=[select Id,AutoPilot_Status__c,Plan_Completeness_Status__c from Plan__c  limit 1]; 
        plan.Plan_Completeness_Status__c='Submitted for Approval';
        plan.Closing_Reason__c='Other';
        plan.Closing_Notes__c='test';
        plan.OwnerId = UserInfo.getUserId();
        Test.startTest();
        //update plan;
        CSMPlanTriggerHelper.submitPlanforApproval(new Set<Id>{plan.Id},'Request_CSO_to_complete_Plan');
        Test.stopTest(); 
    }

    @isTest
    public static void autoPilotRejectTest(){
        Plan__c plan=[select Id,AutoPilot_Status__c,CSM_isAutoPilot__c from Plan__c limit 1];
        plan.AutoPilot_Status__c='Submitted for Approval';
        update plan;
        Test.startTest();
         // Create an approval request for the plan
         Approval.ProcessSubmitRequest planApproval = new Approval.ProcessSubmitRequest();
         planApproval.setComments('Submitting request for approval.');
         planApproval.setObjectId(plan.Id);            
         // Submit on behalf of a specific submitter
         planApproval.setSubmitterId(UserInfo.getUserId());
         try{
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(planApproval);         
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals(
                'Pending', result.getInstanceStatus(), 
                'Instance Status'+result.getInstanceStatus());

                // Reject the submitted request
            // First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = 
                new Approval.ProcessWorkitemRequest();
            req2.setComments('Reject request.');
            req2.setAction('Reject');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
            
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            
            // Verify the results
            System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
            
            System.assertEquals(
                'Rejected', result2.getInstanceStatus(), 
                'Instance Status'+result2.getInstanceStatus());
        }catch(Exception e){

        }
        Test.stopTest();
    }

    
    /*
	 Method Name : createTestUser
	 Description : This method serves as a Utility method to create Test users.
	 Parameters	 : String, called from createTestUser, strProfileName Profile name.
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
        objTestUser.ManagerId = UserInfo.getUserId();
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        
        return objTestUser;
    }

}