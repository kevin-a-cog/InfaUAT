/*
        Trigger:        UserBeforeInsert 
        @Author:        Deeksha
        @Created Date:  6/6/2022
        @Description:   Trigger on User for before Insert and Update

Change History
************************************************************************************************************************
ModifiedBy          Date         Jira Id        Description                                             Tag
Utkarsh Jain        28-04-2023   I2RT-6143      Changing Nickname in IN community                       1
************************************************************************************************************************
*/
    
trigger UserBeforeInsert on User (before insert,before update) {
    
    // Tag 1 - Start
    if(globalApexManager.avoidRecursion('UserBeforeInsert')) {
        return;
    }
    // Tag 1 - End

    //Added by Deeksha Shetty. Refer Tag T04 in UserTriggerHandler
    if(trigger.isBefore){
        if(trigger.isInsert){
            UserTriggerHandler.userBeforeInsertOrUpdate(trigger.New,trigger.OldMap,true);
        }
        if(trigger.isUpdate){            
            UserTriggerHandler.userBeforeInsertOrUpdate(trigger.New,trigger.OldMap,false);
        }        
    }

}