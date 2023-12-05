/*
        Trigger:        QuoteAfterInsert
        @Author:        Rupanjana Mitra
        @Created Date:  24 August 2017
        @Description:   To populate field: Legal Entity based on field: sold to country
*/
trigger QuoteAfterInsert on SBQQ__Quote__c (after Insert){
    //public static Integer count = 0;
    
    /*if(count < 2){
        globalApexManager.allowRun('QuoteAfterInsert');
    } else */
    
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null && Global_config__c.getInstance().Mute_Triggers__c == true ){
        return;
    }
    
    if(globalApexManager.avoidRecursion('QuoteAfterInsert') ) {
        return;
    }
    
    //Call the Helper class[QuoteTriggerHandler] method updateSBQQ_Quote().   
    QuoteTriggerHandler.handleAfterInsert(Trigger.newMap, Trigger.oldMap);
    //count += 1;
}