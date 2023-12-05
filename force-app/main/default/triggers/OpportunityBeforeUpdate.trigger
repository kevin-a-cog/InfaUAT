/*
    Trigger:        OpportunityBeforeUpdate
    @Author:        Vivek Warrier
    @Created Date:  05-Apr-2018
    @Description:   Trigger for before update event on Oppty
*/
/*
Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By            Description                                                                             Tag
**********************************************************************************************************************************************************
Anusha			Apr 4, 2022		IPUE-213		   adding OpportunityUpdateFlag to bypass recursion for method (updatePrimaryESOnOpportunity)
*/
trigger OpportunityBeforeUpdate on Opportunity (before update) {

    //if(!OpportunityTriggerHandler.OpportunityUpdateFlag) {
        if(globalApexManager.avoidRecursion('OpportunityBeforeUpdate')) {
                return;
        }  
    //}
	
    OpportunityTriggerHandler.handlerBeforeUpdate(trigger.oldMap, trigger.newMap);
}