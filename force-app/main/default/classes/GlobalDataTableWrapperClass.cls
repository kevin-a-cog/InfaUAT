/*
 * Name			:	GlobalDataTableWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/12/2021
 * Description	:	Wrapper class for Global Data Tables.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/12/2021		N/A				Initial version.						N/A
 Vignesh Divakaran		7/8/2022		I2RT-6457		Added Wrapper classes to QueryFilter    T01
 														& Filter
 */
public class GlobalDataTableWrapperClass {

	//Public variables.
	@AuraEnabled
	public String strRecordId {get; set;}
	@AuraEnabled
	public String strMainFilterFieldAPIName {get; set;}
	@AuraEnabled
	public String strObjectName {get; set;}
	@AuraEnabled
	public String strFielSetName {get; set;}
	@AuraEnabled
	public List<String> lstRecordIds {get; set;}
	@AuraEnabled
	public List<String> lstFieldNames {get; set;}
	@AuraEnabled
	public List<String> lstAdditionalFilters {get; set;}
	@AuraEnabled
	public List<ColumnWrapperClass> lstColumns {get; set;}
	@AuraEnabled
	public List<sObject> lstRecords {get; set;}
	@AuraEnabled
	public List<RecordWrapperClass> lstWrappedRecords {get; set;}
	@AuraEnabled
	public List<Object> lstRecordsCustomStructure {get; set;}
	@AuraEnabled
	public Map<String, String> mapCustomColumnLabels {get; set;}
	@AuraEnabled
	public Map<String, String> mapParentChildRelationship {get; set;}
	@AuraEnabled
	public Boolean boolRecordLocked {get; set;}
	//Column Properties Wrapper class.
	public class ColumnWrapperClass {

		//Public variables.
		@AuraEnabled
		public Boolean boolIsFormula {get; set;}
		@AuraEnabled
		public Boolean boolContainsHTML {get; set;}
		@AuraEnabled
		public Boolean boolContainsIcons {get; set;}
		@AuraEnabled
		public Integer initialWidth {get; set;}
		@AuraEnabled
		public String strObjectName {get; set;}
		@AuraEnabled
		public String strParentObject {get; set;}
		@AuraEnabled
		public String strFieldName {get; set;}
		@AuraEnabled
		public String strHelpText {get; set;}
		@AuraEnabled
		public String strInnerStyle {get; set;}
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public String sortable {get; set;}
		@AuraEnabled
		public String fieldName {get; set;}
		@AuraEnabled
		public String target {get; set;}
		@AuraEnabled
		public String type {
			get {
				String strType = 'text';
				String strSubtype = 'text';

					//We initialize the variable.
					if(typeAttributes == null) {
						typeAttributes = new TypeWrapperClass();
					}

				//If we received an object type.
				if(objType != null) {

					//Depending on the field type, we set the corresponding column properties.
					if(objType == Schema.DisplayType.Picklist) {
						strType = 'custom';
						strSubtype = 'picklist';
					} else if(objType == Schema.DisplayType.String) {
						strType = 'text';
					} else if(objType == Schema.DisplayType.Boolean) {
						strType = 'boolean';
						strSubtype = 'boolean';
					} else if(objType == Schema.DisplayType.Email) {
						strType = 'email';
					} else if(objType == Schema.DisplayType.Date || objType == Schema.DisplayType.DateTime) {
						strType = 'date-local';
						typeAttributes.year = 'numeric';
						typeAttributes.month = 'short';
						typeAttributes.day = 'numeric';
					} else if(objType == Schema.DisplayType.Double || objType == Schema.DisplayType.Long || objType == Schema.DisplayType.Integer) {
						strType = 'number';
						typeAttributes.minimumIntegerDigits = 1;
						typeAttributes.maximumFractionDigits = 2;
						cellAttributes = new CellWrapperClass();
						cellAttributes.alignment = 'left';
					} else if(objType == Schema.DisplayType.Percent) {
						strType = 'percent';
						typeAttributes.minimumIntegerDigits = 1;
						typeAttributes.maximumFractionDigits = 2;
						cellAttributes = new CellWrapperClass();
						cellAttributes.alignment = 'left';
					} else if(objType == Schema.DisplayType.Reference) {
						strType = 'custom';
						strSubtype = 'link';
						typeAttributes.objectapiname = strObjectName;
						typeAttributes.label = new LabelWrapperClass();
						if(fieldName.endsWith('__r.Id')) {

							//If the object is Case (an specific exception), we use Case Number field.
							if(Case.getSObjectType().getDescribe().getName() == strObjectName) {
								typeAttributes.label.fieldName = fieldName.replace('__r.Id', '__r.CaseNumber');
							} else if(Event.getSObjectType().getDescribe().getName() == strObjectName) {

								//If the object is Event (an specific exception), we use Subject field.
								typeAttributes.label.fieldName = fieldName.replace('__r.Id', '__r.Subject');
							} else if(Contract.getSObjectType().getDescribe().getName() == strObjectName) {

								//If the object is Contract (an specific exception), we use Subject field.
								typeAttributes.label.fieldName = fieldName.replace('__r.Id', '__r.ContractNumber');
							} else {

								//Otherwise we use Name field.
								typeAttributes.label.fieldName = fieldName.replace('__r.Id', '__r.Name');
							}
						} else if(fieldName.endsWith('.Id')) {
							typeAttributes.label.fieldName = fieldName.replaceAll('(\\.Id)(?!.*\\1)', '.Name');
						} else if(Case.getSObjectType().getDescribe().getName() == strObjectName && fieldName == 'Id') {
							typeAttributes.label.fieldName = 'CaseNumber';
						} else if((Task.getSObjectType().getDescribe().getName() == strObjectName || Event.getSObjectType().getDescribe().getName() == strObjectName) && fieldName == 'Id') {
							typeAttributes.label.fieldName = 'Subject';
						} else if(Contract.getSObjectType().getDescribe().getName() == strObjectName && fieldName == 'Id') {
							typeAttributes.label.fieldName = 'ContractNumber';
						} else {
							typeAttributes.label.fieldName = fieldName;
						}

						//If the field is Name, we mark it.
						if(fieldName == 'Name' || fieldName == 'CaseNumber' || fieldName == 'Subject' || fieldName == 'ContractNumber') {
							typeAttributes.boolisname = true;
						}
					}

					//If the column contains HTML data.
					if(boolContainsHTML != null && boolContainsHTML) {
						strType = 'custom';
						strSubtype = 'html';
					}
				}

				//If the column has icons.
				if(boolContainsIcons != null && boolContainsIcons) {

					//Icons.
					strType = 'custom';
					strSubtype = 'icons';
				}

				//We set the subtype.
				typeAttributes.subtype = strSubtype;
				return strType;
			}
		}
		@AuraEnabled
		public String subtype {
			get {
				String strResult = type;
				if(typeAttributes != null && String.isNotBlank(typeAttributes.subtype)) {
					strResult = typeAttributes.subtype;
				}
				return strResult;
			}
		}
		@AuraEnabled
		public Schema.DisplayType objType {get; set;}
		@AuraEnabled
		public TypeWrapperClass typeAttributes {get; set;}
		@AuraEnabled
		public CellWrapperClass cellAttributes {get; set;}
	}

