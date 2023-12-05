/*
Class:              KBApprovalBatch
@Author:            Venky K
@Created Date:      18-Sep-2020
@Description:       Created for Project Utopia
This class works as below:
 - Queries all KB Articles in custom metadata
 - Triggers approval process accordingly.
 - Changes assigne when actors has to be assigned.

Change History.
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                              Tag
*********************************************************************************************************************************************
  
*/

global class KBApprovalBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful{


private set<Id> kbids = new set<Id>();



global KBApprovalBatch(Set<id> kavids) {
        kbids = kavids;        
        system.debug(kbids);
    	
}



global Database.QueryLocator start(Database.BatchableContext BC) {
    
    if(kbids.size() != 0) {
        return Database.getQueryLocator([SELECT Name,Approval_process_name__c,SubmitterId__c,ActorId__c,Setactor__c  FROM KB_Approval_Inflight__c where name in :kbids]) ;
    } else {
        return null;
    }
     
        
 }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{

                        
            for(KB_Approval_Inflight__c kav: (List<KB_Approval_Inflight__c>)scope){
                Id idval = Id.valueof(kav.Name);
            	KnowledgeTriggerHelper.submitForApproval(idval,kav.Approval_process_name__c,'submitting for approval',kav.SubmitterId__c);
                if(kav.Setactor__c){
                    for(ProcessInstance pi : [SELECT Id, ProcessDefinitionId, TargetObjectId, LastActorId FROM ProcessInstance where TargetObjectId = :idval]){
                        ProcessInstanceWorkItem piw = [SELECT Id, ActorId FROM ProcessInstanceWorkItem where ProcessInstanceId = :pi.Id];
                        piw.ActorId = kav.ActorId__c;
                        update piw;
                    }
                }
            }
			
            
    }catch(Exception e){
        system.debug('Excpetion occured in Batch job'+e.getMessage()+' '+e.getLineNumber());
    }
    }
    
    
    
     global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id,Status,JobType,NumberOfErrors,JobItemsProcessed,TotalJobItems,CompletedDate,ExtendedStatus FROM AsyncApexJob WHERE Id =:bc.getJobId()];          
    
        
         //List<String> toAddresses = new List<String>{'vkotapati@informatica.com','mptail@informatica.com','pbalaji@informatica.com','srajalingam@informatica.com'};    
         List<String> toAddresses = new List<String>{'vkotapati@informatica.com'};
         
        
        //toAddresses.add('vkotapati@informatica.com');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        //mail.setTargetObjectId(u.Id);
        mail.setSubject('Batch class for publishing articles' + a.Status);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody
        ('The batch Apex job completed on  ' + a.CompletedDate + ',\n\n' +
        'Job Status : ' + a.Status + '\n'+
        'Total Job Items processed : ' + a.TotalJobItems + '\n'+
        'Number of Job Items processed : ' + a.JobItemsProcessed + '\n' +
        'Number of Failures : '+ a.NumberOfErrors);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
    
    
    
    global void execute(SchedulableContext SC) {
        Set<id> kbids = new Set<Id>();
        KBApprovalBatch edl = new KBApprovalBatch(kbids);
        ID batchprocessid = Database.executeBatch(edl,10);
        }
    }