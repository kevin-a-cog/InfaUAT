/*
    @created by       : SF Developer
    @created on       : 04/07/2021
    @Purpose          : CaseComment Standard object trigger handler class.
    @Testclass        : 
    @JIRA : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description   Jira No.       Tag
 ****************************************************************************************************
 */

public class CaseCommentStandardHandler {

    public void createcustomcasecomment(Map<Id, CaseComment> newMap) {
        for(CaseComment cc: newMap.values()){
            system.debug(cc.ParentId.getSObjectType().getDescribe().getName());
            system.debug(cc.CreatedBy.Name);
            system.debug(Label.jiraintegrationuser);
            String stringmatch = Label.CaseComment_Jira;
            //if(cc.ParentId.getSObjectType().getDescribe().getName() == 'Case' && cc.CreatedById == Label.jiraintegrationuser){
            if(!cc.CommentBody.contains(stringmatch)){
              if(cc.CreatedById == Label.jiraintegrationuser || test.isRunningTest()){
                 Case c = [Select OwnerId from Case where Id = :cc.ParentId];
                 Case_Comment__c ccustom = new Case_Comment__c();
                    ccustom.Case__c = cc.ParentId;                 
                    
                    ccustom.Comment__c = cc.CommentBody;                    
					ccustom.Visibility__c = 'Internal';
                    ccustom.Status__c = 'Submitted'; 
					ccustom.Type__c = 'JIRA Request'; 
                    ccustom.Inbound__c = false;
                    String sRegex = '^.*?-(.*)-.*$';
                    Pattern sPattern = Pattern.compile(sRegex);
                    system.debug(cc.CommentBody);
                    String textval = cc.CommentBody.stripHtmlTags();
                    Matcher sMatcher = sPattern.matcher(textval);
                    String sMatch = '';
                    if(sMatcher.matches()){
                      sMatch = sMatcher.group(1).trim();
                        for(zsfjira__ZIssue__c zi : [Select Id from zsfjira__ZIssue__c where Name = :sMatch LIMIT 1])  {
                          ccustom.ZIssue__c = zi.Id;
                        }
                    }
                    insert ccustom;
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                            FROM CustomNotificationType 
                            WHERE DeveloperName = :Label.Case_Comment_Reminder_Custom_Notification_Dev_Name];

                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(cc.ParentId);
                    notification.setSenderId(Label.jiraintegrationuser);
                    notification.setTitle('New Update from JIRA ');
                    notification.setBody(cc.CommentBody);
                	Set<String> recipientlist = new set<String>();
                	for(Subscription__c sc : [Select Subscriber_Id__c from Subscription__c where Record_Id__c = :cc.parentid and Subscribed__c = TRUE]){
                    	recipientlist.add(sc.Subscriber_Id__c);
                	} 
                	recipientlist.add(c.OwnerId);
                    try {
                        notification.send(recipientlist);
                    } catch (Exception e) {
                        System.debug('Problem sending notification: ' + e.getMessage());
                    }
             }
            }
        }
        
    }

    
}