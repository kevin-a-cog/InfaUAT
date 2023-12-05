/*
@created by       : Vivek Warrier
@created on       : 10/12/2020
@Purpose          : User Trigger calls this to initiate future methods to update Contacts and Permission Set Group Assignments
@Testclass        : 
@JIRA             : STC-120


Change History
**************************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                                     Jira No.       Tag
**************************************************************************************************************************************
Vivek W         16-Feb-2021     Rhapsody            Adding the default Account Id on contact on create                              T1
Vivek W         26-Feb-2021     Rhapsody            Adding Permission Set Licenses for CPQ to Ops and DD                            T2
Wasim           6-Aug-2021      PSA-1911            Populating the Mailing Country in Contact from the User record                  T3
Vivek W         30-Sep-2021     Neha Kumari         Adding additional updates from User to Contact                        PSA-1891  T4
Vivek W         22-Feb-2022     Neha Kumari         User to Contact Changes, Removal of Comments                          PSA-2275  T5
Wasim           25-Apr-2022     PSA June build      Adding checks to update only PSA related contacts and adding          PSA-2337  T6 
                                                    error handling for contact upsert
Vivek W         30-May-2022     PSA June Build      Adding code to optimize User to Contact update                        PSA-2337  T7                                              
Wasim           27-Oct-2022     PSA Nov Build       Adding logic to update the failed record id in the Exception log      PSA-2661  T8
Wasim           07-Oct-2023      Tech Debt           Removed the PSG and PSL assignment and moved it to User Provisioning PSA-3226  T9 
*/
public class psa_us_UserAutomation {
    public static globalApexManager GAM = new globalApexManager(); //<T6>
    @testVisible
    private static Boolean skipCondition = false;
    @future
    public static void contactInsertUpdate(String sNewItems,string sOldList){
        system.debug('sNewItems: ' + sNewItems + '\nsOldList:' + sOldList);
        Map<Id,User> triggerNew = (Map<Id,User>)System.Json.deserialize(sNewItems,Map<Id,User>.class);//T7
        Map<Id,User> oldMap = null;        
        Set<Id> managerIdSet = new Set<Id>();//T4
        if(sOldList!=null && sOldList!=''){
            oldMap = (Map<Id,User>)System.Json.deserialize(sOldList,Map<Id,User>.class);
        }
        //Map<Id,UserRole> roleMap = new Map<Id,UserRole>([SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName LIKE 'PS%']); //<T6> - Commented this code since Community Users also have some roles that starts with PSA,PSL,etc.
        Map<Id,UserRole> roleMap = new Map<Id,UserRole>([SELECT Id, Name, DeveloperName FROM UserRole WHERE Name LIKE 'PS %']); //<T6> //Replaced the above line with this to get only FF related Roles.
        List<String> existingUser = new List<String>();
        //Map<String,User> userMap = new Map<String,User>();
        //List<String> UserDeactivatedList = new List<String>();
        //Map<Id,User> userChangeMap = new Map<Id,User>();
        //Map<Id,User> genericChangeMap = new Map<Id,User>();//T4
        //<T05>
        List<String> userCreate = new List<String>();
        List<String> userRecreate = new List<String>();
        List<String> userDeactivate = new List<String>();
        List<String> userTransfer = new List<String>();
        List<String> userUpdate = new List<String>();
        //</T05>

        //T7
        Map<Id,Boolean> hasSFUser = new Map<Id,Boolean>();
        //T7
        
        System.debug('RoleMap: ' + roleMap);
        Map<String,User_Role_Mapping__mdt> userRoleMap = new Map<String,User_Role_Mapping__mdt>();
        
        Map<Id,Id> mapUserToContactIds = new Map<Id,Id>();//T4
        Map<Id,String> contactsToUpdate = new Map<Id,String>();
        List<Contact> contactsToInsert = new List<Contact>();

        Account[] defaultAccount = [SELECT Id FROM Account WHERE Name = :Label.Informatica_Account_Name LIMIT 1]; //T1
        //pse__Grp__c[] defaultGroup = [SELECT Id FROM pse__Grp__c WHERE Name = :Label.Default_Resource_Group LIMIT 1]; <T6> - Commenting this line since it is not used anywhere below - unnecessary SOQL
        //pse__Practice__c[] defaultSubcontractorPractice = [SELECT Id FROM pse__Practice__c WHERE Name =:Label.Default_Subcontractor_Practice LIMIT 1];
        //pse__Grp__c[] defaultSubcontractorGroup = [SELECT Id FROM pse__Grp__c WHERE Name =:Label.Default_Subcontractor_Group LIMIT 1];
        //pse__Region__c [] defaultSubcontractorRegion = [SELECT Id FROM pse__Region__c WHERE Name =:Label.Default_Subcontractor_Region LIMIT 1];

        for(User_Role_Mapping__mdt urm : [SELECT Id, Active__c, DeveloperName, User_Role_Grouping__c, MasterLabel FROM User_Role_Mapping__mdt WHERE Active__c = true]){
            userRoleMap.put(urm.DeveloperName,urm);
        }

        //<T5>
        //Checking to see if the User records 
        for(User u : triggerNew.values()){
            managerIdSet.add(u.ManagerId); //T4
            if(oldMap != null){
                if((roleMap.get(oldMap.get(u.Id).UserRoleId) == null && roleMap.get(u.UserRoleId) != null) || 
                (oldMap.get(u.Id).IsActive == false && u.IsActive == true && roleMap.get(u.UserRoleId) != null) ||
                (roleMap.get(oldMap.get(u.Id).UserRoleId) != null && roleMap.get(u.UserRoleId) != null && oldMap.get(u.Id).UserRoleId != u.UserRoleId && roleMap.get(u.UserRoleId).DeveloperName.startsWith('PS')) ||
                oldMap.get(u.Id).Department != u.Department && u.Department != null && u.Department?.startsWith('IPS')){
                    userRecreate.add(u.Email);
                }
                else if((roleMap.get(oldMap.get(u.Id).UserRoleId) != null && u.UserRoleId == null) || 
                (oldMap.get(u.Id).IsActive == true && u.IsActive == false && roleMap.get(oldMap.get(u.Id).UserRoleId) != null)){
                    userDeactivate.add(u.Email);
                }
                else if((roleMap.get(oldMap.get(u.Id).UserRoleId) != null && roleMap.get(u.UserRoleId) != null && 
                oldMap.get(u.Id).UserRoleId != u.UserRoleId && !roleMap.get(u.UserRoleId)?.DeveloperName.startsWith('PS')) ||
                oldMap.get(u.Id).Department != u.Department && u.Department != null && !u.Department?.startsWith('IPS')){
                    userTransfer.add(u.Email);
                }
                //T4
                //<Specific Updates> 
                else if(roleMap.get(u.UserRoleId) != null && (oldMap.get(u.Id).ManagerId != u.ManagerId ||
                ///oldMap.get(u.Id).CurrencyIsoCode != u.DefaultCurrencyIsoCode ||
                oldMap.get(u.Id).FirstName != u.FirstName ||
                oldMap.get(u.Id).LastName != u.LastName ||
                oldMap.get(u.Id).Title != u.Title ||
                oldMap.get(u.Id).Phone != u.Phone ||
                oldMap.get(u.Id).MobilePhone != u.MobilePhone ||
                oldMap.get(u.Id).Country != u.Country ||
                oldMap.get(u.Id).City != u.City ||
                oldMap.get(u.Id).State != u.State ||
                oldMap.get(u.Id).PostalCode != u.PostalCode)){                    
                    userUpdate.add(u.Email);
                }
                //</T4>
            }
            else if(roleMap.get(u.UserRoleId) != null){
                userCreate.add(u.Email);
            }
        }

        System.debug('@@@userCreate: ' + userCreate);
        System.debug('@@@userRecreate: ' + userRecreate);
        System.debug('@@@userDeactivate: ' + userDeactivate);
        System.debug('@@@userTransfer: ' + userTransfer);
        System.debug('@@@userUpdate: ' + userUpdate);

        if(userCreate.size() > 0 || userRecreate.size() > 0 || userDeactivate.size() > 0 || userTransfer.size() > 0 || userUpdate.size() > 0){//userMap.size() > 0 || UserDeactivatedList.size() > 0 || userChangeMap.size() > 0 || genericChangeMap.size() > 0){ 
            
            //<T6> - Adding extra checks in the below for loop SOQL to filter only PSA Account related contacts for the update
            for(Contact c: [SELECT Id, Email, pse__Salesforce_User__c, pse__Salesforce_User__r.UserRoleId, pse__Is_Resource__c, pse__Is_Resource_Active__c FROM Contact 
                            WHERE ((Email IN: userCreate OR Email IN: userRecreate OR Email IN: userDeactivate OR Email IN: userTransfer OR Email IN: userUpdate) 
                            OR pse__Salesforce_User__c IN: triggerNew.keySet()) //T7
                            AND pse__Is_Resource__c = true AND psa_Employee_Type__c != null AND Account.Name = 'Informatica LLC PSA']){ //T6,T7
                //<T7>
                hasSFUser.put(c.pse__Salesforce_User__c,false);
                if(triggerNew.containsKey(c.pse__Salesforce_User__c)){
                    hasSFUser.put(c.pse__Salesforce_User__c,true);//Has a Salesforce User linked, and it is part of this transaction
                }
                //</T7>
                if(userCreate.contains(c.Email) || userRecreate.contains(c.Email)){
                    contactsToUpdate.put(c.Id,'Recreate');
                    existingUser.add(c.Email);
                }
                else if(userDeactivate.contains(c.Email)){
                    contactsToUpdate.put(c.Id,'Deactivate'); existingUser.add(c.Email);
                }
                else if(userTransfer.contains(c.Email)){
                    contactsToUpdate.put(c.Id,'Transfer');
                    existingUser.add(c.Email);
                }
                else if(userUpdate.contains(c.Email)){
                    contactsToUpdate.put(c.Id,'Update');
                    existingUser.add(c.Email);
                }
                /**<T4> putting this in else if to stop override of contactsToUpdate Map with null value, if it is already added in the previous branch *
                else if(genericChangeMap.containsKey(c.pse__Salesforce_User__c)){
                    contactsToUpdate.put(c.Id,null);
                    existingUser.add(c.Email);
                }
                *</T4> */
                //<T5>
            }
        }
		
        //Getting the contact corresponding to the User, to populate the ReportsTo on the contact based on the ManagerId on User <T4>
        for(Contact c : [Select Id,Email,pse__Salesforce_User__c,pse__Salesforce_User__r.Email FROM Contact WHERE pse__Salesforce_User__c IN :managerIdSet AND pse__Is_Resource__c = true AND psa_Employee_Type__c != null AND Account.Name = 'Informatica LLC PSA']){
            if(c.Email == c.pse__Salesforce_User__r.Email && c.Email != null && c.Email != ''){
                mapUserToContactIds.put(c.pse__Salesforce_User__c,c.Id);
            }
        }
        //</T4>

        //Creation of a new contact
        for(User u : triggerNew.values()){                
            if(hasSFUser.get(u.Id) == null && !existingUser.contains(u.Email) && u.IsActive && (roleMap.get(u.UserRoleId)!=null  && roleMap.get(u.UserRoleId).Name != 'PS SSC') ){
                Contact cTemp = new Contact();
                cTemp.FirstName = u.FirstName;
                cTemp.LastName = u.LastName;
                cTemp.pse__Salesforce_User__c = u.Id;
                cTemp.pse__Is_Resource__c = true;
                if(roleMap.get(u.UserRoleId) != null){
                    if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
                        System.debug('***UTH - Masterlabel: ' + userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).MasterLabel);
                        cTemp.pse__Resource_Role__c = userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).MasterLabel;
                        if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Subcontractor'){
                            cTemp.pse__External_Resource__c = true;
                            cTemp.psa_Employee_Type__c = 'Independent Contractor';//<T5>
                        }
                        else{
                            /*<T5> */
                            if(u.Department != null){
                                if(u.Department.startsWith('IPS')){
                                    cTemp.psa_Employee_Type__c = 'Informatica-PS';
                                }
                                else{
                                    cTemp.psa_Employee_Type__c = 'Informatica-Non PS';
                                }
                            }
                            /*</T5> */
                        }
                    }
                }
                cTemp.Email = u.Email;
                cTemp.Phone = u.Phone;
                cTemp.Sync_to_MKTO__c = false;
                cTemp.MailingCountry = u.Country; //<T3> 
                //<T5>  
                cTemp.MailingCity = u.City;
                cTemp.MailingState = u.State;
                cTemp.MailingPostalCode = u.PostalCode;
                cTemp.Title = u.Title;
                cTemp.MobilePhone = u.MobilePhone; 
                //</T5>
                /*********************<T4>***************** */
                Date myDate = Date.newinstance(u.CreatedDate.year(), u.CreatedDate.month(), u.CreatedDate.day());
                cTemp.pse__Start_Date__c = myDate;
                cTemp.CurrencyIsoCode = u.DefaultCurrencyIsoCode;
                if(mapUserToContactIds.containsKey(u.ManagerId)){
                    cTemp.ReportsToId = mapUserToContactIds.get(u.ManagerId);
                }
                /*********************</T4>**************** */
                if(defaultAccount[0].Id != null)
                    cTemp.AccountId = defaultAccount[0].Id;
                contactsToInsert.add(cTemp);
            }
        }
        
        //Update of an existing Contact
        List<Contact> contactsListToUpdate = new List<Contact>();
        if(contactsToUpdate.size() > 0){
            Map<String,User> psuserMap = new Map<String,User>();
            for(User u : [SELECT Id, Email, UserRoleId, CreatedDate, /*CurrencyIsoCode, DefaultCurrencyIsoCode,*/ ManagerId,
                            FirstName, LastName, Title, Phone, MobilePhone, Country, City, State, PostalCode, Department FROM User 
                            WHERE Email IN: userCreate OR Email IN: userRecreate OR Email IN: userDeactivate OR Email IN: userTransfer OR Email IN: userUpdate]){
                psuserMap.put(u.Email,u);
            }
            
            System.debug('contactsToUpdate: ' + contactsToUpdate);
            for(Contact c: [SELECT Id, Email, ReportsToId, /*CurrencyIsoCode,*/ pse__Salesforce_User__c,pse__Salesforce_User__r.UserRoleId,
                                    pse__Is_Resource__c,pse__Is_Resource_Active__c, pse__Start_Date__c, pse__Last_Date__c, FirstName, LastName, 
                                    Phone, Title, MobilePhone, pse__Resource_Role__c, pse__External_Resource__c, psa_Employee_Type__c,
                                    MailingCountry, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id IN: contactsToUpdate.keySet()]){
                System.debug('contactsToUpdate.get(c.Id): ' + contactsToUpdate.get(c.Id)); 
                if(hasSFUser.get(c.pse__Salesforce_User__c) || skipCondition){ //<T7>
                    if(contactsToUpdate.get(c.Id) == 'Recreate'){
                        c.pse__Is_Resource__c = true;
                        c.pse__Is_Resource_Active__c = true;
                        if(psuserMap.get(c.Email) != null){ 
                            c.pse__Salesforce_User__c = psuserMap.get(c.Email).Id;
                            System.debug('FF:::-->>' + roleMap);
                            System.debug('FF:::-->>' + psuserMap.get(c.Email).UserRoleId);  
                            System.debug('FF:::-->>' + roleMap.get(psuserMap.get(c.Email).UserRoleId)); 
                            System.debug('FF:::-->>' + roleMap.get(psuserMap.get(c.Email).UserRoleId).DeveloperName);   
                            System.debug('FF:::-->>' + userRoleMap.get(roleMap.get(psuserMap.get(c.Email).UserRoleId).DeveloperName).MasterLabel);  
                            /*<T4>*/ 
                            c.pse__Last_Date__c = null;
                            /*</T4>*/
                            //Updates to pse__Resource_Role__c, ReportsToId, pse__Start_Date__c handled in the Update(OR)Recreate branch
                        }
                    }
                    else if(contactsToUpdate.get(c.Id) == 'Deactivate'){c.pse__Is_Resource_Active__c = false;                    
                        /*<T4>*/
                        Date myDate = Date.newinstance(psuserMap.get(c.Email).CreatedDate.year(), psuserMap.get(c.Email).CreatedDate.month(), psuserMap.get(c.Email).CreatedDate.day());
                        if(c.pse__Start_Date__c == null && psuserMap.get(c.Email) != null) c.pse__Start_Date__c = myDate; c.pse__Last_Date__c = Date.Today(); 
                        /*</T4>*/
                    }
                    else if(contactsToUpdate.get(c.Id) == 'Transfer'){
                        c.pse__Is_Resource_Active__c = false;  
                        c.ReportsToId = null;//<T5>              
                        /*<T4>*/
                        Date myDate = Date.newinstance(psuserMap.get(c.Email).CreatedDate.year(), psuserMap.get(c.Email).CreatedDate.month(), psuserMap.get(c.Email).CreatedDate.day());
                        if(c.pse__Start_Date__c == null && psuserMap.get(c.Email) != null) c.pse__Start_Date__c = myDate;
                        c.pse__Last_Date__c = Date.Today(); 
                        /*</T4>*/
                    }
                    //In case of reactivation of a user/transfer back to PS, or any update of specific fields (find "<Specific Updates>"), these fields should sync
                    //This need not happen in case of transfer from a PS Role or Department to another Role/Department
                    if(contactsToUpdate.get(c.Id) == 'Update' || contactsToUpdate.get(c.Id) == 'Recreate'){
                    /**<T4> */
                        if(psuserMap.get(c.Email) != null){
                            /*<T5> */
                            c.FirstName = psuserMap.get(c.Email).FirstName;
                            c.LastName = psuserMap.get(c.Email).LastName;
                            c.Title = psuserMap.get(c.Email).Title;
                            c.Phone = psuserMap.get(c.Email).Phone;
                            c.MobilePhone = psuserMap.get(c.Email).MobilePhone;
                            c.pse__Resource_Role__c = userRoleMap.get(roleMap.get(psuserMap.get(c.Email).UserRoleId).DeveloperName).MasterLabel;
                            if(userRoleMap.get(roleMap.get(psuserMap.get(c.Email).UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Subcontractor'){
                                c.pse__External_Resource__c = true;
                                c.psa_Employee_Type__c = 'Independent Contractor';
                            }
                            else{ 
                                if(psuserMap.get(c.Email)?.Department != null){                           
                                    if(psuserMap.get(c.Email).Department.startsWith('IPS')){
                                        c.psa_Employee_Type__c = 'Informatica-PS';
                                    }
                                    else{
                                        c.psa_Employee_Type__c = 'Informatica-Non PS';
                                    } 
                                }                           
                            } 
                            c.MailingCountry = psuserMap.get(c.Email).Country;
                            c.MailingCity = psuserMap.get(c.Email).City;
                            c.MailingState = psuserMap.get(c.Email).State;
                            c.MailingPostalCode = psuserMap.get(c.Email).PostalCode;
                            /*</T5> */
                            if(mapUserToContactIds.get(psuserMap.get(c.Email).ManagerId) != null) c.ReportsToId = mapUserToContactIds.get(psuserMap.get(c.Email).ManagerId);
                            //c.CurrencyIsoCode = psuserMap.get(c.Email).DefaultCurrencyIsoCode;
                            Date myDate = Date.newinstance(psuserMap.get(c.Email).CreatedDate.year(), psuserMap.get(c.Email).CreatedDate.month(), psuserMap.get(c.Email).CreatedDate.day());
                            if(c.pse__Start_Date__c == null && psuserMap.get(c.Email) != null) c.pse__Start_Date__c = myDate;
                        }
                    }
                    /**</T4> */
                    contactsListToUpdate.add(c);
                } //</T7>
            }
        }
        system.debug('@@@contactsToInsert:'+contactsToInsert);
        system.debug('@@@contactsListToUpdate:'+contactsListToUpdate);
        if(contactsToInsert.size() > 0 || contactsListToUpdate.size() > 0){
            List<Contact> lstUpsert = new List<Contact>();
            if(contactsToInsert.size() > 0){
                lstUpsert.AddAll(contactsToInsert);
            }
            if(contactsListToUpdate.size() > 0){
                lstUpsert.AddAll(contactsListToUpdate);
            }
            //<T8>
            List<string> strList= new List<string> ();
            for(Contact c: lstUpsert){
                if(String.IsBlank(c.Id)){
                    strList.add(String.valueOf(c.pse__Salesforce_User__c));//On Contact insert, get the user id
                }
                if(String.IsNotBlank(c.Id)){
                    strList.add(String.valueOf(c.Id)); //On Contact update, get the contact id
                }
            }
            string operationMode = '';
            if(contactsToInsert.size() > 0){
                operationMode = operationMode + ' INSERT ';
            }
            if(contactsListToUpdate.size() > 0){
                operationMode = operationMode + ' UPDATE ';
            }

            String recordIds = string.join(strList,',');           
            system.debug('@@@recordIds:'+recordIds);
            //</T8>
            //<T6> - Adding try catch block and storing the error logs in Exceptions_Log__c
            try{
                upsert lstUpsert;
            }
            catch(Exception e){                
                GAM.CreateExceptionRecords('psa_us_UserAutomation --> contactInsertUpdate '+ operationMode, e.getMessage(), recordIds);
            }
            //</T6>
        }        
    }
    /* //<T9> - Commented the method and moved the logic to User Provisioning
    @future
    public static void assignmentInsertUpdate(String sNewItems,string sOldList){
        Map<Id,User> triggerNew = (Map<Id,User>)System.Json.deserialize(sNewItems,Map<Id,User>.class);
        Map<Id,User> oldMap = null;
        if(sOldList!=null && sOldList!=''){
            oldMap = (Map<Id,User>)System.Json.deserialize(sOldList,Map<Id,User>.class);
        }
        Map<Id,UserRole> roleMap = new Map<Id,UserRole>([SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName LIKE 'PS%']);
        List<String> existingUser = new List<String>();
        Map<String,User> userMap = new Map<String,User>();
        List<String> UserDeactivatedList = new List<String>();
        Map<Id,User> userChangeMap = new Map<Id,User>();
        
        System.debug('RoleMap: ' + roleMap);
        Map<String,User_Role_Mapping__mdt> userRoleMap = new Map<String,User_Role_Mapping__mdt>();
        Map<Id,List<Id>> userIdToAssignmentIds = new Map<Id,List<Id>>();
        Map<Id,List<Id>> userIdToLicenseAssignmentIds = new Map<Id,List<Id>>();
        Map<String, PermissionSetGroup> psgMap = new Map<String, PermissionSetGroup>();
        List<PermissionSetAssignment> AssignmentstoInsert = new List<PermissionSetAssignment>();
        Set<Id> AssignmentstoDelete = new Set<Id>();
        Set<Id> PSLAssignmentstoDelete = new Set<Id>();

        //<T2>
        //PermissionSetLicense Assignment Code
        List<PermissionSetLicense> pslList = new List<PermissionSetLicense>([SELECT Id,DeveloperName FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQAAPerm' OR DeveloperName = 'SalesforceCPQ_CPQStandardPerm']);
        List<PermissionSetLicenseAssign> pslAssignmentstoInsert = new List<PermissionSetLicenseAssign>();
        //</T2>
        
        
        for(User_Role_Mapping__mdt urm : [SELECT Id, Active__c, DeveloperName, User_Role_Grouping__c, MasterLabel FROM User_Role_Mapping__mdt WHERE Active__c = true]){
            userRoleMap.put(urm.DeveloperName,urm);
        }

        for(PermissionSetGroup psg : [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName LIKE 'PSA%' AND Status = 'Updated']){
            psgMap.put(psg.DeveloperName,psg);
        }
        System.debug('psgMap: ' + psgMap);

        if(oldMap != null){
            for(User u : [SELECT Id, (SELECT Id, PermissionSetGroup.DeveloperName FROM PermissionSetAssignments WHERE PermissionSetGroup.DeveloperName LIKE 'PSA%' LIMIT 1), (SELECT Id FROM PermissionSetLicenseAssignments WHERE PermissionSetLicense.DeveloperName = 'SalesforceCPQ_CPQAAPerm' OR PermissionSetLicense.DeveloperName = 'SalesforceCPQ_CPQStandardPerm' LIMIT 2) FROM User WHERE Id IN :oldMap.keySet()]){
                for(PermissionSetAssignment psa : u.PermissionSetAssignments){
                    if(userIdToAssignmentIds.containsKey(u.Id)){
                        userIdToAssignmentIds.get(u.Id).add(psa.Id);
                    }
                    else
                    {
                        userIdToAssignmentIds.put(u.Id,new List<Id>{psa.Id});
                    }
                }
                if(u.PermissionSetLicenseAssignments.size() > 0){
                    for(PermissionSetLicenseAssign psla : u.PermissionSetLicenseAssignments){
                        if(userIdToLicenseAssignmentIds.containsKey(u.Id)){
                            userIdToLicenseAssignmentIds.get(u.Id).add(psla.Id);
                        }
                        else
                        {
                            userIdToLicenseAssignmentIds.put(u.Id,new List<Id>{psla.Id});
                        }
                    }
                }
            }
        }

        for(User u : triggerNew.values()){
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
                if(u.IsActive){
                    Id groupId = null;
                    Boolean requiresPSL = false;
                    userMap.put(u.Email,u);
                    System.debug('u.userroleid: ' + u.UserRoleId);
                    if(roleMap.get(u.UserRoleId) != null){    
                        if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
                            if(psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c) != null){
                                groupId = psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c).Id;
                                //<T2>
                                System.debug('1) Group Name: ' + roleMap.get(u.UserRoleId).DeveloperName);
                                if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Deal_Desk' || userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Operations' || userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Sales'){
                                    requiresPSL = true;
                                }
                                //</T2>
                            }
                        }
                    }
                    if(groupId != null){
                        PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = groupId,AssigneeId = u.Id);
                        AssignmentstoInsert.add(assignment);
                        //<T2>
                        if(requiresPSL){
                            List<PermissionSetLicenseAssign> pslAssignment = new List<PermissionSetLicenseAssign>();
                            pslAssignment.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = pslList[0].Id,AssigneeId = u.Id));
                            pslAssignment.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = pslList[1].Id,AssigneeId = u.Id));
                            pslAssignmentstoInsert.addAll(pslAssignment);
                        }
                        //</T2>
                    }
                }
            }
        }

        if(oldMap != null){
            //Deleting and re-inserting the PermissionSetAssignment for reactivated/role changed to PS
            for(User u : userMap.values()){
                if(userIdToAssignmentIds.get(u.Id)!= null) AssignmentstoDelete.addAll(userIdToAssignmentIds.get(u.Id));
                if(userIdToLicenseAssignmentIds.get(u.Id)!= null) PSLAssignmentstoDelete.addAll(userIdToLicenseAssignmentIds.get(u.Id));                
                if(u.IsActive){
                    Id groupId = null;
                    Boolean requiresPSL = false;            
                    if(roleMap.get(u.UserRoleId) != null){    
                        if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
                            if(psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c) != null){
                                groupId = psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c).Id;
                                //<T2>
                                System.debug('2) Group Name: ' + roleMap.get(u.UserRoleId).DeveloperName);
                                if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Deal_Desk' || userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Operations' || userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Sales'){
                                    requiresPSL = true;
                                }
                                //</T2>
                            }
                        }
                    }
                    if(groupId != null){
                        PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = groupId,AssigneeId = u.Id);
                        AssignmentstoInsert.add(assignment);
                        //<T2>
                        if(requiresPSL){
                            List<PermissionSetLicenseAssign> pslAssignment = new List<PermissionSetLicenseAssign>();
                            pslAssignment.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = pslList[0].Id,AssigneeId = u.Id));
                            pslAssignment.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = pslList[1].Id,AssigneeId = u.Id));
                            pslAssignmentstoInsert.addAll(pslAssignment);
                        }
                        //</T2>
                    }
                }
            }
        
            //Deleting and re-inserting the PermissionSetAssignment for change from one PS role to another
            for(User u : userChangeMap.values()){
                if(userIdToAssignmentIds.get(u.Id)!= null) AssignmentstoDelete.addAll(userIdToAssignmentIds.get(u.Id));
                if(userIdToLicenseAssignmentIds.get(u.Id)!= null) PSLAssignmentstoDelete.addAll(userIdToLicenseAssignmentIds.get(u.Id));
                if(u.IsActive){
                    Id groupId = null;
                    Boolean requiresPSL = false;
                    if(roleMap.get(u.UserRoleId) != null){    
                        if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName) != null){
                            if(psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c) != null){
                                groupId = psgMap.get(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c).Id;
                                //<T2>
                                System.debug('3) Group Name: ' + roleMap.get(u.UserRoleId).DeveloperName);
                                if(userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Deal_Desk' || userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Operations' || userRoleMap.get(roleMap.get(u.UserRoleId).DeveloperName).User_Role_Grouping__c == 'PSA_Sales'){
                                    requiresPSL = true;
                                }
                                //</T2>
                            }
                        }
                    }
                    if(groupId != null){
                        PermissionSetAssignment assignment = new PermissionSetAssignment(PermissionSetGroupId = groupId,AssigneeId = u.Id);
                        AssignmentstoInsert.add(assignment);
                        //<T2>
                        if(requiresPSL){
                            List<PermissionSetLicenseAssign> pslAssignment = new List<PermissionSetLicenseAssign>();
                            pslAssignment.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = pslList[0].Id,AssigneeId = u.Id));
                            pslAssignment.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = pslList[1].Id,AssigneeId = u.Id));
                            pslAssignmentstoInsert.addAll(pslAssignment);
                        }
                        //</T2>
                    }
                }
            }
        }

        
        
        
        if(AssignmentstoDelete.size() > 0) {
            List<PermissionSetAssignment> AssignmentsListtoDelete = new List<PermissionSetAssignment>([SELECT Id FROM PermissionSetAssignment WHERE Id IN :AssignmentstoDelete]);
            if(AssignmentsListtoDelete.size()>0){
                delete AssignmentsListtoDelete;
            }
        }
        //<T2>
        if(PSLAssignmentstoDelete.size() > 0){
            List<PermissionSetLicenseAssign> pslAssignmentsListtoDelete = new List<PermissionSetLicenseAssign>([SELECT Id FROM PermissionSetLicenseAssign WHERE Id IN :PSLAssignmentstoDelete]);
            if(pslAssignmentsListtoDelete.size()>0){
                delete pslAssignmentsListtoDelete;
            }
        }
        if(pslAssignmentstoInsert.size() > 0) {
            insert pslAssignmentstoInsert;
        }
        //</T2>
        if(AssignmentstoInsert.size() > 0) {
            insert AssignmentstoInsert;
        }
    }
    */ //</T9>
}