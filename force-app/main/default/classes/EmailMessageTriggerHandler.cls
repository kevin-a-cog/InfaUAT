/*
Class:          EmailMessageTriggerHandler
@Author:        
@Created Date:  
@Description:   Handler class for EmailMessage Trigger

Change History
 ******************************************************************************************************************************
 Modified By            Date            Jira No.        Description                                             Tag
 ******************************************************************************************************************************
 Shashikanth            6/14/2023       I2RT-8533       GEMS - Chatter Post should also stop the GEMS Timer      T01
 */
public class EmailMessageTriggerHandler extends TriggerHandler{
    private EmailMessageTriggerHelper helper = new EmailMessageTriggerHelper();
	
    //<T01>
    public override void beforeInsert() {   
        
        if(globalApexManager.avoidRecursion('EmailMessageTrigger',  'before', 'insert') ) {
            return;
        }
        EmailMessageHandler.beforeInsert((List<EmailMessage>) newList);
    }
    //</T01>

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {   
        
        if(globalApexManager.avoidRecursion('EmailMessageTrigger',  'after', 'insert') ) {
            return;
        }
        helper.afterInsert((List<EmailMessage>) newList);
    }
}