/*
Class:          UserProvisioningHandlerTest
@Author:        Chandana Gowda
@Created Date:  3 Oct 2021
@Description:   Test class for UserProvisioningHandler and UserProvisioningBatch

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Sourabh Bhardwaj                                                            Added logic to test assignment of permissions based upon business roles <T01>
************************************************************************************************************************************************************
*/
@isTest
public with sharing class UserProvisioningHandlerTest {
    
    @TestSetup
    static void setupTestData(){
        Profile pr = [select ID,Name from Profile where name = 'Employee'];
        sObject sObj = new User();
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        User userObj = (User)UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        List<User>  lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj});
        
        User_Provisioning_Request__c userProvisioning = new User_Provisioning_Request__c();
        userProvisioning.User__c = lUser[0].Id;
        userProvisioning.Incident__c = 'test#';
        userProvisioning.Business_Justification__c = 'Test Business justification';
        userProvisioning.Business_Role__c = 'IPS Associate Consultant';
        userProvisioning.Dev_Add_Ons__c = 'Altify Normal User;CPQ Quote;DocuSign';        
        insert userProvisioning;
        
        //<T01>-----------------------------------------
        User_Provisioning_Request__c userProvisioningForBusinessRole = new User_Provisioning_Request__c();
        userProvisioningForBusinessRole.User__c = lUser[0].Id;
        userProvisioningForBusinessRole.Incident__c = 'testBusinessRole#';
        userProvisioningForBusinessRole.Business_Justification__c = 'Test Business justification';
        userProvisioningForBusinessRole.Business_Role__c = 'SOG';
        insert userProvisioningForBusinessRole;
        //------------------------------------------------<T01/>
        
        Date tday =System.Today();
        User_Provisioning_Request__c userProvisioning1 = new User_Provisioning_Request__c();
        userProvisioning1.User__c = lUser[0].Id;
        userProvisioning1.Incident__c = 'testdelete#';
        userProvisioning1.Business_Justification__c = 'Test Business justification';
        userProvisioning1.Business_Role__c = 'IPS Associate Consultant';
        userProvisioning1.Dev_Add_Ons__c = 'CPQ Billing;CPQ Renewal Rep;SDocs';
        userProvisioning1.Start_Date__c = tday;
        insert userProvisioning1;
        UserProvisioningHandler.createAddOnRequests(userProvisioning1.Id);
        List<Add_On_Permission_Request__c> lstPermissionRequest = [SELECT Id,Approval_Status__c,User_Provisioning_Request__r.Pending_Permission_Assignment__c,Start_Date__c,End_Date__c,Permission_Assigned__c FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.Incident__c = 'testdelete#'];
        UserProvisioningHandler.getManualSteps(userProvisioning1.Id);
        for(Add_On_Permission_Request__c permissionRequest:lstPermissionRequest){
            permissionRequest.Approval_Status__c = 'Approved';   
        }
        update lstPermissionRequest;
        UserProvisioningBatch c= new UserProvisioningBatch();
        c.execute(null);
        
        
    }
    
    @IsTest
    static void createAddOnRequestsTest(){
        
        User_Provisioning_Request__c userProvisioning = [SELECT Id,Pending_Permission_Assignment__c FROM User_Provisioning_Request__c LIMIT 1];
        UserProvisioningHandler.createAddOnRequests(userProvisioning.Id);
        List<Add_On_Permission_Request__c> lstPermissionRequest = [SELECT Id,Approval_Status__c,User_Provisioning_Request__r.Pending_Permission_Assignment__c,User_Provisioning_Request__r.Id FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.Id=:userProvisioning.Id AND Permission_Assigned__c=false];
        System.assertEquals(lstPermissionRequest.size(),lstPermissionRequest[0].User_Provisioning_Request__r.Pending_Permission_Assignment__c);
        
        UserProvisioningHandler.getManualSteps(userProvisioning.Id);
        
        for(Add_On_Permission_Request__c permissionRequest:lstPermissionRequest){
            permissionRequest.Approval_Status__c = 'Approved';
        }
        update lstPermissionRequest;
        
        Test.startTest();
        UserProvisioningBatch userProvisioningTest = new UserProvisioningBatch();
        Id batchId = Database.executeBatch(userProvisioningTest);
        String cronExp = '10 28 10 15 9 ?';
        System.schedule('User Provisioning Batch', cronExp, userProvisioningTest);     
        
        
        lstPermissionRequest = [SELECT Id,User_Provisioning_Request__r.Pending_Permission_Assignment__c,User_Provisioning_Request__r.Incident__c FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.Incident__c = 'test#'AND Permission_Assigned__c=false];
        System.assertEquals(lstPermissionRequest.size(),lstPermissionRequest[0].User_Provisioning_Request__r.Pending_Permission_Assignment__c);
    }
    
    
    @IsTest
    static void insertDeleteValidatePRTest(){
        Date today =System.Today();
        User_Provisioning_Request__c userProvisioning = [SELECT Id,Pending_Permission_Assignment__c,User__c,Business_Role__c,Dev_Add_Ons__c FROM User_Provisioning_Request__c Where Start_Date__c=:today And Incident__c ='testdelete#' LIMIT 1];
        
        List<UserProvisioningHandler.PermissionRequestRec> checkExistingPermissions = UserProvisioningHandler.checkExistingPermissionRequests(userProvisioning.User__c,userProvisioning.Business_Role__c,userProvisioning.Dev_Add_Ons__c);
        
        List<Add_On_Permission_Request__c> lstPermissionRequest = [SELECT Id,Approval_Status__c,User_Provisioning_Request__r.Pending_Permission_Assignment__c,Start_Date__c,End_Date__c,Permission_Assigned__c FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.Incident__c = 'testdelete#'];
        
        for(Add_On_Permission_Request__c permissionRequest:lstPermissionRequest){
            permissionRequest.Start_Date__c = null;   
            permissionRequest.End_Date__c = today;
        }
        update lstPermissionRequest;
        
        
        Test.startTest();
        UserProvisioningBatch userProvisioningTest = new UserProvisioningBatch();
        Id batchId1 = Database.executeBatch(userProvisioningTest);
        String cronExp1 = '10 28 10 15 9 ?';
        System.schedule('User Provisioning Batch', cronExp1, userProvisioningTest);  
         
    }
    
    //<T01>------------------------------------------------
    @isTest
    static void createPRforBusinessRole(){
        User_Provisioning_Request__c userProvisioning = [SELECT Id,Pending_Permission_Assignment__c,User__c,Business_Role__c,Dev_Add_Ons__c FROM User_Provisioning_Request__c Where Incident__c ='testBusinessRole#' LIMIT 1];
        UserProvisioningHandler.createAddOnRequests(userProvisioning.Id);
        List<Add_On_Permission_Request__c> lstPermissionRequest = [SELECT Id,Add_Ons__c,User_Provisioning_Request__r.User__c,Start_Date__c,End_Date__c,Approval_Status__c,User_Provisioning_Request__r.Pending_Permission_Assignment__c,User_Provisioning_Request__r.Id,Parent_Role__c,Parent_Role__r.Permission_Assigned__c,Permission_Assigned__c FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.Id=:userProvisioning.Id AND Permission_Assigned__c=false];
        System.assertEquals(lstPermissionRequest.size(),lstPermissionRequest[0].User_Provisioning_Request__r.Pending_Permission_Assignment__c);
        
        UserProvisioningHandler.getManualSteps(userProvisioning.Id);
        
        for(Add_On_Permission_Request__c permissionRequest:lstPermissionRequest){
            permissionRequest.Approval_Status__c = 'Approved';
        }
        update lstPermissionRequest;
        
        Test.startTest();
        UserProvisioningBatch userProvisioningTest = new UserProvisioningBatch();
        Id batchId = Database.executeBatch(userProvisioningTest);
        String cronExp = '10 54 4 15 9 ?';
        System.schedule('User Provisioning Batch', cronExp, userProvisioningTest);     
        
        
        lstPermissionRequest = [SELECT Id,User_Provisioning_Request__r.Pending_Permission_Assignment__c,User_Provisioning_Request__r.Incident__c FROM Add_On_Permission_Request__c WHERE User_Provisioning_Request__r.Incident__c = 'testBusinessRole#'AND Permission_Assigned__c=false];
        System.assertEquals(lstPermissionRequest.size(),lstPermissionRequest[0].User_Provisioning_Request__r.Pending_Permission_Assignment__c);
    }
    //------------------------------------------------<T01/>
    
    @IsTest
    static void getPermissionSetLicenseReportTest(){
        UserProvisioningHandler.getPermissionSetLicenseReport();
        UserProvisioningHandler.getManagedPackageLicenseReport();
    }
}