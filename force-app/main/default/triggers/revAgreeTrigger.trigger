/*
        Trigger:        revAgreeTrigger
        @Author:        RamEsh M S
        @Created Date:  08 July 2020
        @Description:    I2C-659
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                 Tag
********************************************************************************************************************************************************************************************************************
*/

trigger revAgreeTrigger on Revenue_Agreement__c (before insert,after insert, before update, after update) {

    
    if(trigger.isAfter && trigger.isUpdate)
    {
        if(globalApexManager.avoidRecursion('RevAgrrAfterUpdate')) {
        return;
        }

        revAgreeTriggerHandler.revAgrrAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
        
    if(trigger.isBefore && trigger.isUpdate)
    {    
        if(globalApexManager.avoidRecursion('RevAgrrBeforeUpdate')) {
        return;
        }
       
        revAgreeTriggerHandler.revAgrrBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }

}