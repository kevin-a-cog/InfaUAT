/*
Change History
*******************************************************************************************************************
ModifiedBy          Date        Jira        Description                                                         Tag
Narpavi Prabu      11/08/2022   AR-2890     Update the approval process when it is rejectd from custom button    T01       
Harshita J         06/09/2022   AR-2896     Update CST with CSA       T02
Chaitanya T        08/30/2023   AR-3365     New Engagement MFA        T03                             
********************************************************************************************************************
*/
public without sharing class cstAcceptEngagementController {
    
  @AuraEnabled
  public static string acceptEngagementRecord(string engagementId ){
      /*
          1. Update the status to Accepted.
          2. Hide Reject button from the record as well as from Chevron.
          3. Owner should be populated with the name who accepted.
          4. Add the CST Owner to the plan team with the role of CST.
          5. Once staus is moved to complete remove CST from plan team.
      */
      
      // dev notes check with deva for genric method 
      string msg = '';
      Engagement__c objEng = [Select Id,Status__c,Engaged_CSM__c,Plan__c,ownerId,RecType__c From Engagement__c WHERE Id = : engagementId];
      boolean isLocked = true; 
      
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
          objEng.Status__c = 'Accepted';
          objEng.OwnerId = userinfo.getUserId(); 
          update objEng;
          approveapprovalrecord(objEng.id);
          
          boolean alreadyInPlanTeam = false;
          if(objEng.RecType__c == 'CSA'){
            if(objEng.Plan__c != null){
              for(Plan_Team__c pt : [SELECT Id,Plan__c,Role__c,User__c FROM Plan_Team__c 
                                            WHERE Plan__c =: objEng.Plan__c 
                                            AND Role__c = 'CSA' AND User__c =: userinfo.getUserId() LIMIT 1]){//T02  
                alreadyInPlanTeam = true;
              }                                                     
                              
              if(!alreadyInPlanTeam){
                Plan_Team__c oPlanTeam = new Plan_Team__c();
                oPlanTeam.Plan__c = objEng.Plan__c;
                oPlanTeam.Role__c = 'CSA' ;//T02  
                oPlanTeam.User__c = userinfo.getUserId();
                INSERT oPlanTeam;
              } 
            }
          }else if(objEng.RecType__c == 'MFA'){//<T03>
            if(objEng.Plan__c != null){
              for(Plan_Team__c pt : [SELECT Id,Plan__c,Role__c,User__c FROM Plan_Team__c 
                                            WHERE Plan__c =: objEng.Plan__c 
                                            AND Role__c = 'MFA' AND User__c =: userinfo.getUserId() LIMIT 1]){ 
                alreadyInPlanTeam = true;
              }                                                     
                              
              if(!alreadyInPlanTeam){
                Plan_Team__c oPlanTeam = new Plan_Team__c();
                oPlanTeam.Plan__c = objEng.Plan__c;
                oPlanTeam.Role__c = 'MFA' ;
                oPlanTeam.User__c = userinfo.getUserId();
                INSERT oPlanTeam;
              } 
            }
          }//<T03>
          
      }
      return msg;        
  }

  //<T01>
    //Method to update the approval process in the engagement record when rejected from custom button
    public static void approveapprovalrecord(string engagementId )
    {
      
      ProcessInstanceWorkitem[] Pval = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :engagementId AND ProcessInstance.Status = 'Pending']; 
      System.debug(Pval.Size());
      if(Pval.size() > 0)
      {     
          Approval.ProcessWorkItemRequest req2= new Approval.ProcessWorkItemRequest();
          req2.setComments('Approve request.');
          req2.setAction('Approve');
          req2.setWorkItemId(Pval[0].Id);
          Approval.ProcessResult result = Approval.process(req2);
          system.debug('result'+result);
      }
    }
    //<T01>
}