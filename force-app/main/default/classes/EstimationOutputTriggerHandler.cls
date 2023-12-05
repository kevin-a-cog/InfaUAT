/*
Class:  EstimationOutputTriggerHandler
@Author: Chandana Gowda
@Created Date: 15 FEB 2022
@Description: Trigger Handler for Estimator Output events
@Jira: IPUE-219
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description
*************************************************************************************************************************************************************
*/

public with sharing class EstimationOutputTriggerHandler {

    public static globalApexManager GAM = new globalApexManager();

    /*Method Name : handleAfterInsert
    * @param mapNew - newMap: From Trigger
    * @return return-void
    * @throws exception - NA
    * @description - called from After Insert Trigger on Estimation_Output__c
    */  
    public static void handleAfterInsert(Map<Id,Estimation_Output__c> newMap){
        Set<Id> setEstimationSummaryId = new Set<Id>();
        Set<Id> setEstimationOutputId = new Set<Id>();
        for(Estimation_Output__c outputRec:newMap.values()){
            /*If the Estimation Ouput records are created dynamically after the Estimator is shared
            * Share the Output records with the Active collaborators */
            setEstimationSummaryId.add(outputRec.Estimation_Summary__c);
            setEstimationOutputId.add(outputRec.Id);
        }

        if(!setEstimationOutputId.isEmpty()){
            shareEstimationOutput(setEstimationSummaryId,setEstimationOutputId);
        }
    }

    /*Method Name : shareEstimationOutput
    * @param mapNew - setEstimationSummaryId - Set of Estimation Summary Id, setEstimationOutputId - Set of Estimation Output to share 
    * @return return-void
    * @throws exception - NA
    * @description - Manually share the estimation output records setEstimationOutputId with the Active collaborators in setEstimatorCollabId
    */
    public static void shareEstimationOutput(Set<Id> setEstimationSummaryId,Set<Id> setEstimationOutputId){
        List<Estimation_Summary__c> lstEstimationSummary = [SELECT Id,CreatedById,(SELECT Id,Dev_Community_User__c,Access__c FROM Estimator_Collaborators__r WHERE Active__c = true AND Dev_Community_User__c != null),(SELECT Id FROM Estimation_Outputs__r WHERE Id IN :setEstimationOutputId) FROM Estimation_Summary__c WHERE Id IN :setEstimationSummaryId];
        List<Estimation_Output__Share> lstEstimationOutputShareInsert = new List<Estimation_Output__Share>();
        Set<String> setRecordUserIds = new Set<String>(); //Set of String formatted as RecordId-UserId ; UserId has to follow RecordId record 

        for(Estimation_Summary__c summaryRec:lstEstimationSummary){
            String recordUserId;
            if(!summaryRec.Estimator_Collaborators__r.isEmpty()){
                recordUserId = summaryRec.Id+'-'+summaryRec.CreatedById;
                setRecordUserIds.add(recordUserId);

                for(Estimator_Collaborator__c collab:summaryRec.Estimator_Collaborators__r){
                    for(Estimation_Output__c outputRec:summaryRec.Estimation_Outputs__r){
                        //Share the estimation outputs associated with estimation summary with each of the collaborator
                        Estimation_Output__Share outputShare = new Estimation_Output__Share(RowCause = 'Manual',AccessLevel = 'Read');
                        outputShare.ParentId = outputRec.Id;
                        outputShare.UserOrGroupId = collab.Dev_Community_User__c;
                        lstEstimationOutputShareInsert.add(outputShare);

                        recordUserId = outputRec.Id+'-'+collab.Dev_Community_User__c;
                        setRecordUserIds.add(recordUserId);
                    }
                }
            }
        }

        if(!lstEstimationOutputShareInsert.isEmpty()){
            try{
                Database.SaveResult[] lstSaveResult = Database.insert(lstEstimationOutputShareInsert, false);
                for(Integer i = 0; i<lstSaveResult.size() ;i++){
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if(!saveRes.isSuccess()){
                        GAM.CreateExceptionRecords('EstimationOutputTriggerHandler - Error Sharing Estimation Output Record with: '+lstEstimationOutputShareInsert[i].UserOrGroupId, saveRes.getErrors()[0].getMessage(), lstEstimationOutputShareInsert[i].ParentId);
                    }
                }
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimationOutputTriggerHandler',e.getMessage(),'Exception in shareEstimationOutput: ');
            }
        }

        if(!setRecordUserIds.isEmpty()){
            EstimatorCollaboratorTriggerHandler.followRecords(setRecordUserIds);
        }        
    }
}