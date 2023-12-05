@IsTest
public with sharing class ApprovalRequestCommentsControllerTest {
    @IsTest
    private static void test_get_comments() {
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Engagement__c engagementRec = new Engagement__c();
        engagementRec.Name = 'Test Engagement ';
        engagementRec.PSA_Sales_Notes__c='Sample Sales Notes ';
        engagementRec.Deal_Desk_Notes__c='Sample Deal Desk Notes ';
        engagementRec.PSA_Notify__c='NA Portfolio Manager;Individual';            
        engagementRec.psa_Region_GEO__c = 'EMEA';
        engagementRec.PSA_Notify_User__c= userObj.Id;  
        insert engagementRec;
        ApprovalRequestCommentsController contr = new ApprovalRequestCommentsController();
        contr.targetObjectId = engagementRec.Id;
        contr.comments = '';
        contr.getLastApprovalStep();
        Assert.areEqual('', contr.comments);
    }
}