/*
Class:          UserTriggerHandler
@Author:        Deloitte
@Created Date:  10/27/2017
@Description:   handler class for User triggers

Change History
****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                         JIRA        Tag
****************************************************************************************************************************
Kiran G          22 Apr 2019    PrasanthG        Share the contacts with Edit access
while sharing Account and Opptys PRMRT-295/334
Commented code to share at each contact level                      T01
Chandana Gowda    2 Jun 2019     PrasanthG        PRMRT-321 added the condition to fetch ContactShare                T02
records with RowCause='Manual' only
Vivek Warrier    7-Oct-2020     Proj Rhapsody    Contact automation
Vivek Warrier    30-Sep-2020    Neha Kumari      Contact Automation                                                 T03
Vivek Warrier    22-Feb-2022    Neha Kumari      User to Contact update                                  PSA-2275   T04
Vivek Warrier    30-May-2022    Neha Kumari      Optimizing the User2Contact Update                      PSA-2337   T05
Deeksha Shetty.  6-June-2022.   IN tranformation. Avoid Nickname Duplicates                                         T06
Karthi G         09-01-2023     Sarojini B       Update Plan team when user manager is changed           AR-3064    <T07>
Utkarsh Jain     27-April-2023  Neha Mehta       I2RT-6143 - Changing Nickname in IN community                      T08
Prashanth Bhat   01-August-2023                  I2RT-8822 - Optimize the nickname updation logic                   T09
Wasim            09-Oct-2023    Tech Debt        PSA-3226 - Removing the IPS PermissionSetGroup assignment PSA-3226 T10                      
****************************************************************************************************************************
*/

public class UserTriggerHandler{
    
    public static globalApexManager GAM = new globalApexManager();
    
    /**
* this method is invoked from after insert event of User
*
* @param newUserList - list of new users
* @return return-void
* @throws exception - NA
*/
    public static void userAfterInsert(Map<Id,User> newUserMap){//T05 Changed the argument from List to Map
        List<ID> userIDList = new List<ID>();
        for(User usr : newUserMap.values()){ //T05 Added the .values() function on the change from List to Map
            userIDList.add(usr.Id);
        }
        createContactShareRecord(userIDList);
        
        resourceAutomation(newUserMap,null);
    }
    
