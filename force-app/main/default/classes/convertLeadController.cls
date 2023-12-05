/*
Class:          convertLeadController
@Author:        Sreerekha
@Created Date:  09 SEP 2023
@Description:   SALESRT-13356 Polaris - Revisit of the entire Lead Conversion Button

************************************************************************************************************************************
ModifiedBy        Date         JIRA NO        Requested by      Description                       Tag

************************************************************************************************************************************
*/
public class convertLeadController {
    public static globalApexManager GAM = new globalApexManager(); 
    Private static String customerContact = 'Customer Contact';
    Private static String prospectContact = 'Prospect Contact';   
/*
Method Name : fetchDefaultValues
Description : This method returns the initial default values.
Parameters	: email,accountId,leadId.
Return Type : defaultValues
*/   
    public class defaultValues{
        @AuraEnabled public Boolean contactExists;
        @AuraEnabled public Boolean opportunityExists;
        @AuraEnabled public String ContactId;
           
    }    
    @AuraEnabled(cacheable=true)
    public static defaultValues fetchDefaultValues (String accountId, string email) {   
        defaultValues request= new defaultValues();
      
        List<defaultValues> lstDefaultValues = new List<defaultValues>();
        list<Contact> lstCustomerContact = new list<Contact>();
        list<Contact> lstProspectContact= new list<Contact>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstGlobalCustomerContact = new list<Contact>();
        list<Contact> lstGlobalProspectContact= new list<Contact>();
        list<Contact> lstGlobalContact = new list<Contact>(); 
        list<Opportunity> lstOpportunity = new list<Opportunity>();       
        Contact finalContact;
        Boolean contactExists = false;
        Boolean opportunityExists = false; 

        if((accountId != null && accountId != '')) {
            lstOpportunity = [SELECT Id, Name FROM Opportunity WHERE AccountId =:accountId AND IsClosed = false ORDER BY CloseDate DESC];
            if(lstOpportunity.size()>0) {
                opportunityExists = true;
            }
        }
        Contact[] lContact = [SELECT Id,Name, AccountId, RecordType.Name,AccountName__c,Salutation,FirstName, MiddleName, LastName, Email,Title, Phone, LastModifiedDate FROM contact WHERE Email =: email ORDER BY LastModifiedDate DESC];
            if(lContact.size()>0) {
                contactExists = true;        
                for(Contact con :lContact){
                    if(accountId != '' && accountId != null && con.AccountId == accountId){
                        if(con.RecordType.Name == customerContact){
                            lstCustomerContact.add(con);
                            Break;
                        } else if(con.RecordType.Name == prospectContact){
                            lstProspectContact.add(con);
                            Break;
                        } else {
                            lstContact.add(con);
                            Break;
                        }
                    } else {
                        if(con.RecordType.Name == customerContact){
                            lstGlobalCustomerContact.add(con);
                            Break;
                        } else if(con.RecordType.Name == prospectContact){
                            lstGlobalProspectContact.add(con);
                            Break;
                        } else {
                            lstGlobalContact.add(con);
                            Break;
                        }
                    }
                }
                if(lstCustomerContact.size()>0){
                    finalContact = lstCustomerContact[0];
                } else if(lstProspectContact.size()>0){
                    finalContact = lstProspectContact[0];
                } else if(lstContact.size()>0){
                    finalContact = lstContact[0];
                } else if(lstGlobalCustomerContact.size()>0){
                    finalContact = lstGlobalCustomerContact[0];
                } else if(lstGlobalProspectContact.size()>0){
                    finalContact = lstGlobalProspectContact[0];
                } else {
                    finalContact = lstGlobalContact[0];
                }                
                request.contactExists = contactExists;
                request.opportunityExists = opportunityExists;
                if(finalContact != null){
                    request.ContactId = finalContact.Id;
                }
            } else {
                contactExists = false;
                request.contactExists = contactExists;
                request.opportunityExists = opportunityExists;
            }           
        return request;  
    }   
/*
Method Name : lookupContactSearch
Description : This method returns the searched records of lookup for contacts.
Parameters	: searchTerm,accountId,email.
Return Type : list<LookupSearchResult>
*/   
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupContactSearch(String searchTerm, string email) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        string metaFields;
        string objectName = 'Account';
        searchTerm = '%'+String.escapeSingleQuotes(searchTerm)+'%';
        Contact[] lContact = [SELECT Id, Name, RecordType.Name, AccountName__c FROM contact WHERE Email =: email AND Name LIKE :searchTerm ORDER BY LastModifiedDate DESC];
        String conIcon = 'standard:contact';		
        for (contact con : lContact) {
            metaFields = con.AccountName__c +' • '+ con.RecordType.Name;
            results.add(new LookupSearchResult(con.Id, 'Contact', conIcon, con.Name, metaFields));
        }
        return results;            
    }
/*
Method Name : getDefaultContactRecords
Description : This method returns the default contact records of lookup.
Parameters	: Account Id, Email.
Return Type : list<LookupSearchResult>
*/    
    @AuraEnabled(cacheable = false)
    public static List<LookupSearchResult> getDefaultContactRecords(string email) {
        string metaFields;
        string objectName = 'Account';
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String contactIcon = 'standard:contact';	
        Contact[] lContact = [SELECT Id,Name,RecordType.Name,AccountName__c FROM contact WHERE Email =: email ORDER BY LastModifiedDate DESC];
        for (Contact con : lContact) {
            metaFields = con.AccountName__c +' • '+ con.RecordType.Name;
            results.add(new LookupSearchResult(con.Id, 'Contact', contactIcon, con.name, metaFields));
        }
        return results;	
    }   
