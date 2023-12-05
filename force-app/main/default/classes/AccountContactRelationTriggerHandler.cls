/*
Class:          AccountContactRelationTriggerHandler 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Handler Class for AccountContactRelation Triggers

Change History
*********************************************************************************************************************
ModifiedBy  Date            Jira No.    Tag     Description
*********************************************************************************************************************
balajip     02/22/2023      I2RT-7659   T01     Replaced the method updateContacTimeZone with updateContact
                                                and added logic to update the Language on the associated Contact
Vignesh D   5/17/2023       I2RT-8060   T02     Set the datetime on Bypass_DateTime__c everytime a contact is updated.

*/

public without sharing class AccountContactRelationTriggerHandler {

    public static void handleAccountContactRealtionAfterInsert(List<AccountContactRelation> lstnewACR){
        
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();	
        Set<Id> setSupportAccountIds = new Set<Id> ();
        List<AccountContactRelation> lstContactValidation = new List<AccountContactRelation>();

        //get Accounts from contacts
        for(AccountContactRelation acr : lstnewACR){
            setSupportAccountIds.add(acr.AccountId);
        }

        //get support accounts
        Map<Id,Account> mapSupportAccounts =  new Map<Id,Account>([Select id, name from Account where id in: setSupportAccountIds and RecordTypeId = :SupportAccountRecType]);


        //get support account contacts
        if(mapSupportAccounts?.size()>0){
            for(AccountContactRelation acr : lstnewACR){
                if(mapSupportAccounts.containskey(acr.AccountId)){
                    lstContactValidation.add(acr);
                }
            }
        }

        //Check for MaxReadContacts
        if(lstContactValidation?.size()>0){
            supportAccountContactValidation(lstContactValidation);
        }

        updateContact(lstNewACR); //T01
    }

    public static void handleAccountContactRealtionAfterUpdate (List<AccountContactRelation> lstNewACR, map<Id,AccountContactRelation> oldMapACR){
        
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();	
        Set<Id> setSupportAccountIds = new Set<Id> ();
        List<AccountContactRelation> lstContactValidation = new List<AccountContactRelation>();

        //get Accounts from contacts
        for(AccountContactRelation acr : lstnewACR){
            setSupportAccountIds.add(acr.AccountId);
        }

        //get support accounts
        Map<Id,Account> mapSupportAccounts =  new Map<Id,Account>([Select id, name from Account where id in: setSupportAccountIds and RecordTypeId = :SupportAccountRecType]);

        //get support account contacts
        for(AccountContactRelation acr : lstnewACR){
            if(mapSupportAccounts.containskey(acr.AccountId)){
                //check if access level change
                if((acr.Access_level__c!= null && acr.Access_level__c != oldMapACR.get(acr.Id).Access_level__c)||
                    (acr.Primary__c != oldMapACR.get(acr.Id).Primary__c) || acr.IsActive != oldMapACR.get(acr.Id).IsActive){
                        lstContactValidation.add(acr);
                }
            }
        }

        //Check for MaxReadContacts
        if(lstContactValidation?.size()>0){
            supportAccountContactValidation(lstContactValidation);
        }

        updateContact(lstNewACR); //T01
    }

    static void supportAccountContactValidation(List<AccountContactRelation> lstNewACR){

        set<id> setSupportAccountId = new set<id>();
        set<id> hasNoPrimaryContact = new set<Id>();
        set<id> hasmaxContact = new set<id>();
        set<id> hasMorePrimaryContact = new set<id>();

        for(AccountContactRelation acr : lstnewACR){
            setSupportAccountId.add(acr.AccountId);
        }

        for (AggregateResult agr : [SELECT count(Id) countPrimary, AccountId SupportAccount FROM AccountContactRelation where AccountId in :setSupportAccountId and Primary__C = true and isActive = true  group by AccountId]){
           if((Integer)agr.get('countPrimary')<1){
            hasNoPrimaryContact.add((Id)agr.get('SupportAccount'));
           }
            if((Integer)agr.get('countPrimary')>2){
            hasMorePrimaryContact.add((Id)agr.get('SupportAccount'));
           }
           
         
        } 

        for (AggregateResult agr : [SELECT count(Id) countReadWrite, AccountId SupportAccount, Max(Account.Max_Customer_R_W_Contacts__c) maxReadWrite FROM AccountContactRelation where AccountId in :setSupportAccountId and Access_level__c = 'Read/Write' and isActive = true AND (NOT Contact.Email LIKE '%@informatica.com%') group by AccountId]){
            if((Decimal)agr.get('countReadWrite')> (Decimal)agr.get('maxReadWrite')){
                hasmaxContact.add((Id)agr.get('SupportAccount'));
            }
         } 
 
        for(AccountContactRelation acr : lstnewACR){

            if(acr.Primary__c && hasNoPrimaryContact.contains(acr.AccountId)){
                acr.addError('There should be atleast one Primary Contact');
            }
              if(acr.Primary__c && hasMorePrimaryContact.contains(acr.AccountId)){
                acr.addError('Max Two Primary Contacts are allowed');
            }
           
            if(acr.isActive && acr.Access_Level__c =='Read/Write'  && hasmaxContact.contains(acr.AccountId)){
                acr.addError('Max Read/Write contacts limit reached.');
            }
        }
    }

    //T01
    public static void updateContact(List<AccountContactRelation> lstNewACR){
        globalApexManager GAM = new globalApexManager();
        
        //get timezone records
        Map<String, Id> mapTimezoneNameToId = new Map<String, Id>();
        for(TimeZone__c tmz : [Select Id, Name, Timezone__c From TimeZone__c]){
            mapTimezoneNameToId.put(tmz.Timezone__c, tmz.Id);
        }

        Set<Id> setContactId = new Set<Id>();
        for(AccountContactRelation acr : lstnewACR){
            setContactId.add(acr.ContactId);
        }

        Map<Id, Contact> mapIdToContact = new Map<Id, Contact>([Select Id, INFA_Language__c, TimeZone_Lookup__c, TimeZone_Lookup__r.Timezone__c 
                                        From Contact Where Id in :setContactId]);

        List<Contact> lstContactToUpdate = new List<Contact>();
        for(AccountContactRelation acr : lstnewACR){
            Contact cont = mapIdToContact.get(acr.ContactId);
            Boolean contactUpdated = false;
            if(acr.TimeZone__c != null && acr.TimeZone__c != cont.TimeZone_Lookup__r.TimeZone__c){
                if(mapTimezoneNameToId.containsKey(acr.TimeZone__c)){
                    cont.TimeZone_Lookup__c = mapTimezoneNameToId.get(acr.TimeZone__c);
                    contactUpdated = true;
                }
            }
            if(acr.Language__c != null && acr.Language__c != cont.INFA_Language__c){
                cont.INFA_Language__c = acr.Language__c;
                contactUpdated = true;
            }
            if (contactUpdated){
                cont.Bypass_DateTime__c = System.now(); //<T02>
                lstContactToUpdate.add(cont);
            }
        }

        if(!lstContactToUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(lstContactToUpdate);
            for (Database.SaveResult sr : srList) {
               if(!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('AccountContactRelationTriggerHandler --> updateContact --> update of Contact failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
}