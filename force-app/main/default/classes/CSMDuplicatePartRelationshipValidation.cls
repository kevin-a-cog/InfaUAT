/*
* Name			:	CSM_DuplicatePartnerRelationshipValidation
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	this class will call from trigger if it configured in validation settings

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMDuplicatePartRelationshipValidation{
    String errorMessage = 'The selected Partner is associated to the Plan';
    public void validate(List<Partner_Relationship__c> newPartnerRecords) {  
        Set<String> planIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        Set<String> exisitngAccountSet = new Set<String>();
        if(newPartnerRecords!=null && newPartnerRecords.size()>0){
            //Iterate over new list and add unique field to set
            for(Partner_Relationship__c pcontact:newPartnerRecords){
                if(String.isNotBlank(pcontact.Partner_Account__c)){
                    accountIdSet.add(pcontact.Partner_Account__c); 
                }               
                if(String.isNotBlank(pcontact.Plan__c)){
                    planIdSet.add(pcontact.Plan__c);  
                }                
            }
        }
         //Check if accountIdSet collection not empty
         if(accountIdSet.size()>0 && planIdSet.size()>0){   
            //query existing records based on partner account
            for(Partner_Relationship__c pAccount:[SELECT Id, Partner_Account__c, Plan__c FROM Partner_Relationship__c where Plan__c IN : planIdSet AND Partner_Account__c IN : accountIdSet]){
                exisitngAccountSet.add(pAccount.Partner_Account__c);
            } 
           for(Partner_Relationship__c pAccount:newPartnerRecords){
                //Check if the new records account over exisitng records and throw error
                if(exisitngAccountSet.size()>0 && exisitngAccountSet.contains(pAccount.Partner_Account__c)){
                    pAccount.addError(errorMessage);
                }else{
                    exisitngAccountSet.add(pAccount.Partner_Account__c);
                }
            }
        }
    }
}