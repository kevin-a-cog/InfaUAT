/*
        Trigger:        QuoteBeforeInsert
        @Author:        Thejaswini Sattenapalli
        @Created Date:  25 July 2017
        @Description:   To populate the SBQQ__Quote__c object field values based on Opportunity Contact Roles From Related Opportunity
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Himanjan Bora     16 Aug 2017     --          Anil Solanki      Added the trigger framework for Recurssion check            --
                                                                    Line Number 21 through 23.                       
    Ritika Gupta      2 April 2018                Nitin Gupta       Updated recurssion logic to allow code execution for Before Insert twice, 
                                                                    as it is found that in CPQ renewal Process, CPQ creates 2 Quotes and deletes the fist one.
                                                                    And Added call to handleBeforeInsert method <T01> 
    Ambica Pyati    5/21/19        SALESRT-4229    Prasanth Sagar    Added Mute Check                                           T02
                  
    ********************************************************************************************************************************************

   
*/
trigger QuoteBeforeInsert on SBQQ__Quote__c (before Insert){
    /*if(globalApexManager.avoidRecursion('QuoteBeforeInsert') ) {
        return;
    }*/
    
   //------------------------------------------------------------<T02>
   //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true ){
        Return;
    }
   //-------------------------------------------------------------</T02>
   
    QuoteTriggerHandler.handleBeforeInsert(Trigger.New);
    
    
    //Call the Helper class[QuoteTriggerHandler] method updateSBQQ_Quote().   
    //QuoteTriggerHandler.updateSBQQ_Quote(Trigger.new); //commented this call, instead calling handleBeforeInsert() method.<T01>
    
}