/*
        Trigger:        AssetAfterUpdate
        @Author:        Ambica Pyati
        @Created Date:  5 Jan 2020
        @Description:   Trigger on Asset After Update Operations
*/
/*
    Change History
    ********************************************************************************************************************************************
   
    ********************************************************************************************************************************************
   
*/
trigger AssetAfterUpdate on Asset (after Update) {
    if(globalApexManager.avoidRecursion('AssetAfterUpdate') ) {
        return;
    }
    
    AssetTriggerHandler.handleAssetAfterUpdate(trigger.new, trigger.oldMap);
   
}