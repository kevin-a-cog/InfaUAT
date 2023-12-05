public with sharing class CaseNotificationService extends NotificationService{
    public CaseNotificationService() {

    }
    @testvisible
    protected override String getTitle(){
        String title = ' ';
        if(!test.isRunningTest()){ title = 'Case #' + recordNew.get('CaseNumber');}
        return title;
    }
     @testvisible
    protected override String getTextMsgBody(){
        String body = '';
       
        if(!test.isRunningTest()){body = 'Subject: ' + recordNew.get('Subject');        body += newLine + 'Priority: ' + recordNew.get('Priority');        body += newLine + 'Product: ' + recordNew.get('Forecast_Product__c');}
        return body;
    }

}