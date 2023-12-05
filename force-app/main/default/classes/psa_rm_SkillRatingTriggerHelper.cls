/*
Class:          psa_rm_SkillRatingTriggerHelper
@Author:        Vivek Warrier
@Created Date:  25-Nov-2021
@Description:   Helper Class for the psa_SkillRatingHandler.

Change History
**************************************************************************************************************************************
Modified by         Date            Description                                                                     JIRA          Tag
**************************************************************************************************************************************
Vivek Warrier       03-Jan-2022     Adding the AfterUpdate function + Resource Manager prepopulation                PSA-2044      T1                    
Wasim Akram         02-May-2022     On saving a rating for any skill the approval status is changing to Submitted   PSA-2411      T2 
*/
public class psa_rm_SkillRatingTriggerHelper {

    public void populateFieldsBeforeInsert(List<pse__Skill_Certification_Rating__c> newList){
        
        List<Id> contactIdList = new List<Id>();
        for(pse__Skill_Certification_Rating__c scr : newList){
            contactIdList.add(scr.pse__Resource__c);
        }

        Map<Id,Contact> mapContact = new Map<Id,Contact>([SELECT Id,pse__Region__c,pse__Salesforce_User__r.ManagerId FROM Contact WHERE Id IN :contactIdList]);

        for(pse__Skill_Certification_Rating__c scr : newList){
            if(mapContact.get(scr.pse__Resource__c) != null){
                scr.psa_Region__c = mapContact.get(scr.pse__Resource__c).pse__Region__c;
                scr.psa_Resource_Manager__c = mapcontact.get(scr.pse__Resource__c).pse__Salesforce_User__r.ManagerId; //<T1>
            }
        }
    }
    /*<T2> - Commented this code for a bug fix and the functionality is no more required
    public void updatesBeforeUpdate(Map<Id, pse__Skill_Certification_Rating__c> oldMap, Map<Id, pse__Skill_Certification_Rating__c> newMap){
        for(pse__Skill_Certification_Rating__c scr : newMap.values()){
            if(oldmap.get(scr.Id).pse__Rating__c != scr.pse__Rating__c && scr.pse__Approval_Status__c != 'Submitted'){
                scr.pse__Approval_Status__c = 'Submitted';
            }
        }
    }
    </T2> */
    //<T1>
    public void updatesAfterUpdate(Map<Id, pse__Skill_Certification_Rating__c> oldMap, Map<Id, pse__Skill_Certification_Rating__c> newMap){
        for(pse__Skill_Certification_Rating__c scr : newMap.values()){
            if(scr.pse__Approval_Status__c == 'Submitted' && oldMap.get(scr.Id).pse__Approval_Status__c != 'Submitted'){    
                // Create an approval request for S/C Rating        
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                req.setComments('Submitting Rating for Approval');        
                req.setObjectId(scr.id);
                // Submit the approval request for the S/C Rating        
                Approval.ProcessResult result = Approval.process(req);
            }
        }
    }   
    //</T1>
}