/*
Change History
*******************************************************************************************************************
ModifiedBy          Date        Jira        Description                                                         Tag
Narpavi Prabu      11/08/2022   AR-2890     Update the approval process when it is rejectd from custom button    T01       
Narpavi Prabu      02/22/2022   AR-3114     Update the status from 'Rejected'	to 'Close without Engagement'			 T02								
Chaitanya T        08/18/2023   AR-3327 		making approval comments mandatory during rejection                  T03
********************************************************************************************************************
*/

public without sharing class CstRejectEngagementController {
    @AuraEnabled
    public static void rejectEngagementRecord(string engagementId,String closingNotes){
        boolean isLocked = true; 
        Engagement__c objEng = [Select Id,Status__c,Engaged_CSM__c,Plan__c,ownerId From Engagement__c WHERE Id = : engagementId];
        if(Approval.isLocked(objEng.id)){
            Approval.UnlockResult rec = Approval.unlock(objEng.id);   
                  if(rec.isSuccess()) {
                    isLocked  = false;
                  } 
           else{
              for(Database.Error err : rec.getErrors()) {
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('fields that affected this error: ' + err.getFields());
              } 
           }
    

        }else{
            isLocked  = false;
        }
        
        
        if(isLocked == false){
         //<T02>
            objEng.Status__c = 'Close without Engagement';
            objEng.Closing_Notes__c = closingNotes;//<T03>
         //</T02>     
            update objEng;
        }   
        //string engid=objEng.id;
        rejectapprovalrecord(objEng.id );//<T01>
       
      }

      //<T01>
      //Method to update the approval process in the engagement record when rejected from custom button
      public static void rejectapprovalrecord(string engagementId )
      {
        
        ProcessInstanceWorkitem[] Pval = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :engagementId AND ProcessInstance.Status = 'Pending']; 
        System.debug(Pval.Size());
        if(Pval.size() > 0)
        {     
            Approval.ProcessWorkItemRequest req2= new Approval.ProcessWorkItemRequest();
            req2.setComments('Reject request.');
            req2.setAction('Reject');
            req2.setWorkItemId(Pval[0].Id);
            Approval.ProcessResult result = Approval.process(req2);
            system.debug('result'+result);
        }
      }
      //<T01>
       
}