	//Type Attributes Wrapper class.
	public class TypeWrapperClass {

		//Public variables.
		@AuraEnabled
		public Boolean editable {get; set;}
		@AuraEnabled
		public Boolean boolisname {get; set;}
		@AuraEnabled
		public Integer minimumIntegerDigits {get; set;}
		@AuraEnabled
		public Integer maximumFractionDigits {get; set;}
		@AuraEnabled
		public String year {get; set;}
		@AuraEnabled
		public String month {get; set;}
		@AuraEnabled
		public String day {get; set;}
		@AuraEnabled
		public String objectapiname {get; set;}
		@AuraEnabled
		public String subtype {get; set;}
		@AuraEnabled
		public LabelWrapperClass label {get; set;}
		@AuraEnabled
		public List<PicklistWrapperClass> options {get; set;}
	}

	//Cell Attributes Wrapper class.
	public class CellWrapperClass {

		//Public variables.
		@AuraEnabled
		public String alignment {get; set;}
	}

	//Label Attributes Wrapper class.
	public class LabelWrapperClass {

		//Public variables.
		@AuraEnabled
		public String fieldName {get; set;}
	}

	//Label Attributes Wrapper class.
	public class PicklistWrapperClass {

		//Public variables.
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public String value {get; set;}
	}

	//Records Wrapper class.
	public class RecordWrapperClass {

		//Public variables.
		@AuraEnabled
		public SObject objRecord {get; set;}
		@AuraEnabled
		public List<RecordWrapperClass> lstChildRecords {get; set;}
		@AuraEnabled
		public Map<String, String> mapRecordCustomValues {get; set;}
		@AuraEnabled
		public Map<String, List<RecordWrapperClass>> mapChildWrappedRecords {get; set;}
	}

	//Query Filter Wrapper class.
    public class QueryFilter{ //<T01>
        @AuraEnabled
        public String strFilterCondition {get; set;}
        @AuraEnabled
        public List<Filter> lstFilters {get; set;}
    }

	//Filter Wrapper class.
	public class Filter{ //<T01>
        @AuraEnabled
        public String strFilterField {get; set;}
        @AuraEnabled
        public String strFilterOperator {get; set;}
        @AuraEnabled
        public String strFilterValue {get; set;}
    }

	//Actions Wrapper class.
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
		public String strHelpText {get; set;}
		@AuraEnabled
		public List<ActionWrapper> lstSubactions {get; set;}
	}
}