/**
* @description       : 
* @author            : Venky
* @group             : 
* @last modified on  : 01-21-2021
* @last modified by  : SF Developer
* Modifications Log 
* Ver   Date         Author         Modification
* 1.0   01-07-2021   Venky   Initial Version
Change History
*****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
*****************************************************************************************************

Amit GArg      21/06/2021  I2RT-5996   T01     eSupport - Reduce Timezone selection list to avoid incorrect selections
Amit GArg      08/08/2021  I2RT-6736   T02     Admin: Primary Contact not able to create new contact who is already part of another customer account
Vignesh D      22/08/2022  I2RT-6894   T02     Refactor the method and added logic to query ACR and return the wrapper object as JSON string
Vignesh D      31/08/2022  I2RT-7008   T03     Added Access Level field to the query
Amit GArg      10/10/2021  I2RT-7210   T04     PayGo: eSupport caselite detail page to have Add Alternate contact button

**/
public with sharing class ManageCaseContacts {
    
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}
    
    //To get fields map from a given fieldset on an object
    @AuraEnabled    
    public static Map<String,List<String>> getFields(String inputfields) {
        Schema.SObjectType targetType;
        Schema.FieldSet fs;
        String tempstr = ' ';
        Map<String,List<String>> mapTypefields=new Map<String,List<String>>();
        List<Fieldsetwrapper> fswrapperlist = (List<Fieldsetwrapper>) JSON.deserialize(inputfields, List<Fieldsetwrapper>.class);
        
        for(Fieldsetwrapper fswrapper: fswrapperlist){
            system.debug('fswrapper'+fswrapper);
            targetType = Schema.getGlobalDescribe().get(fswrapper.objectName);
            
            Schema.DescribeSObjectResult describe = targetType.getDescribe();
            Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
            
            fs = fsMap.get(fswrapper.fieldSetName);
            
            
            List<Schema.FieldSetMember> fieldSet = fs.getFields();
            if(fieldSet != NULL){
                for(Schema.FieldSetMember fsMember:fieldSet){
                    List<String> lst= new List<String>();
                    lst.add(fsMember.getLabel());
                    lst.add(String.valueOf(fsMember.getType()));
                    if(String.isNotBlank(fswrapper.parentrelationship))    
                        tempstr = fswrapper.parentrelationship + fsMember.getFieldPath();   
                    else         
                        tempstr = fsMember.getFieldPath(); 
                    mapTypefields.put(tempstr,lst);                    
                    
                }
            }
        }
        return mapTypefields;
    }
    
    
    //To get all assigned Case contacts for a given case    
    @AuraEnabled
    public static AssignedCaseContacts getAssignedCaseContacts(String searchTerm, String supportcas, string fields){ //<T02>
        if(String.isBlank(supportcas) || String.isBlank(fields)){
            return null;
        }

        System.debug(fields);
        Set<Id> setContactIds = new Set<Id>();
        AssignedCaseContacts objAssignedCaseContacts = new AssignedCaseContacts();
        objAssignedCaseContacts.lstCaseContacts = new List<Case_Contact__c>();
        objAssignedCaseContacts.lstAccountContacts = new List<AccountContactRelation>();
        Id supportAccountId = [Select Support_Account__c from Case where Id =: supportcas]?.Support_Account__c;
        String strQuery = 'Select Id,Name,Contact__c,'+String.escapeSingleQuotes(fields)+' from Case_Contact__c where case__c = :supportcas';

        searchTerm = String.isNotBlank(searchTerm) ? '%'+String.escapeSingleQuotes(searchTerm)+'%' : searchTerm;
        strQuery = String.isNotBlank(searchTerm) ? strQuery + ' and Contact__r.Name Like :searchTerm order by Name ASC' : strQuery + ' order by Name ASC';
        objAssignedCaseContacts.lstCaseContacts = Database.query(strQuery);

        for(Case_Contact__c objCaseContact : objAssignedCaseContacts.lstCaseContacts){
            setContactIds.add(objCaseContact?.Contact__c);
        }
        objAssignedCaseContacts.lstAccountContacts = [Select ContactId,Access_Level__c from AccountContactRelation Where ContactId IN :setContactIds AND AccountId =: supportAccountId];

        return objAssignedCaseContacts;
    }
    
    //To get all unassigned contacts under the Support account.
    @AuraEnabled
    public static List<AccountContactRelation> getUnassignedCaseContacts(String searchTerm, String caseid,String supportAcc, string fields){
        String SearchKey = '%'+String.escapeSingleQuotes(searchTerm)+'%';
        system.debug('field list'+fields);
        List<Id> conlist = new List<Id>();
        if(String.isNotBlank(supportAcc) && String.isNotBlank(fields) && String.isNotBlank(supportAcc)){
            String SOQL;
            List<AccountContactRelation> contacts = new List<AccountContactRelation>();
            List<Id> accountids = new List<Id>();
            /*for(AccountContactRelation acr : [Select ContactId,contact.AccountId from AccountContactRelation where AccountId =: supportAcc]){
accountids.add(acr.contact.AccountId);
}*/
            
            for(Case_Contact__c cc: [Select Contact__c from Case_Contact__c where Case__c = :caseid]){
                conlist.add(cc.Contact__c);
            }
            
            if(String.isNotBlank(searchTerm)){
                SOQL = 'Select Id,Primary__c,ContactId,Access_Level__c,'+fields+' from AccountContactRelation where AccountId = :supportAcc and ContactId Not in :conlist and Contact.Name Like :SearchKey'; //<T03>
            }
            else{
                SOQL = 'Select Id,Primary__c,ContactId,Access_Level__c,'+fields+'  from AccountContactRelation where AccountId = :supportAcc and ContactId Not in :conlist'; //<T03>
                system.debug('SOQL'+SOQL);
            }
            
            contacts = Database.query(SOQL);
            return contacts;
        }
        else{
            return null;
        }
    }
    
    
    
    
    //Delete Case contact
    @AuraEnabled
    public static string removeCaseContacts(List<Id> casecon){
        String returnMessage;
        
        if(casecon != null){            
            try{
                //List<Id> conids = (List<Id>)JSON.deserialize(casecon, List<Id>.class);               
                DELETE  [SELECT Id FROM Case_Contact__c where Id in :casecon];
                returnMessage = 'SUCCESS';
            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }
        
        return returnMessage;
    }
    
    //Create Case contact
    @AuraEnabled
    public static string createcasecontactcontr(List<Case_Contact__c> casecon, Id supportAcc){
        String returnMessage;
        Set<Id> primaryContactIds = new Set<Id>();
        
        if(casecon != null){            
            try{//<T04> starts
                case c = ((List<Case>)CaseControllerWithoutSharing.getSObjectRecords('select id, recordType.developerName from case where id=\'' + caseCon[0].case__C + '\''))[0];
                string recType = c?.recordType.developerName;
                if(recType == 'Case_Lite'){
                    CaseControllerWithoutSharing.createCaseContacts(casecon);
                }else{//<T04> ends
                    CaseControllerWithoutSharing.createCaseContacts(casecon, supportAcc);
                }
                returnMessage = 'SUCCESS';
            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }
        
        return returnMessage;
    }
    
    //Delete Case contact
    @AuraEnabled
    public static string updatecontacts(List<Contact> contactlist){
        String returnMessage;
        
        if(contactlist != null && contactlist.size() > 0){            
            try{
                //List<Id> conids = (List<Id>)JSON.deserialize(casecon, List<Id>.class);               
                UPDATE contactlist;
                returnMessage = 'SUCCESS';
            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }
        
        return returnMessage;
    }
    
    
    //Add SupportAccount Contacts to Case 
    @AuraEnabled
    public static string addCaseContacts(List<Contact> contacts , String supportcas){
        String returnMessage;
        List<Case_Contact__c> casecontacts = new List<Case_Contact__c>();
        if(contacts != null && contacts.size() > 0){           
            for(Contact c : contacts){
                Case_Contact__c cc = new Case_Contact__c();
                cc.Case__c = supportcas;
                cc.Contact__c = c.Id;
                cc.email__c = c.Email;
            }
            try{
                insert casecontacts;
                returnMessage = 'SUCCESS';
                
            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }
        
        return returnMessage;
    }
    
    public class Fieldsetwrapper{
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public String fieldSetName;
        @AuraEnabled
        public String parentrelationship;
    }
    
    
    //Create New Contact form on esupport CaseCreation and Casedeatil
    @AuraEnabled
    public static string CreateNewContact(String ContactRec, Id SupportAccountId, Id CaseId,string Region, String Location){//<T01>
        String returnMessage = 'SUCCESS';
        List<Id> RecTypeIds = new List<Id>();
        timezone__c tz = [select id,Timezone__c from timezone__c where region__c =: region and location__c =:location limit 1];//<T01>
        Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();    
        Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();    
        RecTypeIds.add(AccRecTypeId_PrtnrAccnt);
        RecTypeIds.add(AccRecTypeId_CustAccnt);
        Id newContactId ;
        
        Contact newContact = (Contact)JSON.deserialize(ContactRec, Contact.class);
        newContact.timezone__c = tz.Timezone__c;//<T01>
        Boolean isExternalUser = [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;
        try{
            
            if((!isExternalUser || !CaseControllerWithoutSharing.isPrimaryContact(SupportAccountId)) ){
                throw new CustomException('INSUFFICIENT ACCESS TO CREATE CONTACT');
            }
            Account SupportAccount = CaseControllerWithoutSharing.getSupportAccount(SupportAccountId)[0];
            
            if(newContact!= null& newContact.email!= null){
                if(CaseControllerWithoutSharing.CheckIFACRExists(newContact.email,SupportAccountId)){//<T02>
                    throw new CustomException('Contact already exist in the System');
                }
                if(CaseControllerWithoutSharing.isContactUnderDifferentAccountExists(newContact.email,SupportAccountId)){//<T02>
                    throw new CustomException(System.label.ErrorMessageForSupportAccount);//<T02>
                }
                if(CaseControllerWithoutSharing.isContactExists(newContact.email)){  
                    throw new CustomException('Contact already exist in the System');//<T02>
                }
                
                /*List<Contact> lstDupContacts = [Select Id,Name,Timezone__c,INFA_Language__c, MailingCountry,Account.BillingCountry,AccountId,Account.RecordtypeId,Account.Recordtype.Name from contact where email = :newContact.email and Account.RecordtypeId in : RecTypeIds limit 1  ];

if(lstDupContacts?.size()>0){
Contact dupContact = lstDupContacts[0];
Contact updateContact = new Contact(Id =dupContact.Id );
returnMessage = 'DUPLICATE';
}else{*/
                if(CaseControllerWithoutSharing.isLeadExists(newContact.email)){
                    throw new CustomException(System.label.Potential_Duplicate_Lead_Validation_Message);//<T02>
                }
                newContact.AccountId = SupportAccount.ParentId;
                newContact.MailingCountry = SupportAccount.Parent.BillingCountry;
                if(isExternalUser){ //Fix for standard error "portal users cannot own partner accounts" when enforcing sharing on class. Default owner of the contact will be set to Support Account's Parent Account's Owner
                    newContact.OwnerId = SupportAccount.Parent.OwnerId;
                }
                //atabase.SaveResult sr = Database.insert(newContact);
                CaseControllerWithoutSharing.createContact(newContact);
                //newContactId = sr.getId();
                newContactId = newContact.Id;
                
            }
            if(newContactId != null &&  SupportAccountId != null){
                List<AccountContactRelation>  lstoldACR = [Select id, ContactId, AccountId from AccountContactRelation where ContactId =:newContactId and AccountId =:SupportAccountId limit 1];
                
                if (lstoldACR?.size()>0){
                    returnMessage = 'CONTACTPRESENT';
                }
                else{
                    AccountContactRelation newAcr = new AccountContactRelation();
                    newAcr.contactId = newContactId;
                    newAcr.AccountId = SupportAccountId;
                    newAcr.Timezone__c = newContact.Timezone__c != null ? newContact.Timezone__c :'';
                    newAcr.Language__c = newContact.INFA_Language__c != null ? newContact.INFA_Language__c : '';
                    newAcr.Phone__c = newContact.Phone != null ? newContact.Phone:'';
                    newAcr.Access_Level__c = newContact.Access_Level__c != null ? newContact.Access_Level__c:'';
                    //Database.SaveResult sr = Database.insert(newAcr) ;
                    AccountContactRelation acrRecord =caseControllerWithoutSharing.createACR(newACR);//<T09>
                    System.debug('newAcr Inserted -->'+acrRecord.id);
                    
                }
                
                
                if(CaseId != null){
                    
                    List<Case_Contact__c> lstcaseCon = [Select id, Contact__c, Case__c from Case_Contact__C where Contact__c =:newContactId and Case__r.Support_Account__c =:SupportAccountId and case__c =:CaseId limit 1];
                    System.debug('lstcaseCon'+lstcaseCon);
                    if (lstcaseCon?.size()>0){
                        returnMessage = 'Contact is added to case already';
                    }
                    else {
                        Case_Contact__c newCaseCon = new Case_Contact__c();
                        newCaseCon.Case__c = CaseId;
                        newCaseCon.Contact__c = newContactId;
                        newCaseCon.email__c = newContact.Email;
                        string ccId = caseControllerWithoutSharing.createCaseContact(newCaseCon) ;
                        System.debug('newCaseCon Inserted -->'+ ccId);
                        returnMessage = 'Contact is added to case successfully';
                        
                    }
                    
                }
            } 
            
            
        }catch (Exception e) {
            
            String message = e.getmessage();//<T02>
            system.debug('@@-2->>'+message);
            //Amarender - Made changes as part of I2RT-4227

            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Please enter Firstname')){
                message = 'Please Enter First Name';
            }
            if(e.getMessage().contains('REQUIRED_FIELD_MISSING, Required fields are missing: [Last Name]')){
                message = 'Please Enter Last Name';
            }
            if(e.getMessage().contains('INVALID_EMAIL_ADDRESS, Email: invalid email address:')){
                message = 'Please Enter valid Email';
            }
            if(e.getMessage().containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION, Max Read/Write contacts limit reached.')){
                message = 'Max Read/Write contacts limit reached';
            }
            //Amarender - Made changes as part of I2RT-4227
            message = message != '' ? message : 'Please Contact your System Administrator';
            system.debug('@@-1->>'+message);
            if(!test.isRunningTest())throw new AuraHandledException(message);
            return null;
        }
        return returnMessage;
    }
    
    
    //<T04> updated whole method to get the alternate contacts/ org users
    @AuraEnabled
    public static List<ContactDetail> getContacts( Id supportAccountId, Id caseId){
        List<AccountContactRelation> contacts = new List<AccountContactRelation>();
        Set<id> setCaseContacts = new set<id>();
        Set<String> setEmailCaseContacts = new Set<String>();
        list<ContactDetail> conList = new list<ContactDetail>();//<T04>
        Id orgId;
        case c = ((List<Case>)CaseControllerWithoutSharing.getSObjectRecords('select id,org__c, recordType.developerName from case where id=\'' + caseId + '\''))[0];
        string caseRecType = c.RecordType.developerName;
        orgId = c.Org__c;
        if(caseRecType == 'Case_Lite'){
            if(!SupportLiteSharing.validateUserAccess('Case','READ',caseId)){
                throw new CustomException('Insufficient access to view the case');
            }
        }
        try {
            
            if(caseId!= null){
                string caseContactQuery = 'Select Contact__c,Email__c from Case_Contact__c where Case__c =\'' + caseId + '\'';
                for(Case_Contact__c cc: (List<Case_Contact__c>)(CaseControllerWithoutSharing.getSObjectRecords(caseContactQuery))){
                    if(String.isNotEmpty(cc?.Contact__c)){
                        setCaseContacts.add(cc.Contact__c);
                    }
                    else{
                        setEmailCaseContacts.add(cc.Email__c);
                    }
                }
            }
            if(caseRecType == 'Case_Lite' && orgId != null){
                string orgUserQuery = 'select id, contact__r.name, contact__r.email, contact__r.phone, contact__c, FirstName__c,LastName__c,Email__c,PhoneNumber__c from org_User__c where org__c = \'' + orgId + '\' AND (Contact__c != null OR Email__c != null) LIMIT 2000';
                list<Org_User__c> users = (List<Org_User__c>)(CaseControllerWithoutSharing.getSObjectRecords(orgUserQuery));
                for(Org_User__c acr: users){
                    if(!setCaseContacts.contains(acr.contact__c) && !setEmailCaseContacts.contains(acr.Email__c)){
                        ContactDetail ac = new ContactDetail();
                        if(String.isNotEmpty(acr?.Contact__c)){
                        ac.name = acr.contact__r.Name;
                        ac.email = acr.contact__r.Email;
                        ac.phone = acr.contact__r.Phone;
                        ac.contactId = acr.contact__c;
                            ac.id = acr.id;
                        }
                        else{
                            ac.name = acr.FirstName__c +' '+ acr.LastName__c;
                            ac.email = acr.Email__c;
                            ac.phone = acr?.PhoneNumber__c;
                            ac.contactId = '';
                            ac.id = acr.id;
                        }
                        conList.add(ac);
            }
                }
            }else if(supportAccountId != null){
                contacts = CaseControllerWithoutSharing.getUnAssignedSupportAccountContacts(supportAccountId, setCaseContacts);
                for(accountContactRelation acr: contacts){
                    ContactDetail ac = new ContactDetail();
                    ac.name = acr.contact.Name;
                    ac.email = acr.contact.Email;
                    ac.phone = acr.contact.Phone;
                    ac.contactId = acr.contactId;
                    ac.id = acr.id; 
                    conList.add(ac);
                }
            }
            return conList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static boolean getPermissionOnObject(){
        Schema.DescribeSObjectResult s = Case_Contact__c.sObjectType.getDescribe();
        Boolean isCreateable = s.isCreateable();
        return isCreateable;
    }
    //<T04> starts
    public class ContactDetail{
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string email;
        @AuraEnabled
        public string phone;
        @AuraEnabled
        public string contactId;
        @AuraEnabled
        public string id;
    }
    //<T04> ends
    public class AssignedCaseContacts{ //<T02>
        @AuraEnabled
        public List<Case_Contact__c> lstCaseContacts;
        @AuraEnabled
        public List<AccountContactRelation> lstAccountContacts;
    }
    
}