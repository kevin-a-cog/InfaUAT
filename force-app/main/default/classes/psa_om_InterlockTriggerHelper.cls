/*
    @created by       : MAHESH GANTI
    @created on       : 11/20/2020
    @Purpose          : PSA- related Interlock handler class.
    @Testclass        : 
    @JIRA             : 
    @Tag              : T01   
Change History
**********************************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                                       Jira No.        Tag
**********************************************************************************************************************************************
Pavithra V      09-Dec-2021     Cosmos              Commented the call to createProjectsFromInterlockIds method         AR-1584         T02
 */
public without sharing class psa_om_InterlockTriggerHelper {
   
    public void handleInterLockAfterInsert(List<Related_Opportunity_Plan__c> interLockRecs){

        system.debug('**ITH-newRecs**________'+interLockRecs);
        Set<Id> interLockIdSet = new Set<Id>();

        Id interLockPSRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Related_Opportunity_Plan__c' and developerName ='AdoptionServices'].Id;
        system.debug('**ITH-interLockPSRecTypeId**________'+interLockPSRecTypeId);

        for(Related_Opportunity_Plan__c ilRec : interLockRecs){
            if((interLockPSRecTypeId <> null) && (ilRec.RecordTypeId  == interLockPSRecTypeId)){
                interLockIdSet.add(ilRec.Id);
            }
        }
        system.debug('**ITH-interLockIdSet**________'+interLockPSRecTypeId);
        if(interLockIdSet.size()>0){
            //psa_ProjectFieldUpdatesHandler.createProjectsFromInterlockIds(interLockIdSet); //T02
        }
    }
}