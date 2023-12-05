/*
    @created by       : cgowda
    @created on       : 08/08/22
    @Purpose          : test class for StripeNotificationTriggerHandler
    @JIRA             : PAYGIT-2
    
Change History
****************************************************************************************************************
ModifiedBy          Date            Jira No.            Description                                        Tag
****************************************************************************************************************
*/
@isTest
public class StripeNotificationTriggerHandlerTest {
    
    @testsetup
    private static void setupTestData(){
        sObject sObj = new Notification_Criteria__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        sObj.put('Evaluation_Trigger__c', 'Create');
        sObj.put('Notification_Type__c', 'MESSAGE_BUBBLE');
        sObj.put('Template_Name__c', 'Stripe_Event_Payment_Failed');
        sObj.put('Platform_Notification_Expiration__c', 5);
        sObj.put('Object__c', 'Stripe_Notification_API__c');
        sObj.put('Condition__c', 'Event_Type__c == \'Payment Failed - Pop Up\'');
              
        List<Notification_Criteria__c> lstNotifCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_Criteria_Detail__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteriaDetail);
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj.put('Field_API_Name__c', 'Event_Type__c');
        sObj.put('Field_Data_Type__c', 'PICKLIST');
        sObj.put('Operator__c', 'equals');
        sObj.put('Value__c', 'Payment Failed - Pop Up');
        List<Notification_Criteria_Detail__c> lstNotifCriteriaDetail = (List<Notification_Criteria_Detail__c>)UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Notification_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj.put('User_Type__c', 'All Org Users');
        sObj.put('Platform_Recipient_Role__c', 'Test');

        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj});        
    }
    
    @isTest
    private static void testPayload1(){
        Stripe_Notification_API__c notifyRec= new Stripe_Notification_API__c();
        notifyRec.Event_Type__c = 'Payment Failed - Pop Up';
        Test.startTest();
        insert notifyRec;
        Test.stopTest();
        notifyRec = [SELECT Payload__c FROM Stripe_Notification_API__c WHERE Id = :notifyRec.Id];
        System.assert(String.isNotBlank(notifyRec.Payload__c),'Error in processing Payload for Notification');
    }

    @isTest
    private static void testPayload2(){
        Stripe_Notification_API__c notifyRec= new Stripe_Notification_API__c();
        Test.startTest();
        insert notifyRec;
        Test.stopTest();
        notifyRec = [SELECT Payload__c FROM Stripe_Notification_API__c WHERE Id = :notifyRec.Id];
        System.assert(String.isBlank(notifyRec.Payload__c),'Error in processing Payload for Notification');
        
        //To cover recurrsion in Trigger
        notifyRec.Id = null;
        insert notifyRec;
    }    
}