    /**
* PRM: this method is invoked from after insert event of Users to insert Contact Share records
*
* @param newUserList - list of new users
* @return return-void
* @throws exception - NA
*/
    @future
    public static void createContactShareRecord(List<ID> newUserIDList){
        Set<ID> contactIdSet = new Set<ID>();
        Map<ID, ID> userContIdMap = new Map<ID, ID>();
        Map<Id, Contact> contactIdMap = new Map<Id, Contact>();
        List<ContactShare> contactShareList = new List<ContactShare>();
        List<ID> accountIDList = new List<ID>(); 
        Map<ID, ID> contactUserMap = new Map<ID, ID>();
        Map<ID, ID> accountContMap =  new Map<ID, ID>();
        Boolean isPartnerUser = false;
        Map<Id, Id> permissionSetUserMap = new Map<Id, Id>();
        List<AccountShare> accShareList = new List<AccountShare>();
        
        List<User> newUserList = [select Id, ContactId, PRM_Contact_Role__c, Contact.AccountId 
                                  from User where ID IN : newUserIDList];
        
        for(PermissionSetAssignment psa : [SELECT Assignee.Name, PermissionSet.Id, AssigneeId,
                                           PermissionSet.isOwnedByProfile, PermissionSet.Profile.Name, PermissionSet.Label
                                           FROM PermissionSetAssignment WHERE PermissionSetId
                                           IN (SELECT Id FROM PermissionSet
                                               WHERE Name = 'PRM_Partner_Admin_Permissions') AND AssigneeId IN : newUserIDList]){
                                                   permissionSetUserMap.put(psa.AssigneeId, psa.PermissionSet.Id);                  
                                               }    
        
        for(User user : newUserList){            
            if(user.ContactId != null && user.PRM_Contact_Role__c != null){
                contactIdSet.add(user.ContactId);
                accountIDList.add(user.Contact.AccountId);
                contactUserMap.put(user.ContactId, user.Id);
                accountContMap.put(user.Contact.AccountId, user.ContactId);
                if(permissionSetUserMap != null && !permissionSetUserMap.isEmpty() && permissionSetUserMap.containsKey(user.Id)){
                    isPartnerUser = true;
                }
                userContIdMap.put(user.Id, user.ContactId);
            }
        }
        
        // If it is a Partner Admin user, query for all contacts associated to the account for the contactId
        if(isPartnerUser && accountIDList != null && !accountIDList.isEmpty()){
            
            AccountShare accShare;
            //---------------------------------------------------------------------------------------------------------------------------------------<T01>
            // Commented code of sharing at COntact level as sharing of Contacts at Account level is handled
            /* for(Account acc : [select Id, (select Id, OwnerId, Name from Contacts) from Account where ID IN : accountIDList]){
for(Contact cont : acc.Contacts){
contactIdMap.put(cont.Id, cont);
userContIdMap.put(contactUserMap.get(accountContMap.get(acc.Id)), cont.Id);
}
} */
            // Create Account share records for only Partner Admin user
            // Share Contacts to Partner Portal Admin with Edit access so that if any newly added contact can be edited by Partner Admin PRMRT-295(T01)
            for(Id accID : accountContMap.keySet()){
                if(accID != null && accountContMap.containsKey(accId) ){              
                    
                    accShare = new AccountShare(UserOrGroupId=contactUserMap.get(accountContMap.get(accId)), RowCause='Manual',
                                                AccountId = accID, AccountAccessLevel='Edit',OpportunityAccessLevel='Edit',ContactAccessLevel = 'Edit');
                    //---------------------------------------------------------------------------------------------------------------------------------------</T01>
                    accShareList.add(accShare);
                }
            }
            
            
        }else{
            contactIdMap = new Map<ID, Contact>([select OwnerId, Id from Contact where ID IN : contactIdSet]);
        }
        //---------------------------------------------------------------------------------------------------------------------------------------<T01>
        // Commented code of sharing at COntact level as sharing of Contacts at Account level is handled
        /*ContactShare contShare;
for(User user : newUserList){
for(Contact con : contactIdMap.values()){
if(user.ContactId != null && userContIdMap != null && !userContIdMap.isEmpty() && userContIdMap.containsKey(user.Id) &&
con != null && con.Id != null){                    
contShare = new ContactShare(UserOrGroupId=user.Id, RowCause='Manual',
ContactId = con.Id, ContactAccessLevel='Edit');
contactShareList.add(contShare);                    
}
}
}*/
        //---------------------------------------------------------------------------------------------------------------------------------------<T01>
        try{
            if(accShareList != null && !accShareList.isEmpty() &&
               Schema.getGlobalDescribe().get('AccountShare').getDescribe().isCreateable()){
                   insert accShareList;
               }
            //---------------------------------------------------------------------------------------------------------------------------------------<T01>
            // Commented code of sharing at COntact level as sharing of Contacts at Account level is handled
            /*if(contactShareList != null && !contactShareList.isEmpty() &&
Schema.getGlobalDescribe().get('ContactShare').getDescribe().isCreateable()){
Database.SaveResult[] saveResultList = Database.insert(contactShareList, false);
for (Database.SaveResult sr : saveResultList) {
if (!sr.isSuccess()) {
GAM.CreateExceptionRecords('UserTriggerHandler', sr.getErrors()[0].getMessage(), '');
}
}
}*/
            //---------------------------------------------------------------------------------------------------------------------------------------<T01>
        }catch(DMLException dExp){
            // Create an exception log using globalApexManager class
            GAM.CreateLogs('UserTriggerHandler', Label.PRM_Contact_Share_Insert_Error);
        }
        
    }
    
