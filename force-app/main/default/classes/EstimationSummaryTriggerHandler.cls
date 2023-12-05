/*
Trigger:        EstimationSummaryTrigger
@Author:        Colton Kloppel
@Created Date:  December 1319 2021
@Description:   To handle Primary logic on the Estimation Summary
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.                      Description                                                 Tag

Colton Kloppel    Dec 13 2021  IPUE-139                        Initial Create  
Anusha Akella     Jan 30th 2021     IPUE-213                   Removing Validation and logic is updated to have only one primary Estimation Summary record.           
Anusha Akella     Jan 31st 2021     IPUE-161                   Trigger to update related records to cancel Status <T02>
Anusha Akella     Feb 6th  2021     IPUE- 161                  Trigger to generate Sdoc based on Custom Meta data values <T03>
Anusha Akella     Feb 9th  2021     IPUE - 161                 Update Esmation Summary Record Access IPUE 161 <T04>
Chandana Gowda    25 Apr 2022       SALESRT-13820              Updated logic to Unmarking/Marking Primary, Added logic sycing primary  <T05>
                                                               estimator to Opty      
Puneet Lohia           3/3/2023        SALESRT-14838   Validate IPUs between Quote and IPU Estimator   <SALESRT-14838>                                                 
nibansal          07/03/2023     SALESRT-14945                 callNotificationService framework and also add the logic to insert Opportunity IPU Services record
nibansal          04/07/2023     SALESRT-15406                  Commented recalculateWarning and change addOppIPUServices
nibansal          06/12/2023        SALESRT-15257               IPU Type attribute
KAPIL TILWANI	  27/06/2023	 SALESRT-16718					Update Account with Opportunity Account.
********************************************************************************************************************************************
*/ 
public with sharing class EstimationSummaryTriggerHandler {
    public static List<Estimation_Summary__c> allEsList;
    public static globalApexManager GAM = new globalApexManager();
    
    public static void beforeInsert(List<Estimation_Summary__c> newLst){
        updateAccountFromOpportunity(newLst);
        handlePrimaryCheckbox(null,newLst);
        toPopulateIPUType(newLst); // SALESRT-15257
    }

    public static void afterInsert(Map<Id,Estimation_Summary__c> newMap){
        updatePrimaryEstimateOnOpty(null, newMap); //<T05>
        addOppIPUServices(newMap.values(), null);
        callNotificationService(newMap.values(), null);
        //recalculateWarning(newMap.values(), null);
    }
    
    public static void beforeUpdate(Map<Id,Estimation_Summary__c> oldMap,Map<Id,Estimation_Summary__c> newMap){
        validateOpportunityChangeOnEstimate(oldMap,newMap);
        handlePrimaryCheckbox(oldMap,newMap.values());
    }
    
    //<T01>
    public static void afterUpdate(List<Estimation_Summary__c> newList, Map<Id,Estimation_Summary__c> oldMap,Map<Id,Estimation_Summary__c> newMap){
        getRelatedEsRecOptyMap(oldMap, newMap);
        generateSDocAttachment(newList, oldMap);
        submitEstimationSummarySharing(oldMap, newMap);        
        updatePrimaryEstimateOnOpty(oldMap, newMap);//<T05>
        addOppIPUServices(newList, oldMap);
        callNotificationService(newList, oldMap);
        recalculateWarning(newList,oldMap);
    }
    //-------------------------------------------------------------------------------------------------------------------------<T05> - STARTS
    private static Set<Id> getOpportunityToUpdate(Map<Id,Estimation_Summary__c> oldMap,List<Estimation_Summary__c> newLst){
        
        Set<Id> setOpportunityUpdate = new Set<Id>();        
        for(Estimation_Summary__c estimator:newLst){
            if(oldMap == null || estimator.Opportunity__c != oldMap.get(estimator.Id).Opportunity__c || estimator.Primary__c != oldMap.get(estimator.Id).Primary__c){
                if(estimator.Opportunity__c != null){
                    setOpportunityUpdate.add(estimator.Opportunity__c);
                }
                if(oldMap != null && oldMap.get(estimator.Id).Opportunity__c != null){
                    setOpportunityUpdate.add(oldMap.get(estimator.Id).Opportunity__c);
                }
            }
        }        
        return setOpportunityUpdate;
    }
    /*Method Name : updatePrimaryEstimateOnOpty
    * @param mapNew - oldMap: From Trigger, newMap: From Trigger
    * @return return-void
    * @throws exception - NA
    * @description - called from after Insert and after update of Estimation Summary, checks if the Opportunity/Primary checkbox is updated on the Estimation Summmary
    */ 
    private static void updatePrimaryEstimateOnOpty(Map<Id,Estimation_Summary__c> oldMap,Map<Id,Estimation_Summary__c> newMap){
        
        Set<Id> setOpportunityUpdate = getOpportunityToUpdate(oldMap,newMap.values());

        if(!setOpportunityUpdate.isEmpty()){
            updatePrimaryEstimateOnOptyFuture(setOpportunityUpdate);
        }
    }

    /*Method Name : updatePrimaryEstimateOnOptyFuture
    * @param mapNew - setOpportunityUpdate: Opportunity Ids WHERE the primary or the opportunityId is updated on Estimation Summary
    * @return return-void
    * @throws exception - NA
    * @description - called from updatePrimaryEstimateOnOpty. on after Insert and after update of Estimation Summary
    */ 
    @future
    private static void updatePrimaryEstimateOnOptyFuture(Set<Id> setOpportunityUpdate){
        List<Opportunity> lstOpportunity = [SELECT Id,Primary_IPU_Estimator__c,(SELECT Id FROM Estimation_Summaries__r WHERE Primary__c = true) FROM Opportunity WHERE Id IN:setOpportunityUpdate];
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        for(Opportunity oppRec:lstOpportunity){
            Estimation_Summary__c primaryEstimate = new Estimation_Summary__c();

            if(!oppRec.Estimation_Summaries__r.isEmpty()){
                primaryEstimate = oppRec.Estimation_Summaries__r[0];
            }

            if(primaryEstimate == null){
                oppRec.Primary_IPU_Estimator__c = null;
            }

            else if(oppRec.Primary_IPU_Estimator__c == null || oppRec.Primary_IPU_Estimator__c != primaryEstimate.Id){
                oppRec.Primary_IPU_Estimator__c = primaryEstimate.Id;
            }

            lstOpportunityToUpdate.add(oppRec);
        }

        if(!lstOpportunityToUpdate.isEmpty()){
            try{
                Database.SaveResult[] lstSaveResult = Database.update(lstOpportunityToUpdate, false);
                for(Integer i = 0; i<lstSaveResult.size() ;i++){
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if(!saveRes.isSuccess()){
                        GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler - Error updating Primary Estimate on Opty : '+lstOpportunityToUpdate[i].Id, saveRes.getErrors()[0].getMessage(), lstOpportunityToUpdate[i].Primary_IPU_Estimator__c);
                    }
                }
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler', e.getMessage(),'Exception in updatePrimaryEstimateOnOptyFuture: ');
            }
        }       
    }

    /*Method Name : handlePrimaryCheckbox
    * @param mapNew - oldMap: From Trigger, newMap: From Trigger
    * @return return-void
    * @throws exception - NA
    * @description - called on Before Insert and before update of Estimation Summary. Checks/Unchecks Primary on Estimation Summary
    */     
    private static void handlePrimaryCheckbox(Map<Id,Estimation_Summary__c> oldMap,List<Estimation_Summary__c> newLst){

        Set<Id> setOpportunityUpdate = getOpportunityToUpdate(oldMap,newLst);
    
        if(setOpportunityUpdate != null){
    
            Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([SELECT Id,Primary_IPU_Estimator__c,(SELECT Id FROM Estimation_Summaries__r WHERE Primary__c = true) FROM Opportunity WHERE Id IN:setOpportunityUpdate]);
            List<Estimation_Summary__c> lstUnprimaryestimator = new List<Estimation_Summary__c>();
            for (Estimation_Summary__c summary : newLst) {
                if(mapOpportunity.get(summary.Opportunity__c)!= null){
    
                    if(mapOpportunity.get(summary.Opportunity__c).Estimation_Summaries__r.isEmpty()){
                        summary.Primary__c = true;
                    }else if(summary.Primary__c){
                        Estimation_Summary__c unPrimary = new Estimation_Summary__c();
                        unPrimary.Id = mapOpportunity.get(summary.Opportunity__c).Estimation_Summaries__r[0].Id;
                        unPrimary.Primary__c = false;
                        lstUnprimaryestimator.add(unPrimary);
    
                    }
                }
            }
    
            if(!lstUnprimaryestimator.isEmpty()){
                try{
                    Database.SaveResult[] lstSaveResult = Database.update(lstUnprimaryestimator, false);
                    for(Integer i = 0; i<lstSaveResult.size() ;i++){
                        Database.SaveResult saveRes = lstSaveResult[i];
                        if(!saveRes.isSuccess()){
                            GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler - Error Checking/Unchecking on estimator : '+lstUnprimaryestimator[i].Id, saveRes.getErrors()[0].getMessage(), lstUnprimaryestimator[i].Primary__c + '');
                        }
                    }
                }
                catch(Exception e){
                    GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler', e.getMessage(),'Exception in handlePrimaryCheckbox: ');
                }                
            }
        }
    }
    //-------------------------------------------------------------------------------------------------------------------<T05/> - ENDS

    //Jira IPUE 161 <T02> 
    private static void getRelatedEsRecOptyMap(Map<Id,Estimation_Summary__c> oldMap,Map<Id,Estimation_Summary__c> newMap){
        set<Id> esOptyId = new set<Id>();
        
        for (Estimation_Summary__c es : newMap.values()) {
            if (es.status__c != oldMap.get(es.Id).status__c && es.status__c == 'Finalized Agreement') {
                esOptyId.add(es.Opportunity__c);
            }
        }
        if (esOptyId.isEmpty()) return;
        
        List<Estimation_Summary__c> esList = [SELECT Id, Status__c FROM Estimation_Summary__c WHERE opportunity__c IN :esOptyId and Id NOT IN :newMap.keySet()];
        
        if (esList.isEmpty()) return;
        
        List<Estimation_Summary__c> esListToUpdate = new List<Estimation_Summary__c>();
        for (Estimation_Summary__c es: esList) {
            es.Status__c = 'cancelled';
            esListToUpdate.add(es);
        }
        if (esListToUpdate.isEmpty()) return;
        
        try{
            update esListToUpdate;
        } catch (Exception e) {
            GAM.CreateLogs('EstimationSummaryTrigger.getRelatedEsRecOptyMap', esListToUpdate, 'getRelatedEsRecOptyMap');
        }
    }
    
    //Jira IPUE 161 <T03>
    //Moving Process Builder logic to Trigger to for SDoc Relationship Record which uses SDoc Job this is used for Automatic Document generation.
    
    private static void generateSDocAttachment(List<Estimation_Summary__c> newList, Map<Id, Estimation_Summary__c> oldMap){
        List<SDOC__SDJob__c> sDocJobList = new List<SDOC__SDJob__c>();
        List<IPUE_Matched_Criteria__c> matchedCriteriaList = new List<IPUE_Matched_Criteria__c>();
        
        List<AutoDocument_Generation__mdt> triggerConditionMdtLst = AutoDocument_Generation__mdt.getall().values();
        
        List<Doc_TriggerCriteria__mdt> criteriaList = [SELECT MasterLabel, operator__c, value__c, field__c,Index__c,AutoDocument_Generation__r.TemplateId__c,AutoDocument_Generation__r.Trigger_Condition__c FROM Doc_TriggerCriteria__mdt WHERE AutoDocument_Generation__c IN :triggerConditionMdtLst ORDER BY MasterLabel ASC];        
        
        Map<Id, List<Doc_TriggerCriteria__mdt>> criteriaMap = new Map<Id, List<Doc_TriggerCriteria__mdt>>();
        
        for (Doc_TriggerCriteria__mdt docCriteria: criteriaList) {
            if (!criteriaMap.containsKey(docCriteria.AutoDocument_Generation__c)) {
                criteriaMap.put(docCriteria.AutoDocument_Generation__c,new List<Doc_TriggerCriteria__mdt> {docCriteria});
            } else {
                criteriaMap.get(docCriteria.AutoDocument_Generation__c).add(docCriteria);
            }
        }
        
        for (Estimation_Summary__c es : newList) {
            Map<Id,  Map<String, boolean>> criteriaBooleanMap = criteriaValues(criteriaMap, es, oldMap.get(es.Id));
            
            for (AutoDocument_Generation__mdt triggerRec: triggerConditionMdtLst) {
                if (!triggerRec.Active__c) {
                    continue;
                }
                BooleanEvaluate boolEval = new BooleanEvaluate(triggerRec.Trigger_Condition__c, criteriaBooleanMap.get(triggerRec.Id).values());
                Boolean isTrue = boolEval.evaluate(); 
                
                if (isTrue) {
                    if(Schema.sObjectType.SDOC__SDJob__c.isCreateable()){
                        SDOC__SDJob__c sdjobObject = new SDOC__SDJob__c(SDOC__Doclist__c = triggerRec.TemplateId__c, SDOC__ObjApiName__c = 'Estimation_Summary__c', SDOC__Oid__c = es.Id, SDOC__Start__c = true);
                        sdocJobList.add(sdjobObject);
                    } else {
                        IPUE_Matched_Criteria__c matchedRecordObj = new IPUE_Matched_Criteria__c(Criteria_Name__c = triggerRec.Label,
                                                                                             Estimation_Summary__c = es.Id,
                                                                                             Active__c = true,
                                                                                             Template_Id__c = triggerRec.TemplateId__c);
                        matchedCriteriaList.add(matchedRecordObj);
                    }
                }
            }
        }
        if (!sdocJobList.isEmpty()) {
            try {
                Database.SaveResult[] lstSdocSaveResult = Database.insert(sdocJobList, false);
                for (Integer i = 0; i<lstSdocSaveResult.size() ;i++) {
                    Database.SaveResult saveSdocRes = lstSdocSaveResult[i];
                    if (!saveSdocRes.isSuccess()) {
                        GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler - Error inserting Sdoc Job for  : '+matchedCriteriaList[i].Estimation_Summary__c, saveSdocRes.getErrors()[0].getMessage(), matchedCriteriaList[i].Estimation_Summary__c);
                    }
                }
            }
            catch(Exception e) {
                GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler', e.getMessage(),'Exception in ShareEstimationSummary: ');
            }
        }        
        if (!matchedCriteriaList.isEmpty()) {
            try {
                Database.SaveResult[] lstSaveResult = Database.insert(matchedCriteriaList, false);
                for (Integer i = 0; i<lstSaveResult.size() ;i++) {
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if (!saveRes.isSuccess()) {
                        GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler - Error inserting IPUE_Matched_Criteria__c for  : '+matchedCriteriaList[i].Estimation_Summary__c, saveRes.getErrors()[0].getMessage(), matchedCriteriaList[i].Estimation_Summary__c);
                    }
                }
            }
            catch(Exception e) {
                GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler', e.getMessage(),'Exception in ShareEstimationSummary: ');
            }
        }     
    }
    
    //This is generic method for evaluating ischanged in the trigger condition metadata
    private static boolean isChanged(String fieldName, String value, sObject newObj,  sObject oldObj) {
        boolean isTrue;
        
        if (value == 'true') {
            isTrue = newObj.get(fieldName) != oldObj.get(fieldName);
        } else {
            isTrue = newObj.get(fieldName) == oldObj.get(fieldName);
        } 
        return isTrue;
    }
    
    //This is generic method for evaluating equalsTo in the trigger condition metadata
    private static boolean equalsTo(String fieldName, String value, sObject obj) {
        return obj.get(fieldName) == value;
    }
    
    //This is generic method for evaluating notEqualsTo in the trigger condition metadata
    private static boolean notEqualsTo (String fieldName, String value, sObject obj) {
        return obj.get(fieldName) != value;
    }
    
    //criteriaValues method used for mapping the trigger condition record to an evaluation of each of it's child criteria to a boolean value
    private static Map<Id,  Map<String, boolean>> criteriaValues(Map<Id, List<Doc_TriggerCriteria__mdt>> criteriaMap, sObject newObj, sObject oldObj) {
        Map<Id,  Map<String, boolean>> criteriaBooleanMap = new Map<Id,  Map<String, boolean>>();
        for (Id autoId : CriteriaMap.keyset()) {
            Map<String, Boolean> crBoolMap = new Map<String, Boolean>();
            for (Doc_TriggerCriteria__mdt dct : CriteriaMap.get(autoId)) {
                if (dct.operator__c == '=') {
                    crBoolMap.put(dct.Index__c, equalsTo(dct.field__c, dct.value__c, newObj));
                } else if (dct.operator__c == '!=') {
                    crBoolMap.put(dct.Index__c, notEqualsTo(dct.field__c, dct.value__c, newObj));
                } else if (dct.operator__c == 'isChanged') {
                    crBoolMap.put(dct.Index__c, isChanged(dct.field__c, dct.value__c, newObj, oldObj));
                }
                criteriaBooleanMap.put(autoId, crBoolMap);
            }
        }
        return criteriaBooleanMap;
    }
    
    //Update Esmation Summary Record Access IPUE 161
    public static void submitEstimationSummarySharing(Map<Id,Estimation_Summary__c> oldMap,Map<Id,Estimation_Summary__c> newMap){
        Set<Id> esIds = new Set<Id>();
        for (Estimation_Summary__c es : newMap.values()) {
            if ((es.Status__c == 'Initialized Agreement' && oldMap.get(es.Id).Status__c == 'Draft') ||
                ((es.Status__c == 'Finalized Agreement' || es.status__c == 'Draft' || es.Status__c == 'Cancelled') && es.Status__c != oldMap.get(es.Id).Status__c)){
                    esIds.add(es.Id);
                }
        }
        if (esIds.isEmpty()) {
            return;
        }
        List<Estimator_Collaborator__c> escList = [SELECT Id, Dev_Community_User__c, Estimation_Summary__c,Active__c, Dev_Community_User__r.Name, Access__c 
                                                   FROM Estimator_Collaborator__c 
                                                   WHERE Estimation_Summary__c 
                                                   IN :esIds 
                                                   AND Dev_Community_User__c != Null 
                                                   AND Active__c = true];
        
        if (escList.isEmpty()) {
            return;
        }
        List<Estimator_Collaborator__c> escUpdateList = new List<Estimator_Collaborator__c>();
        for (Estimator_Collaborator__c esc : escList) {
            if (newMap.get(esc.Estimation_Summary__c).Status__c == 'Cancelled') {
                esc.Active__c = false;
                escUpdateList.add(esc);
            } 
        }
        if (!escUpdateList.isEmpty()) {
            try {
                Database.SaveResult[] lstSaveResult = Database.update(escUpdateList, false);
                for (Integer i = 0; i<lstSaveResult.size() ;i++) {
                    Database.SaveResult saveRes = lstSaveResult[i];
                    if (!saveRes.isSuccess()) {
                        GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler - Error updating the share access of this  Estimation Summary Record with : '+escUpdateList[i].Dev_Community_User__r.Name, saveRes.getErrors()[0].getMessage(), escUpdateList[i].Estimation_Summary__c);
                    }
                }
            }
            catch(Exception e) {
                GAM.CreateExceptionRecords('EstimationSummaryTriggerHandler', e.getMessage(),'Exception in ShareEstimationSummary: ');
            }
        }
    }
  
    //<SALESRT-14945> Starts here
    /**
     * @description : Added the method to insert the Opportunity IPU Services records.
     * 
     * @param : newList - List of Estimation Summaries
     * @param : oldMap - map of Estimation Summary
     * 
     * @return : void
     */
    private static void addOppIPUServices(list<Estimation_Summary__c> lstTriggerNew, map<Id, Estimation_Summary__c> oldMap) {
        
        Set<Id> estSummaryIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        
        for (Estimation_Summary__c estSummary : lstTriggerNew) {
            if((oldMap == null || oldMap.get(estSummary.Id).Primary__c != estSummary.Primary__c) && estSummary.Primary__c) {
                estSummaryIdSet.add(estSummary.Id);
                oppIdSet.add(estSummary.Opportunity__c);
            }
        }
        
        if(oldMap == null && !estSummaryIdSet.isEmpty() && estSummaryIdSet.size() > 0 && !System.isFuture() && !System.isBatch()) {
            IPUServices.deleteOppIPUServices(estSummaryIdSet, oppIdSet);
        } else if(oldMap != null && !estSummaryIdSet.isEmpty() && estSummaryIdSet.size() > 0 && !System.isFuture() && !System.isBatch()) {
            IPUServices.insertOppIPUServices(estSummaryIdSet, oppIdSet);
        }
        
    }

    
    private static void callNotificationService(list<Estimation_Summary__c> lstTriggerNew, map<Id, Estimation_Summary__c> oldMap) {
        NotificationService.notify(trigger.new, oldMap);
    }
    
    //<SALESRT-14838> Starts here
    /**
     * @description : this method recalculates the ipu warnings
     * 
     * @param : newList - List of Estimation Summaries
     * @param : oldMap - map of Estimation Summary
     * 
     * @return : void
     */
    public static void recalculateWarning(list<Estimation_Summary__c> lstTriggerNew, map<Id, Estimation_Summary__c> oldMap){

        Set<Id> oppIdSet = new Set<Id>();
        
        for(Estimation_Summary__c estimationSum : lstTriggerNew){
            
            if(((oldMap == null) || 
                (oldMap !=  null && (oldMap.get(estimationSum.Id).Primary__c != estimationSum.Primary__c || oldMap.get(estimationSum.Id).Opportunity__c != estimationSum.Opportunity__c || oldMap.get(estimationSum.Id).Total_Required_IPUs__c != estimationSum.Total_Required_IPUs__c )
                && estimationSum.Opportunity__c != null && estimationSum.Primary__c && estimationSum.Total_Required_IPUs__c != null))){
                
                oppIdSet.add(estimationSum.Opportunity__c);

                if(oldMap != null && oldMap.get(estimationSum.Id).Opportunity__c != null){
                    oppIdSet.add(oldMap.get(estimationSum.Id).Opportunity__c);
                }
            }
        }

        if(!oppIdSet.isEmpty() && !System.isFuture() && !System.isBatch()){
            InfaSalesUtility.recalculateIpuWarnings(new List<Id>(oppIdSet));
        }
    }
    //<SALESRT-14838> Ends here
   
    //SALESRT-15257 Starts Here
    /**
     * @description : this method populates IPU Type
     * 
     * @param : lstTriggerNew - List of Estimation Summaries
     * 
     * @return : void
     */
    private static void toPopulateIPUType(list<Estimation_Summary__c> lstTriggerNew) {
        
        Set<Id> formIdSet = new Set<Id>();
        map<Id, String> mapOfFormIdAndIPUType = new map<Id, String>();
        
        for (Estimation_Summary__c estSummary : lstTriggerNew) {
            if(estSummary.Form__c != null) {
                formIdSet.add(estSummary.Form__c);
            }
        }
        
        if(!formIdSet.isEmpty()) {
            for(Form__c form : [SELECT Id, IPU_Type__c FROM Form__c WHERE Id IN: formIdSet]) {
                mapOfFormIdAndIPUType.put(form.Id, form.IPU_Type__c);
            }
            
            for (Estimation_Summary__c estSummary : lstTriggerNew) {
                if(estSummary.Form__c != null && mapOfFormIdAndIPUType != null && mapOfFormIdAndIPUType.containsKey(estSummary.Form__c)) {
                    estSummary.IPU_Type__c = mapOfFormIdAndIPUType.get(estSummary.Form__c);
                }
            }
            
        }

        
    }
    //SALESRT-15257 Ends Here
    
    //SALESRT-15257 Starts Here
    /**
     * @description : this method update the Account based on Selected Opportunity
     * 
     * @param : lstTriggerNew - List of Estimation Summaries
     * 
     * @return : void
     */
	
    private static void updateAccountFromOpportunity(list<Estimation_Summary__c> lstTriggerNew){
        Set<Id> OpportunityId = new Set<Id>();
        for(Estimation_Summary__c estimate : lstTriggerNew){
            if(estimate.opportunity__c != null){
                OpportunityId.add(estimate.opportunity__c);
            }
        }
        
        if(OpportunityId.size() > 0){
            map<Id,Id> mapOfOpportunityIdToAccountId = getOpportunityWithAccountIds(OpportunityId);
            
            for(Estimation_Summary__c estimate : lstTriggerNew){
                if(mapOfOpportunityIdToAccountId.containsKey(estimate.Opportunity__c)){
                    estimate.Account__c = mapOfOpportunityIdToAccountId.get(estimate.Opportunity__c);
                }
            }
        }
    }
    
    
    private static map<Id,Id> getOpportunityWithAccountIds(Set<Id> OpportunityId){
        map<Id,Id> mapOfOpportunityIdToAccountId = new map<Id,Id>();
        for(Opportunity opp : [SELECT id,AccountId 
                               FROM Opportunity
                               WHERE Id IN:OpportunityId]){
           mapOfOpportunityIdToAccountId.put(opp.Id,opp.AccountId);                        
        }
        return mapOfOpportunityIdToAccountId;
    }
    
    private static void validateOpportunityChangeOnEstimate(Map<Id,Estimation_Summary__c> oldMap,
                                                            Map<Id,Estimation_Summary__c> newMap){
       
      	list<Estimation_Summary__c> listOfEstimates = new list<Estimation_Summary__c>();
        for(Estimation_Summary__c estimate : newMap.values()){
            if(estimate.Opportunity__c != oldMap.get(estimate.Id).Opportunity__c){
                listOfEstimates.add(estimate);
            }                                                       
        }
        
        if(listOfEstimates.size() > 0){
            updateAccountFromOpportunity(listOfEstimates);                                                        
        }
    }
    
    
}