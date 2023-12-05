/*
Class:          ScheduleLimitsMonitoringAlertsTest 
@Author:        Mohammed Anies
@Created Date:  17 July 2020
@Description:   Test class for batch class ScheduleLimitsMonitoringAlerts 


Change History
*****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag
******************************************************************************************************************************
Uday Gangula		10/30/2023	Prasanth Sagar		SFPLAT-108; Automate Validation Rules to Clari on Oppty  <T01>
*/
@isTest
public class ScheduleLimitsMonitoringAlertsTest {
    public class CalloutMockValidResponse implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ValidationRule","records":[{"attributes":{"type":"ValidationRule","url":"/services/data/v38.0/tooling/sobjects/ValidationRule/03d5i000000QUfYAAW"},"Id":"03d5i000000QUfYAAW","EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v38.0/tooling/sobjects/EntityDefinition/Opportunity"},"DeveloperName":"Opportunity"},"ValidationName":"Opportunity_Stage","Metadata":{"description":"Opportunity Stage","errorConditionFormula":"ISPICKVAL(StageName, Engaged)","errorDisplayField":null,"errorMessage":"Opportunity Stage should be Closed Won","urls":null,"active":true}}]}');
            return res;
        }
    }
    
    public class CalloutMockInvalidResponse implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ValidationRule","records":[{"attributes":{"type":"ValidationRule","url":"/services/data/v38.0/tooling/sobjects/ValidationRule/03d5i000000QUfYAAW"},"Id":"03d5i000000QUfYAAW","ValidationName":"Opportunity_Stage","Metadata":{"description":"Opportunity Stage","errorConditionFormula":"ISPICKVAL(StageName, Engaged)","errorDisplayField":null,"errorMessage":"Opportunity Stage should be Closed Won","urls":null,"active":true}}]}');
            return res;
        }
    }
    
    static testMethod void testScheduleWithValidValidationResult() {
        Test.startTest();
        Org_Limits_History__c objOLH = new Org_Limits_History__c();
        objOLH.Limit_Name__c = 'DataStorageMB';
        objOLH.Limits_Actual_value__c = 5;
        insert objOLH;
        Test.setMock(HttpCalloutMock.class, new CalloutMockValidResponse());
        ScheduleLimitsMonitoringAlerts sPoll = new ScheduleLimitsMonitoringAlerts();
        String sch = '0 0 23 * * ?';
        Id scheduledJobId = System.schedule('Org limits alerts',sch,sPoll) ;
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :scheduledJobId];
        system.assertEquals(sch, ct.CronExpression);
        test.stopTest();        
    }
    
    static testMethod void testScheduleWithInvalidValidationResult() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockInvalidResponse());
        ScheduleLimitsMonitoringAlerts sPoll = new ScheduleLimitsMonitoringAlerts();
        String sch = '0 0 23 * * ?';
        Id scheduledJobId = System.schedule('Org limits alerts',sch,sPoll) ;
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :scheduledJobId];
        system.assertEquals(sch, ct.CronExpression);
        test.stopTest();        
    }
    
    static testMethod void testScheduleExceptionNotification() {
        Test.startTest();
        ScheduleLimitsMonitoringAlerts sPoll = new ScheduleLimitsMonitoringAlerts();
        String mailBody = '<html><body>';
         mailBody = mailBody + '<b> Exception: ' + '</b><br/><br/>';
         mailBody = mailBody + '</body></html>';
         ScheduleLimitsMonitoringAlerts.sendNotificationMail('Exception', mailBody,true);
        Integer afterinvocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(1, afterinvocations, 'An email should be sent:'+afterinvocations);           
    }
  
    static testMethod void testScheduleNotificationException() {
        Test.startTest();
        ScheduleLimitsMonitoringAlerts sPoll = new ScheduleLimitsMonitoringAlerts();
        String mailBody = null;
         ScheduleLimitsMonitoringAlerts.sendNotificationMail('Org Limits: notification exception', mailBody,true);
        Integer afterinvocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(0, afterinvocations, 'An email should be sent:'+afterinvocations);          
    }
}