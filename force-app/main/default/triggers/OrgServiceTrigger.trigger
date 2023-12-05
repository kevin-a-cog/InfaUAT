/*
 * Name         :   OrgServiceTrigger
 * Author       :   Vignesh Divakaran
 * Created Date :   8/29/2022
 * Description  :   Trigger for Org Service.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      8/29/2022       I2RT-7004       Initial version.                            N/A
 */
trigger OrgServiceTrigger on Org_Service__c (after insert, after update, before update) {
    new OrgServiceTriggerHandler().process();
}