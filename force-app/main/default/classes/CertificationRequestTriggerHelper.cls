/*
 * Name         :   CertificationRequestTriggerHelper
 * Author       :   Vignesh Divakaran
 * Created Date :   5/27/2022
 * Description  :   This is an helper class.

 Change History
 ***********************************************************************************************************************************
 Modified By            Date            Jira No.        Tag     Description                                
 ***********************************************************************************************************************************
 Vignesh Divakaran      5/27/2022       I2RT-6149       N/A     Initial version.
 balajip                6/30/2022       I2RT-6643       T01     To include the SME Products when populating the SME details 
                                                                    in the field Support_SMEs__c
 Vignesh Divakaran      7/21/2023       I2RT-8640       T02     Commented the code to rollup certification request onto 
                                                                support account.
 Vignesh Divakaran      7/21/2023       I2RT-8640       T03     Added null check before adding Owner__c id to the set. 
 */

public class CertificationRequestTriggerHelper {

    public static globalApexManager GAM = new globalApexManager();
    public static final Set<String> setCustomPermissions = new Set<String>{'GCS_Manager'};

    /**
    * this method rollsup certification request start and end date onto support account.
    * @param lstNewCertificationRequests, mapOldCertificationRequests
    * @return return-void
    * @throws exception - NA
    */
    /*public void rollupCertificationRequestToSupportAccount(List<Certification_Request__c> lstNewCertificationRequests , Map<Id, Certification_Request__c> mapOldCertificationRequests){

        Date dToday = GlobalUtility.getOrganizationDate();
        Set<String> setRequestTypes = new Set<String>();
        Set<Id> setSupportAccountIds = new Set<Id>();
        Map<Id, Account> mapSupportAccounts = new Map<Id, Account>();

        for(Certification_Request__c objCertificationRequest : lstNewCertificationRequests){

            //Check if any of Start Date, End Date and Status is updated
            Certification_Request__c objCertificationRequestOld = mapOldCertificationRequests.get(objCertificationRequest.Id);
            if(objCertificationRequestOld.Start_Date__c != objCertificationRequest.Start_Date__c || objCertificationRequestOld.End_Date__c != objCertificationRequest.End_Date__c || objCertificationRequestOld.Status__c != objCertificationRequest.Status__c) { 
                    setSupportAccountIds.add(objCertificationRequest.Support_Account__c);
            }
        }

        if(!setSupportAccountIds.isEmpty()){

            Schema.DescribeFieldResult objFieldDescribe = Certification_Request__c.Request_Type__c.getDescribe();
            for (Schema.PicklistEntry objPickList : objFieldDescribe.getPickListValues()) {
                //Add an entry for each request rype
                setRequestTypes.add(objPickList.getValue());
            }

            //Now, we query support account with all active approved certification Requests
            for(Account objSupportAccount : [SELECT Id, Certification_Request_Start_Date__c, Certification_Request_End_Date__c, Certification_Request__c, GCS_Segment__c,
                                                (SELECT Id, Start_Date__c, End_Date__c, Request_Type__c,Product__c,CreatedDate FROM Certification_Requests__r 
                                                WHERE Status__c = 'Approved' AND ((Start_Date__c <= :dToday AND End_Date__c >= :dToday) OR (Start_Date__c >= :dToday AND End_Date__c >= :dToday))
                                                ORDER BY Start_Date__c ASC, End_Date__c DESC) 
                                                FROM Account WHERE Id IN :setSupportAccountIds]){

                Certification_Request__c objActiveCertificationRequest;
                for(Certification_Request__c objCertificationRequest : objSupportAccount.Certification_Requests__r){
                    if(objActiveCertificationRequest == null){
                        objActiveCertificationRequest = objCertificationRequest;
                    }
                    else{
                        if(objCertificationRequest.Start_Date__c <= dToday && objCertificationRequest.End_Date__c >= dToday && objCertificationRequest.CreatedDate > objActiveCertificationRequest.CreatedDate){
                            objActiveCertificationRequest = objCertificationRequest;
                        }
                    }
                }
                if(objActiveCertificationRequest != null){
                    Account objSupportAccountNew = new Account(Id = objSupportAccount.Id);
                    objSupportAccountNew.Certification_Request__c = objActiveCertificationRequest?.Id;
                    objSupportAccountNew.Certification_Request_Start_Date__c = objActiveCertificationRequest?.Start_Date__c;
                    objSupportAccountNew.Certification_Request_End_Date__c = objActiveCertificationRequest?.End_Date__c;
                    objSupportAccountNew.Product__c = objActiveCertificationRequest?.Product__c;
                    //Now, we check for inprogress certification request and update GCS Segment
                    if((objActiveCertificationRequest.Start_Date__c <= dToday && objActiveCertificationRequest.End_Date__c >= dToday) && objSupportAccount.GCS_Segment__c != objActiveCertificationRequest.Request_Type__c){
                        objSupportAccountNew.GCS_Segment__c = objActiveCertificationRequest.Request_Type__c;
                    }
                    //Now, we check for future certification request and reset the GCS Segment to null
                    if((objActiveCertificationRequest.Start_Date__c > dToday && objActiveCertificationRequest.End_Date__c >= dToday) && setRequestTypes.contains(objSupportAccount?.GCS_Segment__c)){
                        objSupportAccountNew.GCS_Segment__c = null;
                    }
                    mapSupportAccounts.put(objSupportAccount.Id, objSupportAccountNew);
                }
            }

            //If there is no active approved certification request, reset fields on support account
            for(Id supportAccountId : new List<Id>(setSupportAccountIds)){
                if(!mapSupportAccounts.containsKey(supportAccountId)){
                    Account objSupportAccount = new Account(Id = supportAccountId);
                    objSupportAccount.GCS_Segment__c = null;
                    objSupportAccount.Certification_Request__c = null;
                    objSupportAccount.Certification_Request_Start_Date__c = null;
                    objSupportAccount.Certification_Request_End_Date__c = null;
                    objSupportAccount.Product__c = null;
                    mapSupportAccounts.put(supportAccountId, objSupportAccount);
                }
            }
        }

        if(!mapSupportAccounts.values().isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(mapSupportAccounts.values(), false);             
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('CertificationRequestTriggerHelper.rollupCertificationRequestToSupportAccount', 'Error while updating support accounts: ', e.getMessage());
            } 
        }
    }*/ //<T02>

