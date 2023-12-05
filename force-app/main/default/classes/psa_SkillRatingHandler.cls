/*
Class:          psa_SkillRatingHandler
@Author:        Vivek Warrier
@Created Date:  25-Nov-2021
@Description:   Handler Class for the Skill Rating trigger.

Change History
**************************************************************************************************************************************
Modified by         Date            Description                                                                     JIRA          Tag
**************************************************************************************************************************************
Wasim Akram         02-May-2022     On saving a rating for any skill the approval status is changing to Submitted   PSA-2411      T1 
*/
public class psa_SkillRatingHandler extends TriggerHandler{
   
    private psa_rm_SkillRatingTriggerHelper helper = new psa_rm_SkillRatingTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
       helper.populateFieldsBeforeInsert((List<pse__Skill_Certification_Rating__c>) newList);
    }

    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {        
      //helper.updatesBeforeUpdate((Map<Id, pse__Skill_Certification_Rating__c>) oldMap, (Map<Id, pse__Skill_Certification_Rating__c>) newMap);  <T1>   
    }
/*  Please uncomment and use
    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {        
        helper.updatesBeforeUpdate((Map<Id, pse__Skill_Certification_Rating__c>) oldMap, (Map<Id, pse__Skill_Certification_Rating__c>) newMap);
    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        
    }       
 */   
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {          
       helper.updatesAfterUpdate((Map<Id, pse__Skill_Certification_Rating__c>) oldMap, (Map<Id, pse__Skill_Certification_Rating__c>) newMap);
    }
/*
    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        
    }*/
}