/*
@created by       : Wasim
@created on       : 25/Oct/2023
@Purpose          : Helper class for psa_pm_ContentDocumentLinkTrigger
@description      :
Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public without sharing class psa_pm_ContentDocumentLinkTriggerHelper {
    public static globalApexManager gam = new globalApexManager(); // To create debug logs and exception logs
    private static List<Schema.SObjectType> sObjects = new Schema.SObjectType[] {
                                                            ContentDocumentLink.SObjectType,
                                                            pse__Proj__c.SObjectType,
                                                            pse__Timecard_Header__c.SObjectType
                                                            };
    public static UnitOfWork uow = new UnitOfWork(sObjects);
    @TestVisible
    private static Id engFileSharingGrpId;
    @TestVisible
    private static Id rmoGroupId;
    /**  
    * @description - Method to display validation on Resume
    * @param listOfContentLink - list of ContentDocumentLink
    * @param setResumeIds - set of Resume Ids
    * @throws exception - NA
    */
    public static void validationOnResume(list<ContentDocumentLink> listOfContentLink, Set<Id> setResumeIds) {
        Set<Id> setResumeToValidate = new Set<Id>();
        String objPrefix;
        for(psa_Resume__c res : [SELECT Id,psa_Status__c FROM psa_Resume__c WHERE Id IN :setResumeIds]){
            if(res.psa_Status__c == 'Submitted' || res.psa_Status__c == 'Approved'){
                setResumeToValidate.add(res.Id);//Needs to throw error present in this set.
            }
        }

        if(!FeatureManagement.checkPermission('PSA_Operations') && !FeatureManagement.checkPermission('PSA_Resource_Manager')
           && !FeatureManagement.checkPermission('PSA_Deal_Desk')){
            for(ContentDocumentLink cDL : listOfContentLink){
                objPrefix = String.valueOf(cDL.LinkedEntityId).substring(0, 3);
                if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix() && !setResumeToValidate.isEmpty() && setResumeToValidate.contains(cDL.LinkedEntityId)){
                    cDL.addError('Sorry, this Resume has been submitted. Please create another one.');
                }
            }
        }
    }

    /** <T03>    
    * @description - Method to prevent attaching the file on the Engagement record when a file is already attached
    * @param listOfContentLink - list of ContentDocumentLink
    * @param engSet - set of Engagement Ids
    * @throws exception - NA
    */
    public static void preventEngagementFileCreation(list<ContentDocumentLink> listOfContentLink, Set<Id> engSet){        
        for(AggregateResult contentDoc : [SELECT LinkedEntityId, COUNT(ContentDocumentId)proCount
                                          FROM ContentDocumentLink
                                          WHERE LinkedEntityId IN :engSet AND LinkedEntity.recordtype.developername = 'Professional_Services_SOW_Review'
                                          GROUP BY LinkedEntityId
        ]){
            //If the Engagement record has more than one file attached
            if(Integer.valueOf(contentDoc.get('proCount')) > 1){
                listOfContentLink[0].addError('Cannot add multiple files. Use Upload New version button to upload a new file.');
            }
        }
    }
    //</T03> 

    /** <T03>    
    * @description - Method to share the file to the approvers as collaborators
    * @param engSet - set of Engagement Ids
    * @throws exception - NA
    */
    public static void shareEngagementFileToApprovers(Set<Id> engSet){
        Set<Id> cdSet = new Set<Id>();//Set to hold content document Ids of PSA record type related Engagements
        //Get only Engagement of PSA record Type related Content Document Links
        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId FROM ContentDocumentLink 
                                             WHERE LinkedEntityId IN : engSet AND 
                                             LinkedEntity.recordtype.developername = 'Professional_Services_SOW_Review'];
        for(ContentDocumentLink cdl : cdlList){
            cdSet.add(cdl.ContentDocumentId);
        }
        if(!Test.isRunningTest()){
            engFileSharingGrpId = [SELECT Id FROM CollaborationGroup WHERE Name = 'PSA Engagement File Sharing' OR Id = :Label.PSAEngagementFileSharingQueue LIMIT 1]?.Id;
        }
        
        //Share the file to the group members as Collaborators  
        if(String.isNotBlank(engFileSharingGrpId)){        
            for(Id cdId : cdSet){
                //Insert ContentDocumentLink - add users as collaborators for the attached file
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = cdId;//Add ContentDocumentId
                cDocLink.LinkedEntityId = engFileSharingGrpId;//Add attachment parentId
                cDocLink.ShareType = 'C';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                uow.registerNew(cDocLink);
            }
        }            
    }
    //</T03> 
    /**    
    * @description - Method to update Time card header
    * @param tcSetIds - set of timecard header Ids
    * @param operationType - insert/update/delete
    * @throws exception - NA
    */
    public static void updateTimecardHeaders(Set<Id> tcSetIds, String operationType){
        //On After Insert
        if(operationType == 'INSERT'){
            for(pse__Timecard_Header__c tcRec: [SELECT Id,PSA_TM_Has_Attachments__c 
                                                FROM pse__Timecard_Header__c 
                                                WHERE ID IN :tcSetIds]){
                if(!tcRec.PSA_TM_Has_Attachments__c){
                    tcRec.PSA_TM_Has_Attachments__c = TRUE;
                    uow.registerDirty(tcRec); 
                }
            }
        }
        //On After Delete
        else if(operationType == 'DELETE'){
            for(AggregateResult conDocTCRec : [SELECT LinkedEntityId,COUNT(ContentDocumentId)tcCount 
                                               FROM ContentDocumentLink
                                               WHERE LinkedEntityId IN :tcSetIds 
                                               GROUP BY LinkedEntityId]){
                if((Integer)conDocTCRec.get('tcCount') <= 1){              
                    pse__Timecard_Header__c tcRec = new pse__Timecard_Header__c(Id = (String)conDocTCRec.get('LinkedEntityId'), PSA_TM_Has_Attachments__c = False);
                    uow.registerDirty(tcRec);                  
                }
            }
        } 
    }
    /**    
    * @description - Method to update Time card header
    * @param setOfProjIds - set of project Ids
    * @param operationType - insert/update/delete
    * @throws exception - NA
    */
    public static void updateProject(Set<Id> setOfProjIds, String operationType){
        //On After Insert
        if(operationType == 'INSERT'){
            for(pse__Proj__c project : [SELECT Id, PSA_PM_Has_Attachment__c
                                        FROM pse__Proj__c 
                                        WHERE Id IN :setOfProjIds]){
                if(!project.PSA_PM_Has_Attachment__c){
                    pse__Proj__c pro = new pse__Proj__c(Id = project.Id, PSA_PM_Has_Attachment__c = true);
                    uow.registerDirty(pro); 
                }
            }
        }
        else if(operationType == 'DELETE'){
            for(AggregateResult contentDoc : [SELECT LinkedEntityId,COUNT(ContentDocumentId)proCount
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId IN :setOfProjIds
                                              GROUP BY LinkedEntityId]){
                if((Integer)contentDoc.get('proCount') <= 1){              
                        pse__Proj__c pro = new pse__Proj__c(Id = (String)contentDoc.get('LinkedEntityId'), PSA_PM_Has_Attachment__c = False);
                        uow.registerDirty(pro);                    
                }
            }
        }       
    }
    /**    
    * @description - Method to share file  attached to the Resume to RMO Resume group
    * @param setOfCDIds - set of content document link Ids
    * @throws exception - NA
    */
    public static void shareResumeFileToRMOGroup(Set<Id> setOfCDIds){
        if(!Test.isRunningTest()){
           rmoGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'RMO Resume Group' LIMIT 1]?.Id; 
        }        
        if(rmoGroupId != null){
            for(Id i : setOfCDIds){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = i;
                cdl.Visibility = 'AllUsers';
                cdl.ShareType = 'C';
                cdl.LinkedEntityId = rmoGroupId;
                uow.registerNew(cdl); 
            }            
        }
    }
    /**    
    * @description - Method that uses Unit of Framework to commit to the database
    * @param newList - list of content document link Ids
    * @throws exception - NA
    */
    public static void callCommitMethod(List<SObject> newList){       
        try{
            uow.commitWork();
        }
        catch(Exception e){
            gam.CreateExceptionRecords('Error caused from psa_pm_ContentDocumentLinkTriggerHelper class', e.getMessage(),newList[0].id);
        }
    }
}