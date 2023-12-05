/****************************************************************************************************************************
*  @Class Name: CustomListViewController
*  @Author: 
*  @Date: 2023-05-20
*  @Description:This is a controller for customLeadListView and dealRegistrationPage component
*****************************************************************************************************************************
ChangeHistory      
ModifiedBy          Date        Requested By       JIRA       Description                                                       Tag
Puneet             20-05-23     SALESRT-15144 & SALESRT-14918      Ability to access converted deal registrations               <T01>
****************************************************************************************************************************/
public with sharing class CustomListViewController {
    
    /**
     * @description : This method is used to get lead records.
     * 
     * @param : key - String key for search
     * 
     * @return : Lead List
     * */ 
    @AuraEnabled
    public static List<Lead> getLeads(String key) {
        List<Lead> leadList;
        String finalKey = '%'+key+'%';

        if(String.isBlank(key)){
            leadList = [SELECT Id, Name, Phone,Email,Company,Deal_Registration_Number__c,Account__c,
                        Account__r.Name,Reseller_SI_Partner__c,Reseller_SI_Partner__r.Name,Field_Sales_Rep__c,
                        Field_Sales_Rep__r.Name,PSM__c,PSM__r.Name,Opportunity__c,Opportunity__r.Name, CreatedDate
                        FROM Lead 
                        WHERE IsConverted = true AND RecordType.DeveloperName = 'Deal_Registration' LIMIT 1000];
        }
        else{
            leadList = [SELECT Id, Name, Phone,Email,Company,Deal_Registration_Number__c,Account__c,
                        Account__r.Name,Reseller_SI_Partner__c,Reseller_SI_Partner__r.Name,Field_Sales_Rep__c,
                        Field_Sales_Rep__r.Name,PSM__c,PSM__r.Name,Opportunity__c,Opportunity__r.Name,CreatedDate
                        FROM Lead 
                        WHERE IsConverted = true AND RecordType.DeveloperName = 'Deal_Registration' AND 
                            (Name LIKE :finalKey OR Email LIKE :finalKey or Deal_Registration_Number__c LIKE :finalKey)
                        ];
        }

        return leadList;
    }

    /**
     * @description : This method is used to get approval history
     * 
     * @param : recordId - Lead record Id
     * 
     * @return : ProcessInstance List
     * */ 
    @AuraEnabled
    public static List<ProcessInstance> getApprovalHistory(String recordId){       
        
        Map<Id,ProcessInstance> mapProcessInstance = new Map<Id,ProcessInstance>(
            [SELECT CompletedDate, CreatedById, CreatedDate,Id,IsDeleted,LastActor.Name,
                LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedBy.name,
                SystemModstamp,TargetObjectId, 
                (SELECT ID, ProcessNodeId, StepStatus,Comments,TargetObjectId,Actor.Name,
                    CreatedById,IsDeleted,IsPending,OriginalActor.Name,ProcessInstanceId,
                    RemindersSent,CreatedDate,ProcessNode.Name
                    FROM StepsAndWorkitems order by CreatedDate DESC,Id DESC) 
                FROM ProcessInstance 
                WHERE ProcessInstance.TargetObjectId =: recordId order By CreatedDate DESC,Id DESC]);

        return mapProcessInstance.values();
    }
}