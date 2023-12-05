/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-03-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * 
 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.            Description                 Tag
 **********************************************************************************************************
 NA                     NA              UTOPIA              Initial version.            NA
 Vignesh D              03-01-2022      I2RT-4972           Increase code coverage      T01
**/
@isTest
public  class EntitledProductControllerTest {
    @testSetup
    static void setupObjectTestData() {


        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            SObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
          
    
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Support Account');
            UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
            UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
    
              
          
            sObj = new Entitled_Product__c();
            UtilityTestData.mEntitledProduct.put('Support_Account__c', lNewSupportAccount[0].Id);
            UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance - Subscription');
            UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
            UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mEntitledProduct.put('Support_Level__c', 'Premium Success');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
            List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Technical_Product_Line__c();
            UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mtechnicalProductLine);
            List<Technical_Product_Line__c> lTechProdLine = (List<Technical_Product_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            

    }

    static testmethod void testTempSupportCreation(){

        Account SupportAccount = [Select id ,parentId,recordtype.name from account where recordtype.name ='Support Account' limit 1];

        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            List<String> unEntitledProducts =  EntitledProductController.getUnEntitledProducts(SupportAccount.Id);

            EntitledProductController.upsertTempSupport(SupportAccount.id,unEntitledProducts[0],System.today().addDays(100),'Basic Success','Test');

            List<Entitled_Product__c> lEntitledProduct= [Select id ,Name from Entitled_Product__c where Manual_Creation_override__c = true];
            Test.stopTest();
        }
    }

    //---------------------------------------<T01>----------------------------
    /*
    Method Name : testExtendProductSupport
    Description : Testing support extension for entitled product.
    Parameters	: None
    Return Type : None
    */
    @isTest
    public static void testExtendProductSupport() {

        Account objSupportAccount = [Select Id from Account where RecordType.Name = 'Support Account' limit 1];
        objSupportAccount.Success_Offering__c = 'Signature Success';
        update objSupportAccount;

        Entitled_Product__c objEntitledProduct = [Select Id,Name,End_Date__c,Reason_for_Extend_Support__c from Entitled_Product__c limit 1];
        objEntitledProduct.End_Date__c = System.today().addYears(1);
        objEntitledProduct.Reason_for_Extend_Support__c = 'Test Extend Support';

        Test.startTest();
        System.assertNotEquals(EntitledProductController.extendProductSupport(JSON.serialize(objEntitledProduct)), false,  'Cannot extend support for entitled product.');
        Test.stopTest();
    }
    //---------------------------------------</T01>----------------------------


}