    /**
* PRM: this method is invoked from after update event of User to delete or create Contact Share records as applicable
*
* @param newUserList - map of <ID,new users> and map of <ID, old user>
* @return return-void
* @throws exception - NA
*/
    public static void userAfterUpdate(Map<Id,User> newUserMap, Map<Id, User> oldUserMap){
        List<ID> deleteShareUserIDList = new List<ID>(); // list of User Ids for Share record deletion  
        List<ID> createShareUserIDList = new List<ID>(); // list of User Ids for Share record creation 
        
        List<Id> managerChangedUserList = new List<Id>(); // List of manager modified user Ids   <T07>
        
        for(Id usr : newUserMap.keySet()){
            // check if PRM Contact Role field on Contact has been updated to Admin 
            if(oldUserMap.containsKey(usr) && oldUserMap.get(usr).PRM_Contact_Role__c != newUserMap.get(usr).PRM_Contact_Role__c &&
               newUserMap.get(usr).PRM_Contact_Role__c != null && 
               newUserMap.get(usr).PRM_Contact_Role__c.equalsIgnoreCase(Label.PRM_Partner_Portal_Admin)){           
                   createShareUserIDList.add(usr);
               }else if(oldUserMap.containsKey(usr) && oldUserMap.get(usr).PRM_Contact_Role__c != newUserMap.get(usr).PRM_Contact_Role__c &&
                        newUserMap.get(usr).PRM_Contact_Role__c != null && 
                        !newUserMap.get(usr).PRM_Contact_Role__c.equalsIgnoreCase(Label.PRM_Partner_Portal_Admin)){
                            deleteShareUserIDList.add(usr);
                        }   
            //<T07>
            if(oldUserMap.containsKey(usr) && oldUserMap.get(usr).ManagerId != newUserMap.get(usr).ManagerId){
                managerChangedUserList.add(usr);
            }
            //</T07>
        }
        //Call method to create Share records if any user is marked as Partner Admin 
        if(createShareUserIDList != null && !createShareUserIDList.isEmpty()){
            createContactShareRecord(createShareUserIDList);
        }
        // Call method to delete existing share records if user is marked as non-Partner Admin
        if(deleteShareUserIDList != null && !deleteShareUserIDList.isEmpty()){
            updateContactShareRecord(deleteShareUserIDList);
        }
        
        //<T07>   invoke queuable class to update Plan team with new Managers to avoid mixed DML error
        if(managerChangedUserList !=null && !managerChangedUserList.isEmpty()){
            CSMManagePlanTeamQueuable csmManagerUpdate = new CSMManagePlanTeamQueuable(managerChangedUserList);
            System.enqueueJob(csmManagerUpdate);
        }
        //</T07>
        
        resourceAutomation(newUserMap,oldUserMap);
    }
    
    /**
* PRM: this method is invoked from after update event of Users
*
* @param deleteShareUserIDList - list of users
* @return return-void
* @throws exception - NA
*/
    @future
    public static void updateContactShareRecord(List<ID> deleteShareUserIDList){
        if(deleteShareUserIDList != null && !deleteShareUserIDList.isEmpty()){
            Map<ID, ID> contactUserIdMap = new Map<ID, ID>();
            Map<ID, ID> accountUserIdMap = new Map<ID, ID>();
            List<ContactShare> contactShareList = new List<ContactShare>();
            List<AccountShare> accountShareList = new List<AccountShare>();
            
            for(User user : [select ContactId, Contact.AccountId from User where ID IN : deleteShareUserIDList]){
                contactUserIdMap.put(user.ContactId, user.Id);
                accountUserIDMap.put(user.Contact.AccountId, user.Id);
            }
            //added the condition to fetch ContactShare objects with RowCause='Manual' only
            //---------------------------------------------------------------------------------<T02>
            for(ContactShare conShare : [select ContactAccessLevel,ContactId,RowCause,UserOrGroupId FROM ContactShare
                                         where RowCause='Manual' AND UserOrGroupId IN : contactUserIdMap.values()])
                //---------------------------------------------------------------------------------</T02>
            {
                if(!contactUserIdMap.containsKey(conShare.ContactId)){
                    contactShareList.add(conShare);
                }                           
            }
            // Query for all Account share records with edit access and update them to have only Read access
            AccountShare accountShare;
            for(AccountShare accShare : [select AccountAccessLevel, AccountId,OpportunityAccessLevel,ContactAccessLevel, RowCause, UserOrGroupId
                                         from AccountShare where UserOrGroupId IN: deleteShareUserIDList]){
                                             if(accountUserIDMap.containsKey(accShare.AccountId)){
                                                 //---------------------------------------------------------------------------------------------------------------------------------------<T01>
                                                 accountShare = new AccountShare(Id=accShare.Id, AccountAccessLevel='Read',OpportunityAccessLevel='Read',ContactAccessLevel = 'Read');
                                                 //---------------------------------------------------------------------------------------------------------------------------------------<T01>
                                                 accountShareList.add(accountShare);
                                             } 
                                         }
            try{
                if(contactShareList != null && !contactShareList.isEmpty() && 
                   Schema.getGlobalDescribe().get('ContactShare').getDescribe().isDeletable()){
                       delete contactShareList;
                   }
                if(accountShareList != null && !accountShareList.isEmpty() &&
                   Schema.getGlobalDescribe().get('AccountShare').getDescribe().isUpdateable()){
                       update accountShareList;
                   }
            }catch(DMLException dExp){
                // Create an exception log using globalApexManager class
                GAM.CreateExceptionRecords('UserTriggerHandler', dExp.getMessage(), contactShareList[0].Id);
            }
        }
    }
    