    /**
    * this method 
    * @param lstCases
    * @return return-void
    * @throws exception - NA
    */
    public void notify(List<Certification_Request__c> lstNewCertificationRequests , Map<Id, Certification_Request__c> mapOldCertificationRequests){
        NotificationService.notify(lstNewCertificationRequests, mapOldCertificationRequests);
    }

    /**
    * this method 
    * @param lstCases
    * @return return-void
    * @throws exception - NA
    */
    public void populateFields(List<Certification_Request__c> lstNewCertificationRequests , Map<Id, Certification_Request__c> mapOldCertificationRequests){
        Map<Id, Id> mapCertRequestIdToAccId = new Map<Id, Id>();
        Set<Id> setApprRejectedCertId = new Set<Id>();
        
        for(Certification_Request__c certRequest : lstNewCertificationRequests){
            mapCertRequestIdToAccId.put(certRequest.Id, certRequest.Support_Account__c);
            if('Approved'.equals(certRequest.Status__c) || 'Rejected'.equals(certRequest.Status__c)){
                setApprRejectedCertId.add(certRequest.Id);
            }
        }
        
        List<AccountTeamMember> lstAccTeamMember = [SELECT AccountId, UserId, User.Name, Product__c FROM AccountTeamMember //T01
                                                    WHERE TeamMemberRole = 'Support SME' 
                                                    AND AccountId IN :mapCertRequestIdToAccId.values()];

        Map<Id, Set<String>> mapAccIdToSMEs = new Map<Id, Set<String>>();
        for(AccountTeamMember accTeamMember : lstAccTeamMember){
            Set<String> setUserDetail = new Set<String>();
            if(mapAccIdToSMEs.containsKey(accTeamMember.AccountId)){
                setUserDetail = mapAccIdToSMEs.get(accTeamMember.AccountId);
            }
            //T01
            String products = '';
            if(String.isNotEmpty(accTeamMember.Product__c)){
                products = ' (' + accTeamMember.Product__c.replaceAll(';', '; ') + ')';
            }
            setUserDetail.add(accTeamMember.User.Name + products);

            mapAccIdToSMEs.put(accTeamMember.AccountId, setUserDetail);
        }

        List<ProcessInstanceStep> lstProcessInstanceStep = [SELECT Id, ActorId, Comments, OriginalActorId, StepStatus, CreatedDate 
                                        FROM ProcessInstanceStep 
                                        WHERE ProcessInstance.TargetObjectId in :setApprRejectedCertId
                                          AND StepStatus in ('Approved', 'Rejected')
                                        ORDER BY CreatedDate Desc];

        for(Certification_Request__c certRequest : lstNewCertificationRequests){
            List<String> lstUserDetail = new List<String>(mapAccIdToSMEs.get(certRequest.Support_Account__c));
            certRequest.Support_SMEs__c = String.join(lstUserDetail, ', ');

            ProcessInstanceStep processInstanceStepSelected;
            for(ProcessInstanceStep processInstanceStep : lstProcessInstanceStep){
                if(processInstanceStep.StepStatus == certRequest.Status__c){
                    processInstanceStepSelected = processInstanceStep;
                    break;
                }
            }
            if(processInstanceStepSelected != null){
                certRequest.Approver__c = processInstanceStepSelected.ActorId;
                certRequest.Approved_Rejected_Date__c = Date.valueOf(processInstanceStepSelected.CreatedDate);
                certRequest.Approver_Comments__c = processInstanceStepSelected.Comments;    
            }
        }
    }

