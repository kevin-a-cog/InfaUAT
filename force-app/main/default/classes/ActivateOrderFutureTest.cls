@isTest
private class ActivateOrderFutureTest
{

    public static globalApexManager GAM = new globalApexManager();
    
    @isTest
    static void testActivateOrder()
    {
        //insert account
        sObject sObjAccount = new Account();
        sObjAccount = UtilityTest.putFieldRecord(sObjAccount,UtilityTestData.mAccountData);
        List<Account> accountlst = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjAccount});
        System.assertEquals(accountlst.size(),1);

        //insert contact 
        sObject sObjContact = new Contact();
        UtilityTestData.mContactData.put('AccountId',accountlst[0].Id);
        sObjContact = UtilityTest.putFieldRecord(sObjContact, UtilityTestData.mContactData);
        List<Contact> contactlst = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObjContact});
        System.assertEquals(contactlst.size(),1);

        //create Order.
        //Date myDate = Date.parse('02/12/2017');
        sObject sObjOrder = new Order();
        UtilityTestData.mOrderData.put('SoldToAccount__c',sObjAccount.Id);
        UtilityTestData.mOrderData.put('SoldToContact__c',sObjContact.Id);
        UtilityTestData.mOrderData.put('EndUserAccount__c',sObjAccount.Id);
        UtilityTestData.mOrderData.put('EndUserContact__c',sObjContact.Id);
        UtilityTestData.mOrderData.put('ShipToAccount__c',sObjAccount.Id);
        UtilityTestData.mOrderData.put('BilltoAccount__c',sObjAccount.Id);
        UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.Today()+'');
        UtilityTestData.mOrderData.put('SoldToAccount__c',sObjAccount.Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today().addDays(-300)+'');
        UtilityTestData.mOrderData.put('AccountId',sObjAccount.Id);
        sObjOrder = UtilityTest.putFieldRecord(sObjOrder,UtilityTestData.mOrderData);
        List<Order> orderlst = (List<order>) UtilityTest.makeInsert(new List<sObject>{sObjOrder});
        System.assertEquals(orderlst.size(),1);

        List<Order> orderList = new List<Order>();
        orderList.add((Order)sObjOrder);
        Set<Id> orderSet = new Set<Id>();
        orderSet.add(orderList.get(0).Id);
        
        ActivateOrderFuture.OrderProductsProvisioningCompelete(orderSet);
        List<Order> orderprovisioned = [Select Id,Name,Status from Order where Id IN : orderSet];
        System.assertEquals(orderprovisioned.size(),1); 
        
        ActivateOrderFuture.activateOrder(orderSet);
        List<Order> orderActivated = [Select Id,Name,Status from Order where Id IN : orderSet ];
        System.assertEquals(orderActivated.size(),1);
       
        ActivateOrderFuture.reviewCompletedOrder(orderSet);
        List<Order> orderReviewed = [Select Id,Name,Status from Order where Id IN : orderSet];
        System.assertEquals(orderReviewed.size(),1);    
     }
}