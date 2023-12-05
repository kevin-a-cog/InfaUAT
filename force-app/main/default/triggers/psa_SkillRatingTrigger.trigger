trigger psa_SkillRatingTrigger on pse__Skill_Certification_Rating__c (before insert, before update,before delete, after insert, after update,after delete) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.psa_SkillRatingTrigger__c){
        new psa_SkillRatingHandler().process();
    }
}