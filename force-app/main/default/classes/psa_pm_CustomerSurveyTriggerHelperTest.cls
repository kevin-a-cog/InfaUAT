/*
@created by       : Pavithra V
@created on       : 12/04/2020
@Purpose          : Test class for psa_pm_CustomerSurveyTriggerHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest(seeAllData=false)
public class psa_pm_CustomerSurveyTriggerHelperTest {
    private static List<Schema.SObjectType> MY_SOBJECTS = 
            new Schema.SObjectType[]{
                Bypass_Trigger_Settings__c.SObjectType,
                Account.SObjectType,
                pse__Region__c.SObjectType,
                pse__Work_Calendar__c.SObjectType,
                Contact.SObjectType,
                Product2.SObjectType,
                Pricebook2.SObjectType,
                pricebookEntry.SObjectType,
                Opportunity.SObjectType,
                OpportunityLineItem.SObjectType,
                pse__Proj__c.SObjectType,
                pse__Time_Period__c.SObjectType,
                pse__Schedule__c.SObjectType,
                pse__Permission_Control__c.SObjectType,
                PSA_MSA_Code_Mapping__c.SObjectType,
                pse__Resource_Request__c.SObjectType,
                pse__Assignment__c.SObjectType,
                pse__Project_Location__c.SObjectType,
                pse__Timecard_Header__c.SObjectType,
                pse__Timecard__c.SObjectType,
                psa_pm_IPS_Customer_Survey__c.SObjectType,
                IPS_Customer_Survey_Line_Item__c.SObjectType
            };
    
    @testSetup
    static void setupObjectTestData() {
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_Customer_Survey_Trigger__c = true;
        uow.registerNew(trigSetting);
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;

        RecordType accRecType = [SELECT id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Customer_Account' Limit 1];
        
        Account accRec = new Account(Name='Test Account');
        uow.registerNew(accRec,Account.RecordTypeId,accRecType);

        pse__Region__c reg1 = new pse__Region__c(Name='Test Region-1',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-1->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true
                                                 );
        uow.registerNew(reg1);

        pse__Region__c reg2 = new pse__Region__c(Name='Test Region-2',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-2->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg2);

        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            uow.registerNew(defaultWorkCalendar);
            
            Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       psa_Target_Bill_Rate__c=10.00,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00,
                                       pse__Salesforce_User__c=userObj.Id,
                                       RecordTypeId=rt.Id);
            uow.registerRelationship(con1, Contact.AccountId,accRec);
            uow.registerRelationship(con1, Contact.pse__Region__c, reg1);
            uow.registerNew(con1, Contact.pse__Work_Calendar__c,defaultWorkCalendar);
            
            Product2 prod = new Product2(Name = 'Test',Offering_Type__c='Professional Services');
            uow.registerNew(prod);
            
            Id pricebookId = Test.getStandardPricebookId(); 
            
            Pricebook2 pricebook2Rec = new Pricebook2(Id = pricebookId,
                                                      IsActive = True);
            uow.registerDirty(pricebook2Rec,new List<SObjectField> { Pricebook2.Id,Pricebook2.IsActive });
            
            pricebookEntry pricebookEntryRec = new pricebookEntry();
            pricebookEntryRec.UnitPrice=100;
            pricebookEntryRec.CurrencyIsoCode='USD';
            pricebookEntryRec.IsActive=true;
            uow.registerRelationship(pricebookEntryRec,pricebookEntry.Pricebook2Id,pricebook2Rec);
            uow.registerNew(pricebookEntryRec,pricebookEntry.Product2Id,prod);

            Opportunity opty = new Opportunity(Type='Direct',
                                               CurrencyIsoCode='USD',
                                               StageName='Validate',
                                               Name = 'Test opportunity2',
                                               psa_om_Start_Date__c=System.today(),
                                               CloseDate = System.today().addDays(2),
                                               psa_om_End_Date__c=System.today()+10,
                                               psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                               PSA_OM_Project_Type__c='JumpStart'
                                               );   
            uow.registerRelationship(opty, Opportunity.Pricebook2Id,pricebook2Rec);                             
            uow.registerNew(opty, Opportunity.AccountId, accRec);

            OpportunityLineItem oppLine = new OpportunityLineItem(TotalPrice=2000,Quantity = 2);
            uow.registerRelationShip(oppLine,OpportunityLineItem.pricebookentryid,pricebookEntryRec);
            uow.registerNew(oppLine,OpportunityLineItem.OpportunityId,opty);
            
            pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Start_Date__c=System.today().addDays(-6),
                                                     pse__End_Date__c=System.today().addDays(10),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     psa_pm_Require_Product_On_Timecards__c=false,
                                                     pse__Allow_Self_Staffing__c=true,
                                                     pse__Is_Billable__c=true);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, accRec);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Project_Manager__c,con1);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Opportunity__c,opty);
            uow.registerNew(projRec1,pse__Proj__c.pse__Region__c ,reg1);

            pse__Time_Period__c tpRec = new pse__Time_Period__c(pse__Start_Date__c=System.today(),
                                                                pse__End_Date__c=System.today(),
                                                                pse__Type__c='Quarter');
            uow.registerNew(tpRec);

            pse__Schedule__c schRec = new pse__Schedule__c(pse__Start_Date__c=System.today().addDays(1),
                                                           pse__End_Date__c=System.today().addDays(10),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
            uow.registerNew(schRec);
            
            pse__Permission_Control__c pc = new pse__Permission_Control__c( pse__User__c = userObj.Id, 
                                                                            pse__Resource_Request_Entry__c = true, 
                                                                            pse__Staffing__c = true);
            uow.registerNew(pc, pse__Permission_Control__c.pse__Project__c, projRec1);

            PSA_MSA_Code_Mapping__c msaCodeMapping = new PSA_MSA_Code_Mapping__c(Name='Test Name');
            uow.registerNew(msaCodeMapping);
            
            pse__Resource_Request__c rrRec = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                          pse__End_Date__c=System.today().addDays(10),
                                                                          pse__SOW_Hours__c=8.00,
                                                                          pse__Resource_Role__c='Consultant',
                                                                          psa_rm_Billable__c=true,
                                                                          pse__Status__c='Draft');
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Staffer_Resource__c,con1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Resource__c,con1);    
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Region__c,reg1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Project__c,projRec1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Opportunity__c,opty);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping);
            uow.registerRelationShip(rrRec,pse__Resource_Request__c.PSA_OM_Opportunity_Product_Id__c,oppLine);
            uow.registerNew(rrRec, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty);
            
            pse__Assignment__c asgmt1 = new pse__Assignment__c(Name = 'Test Assignment',
                                                              pse__Planned_Hours__c = 8,pse__Bill_Rate__c = 0,pse__Is_Billable__c = true,pse__Role__c = 'Senior Consultant',pse__Cost_Rate_Amount__c=10.00);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Project__c, projRec1);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Schedule__c,schRec);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Resource_Request__c, rrRec);
            uow.registerNew(asgmt1, pse__Assignment__c.pse__Resource__c, con1);
            
            pse__Project_Location__c location = new pse__Project_Location__c(pse__End_Date__c=System.today(),pse__Start_Date__c=system.today()-6,psa_pm_Primary__c=true);
            uow.registerNew(location,pse__Project_Location__c.pse__Project__c,projRec1);

            pse__Timecard_Header__c testTimecard = new pse__Timecard_Header__c(
            pse__End_Date__c = system.today(),
            pse__Start_Date__c = system.today()-6,
            pse__Status__c = 'Saved',
            psa_pm_Project_Portfolio_Manager__c = userObj.Id,
            pse__Approver__c = userObj.Id
            );
            uow.registerRelationship(testTimecard,pse__Timecard_Header__c.pse__Resource__c,con1);
            uow.registerRelationship(testTimecard,pse__Timecard_Header__c.pse__Project__c,projRec1);
            uow.registerRelationship(testTimecard,pse__Timecard_Header__c.pse__Assignment__c,asgmt1);
            uow.registerNew(testTimecard,pse__Timecard_Header__c.pse__Primary_Project_Location__c,location);

            pse__Timecard__c timecard = new pse__Timecard__c(
            pse__Start_Date__c = System.today(),
            pse__End_Date__c = System.today()
            );
            uow.registerRelationship(timecard,pse__Timecard__c.pse__Resource__c,con1);
            uow.registerRelationship(timecard,pse__Timecard__c.pse__Assignment__c,asgmt1);
            uow.registerRelationship(timecard,pse__Timecard__c.pse__Timecard_Header__c,testTimecard);
            uow.registerNew(timecard,pse__Timecard__c.pse__Project__c,projRec1);

            psa_pm_IPS_Customer_Survey__c survey = new psa_pm_IPS_Customer_Survey__c(
            psa_pm_Survey_Sent_Date__c = System.today(),
            psa_pm_Survey_Response_Date__c = System.today(),
            psa_pm_Send_Survey__c = true ,
            psa_pm_Overall_technical_competence__c = '4',
            psa_pm_Accelerated_by_Adoption__c = '4',
            psa_pm_accuracy_in_meeting_deadlines__c = '4',
            psa_pm_coaching_and_knowledge_transfer__c ='4' ,
            psa_pm_understanding_projct_requirements__c = '4',
            psa_pm_Rate_our_Velocity_methodolgy__c = '4',
            psa_pm_Rate_Overall_communictn_teamwork__c= '4',
            psa_pm_Engagemnt_manged_initial_to_close__c ='4',
            psa_pm_How_did_PS_deliver_on_expectation__c  ='4'
            );
            uow.registerRelationShip(survey,psa_pm_IPS_Customer_Survey__c.psa_pm_Project__c,projRec1);
            uow.registerRelationShip(survey,psa_pm_IPS_Customer_Survey__c.psa_pm_Time_Period_Quarter__c,tpRec);
            uow.registerNew(survey,psa_pm_IPS_Customer_Survey__c.psa_pm_Customer_Contact__c,con1);

            IPS_Customer_Survey_Line_Item__c sItem = new IPS_Customer_Survey_Line_Item__c(
            Adoptiion_Overall_Abilities_Score__c = '9',
            Survey_Response_date__c = System.today()
            );
            uow.registerRelationShip(sItem,IPS_Customer_Survey_Line_Item__c.Consultant__c,con1);
            uow.registerNew(sItem,IPS_Customer_Survey_Line_Item__c.IPS_Customer_Survey__c,survey);

            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }
    }
    
    public static testMethod void surveyTriggerTest() {
        
        Test.startTest();
        
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        
        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
        
        List<psa_pm_IPS_Customer_Survey__c> lSurveyResults =[Select Id,psa_pm_Customer_Contact__c,psa_pm_Time_Period_Quarter__c,psa_pm_Survey_Sent_Date__c,psa_pm_Send_Survey__c,
                                                             psa_pm_understanding_projct_requirements__c,psa_pm_Accelerated_by_Adoption__c,psa_pm_Consultant_s_were_personable__c,psa_pm_consultants_skilled_knowledgeable__c,
                                                             psa_pm_Engagemnt_manged_initial_to_close__c,psa_pm_How_did_PS_deliver_on_expectation__c,psa_pm_Knowledge_transfer__c,
                                                             psa_pm_Performance_of_software_products__c,psa_pm_accuracy_in_meeting_deadlines__c,psa_pm_coaching_and_knowledge_transfer__c,
                                                             psa_pm_Rate_our_Velocity_methodolgy__c,psa_pm_Rate_Overall_communictn_teamwork__c,
                                                             psa_pm_Recommend_Informatica_val__c 
                                                             from psa_pm_IPS_Customer_Survey__c];
        
        System.assert(lSurveyResults.size()>0, 'Survey Results not created');

        List<IPS_Customer_Survey_Line_Item__c> lSurveyLineItemResults = [Select Id,Consultant__c,Adoptiion_Overall_Abilities_Score__c,Survey_Response_date__c,
                                                                         IPS_Customer_Survey__c from IPS_Customer_Survey_Line_Item__c];
        
        System.assert(lSurveyLineItemResults.size()>0, 'Survey Line Item not created');
        
        lSurveyResults[0].psa_pm_Consultant_1__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_2__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_3__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_4__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_5__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_6__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_7__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_8__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_9__c = lContact[0].Id;
        lSurveyResults[0].psa_pm_Consultant_10__c = lContact[0].Id;
        update lSurveyResults;
        
        Test.stopTest();
    }
    
    
}