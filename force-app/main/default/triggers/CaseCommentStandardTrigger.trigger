/*
Trigger:        CaseCommentStandardTrigger 
@Author:        SF Developer
@Created Date:  07-Apr-2021
@Description:   Trigger on the Standard Object CaseComment


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************

*/
trigger CaseCommentStandardTrigger on CaseComment (after insert) {
    
    //Iniitialize the handler method to be called
    private CaseCommentStandardHandler handler = new CaseCommentStandardHandler();

   
    
    //after insert
    if (trigger.isAfter &&  trigger.isInsert){
        //check for recursion
        if(globalApexManager.avoidRecursion('CaseCommentStandardTrigger', 'after', 'insert') ) {
            return;
        }

        handler.createcustomcasecomment(trigger.newMap); 
    }
}