    /**
    * this method validates if the owner__c is a GCS Manager, else a validation will be thrown.
    * @param lstNewCertificationRequests, mapOldCertificationRequests
    * @return return-void
    * @throws exception - NA
    */
    public void validateOwner(List<Certification_Request__c> lstNewCertificationRequests, Map<Id, Certification_Request__c> mapOldCertificationRequests, Boolean boolIsBefore, Boolean boolIsInsert, Boolean boolIsUpdate){

        Set<Id> setOwnerIds = new Set<Id>();
        Set<Id> permissionSetGroupIds = new Set<Id>();
        Set<Id> setUsersWithCustomPermission = new Set<Id>();

        if(boolIsBefore && boolIsInsert){
            for(Certification_Request__c objCertificationRequest : lstNewCertificationRequests) {
                if(objCertificationRequest.Owner__c != null){ //<T03>
                    setOwnerIds.add(objCertificationRequest.Owner__c);
                }
            }
        }
        else if(boolIsBefore && boolIsUpdate){
            for(Certification_Request__c objCertificationRequest : lstNewCertificationRequests) {
                if(objCertificationRequest.Owner__c != mapOldCertificationRequests.get(objCertificationRequest.Id).Owner__c && objCertificationRequest.Owner__c != null){ //<T03>
                    setOwnerIds.add(objCertificationRequest.Owner__c);
                }
            }
        }

        if(!setOwnerIds.isEmpty()) {
            //Now, we query all the permission sets with custom permission
            for(SetupEntityAccess objSetupEntityAccess : [SELECT Parent.PermissionSetGroupId FROM SetupEntityAccess 
                                                            WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName IN :setCustomPermissions) 
                                                            AND Parent.PermissionSetGroupId != null]) {
                permissionSetGroupIds.add(objSetupEntityAccess.Parent.PermissionSetGroupId);
            }

            //Now, we query users with permission set group
            if(!permissionSetGroupIds.isEmpty()) {
                for(PermissionSetAssignment objPermissionSetAssignment : [SELECT AssigneeId FROM PermissionSetAssignment 
                                                                            WHERE PermissionSetGroupId IN :permissionSetGroupIds AND AssigneeId IN :setOwnerIds]) {
                    setUsersWithCustomPermission.add(objPermissionSetAssignment.AssigneeId);
                }

                for(Certification_Request__c objCertificationRequest : lstNewCertificationRequests) {
                    if(!setUsersWithCustomPermission.contains(objCertificationRequest.Owner__c)) {
                        objCertificationRequest.addError('Owner is not a GCS Manager');
                    }
                }
            }
        }
    }
}