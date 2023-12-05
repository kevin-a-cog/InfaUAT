/*
    @created by       : Venky K
    @created on       : 4/29/2020
    @Purpose          : Interlock Trigger.
    @Testclass        : 
    @JIRA             : 
    @Tag              : T01
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 
*/
trigger InterlockTrigger on Related_Opportunity_Plan__c(after delete, after insert, after update, before delete, before insert, before update) {
        
/*Hierarchy custom setting created in the system with all the triggers names as //checkbox *fields, validation rules checkbox, process builder checkbox, workflow checkbox so that we can *control each logical implementation via custom setting controller.
**/
Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());

//check if the user/profile/org level access for the trigger is OFF/ON
        if (bts == null || bts.Interlock_trigger__c)  {
        System.debug('INTERLOCK TRIGGER ENTRY');
        //Calling the handler method to check for the context/recursive check of the trigger invocation.
                new InterlockTriggerHandler().process();
     }
}