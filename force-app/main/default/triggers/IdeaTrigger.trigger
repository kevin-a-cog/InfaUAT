/*
* Name : IdeaTrigger
* Author : Deeksha Shetty
* Created Date : February 1,2022
* Description : Trigger for Idea. Created for Change Request Detail Page. Status change creates Idea Comment
Change History
*********************************************************************************************************************************************
Modified By            Date               Jira No.                            Description                                       Tag
Deeksha Shetty         10/02/2022         I2RT- Initial version.              Trigger for Idea Object                           N/A
Deeksha Shetty         13/09/2023         I2RT-9074                           Change Request Detail Page Enhancement             T1
**********************************************************************************************************************************************

*/

trigger IdeaTrigger on Idea (before insert,after insert,after update) {
    
    /* T1 Starts*/

    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true 
    ){
        return;
    }
    
    /* T1 Ends*/
    
    if(trigger.isBefore && trigger.isInsert){
        IdeaTriggerHandler handler = new IdeaTriggerHandler();
        handler.onBeforeInsert(trigger.New);
        
    }
        
    if(trigger.isAfter && trigger.isUpdate){
        IdeaTriggerHandler handler = new IdeaTriggerHandler();
        handler.onAfterUpdate(trigger.oldMap,trigger.newMap,trigger.New);
        
    }

}