    /**
* PRM: this method is invoked from after update event of Users
* this method will activate/deactivate the user if is_active is changed
* @param triggerNew - list of users
* @return return-void
* @throws exception - NA
*/
    public static void sharingAfterUpdate(List<User> triggerNew){
        List<id> lstActiveUsers = new List<id>();
        List<id> lstinActiveUsers = new List<id>();  
        
        for(user u : triggerNew){
            if(u.IsActive){
                lstActiveUsers.add(u.Id);
            }else{
                lstinActiveUsers.add(u.Id);
            }
        }  
        
        if(lstActiveUsers.size() > 0){
            ApexSharingUtility.enablesharingForActiveUsers(lstActiveUsers);
        }
        
        if(lstinActiveUsers.size() > 0){
            ApexSharingUtility.disablesharingForInactiveUsers(lstinActiveUsers);
        }
        
    }
    
    /**
* PRM: this method is invoked from after insert event of Users
* this method will activate the user if is_active is checked
* IPS: this method is invoked from after insert event of Users
* this method will call resourceAutomation method, which creates/updates contacts
*
* @param triggerNew - list of users
* @return return-void
* @throws exception - NA
*/
    public static void sharingAfterInsert(List<User> triggerNew){
        List<id> lstActiveUsers = new List<id>();
        
        for(user u : triggerNew){
            if(u.IsActive){
                lstActiveUsers.add(u.Id);
            }
        }  
        
        if(lstActiveUsers.size() > 0){
            ApexSharingUtility.enablesharingForActiveUsers(lstActiveUsers);
        }
        
    }
    
