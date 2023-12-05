/*
 * Name         :   CertificationRequestTrigger
 * Author       :   Vignesh Divakaran
 * Created Date :   5/27/2022
 * Description  :   Trigger for Certification Request.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      5/27/2022       I2RT-6149       Initial version.                            N/A
 */
trigger CertificationRequestTrigger on Certification_Request__c (before insert, after insert, before update, after update) {

    new CertificationRequestTriggerHandler().process();

}