/*
        Trigger:        AssetBeforeUpdate
        @Author:        Anil Solanki
        @Created Date:  5 August 2017
        @Description:   Trigger on Asset Before Update Operations
*/

trigger AssetBeforeUpdate on Asset (before Update) {
    if(globalApexManager.avoidRecursion('AssetBeforeUpdate') ) {
        return;
    }

    //AssetTriggerHandler.handleBeforeUpdate(trigger.new);
    
}