    /**
* IPS: this method is invoked from after insert event of Users
* this method will create a contact if it does not exist and populate PS fields
* @param triggerNew - list of users
* @return return-void
* @throws exception - NA
*/
    /*
public static void resourceAutomation(List<User> triggerNew, Map<Id,User> oldMap){

List<String> existingUser = new List<String>();
Map<String,User> userMap = new Map<String,User>();
List<String> UserDeactivatedList = new List<String>();
Map<Id,User> userChangeMap = new Map<Id,User>();
Map<Id,UserRole> roleMap = new Map<Id,UserRole>([SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName LIKE 'PS%']);
System.debug('RoleMap: ' + roleMap);
Map<String,User_Role_Mapping__mdt> userRoleMap = new Map<String,User_Role_Mapping__mdt>();
Map<Id,List<Id>> userIdToAssignmentIds = new Map<Id,List<Id>>();
Map<String, PermissionSetGroup> psgMap = new Map<String, PermissionSetGroup>();
List<PermissionSetAssignment> AssignmentstoInsert = new List<PermissionSetAssignment>();
Set<Id> AssignmentstoDelete = new Set<Id>();
Map<Id,String> contactsToUpdate = new Map<Id,String>();
List<Contact> contactsToInsert = new List<Contact>();

pse__Grp__c[] defaultGroup = [SELECT Id FROM pse__Grp__c WHERE Name = :Label.Default_Resource_Group LIMIT 1];
pse__Practice__c[] defaultSubcontractorPractice = [SELECT Id FROM pse__Practice__c WHERE Name =:Label.Default_Subcontractor_Practice LIMIT 1];
pse__Grp__c[] defaultSubcontractorGroup = [SELECT Id FROM pse__Grp__c WHERE Name =:Label.Default_Subcontractor_Group LIMIT 1];
pse__Region__c [] defaultSubcontractorRegion = [SELECT Id FROM pse__Region__c WHERE Name =:Label.Default_Subcontractor_Region LIMIT 1];

for(User_Role_Mapping__mdt urm : [SELECT Id, Active__c, DeveloperName, User_Role_Grouping__c, MasterLabel FROM User_Role_Mapping__mdt WHERE Active__c = true]){
userRoleMap.put(urm.DeveloperName,urm);
}

for(PermissionSetGroup psg : [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName LIKE 'PSA%' AND Status = 'Updated']){
psgMap.put(psg.DeveloperName,psg);
}
System.debug('psgMap: ' + psgMap);

if(oldMap != null){
for(User u : [SELECT Id, (SELECT Id, PermissionSetGroup.DeveloperName FROM PermissionSetAssignments WHERE PermissionSetGroup.DeveloperName LIKE 'PSA%' LIMIT 1) FROM User WHERE Id IN :oldMap.keySet()]){
for(PermissionSetAssignment psa : u.PermissionSetAssignments){
if(userIdToAssignmentIds.containsKey(u.Id)){
userIdToAssignmentIds.get(u.Id).add(psa.Id);
}
else
{
userIdToAssignmentIds.put(u.Id,new List<Id>{psa.Id});
}
}
}
}

for(User u : triggerNew){
if(oldMap != null){
if((roleMap.get(oldMap.get(u.Id).UserRoleId) == null && roleMap.get(u.UserRoleId) != null) || 
(oldMap.get(u.Id).IsActive == false && u.IsActive == true)){
userMap.put(u.Email,u);
}
else if((roleMap.get(oldMap.get(u.Id).UserRoleId) != null && roleMap.get(u.UserRoleId) == null) || 
(oldMap.get(u.Id).IsActive == true && u.IsActive == false)){
UserDeactivatedList.add(u.Email);
}
else if(roleMap.get(oldMap.get(u.Id).UserRoleId) != null && roleMap.get(u.UserRoleId) != null &&
oldMap.get(u.Id).UserRoleId != u.UserRoleId){
userChangeMap.put(u.Id,u);
}
}
else if(roleMap.get(u.UserRoleId) != null){
Id groupId = null;
userMap.put(u.Email,u);
System.debug('u.userroleid: ' + u.UserRoleId);
if(roleMap.get(u.UserRoleId) != null){    
if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
if(psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c) != null){
groupId = psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c).Id;
}
}
}
if(groupId != null){
PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = groupId,AssigneeId = u.Id);
AssignmentstoInsert.add(assignment);
}
}
}

if(oldMap != null){
//Deleting and re-inserting the PermissionSetAssignment for reactivated/role changed to PS
for(User u : userMap.values()){
Id groupId = null;            
if(userIdToAssignmentIds.get(u.Id)!= null) AssignmentstoDelete.addAll(userIdToAssignmentIds.get(u.Id));
if(roleMap.get(u.UserRoleId) != null){    
if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
if(psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c) != null){
groupId = psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c).Id;
}
}
}
if(groupId != null){
PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = groupId,AssigneeId = u.Id);
AssignmentstoInsert.add(assignment);
}
}

//Deleting and re-inserting the PermissionSetAssignment for change from one PS role to another
for(User u : userChangeMap.values()){
Id groupId = null;
if(userIdToAssignmentIds.get(u.Id)!= null) AssignmentstoDelete.addAll(userIdToAssignmentIds.get(u.Id));
if(roleMap.get(u.UserRoleId) != null){    
if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
if(psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c) != null){
groupId = psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c).Id;
}
}
}
if(groupId != null){
PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = groupId,AssigneeId = u.Id);
AssignmentstoInsert.add(assignment);
}
}
}

//Activation/change of Role to PS
if(userMap.size() > 0){
for(Contact c: [SELECT Id, Email, pse__Salesforce_User__c,pse__Salesforce_User__r.UserRoleId,pse__Is_Resource__c,pse__Is_Resource_Active__c FROM CONTACT WHERE Email IN: userMap.keySet()]){
contactsToUpdate.put(c.Id,'Activate');
existingUser.add(c.Email);
}
}

//Deactivation/change of Role away from PS
if(UserDeactivatedList.size() > 0){
for(Contact c: [SELECT Id, Email, pse__Salesforce_User__c,pse__Salesforce_User__r.UserRoleId,pse__Is_Resource__c,pse__Is_Resource_Active__c FROM CONTACT WHERE Email IN: UserDeactivatedList]){
contactsToUpdate.put(c.Id,'Deactivate');
}
}

//Change of Role on User 
if(userChangeMap.size() > 0){
for(Contact c: [SELECT Id, Email, pse__Salesforce_User__c,pse__Salesforce_User__r.UserRoleId,pse__Is_Resource__c,pse__Is_Resource_Active__c FROM CONTACT WHERE pse__Salesforce_User__c IN :userChangeMap.keySet()]){
if(userChangeMap.containsKey(c.pse__Salesforce_User__c)){
if(roleMap.get(c.pse__Salesforce_User__r.UserRoleId) != null){
if(roleMap.get(c.pse__Salesforce_User__r.UserRoleId).DeveloperName.startsWith('PS')){
contactsToUpdate.put(c.Id,'Activate');
}
else{
contactsToUpdate.put(c.Id,'Deactivate');
}
}
}
}
}

//Creation of a new contact
for(User u : triggerNew){
if(!existingUser.contains(u.Email)){
Contact cTemp = new Contact();
cTemp.FirstName = u.FirstName;
cTemp.LastName = u.LastName;
cTemp.pse__Salesforce_User__c = u.Id;
cTemp.pse__Is_Resource__c = true;
if(roleMap.get(u.UserRoleId) != null){
if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
System.debug('***UTH - Masterlabel: ' + userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).MasterLabel);
cTemp.pse__Resource_Role__c = userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).MasterLabel;
if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).MasterLabel == 'Subcontractor'){
if(defaultSubcontractorGroup.size() > 0) cTemp.pse__Group__c = defaultSubcontractorGroup[0].Id;
if(defaultSubcontractorPractice.size() > 0) cTemp.pse__Practice__c = defaultSubcontractorPractice[0].Id;
if(defaultSubcontractorRegion.size() > 0) cTemp.pse__Region__c = defaultSubcontractorRegion[0].Id;
cTemp.psa_us_Current_Comp_Plan__c = 'No Comp Plan';
cTemp.pse__External_Resource__c = true;
}
else{
if(defaultGroup.size() > 0) cTemp.pse__Group__c = defaultGroup[0].Id; 
cTemp.psa_us_Current_Comp_Plan__c = 'Global Field Consultant'; 
}
}
}
cTemp.Email = u.Email;
cTemp.Phone = u.Phone;
contactsToInsert.add(cTemp);
}
}

if(contactsToInsert.size() > 0)    psa_us_UserAutomation.contactInsert(Json.serialize(contactsToInsert));
if(contactsToUpdate.size() > 0)    psa_us_UserAutomation.contactUpdate(contactsToUpdate);
if(AssignmentstoDelete.size() > 0) psa_us_UserAutomation.permDelete(AssignmentstoDelete);
if(AssignmentstoInsert.size() > 0) psa_us_UserAutomation.permInsert(Json.serialize(AssignmentstoInsert));

}*/
    
