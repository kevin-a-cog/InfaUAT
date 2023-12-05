/*
@created by       : SONIYA CHOUHAN
@created on       : 02/02/2021
@Purpose          : Handler class for psa_pm_ContentDocumentTrigger

Change History
***************************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                                     Jira No.        Tag
***************************************************************************************************************************************
Vivek Warrier   7-Oct-2021      Jeff Christensen    Throwing error on deletion of file from a Submitted Resume      PSA-106         T01
Vivek Warrier   7-Mar-2022      Jeff Christensen    Throwing error on update of file name on a Submitted Resume     PSA-            T02
Wasim Akram     23-Oct-2023     Manoj               PS Engagement SOW/Proposal documentation workflow               PSA-3173        T03  
*/
public class psa_pm_ContentDocumentTriggerHandler {
    /**    
    * @description - Method called on Before Delete
    * @param listOfContentLink - list of ContentDocument
    * @throws exception - NA
    */
    public static void onBeforeDelete(list<ContentDocument> listOfContentLink) {
        preventEngagementFileDeletion(listOfContentLink);//<T03>
        String objPrefix;
        Set<Id> setContentDocIds = new set<Id>();
        /*****<T01>**** */
        List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
        Set<Id> setResumeIds = new Set<Id>();
        Set<Id> setResumeToValidate = new Set<Id>();
        Map<Id,Id> mapContentDocToResumeID = new Map<Id,Id>();
        /*****</T01>**** */
        List<pse__Proj__c> projListToUpdate = new List<pse__Proj__c>();
         List<pse__Timecard_Header__c> tcListToUpdate = new List<pse__Timecard_Header__c >();
        List<AggregateResult> contentDocumentLinkList = new List<AggregateResult>();
        
        
        for(ContentDocument conDoc : listOfContentLink){
            setContentDocIds.add(conDoc.Id);
        }
        
        if(!setContentDocIds.isEmpty()){
            contentDocumentLinkList = [
                SELECT LinkedEntityId, COUNT(ContentDocumentId)proCount
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId IN :setContentDocIds
                    GROUP BY LinkedEntityId
            ];
            lstContentDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :setContentDocIds];
        }
        
