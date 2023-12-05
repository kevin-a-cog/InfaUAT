/*
 * Name			:	GlobalUserPreferencesClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/20/2021
 * Description	:	Utility class for User preferences.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/20/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalUserPreferencesClass {
    
    /*
     Method Name : getUserPreferences
     Description : This method returns the current user preferences.
     Parameters  : None
     Return Type : Object
     */
    @AuraEnabled(cacheable = false) 
    public static GlobalUserPreferencesWrapperClass getUserPreferences() {
		GlobalUserPreferencesWrapperClass.PicklistWrapperClass objPicklistValue;
		GlobalUserPreferencesWrapperClass objResult = new GlobalUserPreferencesWrapperClass();
		List<String> lstSObjectListViews = new List<String>();
		List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass> lstListViewRecords;

		//We set initial values.
		lstSObjectListViews.add('Case');

		//Now we extract any existing record.
		for(User objRecord : [SELECT Preferences__c FROM User WHERE Id = :UserInfo.getUserId()]) {
			if(String.isNotBlank(objRecord.Preferences__c)) {
				objResult = (GlobalUserPreferencesWrapperClass) JSON.deserialize(objRecord.Preferences__c, GlobalUserPreferencesWrapperClass.class);
			}
		}

		//Now we make sure we have default values.
		if(objResult.objEngineerWorkspace == null) {
			objResult.objEngineerWorkspace = new GlobalUserPreferencesWrapperClass.EngineerWorkspaceWrapperClass();
		}
		if(objResult.objManagerWorkspace == null) {
			objResult.objManagerWorkspace = new GlobalUserPreferencesWrapperClass.ManagerWorkspaceWrapperClass();
		}
		if(objResult.objEngineerWorkspace.boolAutorefreshActive == null) {
			objResult.objEngineerWorkspace.boolAutorefreshActive = false;
		}
		if(objResult.objEngineerWorkspace.intAutorefreshSeconds == null) {
			objResult.objEngineerWorkspace.intAutorefreshSeconds = 30;
		}
		if(objResult.objEngineerWorkspace.lstListViews == null) {
			objResult.objEngineerWorkspace.lstListViews = new List<String> { 'RecentlyViewedCases' };
		}
		if(objResult.objManagerWorkspace.boolAutorefreshActive == null) {
			objResult.objManagerWorkspace.boolAutorefreshActive = false;
		}
		if(objResult.objManagerWorkspace.intAutorefreshSeconds == null) {
			objResult.objManagerWorkspace.intAutorefreshSeconds = 30;
		}
		if(objResult.objManagerWorkspace.lstTeams == null) {
			objResult.objManagerWorkspace.lstTeams = new List<String>();
		}
		if(objResult.objManagerWorkspace.lstTeamsRaiseHand == null) {
			objResult.objManagerWorkspace.lstTeamsRaiseHand = new List<String>();
		}
		if(objResult.objManagerWorkspace.lstQueues == null) {
			objResult.objManagerWorkspace.lstQueues = new List<String>();
		}
		if(objResult.objManagerWorkspace.lstQueuesRaiseHand == null) {
			objResult.objManagerWorkspace.lstQueuesRaiseHand = new List<String>();
		}
		if(objResult.objManagerWorkspace.lstQueuesUrgentRequest == null) {
			objResult.objManagerWorkspace.lstQueuesUrgentRequest = new List<String>();
		}
		if(objResult.mapDataTablesFields == null) {
			objResult.mapDataTablesFields = new Map<String, List<String>>();
		}
		if(objResult.mapDataTablesSorting == null) {
			objResult.mapDataTablesSorting = new Map<String, GlobalUserPreferencesWrapperClass.SortingWrapperClass>();
		}

		//Now we fetch the picklist values.
		objResult.lstTimeframes = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Timeframe__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstTimeframes.add(objPicklistValue);
		}
		objResult.lstGEMSColumns = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.GEMS_Columns__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstGEMSColumns.add(objPicklistValue);
		}
		objResult.lstTeams = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Teams__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstTeams.add(objPicklistValue);
		}
		objResult.lstTeamsColumns = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Teams_Columns__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstTeamsColumns.add(objPicklistValue);
		}
		objResult.lstTeamsColumnsRaiseHand = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Teams_Columns_Raise_Hand__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstTeamsColumnsRaiseHand.add(objPicklistValue);
		}
		objResult.lstQueueColumns = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Queue_Columns__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstQueueColumns.add(objPicklistValue);
		}
		objResult.lstQueueColumnsRaiseHand = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Queue_Columns_Raise_Hand__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstQueueColumnsRaiseHand.add(objPicklistValue);
		}
		objResult.lstQueueColumnsUrgentRequest = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Queue_Columns_Urgent_Request__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstQueueColumnsUrgentRequest.add(objPicklistValue);
		}
		objResult.lstQueues = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Queues__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstQueues.add(objPicklistValue);
		}
		objResult.lstQueuesRaiseAndUrgent = new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>();
		for(PicklistEntry objValue : SObjectType.User.fields.Queues_Raise_And_Urgent__c.getSObjectField().getDescribe().getPicklistValues()) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objValue.getLabel();
			objPicklistValue.value = objValue.getValue();
			objResult.lstQueuesRaiseAndUrgent.add(objPicklistValue);
		}
		objResult.mapListViews = new Map<String, List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>>();
		for(ListView objRecord : [SELECT Name, DeveloperName, SObjectType FROM ListView WHERE SObjectType IN :lstSObjectListViews ORDER BY DeveloperName ASC LIMIT 1000]) {
			objPicklistValue = new GlobalUserPreferencesWrapperClass.PicklistWrapperClass();
			objPicklistValue.label = objRecord.Name;
			objPicklistValue.value = objRecord.DeveloperName;
			if(objResult.mapListViews.get(objRecord.SObjectType) == null) {
				objResult.mapListViews.put(objRecord.SObjectType, new List<GlobalUserPreferencesWrapperClass.PicklistWrapperClass>());
			}
			lstListViewRecords = objResult.mapListViews.get(objRecord.SObjectType);
			lstListViewRecords.add(objPicklistValue);
			objResult.mapListViews.put(objRecord.SObjectType, lstListViewRecords);
		}

		//Now we return the results.
		return objResult;
	}
    
    /*
     Method Name : setUserPreferences
     Description : This method saves the given user preferences.
     Parameters  : Object, called from setUserPreferences, objRecord User preferences.
     Return Type : Object
     */
    @AuraEnabled(cacheable = false) 
    public static void setUserPreferences(GlobalUserPreferencesWrapperClass objRecord) {
		User objUser = new User();

		//First we remove the picklist values.
		objRecord.lstTimeframes = null;
		objRecord.lstGEMSColumns = null;
		objRecord.lstTeams = null;
		objRecord.lstTeamsColumns = null;
		objRecord.lstTeamsColumnsRaiseHand = null;
		objRecord.lstQueueColumns = null;
		objRecord.lstQueueColumnsRaiseHand = null;
		objRecord.lstQueueColumnsUrgentRequest = null;
		objRecord.lstQueues = null;
		objRecord.lstQueuesRaiseAndUrgent = null;
		objRecord.mapListViews = null;

		//Now we prepare the record.
		objUser.Id = UserInfo.getUserId();
		objUser.Preferences__c = JSON.serialize(objRecord, true);
		update objUser;
	}
}