@isTest
public class TestOutlookEmailController {
    
    static testMethod void testFetchContacts() {
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2');
        
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        UtilityTestData.mOpportunityData.put('CloseDate', String.valueOf(System.today()));
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3Q41.17B6O}');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
         Id RecordTypeIdSMG = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId();
        
        
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3qL.10q1u}');
       // UtilityTestData.mRelatedopportunityPlan.put('RecordType.Name','SMG');
        UtilityTestData.mRelatedopportunityPlan.put('recordtypeid',RecordTypeIdSMG);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Related_Opportunity_Plan__c relatedoppty=new Related_Opportunity_Plan__c();
        relatedoppty.Plan__c=lPlan[0].id;
        relatedoppty.Account__c=lAccount[0].id;
        relatedoppty.Opportunity__c=lOpportunity[0].id;
        relatedoppty.RecordTypeId=RecordTypeIdSMG;
         relatedoppty.Interlock_Type__c='Jumpstart';
        relatedoppty.Ignore_ABV__c=true;
        relatedoppty.Products__c='products text area';
        relatedoppty.Solution_Type__c='B2B Data Exchange';
        relatedoppty.Expected_Start_Date__c=System.today()-10;
        relatedoppty.First_Value__c='test first value';
        relatedoppty.Implementation_Owner__c='Customer';
        relatedoppty.Success_Pack__c='Test  Success';
        //relatedoppty.Original_Opportunity_Number__c='op12345';
        relatedoppty.Contract_StartDate__c=System.today()-10;
          relatedoppty.Contract_EndDate__c=System.today()+10;
        relatedoppty.Comments__c='test comments';
        //relatedoppty.Owner=u;
      // relatedoppty.Owner.FirstName= u.FirstName;
       // relatedoppty.Owner.LastName= u.LastName;
        relatedoppty.Project_Name__c='Test IPS PROJECT';
         relatedoppty.IPS_Package__c='JumpStart: Axon';
       relatedoppty.Level_of_Risk__c='Green';
           relatedoppty.Renewal_Likelihood__c='Certain';
        relatedoppty.Is_First_Year_Renewal__c=false;
       relatedoppty.Last_Contact_Date__c=System.today()-20;
        relatedoppty.Highest_Role_Engaged_With__c='Developer';
         relatedoppty.Business_Use_Case__c='test case';
        relatedoppty.Technical_Use_Case__c='test case tech';
relatedoppty.Non_Adopted__c='Active VOS'; 
        relatedoppty.Interested_products__c='Address Verification'; 
        relatedoppty.Adoption_Challenges__c='text area';
        relatedoppty.Additional_Information__c='test add';
