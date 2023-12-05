public with sharing class RaiseHandNotificationService extends NotificationService{
    public RaiseHandNotificationService() {

    }
    
    protected override String getTitle(){
        String title = 'Raise Hand request on the Case #' + recordNew.get('Case_Number__c');
        return title;
    }
    
    protected override String getTextMsgBody(){
        String body = 'Type: ' + recordNew.get('Type__c');
        body += newLine + 'Skill: ' + recordNew.get('Skill__c');
        return body;
    }

    protected override String getEmailMsgBody(){
        String body = 'Type: ' + recordNew.get('Type__c');
        body += newLine + 'Skill: ' + recordNew.get('Skill__c');
        return body;
    }
}