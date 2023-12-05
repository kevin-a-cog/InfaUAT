/*
Class      - ApprovalRequestActioncls
Test Class - ApprovalRequestActionclsTest
Description - Class to managing Approval Request page buttons 
 ----------------
 Change history
 ---------------- ---------------- ------------------------------------------------- -------------------------------- -------------
 DEVELOPER NAME       JIRA/STORY                            DESCRIPTION                                                   TAG
 ***********************************************************************************************************************************
 VENKATESH BALLA    SALESRT-16846       To allow Queue users to take approval request action                        <SALESRT-16846>
 VENKATESH BALLA    SALESRT-17066       Moved object specific logic to utility class InfaApprovalProcessUtil        <SALESRT-17066>
 ***********************************************************************************************************************************
*/
public without sharing class ApprovalRequestActioncls {
    private static Boolean hasModifyAllAcces = FALSE;
    @AuraEnabled
    public static Datawrapper getCurrentStatus(String recordId){
        try{
            Datawrapper dwrap = new Datawrapper(); 
            //dwrap.showButtons = isValidUser(recordId, sObjectName); -- commented for <SALESRT-16846>
            list<ProcessInstanceWorkitem> currentProcessInstanceRecord = getDetailsOnTaregtObject(recordId);
            String sObjectName = getTargetObjectName(currentProcessInstanceRecord[0].ProcessInstance.TargetObjectId);
            String approvalProcessName = currentProcessInstanceRecord[0].ProcessInstance.ProcessDefinition.DeveloperName;
            dwrap.showButtons = isValidUser(recordId, sObjectName);//added for <SALESRT-16846>
            dwrap.sObjectName = sObjectName;
            dwrap.parentObjectId = currentProcessInstanceRecord[0].ProcessInstance.TargetObjectId;
            list<approvalActionDefination> approveAction = new list<approvalActionDefination>();
            for(Approval_Action_Definition__mdt meta : getCustomMetadataRecords(sObjectName,approvalProcessName)){
                approvalActionDefination inApprove = new approvalActionDefination();
                inApprove.actionName = meta.Action__c;
                inApprove.approvalProcessName = meta.Approval_Process_Name__c;
                inApprove.numberOfDayToApprove = meta.No_of_Days_to_Auto_Approve_Reject__c;
                if(meta.Action__c == 'Recall'){
                    dwrap.showRecallButton = checkIfRecallButtonVisibility(dwrap.parentObjectId, meta.Allow_Submitter_to_Recall__c);
                }
                list<approvalActionField> actionFields = new list<approvalActionField>();
                for(Approval_Action_Field_Defination__mdt fieldDefination : meta.Approval_Action_Field_Defination__r){
                    approvalActionField actfield = new approvalActionField();
                    actfield.dataType = fieldDefination.Data_type__c;
                    actfield.fieldAPIName = fieldDefination.Field_API_Name__c;
                    actfield.fieldLabel = fieldDefination.Field_Label__c;
                    actfield.isRequired = fieldDefination.isRequired__c;
                    actfield.picklistValues = fetchPicklistValues(describeDefinationMethod(meta.sObject_Name__c), fieldDefination.Field_API_Name__c);
                    actionFields.add(actfield);
                }
                inApprove.actionFields = actionFields;
                approveAction.add(inApprove);
            }
            dwrap.metadataRecords = approveAction;
            return dwrap;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateRecord(String objectName, Map<String, Object> formData, String approveRejectComment, String parentRecordId, String processInstanceId, String actionType) {
        try{
            if(actionType == 'Approve'){
                InfaApprovalProcessUtil.onApprovalActions(objectName, parentRecordId);//SALESRT-17066
            }
            performAction(actionType, approveRejectComment,processInstanceId);
            if(!formData.isEmpty()){
                SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                sObj.put('Id', parentRecordId);
                for (String fieldName : formData.keySet()) {
                    sObj.put(fieldName, formData.get(fieldName));
                }
                if(objectName == 'Lead' && actionType == 'Reject'){
                    sObj.put('Decision_Criteria_for_Customer__c', approveRejectComment);
                }
                update sObj;
            }
            return actionType == 'Approve' ? System.label.Approval_Success_Message : System.label.Rejection_Success_Message;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String handleRecallAssignment(String recordId){
        try {
            Approval.ProcessWorkItemRequest Preq= new Approval.ProcessWorkItemRequest();
            Preq.setAction('Removed');
            Preq.setWorkItemId(recordId);
            Approval.ProcessResult result = Approval.process(Preq);  
            return System.Label.Recall_Success_Message;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String handleReassignment(String recordId, String newUserId, String targetObjectId, String sObjectName){
        map<Id, Id> mapOfLeadIdToUserId = new map<Id,Id>();
        try{
            InfaApprovalProcessUtil.onReassignActions(sObjectName, targetObjectId, newUserId);//SALESRT-17066
            ProcessInstanceWorkItem piUpdate = new ProcessInstanceWorkItem(Id = recordId, ActorId = newUserId);
            update piUpdate;
            return System.label.Reassigned_Success_Message;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static boolean isValidUser(String recordId, String sobjectName){
        //CustomPermissionsReader cpr = new CustomPermissionsReader();// to check the user permission
        //Boolean IsExemptUser = cpr.hasPermission('SystemAdmin') || cpr.hasPermission('SalesSuperUser');--removed this part of <SALESRT-16846>
        List<ProcessInstanceWorkitem> piws = [SELECT ProcessInstanceId, ProcessInstance.Status, ActorId, Actor.Type FROM ProcessInstanceWorkitem WHERE id=:recordId];
        Boolean isValidUsr = FALSE;
        if(piws.size () == 0){
            return true;
        }else{
            Id currentUserId = USERINFO.getUserId();
            if(piws[0].ActorId <> currentUserId){
                //if step is assigned to Queue - verifies logged in user is part of Queue
                if(piws[0].Actor.Type == 'User'){
                    isValidUsr = isDelegatedApprover(currentUserId, piws[0].ActorId);
                }  
                else if(piws[0].Actor.Type == 'Queue'){
                    isValidUsr = isUserQueueMemeber(piws[0].ActorId, currentUserId);
                }
                if(!isValidUsr){
                    //if logged in user neither Assignee nor Queue memeber - verified if user has modify all access sobject e.g. Lead, DiscountApproval etc..
                    hasModifyAllAcces = hasModifyAllObjectAccess(sobjectName);//added for SALESRT-16846 --Select UserOrGroupId From GroupMember where Group.DeveloperName  ='DR_Queue'
                    isValidUsr = hasModifyAllAcces;
                }
            }
            return ((piws[0].ActorId == currentUserId || isValidUsr) && piws[0].ProcessInstance.Status != 'Approved' )? true : false;
        }
    }

    private static boolean hasModifyAllObjectAccess(String sobjectName){
        Set<Id> permSetIds = new Set<Id>();
        for(PermissionSetAssignment psa : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE assigneeId = :UserInfo.getUserId()]){
                                            permSetIds.add(psa.PermissionSetId);
                                        }
        List<Objectpermissions> ops = [select id, parentid, parent.label, sobjecttype FROM Objectpermissions WHERE PermissionsModifyAllRecords=true AND 
                                       (parentId IN :permSetIds OR Parent.Label =:UserInfo.getProfileId()) AND SobjectType = :sobjectName Limit 1];
        return ops.size() > 0;
    }

    private static boolean isUserQueueMemeber(Id queueId, Id loginUserId){
        List<GroupMember> groupMembers = [Select Id From GroupMember where GroupId = :queueId AND UserOrGroupId = :loginUserId];
        return groupMembers.size() > 0;
    }
    
    private static boolean isDelegatedApprover(Id loginUserId, Id currentAssigneeId){
        List<User> users = [SELECT Id FROM User WHERE Id=:currentAssigneeId AND DelegatedApproverId = :loginUserId];
        return users.size() > 0;
    }

    private static list<Approval_Action_Definition__mdt> getCustomMetadataRecords(String SobjectAPIName,String approvalProcessName){

        return [SELECT id, Action__c, Approval_Process_Name__c,isActive__c, Allow_Submitter_to_Recall__c ,No_of_Days_to_Auto_Approve_Reject__c, sObject_Name__c, (SELECT id, Approval_Action_Definition__c, Data_type__c, Field_API_Name__c, Field_Label__c, isRequired__c from Approval_Action_Field_Defination__r) from Approval_Action_Definition__mdt where isActive__c = TRUE AND sObject_Name__c =:SobjectAPIName AND Approval_Process_Name__c =:approvalProcessName];
    }

    private static Boolean performAction(String actionName, String comments, String workItemId){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(comments);
        req.setAction(actionName);
        req.setWorkitemId(workItemId);
        Approval.ProcessResult result =  Approval.process(req);
        return result.isSuccess();
    }
    
    private static list<ProcessInstanceWorkitem> getDetailsOnTaregtObject(String recordId){
        return [SELECT ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName, ActorId 
        FROM ProcessInstanceWorkitem WHERE id= :recordId];
    }

    private static String getTargetObjectName(Id targetObjectId){
        return targetObjectId.getSObjectType().getDescribe().getName();
    }

    private static Schema.DescribeSObjectResult describeDefinationMethod(String sObjectName){
        return Schema.getGlobalDescribe().get(sObjectName).getDescribe();
    }

    private static List<Option> fetchPicklistValues(Schema.DescribeSObjectResult describeSObjectResult, String picklistFieldApiName){
        List<Option> picklistValues = new List<Option>();
        Schema.SObjectField field = describeSObjectResult.fields.getMap().get(picklistFieldApiName);
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistValues.add(new Option(picklistEntry.getLabel(), picklistEntry.getValue()));
        }
        return picklistValues;
    }

    private static boolean checkIfRecallButtonVisibility(String targetObjectId, boolean showRecallOnParent){
        //CustomPermissionsReader cpr = new CustomPermissionsReader();--removed this part of <SALESRT-16846>
        //boolean IsExemptUser = cpr.hasPermission('SystemAdmin') || cpr.hasPermission('SalesSuperUser');--removed this part of <SALESRT-16846>
        ProcessInstance pi  = [SELECT SubmittedById, SubmittedBy.Name FROM ProcessInstance 
                                WHERE TargetObjectId = :targetObjectId Order By CreatedDate DESC LIMIT 1];
        return  (hasModifyAllAcces ||  (pi.SubmittedById == USERINFO.getUserId() && showRecallOnParent)) ? true : false;               
    }

    public class Datawrapper{
        @AuraEnabled public boolean showButtons;
        @AuraEnabled public boolean showRecallButton;
        @AuraEnabled public string sObjectName;
        @AuraEnabled public string parentObjectId;
        @AuraEnabled public list<approvalActionDefination> metadataRecords;
    }

    public class approvalActionDefination{        
        @AuraEnabled public string actionName;
        @AuraEnabled public string approvalProcessName;
        @AuraEnabled public decimal numberOfDayToApprove;
        @AuraEnabled public list<approvalActionField> actionFields;
    }

    public class approvalActionField{
        @AuraEnabled public string dataType;
        @AuraEnabled public string fieldAPIName;
        @AuraEnabled public string fieldLabel;
        @AuraEnabled public boolean isRequired;
        @AuraEnabled public List<Option> picklistValues;
        @AuraEnabled public boolean getIsTextAreaField(){
            return this.dataType == 'text-area' ? true : false;
        } 
        @AuraEnabled public boolean getIsPicklistField(){
            return this.dataType == 'Picklist' ? true : false;
        }
    }
    public class Option {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}