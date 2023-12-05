/**
        Trigger:        weightageratingtrigger
        @Author:        VenkyK
        @Created Date:  24-Nov-2022
        @Description:   Trigger to handle different events for weightage rating object.

       Change History
    *******************************************************************************************************************************
    ModifiedBy          Date           Jira       Description                                                               Tag
    *******************************************************************************************************************************
   
*/

trigger Weightageratingtrigger on Weightage_Rating__c (after delete, after insert, after update, before delete, before insert, before update) {   
       if(trigger.isafter && trigger.isinsert){              
        	Weightagehandler wh = new Weightagehandler (Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);  
       }
}