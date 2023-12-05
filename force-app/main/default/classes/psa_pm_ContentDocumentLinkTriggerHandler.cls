/*
@created by       : SONIYA CHOUHAN
@created on       : 02/02/2021
@Purpose          : Handler class for psa_pm_ContentDocumentLinkTrigger
@Description      : Modified the whole class by adding helper class and unit of work pattern
Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
Vivek Warrier   23-Sep-2021     Neha Kumari         Adding Resume Files related changes                   PSA-106        T01
Vivek Warrier   11-Feb-2022     Jeff Christensen    Sharing all the resume files with RMO Resume Group    PSA-2228       T02
Wasim Akram     23-Oct-2023     Manoj               PS Engagement SOW/Proposal documentation workflow     PSA-3173       T03  
*/
public class psa_pm_ContentDocumentLinkTriggerHandler {
    public static Map<String,Set<Id>> mapLinkedEntity;//store the map of Object name and Linked Entity Ids
    public static Map<String,Set<Id>> mapContentDocument;//store the map of Object name and Content Document Ids
    /**  
    * @description - Method called on Before Insert of Content Document Link trigger
    * @param listOfContentLink - list of ContentDocumentLink
    * @throws exception - NA
    */
    public static void onBeforeInsert(list<ContentDocumentLink> listOfContentLink) {
        getMapIds(listOfContentLink); //method to get the linked entity ids and content document ids
        //Call Resume related functionality
        if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('psa_Resume__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.validationOnResume(listOfContentLink, mapLinkedEntity.get('psa_Resume__c')); 
        }
    }
    /**  
    * @description - Method called on After Insert of Content Document Link trigger
    * @param listOfContentLink - list of ContentDocumentLink
    * @throws exception - NA
    */
    public static void onAfterInsert(list<ContentDocumentLink> listOfContentLink) {
        //Call Engagement related functionalities
        if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('Engagement__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.preventEngagementFileCreation(listOfContentLink, mapLinkedEntity.get('Engagement__c'));//<T03>
            psa_pm_ContentDocumentLinkTriggerHelper.shareEngagementFileToApprovers(mapLinkedEntity.get('Engagement__c'));//<T03>
        }
        //Call timecard related functionality
        if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('pse__Timecard_Header__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.updateTimecardHeaders(mapLinkedEntity.get('pse__Timecard_Header__c'),'INSERT');
        }
        //Call Project related functionality
        if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('pse__Proj__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.updateProject(mapLinkedEntity.get('pse__Proj__c'), 'INSERT');
        }
        //Call Resume related functionality
        if(!mapContentDocument.isEmpty() && mapContentDocument.get('psa_Resume__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.shareResumeFileToRMOGroup(mapContentDocument.get('psa_Resume__c'));
        }
        psa_pm_ContentDocumentLinkTriggerHelper.callCommitMethod(listOfContentLink); //commit to the database
    }
    /**  
    * @description - Method called on Before Delete of Content Document Link trigger
    * @param listOfContentLink - list of ContentDocumentLink
    * @throws exception - NA
    */
    public static void onBeforeDelete(list<ContentDocumentLink> listOfContentLink) {   
        getMapIds(listOfContentLink); //method to get the linked entity ids and content document ids
         //Call timecard related functionality
         if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('pse__Timecard_Header__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.updateTimecardHeaders(mapLinkedEntity.get('pse__Timecard_Header__c'),'DELETE');
        }
        //Call Project related functionality
        if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('pse__Proj__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.updateProject(mapLinkedEntity.get('pse__Proj__c'),'DELETE');
        }
        //Call Resume related functionality
        if(!mapLinkedEntity.isEmpty() && mapLinkedEntity.get('psa_Resume__c') != null){
            psa_pm_ContentDocumentLinkTriggerHelper.validationOnResume(listOfContentLink, mapLinkedEntity.get('psa_Resume__c')); 
        }
        psa_pm_ContentDocumentLinkTriggerHelper.callCommitMethod(listOfContentLink); //commit to the database
    }
    /**  
    * @description - Method to get the map of LinkedEntity Id and ContentDocumentId of ContentDocumentLink records
    * @param listOfContentLink - list of ContentDocumentLink
    * @throws exception - NA
    */
    public static void getMapIds(list<ContentDocumentLink> listOfContentLink){
        String objPrefix;
        mapLinkedEntity = new Map<String,Set<Id>>();     
        mapContentDocument = new Map<String,Set<Id>>();

        for(ContentDocumentLink contentDocLink : listOfContentLink){
            objPrefix = String.valueOf(contentDocLink.LinkedEntityId).substring(0, 3);
            //store the list of projects if the file is related to the Project
            if(objPrefix == pse__Proj__c.sObjectType.getDescribe().getKeyPrefix() && mapLinkedEntity.containsKey('pse__Proj__c')){
                mapLinkedEntity.get('pse__Proj__c').add(contentDocLink.LinkedEntityId);
            }
            else if(objPrefix == pse__Proj__c.sObjectType.getDescribe().getKeyPrefix()){
                mapLinkedEntity.put('pse__Proj__c',new Set<Id>{contentDocLink.LinkedEntityId});
            }

            //store the list of project content document ids if the file is related to the Project
            if(objPrefix == pse__Proj__c.sObjectType.getDescribe().getKeyPrefix() && mapContentDocument.containsKey('pse__Proj__c')){
                mapContentDocument.get('pse__Proj__c').add(contentDocLink.ContentDocumentId);
            }
             else if(objPrefix == pse__Proj__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapContentDocument.put('pse__Proj__c',new Set<Id>{contentDocLink.ContentDocumentId});
            }

            //store the list of timecard headers if the file is related to the TCH
            if(objPrefix == pse__Timecard_Header__c.sObjectType.getDescribe().getKeyPrefix() && mapLinkedEntity.containsKey('pse__Timecard_Header__c')){
                mapLinkedEntity.get('pse__Timecard_Header__c').add(contentDocLink.LinkedEntityId);
            }
            else if(objPrefix == pse__Timecard_Header__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapLinkedEntity.put('pse__Timecard_Header__c',new Set<Id>{contentDocLink.LinkedEntityId});
            }             

            //store the list of timecard header content document id if the file is related to the TCH
            if(objPrefix == pse__Timecard_Header__c.sObjectType.getDescribe().getKeyPrefix() && mapContentDocument.containsKey('pse__Timecard_Header__c')){
                mapContentDocument.get('pse__Timecard_Header__c').add(contentDocLink.ContentDocumentId);
            }
            else if(objPrefix == pse__Timecard_Header__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapContentDocument.put('pse__Timecard_Header__c',new Set<Id>{contentDocLink.ContentDocumentId});
            }             

            //store the list of engagements if the file is related to the Engagement
            if(objPrefix == Engagement__c.sObjectType.getDescribe().getKeyPrefix() && mapLinkedEntity.containsKey('Engagement__c')){
                mapLinkedEntity.get('Engagement__c').add(contentDocLink.LinkedEntityId);
            }
            else if(objPrefix == Engagement__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapLinkedEntity.put('Engagement__c',new Set<Id>{contentDocLink.LinkedEntityId});
            }
             
            //store the list of engagement content document id if the file is related to the Engagement
            if(objPrefix == Engagement__c.sObjectType.getDescribe().getKeyPrefix() && mapContentDocument.containsKey('Engagement__c')){
                mapContentDocument.get('Engagement__c').add(contentDocLink.ContentDocumentId);
            }
            else if(objPrefix == Engagement__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapContentDocument.put('Engagement__c',new Set<Id>{contentDocLink.ContentDocumentId});
            }             

            //store the list of resumes if the file is related to the Engagement
            if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix() && mapLinkedEntity.containsKey('psa_Resume__c')){
                mapLinkedEntity.get('psa_Resume__c').add(contentDocLink.LinkedEntityId);
            }
            else if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapLinkedEntity.put('psa_Resume__c',new Set<Id>{contentDocLink.LinkedEntityId});
            }             

            //store the list of resume content document id if the file is related to the Engagement
            if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix() && mapContentDocument.containsKey('psa_Resume__c')){
                mapContentDocument.get('psa_Resume__c').add(contentDocLink.ContentDocumentId);
            }
            else if(objPrefix == psa_Resume__c.sObjectType.getDescribe().getKeyPrefix()) {
                mapContentDocument.put('psa_Resume__c',new Set<Id>{contentDocLink.ContentDocumentId});
            }             
        }
    }
}