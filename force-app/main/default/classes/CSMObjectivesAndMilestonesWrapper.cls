/*
 * Name			:	CSMObjectivesAndMilestonesWrapper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/09/2021
 * Description	:	Wrapper class for Objectives and Milestones.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/09/2021		N/A				Initial version.			N/A
 */
public class CSMObjectivesAndMilestonesWrapper {

	//Public variables.
	@AuraEnabled
	public Boolean boolHasChildTable {
		get {
			Boolean boolResult = false;
			if(lstChildRecordsCustomStructure != null && !lstChildRecordsCustomStructure.isEmpty()) {
				boolResult = true;
			}
			return boolResult;
		}
	}
	@AuraEnabled
	public Boolean boolCustomLayout {get; set;}
	@AuraEnabled
	public Boolean boolHasValidId {get; set;}
	@AuraEnabled
	public Integer intRecordLayoutType {get; set;}
	@AuraEnabled
	public Integer intColumnsConfiguration {get; set;}
	@AuraEnabled
	public Integer intMapLabelContentPairsNumberOfColumns {get; set;}
	@AuraEnabled
	public String Id {get; set;}
	@AuraEnabled
	public String strName {get; set;}
	@AuraEnabled
	public String strType {get; set;}
	@AuraEnabled
	public String strPlannedCompletionDate {get; set;}
	@AuraEnabled
	public Date datPlannedCompletionDate {get; set;}
	@AuraEnabled
	public StatusWrapper objStatus {get; set;}
	@AuraEnabled
	public CSMObjectivesAndMilestonesWrapper objAdditionalInformation {get; set;}
	@AuraEnabled
	public List<ProductWrapper> lstProducts {get; set;}
	@AuraEnabled
	public List<ActionWrapper> lstActions {get; set;}
	@AuraEnabled
	public List<IconWrapper> lstIcons {get; set;}
	@AuraEnabled
	public List<Object> lstChildRecordsCustomStructure {get; set;}
	@AuraEnabled
	public Map<String, String> mapStyles {get; set;}
	@AuraEnabled
	public Map<String, Object> mapLabelContentPairs {get; set;}

	//Status wrapper class.
	public class StatusWrapper {

		//Public variables.
		@AuraEnabled
		public String strValue {get; set;}
		@AuraEnabled
		public String strColor {
			get {
				String strResult = '';
				if(strValue == 'Draft') {
					strResult = '#001AFF50';
				} else if(strValue == 'Yet to Start') {
					strResult = '#C8CDD080';
				} else if(strValue == 'In Progress') {
					strResult = '#FFC94D80';
				} else if(strValue == 'Delayed') {
					strResult = '#EE3B2B80';
				} else if(strValue == 'On-hold') {
					strResult = '#FF7F50';
				} else if(strValue == 'Complete') {
					strResult = '#A7DD3C80';
				} else if(strValue == 'Canceled') {
					strResult = '#D44D9F80';
				}
				return strResult;
			}
		}
	}

	//Products wrapper class.
	public class ProductWrapper {

		//Public variables.
		@AuraEnabled
		public Integer intAction {get; set;}
		@AuraEnabled
		public String strValue {get; set;}
		@AuraEnabled
		public String strClasses {
			get {
				return 'slds-badge_lightest';
			}
		}
		@AuraEnabled
		public String strStyle {
			get {
				String strResult = 'color: #00A9BB; border-radius: 5px; font-weight: 500;';
				return strResult;
			}
		}
	}

	//Actions wrapper class.
	public class ActionWrapper {

		//Public variables.
		@AuraEnabled
		public Boolean boolHasSubactions {
			get {
				Boolean boolResult = false;
				if(lstSubactions != null && !lstSubactions.isEmpty()) {
					boolResult = true;
				}
				return boolResult;
			}
		}
		@AuraEnabled
		public Boolean boolIsStaticResource {get; set;}
		@AuraEnabled
		public Integer intAction {get; set;}
		@AuraEnabled
		public Integer intWidth {get; set;}
		@AuraEnabled
		public String strIcon {get; set;}
		@AuraEnabled
		public String strInverseIcon {get; set;}
		@AuraEnabled
		public String strLabel {get; set;}
		@AuraEnabled
		public String strURL {get; set;}
		@AuraEnabled
		public String strInverseURL {get; set;}
		@AuraEnabled
		public List<ActionWrapper> lstSubactions {get; set;}
	}

	//Icons wrapper class.
	public class IconWrapper {

		//Public variables.
		@AuraEnabled
		public Boolean boolIsStaticResource {get; set;}
		@AuraEnabled
		public Integer intWidth {get; set;}
		@AuraEnabled
		public String strIcon {get; set;}
		@AuraEnabled
		public String strURL {get; set;}
		//added for 2177
		@AuraEnabled
		public String strTitle {get; set;}
	}

	//Cell wrapper class.
	public class CellWrapper {

		//Public variables.
		@AuraEnabled
		public String strValue {get; set;}
		@AuraEnabled
		public String strStyle {get; set;}
		
		/*
		 Method Name : CellWrapper
		 Description : Constructor of the class.
		 Parameters	 : String, called from getRecords, strRecordId Record Id.
		 Return Type : None
		 */
		public CellWrapper(String strValue) {
			this.strValue = strValue;
			strStyle = 'width: 50%';
		}
	}
}