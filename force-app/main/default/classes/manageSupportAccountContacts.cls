/*
 * Name         :   manageSupportAccountContacts
 * Author       :   Venky
 * Created Date :   07-JAN-2021
 * Description  :   Controller class for manageSupportAccountContacts LWC.

 Change History
 ******************************************************************************************************************************
 Modified By            Date                Jira No.            Description                                               Tag
 ******************************************************************************************************************************
 Venky                  07-JAN-2021         UTOPIA              Initial version.                                          NA
 Vignesh D              16-NOV-2021         UTOPIA-FF1          Error Handling on removing ACR from Support Account       T01
 Vignesh D              03-MAR-2022         I2RT-5410           Check GCS Admin custom permission                         T02
 balajip                22-FEB-2023         I2RT-7659           to include the Language while fetching the Contact info   T03
 */

public with sharing class manageSupportAccountContacts {

    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}

    //To get all assigned support account contacts for a given support account    
    @AuraEnabled
    public static List<AccountContactRelation> getAccountContactRelation(String searchTerm, String supportAcc){
        String SearchKey =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm)+'%' :'';
        if(String.isNotBlank(supportAcc) ){
            String SOQL;
            List<AccountContactRelation> supportContacts = new List<AccountContactRelation>();
            if(String.isNotBlank(searchTerm)){
                SOQL = 'Select Id,AccountId,ContactId,Contact.AccountId,Contact.Account.Name,Account.Name,Contact.Name,Contact.Email,Contact.Phone, Roles,Contact_Timezone__c, Primary__c,IsActive,Access_Level__c from AccountContactRelation where AccountId =: supportAcc and (Contact.Name Like :SearchKey or Contact.Email Like :SearchKey) order by Contact.Name ASC';
                //SOQL = 'Select Id,AccountId,ContactId,Contact.AccountId,Contact.Account.Name,Account.Name,Contact.Name,Contact.Email,Contact.Phone, Roles,Contact_Timezone__c, Primary__c,IsActive,Access_Level__c from AccountContactRelation where AccountId =: supportAcc and Contact.Name Like :SearchKey order by Contact.Name ASC';
            }
            else{
                SOQL = 'Select Id,AccountId,ContactId,Contact.AccountId,Contact.Account.Name,Account.Name,Contact.Name,Contact.Email,Contact.Phone, Roles,Contact_Timezone__c, Primary__c,IsActive,Access_Level__c  from AccountContactRelation where AccountId =: supportAcc and Contact.Name Like :SearchKey order by Contact.Name ASC';
            }
            
            system.debug('SOQL querty =>'+ SOQL);
            supportContacts = Database.query(SOQL);
            return supportContacts;
        }
        else{
            return null;
        }
    }

    //To get all unassigned contacts under the customer account.
    @AuraEnabled
    public static List<Contact> getUnassignedContacts(String searchTerm, String accountId, String supportAcc){

        system.debug('searchTerm =>'+ searchTerm);
        system.debug('accountId =>'+ accountId);
        system.debug('supportAcc =>'+ supportAcc);

        String SearchKey = searchTerm !=null ?'%'+String.escapeSingleQuotes(searchTerm)+'%' :'';
        if(String.isNotBlank(accountId) && String.isNotBlank(supportAcc)){
            String SOQL;
            List<Contact> contacts = new List<Contact>();
            List<Id> contactIds = new List<Id>();
            for(AccountContactRelation acr : [Select ContactId from AccountContactRelation where AccountId =: supportAcc]){
                contactIds.add(acr.ContactId);
            }

            if(String.isNotBlank(searchTerm)){
                SOQL = 'Select Id,Name,AccountId,Account.Name,Phone,Email,INFA_Language__c from Contact where Id NOT IN (Select ContactId from AccountContactRelation where AccountId =: supportAcc) And AccountId =: accountId and  (Name Like :SearchKey OR email Like :SearchKey) order by Name ASC'; //T03
            }
            else{
                SOQL = 'Select Id,Name,AccountId,Account.Name,Phone,Email,INFA_Language__c from Contact where Id NOT IN (Select ContactId from AccountContactRelation where AccountId =: supportAcc) And AccountId =: accountId order by Name ASC '; //T03
            }
            
            system.debug('SOQL querty =>'+ SOQL);

            contacts = Database.query(SOQL);
            return contacts;
        }
        else{
            return null;
        }
    }

        //Delete AccountContactRelation between contact and support account
        @AuraEnabled
        public static string removeAccountContactRelation(List<AccountContactRelation> supportContacts, String supportAcc){
            String returnMessage;
    
             if(supportContacts != null && supportContacts.size() > 0){
                try{
                    delete supportContacts;
                    returnMessage = 'SUCCESS';
                }
                catch(Exception e){
                    //<T01>
                    //returnMessage = 'Error: '+e.getMessage();
                    throw new AuraHandledException(e.getMessage());
                    //</T01>
                }
            }
    
            return returnMessage;
        }



        
    //Create New Contact form managesupportaccount contacts
    @AuraEnabled
    public static string CreateNewContact(String ContactRec, Id SupportAccountId){
        String returnMessage = 'SUCCESS';
        List<Id> RecTypeIds = new List<Id>();
        Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();    
        Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();    
        RecTypeIds.add(AccRecTypeId_PrtnrAccnt);
        RecTypeIds.add(AccRecTypeId_CustAccnt);
        Id newContactId ;
        System.debug('ContactRec'+ContactRec);
        System.debug('SupportAccountId'+SupportAccountId);
        System.debug('AccRecTypeId_PrtnrAccnt'+AccRecTypeId_PrtnrAccnt);
        System.debug('AccRecTypeId_CustAccnt'+AccRecTypeId_CustAccnt);

        Contact newContact = (Contact)JSON.deserialize(ContactRec, Contact.class);
        System.debug('newContact'+newContact);
        try{

            Account CustAccount = [Select id,ParentId from account where id =:SupportAccountId];
    
            if(newContact!= null& newContact.email!= null){
                List<Contact> lstDupContacts = [Select Id,Name,Timezone__c,INFA_Language__c, MailingCountry,Account.BillingCountry,AccountId,Account.RecordtypeId,Account.Recordtype.Name from contact where email = :newContact.email and Account.RecordtypeId in : RecTypeIds limit 1  ];

                System.debug('lstDupContacts'+lstDupContacts);

                if(lstDupContacts?.size()>0){
                    Contact dupContact = lstDupContacts[0];
                    Contact updateContact = new Contact(Id =dupContact.Id );
                    updateContact.Timezone__c = newContact.Timezone__c != null ? newContact.Timezone__c : (dupContact.Timezone__c!= null?dupContact.Timezone__c :'');
                    updateContact.INFA_Language__c = newContact.INFA_Language__c != null ? newContact.INFA_Language__c : (dupContact.INFA_Language__c!= null?dupContact.INFA_Language__c :'');
                    updateContact.Phone = newContact.Phone != null ? newContact.Phone : (dupContact.Phone!= null?dupContact.Phone :'');
                    updateContact.MailingCountry = newContact.MailingCountry != null ? newContact.MailingCountry : (dupContact.MailingCountry!= null?dupContact.MailingCountry :'');
                    Database.SaveResult sr = Database.update(updateContact) ;
                    newContactId = sr.getId();
                    System.debug('newContactId updated -->'+ newContactId);
                    returnMessage = 'Duplicate Contact is present in system';
                }
                else{
                    if(!CaseControllerWithoutSharing.isLeadExists(newContact.email)){
                        newContact.AccountId = CustAccount.ParentId;
                        Database.SaveResult sr = Database.insert(newContact) ;
                        if(sr.isSuccess()){
                            newContactId = sr.getId();
                        }else{
                            throw new AuraHandledException(sr.getErrors()[0]?.getMessage());
                        }
                        System.debug('newContactId Inserted -->'+ newContactId);
                    }
                    else{
                        throw new CustomException(System.Label.Potential_Duplicate_Lead_Validation_Message);
                    }

                }
            }

            if(newContactId != null &&  SupportAccountId != null){
                List<AccountContactRelation>  lstoldACR = [Select id, ContactId, AccountId from AccountContactRelation where ContactId =:newContactId and AccountId =:SupportAccountId limit 1];

                if (lstoldACR?.size()>0){
                    returnMessage = 'Contact is present in support Account';
                }
                else{
                    AccountContactRelation newAcr = new AccountContactRelation();
                    newAcr.contactId = newContactId;
                    newAcr.AccountId = SupportAccountId;
                    newAcr.Timezone__c = newContact.Timezone__c != null ? newContact.Timezone__c :'';
                    newAcr.Language__c = newContact.INFA_Language__c != null ? newContact.INFA_Language__c : '';
                    newAcr.Phone__c = newContact.Phone != null ? newContact.Phone:'';
                    newAcr.Access_Level__c = newContact.Access_Level__c != null ? newContact.Access_Level__c:'';
                    Database.SaveResult sr = Database.insert(newAcr) ;
                    if(!sr.isSuccess()){
                        throw new AuraHandledException(sr.getErrors()[0]?.getMessage());
                    }
                    System.debug('newAcr Inserted -->'+ sr.getId());

                }

                
            } 

        }catch (Exception e) {
            System.debug(e.getmessage());
            throw new AuraHandledException(e.getMessage());
        }
        return returnMessage;
    }

    //---------------------------------------<T02>------------------------------
    
    /*
     Method Name : checkUserPermission
     Description : This method checks for a specific custom permission assigned to user.
     Parameters  : None.
     Return Type : Booelan.
     */
    @AuraEnabled
    public static Boolean checkUserPermission(){
        String customPermission = 'GCS_Administrative';
        return FeatureManagement.checkPermission(customPermission);
    }

    //---------------------------------------</T02>-----------------------------
     
}