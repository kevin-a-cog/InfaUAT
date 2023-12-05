/*
* Name			:	CSMMilestoneTriggerHandler
* Author		:	Pavithra V
* Created Date	: 	08/20/2021
* Description	:	Handler class which implements interface process methods for Trigger events on Milestone Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
*/
public class CSMMilestoneTriggerHandler extends TriggerHandler {
    
    private CSMMilestoneTriggerHelper helper = new CSMMilestoneTriggerHelper();

    public override void beforeInsert() {
        helper.processBeforeInsert((List<Milestone__c>) newList);
    }

    public override void beforeUpdate() {
       helper.processBeforeUpdate((List<Milestone__c>) newList,(Map<Id,Milestone__c>) oldMap);
    }
    
    public override void afterInsert() {
        helper.processAfterInsert((List<Milestone__c>) newList);
    }

    public override void afterUpdate() {
        helper.processAfterUpdate((List<Milestone__c>) newList,(Map<Id,Milestone__c>) oldMap);
    }
    
     public override void afterDelete() {
        helper.processAfterDelete((List<Milestone__c>) newList,(Map<Id,Milestone__c>) oldMap);
    }

   
}