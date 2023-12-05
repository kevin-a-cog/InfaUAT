@isTest
public class CaseCommentNotificationServiceTest {
    @testsetup
    static void loadData(){     
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        System.runAs(adminUser){
            //create a Case record
            sobject sObj = new Case();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
            sObj.put('OwnerId', UserInfo.getUserId());
            sObj.put('Subject', 'TestClass');
            
            List<Case> lcase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Subscription__c sub = new Subscription__c(Record_Id__c = lcase[0].Id,Subscribed__c = true);
            insert sub;
            
            
            CaseTeamRole teamRole = new CaseTeamRole(Name = 'Test',AccessLevel = 'Edit');
            insert teamRole;
            CaseTeamMember cseTeamMember = new CaseTeamMember(ParentId = lcase[0].Id,MemberId = UserInfo.getUserId(), TeamRoleId = teamRole.Id);
            insert cseTeamMember;
            
            //string cond = 'Visibility__c == '+'\''+ 'External' +'\'';
            string cond = 'Inbound__c == true';
            Notification_Criteria__c nc = new Notification_Criteria__c(Name = 'test', Notification_Type__c = 'Email', Template_Name__c = 'DonotUseThisTemplate',
                                                                      Evaluation_Trigger__c = 'Create/Edit', Object__c = 'Case_Comment__c', Active__c = true,
                                                                      Condition__c= cond);
        	insert nc;
            
            Notification_Criteria_Detail__c ncd = new Notification_Criteria_Detail__c(
                Notification_Criteria__c= nc.Id,Field_API_Name__c = 'Inbound__c');
            insert ncd;            
        }        
    } 
    static testmethod void testAllmethods(){
        Case cse = [SELECT Id FROM Case LIMIT 1];
        sobject SObjectNew = new Case_Comment__c(Inbound__c = true,Case__c = cse.Id,Visibility__c='Internal');
        insert SObjectNew;
        sobject SObjectOld = new Case_Comment__c(Inbound__c = false,Case__c = cse.Id,Visibility__c='External');
        insert SObjectOld;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CaseCommentNotificationServiceHttpMockup());
        NotificationService.notify(SObjectNew, SObjectOld);
        Test.stopTest();
    }
}