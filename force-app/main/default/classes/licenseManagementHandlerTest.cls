/*
Class:          licenseManagementHandlerTest
@Author:        Sreerekha
@Created Date:  7 AUG 2023
@Description:   Test class for licenseManagementHandler

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
************************************************************************************************************************************************************
*/

@isTest
public class licenseManagementHandlerTest {
     @TestSetup
    static void setupTestData(){
        Profile pr = [select ID,Name from Profile where name = 'Employee'];
        sObject sObj = new User();
        UtilityTestData.mUserData.put('ProfileId', pr.Id);User userObj = (User)UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        List<User>  lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj});
       
    }
    
    
    @IsTest
    static void getlicenseManagementHandler(){
        List<Id> selectedUsers = new List<Id>();
        User usr = [Select Id, Name from User where Name = 'Prasanth Sagar Gudey' Limit 1];
        selectedUsers.add(usr.Id);
        User_provisioning_Approver_Matrix__mdt MplMatrix = [Select Id, Label, Department__c,License__c from User_provisioning_Approver_Matrix__mdt where  Label = 'Altify' limit 1];
        User_provisioning_Approver_Matrix__mdt PslMatrix = [Select Id, Label, Department__c,License__c from User_provisioning_Approver_Matrix__mdt where  Label = 'Salesforce CPQ License' limit 1];
        
        licenseManagementHandler.fetchLicensesAssigned(usr.Name);
        licenseManagementHandler.fetchAllLicensesAvailable();
        licenseManagementHandler.fetchBusinessRoles(usr.Name);
        licenseManagementHandler.fetchUsersList(MplMatrix.License__c,usr.Id);
        licenseManagementHandler.fetchUsersForLicense(MplMatrix.License__c);
        licenseManagementHandler.fetchAllUsersList(usr.Name);
        licenseManagementHandler.getRemovalLicenseReport(MplMatrix.License__c);
        licenseManagementHandler.getRemovalLicenseReport(PslMatrix.License__c);
        licenseManagementHandler.getAssignLicenseReport(MplMatrix.Label, usr.Name);
        licenseManagementHandler.getAssignLicenseReport(PslMatrix.Label, usr.Name);
        licenseManagementHandler.validateSelectedUsers(selectedUsers, MplMatrix.Label);
        licenseManagementHandler.validateSelectedUsers(selectedUsers, PslMatrix.Label);
        licenseManagementHandler.createUserProvisioningRemovalReq(selectedUsers, MplMatrix.License__c,'License_Removal', usr.Id);
        licenseManagementHandler.createUserProvisioningAddReq(selectedUsers, MplMatrix.License__c, MplMatrix.Label, usr.Id, 'License_Assignment');
         }
 }