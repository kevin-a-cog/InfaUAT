/*
Class      - InfaApprovalProcessUtil
Test Class - ApprovalRequestActionclsTest
 Description - Class to object specific logic to be called from ApprovalRequestActioncls
 ----------------
 CHANGE HISTORY
 ---------------- ---------------- -------------------------------- ---------------- -------------------------------- ----------------
 DEVELOPER NAME       JIRA/STORY                   DESCRIPTION                                                           TAG
 *************************************************************************************************************************************
 VENKATESH BALLA    SALESRT-17066      Tech debt - Apex sharing record insertion is not working for FSR user          <SALESRT-17066>
 *************************************************************************************************************************************
*/
public without sharing class InfaApprovalProcessUtil {    
    PRIVATE STATIC STRING PSM_STATUS = 'Waiting PSM Approval';
    PRIVATE STATIC STRING FSR_STATUS = 'Waiting Field Sales Approval';
    PRIVATE STATIC STRING RSD_STATUS = 'Waiting RSD Approval';
    PRIVATE STATIC STRING VP_STATUS = 'Waiting VP Approval';
    PRIVATE STATIC STRING PSM_STEPNAME = 'DealApprovalByPSM';
    PRIVATE STATIC STRING FSR_STEPNAME = 'DealApprovalByFSA';
    /**
    * This method is used to handle all the logic related to Approved Status on approvals step
    * @param triggernew - Object API Name, Object record Id
    * @return return-void
    * @throws exception - NA
    */   
    public static void onApprovalActions(String objectType, String recId){
        if(objectType == 'Lead'){
            doLeadApprovalActions(recId);
        }
    }
    /**
    * This method is used to handle all the logic related to Reassigned Status on approvals step
    * @param triggernew - Object API Name, Object record Id
    * @return return-void
    * @throws exception - NA
    */   
    public static void onReassignActions(String objectType, String recId, String newUserId){
        if(objectType == 'Lead'){
            doLeadReassignActions(recId, newUserId);
        }
    }
    
    /*PLACEHOLDER METHODS FOR RECALL AND REJECT ACTIONS*/
    /**
    * This method is used to handle all the logic related to Rejected Status on approvals step
    * @param triggernew - Object API Name, Object record Id
    * @return return-void
    * @throws exception - NA
    */   
    /*private static void onRejectActions(String objectType, String recId){
        
    }
    /**
    * This method is used to handle all the logic related to Recall Status on approvals step
    * @param triggernew - Object API Name, Object record Id
    * @return return-void
    * @throws exception - NA
    */   
    /*private static void onRecallActions(String objectType, String recId){
        
    }*/
    
    /**
    * This method is used to handle all the logic related to ReAssigned Status on Lead object
    * @param triggernew - Object record Id
    * @return return-void
    * @throws exception - NA
    */   
    private static void doLeadReassignActions(String recId, String newUserId){
        ProcessInstance instanceP = getProcessInstanceDetails(recId);
        enableSharingOnReassign((Id)recId, instanceP, (Id)newUserId);
    }
    /**
    * This method is used to handle all the logic related to Approved Status on Lead object
    * @param triggernew - Object record Id
    * @return return-void
    * @throws exception - NA
    */ 
    private static void doLeadApprovalActions(String recId){
        ProcessInstance instanceP = getProcessInstanceDetails(recId);
        updatePSAANDFSROnLead(recId, instanceP);
        verifyApproverAccesses(new List<Id> {recId});//updated to List type
    }

    /**
    * This method is used to update FSR and PSM values if the respective steps are reassigned to different users
    * @param triggernew - Object record Id, Respective approval step process instance id
    * @return return-void
    * @throws exception - NA
    */ 
    private static void updatePSAANDFSROnLead(Id leadId, ProcessInstance instanceP){
        Lead leadRec = getLeadRecList(new List<Id>{leadId})[0];
        Boolean updateRequired = FALSE;
        if(instanceP.StepsAndWorkitems.size() > 0 && instanceP.StepsAndWorkitems[0].ProcessNode.DeveloperName == PSM_STEPNAME && leadRec.PSM__c <> instanceP.StepsAndWorkitems[0].ActorId){
            leadRec.PSM__c = instanceP.StepsAndWorkitems[0].ActorId;
            updateRequired = TRUE;
        }else if(instanceP.StepsAndWorkitems.size() > 0 && instanceP.StepsAndWorkitems[0].ProcessNode.DeveloperName == FSR_STEPNAME && leadRec.Field_Sales_Rep__c <> instanceP.StepsAndWorkitems[0].ActorId){
            leadRec.Field_Sales_Rep__c = instanceP.StepsAndWorkitems[0].ActorId;
            updateRequired = TRUE;
        }
        if(updateRequired)
            update leadRec;
    }
    /**
    * This method is used to provide record access if individual step users dont have access already.
    * @param triggernew - List of Object record Id
    * @return return-void
    * @throws exception - NA
    */

    private static void verifyApproverAccesses(List<Id> recIds){
        Id nextApprover;
        String accessLevel = 'Read';
        List<Lead> leadRecs = getLeadRecList(recIds);
        Map<Id, Id> nextApproversMap = new Map<Id, Id>();
        for(Lead leadRec : leadRecs){
            nextApprover = NULL;
            if(leadRec.Status == PSM_STATUS){
                nextApprover = leadRec.PSM__c;
            }else if(leadRec.Status == FSR_STATUS){
                nextApprover = leadRec.Field_Sales_Rep__c;
            }else if(leadRec.Status == RSD_STATUS){
                nextApprover = leadRec.Approver3__c;
            }else if(leadRec.Status == VP_STATUS){
                nextApprover = leadRec.Approver4__c;
            }
            if(nextApprover <> NULL)
                nextApproversMap.put(leadRec.Id, nextApprover);
        }
        if(!nextApproversMap.isEmpty()){
            for(LeadShare ldShare : [Select Id, LeadId, UserOrGroupId from LeadShare WHERE LeadId IN :nextApproversMap.keySet() AND UserOrGroupId IN :nextApproversMap.values()]){
                nextApproversMap.remove(ldShare.LeadId);
            }
            if(!nextApproversMap.isEmpty()){
                ApexSharingUtility.enableSharingForInternalUsers(nextApproversMap, label.PRM_Lead_Share, accessLevel);
            }
        }
    }
    /**
    * This method is used to provide record access if a steps is reassigned to another user.
    * @param triggernew - Step process instance id and reassigned user id
    * @return return-void
    * @throws exception - NA
    */
    private static void enableSharingOnReassign(Id recId, ProcessInstance instanceP, Id reassigneeId){
        String accessLevel = 'Read';
        if(instanceP.StepsAndWorkitems.size() > 0 && instanceP.StepsAndWorkitems[0].ProcessNode.DeveloperName == PSM_STEPNAME){
            accessLevel = 'Edit';
        }
        ApexSharingUtility.enableSharingForInternalUsers(new map<Id,Id>{recId => reassigneeId}, label.PRM_Lead_Share, accessLevel);
    }
    private static ProcessInstance getProcessInstanceDetails(String recId){
        return [SELECT Id, (SELECT Id, ActorId, ProcessNode.DeveloperName, Comments FROM StepsAndWorkitems order by Id DESC LIMIT 1) 
                                     FROM ProcessInstance WHERE TargetObjectId=:recId AND Status = 'Pending'];
    }

    private static List<Lead> getLeadRecList(List<Id> leadIds){
        return [select id, PSM__c, Field_Sales_Rep__c, Approver3__c, Approver4__c, Status from Lead where Id IN :leadIds];
    }

    /**
    * This method is used to call verifyApproverAccesses asynchronously
    * @param triggernew - List of record ids
    * @return return-void
    * @throws exception - NA
    */
    @future
    public static void asyncEnableApproversAccess(List<Id> recIds){
        verifyApproverAccesses(recIds);
    }
}