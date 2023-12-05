/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for SubscriptionController and SubscriptionService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class SubscriptionControllerTest {
    public SubscriptionControllerTest() {

    }
    
    @testSetup
    static void setupObjectTestData() {
        
        //create a Case record
        SObject sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }

    @isTest
    static void testSubscriptionControllerMethods(){

        Case cse = [Select Id From Case Limit 1];

        Test.startTest();
            SubscriptionController subscriptionCtrl = new SubscriptionController();
            SubscriptionService subscriptionService = new SubscriptionService();

            SubscriptionController.getSubscriptionStatus(cse.Id, UserInfo.getUserId());
            SubscriptionController.toggleSubscription(cse.Id, UserInfo.getUserId(), true);
            SubscriptionController.getSubscriptionStatus(cse.Id, UserInfo.getUserId());
            SubscriptionController.toggleSubscription(cse.Id, UserInfo.getUserId(), false);
            SubscriptionController.getSubscriptionStatus(cse.Id, UserInfo.getUserId());
        Test.stopTest();
    }
}