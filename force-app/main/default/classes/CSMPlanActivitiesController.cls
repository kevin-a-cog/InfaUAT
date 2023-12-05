/*
 * Name			:	CSMPlanActivitiesController
 * Author		:	Deva M
 * Created Date	: 	05-Apr-2022
 * Description	:	Plan Activities controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
Deva M          		05-Apr-2022		N/A				Initial version.			N/A
 */
public with sharing class CSMPlanActivitiesController {
    //Public variables.
	public static String STRING_FIELD_SET_NAME ='CSM_Plan_Tasks';
   /*
	 Method Name : getRecords
	 Description : This method returns the Risks and Issues records related to the provided Id.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRecordId) {
        Set<Id> whatIdSet  = new Set<Id>();
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        String strCleanRecordId;
        String strTaskObjectName = Task.class.getName();
        String strEventObjectName = Event.class.getName();
        if(String.isNotBlank(strRecordId)) {
            //We clean the Plan Id.
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
            //If we received Plan id, we get Plan Product records.
			objDataTable.strObjectName = strTaskObjectName;
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
            whatIdSet.add(strCleanRecordId);
            for(Objective__c obj:[SELECT Id,(Select Id From MIlestones__r) FROM Objective__c WHERE Plan__c=:strCleanRecordId]){
                if(obj.MIlestones__r!=null && obj.MIlestones__r.size()>0){
                    for(Milestone__c objMile:obj.MIlestones__r){
                        whatIdSet.add(objMile.Id);
                    }
                }
            }
            //Now we prepare the response.
			objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strTaskObjectName + 
            ' WHERE WhatId  = :whatIdSet');            
        }
        return objDataTable;
    }
}