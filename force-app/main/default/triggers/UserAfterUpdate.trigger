/*
        Trigger:        UserBeforeInsert 
        @Author:        Deloitte
        @Created Date:  10/27/2017
        @Description:   Trigger on User for after insert 
*/

trigger UserAfterUpdate on User (after update) {

    if(globalApexManager.avoidRecursion('UserAfterUpdate')) {
        return;
    }
    
    UserTriggerHandler.userAfterUpdate(trigger.newMap, trigger.oldMap);
    UserTriggerHandler.sharingAfterUpdate(trigger.New);

}