/*
Class:  IPUE_AddContactsController
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Description: Controller class for IpueReviewContacts
@TestClass: IPUE_AddContactsControllerTest
@Jira: IPUE-156
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description
*************************************************************************************************************************************************************
*/
public with sharing class IPUE_AddContactsController {

    //Wrapper class to hold the column information for datatable
    public class tableColumn{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean sortable = true;
        @AuraEnabled public Boolean hideDefaultActions = true;
    }    
    
    /* Method Name : getFieldsToDisplay
    * @param: NA
    * @return return - List<tableColumn>
    * @throws exception - AuraHandledException if any
    * @description - Gets fields to be dispalyed in the datatable from the contact fieldset
    */
    @AuraEnabled(cacheable=true)
    public static List<tableColumn> getFieldsToDisplay(){
        try {
            List<tableColumn> columnsToDisplay = new List<tableColumn>();
            List<Schema.FieldSetMember> lstFieldSetMember =Schema.SObjectType.Contact.fieldSets.IPUE_Add_Contacts.getFields();
            if(!lstFieldSetMember.isEmpty()){
                for(Schema.FieldSetMember fsMember:lstFieldSetMember){
                    tableColumn column = new tableColumn();
                    column.label = fsMember.getLabel();
                    column.fieldName = fsMember.getFieldPath();
                    column.type = String.valueOf(fsMember.getType());
                    columnsToDisplay.add(column);
                }
            }
            return columnsToDisplay;           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Method Name : getEstimationRec
    * @param : recordId - summary record ID
    * @return: Estimation_Summary__c record
    * @throws exception - NA
    * @description - Gets account, opty and active estimator collaborators associatd with the summary record
    */
    @AuraEnabled
    public static Estimation_Summary__c getEstimationRec(Id recordId){
        return [SELECT Id,Account__c,Opportunity__c,(SELECT Id,Contact__c,Access__c FROM Estimator_Collaborators__r WHERE Active__c = true) FROM Estimation_Summary__c WHERE Id = :recordId LIMIT 1];
    }

    /* Method Name : getLstContacts
    * @param : queryFields,searchTerm,offSetCount,setContactIds
    * @returns: List<Contact>
    * @throws exception - NA
    * @description - Gets contact records based on the search term, offset count and recordIds
    */    
    public static List<sObject> getLstContacts(String queryFields,String searchTerm,Integer offSetCount,Set<Id> setContactIds){
        List<sObject> lstContacts = new List<sObject>();            
        String querySearchTerm = '%'+String.escapeSingleQuotes(searchTerm)+'%';
        String query = 'SELECT Id'+queryFields+' FROM Contact WHERE (Name LIKE :querySearchTerm OR AccountName__c LIKE :querySearchTerm OR Email LIKE :querySearchTerm OR New_Org_Contact_Number__c LIKE :querySearchTerm) ';
        if(setContactIds != null){
            query = query + 'AND Id IN :setContactIds ';
        }
        query = query + 'ORDER BY Name ';
        query = query + (offSetCount == 0 ? 'LIMIT 25 ':'LIMIT 10 ');
        query = query + 'OFFSET :offSetCount';
        lstContacts = Database.query(query);
        return lstContacts;
    }

    /* Method Name : getContacts
    * @param : accountId,opportunityId,queryFields,searchSource,searchTerm,offSetCount,totalNumberOfRows
    * @returns: List<Contact>
    * @throws exception - AuraHandledException if any
    * @description - Gets contact records based on the search term and search source
    */
    @AuraEnabled
    public static List<sObject> getContacts(String accountId,String opportunityId,String searchSource, String searchTerm, String queryFields, String offSetCount ,String totalNumberOfRows){
        try {
            List<sObject> lstContacts = new List<sObject>();
            if(searchSource.equalsIgnoreCase('Global Contacts')){
                //Get all contacts
                lstContacts = getLstContacts(queryFields,searchTerm,Integer.valueof(offSetCount),null);
            }else{
                Set<Id> setContactIds = new Set<Id>();
                //Get contact details from OpportunityContactRole, if searchSource = Opportunity Contacts
                if(searchSource.equalsIgnoreCase('Opportunity Contacts')){
                    for(OpportunityContactRole ocr:[SELECT Id,ContactId FROM OpportunityContactRole WHERE OpportunityId =:opportunityId]){
                        setContactIds.add(ocr.ContactId);
                    }
                    lstContacts = getLstContacts(queryFields,searchTerm,Integer.valueof(offSetCount),setContactIds);                    
                }                
                //Get contact details from AccountContactRelation, if searchSource = Account Contacts
                else if(searchSource.equalsIgnoreCase('Account Contacts')){
                    for(AccountContactRelation acr:[SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId =:accountId]){
                        setContactIds.add(acr.ContactId);
                    }
                    lstContacts = getLstContacts(queryFields,searchTerm,Integer.valueof(offSetCount),setContactIds);
                }
            }
            return lstContacts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Method Name : getNumberOfRecords
    * @param : accountId,opportunityId,searchSource,searchTerm
    * @returns: Integer - total number of contact records
    * @throws exception - AuraHandledException if any
    * @description - Gets total number of contact records based on the search term and search source
    */
    @AuraEnabled
    public static Integer getNumberOfRecords(String accountId,String opportunityId,String searchSource, String searchTerm){
        try {
            Integer contactCount = 0;            
            String querySearchTerm = '%'+String.escapeSingleQuotes(searchTerm)+'%';
            if(searchSource.equalsIgnoreCase('Global Contacts')){
                contactCount = [SELECT count() FROM Contact WHERE Name LIKE :querySearchTerm OR AccountName__c LIKE :querySearchTerm OR Email LIKE :querySearchTerm OR New_Org_Contact_Number__c LIKE :querySearchTerm];
            }else{
                
                //Get contact count from OpportunityContactRole, if searchSource = Opportunity Contacts
                if(searchSource.equalsIgnoreCase('Opportunity Contacts')){
                    List<AggregateResult> lstOptyContact = [SELECT COUNT_DISTINCT(ContactId) contactCount FROM OpportunityContactRole WHERE OpportunityId = :opportunityId AND
                    (Contact.Name LIKE :querySearchTerm OR Contact.AccountName__c LIKE :querySearchTerm OR Contact.Email LIKE :querySearchTerm OR Contact.New_Org_Contact_Number__c LIKE :querySearchTerm)];
                    contactCount = (Integer) lstOptyContact[0].get('contactCount');
                }
                //Get contact count from AccountContactRelation, if searchSource = Account Contacts
                else if(searchSource.equalsIgnoreCase('Account Contacts')){                    
                    List<AggregateResult> lstAccountContact = [SELECT COUNT_DISTINCT(ContactId) contactCount FROM AccountContactRelation WHERE AccountId = :accountId AND
                    (Contact.Name LIKE :querySearchTerm OR Contact.AccountName__c LIKE :querySearchTerm OR Contact.Email LIKE :querySearchTerm OR Contact.New_Org_Contact_Number__c LIKE :querySearchTerm)];
                    contactCount = (Integer) lstAccountContact[0].get('contactCount');
                }
            } 
            return contactCount;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}