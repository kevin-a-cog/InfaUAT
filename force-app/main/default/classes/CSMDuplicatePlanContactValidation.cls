/*
* Name			:	CSM_DuplicatePlanContactValidation
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	this class will call from trigger and validate the duplicate contact

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMDuplicatePlanContactValidation{
    String errorMessage = 'Duplicate Plan Contact is not Allowed on same plan';
    public void validate(List<Plan_Contact__c> planContactList) {  
        Set<String> planIdSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        Set<String> exisitngContactSet = new Set<String>();
        if(planContactList!=null && planContactList.size()>0){
            //Iterate over new list and add unique field to set
            for(Plan_Contact__c pcontact:planContactList){
                if(String.isNotBlank(pcontact.Contact__c)){
                    contactIdSet.add(pcontact.Contact__c); 
                }               
                if(String.isNotBlank(pcontact.Plan__c)){
                    planIdSet.add(pcontact.Plan__c);  
                }                
            }
        }
         //Check if emailset collection not empty
         if(contactIdSet.size()>0 && planIdSet.size()>0){   
            //query existing records based on email
            for(Plan_Contact__c pcontact:[SELECT Id, Plan__c, Contact_email__c, Contact__c FROM Plan_Contact__c where Plan__c IN : planIdSet AND Contact__c IN : contactIdSet]){
                exisitngContactSet.add(pcontact.Contact__c);
            } 
           for(Plan_Contact__c pcontact:planContactList){
                //Check if the new records email over exisitng records and throw error
                if(exisitngContactSet.size()>0 && exisitngContactSet.contains(pcontact.Contact__c)){
                    pcontact.addError(errorMessage);
                }else{
                    exisitngContactSet.add(pcontact.Contact__c);
                }
            }
        }
    }
}