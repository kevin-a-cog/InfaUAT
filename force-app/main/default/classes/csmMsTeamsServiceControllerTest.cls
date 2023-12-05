@isTest
public with sharing class csmMsTeamsServiceControllerTest {
    @isTest
    public static void testAllMethods() {
        
        //Now we create a Plan.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'Test';
		insert objPlan;
        
        Plan__c plan=[select Id from Plan__c limit 1];
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Role__c='CSM', Primary__c=true, Plan__c=plan.Id,User_Email__c='abc@abc.com',icollabTeam__c=true);
        insert new Plan_Team__c(User__c=UserInfo.getUserId(),Role__c='CSM Manager', Primary__c=true, Plan__c=plan.Id,User_Email__c='abc1@abc.com',icollabTeam__c=false);
        List<Plan_Team__c> plant=[select Id,icollabTeam__c,Plan__c from Plan_Team__c limit 2];
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new csmCalloutRestMock());
       	csmMsTeamsServiceController.doCallout_instantmeeting(objPlan.Id, 'MSTeam_Group_Chat_Id__c', 'plan_team__r', 'User_Email__c', 'Instant Meeting', 'eventSubject');
      	csmMsTeamsServiceController.doCallout_CreateGroupChat(objPlan.Id, 'MSTeam_Group_Chat_Id__c', 'plan_team__r', 'User_Email__c', 'Group_Chat_New', 'eventSubject');
        csmMsTeamsServiceController.doCallout_CreateGroupChat(objPlan.Id, 'Name', 'plan_team__r', 'User_Email__c', 'Group_Chat_New', 'eventSubject');
        
       	//csmMsTeamsServiceController.doCallout_Channel('channelinput', 'Group Chat');
       	csmMsTeamsServiceController.getData(plan.Id);
       	csmMsTeamsServiceController.updatePlanteamData(plant,plan.id);
        Test.stopTest();
        
    }
}