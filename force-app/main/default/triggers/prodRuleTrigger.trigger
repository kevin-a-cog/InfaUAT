/********************************************************************************************************************************************
*        Name        :        prodRuleTrigger
*        Author      :        RamEsh M S
*        Date        :        03 November 2020
*        Description :        Handler Deletion of Product Rule 
*********************************************************************************************************************************************
Change History
**************************************************************************************************************************************************************
ModifiedBy                  Date               Requested By               Description                                                                  Tag
**************************************************************************************************************************************************************    
**************************************************************************************************************************************************************/ 
trigger prodRuleTrigger on SBQQ__ProductRule__c (before delete) {
 if(globalApexManager.avoidRecursion('prodRuleBeforeDelete') ) {
        return;
    }
restrictDelete.restrictDeletion('Product Rule',Trigger.Old);
}