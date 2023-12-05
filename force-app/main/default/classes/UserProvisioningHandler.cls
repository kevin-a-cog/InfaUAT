/*
Class:          UserProvisioningHandler
@Author:        Chandana Gowda
@Created Date:  3 Oct 2021
@Description:   Class used to create permission set requests from the user provisioning request submitted
@Test Class:    UserProvisioningHandlerTest

Change History
***********************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description                                                                     Tag
Chandana Gowda      19-May-2022                                             Added changes to fetch the right records based on the users department
Chandana Gowda      07-Jun-2022                                             Added changes to check for any of the existing permission requests              
Sourabh Bhardwaj                                                            Added changes to create PRs having lookup to parent PR for Business Roles  <T02>
************************************************************************************************************************************************************************
*/
public with sharing class UserProvisioningHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    public static String userDepartment;
    public static List<string> excludeAutoApprove = String.valueOf(Label.Permission_Request_Exclude_Auto_Approve).split(';'); //List of permissions that are to be Auto excluded even if the request is from Blanket Approvers.
	//<T02>The above variable has been transferred from createAddOnRequests method to here to make it available globally.       
    
    @AuraEnabled
    public static void createAddOnRequests(Id recId){
        User_Provisioning_Request__c provisioningRequest = [SELECT Id,User__c,Blanket_Approver1__c,User__r.Department,Business_Role__c,Dev_Add_Ons__c,Business_Justification__c,Incident__c,Start_Date__c, End_Date__c FROM User_Provisioning_Request__c WHERE ID = :recId LIMIT 1];
        List<Add_On_Permission_Request__c> lstPermissionRequestToInsert = new List<Add_On_Permission_Request__c>();
        set<String> setBusinessRolePR = new set<String>();//<T02>
        
        Set<String> setPermissions = new Set<String>();

        if(String.isNotBlank(provisioningRequest.User__r.Department)){
            userDepartment = provisioningRequest.User__r.Department.toUpperCase(); //department of the user, refered to assign 
        }
        
        //Set of Permissions to be assigned
        if(provisioningRequest.Business_Role__c != null){
            setPermissions.add(provisioningRequest.Business_Role__c);
        }
        if(provisioningRequest.Dev_Add_Ons__c != null){
            setPermissions.addAll(provisioningRequest.Dev_Add_Ons__c.split(';'));
        }
		
        setPermissions.addAll(excludeAutoApprove); //<T02> Including the permissions from custom label for adding PR with approvers in business role based PRs
        
        if(!setPermissions.isEmpty()){

            Map<String,List<String>> mapPSGNameApprover = new Map<String,List<String>>();
            Set<String> setApproverUsernames = new Set<String>();
            Map<String,String> mapPsgManualStep = new Map<String,String>();

            //To get all approver matrix record for the permission request, "ORDER BY Label,Department__c NULLS LAST" used to sort the record that in the required order for RegEx evaluation
            Map<Id,User_provisioning_Approver_Matrix__mdt>  mapApproverMatrix= new Map<Id,User_provisioning_Approver_Matrix__mdt>([SELECT Id,Label,Approver_1_Username__c,Approver_2_Username__c,Department__c,Manual_Step__c,Role_Based_PSGs__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label IN :setPermissions ORDER BY Label,Department__c NULLS LAST]);
            
            if(!mapApproverMatrix.isEmpty()){

                Map<String,List<Id>> mapPermissionMatrixIds = new Map<String,List<Id>>(); //Map of Permission label and set of all ApproverMatrix records associated with it
                for(User_provisioning_Approver_Matrix__mdt matrix:mapApproverMatrix.values()){

                    List<Id> setMatrixIds = new List<Id>();
                    if(mapPermissionMatrixIds.keySet().contains(matrix.Label)){
                        setMatrixIds = mapPermissionMatrixIds.get(matrix.Label);
                    }
                    setMatrixIds.add(matrix.Id);
                    mapPermissionMatrixIds.put(matrix.Label,setMatrixIds);

                    if(String.isNotBlank(matrix.Manual_Step__c)){
                        mapPsgManualStep.put(matrix.Label,'Not Complete');
                    }
                                        
                    //<T02>-----------------------------------------------
                    if(String.isNotBlank(matrix.Role_Based_PSGs__c)){
                       setBusinessRolePR.add(matrix.Label);
                    }
                    //-----------------------------------------------<T02/>
                }

                for(String permission:mapPermissionMatrixIds.keySet()){
                    //To get the correct Matrix record for the permission based on the user department
                    User_provisioning_Approver_Matrix__mdt matrix = getApproverMatrixRecord(mapPermissionMatrixIds.get(permission),mapApproverMatrix);
                    List<String> approvers = new List<String>();
                    if(String.isNotBlank(matrix.Approver_1_Username__c)){                        
                        approvers.add(matrix.Approver_1_Username__c);
                    }
                    if(String.isNotBlank(matrix.Approver_2_Username__c)){
                        approvers.add(matrix.Approver_2_Username__c);
                    }
                    mapPSGNameApprover.put(matrix.Label,approvers);
                    setApproverUsernames.addAll(approvers);
                }
                
                Map<String,Id> mapApproverId = new Map<String,Id>();
                if(!setApproverUsernames.isEmpty()){
                    List<User> lstUser = [SELECT Id,UserName FROM User WHERE UserName IN :setApproverUsernames];
                    for(User userRec:lstUser){
                        mapApproverId.put(userRec.UserName,userRec.Id);
                    }
                }
                
                List<String> lstPermissionRequest = new List<String>();
                if(!String.isBlank(provisioningRequest.Dev_Add_Ons__c)){
                    lstPermissionRequest.addAll(provisioningRequest.Dev_Add_Ons__c.split(';'));
                }
                if(!String.isBlank(provisioningRequest.Business_Role__c)){
                    lstPermissionRequest.add(provisioningRequest.Business_Role__c);
                }

                if(!lstPermissionRequest.isEmpty()){
                    for(String addOn:lstPermissionRequest){
                        Add_On_Permission_Request__c request = new Add_On_Permission_Request__c();
                        request.Add_Ons__c = addOn;
                        request.User_Provisioning_Request__c = provisioningRequest.Id;
                        request.Business_Justification__c = provisioningRequest.Business_Justification__c;
                        request.Start_Date__c = provisioningRequest.Start_Date__c;
                        request.End_Date__c = provisioningRequest.End_Date__c;
                        request.Incident__c = provisioningRequest.Incident__c;
                        if(mapPsgManualStep.get(addOn) != null){
                            request.Manual_Step__c = mapPsgManualStep.get(addOn);
                        }
                        //If Blanket Approver if populated or if approvers found, Auto Approver the record
                        if((String.isBlank(provisioningRequest.Blanket_Approver1__c) || excludeAutoApprove.contains(addOn)) && !mapPSGNameApprover.get(addOn).isEmpty()){
                            List<String> approvers = mapPSGNameApprover.get(addOn);
                            request.Approver__c = mapApproverId.get(approvers[0]);
                            if(approvers.size() > 1){
                                request.Approver_2__c = mapApproverId.get(approvers[1]);
                            }
                        }else {
                            request.Approval_Status__c = 'Approved';
                        }
                        lstPermissionRequestToInsert.add(request);
                    }
                }
        
                try{
                    if(!lstPermissionRequestToInsert.isEmpty()){
                        Database.SaveResult[] srList = Database.insert(lstPermissionRequestToInsert, true);
                        //<T02>------------------------------------------------------------------------------                        						
						List<Add_On_Permission_Request__c> lstPRforBusinessRole = new List<Add_On_Permission_Request__c>();
                        for(Add_On_Permission_Request__c ad : lstPermissionRequestToInsert){
                            if(setBusinessRolePR.contains(ad.Add_Ons__c) && ad.Id != null){
                                lstPRforBusinessRole = createPRForBusinessRole(ad, mapApproverMatrix, mapPermissionMatrixIds, mapPSGNameApprover, mapApproverId);
                            }
                        }                        
                        if(!lstPRforBusinessRole.isEmpty()){
                            try{
                                Database.SaveResult[] srList2 = Database.insert(lstPRforBusinessRole, true);                                
                            }
                            catch(Exception e){
                                GAM.CreateLogs('UserProvisioningHandler.createAddOnRequests', lstPRforBusinessRole, 'lstPRforBusinessRole');
                            }
                        }
                        //--------------------------------------------------<T02/>
                    }
                }catch(Exception e){
                    GAM.CreateLogs('UserProvisioningHandler.createAddOnRequests', lstPermissionRequestToInsert, 'lstPermissionRequestToInsert');
                }
            }            
        }
    }
    
    /**Method used to fetch the right approver for the permission request based on Users department*/
    private static User_provisioning_Approver_Matrix__mdt getApproverMatrixRecord(List<Id> lstMatrixId,Map<Id,User_provisioning_Approver_Matrix__mdt> mapApproverMatrix){
        
        User_provisioning_Approver_Matrix__mdt approverMatricRec = new User_provisioning_Approver_Matrix__mdt();
        
        //If User department is blank, then use the default approver matrix record
        if(String.isBlank(userDepartment)){
            for(Id matrixId:lstMatrixId){
                User_provisioning_Approver_Matrix__mdt matrixRec = mapApproverMatrix.get(matrixId);
                if(String.isBlank(matrixRec.Department__c)){
                    approverMatricRec = matrixRec;
                    break;
                }
            }
        }else{ //If User department is not blank, fetch based on department
            for(Id matrixId:lstMatrixId){
                User_provisioning_Approver_Matrix__mdt matrixRec = mapApproverMatrix.get(matrixId);
                if(String.isNotBlank(matrixRec.Department__c)){
                    //Evaluate if the RegEx on matrix record matches the user's department
                    if(Pattern.matches(matrixRec.Department__c, userDepartment)){
                        approverMatricRec = matrixRec;
                        break;
                    }    
                }else{
                    approverMatricRec = matrixRec;
                    break;
                }
            }
        }
        return approverMatricRec;
    }
    
    //<T02>---------------------------------------------
    public static List<Add_On_Permission_Request__c> createPRForBusinessRole(Add_On_Permission_Request__c BusinessRole, Map<Id,User_provisioning_Approver_Matrix__mdt> mapApproverMatrix, Map<String,List<Id>> mapPermissionMatrixIds, Map<String,List<String>> mapPSGNameApprover, Map<String,Id> mapApproverId){
        User_provisioning_Approver_Matrix__mdt matrix = getApproverMatrixRecord(mapPermissionMatrixIds.get(BusinessRole.Add_Ons__c),mapApproverMatrix);
        List<Add_On_Permission_Request__c> lstPermissionRequests = new List<Add_On_Permission_Request__c>();
        if(String.isNotBlank(matrix.Role_Based_PSGs__c)){			
        	List<String> PSGs = matrix.Role_Based_PSGs__c.split(';');
        	for(String addon : PSGs){
                Add_On_Permission_Request__c request = new Add_On_Permission_Request__c();
                request.Add_Ons__c = addOn;
                request.User_Provisioning_Request__c = BusinessRole.User_Provisioning_Request__c;
                request.Business_Justification__c = BusinessRole.Business_Justification__c;
                request.Start_Date__c = BusinessRole.Start_Date__c;
                request.End_Date__c = BusinessRole.End_Date__c;
                request.Incident__c = BusinessRole.Incident__c;
                request.Parent_Role__c = BusinessRole.Id;
                if(excludeAutoApprove.contains(addon) && !mapPSGNameApprover.get(addOn).isEmpty()){
                    List<String> approvers = mapPSGNameApprover.get(addOn);
                    request.Approver__c = mapApproverId.get(approvers[0]);
                    if(approvers.size() > 1){
                          request.Approver_2__c = mapApproverId.get(approvers[1]);
                       }
                }else{
                    request.Approver__c = BusinessRole.Approver__c;
                    request.Approver_2__c = BusinessRole.Approver_2__c;
                    request.Approval_Status__c = 'Controlled By Parent Role';
                }        
               	lstPermissionRequests.add(request);
            }
		}       
       return lstPermissionRequests;    
    }
    //---------------------------------------------<T02/>

    public class PermissionRequestRec{
        @AuraEnabled public String prName;
        @AuraEnabled public String prLink;
        @AuraEnabled public String prPermission;
    }
    
    @AuraEnabled
    public static List<PermissionRequestRec> checkExistingPermissionRequests(String userId, String lstPermission, String businessRole){
        List<PermissionRequestRec> lstExistingPermissionRequests = new List<PermissionRequestRec>();
        Set<String> setPermissions = new Set<String>();
    
        if(String.isNotBlank(businessRole)){
            setPermissions.add(businessRole);
        }
    
        if(String.isNotBlank(lstPermission)){
            setPermissions.addAll(lstPermission.split(';'));
        }
        
        for(Add_On_Permission_Request__c prRec: [SELECT Id,Name,Add_Ons__c FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.User__c = :userId AND Add_Ons__c IN :setPermissions]){
            PermissionRequestRec request= new PermissionRequestRec();
            request.prName = prRec.Name;
            request.prLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' +prRec.Id ;
            request.prPermission = prRec.Add_Ons__c;
            lstExistingPermissionRequests.add(request);
        }
        return lstExistingPermissionRequests;
    }
    
    @AuraEnabled
    public static List<PermissionSetLicense> getPermissionSetLicenseReport(){
        try {
            List<PermissionSetLicense> pslReport = [SELECT Id,MasterLabel,TotalLicenses, UsedLicenses FROM PermissionSetLicense WHERE TotalLicenses > 0 ORDER BY MasterLabel];
            return pslReport;        
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getManagedPackageLicenseReport(){
        try {
            Map<String, List<String>> mapPublisherToPackageLicense = new Map<String, List<String>>();
            Map<String, String> mapPublishers = new Map<String, String>();
            List<Publisher> publisher = [SELECT Name, NamespacePrefix FROM Publisher WHERE IsSalesforce = false];
            for(publisher publish: publisher){
                mapPublishers.put(publish.NamespacePrefix, publish.Name);
            }
            List<PackageLicense> packageLicense = [SELECT Id,AllowedLicenses, UsedLicenses, NamespacePrefix FROM PackageLicense WHERE AllowedLicenses > 0 ORDER BY NamespacePrefix];
            for(PackageLicense license: packageLicense){
                    List<String> oneReport = new List<String>();
                    if(mapPublishers.containsKey(license.NamespacePrefix)){
                        oneReport.add(mapPublishers.get(license.NamespacePrefix));
                        oneReport.add(String.valueOf(license.AllowedLicenses));
                        oneReport.add(String.valueOf(license.UsedLicenses));
                        mapPublisherToPackageLicense.put(mapPublishers.get(license.NamespacePrefix), oneReport);
                    }
            }
            
            List<String> mplReports = new List<String>();
            for(List<String> listValues: mapPublisherToPackageLicense.values()){
                String str = '';
                for(String values: listValues){
                    str = str+values+',';
                }
                mplReports.add(str);
            }
            return mplReports;        
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraenabled(cacheable=true)
    public static List<User_provisioning_Approver_Matrix__mdt> getManualSteps(Id userProvisioningId){
        List<User_provisioning_Approver_Matrix__mdt> userProvisioningMatrix = new List<User_provisioning_Approver_Matrix__mdt>();
        if(userProvisioningId != null){
            List<Add_On_Permission_Request__c> lstAddOnRequest = [SELECT Add_Ons__c from Add_On_Permission_Request__c WHERE Manual_Step__c = 'Not Complete' AND User_Provisioning_Request__c = :userProvisioningId];
            if(!lstAddOnRequest.isEmpty()){
                List<String> lstAddOnNames = new List<String>();
                for(Add_On_Permission_Request__c addOnRequest:lstAddOnRequest){
                    lstAddOnNames.add(addOnRequest.Add_Ons__c);
                }
                Set<String> setAddOnNames = new Set<String>();
                for(User_provisioning_Approver_Matrix__mdt userProvisioningMat: [SELECT Id,Label,Manual_Step__c FROM User_provisioning_Approver_Matrix__mdt WHERE Label IN :lstAddOnNames]){
                    if(!setAddOnNames.contains(userProvisioningMat.Label)){
                        userProvisioningMatrix.add(userProvisioningMat);
                        setAddOnNames.add(userProvisioningMat.Label);
                    }
                }
            }
        }
        return userProvisioningMatrix;
    }    
}