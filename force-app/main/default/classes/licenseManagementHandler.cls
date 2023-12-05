/*
Class:          licenseManagementHandler
@Author:        Sreerekha
@Created Date:  09 June 2023
@Description:   Controller class for licenseAssignment LWC component - Used on User Provisioing App
*/
public with sharing class licenseManagementHandler {
    
    public static String userDepartment;
    public static globalApexManager GAM = new globalApexManager();
    public static String useId = UserInfo.getName();
    public static List<string> excludePorfiles = String.valueOf(Label.Profile_Exclude_License_Removal).split(';'); //List of profiles that are to be excluded for License Removal.
    public static List<string> excludeLicenses = String.valueOf(Label.License_Excluse_Removal).split(';'); //List of Licenses that are to be excluded for License Removal.
    /* Method Name : fetchLicensesAssigned
* @param mapNew - userId - Current User FullName
* @return return - List
* @throws exception - NA 
* @description - To fetch licenses assigned to the logged in user as per the metadata
*/
    @AuraEnabled(cacheable=true)
    public static List<String> fetchLicensesAssigned (String userId){
        Set<String> LicensesAvailable = new Set<String>();
       try{
            List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix = new List<User_provisioning_Approver_Matrix__mdt>();
            List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix1 = [SELECT Id,Label,Department__c,License__c,Approver_1_Name__c,Approver_2_Name__c  FROM User_provisioning_Approver_Matrix__mdt WHERE Approver_1_Name__c  =:userId and License__c!= null];
            List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix2 = [SELECT Id,Label,Department__c,License__c,Approver_1_Name__c,Approver_2_Name__c  FROM User_provisioning_Approver_Matrix__mdt WHERE Approver_2_Name__c  =:userId and License__c!= null];
            if(lstApproverMatrix1.size()>0){
                lstApproverMatrix.addAll(lstApproverMatrix1);
            }       
            if(lstApproverMatrix2.size()>0){
                lstApproverMatrix.addAll(lstApproverMatrix2);
            }  
            for(User_provisioning_Approver_Matrix__mdt approverMatrix:lstApproverMatrix){
                Set<String> setLicense = new Set<String>();
                
                if(String.isNotBlank(approverMatrix.License__c)){
                    setLicense.addAll(approverMatrix.License__c.split(';'));
                    LicensesAvailable.addAll(setLicense);
                }                
            } 
            LicensesAvailable.removeAll(excludeLicenses);
            List<String> lstLicensesAvailable = new List<String>(LicensesAvailable);
            lstLicensesAvailable.sort();
            return lstLicensesAvailable;}
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    /* Method Name : fetchAllLicensesAvailable
* @param mapNew - NA
* @return return - List
* @throws exception - NA 
* @description - To fetch licenses available in the org
*/
    @AuraEnabled(cacheable=true)
    public static List<String> fetchAllLicensesAvailable (){
        Set<String> LicensesAvailable = new Set<String>();
        Set<String> setMpl = new Set<String>();
        Set<String> setPsl = new Set<String>();
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix = [SELECT Id,Label,Department__c,Managed_Package_License__c,Permission_Set_License__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label ='All Available Licenses' LIMIT 1];
        
        if(String.isNotBlank(lstApproverMatrix[0].Managed_Package_License__c)){
            setMpl.addAll(lstApproverMatrix[0].Managed_Package_License__c.split(';'));
            LicensesAvailable.addAll(setMpl);
        }
        if(String.isNotBlank(lstApproverMatrix[0].Permission_Set_License__c)){
            setPsl.addAll(lstApproverMatrix[0].Permission_Set_License__c.split(';'));
            LicensesAvailable.addAll(setPsl); 
        }
        List<String> lstLicensesAvailable = new List<String>(LicensesAvailable);
        lstLicensesAvailable.sort();
        return lstLicensesAvailable;
        
    }
    /* Method Name : fetchBusinessRoles
* @param mapNew - userId - Current User FullName
* @return return - List
* @throws exception - NA 
* @description - To fetch Business Roles Assigned to the user
*/
    @AuraEnabled(cacheable=true)
    public static List<String> fetchBusinessRoles (String userId){
        
        Set<String> setLicense = new Set<String>();
        
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix = new List<User_provisioning_Approver_Matrix__mdt>();
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix1 = [SELECT Id,Label,Approver_1_Name__c,Approver_2_Name__c,Addon_License_Role__c  FROM User_provisioning_Approver_Matrix__mdt WHERE Approver_1_Name__c  =:userId and Addon_License_Role__c = True];
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix2 = [SELECT Id,Label,Approver_1_Name__c,Approver_2_Name__c,Addon_License_Role__c  FROM User_provisioning_Approver_Matrix__mdt WHERE Approver_2_Name__c  =:userId and Addon_License_Role__c = True];
        if(lstApproverMatrix1.size()>0){
            lstApproverMatrix.addAll(lstApproverMatrix1);
        }       
        if(lstApproverMatrix2.size()>0){
            lstApproverMatrix.addAll(lstApproverMatrix2);
        }    
        for(User_provisioning_Approver_Matrix__mdt approverMatrix:lstApproverMatrix){
            
            if(String.isNotBlank(approverMatrix.Label)){
                setLicense.add(approverMatrix.Label);
            }
            
        }
        
        List<String> lstLicensesAvailable = new List<String>(setLicense);
        lstLicensesAvailable.sort();
        return lstLicensesAvailable;
        
    }
    
    /* Method Name : fetchUsersList
* @param mapNew - License - Selected License Name
* @return return - List
* @throws exception - NA 
* @description - TO fetch the users associated with the License selected for Removal
*/
    @AuraEnabled(cacheable=false)
    public static List<User> fetchUsersList (String License, String userId){
        Set<String> userRecId = new Set<String>();
        Set<String> setMpl = new Set<String>();
        Set<String> setPsl = new Set<String>();
        List<UserPackageLicense> mplUsers = new List<UserPackageLicense>();
        List<PermissionSetLicenseAssign> pslUsers = new List<PermissionSetLicenseAssign>();
        try{
        User_provisioning_Approver_Matrix__mdt matrix = [SELECT Id,Label,DeveloperName,Department__c,Permission_Set_Group__c,Managed_Package_License__c,Permission_Set_License__c,Permission_Set_Name__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label =:License limit 1];
       /* if(String.isNotBlank(Matrix.Managed_Package_License__c)){
     	   setMpl.addAll(matrix.Managed_Package_License__c.split(';'));
        }
        if(String.isNotBlank(Matrix.Permission_Set_License__c)){
        	setPsl.addAll(matrix.Permission_Set_License__c.split(';'));
        }*/
        User logInUser = [Select Id,Department from User where Id =:userId];
        if(logInUser.Department != null && logInUser.Department.contains ('IT ')){
            userDepartment = 'IT' + '%';
            mplUsers = [Select Id, UserId, PackageLicenseId, PackageLicense.NamespacePrefix from UserPackageLicense where PackageLicense.NamespacePrefix =:matrix.DeveloperName  and User.Profile.Name NOT IN :excludePorfiles and User.Department LIKE :userDepartment];
            pslUsers = [Select id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.DeveloperName from PermissionSetLicenseAssign where PermissionSetLicense.DeveloperName =:matrix.DeveloperName and Assignee.Profile.Name NOT IN :excludePorfiles and Assignee.Department Like :userDepartment];
        } 
        else{
            userDepartment = 'IT' + '%';
            mplUsers = [Select Id, UserId, PackageLicenseId, PackageLicense.NamespacePrefix from UserPackageLicense where PackageLicense.NamespacePrefix =:matrix.DeveloperName  and User.Profile.Name NOT IN :excludePorfiles and (NOT User.Department LIKE :userDepartment)];
            pslUsers = [Select id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.DeveloperName from PermissionSetLicenseAssign where PermissionSetLicense.DeveloperName =:matrix.DeveloperName and Assignee.Profile.Name NOT IN :excludePorfiles and (NOT Assignee.Department Like :userDepartment)];
        }
        
        if(mplUsers.size()>0){
            for (UserPackageLicense muser : mplUsers){
                userRecId.add(muser.UserId);
            } 
        }
        if(pslUsers.size()>0){
            for(PermissionSetLicenseAssign puser : pslUsers){
                userRecId.add(puser.AssigneeId);                
            }
        }
           }
        catch (Exception e) {
            system.debug(e.getMessage());
        }
         List<Schema.FieldSetMember> fieldSetList = SObjectType.User.FieldSets.LicenseProvisioningUser.getFields();
        String queryString = 'SELECT Id';
        for (Schema.FieldSetMember fieldSet : fieldSetList) {
            queryString += ',' + fieldSet.getFieldPath();
        }
        queryString += ' FROM User WHERE ID IN :userRecId';
         return (List<User>)Database.query(queryString);
    }

    /* Method Name : fetchUsersForLicense
* @param mapNew - License - Selected License Name
* @return return - List
* @throws exception - NA 
* @description - TO fetch the users associated with the License selected for Report
*/
    @AuraEnabled(cacheable=false)
    public static List<User> fetchUsersForLicense (String License){
        Set<String> userRecId = new Set<String>();
        List<UserPackageLicense> mplUsers = new List<UserPackageLicense>();
        List<PermissionSetLicenseAssign> pslUsers = new List<PermissionSetLicenseAssign>();
        User_provisioning_Approver_Matrix__mdt matrix = [SELECT Id,Label,DeveloperName, Department__c,Permission_Set_Group__c,Managed_Package_License__c,Permission_Set_License__c,Permission_Set_Name__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label =:License limit 1];
            
        mplUsers = [Select Id, UserId, PackageLicenseId, PackageLicense.NamespacePrefix from UserPackageLicense where PackageLicense.NamespacePrefix =: matrix.DeveloperName  and User.Profile.Name NOT IN :excludePorfiles];
        pslUsers = [Select id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.DeveloperName from PermissionSetLicenseAssign where PermissionSetLicense.DeveloperName =: matrix.DeveloperName and Assignee.Profile.Name NOT IN :excludePorfiles];
        
        if(mplUsers.size()>0){
            for (UserPackageLicense muser : mplUsers){
                userRecId.add(muser.UserId);
            } 
        }
        if(pslUsers.size()>0){
            for(PermissionSetLicenseAssign puser : pslUsers){
                userRecId.add(puser.AssigneeId);                
            }
        }
        
        List<Schema.FieldSetMember> fieldSetList = SObjectType.User.FieldSets.LicenseProvisioningUser.getFields();
        String queryString = 'SELECT Id';
        for (Schema.FieldSetMember fieldSet : fieldSetList) {
            queryString += ',' + fieldSet.getFieldPath();
        }
        queryString += ' FROM User WHERE ID IN :userRecId';
        return (List<User>)Database.query(queryString);
        
    }
    
    /* Method Name : fetchAllUsersList
* @param mapNew - userId - Current User FullName
* @return return - List
* @throws exception - NA 
* @description - To fetch all the activated users for Assignment
*/
    @AuraEnabled(cacheable=false)
    public static List<User> fetchAllUsersList (String userId){
        
        List <User> activeUsers = [Select Id,name from User where IsActive = true and UserType ='Standard' order by Name];
        
        List<Schema.FieldSetMember> fieldSetList = SObjectType.User.FieldSets.LicenseProvisioningUser.getFields();
        String queryString = 'SELECT Id';
        for (Schema.FieldSetMember fieldSet : fieldSetList) {
            queryString += ',' + fieldSet.getFieldPath();
        }
        queryString += ' FROM User WHERE ID IN :activeUsers order by Name';
        return (List<User>)Database.query(queryString);
    }
    /* Method Name : getRemovalLicenseReport
* @param mapNew - userIds, Selected License, Type of Action, userId - Current User Id
* @return return - NA
* @throws exception - NA 
* @description - To create User Provisioning request for Removal
*/
    public class LicenseRemovalRec{
        @AuraEnabled public Integer AllowedLicenses;
        @AuraEnabled public Integer UsedLicenses;
        @AuraEnabled public Integer SelectedLicenses;
        @AuraEnabled public String License;        
    }
    
    @auraEnabled
    public static List<LicenseRemovalRec> getRemovalLicenseReport ( String License){
        List<LicenseRemovalRec> lstLicenseRemovalRec = new List<LicenseRemovalRec>();
        User_provisioning_Approver_Matrix__mdt matrix = [Select Id,Label,DeveloperName, Managed_Package_License__c, Permission_Set_License__c from User_provisioning_Approver_Matrix__mdt where label =:License LIMIT 1];
        if(matrix.Managed_Package_License__c != null){
            PackageLicense plRec = [Select id,AllowedLicenses, UsedLicenses, NamespacePrefix  from PackageLicense where NamespacePrefix =:matrix.DeveloperName Limit 1];
            LicenseRemovalRec request= new LicenseRemovalRec();
            request.AllowedLicenses = plRec.AllowedLicenses;
            request.UsedLicenses = plRec.UsedLicenses;
            request.License = License;
            lstLicenseRemovalRec.add(request);
        }
        else if(matrix.Permission_Set_License__c != null){
            
            PermissionSetLicense pslRec=  [SELECT Id,MasterLabel,TotalLicenses,DeveloperName, UsedLicenses FROM PermissionSetLicense where DeveloperName =:matrix.DeveloperName limit 1];
            LicenseRemovalRec request= new LicenseRemovalRec();
            request.AllowedLicenses = pslRec.TotalLicenses;
            request.UsedLicenses = pslRec.UsedLicenses;
            request.License = License;
            lstLicenseRemovalRec.add(request);
        }
        return lstLicenseRemovalRec;
        
    }
    
    /* Method Name : getAssignLicenseReport
* @param mapNew - userIds, Selected License, Type of Action, userId - Current User Id
* @return return - NA
* @throws exception - NA 
* @description - To create User Provisioning request for Removal
*/
    public class LicenseAssignRec{
        @AuraEnabled public Integer AllowedLicenses;
        @AuraEnabled public Integer UsedLicenses;
        @AuraEnabled public String License;        
    }
    
    @auraEnabled
    public static List<LicenseAssignRec> getAssignLicenseReport (String Role, String userId){
        List<LicenseAssignRec> lstLicenseAssignRec = new List<LicenseAssignRec>();
        Set<String> setMpl = new Set<String>();
        Set<String> setPsl = new Set<String>();
        Set<String> License = new Set<String>();
        Map<String,String> mapLicenseName = new Map<String,String>();
        
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix = new List<User_provisioning_Approver_Matrix__mdt>();
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix1 = [SELECT Id,Label, License__c,Department__c,Managed_Package_License__c, Permission_Set_License__c,Approver_1_Name__c,Approver_2_Name__c  FROM User_provisioning_Approver_Matrix__mdt WHERE Approver_1_Name__c  =:userId and Label =:Role];
        List<User_provisioning_Approver_Matrix__mdt>  lstApproverMatrix2 = [SELECT Id,Label, License__c,Department__c,Managed_Package_License__c, Permission_Set_License__c,Approver_1_Name__c,Approver_2_Name__c FROM User_provisioning_Approver_Matrix__mdt WHERE Approver_2_Name__c  =:userId and Label =:Role];
        
        if(lstApproverMatrix1.size()>0){
            lstApproverMatrix.addAll(lstApproverMatrix1);
        }       
        if(lstApproverMatrix2.size()>0){
            lstApproverMatrix.addAll(lstApproverMatrix2);
        }
        
        if(lstApproverMatrix.size()>0){
            for(User_provisioning_Approver_Matrix__mdt approverMatrix:lstApproverMatrix){                
                
                if(String.isNotBlank(approverMatrix.Managed_Package_License__c)){
                    setMpl.addAll(approverMatrix.Managed_Package_License__c.split(';'));
                    License.addAll(approverMatrix.License__c.split(';'));
                }
                if(String.isNotBlank(approverMatrix.Permission_Set_License__c)){
                    setPsl.addAll(approverMatrix.Permission_Set_License__c.split(';'));
                    License.addAll(approverMatrix.License__c.split(';'));
                }
                
            }}
        
        List<User_provisioning_Approver_Matrix__mdt> licenseMatrix = [Select Id,Label,License__c, Managed_Package_License__c, Permission_Set_License__c from User_provisioning_Approver_Matrix__mdt where License__c IN:License and License_Management_Module__c = true];
        for(User_provisioning_Approver_Matrix__mdt matrix:licenseMatrix){
            if(matrix.Managed_Package_License__c != null){
                mapLicenseName.put(matrix.Managed_Package_License__c,matrix.Label); 
            }else{
                mapLicenseName.put(matrix.Permission_Set_License__c,matrix.Label); 
            }
                     
        }
        if(setMpl.Size()>0){
            List<PackageLicense> plRecs = [Select id,AllowedLicenses, UsedLicenses, NamespacePrefix  from PackageLicense where NamespacePrefix IN : setMpl];
            for(PackageLicense eachPl : plRecs){
                LicenseAssignRec request= new LicenseAssignRec();
                request.AllowedLicenses = eachPl.AllowedLicenses;
                request.UsedLicenses = eachPl.UsedLicenses;
                request.License = mapLicenseName.get(eachPl.NamespacePrefix);
                lstLicenseAssignRec.add(request);
            }
        }
        if(setPsl.Size()>0) {
            List<PermissionSetLicense> pslRecs=  [SELECT Id,MasterLabel,DeveloperName,TotalLicenses, UsedLicenses FROM PermissionSetLicense where DeveloperName IN:setPsl ];
            for(PermissionSetLicense eachPsl : pslRecs){
                LicenseAssignRec request= new LicenseAssignRec();
                request.AllowedLicenses = eachPsl.TotalLicenses;
                request.UsedLicenses = eachPsl.UsedLicenses;
                request.License = mapLicenseName.get(eachPsl.DeveloperName);
                lstLicenseAssignRec.add(request);
            }
        }
        return lstLicenseAssignRec;
        
    }
    
    /* Method Name : createUserProvisioningRemovalReq
* @param mapNew - userIds, Selected License, Type of Action, userId - Current User Id
* @return return - NA
* @throws exception - NA 
* @description - To create User Provisioning request for Removal
*/
    @AuraEnabled
    public static String createUserProvisioningRemovalReq (List<Id> userIds, String License, String Action, String Owner ){
        List<User_Provisioning_Request__c> lstUserProvRequest = new List<User_Provisioning_Request__c>();
        if(userIds.size()>0 && Action == 'License_Removal'){
            for(Id eachUser : userIds){
                User_Provisioning_Request__c request = new User_Provisioning_Request__c();
                request.Incident__c = '-NA-';
                request.User__c = eachUser;
                request.End_Date__c = system.today();
                request.OwnerId = Owner;
                request.License__c = License;
                request.License_Action__c = 'License Removal';
                lstUserProvRequest.add(request);
            }
        }
        try{
            if(lstUserProvRequest.size()>0){
                Database.SaveResult[] userProvList = Database.insert(lstUserProvRequest, true);  
            }
        }
        catch (Exception e) {
            system.debug('Errir sree--'+e.getMessage()+e.getLineNumber());
            GAM.CreateLogs('licenseManagementHandler.createUserProvisioningRemovalReq', lstUserProvRequest, 'lstUserProvRequest');
        }
        licenseManagementHandler.createRemovalRequests(lstUserProvRequest);
        return 'Successfully submitted users for Removal.';
    }
    
    /* Method Name : createUserProvisioningAddReq
* @param mapNew - userIds, Selected Licenses, Business Role, userId- Current UserId
* @return return - NA
* @throws exception - NA 
* @description - To create User Provisioning request for Removal
*/
    @AuraEnabled
    public static String createUserProvisioningAddReq (List<Id> userIds, String License, String Role, String Owner,String Action ){
        List<User_Provisioning_Request__c> lstUserProvAddRequest = new List<User_Provisioning_Request__c>();
        if(userIds.size()>0 && Action == 'License_Assignment'){
            for(Id eachUser : userIds){
                User_Provisioning_Request__c request = new User_Provisioning_Request__c();
                request.Incident__c = '-NA-';
                request.User__c = eachUser;
                request.OwnerId = Owner;
                request.License__c = License;
                request.License_Assignment_Role__c = Role;
                request.License_Action__c = 'License Assignment';
                lstUserProvAddRequest.add(request);
            }
        }
        try{
            if(lstUserProvAddRequest.size()>0){
                Database.SaveResult[] userProvList = Database.insert(lstUserProvAddRequest, true);  
            }
        }
        catch (Exception e) {
            GAM.CreateLogs('licenseManagementHandler.createUserProvisioningAddReq', lstUserProvAddRequest, 'lstUserProvAddRequest');
        }
        licenseManagementHandler.createAddRequests(lstUserProvAddRequest);
        return 'Successfully submitted users for Assignment.';
        
    }
    
    /* Method Name : getFieldLableAndFieldAPI
* @param mapNew - NA
* @return return - NA
* @throws exception - NA 
* @description - To fetch FieldLabels for dataset
*/
    @AuraEnabled
    public static String getFieldLableAndFieldAPI(){        
        try {
            return JSON.serialize(SObjectType.User.FieldSets.LicenseProvisioningUser.getFields());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Method Name : createRemovalRequests
* @param mapNew - List <User_Provisioning_Request__c>
* @return return - NA
* @throws exception - NA 
* @description - To create Permission requests for removal action
*/    
    public static void createRemovalRequests(List<User_Provisioning_Request__c> lstUserProvRequest){
        
        List<Add_On_Permission_Request__c> lstPermissionRequestToInsert = new List<Add_On_Permission_Request__c>();
        
        if(lstUserProvRequest.size()>0){
            for(User_Provisioning_Request__c provisioningRequest :lstUserProvRequest){
                if(provisioningRequest.License__C != null){
                    
                    Add_On_Permission_Request__c request = new Add_On_Permission_Request__c();
                    request.Add_Ons__c = provisioningRequest.License__C;
                    request.User_Provisioning_Request__c = provisioningRequest.Id;
                    request.End_Date__c = provisioningRequest.End_Date__c;
                    request.Incident__c = provisioningRequest.Incident__c;
                    request.Approval_Status__c = 'Approved';
                    request.License_Action__c = 'License Removal';
                    request.License_Request_Status__c = 'In Progress';
                    request.Permission_Assigned__c = true;
                    request.Approver__c = provisioningRequest.OwnerId;
                    lstPermissionRequestToInsert.add(request);
                }            
            }            
        }
        try{
            if(lstPermissionRequestToInsert.Size()>0){
                Database.SaveResult[] userProvList = Database.insert(lstPermissionRequestToInsert, true);
            }           
        }
        catch (Exception e) {
            GAM.CreateLogs('licenseManagementHandler.createRemovalRequests', lstPermissionRequestToInsert, 'lstPermissionRequestToInsert');
        }
    }
    
    /* Method Name : createAddRequests
* @param mapNew - List <User_Provisioning_Request__c>
* @return return - NA
* @throws exception - NA 
* @description - To create Permission requests for assign action
*/
    public static void createAddRequests(List<User_Provisioning_Request__c> lstUserProvAddRequest){
        
        List<Add_On_Permission_Request__c> lstAddPermissionRequestToInsert = new List<Add_On_Permission_Request__c>();
        
        if(lstUserProvAddRequest.size()>0){
            for(User_Provisioning_Request__c provisioningRequest :lstUserProvAddRequest){
                if(provisioningRequest.License__C != null){
                    
                    Add_On_Permission_Request__c request = new Add_On_Permission_Request__c();
                    request.Add_Ons__c = provisioningRequest.License_Assignment_Role__c;
                    request.User_Provisioning_Request__c = provisioningRequest.Id;
                    request.License_Action__c = 'License Assignment';
                    request.Incident__c = provisioningRequest.Incident__c;
                    request.Approval_Status__c = 'Approved';
                    request.License_Request_Status__c = 'In Progress';
                    request.Approver__c = provisioningRequest.OwnerId;                    
                    lstAddPermissionRequestToInsert.add(request);
                }                
            }           
        }
        try{
            if(lstAddPermissionRequestToInsert.Size()>0){
                Database.SaveResult[] userProvList = Database.insert(lstAddPermissionRequestToInsert, true);
            }           
        }
        catch (Exception e) {
            GAM.CreateLogs('licenseManagementHandler.createAddRequests', lstAddPermissionRequestToInsert, 'lstAddPermissionRequestToInsert');
        }
    }
    
    /* Method Name : searchUsers
* @param mapNew - userIds, Selected Licenses, Business Role, userId- Current UserId
* @return return - NA
* @throws exception - NA 
* @description - To create User Provisioning request for Removal
*/
    @AuraEnabled(Cacheable = true)
    public static list<User> searchUsers(String textkey) {
        String  Name = '%' + textkey + '%';
        list<User> lstUser = [SELECT  Id,Name from User WHERE Name LIKE :Name AND Department like:userDepartment];
        
        if(lstUser.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        List<Schema.FieldSetMember> fieldSetList = SObjectType.User.FieldSets.LicenseProvisioningUser.getFields();
        String queryString = 'SELECT Id';
        for (Schema.FieldSetMember fieldSet : fieldSetList) {
            queryString += ',' + fieldSet.getFieldPath();
        }
        queryString += ' FROM User WHERE ID IN :lstUser';
        return (List<User>)Database.query(queryString);
    }
    
    /* Method Name : validateSelectedUsers
* @param mapNew - userIds, Business Role
* @return return - NA
* @throws exception - NA 
* @description - To check if selected users already have required access
*/
    public class PermissionRequestRec{
        @AuraEnabled public Id prId;
        @AuraEnabled public String prName;
        @AuraEnabled public String prUserName;
        @AuraEnabled public String prBusinessRole;        
        @AuraEnabled public Boolean isAllLicensesAvailable;
    }
    
    @AuraEnabled(Cacheable = false)
    public static List<PermissionRequestRec> validateSelectedUsers(List<Id> selectedUsers, String BusinessRole) {
        
        List<PermissionRequestRec> lstPermissionRequests = new List<PermissionRequestRec>();
        Map<Id,Boolean> mapUserAccess = new Map<Id,Boolean>();
        List<User> userList = [Select Id, UserName, Name from User where Id IN :selectedUsers];
        User_provisioning_Approver_Matrix__mdt matrix = [SELECT Id,Label,Department__c,Permission_Set_Group__c,Managed_Package_License__c,Permission_Set_License__c,Permission_Set_Name__c,Role_Based_PSGs__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label =:BusinessRole limit 1];
        
        Set<String> setMpl = new Set<String>();
        Set<String> setPsl = new Set<String>();
        Set<String> setPsg = new Set<String>();
        Set<String> setPs = new Set<String>();
        
        if(String.isNotBlank(matrix.Managed_Package_License__c)){
            setMpl.addAll(matrix.Managed_Package_License__c.split(';'));                
        }
        
        if(String.isNotBlank(matrix.Permission_Set_License__c)){
            setPsl.addAll(matrix.Permission_Set_License__c.split(';'));
        }
        if(String.isNotBlank(matrix.Permission_Set_Group__c)){
            setPsg.addAll(matrix.Permission_Set_Group__c.split(';'));                
        }
        
        if(String.isNotBlank(matrix.Permission_Set_Name__c)){
            setPs.addAll(matrix.Permission_Set_Name__c.split(';'));
        }
        
        //Creating a map of Managed Package License Name and Id
        Map<String, List<Id>> mapMplUsers = new Map<String, List<Id>>();
        if(!setMpl.isEmpty()){
            List<UserPackageLicense> lstPackageLicense= [SELECT Id,UserId,PackageLicenseId,PackageLicense.NamespacePrefix FROM UserPackageLicense WHERE UserId IN :selectedUsers AND PackageLicenseId != null AND PackageLicense.NamespacePrefix IN:setMpl];
            for(UserPackageLicense mpl:lstPackageLicense){
                if(mapMplUsers.ContainsKey(mpl.PackageLicense.NamespacePrefix)){
                    mapMplUsers.get(mpl.PackageLicense.NamespacePrefix).add(mpl.UserId);
                }else{
                    List<Id> mplUsers = new List<Id>();
                    mplUsers.add(mpl.UserId);
                    mapMplUsers.put(mpl.PackageLicense.NamespacePrefix,mplUsers);
                }                
            }
        }        
        //Creating a map of Permission Set License Name and Id
        Map<String, List<Id>> mapPslUsers = new Map<String, List<Id>>();
        if(!setPsl.isEmpty()){
            List<PermissionSetLicenseAssign> lstpslRec = [SELECT Id,AssigneeId,PermissionSetLicenseId,PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssign WHERE AssigneeId IN :selectedUsers AND PermissionSetLicenseId != null AND PermissionSetLicense.DeveloperName IN:setPsl];
            for(PermissionSetLicenseAssign psl:lstpslRec){
                if(mapPslUsers.ContainsKey(psl.PermissionSetLicense.DeveloperName)){
                    mapPslUsers.get(psl.PermissionSetLicense.DeveloperName).add(psl.AssigneeId);
                }else{
                    List<Id> pslUsers = new List<Id>();
                    pslUsers.add(psl.AssigneeId);
                    mapPslUsers.put(psl.PermissionSetLicense.DeveloperName,pslUsers);
                }    
            }
        }
        //Creating a map of PSG Label and Id
        Map<String, List<Id>> mapPsgUsers = new Map<String, List<Id>>();
        if(!setPsg.isEmpty()){
            List<PermissionSetAssignment> lstPsgRec =[SELECT Id,PermissionSetGroupId, PermissionSetId,AssigneeId,PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId IN :selectedUsers AND PermissionSetGroupId != null AND PermissionSetGroup.DeveloperName IN :setPsg];
            for(PermissionSetAssignment psg:lstPsgRec){
                if(mapPsgUsers.ContainsKey(psg.PermissionSetGroup.DeveloperName)){
                    mapPsgUsers.get(psg.PermissionSetGroup.DeveloperName).add(psg.AssigneeId);
                }else{
                    List<Id> psgUsers = new List<Id>();
                    psgUsers.add(psg.AssigneeId);
                    mapPsgUsers.put(psg.PermissionSetGroup.DeveloperName,psgUsers);
                } 
            }
        }
        //Creating a map of Permission Set Name and Id
        Map<String, List<Id>> mapPermUsers = new Map<String, List<Id>>();
        if(!setPs.isEmpty()){
            List<PermissionSetAssignment> lstPsRec = [SELECT Id,AssigneeId, PermissionSetId, PermissionSetGroupId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :selectedUsers AND PermissionSetGroupId = null AND PermissionSetId !=null AND PermissionSet.Name IN:setPs ];
            for(PermissionSetAssignment permset:lstPsRec){
                if(mapPermUsers.ContainsKey(permset.PermissionSet.Name)){
                    mapPermUsers.get(permset.PermissionSet.Name).add(permset.AssigneeId);
                }else{
                    List<Id> permUsers = new List<Id>();
                    permUsers.add(permset.AssigneeId);
                    mapPermUsers.put(permset.PermissionSet.Name,permUsers);
                } 
            }
        }
        for(Id eachId:selectedUsers){
            mapUserAccess.put(eachId,True);
            
            if(!setMpl.isEmpty() && mapUserAccess.get(eachId)){
                for(String str:setMpl){
                    if(mapMplUsers.get(str) != null && mapMplUsers.get(str).contains(eachId) && mapUserAccess.get(eachId))
                    {
                        mapUserAccess.put(eachId,true);
                    }
                    else{
                        mapUserAccess.put(eachId,false);
                    }
                }                
            }
            if(!setPsl.isEmpty() && mapUserAccess.get(eachId)){
                for(String str:setPsl){
                    if(mapPslUsers.get(str) != null && mapPslUsers.get(str).contains(eachId) && mapUserAccess.get(eachId)){
                        mapUserAccess.put(eachId,true);
                    }
                    else{
                        mapUserAccess.put(eachId,false);
                    }
                }
            }
            if(!setPsg.isEmpty() && mapUserAccess.get(eachId)){
                for(String str:setPsg){
                    if(mapPsgUsers.get(str) != null && mapPsgUsers.get(str).contains(eachId) && mapUserAccess.get(eachId)){
                        mapUserAccess.put(eachId,true);
                    }
                    else{
                        mapUserAccess.put(eachId,false);
                    }
                }
            }
            if(!setPs.isEmpty() && mapUserAccess.get(eachId)){
                for(String str:setPs){
                    if(mapPermUsers.get(str) != null && mapPermUsers.get(str).contains(eachId)&& mapUserAccess.get(eachId)){
                        mapUserAccess.put(eachId,true);
                    }
                    else{
                        mapUserAccess.put(eachId,false);
                    }
                }
            }
            
        } 
        
        for(User usLst :userList){    
            PermissionRequestRec request= new PermissionRequestRec();
            request.prUserName = usLst.userName;
            request.prName = usLst.Name;
            request.prId = usLst.Id;
            request.prBusinessRole = BusinessRole;
            request.isAllLicensesAvailable = mapUserAccess.get(usLst.Id);
            lstPermissionRequests.add(request);
        }
        return lstPermissionRequests;
        
    }    
    
}