/*
Method Name : lookupOptySearch
Description : This method returns the searched records of lookup for optys.
Parameters	: searchTerm,accountId.
Return Type : list<LookupSearchResult>
*/    
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupOptySearch(String searchTerm, String accountId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        string metaFields;
        string objectName = 'Account';
        searchTerm = '%'+String.escapeSingleQuotes(searchTerm)+'%';
        Opportunity[] lOpportunity = [SELECT Id, Name, CloseDate, IsClosed, New_Org_Opportunity_Number__c, Account.Name, RecordType.name FROM Opportunity WHERE Name LIKE :searchTerm AND AccountId =:accountId AND IsClosed = false ORDER BY CloseDate DESC];
        String oppIcon = 'standard:opportunity';		
        for (opportunity opp : lOpportunity) {
            Datetime closeDate = opp.CloseDate;
            Date myDate = date.newinstance(closeDate.year(), closeDate.month(), closeDate.day());
            String sdate = String.valueOf(myDate);
            metaFields = opp.Account.Name +' • '+ opp.New_Org_Opportunity_Number__c+' • '+sdate+' • '+opp.RecordType.name;
            results.add(new LookupSearchResult(opp.Id, 'Opportunity', oppIcon, opp.name, metaFields));
        }		
        return results;          
    }    
/*
Method Name : getDefaultOptyRecords
Description : This method returns the default Opportunity records of lookup.
Parameters	: AccountID.
Return Type : list<LookupSearchResult>
*/    
    @AuraEnabled(cacheable = false)
    public static List<LookupSearchResult> getDefaultOptyRecords(String accountId) {
        string metaFields;
        string objectName = 'Account';
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String opportunityIcon = 'standard:opportunity';
        for (Opportunity opp : [SELECT Id, Name, CloseDate, IsClosed, New_Org_Opportunity_Number__c, RecordType.name, Account.Name FROM Opportunity WHERE AccountId =:accountId AND IsClosed = false ORDER BY CloseDate DESC]) {
            Datetime closeDate = opp.CloseDate;
            Date myDate = date.newinstance(closeDate.year(), closeDate.month(), closeDate.day());
            String sdate = String.valueOf(myDate);
            metaFields = opp.Account.Name +' • '+ opp.New_Org_Opportunity_Number__c+' • '+sdate+' • '+opp.RecordType.name;
            String oppName = opp.Name+' - '+ opp.RecordType.name;
            results.add(new LookupSearchResult(opp.Id, 'Opportunity', opportunityIcon, opp.Name , metaFields));
        }
        return results;	
    }
/*
Method Name : getContactFieldNames
Description : This method returns the list of contact fields to be displayed.
Parameters	: 
Return Type : list<String>
*/    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getContactFieldNames(string leadId, String contactId) {
        List<string> mappings = String.valueOf(Label.UI_Contact_Field_Names).split(';');
        Map<String,String> contactMappings = new Map<String, String>();        
        String state;

        if(leadId == null || leadId == ''){
            return null;
        }
        
        if(contactId != null && contactId != ''){
        //Field set query
        List<Schema.FieldSetMember> fieldSetList = SObjectType.Contact.FieldSets.Polaris_Contact_UI_Fields.getFields();
        String queryString = 'SELECT Id';
        for (Schema.FieldSetMember fieldSet : fieldSetList) {
            queryString += ',' + fieldSet.getFieldPath();
        }
        queryString += ' FROM Contact WHERE Id =:contactId LIMIT 1';        
        Contact selectedContact = Database.query(queryString);
        for(String eachMap : mappings){
            String conValue;
            if(string.valueOf(selectedContact.get(eachMap.split('-')[1])) != null){
                conValue = string.valueOf(selectedContact.get(eachMap.split('-')[1]));
            }else {
                conValue = '';
            }
            if(eachMap.split('-')[2] != null){
                state = eachMap.split('-')[2];
            }
            contactMappings.put(eachMap.split('-')[1]+'-'+state,conValue);            
        }
        } else  {
        //Field set query
        List<Schema.FieldSetMember> fieldSetList = SObjectType.Lead.FieldSets.Polaris_Lead_UI_Fields.getFields();
        String queryString = 'SELECT Id';
        for (Schema.FieldSetMember fieldSet : fieldSetList) {
            queryString += ',' + fieldSet.getFieldPath();
        }
        queryString += ' FROM Lead WHERE Id =:leadId LIMIT 1';        
        Lead lLeadRec = Database.query(queryString);
        for(String eachMap : mappings){
            String leadValue;
            if(string.valueOf(lLeadRec.get(eachMap.split('-')[0])) != null){
                leadValue = string.valueOf(lLeadRec.get(eachMap.split('-')[0]));
            }else {
                leadValue = '';
            }
            if(eachMap.split('-')[2] != null){
                state = eachMap.split('-')[2];
            }
            contactMappings.put(eachMap.split('-')[1]+'-'+state ,leadValue);            
        }
        }
       return contactMappings;
    }
}