/*
 * Name			:	CSMPartnerRelationshipTrigger 
 * Author		:	Deva M
 * Created Date	: 	08/07/2021
 * Description	:	Trigger on Partner Relationship Object

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					08/07/2021		N/A				Initial version.			N/A
 */
trigger CSMPartnerRelationshipTrigger on Partner_Relationship__c (after delete, after insert, after update, before delete, before insert, before update) {
    new CSMPartnerRelationshipTriggerHandler().process();
}