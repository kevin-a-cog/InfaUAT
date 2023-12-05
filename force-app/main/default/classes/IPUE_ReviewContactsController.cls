/*
Class:  IPUE_ReviewContactsController
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

public with sharing class IPUE_ReviewContactsController {

    //Wrapper used for renerdering the Existing/New Collaborators
    public class ReviewContactData{
        @AuraEnabled public Id contactId{get;set;} 
        @AuraEnabled public Id estimationCollaboratorId{get;set;} // Estimator Collaborator Id, populated only for existing records
        @AuraEnabled public String contactName{get;set;}
        @AuraEnabled public String contactAccount{get;set;}
        @AuraEnabled public String contactEmail{get;set;}
        @AuraEnabled public String accessType {get;set;}{accessType = 'Edit';} //Access type of existing Estimator Collaborator, default = edit
        @AuraEnabled public Boolean isSelected {get;set;}{isSelected = true;} //Used to identify if the record is selected in the datatable
        @AuraEnabled public Boolean isPicklistDisabled {get;set;}{isPicklistDisabled = false;} //Used to idenity if the picklist has to disabled for the existing Collaborator
    }
    
    /* Method Name : getEstimationCollaborators
    * @return return - String recordId,List<Id> selectedContactIds
    * @throws exception - NA
    * @description - Return all the existing collborators and new contact information
    */
    @AuraEnabled
    public static List<ReviewContactData> getEstimationCollaborators(String recordId,List<Id> selectedContactIds){
        try {
            List<ReviewContactData> lstContactData = new List<ReviewContactData>();
            Set<Id> setSelectedContactIds = new Set<Id>(selectedContactIds);

            //Existing Estimator Collaborators
            List<Estimator_Collaborator__c> lstExistingCollaborators = [SELECT Id,Contact__c,Access__c, Contact__r.Name, Contact__r.AccountName__c, Contact__r.Email FROM Estimator_Collaborator__c WHERE Estimation_Summary__c = :recordId];
            if(!lstExistingCollaborators.isEmpty()){
                for(Estimator_Collaborator__c collaboator:lstExistingCollaborators){
                    ReviewContactData contactData = new ReviewContactData();
                    contactData.EstimationCollaboratorId = collaboator.Id;
                    contactData.contactId = collaboator.Contact__c;
                    contactData.contactName = collaboator.Contact__r.Name;
                    contactData.contactAccount = collaboator.Contact__r.AccountName__c;
                    contactData.contactEmail = collaboator.Contact__r.Email;
                    contactData.accessType = collaboator.Access__c;
                    //If the existing record is unselected in the add contacts or inactive Collaborator
                    if(!setSelectedContactIds.contains(collaboator.Contact__c)){
                        contactData.isSelected = false;
                        contactData.isPicklistDisabled = true;
                    }
                    setSelectedContactIds.remove(collaboator.Contact__c);
                    lstContactData.add(contactData);
                }
            }

            //Fetching new contact information
            if(!setSelectedContactIds.isEmpty()){
                List<Contact> lstContact = [SELECT Id,Name,AccountName__c,Email FROM Contact WHERE Id IN :setSelectedContactIds];
                for(Contact contactRec:lstContact){
                    ReviewContactData contactData = new ReviewContactData();
                    contactData.contactId = contactRec.Id;
                    contactData.contactName = contactRec.Name;
                    contactData.contactAccount = contactRec.AccountName__c;
                    contactData.contactEmail = contactRec.Email;
                    lstContactData.add(contactData);
                }
            }
            return lstContactData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Method Name : upsertEstimationCollaborators
    * @return return - String recordId,List<ReviewContactData> lstCollaboatorData
    * @throws exception - NA
    * @description - Upserts the selected contacts on the datatable
    */
    @AuraEnabled
    public static void upsertEstimationCollaborators(Id recordId,List<ReviewContactData> lstCollaboatorData){
        List<Estimator_Collaborator__c> lstEstimationCollabsToUpsert = new List<Estimator_Collaborator__c>();
        
        for(ReviewContactData contactData:lstCollaboatorData){
            Estimator_Collaborator__c collabRec = new Estimator_Collaborator__c();
            //Existing Estimator Collaborator
            if(!String.isBlank(contactData.estimationCollaboratorId)){
                collabRec.Id = contactData.estimationCollaboratorId;
                //If existing record is unselected, then set Active to false, do not update the accessType
                if(contactData.isPicklistDisabled){
                    collabRec.Active__c = false;
                }else{                    
                    collabRec.Active__c = true;
                    collabRec.Access__c = contactData.accessType;
                }
            }
            //New selected contact
            else if(contactData.isSelected){
                collabRec.Contact__c = contactData.contactId;
                collabRec.Estimation_Summary__c = recordId;
                collabRec.Access__c = contactData.accessType;
            }
            //If new contact is unselected, do not add it to the list
            else{
                continue;
            }
            lstEstimationCollabsToUpsert.add(collabRec);
        }
        
        try{
            List<Database.upsertResult> upsertResults = Database.upsert(lstEstimationCollabsToUpsert,true);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}