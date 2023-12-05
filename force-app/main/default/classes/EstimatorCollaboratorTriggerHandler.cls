/*
Class:  EstimatorCollaboratorTriggerHandler
@Author: Chandana Gowda
@Created Date: 14 FEB 2022
@Description: Trigger Handler for Estimator Collaborator events
@Jira: IPUE-156
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description
*************************************************************************************************************************************************************
*/
//Changing to without Sharing, to allow follow records
public without sharing class EstimatorCollaboratorTriggerHandler {

    
    private static globalApexManager GAM = new globalApexManager();
    private static String COMMUNITY_ID = Label.Success_Community_Id;

    /*Method Name : handleAfterInsert
    * @param mapNew - newMap: From Trigger
    * @return return-void
    * @throws exception - NA
    * @description - called from After Insert Trigger on Estimator_Collaborator__c
    */  
    public static void handleAfterInsert(Map<Id,Estimator_Collaborator__c> newMap){
        Set<Id> setEstimationSummaryId = new Set<Id>();
        Set<Id> setEstimatorCollabId = new Set<Id>();
        for(Estimator_Collaborator__c collab:newMap.values()){
            /* If the user field is populated on insert of estimation output, share the estimation output and estimation summary records
            *  Mostly invoked when any existing estimation summary is cloned along with the collaborators where the users are already provisioned by the integration*/
            if(collab.Active__c && collab.Dev_Community_User__c != null){
                setEstimationSummaryId.add(collab.Estimation_Summary__c);
                setEstimatorCollabId.add(collab.Id);
            }
        }

        if(!setEstimatorCollabId.isEmpty()){
            ShareEstimationSummary(setEstimationSummaryId,setEstimatorCollabId);
        }
    }

    /*Method Name : handleAfterUpdate
    * @param mapNew - oldMap: From Trigger, newMap: From Trigger
    * @return return-void
    * @throws exception - NA
    * @description - called from After update Trigger on Estimator_Collaborator__c
    */
    public static void handleAfterUpdate(Map<Id,Estimator_Collaborator__c> oldMap,Map<Id,Estimator_Collaborator__c> newMap){
        Set<Id> setEstimationSummaryToShareId = new Set<Id>();
        Set<Id> setEstimatorCollabToShareId = new Set<Id>();
        Set<Id> setEstimationSummaryToRevokeId = new Set<Id>();
        Set<Id> setEstimatorCollabToRevokeId = new Set<Id>();
        Set<Id> setCommunityUserToRevokeId = new Set<Id>();
        
        for(Estimator_Collaborator__c collab:newMap.values()){
            /*Share the estimation summary and output records with the collaborators when the user reference is updated on the collaborator record by integration
            * Also update the sharing when the Access or Active flag is updated by the user */
            if(collab.Dev_Community_User__c != null && (collab.Dev_Community_User__c != oldMap.get(collab.Id).Dev_Community_User__c || collab.Active__c != oldMap.get(collab.Id).Active__c || collab.Access__c != oldMap.get(collab.Id).Access__c)){
                if(collab.Active__c){ //If the collaborator is active, share the estimation summary and output records
                    setEstimationSummaryToShareId.add(collab.Estimation_Summary__c);
                    setEstimatorCollabToShareId.add(collab.Id);
                }else if(collab.Active__c != oldMap.get(collab.Id).Active__c){ //If the collaborator is made inactive, revoke the estimation summary and output record access
                    setEstimationSummaryToRevokeId.add(collab.Estimation_Summary__c);
                    setEstimatorCollabToRevokeId.add(collab.Id);
                    setCommunityUserToRevokeId.add(collab.Dev_Community_User__c);
                }
            }
        }

        if(!setEstimatorCollabToShareId.isEmpty()){
            ShareEstimationSummary(setEstimationSummaryToShareId,setEstimatorCollabToShareId);
        }

        if(!setEstimatorCollabToRevokeId.isEmpty()){
            RevokeEstimatorAccess(setEstimationSummaryToRevokeId,setEstimatorCollabToRevokeId,setCommunityUserToRevokeId);
        }
    }

    /*Method Name : ShareEstimationSummary
    * @param mapNew - setEstimationSummaryId - Set of Estimation Summary Id, setEstimatorCollabId - Set of Collabs to share record with
    * @return return-void
    * @throws exception - NA
    * @description - Manually share the estimation summary and estimation output records with the collaborators in setEstimatorCollabId
    */
    public static void ShareEstimationSummary(Set<Id> setEstimationSummaryId,Set<Id> setEstimatorCollabId){
        List<Estimation_Summary__c> lstEstimationSummary = [SELECT Id,CreatedById,(SELECT Id,Dev_Community_User__c,Access__c FROM Estimator_Collaborators__r WHERE Id IN :setEstimatorCollabId),(SELECT Id FROM Estimation_Outputs__r) FROM Estimation_Summary__c WHERE Id IN :setEstimationSummaryId];
        List<Estimation_Summary__Share> lstEstimationSummaryShareInsert = new List<Estimation_Summary__Share>();
        List<Estimation_Output__Share> lstEstimationOutputShareInsert = new List<Estimation_Output__Share>();
        Set<String> setRecordUserIds = new Set<String>(); //Set of String formatted as RecordId-UserId ; UserId has to follow RecordId record 

        for(Estimation_Summary__c summaryRec:lstEstimationSummary){
            String recordUserId;

            recordUserId = summaryRec.Id+'-'+summaryRec.CreatedById;
            setRecordUserIds.add(recordUserId);
            
            for(Estimator_Collaborator__c collab:summaryRec.Estimator_Collaborators__r){
                //Share the estimation Summary record with each collaborator
                Estimation_Summary__Share summaryShare = new Estimation_Summary__Share(RowCause = 'Manual');
                summaryShare.ParentId = summaryRec.Id;
                summaryShare.UserOrGroupId = collab.Dev_Community_User__c;
                summaryShare.AccessLevel = collab.Access__c;
                lstEstimationSummaryShareInsert.add(summaryShare);

                recordUserId = summaryRec.Id+'-'+collab.Dev_Community_User__c;
                setRecordUserIds.add(recordUserId);

                for(Estimation_Output__c outputRec:summaryRec.Estimation_Outputs__r){
                    //Share the estimation outputs associated with estimation summary with each of the collaborator
                    Estimation_Output__Share outputShare = new Estimation_Output__Share(RowCause = 'Manual',AccessLevel = 'Read');
                    outputShare.ParentId = outputRec.Id;
                    outputShare.UserOrGroupId = collab.Dev_Community_User__c;
                    lstEstimationOutputShareInsert.add(outputShare);

                    recordUserId = outputRec.Id+'-'+collab.Dev_Community_User__c;
                    setRecordUserIds.add(recordUserId);

                    recordUserId = outputRec.Id+'-'+summaryRec.CreatedById;
                    setRecordUserIds.add(recordUserId);
                }
            }
        }

        if(!lstEstimationSummaryShareInsert.isEmpty()){
            try{
                Database.SaveResult[] lstSaveResult = Database.insert(lstEstimationSummaryShareInsert, false);
                for(Integer i = 0; i<lstSaveResult.size() ;i++){
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if(!saveRes.isSuccess()){
                        GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler - Error Sharing Estimation Summary Record with : '+lstEstimationSummaryShareInsert[i].UserOrGroupId, saveRes.getErrors()[0].getMessage(), lstEstimationSummaryShareInsert[i].ParentId);
                    }
                }
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler', e.getMessage(),'Exception in ShareEstimationSummary: ');
            }
        }

        if(!lstEstimationOutputShareInsert.isEmpty()){
            try{
                Database.SaveResult[] lstSaveResult = Database.insert(lstEstimationOutputShareInsert, false);
                for(Integer i = 0; i<lstSaveResult.size() ;i++){
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if(!saveRes.isSuccess()){
                        GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler - Error Sharing Estimation Output Record with: '+lstEstimationOutputShareInsert[i].UserOrGroupId, saveRes.getErrors()[0].getMessage(), lstEstimationOutputShareInsert[i].ParentId);
                    }
                }
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler',e.getMessage(),'Exception in ShareEstimationSummary: ');
            }
        }

        if(!setRecordUserIds.isEmpty()){
            followRecords(setRecordUserIds);
        }
    }

    /*Method Name : RevokeEstimatorAccess
    * @param mapNew - setEstimationSummaryId - Set of Estimation Summary Id, setEstimatorCollabId - Set of Collabs to revoke record access,setCommunityUserToRevokeId - set community User Ids
    * @return return-void
    * @throws exception - NA
    * @description - revoke the access to estimation summary and estimation output records for collaborators in setEstimatorCollabId
    */
    public static void RevokeEstimatorAccess(Set<Id> setEstimationSummaryId,Set<Id> setEstimatorCollabId,Set<Id> setCommunityUserToRevokeId){
        List<Estimation_Summary__c> lstEstimationSummary = [SELECT Id,(SELECT Id,Dev_Community_User__c FROM Estimator_Collaborators__r WHERE Id IN :setEstimatorCollabId),(SELECT Id FROM Estimation_Outputs__r) FROM Estimation_Summary__c WHERE Id IN :setEstimationSummaryId];
        List<Estimation_Summary__Share> lstEstimationSummaryShare = [SELECT Id,ParentId,UserOrGroupId FROM Estimation_Summary__Share WHERE UserOrGroupId IN :setCommunityUserToRevokeId AND ParentId IN :setEstimationSummaryId];
        List<Estimation_Output__Share> lstEstimationOutputShare = [SELECT Id,ParentId,UserOrGroupId FROM Estimation_Output__Share WHERE UserOrGroupId IN :setCommunityUserToRevokeId AND Parent.Estimation_Summary__c IN :setEstimationSummaryId];
        Map<String,Estimation_Summary__Share> mapSummaryUserIdToRevoke = new Map<String,Estimation_Summary__Share>();
        Map<String,Estimation_Output__Share> mapOutputUserIdToRevoke = new Map<String,Estimation_Output__Share>();
        List<Estimation_Summary__Share> lstSummaryShareToDelete = new List<Estimation_Summary__Share>();
        List<Estimation_Output__Share> lstOutputShareToDelete = new List<Estimation_Output__Share>();
        Set<String> setRecordUserIds = new Set<String>(); //Set of String formatted as RecordId-UserId ; UserId has to unfollow RecordId record 

        for(Estimation_Summary__Share summaryShare:lstEstimationSummaryShare){
            mapSummaryUserIdToRevoke.put(String.valueOf(summaryShare.ParentId)+String.valueOf(summaryShare.UserOrGroupId),summaryShare);
        }

        for(Estimation_Output__Share outputShare:lstEstimationOutputShare){
            mapOutputUserIdToRevoke.put(String.valueOf(outputShare.ParentId)+String.valueOf(outputShare.UserOrGroupId),outputShare);
        }

        for(Estimation_Summary__c summaryRec:lstEstimationSummary){

            for(Estimator_Collaborator__c collab:summaryRec.Estimator_Collaborators__r){
                String recordUserId;

                String summaryShareId = String.valueOf(summaryRec.Id)+String.valueOf(collab.Dev_Community_User__c);
                lstSummaryShareToDelete.add(mapSummaryUserIdToRevoke.get(summaryShareId));

                recordUserId = summaryRec.Id+'-'+collab.Dev_Community_User__c;
                setRecordUserIds.add(recordUserId);

                for(Estimation_Output__c outputRec:summaryRec.Estimation_Outputs__r){
                    String outputShareId = String.valueOf(outputRec.Id)+String.valueOf(collab.Dev_Community_User__c);
                    lstOutputShareToDelete.add(mapOutputUserIdToRevoke.get(outputShareId));

                    recordUserId = outputRec.Id+'-'+collab.Dev_Community_User__c;
                    setRecordUserIds.add(recordUserId);
                }
            }
        }

        if(!lstSummaryShareToDelete.isEmpty()){
            try{
                delete lstSummaryShareToDelete;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler', e.getMessage(),'Exception in RevokeEstimatorAccess: deleting Estimation_Summary__Share');
            }
        }

        if(!lstOutputShareToDelete.isEmpty()){
            try{
                delete lstOutputShareToDelete;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler', e.getMessage(),'Exception in RevokeEstimatorAccess: deleting Estimation_Output__Share');
            }
        }

        if(!setRecordUserIds.isEmpty()){
            unfollowRecords(setRecordUserIds);
        }        
    }

    /*Method Name : followRecords
    * @param mapNew - setRecordUserIds: List of String formatted as RecordId-UserId ; UserId has to follow RecordId record
    * @return return-void
    * @throws exception - NA
    * @description - follow the estimation summary and estimation output records
    */
    @future
    public static void followRecords(Set<String> setRecordUserIds){
        List<EntitySubscription> lstEntitySubscriptionToInsert = new List<EntitySubscription>();
        Set<Id> setUserId = new Set<Id>();
        Set<Id> setRecordId = new Set<Id>();
        
        for(String recordUserId:setRecordUserIds){
            List<String> recordIds = recordUserId.split('-');
            setRecordId.add(recordIds[0]);
            setUserId.add(recordIds[1]);
        }
        
        //Remove the list the records that are already being followed by the user
        List<EntitySubscription> lstEntitySubscription = [SELECT Id,ParentId,SubscriberId FROM EntitySubscription WHERE parentId IN :setRecordId];
        for(EntitySubscription subscribe: lstEntitySubscription){
            String recordUserId = subscribe.ParentId+'-'+subscribe.SubscriberId;
            if(setRecordUserIds.contains(recordUserId)){
                setRecordUserIds.remove(recordUserId);
            }
        }

        if(!setRecordUserIds.isEmpty()){
            Map<Id,User> mapUserInfo = new Map<Id,User>([SELECT Id,UserType FROM User WHERE Id IN :setUserId]);

            for(String recordUserId:setRecordUserIds){
                List<String> recordIds = recordUserId.split('-');
                EntitySubscription subscribe = new EntitySubscription();
                subscribe.ParentId = recordIds[0];
                subscribe.SubscriberId = recordIds[1];
                if(mapUserInfo.get(recordIds[1]).UserType != 'Standard'){
                    subscribe.NetworkId = COMMUNITY_ID;
                }
                lstEntitySubscriptionToInsert.add(subscribe);
            }

            try{
                Database.SaveResult[] lstSaveResult = Database.insert(lstEntitySubscriptionToInsert, false);
                for(Integer i = 0; i<lstSaveResult.size() ;i++){
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if(!saveRes.isSuccess()){
                        GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler - Error Following Record for User: '+lstEntitySubscriptionToInsert[i].SubscriberId, saveRes.getErrors()[0].getMessage(), lstEntitySubscriptionToInsert[i].ParentId);
                    }
                }
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler',e.getMessage(),'Exception in followRecords: ');
            }
        }       
    }

    /*Method Name : unfollowRecords
    * @param mapNew - setRecordUserIds: List of String formatted as RecordId-UserId ; UserId has to Unfollow RecordId record
    * @return return-void
    * @throws exception - NA
    * @description - unfollow the estimation summary and estimation output records
    */
    @future
    public static void unfollowRecords(Set<String> setRecordUserIds){
        List<EntitySubscription> lstEntitySubscriptionToDelete = new List<EntitySubscription>();
        Set<Id> setRecordId = new Set<Id>();
        
        for(String recordUserId:setRecordUserIds){
            List<String> recordIds = recordUserId.split('-');
            setRecordId.add(recordIds[0]);
        }

        List<EntitySubscription> lstEntitySubscription = [SELECT Id,ParentId,SubscriberId FROM EntitySubscription WHERE parentId IN :setRecordId];

        for(EntitySubscription unsubscribe: lstEntitySubscription){
            String recordUserId = unsubscribe.ParentId+'-'+unsubscribe.SubscriberId;
            if(setRecordUserIds.contains(recordUserId)){
                lstEntitySubscriptionToDelete.add(unsubscribe);
            }
        }

        try{
            Delete lstEntitySubscriptionToDelete;
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('EstimatorCollaboratorTriggerHandler',e.getMessage(),'Exception in unfollowRecords: ');
        }        
    }
}