relatedoppty.CSM_Summary__c='test summary';
      relatedoppty.Partner_name_if_any__c='NA';
        relatedoppty.Primary_challenge_s__c='Competitor Risk';
        
        insert relatedoppty;
        
       
        
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00DL.5y0LE:a3qL.10q1u}');
        UtilityTestData.mRelatedopportunityPlan.put('recordtypeid',RecordTypeIdSMG);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan2 = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});       
        List<EmailMessage> emails=new List<EmailMessage>();
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.RelatedToId = lRelatedopportunityPlan2[0].Id; 
        email.Interlock__c = lRelatedopportunityPlan2[0].Id; 
        emails.add(email);
        EmailMessage email2 = new EmailMessage();
        email2.FromAddress = 'test@abc.org';
        email2.Incoming = false;
        email2.ToAddress= 'test@xyz.org';
        email2.Subject = 'Test email2';
        email2.HtmlBody = 'Test email body2';
        email2.RelatedToId = lRelatedopportunityPlan[0].Id; 
        email2.Interlock__c = lRelatedopportunityPlan[0].Id; 
        emails.add(email2);
        
        
        insert emails;
        
        List<Id> emailIds=new List<Id>();
        for(EmailMessage em : emails)
        {
            emailIds.add(em.Id);
        }
        Attachment att = new Attachment();
        att.Name = 'test';
        att.Body = Blob.ValueOf('test');
        att.ParentId = emailIds[0];
        
        Insert att;
        
        
        Test.startTest();
        
        Plan__c pln=[select id,Name,Account__c,Thread_Id__c from Plan__c where id=:lPlan[0].Id];
        Related_Opportunity_Plan__c relatedoppty2=[SELECT Id,Interlock_Type__c,Account__c,Account__r.Name,Solution_Type__c,Project_Name__c,IPS_Project__c,IPS_Package__c,Products__c,Expected_Start_Date__c,
                                                  First_Value__c,Implementation_Owner__c,Support_Level__c,Success_Pack__c,Original_Opportunity__c,Original_Opportunity__r.Name,Technical_Use_Case__c,Adopted_Products__c,Non_Adopted__c,
                                                  Original_Opportunity_Number__c,Opportunity__c,Contract_StartDate__c,Contract_EndDate__c,Opportunity_ARR__c,Comments__c,Thread_Id__c,Account_Region_formula__c,Interested_products__c,
                                                  IPS_Project_Manager_Email__c,CreatedBy.Name,Opportunity_Owner_Email__c,Old_Org_Opportunity_Number__c,Renewal_Likelihood__c,
                                                  Is_First_Year_Renewal__c,Last_Contact_Date__c,Contact__c,Contact__r.Name,Owner.FirstName,Owner.LastName,Highest_Role_Engaged_With__c,Business_Use_Case__c,Adoption_Challenges__c,CSM_Summary__c,Additional_Information__c,
                                                  Renewal_Date_formula__c,Partner_name_if_any__c,Level_of_Risk__c,Key_customer_contact__c,Primary_challenge_s__c,Opportunity_Number__c from Related_Opportunity_Plan__c where id=:relatedoppty.Id]; 
        
        Related_Opportunity_Plan__c relatedoppty1=[SELECT Id,Interlock_Type__c,OwnerId,Account__c,Account__r.Name,Solution_Type__c,Project_Name__c,IPS_Project__c,IPS_Package__c,Products__c,Expected_Start_Date__c,
                                                   First_Value__c,Implementation_Owner__c,Support_Level__c,Success_Pack__c,Original_Opportunity__c,Original_Opportunity__r.Name,Technical_Use_Case__c,Adopted_Products__c,Non_Adopted__c,
                                                   Original_Opportunity_Number__c,Opportunity__c,Contract_StartDate__c,Contract_EndDate__c,Opportunity_ARR__c,Comments__c,Thread_Id__c,Account_Region_formula__c,Interested_products__c,
                                                   IPS_Project_Manager_Email__c,CreatedBy.Name,Opportunity_Owner_Email__c,Old_Org_Opportunity_Number__c,Renewal_Likelihood__c,
                                                   Is_First_Year_Renewal__c,Last_Contact_Date__c,Contact__c,Contact__r.Name,Owner.FirstName,Owner.LastName,Highest_Role_Engaged_With__c,Business_Use_Case__c,Adoption_Challenges__c,CSM_Summary__c,Additional_Information__c,
                                                   Renewal_Date_formula__c,Partner_name_if_any__c,Level_of_Risk__c,Key_customer_contact__c,Primary_challenge_s__c,Opportunity_Number__c from Related_Opportunity_Plan__c where id=:lRelatedopportunityPlan2[0].Id]; 
        
        System.debug('pln-->'+pln);
        User u=[Select Id, FirstName, LastName,Email from User where Id=:relatedoppty1.OwnerId];
        List<String> refIDForPlan= new List<String>();
        refIDForPlan.add(pln.Thread_Id__c);
        
        List<String> refIDForInterlock= new List<String>();
        refIDForInterlock.add(relatedoppty.Thread_Id__c);
        
         
      
        
        OutlookEmailController.fetchContacts(refIDForPlan,'Plan Subject');
        OutlookEmailController.fetchContacts(refIDForInterlock,'SMG Hand Off');
        OutlookEmailController.fetchContacts(refIDForInterlock,'CSM Request – Region');
        OutlookEmailController.fetchInterlock(relatedoppty.Id);
        OutlookEmailController.validateInterlock(relatedoppty.Id);
        OutlookEmailController.notifyViaEmail(relatedoppty2.Id); 
      //  OutlookEmailController.getRenewalOpptycloseDate(relatedoppty.Id);
        OutlookEmailController.getRenewalOpptycloseDate(relatedoppty1.Id);
        OutlookEmailController.fetchTemplate('JumpStart',relatedoppty2.Id); 
        OutlookEmailController.fetchTemplate('Renewal Rescue',relatedoppty2.Id);
        OutlookEmailController.fetchTemplate('Renewal Rescue',relatedoppty1.Id);
        OutlookEmailController.invokableSMGHandoffPostonEM(emailIds);
        OutlookEmailController.fetchemails(emailIds);
        OutlookEmailController.fetchAttachments(emailIds[0]);
        //OutlookEmailController.InterlockWrapper wrapper= new WrapperController.InterlockWrapper();
        
        
        Test.stopTest();
        
      
        
        
        
        
        
        
    }
    
    
}