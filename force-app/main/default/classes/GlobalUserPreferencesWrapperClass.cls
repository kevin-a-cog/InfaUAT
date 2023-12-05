/*
 * Name			:	GlobalUserPreferencesWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/20/2021
 * Description	:	Wrapper class for User Preferences feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/20/2021		N/A				Initial version.			N/A
 */
public class GlobalUserPreferencesWrapperClass {

	//Public variables.
	@AuraEnabled
	public EngineerWorkspaceWrapperClass objEngineerWorkspace {get; set;}
	@AuraEnabled
	public ManagerWorkspaceWrapperClass objManagerWorkspace {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstTimeframes {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstGEMSColumns {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstTeams {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstTeamsColumns {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstTeamsColumnsRaiseHand {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstQueueColumns {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstQueueColumnsRaiseHand {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstQueueColumnsUrgentRequest {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstQueues {get; set;}
	@AuraEnabled
	public List<PicklistWrapperClass> lstQueuesRaiseAndUrgent {get; set;}
	@AuraEnabled
	public Map<String, SortingWrapperClass> mapDataTablesSorting {get; set;}
	@AuraEnabled
	public Map<String, List<String>> mapDataTablesFields {get; set;}
	@AuraEnabled
	public Map<String, List<PicklistWrapperClass>> mapListViews {get; set;}

	//This class contains the Engineering Workspace configuration.
	public class EngineerWorkspaceWrapperClass {

		//Public variables.
		@AuraEnabled
		public Boolean boolAutorefreshActive {get; set;}
		@AuraEnabled
		public Integer intAutorefreshSeconds {get; set;}
		@AuraEnabled
		public Integer intSplitterPosition {get; set;}
		@AuraEnabled
		public String strView {get; set;}
		@AuraEnabled
		public String strPinnedListView {get; set;}
		@AuraEnabled
		public List<String> lstListViews {get; set;}
	}

	//This class contains the Manager Workspace configuration.
	public class ManagerWorkspaceWrapperClass {

		//Public variables.
		@AuraEnabled
		public Boolean boolAutorefreshActive {get; set;}
		@AuraEnabled
		public Integer intAutorefreshSeconds {get; set;}
		@AuraEnabled
		public String strTeamsSelectedTab {get; set;}
		@AuraEnabled
		public List<String> lstTeams {get; set;}
		@AuraEnabled
		public List<String> lstTeamsRaiseHand {get; set;}
		@AuraEnabled
		public List<String> lstQueues {get; set;}
		@AuraEnabled
		public List<String> lstQueuesRaiseHand {get; set;}
		@AuraEnabled
		public List<String> lstQueuesUrgentRequest {get; set;}
	}

	//This wrapper class represents a picklist field.
	public class PicklistWrapperClass {

		//Public variables.
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public String value {get; set;}
	}

	//This wrapper class represents a sorting configuration.
	public class SortingWrapperClass {

		//Public variables.
		@AuraEnabled
		public String strFieldName {get; set;}
		@AuraEnabled
		public String strSortDirection {get; set;}
	}
}