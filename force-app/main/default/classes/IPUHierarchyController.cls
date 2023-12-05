/*
 * Name			:	IPUHierarchyController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	1/24/2023
 * Description	:	IPU Hierarchy controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		1/24/2023		N/A				Initial version.						N/A
 */
public without sharing class IPUHierarchyController {

	//Public variables.
	public static String STR_DATETIME_FORMAT = 'MM/dd/yyyy';

	/*
	 Method Name : getRecords
	 Description : This method returns the hierarchy of records based on the provided id.
	 Parameters	 : Boolean, called from getRecords, boolShowAllLevels If TRUE, the component will return all levels, regardless of the number of parents.
	 			   String, called from getRecords, strRecordId Record Id.
	 Return Type : Wrapper class.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(Boolean boolShowAllLevels, Id idRecord) {
		String strNewFieldName;
		String strFieldSetOrgEntitlement = '';
		String strFieldSetOrgEntitlementLine = '';
		Date datValue;
		GlobalDataTableWrapperClass objDataTable;
		GlobalDataTableWrapperClass objResult = new GlobalDataTableWrapperClass();
		Set<Id> setOrgIds = new Set<Id>();
		Set<Id> setOrgEntitlementIds = new Set<Id>();
		Set<Id> setFulfillmentLineIds = new Set<Id>();
		Set<String> setOrgUUIDs = new Set<String>();
		Set<String> setFieldSetOrg = new Set<String>();
		Set<String> setFieldSetOrgEntitlement = new Set<String>();
		Set<String> setFieldSetOrgEntitlementLine = new Set<String>();
		List<String> lstFieldSetOrg = new List<String>();
		List<String> lstFieldSetOrgEntitlement = new List<String>();
		List<String> lstFieldSetOrgEntitlementLine = new List<String>();
		Map<String, Object> mapRecordValues;
		Map<String, GlobalDataTableWrapperClass.ColumnWrapperClass> mapFields = new Map<String, GlobalDataTableWrapperClass.ColumnWrapperClass>();

		//If we received data.
		if(idRecord != null) {
			objResult.lstRecordsCustomStructure = new List<Object>();
			objResult.lstColumns = new List<GlobalDataTableWrapperClass.ColumnWrapperClass>();
			objResult.mapParentChildRelationship = new Map<String, String>();

			//If the Id is a Fulfillment.
			if(idRecord.getSObjectType() == Fulfillment__c.sObjectType) {
				for(Fulfillment_Line__c objRecord : [SELECT Id, Org__r.Id, Org__r.Name FROM Fulfillment_Line__c WHERE Fullfillment__c = :idRecord AND Org__c <> NULL LIMIT 50000]) {
					setOrgIds.add(objRecord.Org__r.Id);
					setFulfillmentLineIds.add(objRecord.Id);
				}
			} else if(idRecord.getSObjectType() == Fulfillment_Line__c.sObjectType) {

				//If the Id is a Fulfillment Line.
				for(Fulfillment_Line__c objRecord : [SELECT Id, Org_UUID__c FROM Fulfillment_Line__c WHERE Id = :idRecord LIMIT 50000]) {
					if(objRecord.Org_UUID__c != null) {
						setOrgUUIDs.add(objRecord.Org_UUID__c);
					}
					setFulfillmentLineIds.add(objRecord.Id);
				}
				if(!setOrgUUIDs.isEmpty()) {
					for(Org__c objRecord : [SELECT Id, Name FROM Org__c WHERE OrgID__c IN :setOrgUUIDs LIMIT 500000]) {
						setOrgIds.add(objRecord.Id);
					}
				}
			} else if(idRecord.getSObjectType() == Org__c.sObjectType) {

				//If the Id is an Org.
				for(Org__c objRecord : [SELECT Id, Name FROM Org__c WHERE Id = :idRecord LIMIT 1]) {
					setOrgIds.add(objRecord.Id);
				}
			}

			//If we have Org Ids, we query the Org Entitlements and Org Entitlement Lines.
			if(!setOrgIds.isEmpty() || !setFulfillmentLineIds.isEmpty()) {

				//We get the Field Sets first.
				setFieldSetOrg.add('Id');
				setFieldSetOrg.add('Name');
				for(Schema.FieldSetMember objRecord : SObjectType.Org__c.FieldSets.IPU_Hierarchy_Fields.getFields()) {
					setFieldSetOrg.add(objRecord.getFieldPath());
				}
				if(!setFieldSetOrg.isEmpty()) {
					lstFieldSetOrg.addAll(setFieldSetOrg);
				}
				setFieldSetOrgEntitlement.add('Id');
				setFieldSetOrgEntitlement.add('Name');
				for(Schema.FieldSetMember objRecord : SObjectType.Org_Entitlement__c.FieldSets.IPU_Hierarchy_Fields.getFields()) {
					setFieldSetOrgEntitlement.add(objRecord.getFieldPath());
				}
				if(!setFieldSetOrgEntitlement.isEmpty()) {
					lstFieldSetOrgEntitlement.addAll(setFieldSetOrgEntitlement);
				}
				setFieldSetOrgEntitlementLine.add('Id');
				setFieldSetOrgEntitlementLine.add('Name');
				for(Schema.FieldSetMember objRecord : SObjectType.Org_Entitlement_Line__c.FieldSets.IPU_Hierarchy_Fields.getFields()) {
					setFieldSetOrgEntitlementLine.add(objRecord.getFieldPath());
				}
				if(!setFieldSetOrgEntitlementLine.isEmpty()) {
					lstFieldSetOrgEntitlementLine.addAll(setFieldSetOrgEntitlementLine);
				}

				//We save the Org records, only if there are more than 1.
				if(boolShowAllLevels == null || (setOrgIds.size() > 1 && boolShowAllLevels)) {
					for(Org__c objRecord : Database.query('SELECT ' + String.join(lstFieldSetOrg, ',') + ' FROM Org__c WHERE Id IN :setOrgIds LIMIT 50000')) {
						mapRecordValues = new Map<String, Object>();
						mapRecordValues.put('intRecordLayoutType', 1);
						mapRecordValues.put('intColumnsConfiguration', 1);
						for(String strField : lstFieldSetOrg) {
							strNewFieldName = fixApiNames(strField);
							mapRecordValues.put(strNewFieldName, '');
							if(objRecord.get(strField) != null) {
								if(objRecord.get(strField) instanceof Date) {
									datValue = (Date) objRecord.get(strField);
									mapRecordValues.put(strNewFieldName, Datetime.newInstance(datValue.year(), datValue.month(), datValue.day()).format(STR_DATETIME_FORMAT));
								} else if(objRecord.get(strField) instanceof Boolean) {
									mapRecordValues.put(strNewFieldName, Boolean.valueOf(objRecord.get(strField)));
								} else {
									mapRecordValues.put(strNewFieldName, String.valueOf(objRecord.get(strField)));
								}
							}
						}
						objResult.lstRecordsCustomStructure.add(mapRecordValues);
					}
				}

				//We get any possible related Org Entitlements via Fulfillment Line and Org Entitlement Line.
				if(!setFulfillmentLineIds.isEmpty()) {
					for(Org_Entitlement_Line__c objRecord : [SELECT Org_Entilement__c FROM Org_Entitlement_Line__c WHERE Fulfillment_Line__c IN :setFulfillmentLineIds LIMIT 50000]) {
						setOrgEntitlementIds.add(objRecord.Org_Entilement__c);
					}
				}

				//Now we get the records.
				for(Org_Entitlement__c objRecord : Database.query('SELECT Org_Id__c, ' + String.join(lstFieldSetOrgEntitlement, ',') + ', (SELECT ' + String.join(lstFieldSetOrgEntitlementLine, ',') + 
						' FROM Org_Entitlement_Lines__r) FROM Org_Entitlement__c WHERE Org_Id__c IN :setOrgIds OR Id IN :setOrgEntitlementIds LIMIT 50000')) {

					//We create the initial hierarchy, only if there are more than 1 Org.
					if(boolShowAllLevels == null || (setOrgIds.size() > 1 && boolShowAllLevels)) {
						objResult.mapParentChildRelationship.put(objRecord.Id, objRecord.Org_Id__c);
					}

					//Now we save the Org Entitlement record.
					mapRecordValues = new Map<String, Object>();
					mapRecordValues.put('intRecordLayoutType', 1);
					mapRecordValues.put('intColumnsConfiguration', 2);
					for(String strField : lstFieldSetOrgEntitlement) {
						mapRecordValues.put(strField, '');
						if(objRecord.get(strField) != null) {
							if(objRecord.get(strField) instanceof Date) {
								datValue = (Date) objRecord.get(strField);
								mapRecordValues.put(strField, Datetime.newInstance(datValue.year(), datValue.month(), datValue.day()).format(STR_DATETIME_FORMAT));
							} else if(objRecord.get(strField) instanceof Boolean) {
								mapRecordValues.put(strField, Boolean.valueOf(objRecord.get(strField)));
							} else {
								mapRecordValues.put(strField, String.valueOf(objRecord.get(strField)));
							}
						}
					}
					objResult.lstRecordsCustomStructure.add(mapRecordValues);

					//Now we check the Org Entitlement Line records.
					if(objRecord.Org_Entitlement_Lines__r != null && !objRecord.Org_Entitlement_Lines__r.isEmpty()) {
						for(Org_Entitlement_Line__c objInnerRecord : objRecord.Org_Entitlement_Lines__r) {

							//We create the hierarchy.
							objResult.mapParentChildRelationship.put(objInnerRecord.Id, objRecord.Id);
		
							//Now we save the Org Entitlement record.
							mapRecordValues = new Map<String, Object>();
							mapRecordValues.put('intRecordLayoutType', 1);
							mapRecordValues.put('intColumnsConfiguration', 3);
							for(String strField : lstFieldSetOrgEntitlementLine) {
								mapRecordValues.put(strField, '');
								if(objInnerRecord.get(strField) != null) {
									if(objInnerRecord.get(strField) instanceof Date) {
										datValue = (Date) objInnerRecord.get(strField);
										mapRecordValues.put(strField, Datetime.newInstance(datValue.year(), datValue.month(), datValue.day()).format(STR_DATETIME_FORMAT));
									} else if(objInnerRecord.get(strField) instanceof Boolean) {
										mapRecordValues.put(strField, Boolean.valueOf(objInnerRecord.get(strField)));
									} else {
										mapRecordValues.put(strField, String.valueOf(objInnerRecord.get(strField)));
									}
								}
							}
							objResult.lstRecordsCustomStructure.add(mapRecordValues);
						}
					}
				}

				//Now we get the columns definition.
				objDataTable = new GlobalDataTableWrapperClass();
				objDataTable.strObjectName = Org__c.class.getName();
				objDataTable.lstFieldNames = lstFieldSetOrg;
				for(GlobalDataTableWrapperClass.ColumnWrapperClass objRecord : GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable).lstColumns) {
					switch on objRecord.fieldName {
						when 'Name' {
							objRecord.label = 'Name';
						}
						when 'OrgType__c' {
							objRecord.label = 'Type';
						}
					}
					objRecord.fieldName = fixApiNames(objRecord.fieldName);
					if(objRecord.fieldName == 'Name') {
						objRecord.label = 'Name';
					}
					if(objRecord.fieldName != 'Id') {
						mapFields.put(objRecord.fieldName, objRecord);
					}
				}
				objDataTable = new GlobalDataTableWrapperClass();
				objDataTable.strObjectName = Org_Entitlement__c.class.getName();
				objDataTable.lstFieldNames = lstFieldSetOrgEntitlement;
				for(GlobalDataTableWrapperClass.ColumnWrapperClass objRecord : GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable).lstColumns) {
					if(objRecord.fieldName == 'Name') {
						objRecord.label = 'Name';
					}
					if(objRecord.fieldName != 'Id') {
						mapFields.put(objRecord.fieldName, objRecord);
					}
				}
				objDataTable = new GlobalDataTableWrapperClass();
				objDataTable.strObjectName = Org_Entitlement_Line__c.class.getName();
				objDataTable.lstFieldNames = lstFieldSetOrgEntitlementLine;
				for(GlobalDataTableWrapperClass.ColumnWrapperClass objRecord : GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable).lstColumns) {
					if(objRecord.fieldName == 'Name') {
						objRecord.label = 'Name';
					}
					if(objRecord.fieldName != 'Id') {
						mapFields.put(objRecord.fieldName, objRecord);
					}
				}
				objResult.lstColumns.addAll(mapFields.values());
			}
		}

		//We return the result.
		return objResult;
    }

	/*
	 Method Name : fixApiNames
	 Description : This method syncs the field names.
	 Parameters	 : String, called from fixApiNames, strFieldName Field name.
	 Return Type : String
	 */
    private static String fixApiNames(String strFieldName) {
		String strResult = strFieldName;
		switch on strFieldName {
			when 'OrgID__c' {
				strResult = 'Org_UUID__c';
			}
			when 'OrgType__c' {
				strResult = 'Type__c';
			}
		}
		return strResult;
	}
}