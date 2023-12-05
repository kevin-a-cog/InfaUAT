/*
 @Purpose          : Handler class for ContentVersionTriggerHandler
 Change History 
 * ****************************************************************************************************************************
 * Modified By      Date            Requested By            JIRA No.        Description                                     Tag
 * ****************************************************************************************************************************
 * Vivek Warrier    18-Feb-2022     Jeff Christensen        PSA-2228        Prevention of Upload of new file version        T01
 *                                                                          when Resume is submitted
 * Jiju             24-Mar-2022     IPUE                    IPUE 161        Versioning of IPUE files created from Sdocs     T02
 * 
 * Rohit            18-Nov-2023     PSA Nov Build 23        PSA-3240        RevOps access issues                            T03
 */
public with sharing class ContentVersionTriggerHandler {

    //------------------------------<T01>
    //Prevention of Upload of new file version when Resume is submitted
    public static void processBeforeInsert(List<ContentVersion> conVerList){

        String objPrefix;
        List<Id> cdIds = new List<Id>();
        Set<Id> resumeIds = new Set<Id>();
        Map<Id,List<Id>> contentDocToResumeIdMap = new Map<Id,List<Id>>();
        Map<Id,String> idToResumeStatusMap = new Map<Id,String>();
        for(ContentVersion conver : conVerList){
            cdIds.add(conver.ContentDocumentId);
        }

        List<ContentVersion> contVerList = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :cdIds];
           
        if(contVerList.size() > 0){
            for(ContentDocumentLink cdl : [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :cdIds]){
                objPrefix = String.valueOf(cdl.LinkedEntityId).substring(0, 3);
                if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix()) {
                    if(contentDocToResumeIdMap.containsKey(cdl.ContentDocumentId)){
                        contentDocToResumeIdMap.get(cdl.ContentDocumentId).add(cdl.LinkedEntityId);
                    }
                    else{
                        contentDocToResumeIdMap.put(cdl.ContentDocumentId,new List<Id>{cdl.LinkedEntityId});
                    } 
                    resumeIds.add(cdl.LinkedEntityId);               
                }
            }
            

            if(resumeIds.size() > 0 ){
                for(psa_Resume__c res : [SELECT Id, psa_Status__c FROM psa_Resume__c WHERE Id IN: resumeIds]){
                    if(res.psa_Status__c == 'Submitted' || res.psa_Status__c == 'Approved'){
                        idToResumeStatusMap.put(res.Id,'FALSE');
                    }
                }
            }

            if((!FeatureManagement.checkPermission('PSA_Operations') && !FeatureManagement.checkPermission('PSA_Deal_Desk') && !FeatureManagement.checkPermission('PSA_Resource_Manager')) || Test.isRunningTest()){//T03
                for(ContentVersion cv : conVerList){
                    if(contentDocToResumeIdMap.size() > 0){
                        for(Id i : contentDocToResumeIdMap.get(cv.ContentDocumentId)){
                            if(idToResumeStatusMap.get(i) != null && idToResumeStatusMap.get(i) == 'FALSE'){
                                cv.addError('This document is tagged to a submitted/approved Resume. Please contact RMO.');
                            }
                        }
                    }
                }
            }
        }
    }
    //------------------------------</T01>

    public static void processAfterInsert(List<ContentVersion> conVerList){
        createContentDistribution(conVerList);
		handleVersionForIPUE(conVerList); //<T02>
    }
    
    public static void createContentDistribution(List<ContentVersion> conVerList){
        List<ContentDistribution> conDistList = new List<ContentDistribution>();
        for(ContentVersion conVer: conVerList){
            String relatedRecordId = conVer.FirstPublishLocationId;
            if(relatedRecordId != null && relatedRecordId.startsWith('500')){
                ContentDistribution conDist = new ContentDistribution();
                conDist.ContentVersionId = conVer.Id;
                conDist.Name = conVer.Title;
                conDist.PreferencesNotifyOnVisit = false;
                conDistList.add(conDist);
            }
        }
        if(!conDistList.isEmpty()){
          insert conDistList;    
        }
    }
    
    //-------------------------------------------------------------------------<T02>
    //Versioning of IPUE files created from Sdocs
    public static void handleVersionForIPUE(List<ContentVersion> conVerList){
        Set<Id> estSummIdSet = new Set<Id>();      
        Set<Id> conVerIdSet = new Set<Id>();
        Set<Id> conDocIdToDeleteSet = new Set<Id>();
        Map<Id,Id> estSumIdbyConVerIdMap = new Map<Id,Id>();
        List<ContentVersion> cloneConVersionList = new List<ContentVersion>();
        
        for(ContentVersion conVer: conVerList){
            if(conVer.FirstPublishLocationId != null && conVer.FirstPublishLocationId.getSObjectType() == Estimation_Summary__c.sObjectType){
                conVerIdSet.add(conVer.Id);
                estSummIdSet.add(conVer.FirstPublishLocationId);
                estSumIdbyConVerIdMap.put(conVer.Id,conVer.FirstPublishLocationId);
            }
        }
        
        if(!estSummIdSet.isEmpty()){
            Map<Id,List<contentDocumentLink>> estSumByConDocLinkLstMap = new Map<Id,List<contentDocumentLink>>();
            for(contentDocumentLink conDocLinkRec : [Select Id,ContentDocumentId,ContentDocument.Title,LinkedEntityId,SystemModstamp from contentDocumentLink where LinkedEntityId IN :estSummIdSet order by SystemModstamp desc]){
                if(estSumByConDocLinkLstMap.containsKey(conDocLinkRec.LinkedEntityId)) {
                    estSumByConDocLinkLstMap.get(conDocLinkRec.linkedEntityId).add(conDocLinkRec);
                } else {
                    estSumByConDocLinkLstMap.put(conDocLinkRec.linkedEntityId, new List<ContentDocumentLink>{conDocLinkRec});
                }
            }
            
            for(ContentVersion conVer : conVerList){
                if(conVerIdSet.contains(conVer.Id)){
                    for(contentDocumentLink conDocLinkRec : estSumByConDocLinkLstMap.get(estSumIdbyConVerIdMap.get(conVer.Id))){
                        if(conVer.Title == conDocLinkRec.ContentDocument.Title && conVer.contentDocumentId != conDocLinkRec.ContentDocumentId){
                            ContentVersion cloneConVersion = conVer.clone(false, false, false, false);
                            cloneConVersion.ContentDocumentId  = conDocLinkRec.ContentDocumentId;
                            cloneConVersion.ContentBodyId = null;
                            cloneConVersion.FirstPublishLocationId = null;
                            cloneConVersionList.add(cloneConVersion);
                            conDocIdToDeleteSet.add(conVer.ContentDocumentId);
                        }
                    }
                }
            }
            
            if(!cloneConVersionList.isEmpty()){
                insert cloneConVersionList;
            }
            
            if(!conDocIdToDeleteSet.isEmpty()){
                List<contentDocument> conDocToDeleteLst = [Select Id from ContentDocument where Id IN: conDocIdToDeleteSet];
                delete conDocToDeleteLst;
            }
        }

    }
    //-------------------------------------------------------------------------<T02/>
}