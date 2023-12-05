/*
 * Name         :   EmailMessageTrigger
 * Author       :   Monserrat Pedroza
 * Created Date :   2/6/2022
 * Description  :   Trigger for Email Message object

 Change History
 ******************************************************************************************************************************
 Modified By            Date            Jira No.        Description                                             Tag
 ******************************************************************************************************************************
Monserrat Pedroza      2/6/2022        N/A             Initial version.                                         N/A
Shashikanth            6/14/2023       I2RT-8533       GEMS - Chatter Post should also stop the GEMS Timer      T01
 */
trigger EmailMessageTrigger on EmailMessage(before insert, after insert) {
    //<T01>
    EmailMessageTriggerHandler emessageTriggerHandler = new EmailMessageTriggerHandler();
    emessageTriggerHandler.process();
    //</T01>
}