        for(AggregateResult contentDoc : contentDocumentLinkList){
            objPrefix = String.valueOf(contentDoc.get('LinkedEntityId')).substring(0, 3);
            if(objPrefix == pse__Proj__c.sObjectType.getDescribe().getKeyPrefix()){
                if((Integer)contentDoc.get('proCount') <= 1){
                    
                        pse__Proj__c pro = new pse__Proj__c(Id = (String)contentDoc.get('LinkedEntityId'), PSA_PM_Has_Attachment__c = False);
                        projListToUpdate.add(pro);
                    
                }
            }
            
            if(objPrefix == pse__Timecard_Header__c.sObjectType.getDescribe().getKeyPrefix()){
                if((Integer)contentDoc.get('proCount') <= 1){                    
                        pse__Timecard_Header__c tcRec= new pse__Timecard_Header__c (Id = (String)contentDoc.get('LinkedEntityId'), PSA_TM_Has_Attachments__c = False);
                        tcListToUpdate.add(tcRec);
                    
                }
            }
        /****<T01>*****/
        }
        for(ContentDocumentLink contentDoc : lstContentDocLink){            
            objPrefix = String.valueOf(contentDoc.LinkedEntityId).substring(0, 3);
            if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix()){
                setResumeIds.add(contentDoc.LinkedEntityId);
                mapContentDocToResumeID.put(contentDoc.ContentDocumentId,contentDoc.LinkedEntityId);
            }
        /****</T01>*****/
        }

        /****************************************<T01>*******************************************************/        

        for(psa_Resume__c res : [SELECT Id,psa_Status__c FROM psa_Resume__c WHERE Id IN :setResumeIds]){
            if(res.psa_Status__c == 'Submitted' || res.psa_Status__c == 'Approved'){
                setResumeToValidate.add(res.Id);//Needs to throw error present in this set.
            }
        }
        if(!FeatureManagement.checkPermission('PSA_Operations') && !FeatureManagement.checkPermission('PSA_Deal_Desk') && !FeatureManagement.checkPermission('PSA_Resource_Manager')){
            for(ContentDocument cD : listOfContentLink){
                if(setResumeToValidate.contains(mapContentDocToResumeID.get(cD.Id))){
                    cD.addError('Sorry, this file is associated to a submitted Resume. Please contact the RMO.');
                }
            } 
        }   

        /*****************************************</T01>********************************************************/
        update projListToUpdate;
        update tcListToUpdate;
    }
    /** <T03>    
    * @description - Method to prevent file deletion when attached to the Engagement record
    * @param listOfContentLink - list of ContentDocument
    * @throws exception - NA
    */
    public static void preventEngagementFileDeletion(list<ContentDocument> listOfContentLink){
        Set<Id> setContentDocIds = new set<Id>();
        List<AggregateResult> contentDocumentLinkList = new List<AggregateResult>();
        String fileObjPrefix;
        String engagementObjPrefix = Engagement__c.sObjectType.getDescribe().getKeyPrefix();//Get the Engagement object's key prefix - a0A
        for(ContentDocument conDoc : listOfContentLink){
            //Store the Content Document Ids
            setContentDocIds.add(conDoc.Id);        
        }
        if(!setContentDocIds.isEmpty()){
            //Get the count of files under each Engagement
            contentDocumentLinkList = [
                SELECT LinkedEntityId, COUNT(ContentDocumentId)proCount
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId IN :setContentDocIds
                    GROUP BY LinkedEntityId
            ];
        }
        Set<Id> engagementList = new Set<Id>();
        for(AggregateResult contentDoc : contentDocumentLinkList){
             //Get the first three digits of the object the file is linked to
            fileObjPrefix = String.valueOf(contentDoc.get('LinkedEntityId')).substring(0, 3);
            if(fileObjPrefix == engagementObjPrefix){
                engagementList.add(String.valueOf(contentDoc.get('LinkedEntityId')));            
            }
        }
        //Check if the file is linked to Engagement
        for(Engagement__c eng : [SELECT Id,RecordType.developername,psa_Status__c FROM Engagement__c WHERE Id IN :engagementList]){
            if(eng.RecordType.developername == 'Professional_Services_SOW_Review' && eng.psa_Status__c != 'Draft'){
                listOfContentLink[0].addError('Cannot delete the file once uploaded. Use Upload New version button to upload a new file.');
            }
        }
    }
    //</T03>
    //<T02>
    public static void onBeforeUpdate(Map<Id,ContentDocument> mapOldContentDoc, List<ContentDocument> lstNewContentDoc){
        
        Set<Id> lstNameChangeCD = new Set<Id>();
        Set<Id> setResumeToValidate = new Set<Id>();
        List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
        String objPrefix;
        Set<Id> setResumeIds = new Set<Id>();
        Map<Id,Id> mapContentDocToResumeID = new Map<Id,Id>();

        for(ContentDocument cd : lstNewContentDoc){
            if(cd.Title != mapOldContentDoc.get(cd.Id).Title || cd.Description != mapOldContentDoc.get(cd.Id).Description){
                lstNameChangeCD.add(cd.Id);
            }
        }

        if(lstNameChangeCD.size() > 0){

            lstContentDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :lstNameChangeCD];

            if(lstContentDocLink.size() > 0){
                    
                for(ContentDocumentLink cdl : lstContentDocLink){                    
                    objPrefix = String.valueOf(cdl.LinkedEntityId).substring(0, 3);
                    if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix()){
                        setResumeIds.add(cdl.LinkedEntityId);
                        mapContentDocToResumeID.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                    }
                }
            }

            if(setResumeIds.size() > 0){
                for(psa_Resume__c res : [SELECT Id,psa_Status__c FROM psa_Resume__c WHERE Id IN :setResumeIds]){
                    if(res.psa_Status__c == 'Submitted' || res.psa_Status__c == 'Approved'){
                        setResumeToValidate.add(res.Id);//Needs to throw error present in this set.
                    }
                }

                if(!FeatureManagement.checkPermission('PSA_Operations') && !FeatureManagement.checkPermission('PSA_Resource_Manager')){
                    for(ContentDocument cD : lstNewContentDoc){
                        if(setResumeToValidate.contains(mapContentDocToResumeID.get(cD.Id))){
                            cD.addError('Sorry, this file is associated to a submitted Resume. Please contact the RMO.');
                        }
                    } 
                }
            }
        }
    }
    //</T02>
}