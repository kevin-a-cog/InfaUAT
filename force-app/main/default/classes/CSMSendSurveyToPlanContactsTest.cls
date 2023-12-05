/*
* Name			:	CSMSendSurveyToPlanContactsTest
* Author		:	
* Created Date	: 	
* Description	:	CSMSendSurveyToPlanContacts Test class

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					                Tag
**********************************************************************************************************
 
 Chaitanya T       11/27/2023       AR-3408       Plan contact is not receiving Survey for 
                                                  another Engagement once responded to Survey   T01
*/
@isTest
public class CSMSendSurveyToPlanContactsTest {
    static Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() {
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        
        //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
        
        sObject contact1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        contact1 = UtilityTest.putFieldRecord(contact1, UtilityTestData.mContactData);
        
        sObject contact2 = new Contact();//<T01> start
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        contact2 = UtilityTest.putFieldRecord(contact2, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact,contact1,contact2});//</T01> end
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('AutoPilot_Status__c','Submitted for Approval');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',false+'');
        UtilityTestData.mPlan.put('Is_Internal__c',false+'');
        UtilityTestData.mPlan.put('Csm_Manager__c',UserInfo.getUserId()+'');
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('PAF_Frequency__c',30+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan}); 
        
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Role__c','Business Owner');//
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        //UtilityTestData.mPlanContact.put('Business_Outcome_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('Onboarding_Survey_Count__c','1');
        UtilityTestData.mPlanContact.put('CST_Survey_Sent__c','true');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        
        sObject technicalOwner = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[1].Id);
        UtilityTestData.mPlanContact.put('Role__c','Technical Owner');//
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        UtilityTestData.mPlanContact.put('Outcome_Survey_Count__c','1');
        //UtilityTestData.mPlanContact.put('Onboarding_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('CST_Survey_Sent__c','true');
        technicalOwner = UtilityTest.putFieldRecord(technicalOwner, UtilityTestData.mPlanContact);

        sObject technicalContributor = new Plan_Contact__c();//<T01> start
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[2].Id);
        UtilityTestData.mPlanContact.put('Role__c','Technical Contributor');//
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        UtilityTestData.mPlanContact.put('Outcome_Survey_Count__c','1');
        //UtilityTestData.mPlanContact.put('Onboarding_Survey_Sent__c','true');
        UtilityTestData.mPlanContact.put('CST_Survey_Sent__c','true');
        technicalContributor = UtilityTest.putFieldRecord(technicalContributor, UtilityTestData.mPlanContact);
        
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact,technicalOwner,technicalContributor});//</T01> end
        String OutcomeRecordTypeId = Schema.SObjectType.Survey_Response__c.getRecordTypeInfosByDeveloperName().get('CSP_Business_outcome').getRecordTypeId();
        String OnboardRecordTypeId = Schema.SObjectType.Survey_Response__c.getRecordTypeInfosByDeveloperName().get('CSP_Onboarding').getRecordTypeId();
        String cstRecordTypeId = Schema.SObjectType.Survey_Response__c.getRecordTypeInfosByDeveloperName().get('CST_Survey').getRecordTypeId();
        
        sObject onboardSurveyResponse = new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[0].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OnboardRecordTypeId);
        onboardSurveyResponse = UtilityTest.putFieldRecord(onboardSurveyResponse, UtilityTestData.mSurveyResponse);
        
        
        sObject outcomeSurveyResponse = new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[0].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OutcomeRecordTypeId);
        outcomeSurveyResponse = UtilityTest.putFieldRecord(outcomeSurveyResponse, UtilityTestData.mSurveyResponse);
        
        sObject cstSurveyResponse= new Survey_Response__c();
        UtilityTestData.mSurveyResponse.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mSurveyResponse.put('Plan_Contact__c',lPlanContact[0].Id);
        UtilityTestData.mSurveyResponse.put('RecordTypeId',OutcomeRecordTypeId);
        cstSurveyResponse = UtilityTest.putFieldRecord(cstSurveyResponse, UtilityTestData.mSurveyResponse);
        //List<Survey_Response__c> lsurveyResponse = (List<Survey_Response__c>) UtilityTest.makeInsert(new List<sObject>{outcomeSurveyResponse,cstSurveyResponse,onboardSurveyResponse}); 
        sObject engagement2 = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('RecType__c', 'CSA');//<T01>
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Approved');
        engagement2 = UtilityTest.putFieldRecord(engagement2, UtilityTestData.mEngagementData);
        
        sObject engMFA = new Engagement__c();//<T01> start
        UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('RecType__c', 'MFA');
        UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('Status__c','Approved');
        engMFA = UtilityTest.putFieldRecord(engMFA, UtilityTestData.mEngagementData);
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement2,engMFA});//</T01> end
    }
    
    @isTest
    public static void checkOnboardSurveyFlag(){
        List<String> planIdSet = new List<String>();
        List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c limit 1];
        for(Plan__c obPlan:plan){
            obPlan.Sub_Stage__c = 'Design';
            obPlan.OwnerId = UserInfo.getUserId();
            obPlan.Closing_Notes__c = 'Test';
            obPlan.Closing_Reason__c = 'Lost Opportunity';
            obPlan.Plan_Completeness_Status__c = 'Submitted for Approval';
            planIdSet.add(obPlan.Id);
        }
        CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(planIdSet, CSMSendSurveyToPlanContacts.ONBOARDING_SURVEY);
        //update plan;        
    }
    
    @isTest
    public static void checkOutcomeSurveyFlag(){
        List<String> planIdSet = new List<String>();
        List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c,Closing_Reason__c,Closing_Notes__c,Status__c,CST_Survey_Sent__c FROM Plan__c Limit 1 ];
        for(Plan__c obPlan:plan){
            obPlan.Sub_Stage__c = 'Optimize';
            obPlan.Status__c = 'Submitted for Approval';
            obPlan.Closing_Reason__c = 'Lost Opportunity';
            obPlan.Closing_Notes__c = 'Completed';
            planIdSet.add(obPlan.Id);
        }
        //update plan;
        CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(planIdSet, CSMSendSurveyToPlanContacts.OUTCOME_SURVEY); 
        
    }
    @isTest
    public static void checkCSTSurveyFlag(){
        Engagement__c eng = [Select id, status__c from Engagement__c Limit 1];
        eng.Status__c = 'Closed';
        update eng;
    }

    @isTest
    public static void checkCSASurveyFlag(){
        List<String> planIdSet = new List<String>();
        List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c,Closing_Reason__c,Closing_Notes__c,Status__c,CST_Survey_Sent__c FROM Plan__c Limit 1 ];
        for(Plan__c obPlan:plan){
            obPlan.Sub_Stage__c = 'Optimize';
            obPlan.Status__c = 'Complete';
            obPlan.Closing_Reason__c = 'Lost Opportunity';
            obPlan.Closing_Notes__c = 'Completed';
            planIdSet.add(obPlan.Id);
        }
        //update plan;
        CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(planIdSet, CSMSendSurveyToPlanContacts.CST_SURVEY); 
        
    }

    @isTest
    public static void checkMFASurveyFlag(){
        List<String> planIdSet = new List<String>();
        List<Plan__c> plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c,Closing_Reason__c,Closing_Notes__c,Status__c,CST_Survey_Sent__c FROM Plan__c Limit 1 ];
        for(Plan__c obPlan:plan){
            obPlan.Sub_Stage__c = 'Optimize';
            obPlan.Status__c = 'Complete';
            obPlan.Closing_Reason__c = 'Lost Opportunity';
            obPlan.Closing_Notes__c = 'Completed';
            planIdSet.add(obPlan.Id);
        }
        //update plan;
        CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(planIdSet, CSMSendSurveyToPlanContacts.MFA_SURVEY); 
        
    }

    @isTest
    public static void checkUpdateSurveyFlagOnEng(){
        Engagement__c engRec = [SELECT Id FROM Engagement__c WHERE RecType__c='MFA'];
        String strEngRecId = (String)engRec.Id;
        CSMSendSurveyToPlanContacts.updateSurveyFlagOnEng(strEngRecId,'MFA');
    }
}