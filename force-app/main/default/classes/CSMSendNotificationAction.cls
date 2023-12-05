/*
* Name          :   CSMSendNotificationAction
* Author        :   Pavithra V
* Created Date  :   26/11/2021
* Description   :   CSMSendNotificationAction

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Pavithra V             13/10/2021      N/A             Initial version.            N/A
*/
public class CSMSendNotificationAction {
    
    public static globalApexManager GAM = new globalApexManager();
    
    @InvocableMethod(label='Plan Communication - Send Notification to User' description='Send notification and submit the Plan comment' category='Plan Communication')
    public static void sendNotificationToUser(List<Id> idList) {
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName = :Label.CSM_Plan_Comment_Reminder];
        Set<Id> recordToUpdateIdSet = new Set<Id>();                                           
    
        for(Plan_Comment__c cc : [SELECT Id, CreatedById, Plan__r.Name, Comment__C FROM Plan_Comment__c WHERE Id IN :idList]) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('A Plan comment has been added to the plan : ' + cc.Plan__r.Name);
            notification.setBody('A new Plan comment has been added to the Plan:\n' + cc.Comment__c.replaceAll('<[/a-zAZ0-9]*>',' ').replaceAll('&nbsp;',' '));
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(cc.Id);
            try {
                notification.send(new Set<String> { cc.CreatedById });
                recordToUpdateIdSet.add(cc.Id);
            } catch (Exception e) {
                GAM.CreateExceptionRecords('Plan Comments : Remind me Notification failed! ', e.getMessage(), 'error from CSMSendNotificationAction');
            }
        }

        if(!recordToUpdateIdSet.isEmpty()) {
            List<Plan_Comment__c> planCommentList = new List<Plan_Comment__c>();
            for(Id ccId : recordToUpdateIdSet) {
                planCommentList.add(new Plan_Comment__c(Id = ccId, Status__c = 'Submitted'));
            }
            try {
                update planCommentList;
            } catch (Exception e) {
                GAM.CreateExceptionRecords('Plan Comments : Remind me > Update of Plan Comments failed! ', e.getMessage(), 'error from CSMSendNotificationAction');
            }
        }
    }

}