    public static void resourceAutomation(Map<Id,User> triggerNew, Map<Id,User> oldMap){
        Map<Id,UserRole> roleMap = new Map<Id,UserRole>([SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName LIKE 'PS%']);
        Map<Id,User> mapUsersToProcess = new Map<Id,User>(); //T05 Change from List to Map
        Map<Id,User> mapOldUsers = null;
        if(oldMap != null){
            mapOldUsers = new Map<Id,User>();
        }
        for(User u : triggerNew.values()){
            if(oldMap != null){
                boolean bProcess = false;
                //<T4>
                if((roleMap.get(u.UserRoleId) != null && oldMap.get(u.Id).UserRoleId != u.UserRoleId && 
                    roleMap.get(u.UserRoleId) != null) || //UserRole is changed/populated with a PS Role
                   (oldMap.get(u.Id).IsActive == false && u.IsActive == true && roleMap.get(u.UserRoleId) != null) || //PS User is Activated
                   (oldMap.get(u.Id).Department != u.Department && u.Department != null && u.Department?.startsWith('IPS')) || //Department is changed from non-IPS to IPS
                   (roleMap.get(oldMap.get(u.Id).UserRoleId) != null && roleMap.get(u.UserRoleId) == null) || //PS UserRole is removed/replaced
                   (oldMap.get(u.Id).IsActive == true && u.IsActive == false && roleMap.get(oldMap.get(u.Id).UserRoleId) != null) || //PS user is deactivated
                   (oldMap.get(u.Id).Department != u.Department && u.Department != null && !u.Department?.startsWith('IPS')) || //Department is changed from IPS to non-IPS
                   //Change of any of the following fields
                   oldMap.get(u.Id).ManagerId != u.ManagerId ||
                   oldMap.get(u.Id).CurrencyIsoCode != u.DefaultCurrencyIsoCode ||
                   oldMap.get(u.Id).FirstName != u.FirstName ||
                   oldMap.get(u.Id).LastName != u.LastName ||
                   oldMap.get(u.Id).Title != u.Title ||
                   oldMap.get(u.Id).Phone != u.Phone ||
                   oldMap.get(u.Id).MobilePhone != u.MobilePhone ||
                   oldMap.get(u.Id).Country != u.Country ||
                   oldMap.get(u.Id).City != u.City ||
                   oldMap.get(u.Id).State != u.State ||
                   oldMap.get(u.Id).PostalCode != u.PostalCode){
                       bProcess = true;
                   }
                //</T4>
                //</T03>
                if(bProcess){
                    mapUsersToProcess.put(u.Id,u); //T05
                    mapOldUsers.put(u.Id,oldMap.get(u.Id));
                }
            }
            else if(roleMap.get(u.UserRoleId) != null){
                mapUsersToProcess.put(u.Id,u); //T05
            }
        }
        
        if(mapUsersToProcess.size()>0){
            string sNewItems = Json.serialize(mapUsersToProcess); //T05
            string sOldList = null;
            if(mapOldUsers!=null){
                sOldList = Json.serialize(mapOldUsers);
            }
            psa_us_UserAutomation.contactInsertUpdate(sNewItems,sOldList);
            //psa_us_UserAutomation.assignmentInsertUpdate(sNewItems,sOldList);//<T10>
        }
    }
    
    
    //T08 Start
    //T06 - IN: To Avoid Duplicate User NickNames in the Community and generate new nickname for the new users in specifc format : john.redm_12
    //T09 Start : Optimize the nickname updation logic for IN & KB user
    public static void userBeforeInsertOrUpdate(List<User> userlist, Map<Id,User> oldMap, Boolean isInsert){
        Map<String,User> userMapInsert = new Map<String, User>(); // to handle Nickname population during user insertion
        Map<String,User> userMapUpdate = new Map<String, User>(); // to handle Nickname population during user updation
        List<User> userListInsert      = new List<User>();        // to handle Nickname population during user insertion for duplicates in same transaction
        String Pid =[Select id from profile where name='External Identity Community'].Id;
        
        try{
            for(user us : userlist){
                
                if(us.profileId == Pid){    //Profile check added specifically to handle IN and KB community users' Nickname population.           
                    if(isInsert && us.FirstName != null && us.LastName != null){
                        if(us.FirstName.length() >= 4 && us.LastName.length() >= 4){
                            us.CommunityNickname = us.FirstName.substring(0,4).capitalize() + '.' + us.LastName.substring(0,4).capitalize();
                        }
                        else if(us.FirstName.length() < 4 && us.LastName.length() >= 4){
                            us.CommunityNickname = us.FirstName.substring(0,1).capitalize() + '.' + us.LastName.substring(0,4).capitalize();
                        }
                        else if(us.FirstName.length() >= 4 && us.LastName.length() < 4){
                            us.CommunityNickname = us.FirstName.substring(0,4).capitalize() + '.' + us.LastName.substring(0,1).capitalize();
                        }
                        else if(us.FirstName.length() < 4 && us.LastName.length() < 4){
                            us.CommunityNickname = us.FirstName.substring(0,1).capitalize() + '.' + us.LastName.substring(0,1).capitalize();
                        }
                        
                        if(userMapInsert.containsKey(us.CommunityNickname)){
                            userListInsert.add(us); 
                        }
                        else{
                            userMapInsert.put(us.CommunityNickname, us);
                        }                    
                    } 
                    else if(!isInsert && (us.CommunityNickname != oldMap.get(us.Id).CommunityNickname)){
                        if (userMapUpdate.containsKey(us.CommunityNickname)) {
                            us.CommunityNickname.addError('Nickname already exists');
                        } 
                        else {
                            userMapUpdate.put(us.CommunityNickname, us);
                        }                
                    }   
                } 
            }
            
            if(userMapUpdate != null){
                isDuplicateNickName(userMapUpdate,isInsert);
            }
            if(userMapInsert != null){
                isDuplicateNickName(userMapInsert,isInsert);
            }
            if(userListInsert != null){
                generateNewNickName(userListInsert);
            }
        }
        catch(Exception exp){
            System.debug('Exception occured in UserTriggerHandler.userBeforeInsertOrUpdate'+exp.getMessage());
        }
    }
    
