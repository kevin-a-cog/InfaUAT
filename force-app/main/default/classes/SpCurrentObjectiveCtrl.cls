public without sharing class SpCurrentObjectiveCtrl {
    
    @AuraEnabled(cacheable = true)
    public static list<Objective__c> fetchNextObjective(string strRecordId){
        string strCleanRecordId = String.escapeSingleQuotes(strRecordId);
        List<String> lstObjectiveFields = new List<String>();
    List<String> lstMilestoneFields = new List<String>();
    List<String> lstObjectiveProductFields = new List<String>();
    List<String> lstMilestoneProductFields = new List<String>();

        //We define the fields for Objective.
      lstObjectiveFields.add('Name');
      lstObjectiveFields.add('CSM_Planned_Completion_Date__c');
      lstObjectiveFields.add('Status__c');
      lstObjectiveFields.add('Target_KPI__c');
      lstObjectiveFields.add('Actual_KPI__c');
      lstObjectiveFields.add('Business_Goal__c');
      lstObjectiveFields.add('Technical_Goal__c');
      lstObjectiveFields.add('CreatedDate');
      lstObjectiveFields.add('CreatedBy.Name');
      lstObjectiveFields.add('LastModifiedDate');
      lstObjectiveFields.add('LastModifiedBy.Name');
      lstObjectiveFields.add('Sign_Off_Date__c');
      lstObjectiveFields.add('Customer_Sign_off_Contact__r.Name');

      //We define the fields for Milestone.
      lstMilestoneFields.add('Name');
      lstMilestoneFields.add('Milestone_Type__c');
      lstMilestoneFields.add('Key_Milestone__c');
      lstMilestoneFields.add('Planned_Completion_Date__c');
      lstMilestoneFields.add('Status__c');
      lstMilestoneFields.add('CreatedDate');
      lstMilestoneFields.add('CreatedBy.Name');
      lstMilestoneFields.add('LastModifiedDate');
      lstMilestoneFields.add('LastModifiedBy.Name');
      lstMilestoneFields.add('Description__c');
      lstMilestoneFields.add('Actual_Completion_Date__c');

      //We define the fields for Objective Products.
      lstObjectiveProductFields.add('Plan_Product_Alias__r.Name__c');

      //We define the fields for Milestone Products.
      lstMilestoneProductFields.add('Milestone__c');
      lstMilestoneProductFields.add('Milestone__r.Name');//added for 2177
      lstMilestoneProductFields.add('Plan_Product_Alias__r.Name__c');

            string  dynamicsoql = 'SELECT Id, ' + String.join(lstObjectiveFields, ',') + ', (SELECT Id, ' + String.join(lstMilestoneFields, ',') + 
          ' FROM Milestones__r WHERE Is_Internal__c = false ORDER BY Planned_Completion_Date__c ASC), (SELECT ' + String.join(lstObjectiveProductFields, ',') + ' FROM ' + 
          'Objective_Products__r ORDER BY Plan_Product_Alias__r.Name__c ASC),Plan__r.CSM_isAutoPilot__c FROM Objective__c WHERE Is_Internal__c = false and ' + 
		  'Plan__c = :strCleanRecordId AND CSM_Planned_Completion_Date__c != null AND CSM_Planned_Completion_Date__c >= TODAY ORDER BY CSM_Planned_Completion_Date__c ASC LIMIT 1';            
            return Database.query(dynamicsoql);        
    }

}