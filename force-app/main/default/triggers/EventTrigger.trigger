/*
 * Name			:	GlobalZoomUtilitiesClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	Utilities class for Zoom Integration.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 */
trigger EventTrigger on Event(after insert, after update) {

	//Now we decide the execution.
	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			ActivityTriggerHandler.afterInsert(Trigger.new);
		} else if(Trigger.isUpdate) {
			ActivityTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
		}
	}
}