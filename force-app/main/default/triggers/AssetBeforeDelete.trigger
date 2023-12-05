/*
        Trigger:        AssetBeforeDelete
        @Author:        Mitra Rupanjana
        @Created Date:  20 October 2017
        @Description:   Trigger on Asset Before Delete Operations
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy      Date        Requested By        Description   
    Anil Solanki    08/06/20      I2C-726           Commenting method deleteOrderStatus<T01>                                            
    ********************************************************************************************************************************************
   
*/
trigger AssetBeforeDelete on Asset (Before Delete) {
    if(globalApexManager.avoidRecursion('AssetBeforeDelete')){
    return;
    }
    
   //AssetTriggerHandler.deleteOrderStatus(trigger.oldMap); <T01>
}