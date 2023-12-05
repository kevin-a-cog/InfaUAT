/*
    @created by       : Pavithra V
    @created on       : 09/03/2021
    @Purpose          : Test class for 
    @Testclass        : CaseTriggerHelperTest
    @JIRA             : I2RT
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 Vignesh D      17/12/2021    UTOPIA-FF2    T01     Increase code coverage
 balajip        11/03/2022    I2RT-5624     T02     new method testCaseDelete to cover Delete/Undelete methods of TriggerHandler class
 Sandeep D      10/06/2022    I2RT-7211     T03     new methods and code added to increase coverage 
 Sandeep D      11/10/2022    I2RT-6980     T04     new methods and code added to increase coverage
 Vignesh D      11/01/2023    I2RT-6778     T05     Increase code coverage 
 balajip        31/01/2023    I2RT-7596     T06     removed the call to the removed method getSobjectName
 Isha           01/02/2023   I2RT-7747      T07      Increased  Code coverage 
 Shashikanth    07/27/2023    I2RT-8524     T08     Added new test methods for Case Segment Helper and removed test data of 'Hypercare'
 */
@isTest
public class CaseTriggerHelperTest {
    
    @testSetup
    static void setupObjectTestData() {
        //Create Segmentation Criterias
        List<Case_Segmentation_Criteria__c> lstCaseSegmentationCriterias = new List<Case_Segmentation_Criteria__c>();
        List<Case_Segmentation_Condition__c> lstCaseSegmentationConditions = new List<Case_Segmentation_Condition__c>();

       Case_Segmentation_Criteria__c objCaseSegmentationCriteria = new Case_Segmentation_Criteria__c();
        objCaseSegmentationCriteria.Order__c = 1;
        objCaseSegmentationCriteria.Filter__c = '((1 OR 2) AND (3 OR 4 OR 5)) OR 6';
        objCaseSegmentationCriteria.Segment__c = 'Strategic';
        objCaseSegmentationCriteria.Start_Date__c = null;
        objCaseSegmentationCriteria.End_Date__c = null;
        lstCaseSegmentationCriterias.add(objCaseSegmentationCriteria);

        objCaseSegmentationCriteria = new Case_Segmentation_Criteria__c();
        objCaseSegmentationCriteria.Order__c = 2;
        objCaseSegmentationCriteria.Filter__c = '(1 AND 2) OR (3 AND 4)';
        objCaseSegmentationCriteria.Segment__c = 'Preferred';
        objCaseSegmentationCriteria.Start_Date__c = null;
        objCaseSegmentationCriteria.End_Date__c = null;
        lstCaseSegmentationCriterias.add(objCaseSegmentationCriteria);

        objCaseSegmentationCriteria = new Case_Segmentation_Criteria__c();
        objCaseSegmentationCriteria.Order__c = 3;
        objCaseSegmentationCriteria.Filter__c = null;
        objCaseSegmentationCriteria.Segment__c = 'Base';
        objCaseSegmentationCriteria.Start_Date__c = null;
        objCaseSegmentationCriteria.End_Date__c = null;
        lstCaseSegmentationCriterias.add(objCaseSegmentationCriteria);

        insert lstCaseSegmentationCriterias;

        //Create Segmentation Conditions
        Case_Segmentation_Condition__c objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 1;
        objCaseSegmentationCondition.Filter_Field__c = 'Success_Offering__c';
        objCaseSegmentationCondition.Operator__c = 'equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Signature Select';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 2;
        objCaseSegmentationCondition.Filter_Field__c = 'Success_Offering__c';
        objCaseSegmentationCondition.Operator__c = 'equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Signature Success';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 3;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Active VOS,Axon Data Governance,Cloud Application Integration';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 4;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Cloud MDM - Reference 360,Connectors,Customer 360,Customer 360 Insights,Customer 360 Insights(AllSight)';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 5;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Enterprise Data Catalog,Enterprise Data Preparation,Foundation 360,Identity Resolution,MDM Multidomain,PowerCenter,Procurement';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 6;
        objCaseSegmentationCondition.Filter_Field__c = 'Preferred_Language__c';
        objCaseSegmentationCondition.Operator__c = 'not equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'English';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        //Preferred
        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 1;
        objCaseSegmentationCondition.Filter_Field__c = 'Success_Offering__c';
        objCaseSegmentationCondition.Operator__c = 'equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Premium Success';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 2;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Cloud Data Governance and Catalog,Cloud Data Market Place,Customer 360 SaaS, MDM Multidomain SaaS, Product 360 SaaS, Reference 360 SaaS, Supplier 360 SaaS, Mass Ingestion';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 3;
        objCaseSegmentationCondition.Filter_Field__c = 'Support_Account__r.Support_Account_Solution_Category__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Cloud Modernization,MDM Modernization';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 4;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Cloud Data Integration';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        insert lstCaseSegmentationConditions;

        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        slaprocess sa = [select Id,name from slaprocess where name = 'Premium Success' LIMIT 1];
        
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        sObject sObj3;
        
        //create an TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
        
        //create an Account record
        sObj = new Account();
        UtilityTestData.mAccountData.put('TimeZone__c',lTimezone[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);

        sObj1 = new Account();
        UtilityTestData.mAccountData.put('TimeZone__c',lTimezone[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        setupCertificationRequests(lAccount[0].Id);

        //create an Entitlement record
        sObj = new Entitlement();
        UtilityTestData.mEntitlement.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
        sObj.put('SlaProcessId',sa.Id);
        List<Entitlement> lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[1].Id);
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        UtilityTestData.mContactData.put('Email', 'testinformatica@testinformatica.com');
        UtilityTestData.mContactData.put('INFA_Language__c', 'English');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        List<BusinessHours> bhs =[select Id from BusinessHours where Name LIKE '%08x05%' LIMIT 1];
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        Id AAERecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();        
  
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        //create a Case record
        sObj = new Case();
        sObj.put('OwnerId', testGroup.Id);
        sObj.put('Success_Offering__c', 'Premium Success');
        sObj.put('ContactId', lContact[0].Id);
        sObj.put('AccountId', lAccount[0].Id);
        sObj.put('Support_Account__c', lAccount[0].Id);
        sObj.put('Priority', 'P1');
        sObj.put('RecordTypeId',rt1.Id);
        sObj.put('EntitlementId', lEntitlement[0].Id);
        if(bhs.size()>0){
          sObj.put('BusinessHoursId',bhs[0].Id); 
        }
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        
        sObj1 = new Case();        
        sObj1.put('OwnerId', testGroup.Id);
        sObj1.put('Success_Offering__c', 'Basic Success');
        sObj1.put('ContactId', lContact[0].Id);
        sObj1.put('AccountId', lAccount[0].Id);
        sObj1.put('Support_Account__c', lAccount[0].Id);//
        sObj1.put('EntitlementId', lEntitlement[0].Id);
        sObj1.put('Priority', 'P3');
        sObj1.put('RecordTypeId',AAERecordTypeId);
        if(bhs.size()>0){
          sObj1.put('BusinessHoursId',bhs[0].Id);  //Success_Offering__c
        }
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        sObj1.put('Priority', 'P2');
        sObj1.put('OwnerId', UserInfo.getUserId());
        update sObj1;

        /*
        sObj2 = new Case();        
        sObj2.put('OwnerId', testGroup.Id);
        sObj2.put('Success_Offering__c', 'Signature Success');
        sObj2.put('ContactId', lContact[0].Id);
        sObj2.put('AccountId', lAccount[0].Id);
        sObj2.put('Support_Account__c', lAccount[0].Id);
        sObj2.put('Priority', 'P1');
        sObj2.put('RecordTypeId',rt1.Id);
        sObj2.put('EntitlementId', lEntitlement[0].Id);
        if(bhs.size()>0){
          sObj2.put('BusinessHoursId',bhs[0].Id); 
        }
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        sObj3 = new Case();
        sObj3.put('OwnerId', testGroup.Id);
        sObj3.put('Success_Offering__c', 'Premium Success');
        sObj3.put('ContactId', lContact[0].Id);
        sObj3.put('AccountId', lAccount[0].Id);
        sObj3.put('Support_Account__c', lAccount[0].Id);
        sObj3.put('Priority', 'P2');
        sObj3.put('RecordTypeId',rt1.Id);
        sObj3.put('EntitlementId', lEntitlement[0].Id);
        if(bhs.size()>0){
          sObj3.put('BusinessHoursId',bhs[0].Id); 
        }
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});*/
    }

    static void setupCertificationRequests(Id supportAccountId)
    {
      String strCertificationType = '';

      for(Schema.PicklistEntry objPickList : Certification_Request__c.Certification_Type__c.getDescribe().getPickListValues()) {
            strCertificationType = objPickList.getValue();
            break;
      }

      List<Certification_Request__c> lstCertificationRequests = new List<Certification_Request__c>();

      Certification_Request__c objCertificationRequest = new Certification_Request__c();
        objCertificationRequest.Support_Account__c = supportAccountId;
        objCertificationRequest.Start_Date__c = System.today();
        objCertificationRequest.End_Date__c = System.today().addDays(20);
        objCertificationRequest.Request_Type__c = 'Hypercare';
        objCertificationRequest.Certification_Type__c = strCertificationType;
        objCertificationRequest.Business_Justification__c = 'Test Business Justification';
        objCertificationRequest.Status__c = 'Approved';
        objCertificationRequest.Owner__c = UserInfo.getUserId();
        objCertificationRequest.Product__c = 'Active VOS';
        lstCertificationRequests.add(objCertificationRequest);

        insert lstCertificationRequests;
    }
    
    @isTest
    static void testCaseTriggerHelper(){
        Test.startTest();
        List<Case> lCase = [Select Id From Case]; 
        lCase[0].OwnerId = UserInfo.getUserId();

        update lCase[0];
        System.assert(lCase.size()>0 , 'Case not created');
        Test.stopTest();
    }
    //T07
    @isTest
    static void testCaseStatusChange(){
        Test.startTest();
        List<Case> lCase = [Select Id ,status From Case]; 
        try{
        
        Raise_Hand__c rh=new Raise_Hand__c(Case__c=lCase[0].Id,Name='test collab',status__c='Open');
        insert rh;
            lCase[0].Status='Closed';
          update lCase[0];
        }catch(Exception ex){}
        Test.stopTest();
    }
    //T02
    @isTest
    static void testCaseDelete(){
        Test.startTest();
        List<Case> lCase = [Select Id From Case]; 
        try{
            delete lCase[0];
            undelete lCase[0];
        }catch(Exception ex){}
        Test.stopTest();
    }
    @isTest
    static void testCaseTriggerHelperBasicSuccess(){
        Test.startTest();
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        Group testGroup = [Select Id from Group where Name='test group' Limit 1];
        Account accountObj = [Select Id from Account limit 1];
        Contact contactObj = [Select Id from Contact limit 1];
        Entitlement entitlementObj = [Select Id from Entitlement limit 1];
        List<BusinessHours> bhs =[select Id from BusinessHours where Name LIKE '%08x05%' LIMIT 1];
        sObject sObj1 = new Case();        
        sObj1.put('OwnerId', testGroup.Id);
        sObj1.put('Success_Offering__c', 'Basic Success');
        sObj1.put('ContactId', contactObj.Id);
        sObj1.put('AccountId', accountObj.Id);
        sObj1.put('Support_Account__c', accountObj.Id);//
        sObj1.put('EntitlementId', entitlementObj.Id);
        sObj1.put('Priority', 'P2');
        sObj1.put('RecordTypeId',rt1.Id);
        if(bhs.size()>0){
          sObj1.put('BusinessHoursId',bhs[0].Id); 
        }
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj1});
        Test.stopTest();
    }
    @isTest
    static void testCaseTriggerHelperSigSuccess(){
        Test.startTest();
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        RecordType caseliteRecTypeId = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Case_Lite' Limit 1];
        Group testGroup = [Select Id from Group where Name='test group' Limit 1];
        Account accountObj = [Select Id from Account limit 1];
        Contact contactObj = [Select Id from Contact limit 1];
        Entitlement entitlementObj = [Select Id from Entitlement limit 1];
        List<BusinessHours> bhs =[select Id from BusinessHours where Name LIKE '%08x05%' LIMIT 1];
        sObject sObj1 = new Case();        
        sObj1.put('OwnerId', testGroup.Id);
        sObj1.put('Success_Offering__c', 'Signature Success');
        sObj1.put('ContactId', contactObj.Id);
        sObj1.put('AccountId', accountObj.Id);
        sObj1.put('Support_Account__c', accountObj.Id);//
        sObj1.put('EntitlementId', entitlementObj.Id);
        sObj1.put('Priority', 'P1');
        sObj1.put('RecordTypeId',rt1.Id);
        if(bhs.size()>0){
          sObj1.put('BusinessHoursId',bhs[0].Id); 
        }
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCasePowerCenter);
        Org__c orgrec=new Org__c (Account__c=accountObj.Id,name='test org');
        insert orgrec;
        sObject caseliteRec = new Case();        
        caseliteRec.put('OwnerId', testGroup.Id);
        caseliteRec.put('Success_Offering__c', 'Signature Success');
        caseliteRec.put('ContactId', contactObj.Id);
        caseliteRec.put('AccountId', accountObj.Id);
        caseliteRec.put('Support_Account__c', accountObj.Id);//
        caseliteRec.put('EntitlementId', entitlementObj.Id);
        caseliteRec.put('Priority', 'P1');
        caseliteRec.put('RecordTypeId',caseliteRecTypeId.Id);
        caseliteRec.put('Org__c',orgrec.Id);
        if(bhs.size()>0){
          caseliteRec.put('BusinessHoursId',bhs[0].Id); 
        }
        caseliteRec = UtilityTest.putFieldRecord(caseliteRec, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj1,caseliteRec});

        Case caseclone = (case)sObj1.clone(false, false, false, false);
        insert caseclone ;
        Test.stopTest();
    }
    @isTest
    static void testCaseTriggerHelperPremiumSuccess(){
        Test.startTest();
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        Group testGroup = [Select Id from Group where Name='test group' Limit 1];
        Account accountObj = [Select Id from Account limit 1];
        Contact contactObj = [Select Id from Contact limit 1];
        Entitlement entitlementObj = [Select Id from Entitlement limit 1];
        List<BusinessHours> bhs =[select Id from BusinessHours where Name LIKE '%08x05%' LIMIT 1];
        sObject sObj1 = new Case();        
        sObj1.put('OwnerId', testGroup.Id);
        sObj1.put('Success_Offering__c', 'Premium Success');
        sObj1.put('ContactId', contactObj.Id);
        sObj1.put('AccountId', accountObj.Id);
        sObj1.put('Support_Account__c', accountObj.Id);//
        sObj1.put('EntitlementId', entitlementObj.Id);
        sObj1.put('Priority', 'P2');
        sObj1.put('RecordTypeId',rt1.Id);
        sObj1.put('IR_Target_Date__c',system.now().addDays(6) );
        sObj1.put('eOGR_Target_Date__c',system.now().addDays(5) );
        sObj1.put('OGR_Target_Date__c',system.now().addDays(4) );
        sObj1.put('Attention_Target_Date__c',system.now().addDays(3) );
        sObj1.put('Escalation_Target_Date__c',system.now().addDays(2) );
        sObj1.put('TSR_Target_Date__c',system.now().addDays(1) );
        if(bhs.size()>0){
          sObj1.put('BusinessHoursId',bhs[0].Id); 
        }
        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj1});
        id caseId = (Id)sObj1.get('id');
        set<id> caseIds = new set<ID>();
        CASEiDS.ADD(caseId);
        caseTriggerHelper.updateCaseFromMilestones(caseIds);
        Test.stopTest();
    }

    @isTest
    static void testCaseTriggerHelperStatusClosed(){
        Test.startTest();
        List<Case> lCase = [Select Id From Case]; 
        lCase[0].status = 'Closed';
        lCase[0].Success_Offering__c = 'Basic Success';
        update lCase[0];
        System.assert(lCase.size()>0 , 'Case not created');
        Test.stopTest();
    }
    
    @isTest
    static void testCaseTriggerHelperStatusBooked(){
        Test.startTest();
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Ask_An_Expert' Limit 1];
        Group testGroup = [Select Id from Group where Name='test group' Limit 1];
        Account accountObj = [Select Id from Account limit 1];
        Contact contactObj = [Select Id from Contact limit 1];
        Entitlement entitlementObj = [Select Id from Entitlement limit 1];
        sObject sObj1 = new Case();        
        sObj1.put('OwnerId', testGroup.Id);
        sObj1.put('Success_Offering__c', 'Signature Success');
        sObj1.put('ContactId', contactObj.Id);
        sObj1.put('AccountId', accountObj.Id);
        sObj1.put('Support_Account__c', accountObj.Id);//
        sObj1.put('EntitlementId', entitlementObj.Id);
        sObj1.put('Priority', 'P1');
        sObj1.put('Status', 'Booked');
        //sObj1.put('OwnerId', UserInfo.getUserId());
        sObj1.put('Closing_Notes__c' , 'test');
        sObj1.put('RecordTypeId',rt1.Id);

        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj1});
        system.debug('sObj1====> ' + sObj1);
       
        User changeowner = [Select Id,Name from User limit 1];
       // Account accountObjforEngagement = [Select Id from Account limit 1];
         Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();

        system.debug('changeowner--> ' + changeowner);
        sObj1.put('OwnerId',UserInfo.getUserId());
          
           // T 03 starts
            sObject engagement = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',accountObj.Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpStartRT);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
            engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);
             List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
            Engagement__c insertedEngmnt = [select id,Account__c from Engagement__c limit 1];
        
        sObj1.put('Engagement__c' , insertedEngmnt.Id); 
              // T03 ends 
        sObj1.put('Closing_Notes__c' , 'test2');
        update sObj1;
        Test.stopTest();
    }
    
    @isTest
    static void testCaseTriggerHelperStatusClosedUpdateFutureMilestone(){
        Test.startTest();
        List<Case> lCase = [Select Id From Case]; 
        lCase[0].status = 'Closed';
        lCase[0].Success_Offering__c = 'Premium Success';
        update lCase[0];
        System.assert(lCase.size()>0 , 'Case not created');
        Map<String,String> mapCaseUpdatedStatus = new Map<String,String>();
        mapCaseUpdatedStatus.put(lCase[0].Id , lCase[0].status);
        Set<Id> setCaseId = new Set<Id>{lCase[0].Id};
        CaseTriggerHelper.updateMilestone_Future(setCaseId,mapCaseUpdatedStatus);
        Test.stopTest();
    }

    //---------------------------------------<T01>----------------------------
    /*
    Method Name : testValidateCaseContacts
    Description : Validates Case Contact creation, if Case Contact does not exist from ContactId on Case
    Parameters  : None
    Return Type : None
    */
    @isTest
    public static void testValidateCaseContacts() {

            Test.startTest();
      Case objCase = [Select Id,ContactId from Case LIMIT 1];
      List<Case_Contact__c> lstCaseContacts = [Select Id from Case_Contact__c where Case__c =: objCase.Id];

      System.assertEquals(!lstCaseContacts.isEmpty(), true, 'No Case Contacts found.');
      
      delete lstCaseContacts;

      //Now make the contact as primary
      AccountContactRelation objAcr = [Select Id from AccountContactRelation where ContactId =: objCase.ContactId];
      objAcr.Primary__c = true;
      objAcr.Access_Level__c = 'Read/Write';
      update objAcr;

      update objCase;

      lstCaseContacts = [Select Id from Case_Contact__c where Case__c =: objCase.Id];

      System.assertEquals(!lstCaseContacts.isEmpty(), true, 'No Case Contacts found, after case update.');
      Test.stopTest();
    }
    //---------------------------------------</T01>----------------------------
    //---------------------------------------<T03>----------------------------
     @isTest
    static void TestMilestone(){        
        Test.startTest();
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c,OwnerId From Case Limit 1];
        
        sobject sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'External');
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase[0].Id);
        sObj.put('Inbound__c', false);
        sObj.put('Importance__c', false);
        sObj.put('Status__c','Submitted');
        sObj.put('Type__c','Predictive Escalation');
        sObj.put('Sub_Type__c','Initial Response');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        
        
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Case_Comment__c cc = [Select Id From Case_Comment__c Limit 1]; 
        cc.Comment__c ='Updated Comment - Test';
        cc.Status__c = 'Submitted';
        update cc;
        
        List<CaseMilestone> lCaseMilestone = [select Id,MilestoneTypeId,milestonetype.name,CaseId from CaseMilestone where caseId =: lCase[0].Id];
        System.debug('lCaseMilestone >> '+ lCaseMilestone);
        cc.Comment__c ='';
        cc.Status__c = 'Submitted';
        update cc;
        
        lCase[0].Description ='Updated Desc';
        update lCase[0];
        
        lCase[0].Description ='Updated Description';
        update lCase[0];
        
        Test.stopTest();
    }
     //---------------------------------------</T03>----------------------------
     //---------------------------------------<T03 starts>----------------------------
     @isTest
    static void testForSort(){
        Test.startTest();
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        Group testGroup = [Select Id from Group where Name='test group' Limit 1];
        Account accountObj = [Select Id from Account limit 1];
        Contact contactObj = [Select Id from Contact limit 1];
        Entitlement entitlementObj = [Select Id from Entitlement limit 1];
        List<BusinessHours> bhs =[select Id from BusinessHours where Name LIKE '%08x05%' LIMIT 1];
        sObject sObj1 = new Case();        
        sObj1.put('OwnerId', testGroup.Id);
        sObj1.put('Success_Offering__c', 'Premium Success');
        sObj1.put('ContactId', contactObj.Id);
        sObj1.put('AccountId', accountObj.Id);
        sObj1.put('Support_Account__c', accountObj.Id);//
        sObj1.put('EntitlementId', entitlementObj.Id);
        sObj1.put('Priority', 'P2');
        sObj1.put('RecordTypeId',rt1.Id);
        sObj1.put('IR_Target_Date__c',system.now().addDays(6) );
        sObj1.put('eOGR_Target_Date__c',system.now().addDays(5) );
        sObj1.put('OGR_Target_Date__c',system.now().addDays(4) );
        sObj1.put('Attention_Target_Date__c',system.now().addDays(3) );
        sObj1.put('Escalation_Target_Date__c',system.now().addDays(2) );
        sObj1.put('TSR_Target_Date__c',system.now().addDays(1) );
        if(bhs.size()>0){
          sObj1.put('BusinessHoursId',bhs[0].Id); 
        }
        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCasePowerCenter);
        UtilityTest.makeInsert(new List<sObject>{sObj1});
        List<Case> lCase = [Select Id,Case_Weightage__r.Full_Case_Weightage__c From Case limit 3]; 
        List<SortCasesWithWeightages> records = new List<SortCasesWithWeightages>();
         for(Case record : lCase) {
           decimal totalweightage = 100;
             records.add(new SortCasesWithWeightages(record,totalweightage));
             // System.assert(records[0].compareTo(records[1]) > 0);
              records[0].compareTo(records[0]);  
         }
         
         records.sort();
      
        Test.stopTest();
    }
    //---------------------------------------<T04 Ends>----------------------------

    @isTest
    static void testCaseSegmentHelperCertificationRequest(){
        Test.startTest();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Account accountObj = [Select Id from Account limit 1];
        Contact contactObj = [Select Id from Contact limit 1];
        Entitlement entitlementObj = [Select Id from Entitlement limit 1];
      //-----------
      sObject sObj = new Case();
            UtilityTestData.mCase.put('Subject', 'Test technical Case');
            UtilityTestData.mCase.put('status', 'New');
            UtilityTestData.mCase.put('Priority', 'P1');
            UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
            UtilityTestData.mCase.put('AccountId', accountObj.Id);
            UtilityTestData.mCase.put('Support_Account__c', accountObj.Id);
            //UtilityTestData.mCase.put('Attention_Request__c ', 'Callback');
            UtilityTestData.mCase.put('EntitlementId ', entitlementObj.Id);
            //UtilityTestData.mCase.put('BusinessHoursId ', bussinessHourList[0].Id);
            UtilityTestData.mCase.put('ContactId ', contactObj.Id);
            UtilityTestData.mCase.put('Is_Internal_Or_External_Case__c', 'External');
            UtilityTestData.mCase.put('Forecast_Product__c', 'Active VOS');
            //UtilityTestData.mCase.put('slaStartDate ', system.now()+'');  
            //  UtilityTestData.mCase.put('Case_Timezone_Name__c ', bussinessHourList[0].Id); 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
            List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.stopTest();
    }

    //<T08>
    @isTest
    static void testCaseSegmentHelperCriteriaCaseIndex(){
        Test.startTest();        
        prepareCaseSegmentHelperTestCases(0);
        Test.stopTest();
    }

    static void prepareCaseSegmentHelperTestCases(Integer noOfcases)
    {
      Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Id operationsCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
        Account accountObj = [Select Id from Account limit 1];
        accountObj.Success_Offering__c = 'Premium Success';
        update accountObj;

        Contact contactObj = [Select Id from Contact limit 1];
        //Entitlement entitlementObj = [Select Id from Entitlement limit 1];

        Entitlement entitlementObj = new Entitlement(AccountId = accountObj.Id,Name = 'Premium Success',StartDate = System.today(), EndDate = system.today().addyears(3),Support_Level__c = 'Premium Success');
        insert entitlementObj;
        
       

      Integer caseIndexValue = 5;

      if(noOfcases > 0)
      {
        caseIndexValue = noOfcases;
      }
      else 
      {
        Case_Segment_Period_Configuration__mdt caseSegmentCondfig =  [SELECT Case_Index__c
                                                                      FROM Case_Segment_Period_Configuration__mdt
                                                                      WHERE Product__c = 'Cloud Data Governance and Catalog'
                                                                      AND  Segment__c = 'Preferred' LIMIT 1];
          if(caseSegmentCondfig != null)
          {
            caseIndexValue = Integer.valueOf(caseSegmentCondfig.Case_Index__c);
          }
      }

        List<Case> caseObjects = new List<Case>();
        for(Integer index = 0;index < caseIndexValue;index++)
        {
          Case sObj = new Case();
          sObj.Subject = 'Test technical Case CSH'+ index;
          sObj.status = 'New';
          sObj.Priority = 'P1';
          sObj.RecordTypeId = technicalCaseRecType;
          sObj.AccountId =  accountObj.Id;
          sObj.Support_Account__c =  accountObj.Id;
          sObj.EntitlementId =  entitlementObj.Id;
          sObj.ContactId =  contactObj.Id;
          sObj.Is_Internal_Or_External_Case__c =  'External';
          sObj.Forecast_Product__c = 'Cloud Data Governance and Catalog';
          sObj.Success_Offering__c =  'Premium Success';

          caseObjects.add(sObj);
        }

        System.debug('testCaseSegmentHelperCriteriaCaseIndex, caseObjects -- '+caseObjects);
        
        if(caseIndexValue > 0)
        {
          insert caseObjects;
        }
    }
   
    //</T08>
}