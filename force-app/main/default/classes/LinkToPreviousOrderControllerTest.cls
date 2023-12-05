/*@Author:       Anil Solanki
*  @Created Date:  11/15/2019
*  @Description:   Test class for LinkToPreviousOrderController Classwith the updated test framework
* Change History
******************************************************************
* ModifiedBy          Date        Requested By        Description                 Tag
*
******************************************************************
*/
@isTest
private class LinkToPreviousOrderControllerTest {

    
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACC_Prospect_Account_Record_Type).getRecordTypeId());
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData); 
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.startTest();
        //Insert Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'New');
        UtilityTestData.mOpportunityData.put('CloseDate',System.today()+'');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lOpportunityRecord.size(), 1);
        
        //Insert Opportunity Contact Roles
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj = new OpportunityContactRole();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lContactRoles.size(), 1);
        
        sObj = new Product2();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        //sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData); 
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert a legal entity record
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create Quote
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[0].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
           test.stopTest();      
        //Create related Order record
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
        UtilityTestData.mOrderData.put('Ready_for_Billing_Received__c','False'); 
        UtilityTestData.mOrderData.put('Status','Review Completed'); 
        UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed'); 
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
        
        sObject sObj1 = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('Type','Amendment');
        UtilityTestData.mOrderData.put('Ready_for_Billing_Received__c','False'); 
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderData);
        
        List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
        
        sObj = new Old_Org_Order__c();
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mOldOrgOrderData );
        List<Old_Org_Order__c>  lOldOrgOrder = (List<Old_Org_Order__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }
    
    
     @isTest
    Static void LinkToPreviousOrderControllertest() {
        test.startTest();
        List<Order> lOrder = [Select Id from Order];
        List<Old_Org_Order__c> lOldOrgOrder = [Select Id,Name from Old_Org_Order__c];
        List<Previous_Order__c> POList = new List<Previous_Order__c>();
        Previous_Order__c po = new Previous_Order__c();
        po.Previous_Order_Apttus__c = lOldOrgOrder[0].Id;
        po.Previous_Order_Notes__c = 'Test';
        po.Order__c = lOrder[1].Id;
        POList.add(po);
        
        PageReference pageRef = page.LinkToPreviousOrder;
        pageRef.getParameters().put('id', String.valueOf(lOrder[1].Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lOrder[1]);
        LinkToPreviousOrderController controller = new LinkToPreviousOrderController(sc);
        controller.PreviousOrderList.addAll(POList);
        controller.SaveOrderRecords();
            test.stopTest();
    }
     @isTest
    Static void LinkToPreviousOrderControllertest1() {
        test.startTest();
        List<Order> lOrder = [Select Id from Order];
        List<Old_Org_Order__c> lOldOrgOrder = [Select Id,Name from Old_Org_Order__c];
        List<Previous_Order__c> POList = new List<Previous_Order__c>();
        Previous_Order__c po = new Previous_Order__c();
        po.Previous_Order_Apttus__c = lOldOrgOrder[0].Id;
        po.Previous_Order_Notes__c = 'Test';
        po.Previour_Order_CPQ__c = lOrder[1].Id;
        po.Order__c = lOrder[1].Id;
        POList.add(po);
        
        PageReference pageRef = page.LinkToPreviousOrder;
        pageRef.getParameters().put('id', String.valueOf(lOrder[1].Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(lOrder[1]);
        LinkToPreviousOrderController controller = new LinkToPreviousOrderController(sc);
        controller.PreviousOrderList.addAll(POList);
        controller.SaveOrderRecords();
            test.stopTest();
    }
}