/*
Class:          UserProvisioningBatch
@Author:        Chandana Gowda
@Created Date:  3 Oct 2021
@Description:   Batch to assin user MPL,PSL and PSGs when the provisioning request is approved
@Test Class:    UserProvisioningHandlerTest

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By       Description                                                                 Tag
nmane                                                                      Added logic for Start/EndDate,Permission set assignmnet and checking for    <T01>
                                                                           mpl/psl assignment before PS/PSG Assignment

Sourabh Bhardwaj                    SALESRT-14044                         Added logic for providing PSG for business roles and also logic for handling
                                                                          scenarios where a PSG is already assigned yet a UP Request is raised for the 
                                                                          PSG.                                                                         <T02>
Sreerekha A                                                                          <T03>
Wasim               07-Oct-2023      PSA-3226                             Moving the Permission set group assignment and license from User to contact  <T04>
                                                                          Automation to User provisioning                    
Wasim               18-Oct-2023      PSA-3235                             Adding null check                                                            <T05>    
************************************************************************************************************************************************************
*/
global class UserProvisioningBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    public List<Exceptions_Log__c> lstExceptionLog = new List<Exceptions_Log__c>();
    public Map<String,Id> mapPermissionRequestId = new Map<String,Id>(); //Map of UserId+PSGName and Add_On_Permission_Request__c Id, used in updating the permission Assigned flag on permission request record
    public Set<Id> setPSAsigneeId = new Set<Id>();
    public Map<Id,Id> mapLicenseRequestId = new Map<Id,Id>(); //Map of UserID & Add_On_Permission_Request__c Id //<T03>
    public Map<Id,Add_On_Permission_Request__c> mapPRParentRole = new Map<Id,Add_On_Permission_Request__c>();//<T02> For storing the PRs where parent role field is not blank
    public List<Id> errorId = new List<Id>(); //<T03> stores the userIds for which error occured
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        String approvedStatus = 'Approved';
        String permissionAssigned = 'Permission Assigned'; //<T03>
        String permissionRemoved = 'Permission Removed'; //<T03>
        Date today =System.Today();   // <T01>
        query = 'SELECT Id,Add_Ons__c,User_Provisioning_Request__c,User_Provisioning_Request__r.User__c,User_Provisioning_Request__r.Business_Role__c, Start_Date__c,End_Date__c,Permission_Assigned__c,Parent_Role__c,Parent_Role__r.Permission_Assigned__c,Parent_Role__r.Approver__c,Parent_Role__r.Approver_2__c,License_Action__c FROM Add_On_Permission_Request__c WHERE (Approval_Status__c = :approvedStatus OR Parent_Role__r.Approval_Status__c =: approvedStatus) AND License_Request_Status__c !=:permissionAssigned AND License_Request_Status__c !=:permissionRemoved AND (Permission_Assigned__c = false OR (End_Date__c =:today AND Permission_Assigned__c = true))';    //<T01> //Parent_Role__r.Approval_Status__c criteria has been added in <T02> //<T03>
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Add_On_Permission_Request__c> scope){
        List<Add_On_Permission_Request__c> lstUserProvisioningRequestUpdate = new List<Add_On_Permission_Request__c>();
        Map<Id,Set<String>> mapUserPsgsToAssign = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapUserPsgsToDelete = new Map<Id,Set<String>>();
        Set<String> permissionSetGroupNames = new Set<String>();
        List<Add_On_Permission_Request__c> lstPRtoAssign = new List<Add_On_Permission_Request__c>();
        List<Add_On_Permission_Request__c> lstPRtoRemove = new List<Add_On_Permission_Request__c>();
        Set<Id> userIds = new Set<Id>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> pslaList = new List<PermissionSetLicenseAssign>();
        List<UserPackageLicense> uplList = new List<UserPackageLicense>();
        //<T01>----------------------------------------
        //Seggragating the Permission Request for Permission Assignmnet and Removal
        for(Add_On_Permission_Request__c userRequest:scope){
            if(!userRequest.Permission_Assigned__c && (userRequest.Start_Date__c == system.Today() || userRequest.Start_Date__c==null)){
                lstPRtoAssign.add(userRequest);
            }
            if(userRequest.Permission_Assigned__c && userRequest.End_Date__c == system.Today()){
                lstPRtoRemove.add(userRequest);
            }
            setPSAsigneeId.add(userRequest.User_Provisioning_Request__r.User__c);
            
            //Map of User & Permission Request created for License Management Module //<T03>
            if(userRequest.License_Action__c != null){
              mapLicenseRequestId.put(userRequest.Id,userRequest.User_Provisioning_Request__r.User__c);
            }
            //<T03> ends
            
            //---------------------------<T02>
            if(String.isNotBlank(userRequest.Parent_Role__c)){
                mapPRParentRole.put(userRequest.Id,userRequest);
            }//--------------------------<T02>
            //<T04>
            //Store the userIds in a set that needs to be processed for IPS Role 
            //<T05> - Adding null check for Business Role
            if(userRequest.User_Provisioning_Request__r.Business_Role__c != null && userRequest.User_Provisioning_Request__r.Business_Role__c.startsWithIgnoreCase('IPS ')){
                userIds.add(userRequest.User_Provisioning_Request__r.User__c);
            }
            //</T04>
        }
        //<T04> - Delete all the existing Permission set group assignment and Permission set license assign assigned to the Users
        if(userIds.size() > 0){
            //Get the permission set assignment and permission set license assignment for those users and add it to delete list
                psaList = [SELECT Id,AssigneeId,PermissionSetGroupId FROM PermissionSetAssignment WHERE AssigneeId IN :userIds AND PermissionSetGroupId != null AND (PermissionSetGroup.MasterLabel LIKE 'PSA%' OR PermissionSetGroup.MasterLabel LIKE 'CPQ%' OR PermissionSetGroup.MasterLabel LIKE 'Conga%')];
                pslaList = [SELECT Id,AssigneeId,PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId IN :userIds AND PermissionSetLicenseId != null AND PermissionSetLicense.DeveloperName LIKE 'SalesforceCPQ%'];
                uplList = [SELECT Id,PackageLicenseId,UserId FROM UserPackageLicense WHERE UserId IN :userIds AND PackageLicense.NamespacePrefix IN ('pse', 'APXTConga4')];
            }
         //</T04>
        //--------------------------------------------<T01/>

        //Creating a map of Users and the PSG to be assigned
        for(Add_On_Permission_Request__c userRequest:lstPRtoAssign){
            Set<String> psgToAssign = new Set<String>();
            if(!mapUserPsgsToAssign.containsKey(userRequest.User_Provisioning_Request__r.User__c)){
                psgToAssign.add(userRequest.Add_Ons__c);
            }else{
                psgToAssign = mapUserPsgsToAssign.get(userRequest.User_Provisioning_Request__r.User__c);
                psgToAssign.add(userRequest.Add_Ons__c);
            }
            mapUserPsgsToAssign.put(userRequest.User_Provisioning_Request__r.User__c,psgToAssign); 
            permissionSetGroupNames.addAll(psgToAssign);          
        }
        //<T01>------------
        //Creating a map of Users and the PSG to be deleted
        for(Add_On_Permission_Request__c userRequest:lstPRtoRemove){
            Set<String> psgToDelete = new Set<String>();
            if(!mapUserPsgsToDelete.containsKey(userRequest.User_Provisioning_Request__r.User__c)){
                psgToDelete.add(userRequest.Add_Ons__c);
            } else{
                psgToDelete = mapUserPsgsToDelete.get(userRequest.User_Provisioning_Request__r.User__c);
                psgToDelete.add(userRequest.Add_Ons__c);
            }
            mapUserPsgsToDelete.put((userRequest.User_Provisioning_Request__r.User__c),psgToDelete); 
            permissionSetGroupNames.addAll(psgToDelete);
            
           }
        //------------<T01/>
        

        Map<String,Set<String>> mapPsgPerm = new Map<String,Set<String>>(); //Map of Permission and Permission Set  to be assigned  //<T01>
        Set<String> setPermSet = new Set<String>(); //Set of Permission Sets   //<T01>
        Map<String,Set<String>> mapPsgMpl = new Map<String,Set<String>>(); //Map of Permission and Managed Package License to be assigned
        Map<String,Set<String>> mapPsgPsl = new Map<String,Set<String>>(); //Map of Permission and Permission Set License to be assigned
        Map<String,Set<String>> mapPsgPublicGroup = new Map<String,Set<String>>(); //Map of Permission and Public group to be assigned
        Map<String,Set<String>> mapPsgPermGroup = new Map<String,Set<String>>(); //Map of Permission and Permission Set group to be assigned //<T03>
        Map<String,String> mapPsgPermSets = new Map<String,String>(); //Map of Permission and Permission Set group to be assigned //<T01>
        Map<String,String> mapPsgRole = new Map<String,String>(); //Map of Permission and Role to be assigned
        Set<String> setPackageLicense = new Set<String>(); //Set of Managed Package License Names
        Set<String> setPermissionSetLicense = new Set<String>(); //Set of Permission Set License Names
        Set<String> setPermGrpSet = new Set<String>(); //Set of Permission Set Group Names //<T03>
        Set<String> setPublicGroup = new Set<String>(); //Set of Public Group Names
        Map<String,String> mapPermissionRole = new Map<String,String>(); //Set of Permission request where role has to be updated - specific to IPS
        List<User_provisioning_Approver_Matrix__mdt>  lstPermissionsInfo = [SELECT Id,Label,Role__c,Public_Group__c,Permission_Set_Group__c,Managed_Package_License__c,Permission_Set_License__c,Permission_Set_Name__c,Role_Based_PSGs__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label IN :permissionSetGroupNames];
        for(User_provisioning_Approver_Matrix__mdt permissionInfo:lstPermissionsInfo){
            Set<String> setMpl = new Set<String>();
            Set<String> setPsl = new Set<String>();
            Set<String> setPG = new Set<String>();
            Set<String> setPSG = new Set<String>(); //<T03>
            Set<String> setPS = new Set<String>();    //<T01>
            
            if(String.isNotBlank(permissionInfo.Managed_Package_License__c)){
                setMpl.addAll(permissionInfo.Managed_Package_License__c.split(';'));
                mapPsgMpl.put(permissionInfo.Label,setMpl);
                setPackageLicense.addAll(setMpl);
            }
            
            if(String.isNotBlank(permissionInfo.Permission_Set_License__c)){
                setPsl.addAll(permissionInfo.Permission_Set_License__c.split(';'));
                mapPsgPsl.put(permissionInfo.Label,setPsl);
                setPermissionSetLicense.addAll(setPsl); 
             }
            //<T01>------------------------------------
            if(String.isNotBlank(permissionInfo.Permission_Set_Name__c)){
                setPS.addAll(permissionInfo.Permission_Set_Name__c.split(';'));
                mapPsgPerm.put(permissionInfo.Label,setPS);
                setPermSet.addAll(setPS);
            }
            //------------------------------------------<T01/>
            
            if(String.isNotBlank(permissionInfo.Permission_Set_Group__c)){
             //<T03>------------------------------------    
                setPSG.addAll(permissionInfo.Permission_Set_Group__c.split(';'));
                mapPsgPermGroup.put(permissionInfo.Label,setPSG);
                setPermGrpSet.addAll(setPSG);
             //<T03>------------------------------------                
             // mapPsgPermGroup.put(permissionInfo.Label,permissionInfo.Permission_Set_Group__c);//<T03>
                                
            }
            
            //<T04> - Changing the if condition to accomodate the change in logic for IPS users
            //if(String.isNotBlank(permissionInfo.Role__c) && String.isBlank(permissionInfo.Permission_Set_Group__c) && String.isBlank(permissionInfo.Permission_Set_Name__c)){ //If PSG and PS are blank, then the provisioning is for IPS, only role update to be made
            if(String.isNotBlank(permissionInfo.Role__c) && permissionInfo.Role__c.startsWithIgnoreCase('PS')){
                mapPermissionRole.put(permissionInfo.Label,permissionInfo.Role__c);
            }
            
            if(String.isNotBlank(permissionInfo.Public_Group__c)){
                setPG.addAll(permissionInfo.Public_Group__c.split(';'));
                mapPsgPublicGroup.put(permissionInfo.Label,setPG);
                setPublicGroup.addAll(setPG); 
            }
            
            if(String.isNotBlank(permissionInfo.Role__c)){
                mapPsgRole.put(permissionInfo.Label,permissionInfo.Role__c);
            }            
        }
        
        //Creating a map of Managed Package License Name and Id
        Map<String,Id> mapMplNameId = new Map<String,Id>();
        if(!setPackageLicense.isEmpty()){
            List<PackageLicense> lstPackageLicense= [SELECT Id,NamespacePrefix FROM PackageLicense WHERE NamespacePrefix IN :setPackageLicense];
            for(PackageLicense mpl:lstPackageLicense){
                mapMplNameId.put(mpl.NamespacePrefix,mpl.Id);
            }
        }
        
        //Creating a map of Permission Set License Name and Id
        Map<String,Id> mapPslNameId = new Map<String,Id>();
        if(!setPermissionSetLicense.isEmpty()){
            List<PermissionSetLicense> lstPermissionSetLicense= [SELECT Id,DeveloperName FROM PermissionSetLicense WHERE DeveloperName IN :setPermissionSetLicense];
            for(PermissionSetLicense psl:lstPermissionSetLicense){
                mapPslNameId.put(psl.DeveloperName,psl.Id);
            }
        }
        
        //<T01>---------------------------------------
        //Creating a map of Permission Set Name and Id
        Map<String,Id> mapPermNameId = new Map<String,Id>();
        if(!setPermSet.isEmpty()){
            List<PermissionSet> lstPermissionSet= [SELECT Id,Name,PermissionSetGroupId FROM PermissionSet WHERE Name IN :setPermSet AND PermissionSetGroupId=null];
            for(PermissionSet permset:lstPermissionSet){
                mapPermNameId.put(permset.Name,permset.Id);
            }
        }
        
        //---------------------------------------<T01>
        //Creating a map of Public Group Name and Id
        Map<String,Id> mapPGNameId = new Map<String,Id>();
        if(!setPublicGroup.isEmpty()){
            List<Group> lstPublicGroups = [SELECT Id,Name FROM Group WHERE Name IN :setPublicGroup AND Type = 'Regular'];
            for(Group grp:lstPublicGroups){
                mapPGNameId.put(grp.Name,grp.Id);
            }
        }
        
        //Creating a map of Role Name and Id
        Map<String,Id> mapRoleNameId = new Map<String,Id>();
        if(!mapPsgRole.isEmpty()){
            List<UserRole> lstUserRole = [SELECT Id,DeveloperName FROM UserRole WHERE DeveloperName IN :mapPsgRole.values()];
            for(UserRole role:lstUserRole){
                mapRoleNameId.put(role.DeveloperName,role.Id);
            }
        }
        //Creating a map of PSG Label and Id
        Map<String,Id> mapPsgNameId = new Map<String,Id>();
        //Map<Id,PermissionSetGroup> mapPermissionSetGroups = new Map<Id,PermissionSetGroup>([SELECT Id,DeveloperName,MasterLabel FROM PermissionSetGroup WHERE DeveloperName IN :mapPsgPermGroup.values()]); //<T03>
         if(!setPermGrpSet.isEmpty()){
             Map<Id,PermissionSetGroup> mapPermissionSetGroups = new Map<Id,PermissionSetGroup>([SELECT Id,DeveloperName,MasterLabel FROM PermissionSetGroup WHERE DeveloperName IN :setPermGrpSet]); //<T03>
        for(PermissionSetGroup psgRec:mapPermissionSetGroups.values()){
            mapPsgNameId.put(psgRec.DeveloperName,psgRec.Id);
        }}
        Set<Id> setPermissionRequestId = new Set<Id>(); //Set of UserId where role has to be updated
        for(Add_On_Permission_Request__c userRequest:lstPRtoAssign){

            //Add to the set only if the no permission set group/pemission set is to be assigned, specific to IPS
            if (!mapPermissionRole.isEmpty() && mapPermissionRole.containsKey(userRequest.Add_Ons__c)) {
                setPermissionRequestId.add(userRequest.Id);
                continue;
            }

            //<T01>-----------------------
            if(!mapPsgPerm.isEmpty() && mapPsgPerm.containsKey(userRequest.Add_Ons__c)){
                //Creating a map of UserId+FirstPSName and Add_On_Permission_Request__c Id
                List<String> lstPSNames = new List<String> (mapPsgPerm.get(userRequest.Add_Ons__c));
                String psName = lstPSNames[0];
                mapPermissionRequestId.put(userRequest.User_Provisioning_Request__r.User__c+psName,userRequest.Id);
            }

            if(!mapPsgPermGroup.isEmpty() && mapPsgPermGroup.containsKey(userRequest.Add_Ons__c)){
                //Creating a map of UserId+PSGName and Add_On_Permission_Request__c Id
                //<T03>
                List<String> lstPSGNames = new List<String> (mapPsgPermGroup.get(userRequest.Add_Ons__c));
                String psgName = lstPSGNames[0];
                mapPermissionRequestId.put(userRequest.User_Provisioning_Request__r.User__c+psgName,userRequest.Id);
                /*
                String psgName = mapPsgPermGroup.get(userRequest.Add_Ons__c);            
                mapPermissionRequestId.put(userRequest.User_Provisioning_Request__r.User__c+psgName,userRequest.Id);*/ 
                //<T03>
            }            
            //-------------------------------<T01/>
        }        
        
        List<UserPackageLicense> lstUserPackageLicenseToInsert = new List<UserPackageLicense>();
        List<PermissionSetLicenseAssign> lstPslAssignmentToInsert = new List<PermissionSetLicenseAssign>();
        List<GroupMember> lstGroupMemberToInsert = new List<GroupMember>();
        List<PermissionSetAssignment> lstPermissionSetAssignmentToInsert = new List<PermissionSetAssignment>();    
        List<User> lstUserRoletoUpdate = new List<User>();   
        List<PermissionSetAssignment> lstPermissionSetAssignmentToDelete = new List<PermissionSetAssignment>();    //<T01>
        List<UserPackageLicense> lstUserPackageLicenseToDelete = new List<UserPackageLicense>();
        List<PermissionSetLicenseAssign> lstPslAssignmentToDelete = new List<PermissionSetLicenseAssign>();
        List<GroupMember> lstGroupMemberToDelete = new List<GroupMember>();
        //<T03>
        List<UserPackageLicense> lstExistingUserPackageLicense = [Select Id,UserId,PackageLicenseId from UserPackageLicense where UserId IN:mapUserPsgsToAssign.keySet() and PackageLicenseId IN: mapMplNameId.values()]; //<T03>
        Map<String,Id> mapExistingUserPackageLicense = new Map<String,Id>();
        for(UserPackageLicense upl :lstExistingUserPackageLicense){
            String userID = upl.UserId;
            mapExistingUserPackageLicense.put(upl.PackageLicenseId+userID,upl.Id);
        }
        //<T03> ends
        for(Id userId:mapUserPsgsToAssign.keySet()){
            for(String psgToAssign:mapUserPsgsToAssign.get(userId)){
                if(mapPsgMpl.containsKey(psgToAssign)){
                    Set<String> setMpl = mapPsgMpl.get(psgToAssign);
                    for(String mpl:setMpl){
                       if(mapExistingUserPackageLicense.get(userId+mpl) == null){ //<T03>
                        UserPackageLicense upl = new UserPackageLicense();
                        upl.UserId = userId;
                        upl.PackageLicenseId = mapMplNameId.get(mpl);
                        lstUserPackageLicenseToInsert.add(upl);  
                    }
                }
                    
                }
                if(mapPsgPsl.containsKey(psgToAssign)){
                    Set<String> setPsl = mapPsgPsl.get(psgToAssign);
                    for(String psl:setPsl){
                        PermissionSetLicenseAssign psla = new PermissionSetLicenseAssign();
                        psla.AssigneeId = userId;
                        psla.PermissionSetLicenseId = mapPslNameId.get(psl);
                        lstPslAssignmentToInsert.add(psla);                        
                    }
                }
                if(mapPsgPublicGroup.containsKey(psgToAssign)){
                    Set<String> setGroup= mapPsgPublicGroup.get(psgToAssign);
                    for(String grpName:setGroup){
                        GroupMember grpMemeber = new GroupMember();
                        grpMemeber.GroupId = mapPGNameId.get(grpName);
                        grpMemeber.UserOrGroupId = userId;
                        lstGroupMemberToInsert.add(grpMemeber);
                    }
                }
                if(mapPsgRole.containsKey(psgToAssign)){
                    User usrtoUpdate = new User(Id = userId);
                    usrtoUpdate.UserRoleId = mapRoleNameId.get(mapPsgRole.get(psgToAssign));
                    lstUserRoletoUpdate.add(usrtoUpdate);
                }
                //<T01>-----------------------------
                if(mapPsgPerm.containsKey(psgToAssign)){
                    Set<String> setPS = mapPsgPerm.get(psgToAssign);
                    for(String permset:setPS){
                        PermissionSetAssignment psa = new PermissionSetAssignment();
                        psa.AssigneeId = userId;
                        psa.PermissionSetId = mapPermNameId.get(permset);
                        lstPermissionSetAssignmentToInsert.add(psa);                        
                    }
                }
                //------------------------------<T01/>
                if(mapPsgPermGroup.containsKey(psgToAssign)){
                    //<T03>-----------------------------------------------------
                    Set<String> setPSG = mapPsgPermGroup.get(psgToAssign);
                    for(String permgrp:setPSG){
                        PermissionSetAssignment psg = new PermissionSetAssignment();
                        psg.AssigneeId = userId;
                        psg.PermissionSetGroupId = mapPsgNameId.get(permgrp);
                        lstPermissionSetAssignmentToInsert.add(psg);   
                     }
                    /*PermissionSetAssignment psaRec = new PermissionSetAssignment(AssigneeId = userId);
                    psaRec.PermissionSetGroupId = mapPsgNameId.get(mapPsgPermGroup.get(psgToAssign));
                    lstPermissionSetAssignmentToInsert.add(psaRec);*/
                    //<T03>-----------------------------------------------------------
                }
            }
        }
        
        //<T01>-----------------------------
        //Getting the PermissionSetGroup Assignment to Delete
        List<PermissionSetAssignment> lstpsaRec = [SELECT Id,PermissionSetGroupId, PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :mapUserPsgsToDelete.keySet() AND PermissionSetGroupId != null];
        if (!lstpsaRec.isEmpty()) {
            for(PermissionSetAssignment psaRec:lstpsaRec){
                if(mapUserPsgsToDelete.keySet().contains(psaRec.AssigneeId)){
                    for(String psgToRemove:mapUserPsgsToDelete.get(psaRec.AssigneeId)){
                        //<T03>-------------------------------------
                        if(mapPsgPermGroup.containsKey(psgToRemove)){
                            Set<String> setPsg = mapPsgPermGroup.get(psgToRemove);
                            for(String psg:setPsg){
                                if(psaRec.PermissionSetGroupId == mapPsgNameId.get(psg)){
                                    lstPermissionSetAssignmentToDelete.add(psaRec);                                
                                }
                            }
                        }
                       /* if(psaRec.PermissionSetGroupId == mapPsgNameId.get(mapPsgPermGroup.get(psgToRemove))){
                            lstPermissionSetAssignmentToDelete.add(psaRec);                                
                        }*/
                        //<T03>---------------------------------------------------------------------
                    }
                }
            }
        }
        //<T04> - add the existing PSG assignment to the delete list for IPS Users
        if(psaList.size() > 0){
            lstPermissionSetAssignmentToDelete.addAll(psaList);
        }
        //</T04>
        //Getting the Permission Set License to Delete
        List<PermissionSetLicenseAssign> lstpslRec = [SELECT Id,AssigneeId,PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId IN :mapUserPsgsToDelete.keySet() AND PermissionSetLicenseId != null];
        if (!lstpslRec.isEmpty()) {
            for(PermissionSetLicenseAssign pslRec:lstpslRec){
                if(mapUserPsgsToDelete.keySet().contains(pslRec.AssigneeId)){
                    for(String psgToRemove:mapUserPsgsToDelete.get(pslRec.AssigneeId)){
                        if(mapPsgPsl.containsKey(psgToRemove)){
                            Set<String> setPsl = mapPsgPsl.get(psgToRemove);
                            for(String psl:setPsl){
                                if(pslRec.PermissionSetLicenseId == mapPslNameId.get(psl)){
                                    lstPslAssignmentToDelete.add(pslRec);                                
                                }
                            }
                        }
                    }
                }
            }
         }
        //<T04> - add the existing PSL assignment to the delete list for IPS Users
        if(pslaList.size() > 0){
            lstPslAssignmentToDelete.addAll(pslaList);
        }
        //</T04>
        //Getting the Permission Set Assignment to Delete
        List<PermissionSetAssignment> lstpsa2del = [SELECT Id,AssigneeId, PermissionSetId, PermissionSetGroupId FROM PermissionSetAssignment WHERE AssigneeId IN :mapUserPsgsToDelete.keySet() AND PermissionSetGroupId = null AND PermissionSetId !=null];
        if (!lstpsa2del.isEmpty()) {
            for(PermissionSetAssignment psa2del:lstpsa2del){
                if(mapUserPsgsToDelete.keySet().contains(psa2del.AssigneeId)){
                    for(String psgToRemove:mapUserPsgsToDelete.get(psa2del.AssigneeId)){
                        if(mapPsgPerm.containsKey(psgToRemove)){
                            Set<String> setPS = mapPsgPerm.get(psgToRemove);
                            for(String ps:setPS){
                                if(psa2del.PermissionSetId == mapPermNameId.get(ps)){
                                    lstPermissionSetAssignmentToDelete.add(psa2del);                                
                                }
                            }
                        }
                    }
                }
            } 
        }
        
        //Getting the Managed Package License Assignment to Delete
        List<UserPackageLicense> lstuplRec = [SELECT Id,UserId,PackageLicenseId FROM UserPackageLicense WHERE UserId IN :mapUserPsgsToDelete.keySet() AND PackageLicenseId != null];
        if (!lstuplRec.isEmpty()) {
            for(UserPackageLicense uplRec:lstuplRec){
                if(mapUserPsgsToDelete.keySet().contains(uplRec.UserId)){
                    for(String psgToRemove:mapUserPsgsToDelete.get(uplRec.UserId)){
                        if(mapPsgMpl.containsKey(psgToRemove)){
                            Set<String> setMpl = mapPsgMpl.get(psgToRemove);
                            for(String mpl:setMpl){
                                if(uplRec.PackageLicenseId == mapMplNameId.get(mpl)){
                                    lstUserPackageLicenseToDelete.add(uplRec);                                
                                }
                            }
                        }
                    }
                }
            }
        }
        //<T04> - add the existing User Package License assignment to the delete list for IPS Users
        if(uplList.size() > 0){
            lstUserPackageLicenseToDelete.addAll(uplList);
        }
        //</T04>
        //Getting the Public Group Membership to Delete
        List<GroupMember> lstPsgPublicGroupRec = [SELECT Id,GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN :mapUserPsgsToDelete.keySet() AND GroupId != null];
        if (!lstPsgPublicGroupRec.isEmpty()) {
            for(GroupMember PsgPublicGroupRec:lstPsgPublicGroupRec){
                if(mapUserPsgsToDelete.keySet().contains(PsgPublicGroupRec.UserOrGroupId)){
                    for(String psgToRemove:mapUserPsgsToDelete.get(PsgPublicGroupRec.UserOrGroupId)){
                        if(mapPsgPublicGroup.containsKey(psgToRemove)){
                            Set<String> setGroup= mapPsgPublicGroup.get(psgToRemove);
                            for(String grpName:setGroup){
                                if(PsgPublicGroupRec.GroupId == mapPGNameId.get(grpName)){
                                    lstGroupMemberToDelete.add(PsgPublicGroupRec);                                
                                }
                            }
                        }
                    }
                }
            }
        }
        //Delete operation - start
        //Deleting Permission set group
        if (!lstPermissionSetAssignmentToDelete.isEmpty()) {
            Set<PermissionSetAssignment> setPermissionSetAssignmentToDelete = new Set<PermissionSetAssignment>();
            setPermissionSetAssignmentToDelete.addAll(lstPermissionSetAssignmentToDelete);
            List<PermissionSetAssignment> fnlLstPermissionSetAssignmentToDelete = new List<PermissionSetAssignment>(setPermissionSetAssignmentToDelete);  
            try{
                Database.DeleteResult[] drList = Database.delete(fnlLstPermissionSetAssignmentToDelete, false);
                for(Integer i=0;i<fnlLstPermissionSetAssignmentToDelete.size();i++){
                    if(!drList[i].isSuccess()){
                        errorId.add(fnlLstPermissionSetAssignmentToDelete[i].AssigneeId); //<T03>
                        createExceptionRecord('UserProvisioningBatch - Error deleting Permission Set Group/Permission Set Assignment', drList[i].getErrors()[0].getMessage() , ' UserId - '+ fnlLstPermissionSetAssignmentToDelete[i].AssigneeId+';PermissionSetGroupId - '+ fnlLstPermissionSetAssignmentToDelete[i].PermissionSetGroupId+';PermissionSetId - '+ fnlLstPermissionSetAssignmentToDelete[i].PermissionSetId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error deleting Permission Set Group/Permission Set Assignment', e.getMessage(), String.join(fnlLstPermissionSetAssignmentToDelete,','));
            }                               
        }
        
        //Deleting Permission Set License
        if (!lstPslAssignmentToDelete.isEmpty()) {
            Set<PermissionSetLicenseAssign> setPslAssignmentToDelete = new Set<PermissionSetLicenseAssign>();
            setPslAssignmentToDelete.addAll(lstPslAssignmentToDelete);
            List<PermissionSetLicenseAssign> FnlLstPslAssignmentToDelete = new List<PermissionSetLicenseAssign>(setPslAssignmentToDelete);    
            try{
                Database.DeleteResult[] drList = Database.delete(FnlLstPslAssignmentToDelete, false);
                for(Integer i=0;i<FnlLstPslAssignmentToDelete.size();i++){
                    if(!drList[i].isSuccess()){
                         errorId.add(FnlLstPslAssignmentToDelete[i].AssigneeId); //<T03>
                        createExceptionRecord('UserProvisioningBatch - Error deleting Permission Set License', drList[i].getErrors()[0].getMessage() , ' AssigneeId - '+ FnlLstPslAssignmentToDelete[i].AssigneeId+';PermissionSetLicenseId - '+ FnlLstPslAssignmentToDelete[i].PermissionSetLicenseId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error deleting Permission Set License', e.getMessage(), String.join(FnlLstPslAssignmentToDelete,','));
            }                               
        }
        //ps
        //Deleting Managed Package License
        if (!lstUserPackageLicenseToDelete.isEmpty()) {
            Set<UserPackageLicense> setUserPackageLicenseToDelete = new Set<UserPackageLicense>();
            setUserPackageLicenseToDelete.addAll(lstUserPackageLicenseToDelete);
            List<UserPackageLicense> fnlLstUserPackageLicenseToDelete = new List<UserPackageLicense>(setUserPackageLicenseToDelete);    
            try{
                Database.DeleteResult[] drList = Database.delete(fnlLstUserPackageLicenseToDelete, false);
                for(Integer i=0;i<fnlLstUserPackageLicenseToDelete.size();i++){
                    if(!drList[i].isSuccess()){
                        errorId.add(fnlLstUserPackageLicenseToDelete[i].UserId); //<T03>
                        createExceptionRecord('UserProvisioningBatch - Error deleting Managed Package License', drList[i].getErrors()[0].getMessage() , ' UserId - '+ fnlLstUserPackageLicenseToDelete[i].UserId+';PackageId - '+ fnlLstUserPackageLicenseToDelete[i].PackageLicenseId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error deleting Managed Package License', e.getMessage(), String.join(fnlLstUserPackageLicenseToDelete,','));
            }                               
        }
        
        //Deleting users from public group
        if (!lstGroupMemberToDelete.isEmpty()) {
            Set<GroupMember> setGroupMemberToDelete = new Set<GroupMember>();
            setGroupMemberToDelete.addAll(lstGroupMemberToDelete);
            List<GroupMember> fnlLstGroupMemberToDelete = new List<GroupMember>(setGroupMemberToDelete); 
            try{
                Database.DeleteResult[] drList = Database.delete(fnlLstGroupMemberToDelete, false);
                for(Integer i=0;i<fnlLstGroupMemberToDelete.size();i++){
                    if(!drList[i].isSuccess()){
                        createExceptionRecord('UserProvisioningBatch - Error Deleting users from public group', drList[i].getErrors()[0].getMessage() , ' UserOrGroupId - '+ fnlLstGroupMemberToDelete[i].UserOrGroupId+';GroupId - '+ fnlLstGroupMemberToDelete[i].GroupId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error deleting users from public group', e.getMessage(), String.join(fnlLstGroupMemberToDelete,','));
            }                               
        } 
        //Delete operation - end
        //--------------------<T01/>
        //Assigning Managed Package License
        if (!lstUserPackageLicenseToInsert.isEmpty()) {
            try{
                Database.SaveResult[] srList = Database.insert(lstUserPackageLicenseToInsert, false);
                for(Integer i=0;i<lstUserPackageLicenseToInsert.size();i++){
                    if(!srList[i].isSuccess()){
                        errorId.add(lstUserPackageLicenseToInsert[i].UserId); //<T03>
                        createExceptionRecord('UserProvisioningBatch - Error assigning Managed Package License', srList[i].getErrors()[0].getMessage() , ' UserId - '+ lstUserPackageLicenseToInsert[i].UserId+';PackageId - '+ lstUserPackageLicenseToInsert[i].PackageLicenseId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error assigning Managed Package License', e.getMessage(), String.join(lstUserPackageLicenseToInsert,','));
            }                               
        }
        
       //Assigning Permission Set License
        if (!lstPslAssignmentToInsert.isEmpty()) {
            Set<PermissionSetLicenseAssign> setPslAssignmentToInsert = new Set<PermissionSetLicenseAssign>();
            setPslAssignmentToInsert.addAll(lstPslAssignmentToInsert);
            List<PermissionSetLicenseAssign> fnlLstPslAssignmentToInsert = new List<PermissionSetLicenseAssign>(setPslAssignmentToInsert); 
            try{
                Database.SaveResult[] srList = Database.insert(fnlLstPslAssignmentToInsert, false);
                for(Integer i=0;i<fnlLstPslAssignmentToInsert.size();i++){
                    if(!srList[i].isSuccess()){
                        errorId.add(lstUserPackageLicenseToInsert[i].UserId); //<T03>
                        createExceptionRecord('UserProvisioningBatch - Error assigning Permission Set License', srList[i].getErrors()[0].getMessage() , ' UserId - '+ fnlLstPslAssignmentToInsert[i].AssigneeId+';PermissionSetLicenseId - '+ fnlLstPslAssignmentToInsert[i].PermissionSetLicenseId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error assigning Permission Set License', e.getMessage(), String.join(fnlLstPslAssignmentToInsert,','));
            }                               
        }
        
        //<T01>--------------------------------------
        Set<PermissionSetAssignment> setPermissionSetAssignmentToInsert = new Set<PermissionSetAssignment>();
        //to validate mpls and psls are inserted
        if (!lstPermissionSetAssignmentToInsert.isEmpty()) {
            setPermissionSetAssignmentToInsert.addAll(lstPermissionSetAssignmentToInsert);
            Set<Id> setuserId = new Set<Id>(); //set of userids
            //creating set of users with permission set group/ Permission set request
            for(PermissionSetAssignment PermissionSetAssignmentToInsert:lstPermissionSetAssignmentToInsert){
                setuserId.add(PermissionSetAssignmentToInsert.AssigneeId);
            }
            //List of UserPackageLicenses(mpl) associated with users with permission set group/ Permission set request
            List<UserPackageLicense> lstUserPackageLicense= [SELECT Id,UserId,PackageLicenseId FROM UserPackageLicense WHERE UserId IN :setuserId];  //mpl records
            //List of PermissionSetLicenseAssign(psl) associated with users with permission set group/ Permission set request
            List<PermissionSetLicenseAssign> lstPermissionSetLicenseAssign= [SELECT Id,AssigneeId,PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId IN :setuserId];  //psl records
            
            //List of PermissionSetGroup associated with all Add-on requests 
           // List<PermissionSetGroup> lstpsg = [SELECT Id,DeveloperName,MasterLabel FROM PermissionSetGroup WHERE DeveloperName IN :mapPsgPermGroup.values()]; /<T03>
             List<PermissionSetGroup> lstpsg = [SELECT Id,DeveloperName,MasterLabel FROM PermissionSetGroup WHERE DeveloperName IN :setPermGrpSet];  //<T03>
            //List of PermissionSet associated with all Add-on requests 
            List<PermissionSet> lstPermissionSet= [SELECT Id,Name,PermissionSetGroupId FROM PermissionSet WHERE Name IN :setPermSet AND PermissionSetGroupId=null];
            
            for(PermissionSetAssignment PermissionSetAssignmentToInsert:lstPermissionSetAssignmentToInsert){   
                String psname;   //variable to store Permission name
                String psgname;   //variable to store Permission Set Group name
                if(PermissionSetAssignmentToInsert.PermissionSetId!=null || PermissionSetAssignmentToInsert.PermissionSetGroupId!=null){
                    for(PermissionSet ps:lstPermissionSet){
                        //Getting the permission Set name 
                        if(PermissionSetAssignmentToInsert.PermissionSetId==ps.Id ){
                            psname = ps.Name;
                        }
                    }
                    for(PermissionSetGroup psg:lstpsg){
                        //Getting the permission Set Group name 
                        if(PermissionSetAssignmentToInsert.PermissionSetGroupId==psg.Id ){
                            psgname = psg.DeveloperName;
                        }
                    }
                    //Add all permission sets from single PermissionSetAssignmentToInsert record to Set
                    for(User_provisioning_Approver_Matrix__mdt permissionInfo:lstPermissionsInfo){
                        //Set of permission Set Groups
                        Set<String> setPsg = new Set<String>();  
                        //Set of permission Sets
                        Set<String> setPS = new Set<String>();
                        if(mapUserPsgsToAssign.containsKey(PermissionSetAssignmentToInsert.AssigneeId)){
                            Set<String> psgToAsgn4User = new Set<String>();
                            psgToAsgn4User = mapUserPsgsToAssign.get(PermissionSetAssignmentToInsert.AssigneeId);
                            if(psgToAsgn4User.contains(permissionInfo.Label)){                              
                                if(String.isNotBlank(permissionInfo.Permission_Set_Name__c)){
                                    //Add all permission sets from single  User_provisioning_Approver_Matrix__mdt  record to Set
                                    setPS.addAll(permissionInfo.Permission_Set_Name__c.split(';'));
                                }
                                if(String.isNotBlank(permissionInfo.Permission_Set_Group__c)){
                                    //Add all permission sets from single  User_provisioning_Approver_Matrix__mdt  record to Set
                                    setPsg.addAll(permissionInfo.Permission_Set_Group__c.split(';'));
                                }
                                
                                if(setPS.contains(psname) || setPsg.contains(psgname) ){
                                    Integer mplcount=0;       //variable to check each and every mpl related to the PermissionSetAssignmentToInsert record are inserted
                                    Integer pslcount=0;       //variable to check each and every psl related to the PermissionSetAssignmentToInsert record are inserted
                                    //for all mpl related to single PermissionSetAssignmentToInsert record
                                    Set<String> setMpl = new Set<String>();
                                    if(mapPsgMpl.containsKey(permissionInfo.Label)){
                                        //collect all mpls related to single PermissionSetAssignmentToInsert record in Set
                                        setMpl = mapPsgMpl.get(permissionInfo.Label);
                                        for(String mpl:setMpl){
                                            for(UserPackageLicense upl:lstUserPackageLicense){
                                                if(upl.UserId ==PermissionSetAssignmentToInsert.AssigneeId && upl.PackageLicenseId == mapMplNameId.get(mpl))
                                                {
                                                    mplcount++;
                                                } 
                                            }
                                        }    
                                    }
                                    
                                    //for all mpl related to single PermissionSetAssignmentToInsert record
                                    Set<String> setPsl = new Set<String>();
                                    if(mapPsgPsl.containsKey(permissionInfo.Label)){
                                        //collect all psls related to single PermissionSetAssignmentToInsert record in Set
                                        setPsl = mapPsgPsl.get(permissionInfo.Label);
                                        for(String psl:setPsl){
                                            for(PermissionSetLicenseAssign psla:lstPermissionSetLicenseAssign){
                                                if(psla.AssigneeId ==PermissionSetAssignmentToInsert.AssigneeId && psla.PermissionSetLicenseId == mapPslNameId.get(psl))
                                                {
                                                    pslcount++;
                                                } 
                                            }                           
                                        }
                                    }
                                    //if mpl or psl is not inserted for the PermissionSetAssignmentToInsert record remove that record from Set To Insert
                                    if(setPsl.size()!=pslcount || setMpl.size()!=mplcount ){
                                        if(setPermissionSetAssignmentToInsert.contains(PermissionSetAssignmentToInsert)){
                                            setPermissionSetAssignmentToInsert.remove(PermissionSetAssignmentToInsert);
                                        }
                                    }
                                }
                            }         
                        }
                    }  
                }
            }
        }
        
        //---------------------------------------<T01>
        //Assigning Permission set group and/or Permission Set
        if (!setPermissionSetAssignmentToInsert.isEmpty()) {
            List<PermissionSetAssignment> fnlLstPermissionSetAssignmentToInsert = new List<PermissionSetAssignment>(setPermissionSetAssignmentToInsert);  
            try{
                Database.SaveResult[] srList = Database.insert(fnlLstPermissionSetAssignmentToInsert, false);
                //<T03>
                for(Integer i=0;i<fnlLstPermissionSetAssignmentToInsert.size();i++){
                    if(!srList[i].isSuccess()){
                        errorId.add(fnlLstPermissionSetAssignmentToInsert[i].AssigneeId);
                       }
                }
                //<T03> Ends                
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error assigning Permission Set Group/Permission Set', e.getMessage(), String.join(fnlLstPermissionSetAssignmentToInsert,','));                
            }                               
        }
        
        //Adding users to public group
        if (!lstGroupMemberToInsert.isEmpty()) {
            try{
                Database.SaveResult[] srList = Database.insert(lstGroupMemberToInsert, false);
                for(Integer i=0;i<lstGroupMemberToInsert.size();i++){
                    if(!srList[i].isSuccess()){
                        createExceptionRecord('UserProvisioningBatch - Error adding user to the Public Group', srList[i].getErrors()[0].getMessage() , ' UserId - '+ lstGroupMemberToInsert[i].UserOrGroupId+';GroupId - '+ lstGroupMemberToInsert[i].GroupId);
                    }
                }
            }catch(Exception e){
                createExceptionRecord('UserProvisioningBatch.execute - Error adding user to the Public Group', e.getMessage(), String.join(lstGroupMemberToInsert,','));
            }                               
        }
        //Updating user role
        if(!lstUserRoletoUpdate.isEmpty()){
            System.enqueueJob(new UserProvisioningRoleUpdate(lstUserRoletoUpdate,setPermissionRequestId));
        } 
    }

    global void createExceptionRecord(String CausedFrom, String ErrorMessage, String RecordId){
        Exceptions_Log__c ls = new Exceptions_Log__c();
        ls.System_Message__c     = ErrorMessage != null ? ErrorMessage : '';
        ls.Caused_From__c        = CausedFrom != null ? CausedFrom : '';
        ls.Record_Id__c          = RecordId != null ? RecordId : '';
        ls.Exception_Debug__c    = 'Exception';
        lstExceptionLog.add(ls);
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(!setPSAsigneeId.isEmpty()){
            // List<Add_On_Permission_Request__c> lstPermissionAssigned = new List<Add_On_Permission_Request__c>();
            List<Add_On_Permission_Request__c> lstPermissionAssigned = new List<Add_On_Permission_Request__c>();
            List<PermissionSetAssignment> lstPermissionSetAssignmentInserted = [SELECT Id,AssigneeId,PermissionSetGroupId,PermissionSetGroup.DeveloperName, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :setPSAsigneeId];
            Set<Id> setParentRequestId = new Set<Id>();
            
            for(PermissionSetAssignment psga:lstPermissionSetAssignmentInserted){
                Add_On_Permission_Request__c permissionRequest = new Add_On_Permission_Request__c(Permission_Assigned__c = true);
                //<T01>--------------------------
                if(String.isNotBlank(psga.PermissionSetGroupId) && mapPermissionRequestId.containsKey(psga.AssigneeId+psga.PermissionSetGroup.DeveloperName)){
                    Id permissionRequestId = mapPermissionRequestId.get(psga.AssigneeId+psga.PermissionSetGroup.DeveloperName);
                    permissionRequest.Id = permissionRequestId;
                    if(mapPRParentRole.containsKey(permissionRequestId)){
                        permissionRequest.Approval_Status__c = 'Approved';
                        setParentRequestId.add(mapPRParentRole.get(permissionRequestId).Parent_Role__c);
                    }
                    lstPermissionAssigned.add(permissionRequest); 
                }
                else if(mapPermissionRequestId.containsKey(psga.AssigneeId+psga.PermissionSet.Name)){
                    Id permissionRequestId = mapPermissionRequestId.get(psga.AssigneeId+psga.PermissionSet.Name);
                    permissionRequest.Id = permissionRequestId;
                    if(mapPRParentRole.containsKey(permissionRequestId)){
                        permissionRequest.Approval_Status__c = 'Approved';
                        setParentRequestId.add(mapPRParentRole.get(permissionRequestId).Parent_Role__c);
                    }
                    lstPermissionAssigned.add(permissionRequest);
                }
                //------------------------------<T01>
            }
            if(!lstPermissionAssigned.isEmpty()){
                try{
                    Database.SaveResult[] lstSaveResult = Database.update(lstPermissionAssigned, false);

                    if(!setParentRequestId.isEmpty()){
                        try{                            
                            List<AggregateResult> lstParentRequestAggregate = [SELECT Parent_Role__c,count(Id) REC_COUNT FROM Add_On_Permission_Request__c WHERE Parent_Role__c IN :setParentRequestId AND Permission_Assigned__c = false GROUP BY Parent_Role__c];
                            List<Add_On_Permission_Request__c> lstParentRequestToUpdate = new List<Add_On_Permission_Request__c>();
                            for(AggregateResult res:lstParentRequestAggregate){
                                setParentRequestId.remove((Id)res.get('Parent_Role__c'));
                            }

                            if(!setParentRequestId.isEmpty()){
                                for(Id parentRoleId:setParentRequestId){
                                    Add_On_Permission_Request__c parentRec = new Add_On_Permission_Request__c(Permission_Assigned__c = true,Id = parentRoleId);                                    
                                    lstParentRequestToUpdate.add(parentRec);
                                }
                            }

                            Database.SaveResult[] lstSaveResultParent = Database.update(lstParentRequestToUpdate, false);
    
                        }catch(Exception e){
                              createExceptionRecord('UserProvisioningBatch.finish - Error updating Parent Role Permission Request records', e.getMessage(), String.join(lstPermissionAssigned,','));
                        }
                    }                    
                }catch(Exception e){
                    createExceptionRecord('UserProvisioningBatch.finish - Error updating Permission Request records', e.getMessage(), String.join(lstPermissionAssigned,','));
                }
            }                  
        }
        //<T03>
        // Update License Module status field for Assignment and Removal
        List<Add_On_Permission_Request__c> lstPermRequestToUpdate = new List<Add_On_Permission_Request__c>();
        if(!mapLicenseRequestId.isEmpty()){
            List<Add_On_Permission_Request__c> permRequests = [Select Id,License_Action__c,License_Request_Status__c from Add_On_Permission_Request__c where Id IN:mapLicenseRequestId.keySet()];
            for(Add_On_Permission_Request__c eachPerm : permRequests){
                if(errorId.contains(mapLicenseRequestId.get(eachPerm.Id))){
                     eachPerm.License_Request_Status__c = 'Error - Failed to run';
                }
                else if(!errorId.contains(mapLicenseRequestId.get(eachPerm.Id)) && eachPerm.License_Action__c == 'License Assignment'){
                     eachPerm.License_Request_Status__c = 'Permission Assigned';
                }
                else if(!errorId.contains(mapLicenseRequestId.get(eachPerm.Id)) && eachPerm.License_Action__c == 'License Removal'){
                     eachPerm.License_Request_Status__c = 'Permission Removed';
                }
                lstPermRequestToUpdate.add(eachPerm);
            }
        }
        try{
          Database.SaveResult[] lstSaveResultParent = Database.update(lstPermRequestToUpdate, false);
        }catch(Exception e){
             createExceptionRecord('UserProvisioningBatch.finish - Error updating Permission Request Status', e.getMessage(),'lstPermRequestToUpdate');
         }
        //<T03> ends
        //Inserting Exception Logs - Logic added in finish method as the DML of non-setup object not allowed in execute method
        if(!lstExceptionLog.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lstExceptionLog, false);
        }
    }
    
    global void execute(SchedulableContext ctx){                
        //Create a new Instance of the Class UserProvisioningBatch
        UserProvisioningBatch assignPSGBatch = new UserProvisioningBatch();
        database.executebatch(assignPSGBatch,200);
    }
}