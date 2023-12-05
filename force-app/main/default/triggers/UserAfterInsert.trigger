/*
        Trigger:        UserBeforeInsert 
        @Author:        Deloitte
        @Created Date:  10/27/2017
        @Description:   Trigger on User for after insert
*/

trigger UserAfterInsert on User (after insert) {
    
    UserTriggerHandler.userAfterInsert(trigger.newMap);
    UserTriggerHandler.sharingAfterInsert(trigger.New);
  
}