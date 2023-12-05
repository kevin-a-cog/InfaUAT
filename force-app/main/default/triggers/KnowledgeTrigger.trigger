/*
    @created by       : Venky K
    @created on       : 4/29/2020
    @Purpose          : Knowledge Trigger.
    @Testclass        : 
    @JIRA             : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 
*/
trigger KnowledgeTrigger on Knowledge__kav(after delete, after insert, after update, before delete, before insert, before update) {
        
    /*Hierarchy custom setting created in the system with all the triggers names as //checkbox *fields, validation rules checkbox, process builder checkbox, workflow checkbox so that we can *control each logical implementation via custom setting controller.
    **/
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    
    //check if the user/profile/org level access for the trigger is OFF/ON
    if (bts == null || bts.Knowledge__c)  {
            
        //Calling the handler method to check for the context/recursive check of the trigger invocation.
        new KnowledgeTriggerHandler().process();
    }
}

/*trigger KnowledgeTrigger on Knowledge__kav (before update, after insert) {

    if(trigger.isupdate){
        Knowledge__kav oldKB;
        for(Knowledge__kav kb : trigger.new){
            oldKB = trigger.oldmap.get(kb.Id);
            if((kb.AQI_Score__c == NULL || kb.AQI_Score__c  == 0) && oldKB.Content_Reviewed_Date__c != kb.Content_Reviewed_Date__c){
                // kb.TR_Submitted_Date__c = null;
                // kb.ValidationStatus = 'Published';        
                kb.addError('Please review AQI Checklist before approving');

            }

            if(kb.Expiration_Term__c != oldKB.Expiration_Term__c){
                if(kb.LastPublishedDate == null){
                    kb.Expiration_Date__c = kb.createddate.date().addmonths(integer.valueof(kb.Expiration_Term__c.substring(0,2)));
                } else {
                    kb.Expiration_Date__c = kb.LastPublishedDate.date().addmonths(integer.valueof(kb.Expiration_Term__c.substring(0,2)));
                }
            }
        }
    }
    
    Set<Id> masterids = new Set<Id>();
    if(trigger.isinsert){
        for(Knowledge__kav kb : trigger.new){
            if(!kb.IsMasterLanguage){
            masterids.add(kb.MasterVersionId);
            }
        }
        if(masterids.size() > 0){
            Map<id,Knowledge__kav>  kavmap= new Map<Id,Knowledge__kav  >([Select Id,PublishStatus  from Knowledge__kav where Id in :masterids]);
            for(Knowledge__kav kav : trigger.new ){
                if(kavmap.get(kav.MasterVersionId).PublishStatus != 'Draft'){
                    kav.addError('You cannot create Translation article'); 
                }
            }
        }
    }
   
    if(trigger.isafter){
        List<Knowledge__kav> kbupdatelist = new List<Knowledge__kav>();
        for(Knowledge__kav kb : trigger.new){
            if(kb.UrlName != kb.ArticleNumber){
                kb.UrlName = kb.ArticleNumber;
                kbupdatelist.add(kb);
            }
        }
        if(kbupdatelist.size() > 0){
            try{
            update kbupdatelist;
            } catch (exception e){
            system.debug('Exception occured while updating'+e.getmessage()+';'+e.getlinenumber());
            }
        }
    }
}*/