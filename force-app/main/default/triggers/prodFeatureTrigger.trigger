/********************************************************************************************************************************************
*        Name        :        prodFeatureTrigger
*        Author      :        RamEsh M S
*        Date        :        03 November 2020
*        Description :        Handler Deletion of Product Feature 
*********************************************************************************************************************************************
Change History
**************************************************************************************************************************************************************
ModifiedBy                  Date               Requested By               Description                                                                  Tag
**************************************************************************************************************************************************************    
**************************************************************************************************************************************************************/ 
trigger prodFeatureTrigger on SBQQ__ProductFeature__c (before delete) {
 if(globalApexManager.avoidRecursion('prodFeaBeforeDelete') ) {
        return;
    }
restrictDelete.restrictDeletion('Product Feature',Trigger.Old);
}