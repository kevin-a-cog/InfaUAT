/*
        Trigger:        AssetBeforeInsert 
        @Author:        Anil Solanki
        @Created Date:  15/03/2018
        @Description:   handler logic on before insert of asset
*/

trigger AssetBeforeInsert on Asset(Before Insert) {

        
    if(globalApexManager.avoidRecursion('AssetBeforeInsert')) {
                    return;
        }
    
    //AssetTriggerHandler.handleBeforeInsert (Trigger.new);


}