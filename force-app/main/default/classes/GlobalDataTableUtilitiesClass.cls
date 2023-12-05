/*
 * Name			:	GlobalDataTableUtilitiesClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/12/2021
 * Description	:	Utilities class for Global Data Tables.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/12/2021		N/A				Initial version.						N/A
 Vignesh Divakaran		7/8/2022		I2RT-6457		Added Utility method to fetch 			T01
 														datatable fields and records
 Vignesh Divakaran		1/30/2022		I2RT-7685		String escaping single quotes for 		T02 
 														filter value
 Isha Bansal            14/11/2023      I2RT-9463       Correct Subject column for case         T03
 */
public with sharing class GlobalDataTableUtilitiesClass {

	//Public variables.
	public static Set<String> setFieldNames = new Set<String>();

	/*
	 Method Name : getDataTableDetails
	 Description : This method returns the Data Table structure for the provided Object + Field Set.
	 Parameters	 : GlobalDataTableWrapperClass, called from getDataTableDetails, objRequest Request data.
	 Return Type : Data Table structure.
	 */
    public static GlobalDataTableWrapperClass getDataTableDetails(GlobalDataTableWrapperClass objRequest) {
		Schema.DescribeFieldResult objObjectField;
		GlobalDataTableWrapperClass objResult = new GlobalDataTableWrapperClass();
		GlobalDataTableWrapperClass.ColumnWrapperClass objColumn;
		GlobalDataTableWrapperClass.PicklistWrapperClass objPicklist;
		Map<String, Schema.SObjectField> mapObjectFields;
		Map<String, Schema.DescribeFieldResult> mapChildRelationships = new Map<String, Schema.DescribeFieldResult>();

		//First we initialize the variables.
		objResult.lstColumns = new List<GlobalDataTableWrapperClass.ColumnWrapperClass>();
		objResult.lstFieldNames = new List<String>();
		setFieldNames = new Set<String>();

		//Now we get all the child relationships from the given object.
		for(Schema.SobjectField objField : Schema.getGlobalDescribe().get(objRequest.strObjectName).getDescribe().fields.getMap().values()) {
			if(objField.getDescribe().getType() == Schema.DisplayType.REFERENCE) {
				mapChildRelationships.put(objField.getDescribe().getRelationshipName(), objField.getDescribe());
			}
		}

		//If we received the Field Set Name, we use it to get the fields.
		if(String.isNotBlank(objRequest.strFielSetName)) {

			//Now we iterate over the Field Set records.
			for(Schema.FieldSetMember objField : Schema.getGlobalDescribe().get(objRequest.strObjectName).getDescribe().FieldSets.getMap().get(objRequest.strFielSetName).getFields()) {
				objObjectField = objField.getSObjectField().getDescribe();
				objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();
				objColumn.strParentObject = objRequest.strObjectName;
				objColumn.fieldName = objField.getFieldPath();
				objColumn.label = objField.getLabel();
				objColumn.objType = objField.getType();
				objColumn.boolIsFormula = false;
				for(Schema.SObjectType objReference : objObjectField.getReferenceTo()) {
					objColumn.strObjectName = objReference.getDescribe().getName();
				}
				if(objObjectField.isCalculated() || objObjectField.isAutonumber()) {
					objColumn.boolIsFormula = true;
				}

				//Now we check if we have picklist values.
				if(objObjectField.getPicklistValues() != null) {
					if(objColumn.typeAttributes == null) {
						objColumn.typeAttributes = new GlobalDataTableWrapperClass.TypeWrapperClass();
					}
					if(objColumn.typeAttributes.options == null) {
						objColumn.typeAttributes.options = new List<GlobalDataTableWrapperClass.PicklistWrapperClass>();
					}
					for(Schema.PicklistEntry objPicklistValue : objObjectField.getPicklistValues()) {
						objPicklist = new GlobalDataTableWrapperClass.PicklistWrapperClass();
						objPicklist.label = objPicklistValue.getLabel();
						objPicklist.value = objPicklistValue.getValue();
						objColumn.typeAttributes.options.add(objPicklist);
					}
				}

				//Now we set the general details.
				objColumn = completeColumn(objColumn, objRequest, mapChildRelationships);

				//Finally, we add the column.
				objResult.lstColumns.add(objColumn);
			}
		} else if(objRequest.lstFieldNames != null && !objRequest.lstFieldNames.isEmpty()) {

			//As we didn't received a Field Set name, we use the provided fields.
			mapObjectFields = Schema.getGlobalDescribe().get(objRequest.strObjectName).getDescribe().fields.getMap();
			for(String strFieldName : objRequest.lstFieldNames) {
				objObjectField = mapObjectFields.get(strFieldName).getDescribe();
				objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();
				objColumn.strParentObject = objRequest.strObjectName;
				objColumn.fieldName = objObjectField.getName();
				objColumn.label = objObjectField.getLabel();
				objColumn.objType = objObjectField.getType();
				objColumn.boolIsFormula = false;
				for(Schema.SObjectType objReference : objObjectField.getReferenceTo()) {
					objColumn.strObjectName = objReference.getDescribe().getName();
				}
				if(objObjectField.isCalculated() || objObjectField.isAutonumber()) {
					objColumn.boolIsFormula = true;
				}

				//Now we check if we have picklist values.
				if(objObjectField.getPicklistValues() != null) {
					if(objColumn.typeAttributes == null) {
						objColumn.typeAttributes = new GlobalDataTableWrapperClass.TypeWrapperClass();
					}
					if(objColumn.typeAttributes.options == null) {
						objColumn.typeAttributes.options = new List<GlobalDataTableWrapperClass.PicklistWrapperClass>();
					}
					for(Schema.PicklistEntry objPicklistValue : objObjectField.getPicklistValues()) {
						objPicklist = new GlobalDataTableWrapperClass.PicklistWrapperClass();
						objPicklist.label = objPicklistValue.getLabel();
						objPicklist.value = objPicklistValue.getValue();
						objColumn.typeAttributes.options.add(objPicklist);
					}
				}
				
				//Now we set the general details.
				objColumn = completeColumn(objColumn, objRequest, mapChildRelationships);

				//Finally, we add the column.
				objResult.lstColumns.add(objColumn);
			}
		}		

		//We always add the Id.
		setFieldNames.add('Id');
		objResult.lstFieldNames.addAll(setFieldNames);
		return objResult;
    }

	/*
	 Method Name : completeColumn
	 Description : This method completes the provided column with the general configuration.
	 Parameters	 : Object, called from completeColumn, objColumn Column.
	 			   Object, called from completeColumn, objRequest Original request.
				   Map, called from completeColumn, mapChildRelationships Object relationships.
	 Return Type : Column.
	 */
    public static GlobalDataTableWrapperClass.ColumnWrapperClass completeColumn(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn, GlobalDataTableWrapperClass objRequest, 
			Map<String, Schema.DescribeFieldResult> mapChildRelationships) {
		Boolean boolIsCase = false;
		Boolean boolIsEvent = false;

		//If the object is Case (an specific exception), we use Id field.
		if(objColumn.fieldName.endsWith('CaseNumber')) {
			boolIsCase = true;
			setFieldNames.add(objColumn.fieldName);
			objColumn.fieldName = objColumn.fieldName.replace('CaseNumber', 'Id');
		}

		//If the object is Event (an specific exception), we use Id field.
		if(objColumn.fieldName.endsWith('Subject') && objColumn.strParentObject!=Case.getSObjectType().getDescribe().getName()) { //T03: Added Case condition
			boolIsEvent = true;
			setFieldNames.add(objColumn.fieldName);
			objColumn.fieldName = objColumn.fieldName.replace('Subject', 'Id');
		}

		//If the object is Event (an specific exception), we use Id field.
		if(objColumn.fieldName.endsWith('ContractNumber')) {
			boolIsEvent = true;
			setFieldNames.add(objColumn.fieldName);
			objColumn.fieldName = objColumn.fieldName.replace('ContractNumber', 'Id');
		}

		//Now we set the default values.
		objColumn.sortable = 'true';
		objColumn.strFieldName = objColumn.fieldName;

		//Now we check if the field is a reference.
		if(objColumn.objType == Schema.DisplayType.Reference) {
			if(objColumn.fieldName.endsWith('__c')) {
				//If the object is Case (an specific exception), we use Case Number field.
				if(Case.getSObjectType().getDescribe().getName() == objColumn.strObjectName) {
					setFieldNames.add(objColumn.fieldName.replace('__c', '__r.CaseNumber'));
				} else if(Event.getSObjectType().getDescribe().getName() == objColumn.strObjectName) {

					//If the object is Event (an specific exception), we use Subject field.
					setFieldNames.add(objColumn.fieldName.replace('__c', '__r.Subject'));
				} else if(Contract.getSObjectType().getDescribe().getName() == objColumn.strObjectName) {

					//If the object is Contract (an specific exception), we use Subject field.
					setFieldNames.add(objColumn.fieldName.replace('__c', '__r.ContractNumber'));
				} else {

					//Otherwise we use Name field.
					setFieldNames.add(objColumn.fieldName.replace('__c', '__r.Name'));
				}
				objColumn.fieldName = objColumn.fieldName.replace('__c', '__r.Id');
			} else {
				setFieldNames.add(objColumn.fieldName.replaceAll('(Id)(?!.*\\1)', '.Name'));
				objColumn.fieldName = objColumn.fieldName.replaceAll('(Id)(?!.*\\1)', '.Id');
			}
		} else {
			setFieldNames.add(objColumn.fieldName);
		}
		if(objRequest.mapCustomColumnLabels != null && String.isNotBlank(objRequest.mapCustomColumnLabels.get(objColumn.fieldName))) {
			objColumn.label = objRequest.mapCustomColumnLabels.get(objColumn.fieldName);
		}

		//If Name field is included, we convert it into a link in the front end.
		if(objColumn.fieldName == 'Name' || boolIsCase || boolIsEvent) {
			objColumn.strObjectName = objRequest.strObjectName;
			objColumn.objType = Schema.DisplayType.Reference;

			//Now we check if there's a child relationship present in the current field.
			if(mapChildRelationships != null && objColumn.fieldName.contains('.')) {
                for(String strObjectName : objColumn.fieldName.split('\\.')) {
					if(mapChildRelationships.containsKey(strObjectName)) {
						for(Schema.SObjectType objReference : mapChildRelationships.get(strObjectName).getReferenceTo()) {
							objColumn.strObjectName = objReference.getDescribe().getName();
						}
						break;
					}
				}
			}
		}
		return objColumn;
	}

	/*
	 Method Name : getDatatableDetailsAndRecords
	 Description : This method returns the Data Table structure for the provided Object + Field Set and also the SObject records.
	 Parameters	 : String, called from getDatatableDetailsAndRecords, recordId  Record Id.
	 			   String, called from getDatatableDetailsAndRecords, strObjectAPIName Object Name.
	 			   String, called from getDatatableDetailsAndRecords, strFieldsetAPIName FieldSet Name.
				   Object, called from getDatatableDetailsAndRecords, objQueryFilter SOQL query filters.
	 Return Type : Data Table structure.
	 */
	@AuraEnabled
	public static GlobalDataTableWrapperClass getDatatableDetailsAndRecords(String recordId, String strObjectAPIName, String strFieldsetAPIName,GlobalDataTableWrapperClass.QueryFilter objQueryFilter) { //<T01>
        GlobalDataTableWrapperClass objRequest = new GlobalDataTableWrapperClass();
        objRequest.strObjectName = String.escapeSingleQuotes(strObjectAPIName);
        objRequest.strFielSetName = String.escapeSingleQuotes(strFieldsetAPIName);
        GlobalDataTableWrapperClass objResult = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
       
        //Now, we construct the SOQL query to get the sobject records
        if(String.isNotBlank(strObjectAPIName) && !objResult.lstFieldNames.isEmpty()){
            String strQuery = 'SELECT ' + String.join(objResult.lstFieldNames, ',') + ' FROM ' +  objRequest.strObjectName;

            if(objQueryFilter != null){
                List<String> lstFilterConditions = new List<String>();
                for(GlobalDataTableWrapperClass.Filter objFilter : objQueryFilter.lstFilters){
					//---------------------------------------<T02>-----------------------------
					if(objFilter.strFilterValue.startsWith('\'') && objFilter.strFilterValue.endsWith('\'')){
						objFilter.strFilterValue = '\'' +String.escapeSingleQuotes(objFilter.strFilterValue.removeStart('\'').removeEnd('\''))+ '\'';
					}
					else{
						objFilter.strFilterValue = String.escapeSingleQuotes(objFilter.strFilterValue);
					}
					//---------------------------------------<T02>-----------------------------
                    String tempString = String.escapeSingleQuotes(objFilter.strFilterField) + ' ' + String.escapeSingleQuotes(objFilter.strFilterOperator) + ' ' +objFilter.strFilterValue; //<T02>
                    lstFilterConditions.add(tempString); 
                }

				//Now, we construct all the filter conditions
                strQuery += ' WHERE '+String.join(lstFilterConditions, ' ' + String.escapeSingleQuotes(objQueryFilter.strFilterCondition) + ' ');
            }

            strQuery += ' WITH SECURITY_ENFORCED';
            objResult.lstRecords = Database.query(strQuery);
        }

		return objResult;
	}
}