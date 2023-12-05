/********************************************************************************************************************************************
*        Name        :        DisSchTrigger
*        Author      :        RamEsh M S
*        Date        :        03 November 2020
*        Description :        Handle Deletion of Discount Schedule
*********************************************************************************************************************************************
Change History
**************************************************************************************************************************************************************
ModifiedBy                  Date               Requested By               Description                                                                  Tag
**************************************************************************************************************************************************************    
**************************************************************************************************************************************************************/ 
trigger DisSchTrigger on SBQQ__DiscountSchedule__c (before delete) {
 if(globalApexManager.avoidRecursion('DisSchBeforeDelete') ) {
        return;
    }
restrictDelete.restrictDeletion('Discount Schedule',Trigger.Old);
}