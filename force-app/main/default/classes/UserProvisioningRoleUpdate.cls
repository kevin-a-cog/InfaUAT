/*
Class:          UserProvisioningRoleUpdate
@Author:        Chandana Gowda
@Created Date:  3 Oct 2021
@Description:   Queuqble class to update user Role, for user provisioning. created queuable class as the logic for FF
                user provsioioning happens in a future method on update of user role
@Test Class:    UserProvisioningHandlerTest

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
************************************************************************************************************************************************************
*/
global with sharing class UserProvisioningRoleUpdate implements Queueable {
    public static globalApexManager GAM = new globalApexManager();   
    List<User> lstUserRoletoUpdate = new List<User>();
    Set<Id> setPermissionRequestIdToUpdate = new Set<Id>();
    
    public UserProvisioningRoleUpdate(List<User> lstUsers,Set<Id> setPermissionRequestId) {
        this.lstUserRoletoUpdate = lstUsers;
        this.setPermissionRequestIdToUpdate = setPermissionRequestId;
    }

    global void execute(QueueableContext ctx){
        List<Add_On_Permission_Request__c> lstPermissionRequest= [SELECT Id,Add_Ons__c,User_Provisioning_Request__c,User_Provisioning_Request__r.User__c FROM Add_On_Permission_Request__c WHERE Id IN :setPermissionRequestIdToUpdate];
        Set<Id> setAddOnRequestIdToUpdate = new Set<Id>();
        Map<Id,Id> mapUserPermissionRequestId = new Map<Id,Id>();
        for(Add_On_Permission_Request__c permissionReq:lstPermissionRequest){
            mapUserPermissionRequestId.put(permissionReq.User_Provisioning_Request__r.User__c,permissionReq.Id);
        }
        //Updating user Role
        if(!lstUserRoletoUpdate.isEmpty()){
            try{
                if(Test.isRunningTest()) {
                    globalApexManager.avoidRecursion('UserAfterUpdate');
                }
                Database.SaveResult[] srList = Database.update(lstUserRoletoUpdate, false);
                for(Database.SaveResult saveRes:srList){
                    if(saveRes.isSuccess() && mapUserPermissionRequestId.containsKey(saveRes.getId())){
                        setAddOnRequestIdToUpdate.add(mapUserPermissionRequestId.get(saveRes.getId()));
                    }else{
                        GAM.CreateLogs('UserProvisioningRoleUpdate.execute - Error updating user Role', saveRes.getId(),String.valueOf(saveRes.getErrors()[0].getStatusCode()), saveRes.getErrors()[0].getMessage());
                    }
                }
                if(!setAddOnRequestIdToUpdate.isEmpty()){
                    updatePemrissionRequest(setAddOnRequestIdToUpdate);
                }
            }catch(Exception e){
                GAM.CreateLogs('UserProvisioningRoleUpdate.execute - Error updating user Role', lstUserRoletoUpdate, 'lstUserRoletoUpdate');
            }
        }
        GAM.InsertDebugLogs(); 
    }
    
    @future
    public static void updatePemrissionRequest(Set<Id> setAddOnRequestIdToUpdate){
        List<Add_On_Permission_Request__c> lstPermissionRequestToUpdate = new List<Add_On_Permission_Request__c>();
        for(Id requestId:setAddOnRequestIdToUpdate){
            Add_On_Permission_Request__c permissionReq = new Add_On_Permission_Request__c(Id = requestId);
            permissionReq.Permission_Assigned__c = true;
            lstPermissionRequestToUpdate.add(permissionReq);
        }
        try{
            Database.SaveResult[] srList = Database.update(lstPermissionRequestToUpdate, false);
        }catch(Exception e){
                GAM.CreateLogs('UserProvisioningRoleUpdate.updatePemrissionRequest - Error updating Permission Request Record', lstPermissionRequestToUpdate, 'lstPermissionRequestToUpdate');
        }
    }
}