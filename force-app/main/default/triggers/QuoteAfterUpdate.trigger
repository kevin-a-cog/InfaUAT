/*
        Trigger:        QuoteAfterUpdate
        @Author:        Rupanjana Mitra
        @Created Date:  24 August 2017
        @Description:   To populate field: Legal Entity based on field: sold to country
*/
/*
Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    Ritika Gupta      04/05/2018    TKT-001070    Nitin Gupta       Deactivating this trigger.                                             
    Chandana Gowda    16 Mar 21     TAX-105       Rob Newlin        Activating the trigger                      
    ********************************************************************************************************************************************  
    
*/
trigger QuoteAfterUpdate on SBQQ__Quote__c (after Update){
    
    if(globalApexManager.avoidRecursion('QuoteAfterUpdate') ) {
        return;
    }
    
    //Call the Helper class[QuoteTriggerHandler] method updateLegalEntity().   
    QuoteTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
}