    public static void isDuplicateNickName(Map<String,User> userMap,Boolean isInsert){
        
        List<User> userList = [SELECT CommunityNickname FROM User WHERE CommunityNickname IN :userMap.KeySet()];
        if(userList.size() > 0 && isInsert){
            List<User> userListToRegenerate = new List<User>();
            for(User objUser : userList){
                userListToRegenerate.add(userMap.get(objUser.CommunityNickname));//Check for existing Users with Duplicate nicknames               
            }
            if(userListToRegenerate != null && userListToRegenerate.size() > 0){
                generateNewNickName(userListToRegenerate); //If Nickname duplicate , generate nickname by appending random 2 digit number
            }
        }
        else if(userList.size() > 0 && !isInsert){
            
            for(User objUser :userList){
                User duplicateNickname = userMap.get(objUser.CommunityNickname);
                duplicateNickname.CommunityNickname.addError('Nickname already exists');//During update , if provided Nickname already exists , add error
            }       
        }
    }
    
    public static void generateNewNickName(List<User> userList){
        Map<String,User> userMapDupeCheck = new Map<String,User>();
        
        if(userList.size() > 0){
            
            for(User us : userList){
                if(us.FirstName.length() >= 4 && us.LastName.length() >= 4){
                    us.CommunityNickname = us.FirstName.substring(0,4).capitalize() + '.' + us.LastName.substring(0,4).capitalize() + '_' + Integer.valueof((Math.random() * 99));
                }
                else if(us.FirstName.length() < 4 && us.LastName.length() >= 4){
                    us.CommunityNickname = us.FirstName.substring(0,1).capitalize() + '.' + us.LastName.substring(0,4).capitalize() + '_' + Integer.valueof((Math.random() * 99));
                }
                else if(us.FirstName.length() >= 4 && us.LastName.length() < 4){
                    us.CommunityNickname = us.FirstName.substring(0,4).capitalize() + '.' + us.LastName.substring(0,1).capitalize() + '_' + Integer.valueof((Math.random() * 99));
                }
                else if(us.FirstName.length() < 4 && us.LastName.length() < 4){
                    us.CommunityNickname = us.FirstName.substring(0,1).capitalize() + '.' + us.LastName.substring(0,1).capitalize() + '_' + Integer.valueof((Math.random() * 99));
                }
                
                userMapDupeCheck.put(us.CommunityNickname,us);
            }
            if(userMapDupeCheck.size() > 0){
                isDuplicateNickName(userMapDupeCheck,true);//Check if the system already has any duplicate nickname matching appended random number
            }
        }       
    }
    //T08 End
    //T09 End
}