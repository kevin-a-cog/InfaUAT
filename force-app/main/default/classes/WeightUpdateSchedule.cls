/*
 * Name         :   WeightUpdateSchedule
 * Author       :   - Unknown
 * Created Date :   - Unknown
 * Description  :    class for WeightUpdateSchedule.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
Sandeep Duggi             10/22/2022     I2RT-7260                                                                                      T01

 */
global class WeightUpdateSchedule implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime currentDT = System.now();
        datetime timeCondition = currentDT.addHours(1);
        datetime timeConditionForOperationCases = currentDT.addHours(2);
        if(Label.WeightageLoadAllOpen == 'false'){
            // T01 modified query to collect operational case records
        	return Database.getQueryLocator([Select Id, Case__r.AccountId, Case__r.Support_Account__c, Business__c, SameTimeZone__c from Case_Weightage__c where (Case__r.RecordType.Name = 'Technical' OR (Case__r.RecordType.Name = 'Operations' AND Case__r.Service_Appointment_AAE__r.SchedStartTime   <:timeConditionForOperationCases ) )
                                             																												AND (Case__r.Status NOT IN ('Closed','Resolved')) 
                                                                                                                                                            AND (  (SameTimeZone__c = True AND Business__c = 'OFF') 
                                                                                                                                                                    OR (SameTimeZone__c = False AND Business__c = 'ON') 
                                                                                                                                                                    OR ( Case__r.eOGR_Target_Date__c   <:timeCondition OR  Case__r.OGR_Target_Date__c   <:timeCondition)
                                                                                                                                                                ) ]);
        }else {
            return Database.getQueryLocator([Select Id, Case__r.AccountId, Case__r.Support_Account__c, Business__c, SameTimeZone__c from Case_Weightage__c where Case__r.Status NOT IN ('Closed','Resolved')]);
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Id> caseIdsForWeightRecalculation = new List<Id>();
        List<Id> projectIdsForWeightRecalculation = new List<Id>();
        List<Id> accountIdsForWeightRecalculation = new List<Id>();
        
        List<Case_Weightage__c> lCases = new List<Case_Weightage__c>();
        lCases = (List<Case_Weightage__c>) scope;

        if(lCases.size() > 0) {
            for(Case_Weightage__c cs : lCases){
                caseIdsForWeightRecalculation.add(cs.Case__c);
                projectIdsForWeightRecalculation.add(cs.Case__r.Support_Account__c);
                accountIdsForWeightRecalculation.add(cs.Case__r.AccountId);         
            }
            if(!caseIdsForWeightRecalculation.IsEmpty()){
                CaseWeightageHelper.updateWeightsNonFuture(caseIdsForWeightRecalculation, projectIdsForWeightRecalculation, accountIdsForWeightRecalculation, 'Case');
            }
        }
    }

    //Batch Finish method for after exeutetion of batch work
    global void finish(Database.BatchableContext BC){ 

    }
    
    global void execute(SchedulableContext SC) {
        WeightUpdateSchedule pps = new WeightUpdateSchedule();
        ID batchprocessid = Database.executeBatch(pps,10);
    }
}