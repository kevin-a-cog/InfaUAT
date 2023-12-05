/*
Class:          psa_rm_ResourceSkillUpdateBatch
@Author:        Vivek Warrier
@Created Date:  25-Nov-2021
@Description:   Batch class to change the status of a Skill Rating to Expired on reaching the Expiry Date.
*/
global class psa_rm_SkillRatingUpdateBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('psa_rm_ResourceSkillUpdateBatch, Line 9');
        Date dt = Date.today();
        string query = 'SELECT Id,psa_Status__c,pse__Expiration_Date__c FROM pse__Skill_Certification_Rating__c WHERE psa_External_Id__c = null AND pse__Expiration_Date__c < TODAY ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<pse__Skill_Certification_Rating__c> scope){
        List<pse__Skill_Certification_Rating__c> scrToBeUpdated = new List<pse__Skill_Certification_Rating__c>();
        for(pse__Skill_Certification_Rating__c scr : scope){
            scr.psa_Status__c = 'Expired';
            scrToBeUpdated.add(scr);
        }
        if(scrToBeUpdated.size() > 0){
            try{
                update scrToBeUpdated;
            }
            catch(exception e){
                System.debug('psa_rm_SkillRatingUpdateBatch, Error: ' + e.getMessage());
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }
}