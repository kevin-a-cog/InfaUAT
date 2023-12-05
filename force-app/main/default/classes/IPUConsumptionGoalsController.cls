/*
 * Name			:	IPUConsumptionGoalsController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/15/2023
 * Description	:	IPU Consumption Goals controller.

 Change History
 ***************************************************************************************************************************
 Modified By			Date			Jira No.		Description												Tag
 ***************************************************************************************************************************
 Monserrat Pedroza		3/15/2023		N/A				Initial version.										N/A
 Karthi G               22/11/2023        AR-3561          Changing the Opty close date criteria                T1
 */
public without sharing class IPUConsumptionGoalsController {

	//Public variables.
	public static String STR_DATETIME_FORMAT = 'MM/dd/yyyy';
	public static List<String> LST_ORG_TYPE = new List<String>{'Production'};

	/*
	 Method Name : saveButtonType
	 Description : This method returns which save button should be displayed.
	 Parameters	 : idRecord, called from saveButtonType, idRecord Record Id.
	 Return Type : Integer. 0 = Save; 1 = Save and Consumption Goals; 2 = Save and Churn Forecast;
	 */
    @AuraEnabled(cacheable = false)
    public static Integer saveButtonType(Id idRecord) {
		Boolean boolRenewalOpportunityInNext365Days = false;
		Boolean boolIPUProductOnPlan = false;
		Boolean boolHasProdOrg = false;
		Integer intResult = 0;

		//If we have IPU Products.
		if(Database.countQuery('SELECT count() FROM Related_Account_Plan__c WHERE (Account_Plan__c = :idRecord OR Account__c = :idRecord) AND Forecast_Product__c = \'IPU\' AND ' + 
				'Contract__r.SBQQ__Order__c <> NULL') != 0) {
			boolIPUProductOnPlan = true;
		}
		
		//If we have Renewal Opportunities closing in the next 365 days.
		if(Database.countQuery('SELECT count() FROM Related_Opportunity_Plan__c WHERE (Plan__c = :idRecord OR Account__c = :idRecord) AND (Opportunity__r.CloseDate =NEXT_N_DAYS:365  AND Opportunity__r.CloseDate >NEXT_N_DAYS:120 AND ' + //T1
				'(Opportunity__r.OARR_OnPrem_Subscription1__c>0 OR Opportunity__r.OARR_Cloud1__c>0))') != 0) {
			boolRenewalOpportunityInNext365Days = true;
		}

		//If we have Prod Orgs.
		idRecord = getAccountId(idRecord);
		if(Database.countQuery('SELECT count() FROM Org__c WHERE OrgType__c IN :LST_ORG_TYPE AND Account__c = :idRecord') != 0) {
			boolHasProdOrg = true;
		}

		//Now we decide the type of button.
		if(boolHasProdOrg && boolIPUProductOnPlan) {
			intResult = 1;
		}
		else if(boolRenewalOpportunityInNext365Days){
			intResult = 2;
		}

		//We return the result.
		return intResult;
	}

	/*
	 Method Name : getRecords
	 Description : This method returns the hierarchy of records based on the provided id.
	 Parameters	 : Boolean, called from getRecords, boolIsReadOnly If TRUE, the columns for existing records won't be editable.
	 			   Boolean, called from getRecords, boolGetActiveIPUConsumptionGoals If TRUE, Active IPU Consumption Goals will be retrieved.
				   Id, called from getRecords, idRecord Record Id.
	 Return Type : Wrapper class.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(Boolean boolIsReadOnly, Boolean boolGetActiveIPUConsumptionGoals, Id idRecord) {
		Boolean boolHasObjectiveOnList;
		Date datValue;
		Object objValue;
		IPUConsumptionGoalsWrapper objSortedValue;
		IPUConsumptionGoalsWrapper objSortedObjective;
		GlobalDataTableWrapperClass objDataTable;
		GlobalDataTableWrapperClass objResult = new GlobalDataTableWrapperClass();
		GlobalDataTableWrapperClass.ActionWrapper objAction;
		GlobalDataTableWrapperClass.ColumnWrapperClass objColumn;
		Set<String> setOrgServicesWithInactiveICGRecords = new Set<String>();
		Set<String> setUniqueIds = new Set<String>();
		Set<String> setFieldSetICG = new Set<String>();
		Set<String> setSortableFields = new Set<String>();
		Set<String> setColumnsOrder = new Set<String>();
		Set<String> setEditableFields = new Set<String>();
		Set<String> setIncludedOrgServices = new Set<String>();
		List<String> lstFieldSetICG = new List<String>();
		List<IPUConsumptionGoalsWrapper> lstSortableValues = new List<IPUConsumptionGoalsWrapper>();
		List<IPUConsumptionGoalsWrapper> lstSortableObjectives;
		List<GlobalDataTableWrapperClass.ActionWrapper> lstActions;
		List<Map<String, String>> lstServices;
		List<Map<String, String>> lstLocalServices;
		List<Map<String, String>> lstObjectives;
		List<Map<String, String>> lstConfirmedObjectives;
		Map<String, Object> mapRecordValues;
		Map<String, GlobalDataTableWrapperClass.ColumnWrapperClass> mapFields = new Map<String, GlobalDataTableWrapperClass.ColumnWrapperClass>();
		Set<String> inactiveOrgServices = new Set<String>();
        inactiveOrgServices.addAll([Select Value_Long_text__c from CSM_Static_Value__mdt WHERE DeveloperName='ICGInactiveOrgServices' LIMIT 1]?.Value_Long_text__c?.split(','));
		setOrgServicesWithInactiveICGRecords.addAll(inactiveOrgServices);
		//If we received data.
		if(idRecord != null) {
			objResult.lstRecordsCustomStructure = new List<Object>();
			objResult.lstColumns = new List<GlobalDataTableWrapperClass.ColumnWrapperClass>();

			//We get the Account id, based on the object type.
			idRecord = getAccountId(idRecord);

			//If we have an Account Id.
			if(idRecord.getSObjectType() == Account.SObjectType) {

				//We get the Field Sets first.
				setFieldSetICG.add('Id');
				setFieldSetICG.add('Name');
				setFieldSetICG.add('Expected_Goal__c');
				setFieldSetICG.add('Objective_Name__c');
				setFieldSetICG.add('Objective_Id__c');
				setFieldSetICG.add('Expected_Date__c');
				setFieldSetICG.add('Comments__c');
				if(!setFieldSetICG.isEmpty()) {
					lstFieldSetICG.addAll(setFieldSetICG);
				}

				//We set the sortable fields.
				setSortableFields.add('Name');

				//We set the columns order.
				setColumnsOrder.add('Name');
				setColumnsOrder.add('Estimated IPUs');
				setColumnsOrder.add('Last Billing Cycle Usage');
				setColumnsOrder.add('Expected_Goal__c');
				setColumnsOrder.add('Objective_Name__c');
				setColumnsOrder.add('Expected_Date__c');
				setColumnsOrder.add('Comments__c');

				//We set the editable fields.
				setEditableFields.add('Name');
				setEditableFields.add('Expected_Goal__c');
				setEditableFields.add('Objective_Name__c');
				setEditableFields.add('Expected_Date__c');
				setEditableFields.add('Comments__c');

				//Now we get the Service picklist values.
				lstServices = getServicePicklistValues(idRecord);

				//Now we get the Objectives per Account.
				lstObjectives = getObjectives(idRecord);

				//Now we get the records.
				for(IPU_Consumption_Goal__c objRecord : Database.query('SELECT Service__c, Active__c, ' + String.join(lstFieldSetICG, ',') + ' FROM IPU_Consumption_Goal__c WHERE ' + 
						'Is_Latest__c = TRUE AND Account__c = :idRecord ORDER BY Name ASC LIMIT 50000')) {

					//If the record is inactive, we store the Id.
					if(!objRecord.Active__c) {
						setOrgServicesWithInactiveICGRecords.add(objRecord.Service__c);
					}

					//If the status matches the current tab.
					if(boolGetActiveIPUConsumptionGoals == objRecord.Active__c) {

						//If we have a objective, we make sure it is part of the picklist.
						boolHasObjectiveOnList = false;
						if(objRecord.Objective_Id__c != null) {
							for(Map<String, String> mapObjectiveValues : lstObjectives) {
								if(mapObjectiveValues.containsKey(objRecord.Objective_Id__c)) {
									boolHasObjectiveOnList = true;
									break;
								}
							}

							//We check if we have the objective on the list.
							if(boolHasObjectiveOnList) {
								lstConfirmedObjectives = lstObjectives;
							} else {

								//We don't have it, so we add it and sort the list.
								lstSortableObjectives = new List<IPUConsumptionGoalsWrapper>();
								lstConfirmedObjectives = new List<Map<String, String>>();

								//We add the value.
								lstConfirmedObjectives.addAll(lstObjectives);
								lstConfirmedObjectives.add(new Map<String, String> {
									'label' => objRecord.Objective_Name__c,
									'value' => objRecord.Objective_Id__c
								});

								//We sort the values.
								for(Map<String, String> mapValueToBeSorted : lstConfirmedObjectives) {
									objSortedObjective = new IPUConsumptionGoalsWrapper();
									objSortedObjective.intSortTarget = 2;
									objSortedObjective.strObjectiveName = mapValueToBeSorted.get('label');
									objSortedObjective.mapObjectives = mapValueToBeSorted;
									lstSortableObjectives.add(objSortedObjective);
								}
								lstSortableObjectives.sort();
								
								//Now we add the sorted objectives to the confirmed list.
								lstConfirmedObjectives = new List<Map<String, String>>();
								setUniqueIds = new Set<String>();
								for(IPUConsumptionGoalsWrapper objFinalSortedObjective : lstSortableObjectives) {
									if(!setUniqueIds.contains(objFinalSortedObjective.mapObjectives.get('value'))) {
										lstConfirmedObjectives.add(objFinalSortedObjective.mapObjectives);
										setUniqueIds.add(objFinalSortedObjective.mapObjectives.get('value'));
									}
								}
							}
						} else {
							lstConfirmedObjectives = lstObjectives;
						}
	
						//Now we save the ICG record.
						lstLocalServices = lstServices;
						lstLocalServices.add(new Map<String, String> {
							'label' => objRecord.Service__c,
							'value' => objRecord.Service__c
						});
						mapRecordValues = new Map<String, Object>();
						mapRecordValues.put('intRecordLayoutType', 1);
						mapRecordValues.put('lstOverridenValues', new List<Object> {
							new Map<String, Object> {
								'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
								'strRecordFieldAPIName' => 'Name',
								'objAdditionalAttributes' => new Map<String, Object> {
									'strEditableFieldName' => 'Service__c',
									'strEditableFieldType' => 'picklist',
									'lstPicklistOptions' => lstLocalServices
								}
							},
							new Map<String, Object> {
								'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
								'strRecordFieldAPIName' => 'Comments__c',
								'objAdditionalAttributes' => new Map<String, Object> {
									'lstCSS' => new List<String> {
										'{ max-width: 200px; white-space: normal; padding-right: 10px; }'
									}
								}
							},
							new Map<String, Object> {
								'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
								'strRecordFieldAPIName' => 'Objective_Name__c',
								'objAdditionalAttributes' => new Map<String, Object> {
									'strEditableFieldName' => 'Objective_Name__c',
									'strEditableFieldType' => 'picklist',
									'strSelectedValue' => objRecord.Objective_Id__c,
									'lstPicklistOptions' => lstConfirmedObjectives
								}
							},
							new Map<String, Object> {
								'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
								'strRecordFieldAPIName' => 'Expected_Date__c',
								'objAdditionalAttributes' => new Map<String, Object> {
									'strEditableFieldName' => 'Expected_Date__c',
									'strEditableFieldType' => 'standarddate',
									'strSelectedValue' => objRecord.Expected_Date__c
								}
							}
						});
						for(String strField : lstFieldSetICG) {
							objValue = extractValueRecursively(objRecord, strField);
							if(objValue instanceof Date) {
								datValue = (Date) objValue;
								mapRecordValues.put(strField, Datetime.newInstance(datValue.year(), datValue.month(), datValue.day()).format(STR_DATETIME_FORMAT));
							} else {
								if(strField == 'Name') {
									mapRecordValues.put(strField, objRecord.Service__c);
									setIncludedOrgServices.add(objRecord.Service__c);
								} else {
									switch on strField {
										when else {
											mapRecordValues.put(strField, String.valueOf(objValue));
										}
									}
								}
							}
						}
						objSortedValue = new IPUConsumptionGoalsWrapper();
						objSortedValue.intSortTarget = 1;
						objSortedValue.strServiceName = (String) mapRecordValues.get('Name');
						objSortedValue.mapRecordValues = mapRecordValues;
						lstSortableValues.add(objSortedValue);
					}
				}
				for(Org_Service__c objRecord : [SELECT Id, Name, Number_of_Entitlements_consumed__c, Previous_Number_of_Entitlements_consumed__c, Estimated_Number_of_entitlements__c FROM Org_Service__c WHERE Org_ID__r.Account__c = :idRecord AND Service_Type__c='Service' ORDER BY Name ASC LIMIT 50000]) {
	
                        if(!inactiveOrgServices.contains(objRecord.Name) && setOrgServicesWithInactiveICGRecords.contains(objRecord.Name) && objRecord.Number_of_Entitlements_consumed__c>0){
                        	setOrgServicesWithInactiveICGRecords.remove(objRecord.Name);
                        }
						//If there's already an IPU Consumption Goal record, we merge the data.
						if(setIncludedOrgServices.contains(objRecord.Name)) {
							for(Object objMapRecordValues : lstSortableValues) {
								objSortedValue = (IPUConsumptionGoalsWrapper) objMapRecordValues;
								if(objSortedValue.mapRecordValues.get('Name') == objRecord.Name) {
	
									//Now we add the values.
									addOrgServiceRecord(objRecord, objSortedValue.mapRecordValues);
								}
							}
						} else {
		
							//Now we set the record structure.
							lstLocalServices = lstServices;
							lstLocalServices.add(new Map<String, String> {
								'label' => objRecord.Name,
								'value' => objRecord.Name
							});
							mapRecordValues = new Map<String, Object>();
							mapRecordValues.put('intRecordLayoutType', 1);
							mapRecordValues.put('lstOverridenValues', new List<Object> {
								new Map<String, Object> {
									'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
									'strRecordFieldAPIName' => 'Name',
									'objAdditionalAttributes' => new Map<String, Object> {
										'strEditableFieldName' => 'Service__c',
										'strEditableFieldType' => 'picklist',
										'lstPicklistOptions' => lstLocalServices
									}
								},
								new Map<String, Object> {
									'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
									'strRecordFieldAPIName' => 'Comments__c',
									'objAdditionalAttributes' => new Map<String, Object> {
										'lstCSS' => new List<String> {
											'{ max-width: 200px; white-space: normal; padding-right: 10px; }'
										}
									}
								},
								new Map<String, Object> {
									'strRecordObjectAPIName' => 'IPU_Consumption_Goal__c',
									'strRecordFieldAPIName' => 'Objective_Name__c',
									'objAdditionalAttributes' => new Map<String, Object> {
										'strEditableFieldName' => 'Objective_Name__c',
										'strEditableFieldType' => 'picklist',
										'lstPicklistOptions' => lstObjectives
									}
								}
							});
	
							//Now we add the values.
							mapRecordValues.put('Id', objRecord.Id);
							mapRecordValues.put('Name', objRecord.Name);
	
							//We set the general values.
							addOrgServiceRecord(objRecord, mapRecordValues);
	
							//We save the structure
							objSortedValue = new IPUConsumptionGoalsWrapper();
							objSortedValue.intSortTarget = 1;
							objSortedValue.strServiceName = (String) mapRecordValues.get('Name');
							objSortedValue.mapRecordValues = mapRecordValues;
							lstSortableValues.add(objSortedValue);
							setIncludedOrgServices.add(objRecord.Name);
						}
				}

				//Now we sort the records and add them to the main list.
				lstSortableValues.sort();
				for(IPUConsumptionGoalsWrapper objWrappedSortedValue : lstSortableValues) {
					List<GlobalDataTableWrapperClass.ActionWrapper> wrp = (List<GlobalDataTableWrapperClass.ActionWrapper>)objWrappedSortedValue.mapRecordValues?.get('Last Billing Cycle Usage');
					String strServiceName = (String)objWrappedSortedValue.mapRecordValues.get('Name');
					Integer usage = (wrp!=null && wrp.size()>0) ? Integer.valueof(wrp[0]?.strLabel):0;
					//If the Org Service is not related to an Inactive ICG record and we are in the Active tab, or we are in the Inactive tab.
					if((boolGetActiveIPUConsumptionGoals && !setOrgServicesWithInactiveICGRecords.contains(strServiceName)) || (!boolGetActiveIPUConsumptionGoals && setOrgServicesWithInactiveICGRecords.contains(strServiceName))){
						objResult.lstRecordsCustomStructure.add(objWrappedSortedValue.mapRecordValues);
					}
				}

				//We prepare the table.
				objDataTable = new GlobalDataTableWrapperClass();
				objDataTable.strObjectName = IPU_Consumption_Goal__c.class.getName();
				objDataTable.lstFieldNames = lstFieldSetICG;
				for(GlobalDataTableWrapperClass.ColumnWrapperClass objRecord : GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable).lstColumns) {
					if(objRecord.fieldName == 'Name') {
						objRecord.label = 'Service';
					}
					if(setSortableFields.contains(objRecord.fieldName)) {
						objRecord.sortable = 'true';
					}
					if(objRecord.fieldName != 'Id') {
						mapFields.put(objRecord.fieldName, objRecord);
					}
					if((boolIsReadOnly == null || !boolIsReadOnly) && objRecord.fieldName != 'Name') {
						objRecord.typeAttributes.editable = true;
					}
					objRecord.typeAttributes.objectapiname = objDataTable.strObjectName;

					//Now we define the initial width of the columns.
					defineInitialColumnWidth(objRecord);
				}

				//We add Custom columns.
				objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();
				objColumn.boolContainsHTML = false;
				objColumn.boolIsFormula = false;
				objColumn.fieldName = 'Estimated IPUs';
				objColumn.label = objColumn.fieldName;
				objColumn.strHelpText = Label.Help_Hint_Estimated_IPUs;
				objColumn.strInnerStyle = 'white-space: normal;';
				objColumn.objType = Schema.DisplayType.String;
				objColumn.sortable = 'false';
				objColumn.strFieldName = objColumn.fieldName;
				objColumn.strObjectName = 'IPU_Consumption_Goal__c';
				mapFields.put(objColumn.fieldName, objColumn);
				objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();
				objColumn.boolContainsIcons = true;
				objColumn.fieldName = 'Last Billing Cycle Usage';
				objColumn.label = objColumn.fieldName;
				objColumn.strFieldName = objColumn.fieldName;
				objColumn.strInnerStyle = 'white-space: normal;';
				objColumn.initialWidth = 90;
				mapFields.put(objColumn.fieldName, objColumn);

				//Finally we set the column order.
				for(String strColumnName : setColumnsOrder) {
					objResult.lstColumns.add(mapFields.get(strColumnName));
				}
			}
		}

		//We return the result.
		return objResult;
    }

	/*
	 Method Name : saveRecords
	 Description : This method saves the given records.
	 Parameters	 : Id, called from saveRecords, idRecord Plan Id.
	 			   List, called from saveRecords, lstRecords Records.
	 Return Type : void
	 */
	@AuraEnabled(cacheable = false)
    public static void saveRecords(Id idRecord, List<IPU_Consumption_Goal__c> lstRecords) {
		Id idAccount;
		Set<String> setExistingRecords = new Set<String>();
		Set<String> setUniqueIdsToInsert = new Set<String>();
		Set<String> setServices = new Set<String>();
		List<Map<String, String>> lstObjectives;
		List<IPU_Consumption_Goal__c> lstRecordsToInsert = new List<IPU_Consumption_Goal__c>();
		List<IPU_Consumption_Goal__c> lstRecordsToUpdate = new List<IPU_Consumption_Goal__c>();

		//If we received records.
		if(lstRecords != null && !lstRecords.isEmpty()) {

			//We get the Account Id.
			idAccount = getAccountId(idRecord);

			//Now we mark all the existing records as "not latest" and update Objectives selections.
			for(IPU_Consumption_Goal__c objRecord : lstRecords) {
				if(objRecord.Id != null) {
					setExistingRecords.add(objRecord.Id);
				}
				if(String.isNotBlank(objRecord.Objective_Id__c) && objRecord.Objective_Id__c == 'None') {
					objRecord.Objective_Id__c = '';
				}

				//We set the general values.
				objRecord.Account__c = idAccount;
				objRecord.Objective_Name__c = null;
				objRecord.Is_Latest__c = true;
				objRecord.Unique_Id__c = idAccount + objRecord.Service__c + 'true';
				setExistingRecords.add(objRecord.Unique_Id__c);
				setServices.add(objRecord.Service__c);

				//If it is a new record, we mark it for saving.
				if(objRecord.Id == null || objRecord.Id.getSObjectType() == Org_Service__c.SObjectType) {
					setUniqueIdsToInsert.add(objRecord.Unique_Id__c);
				}
			}
			lstObjectives = getObjectives(idAccount);
			lstObjectives.add(new Map<String, String> {
				'label' => 'None',
				'value' => ''
			});
			for(Map<String, String> mapRecord : lstObjectives) {
				for(IPU_Consumption_Goal__c objRecord : lstRecords) {
					if(objRecord.Objective_Id__c != null && mapRecord.get('value') == objRecord.Objective_Id__c) {
						objRecord.Objective_Name__c = (String) mapRecord.get('label');
					}
				}
			}
			for(IPU_Consumption_Goal__c objRecord : lstRecords) {
				if(objRecord.Objective_Id__c != null && objRecord.Objective_Name__c == null) {
					throw new AuraHandledException(Label.Invalid_Objective + '|||' + objRecord.Id);
				}
			}
			for(IPU_Consumption_Goal__c objRecord : lstRecords) {
				objRecord.Id = null;
			}
			if(!setExistingRecords.isEmpty()) {
				for(IPU_Consumption_Goal__c objRecord : [SELECT Id, Service__c, Unique_Id__c, Expected_Goal__c, Objective_Id__c, Expected_Date__c, Comments__c, Account__c FROM 
						IPU_Consumption_Goal__c WHERE (Id IN :setExistingRecords OR Unique_Id__c IN :setExistingRecords) AND Is_Latest__c = TRUE AND Account__c = :idAccount LIMIT 50000]) {

					//We look for Org Service value previously stored.
					for(IPU_Consumption_Goal__c objInnerRecord : lstRecords) {
						if(objRecord.Unique_Id__c == objInnerRecord.Unique_Id__c) {

							//Now we make sure there's an actual change in the new record.
							if(objRecord.Expected_Goal__c != objInnerRecord.Expected_Goal__c || objRecord.Objective_Id__c != objInnerRecord.Objective_Id__c || 
									objRecord.Expected_Date__c != objInnerRecord.Expected_Date__c || objRecord.Comments__c != objInnerRecord.Comments__c) {
								setUniqueIdsToInsert.add(objRecord.Unique_Id__c);

								//Now we set the new values.
								objRecord.Is_Latest__c = false;
								objRecord.Unique_Id__c = idAccount + objRecord.Service__c + 'false' + Datetime.now().millisecond();
								lstRecordsToUpdate.add(objRecord);
							}
						}
					}
				}
				if(!lstRecordsToUpdate.isEmpty()) {
					update lstRecordsToUpdate;
				}
			}
			
			Map<String,Decimal> mapConsumption = new Map<String,Decimal>();
			//Now we query the Actual values, to validate them.
			for(Org_Service__c objRecord : [SELECT Id, Name, Number_of_Entitlements_consumed__c FROM Org_Service__c WHERE Org_ID__r.Account__c = :idAccount AND Name IN :setServices  AND Service_Type__c='Service' LIMIT 50000]) {
				if(mapConsumption.containsKey(objRecord.Name)){
					Decimal val = mapConsumption.get(objRecord.Name)+objRecord.Number_of_Entitlements_consumed__c;
					mapConsumption.put(objRecord.Name,val);
				}
				else{
					mapConsumption.put(objRecord.Name,objRecord.Number_of_Entitlements_consumed__c);
				}
			}

			for(IPU_Consumption_Goal__c objInnerRecord : lstRecords) {
					//We check the comments field.
				if(mapConsumption.containsKey(objInnerRecord.Service__c) && mapConsumption.get(objInnerRecord.Service__c) > objInnerRecord.Expected_Goal__c) {
					if(String.isBlank(objInnerRecord.Comments__c)) {
						throw new AuraHandledException(Label.Comments_Required);
					}
				}
			}
			
	
			//Now we insert the new records.
			for(IPU_Consumption_Goal__c objRecord : lstRecords) {
				if(setUniqueIdsToInsert.contains(objRecord.Unique_Id__c)) {
					lstRecordsToInsert.add(objRecord);
				}
			}
			if(!lstRecordsToInsert.isEmpty()) {
				insert lstRecordsToInsert;
			}
		}
	}

	/*
	 Method Name : getServicePicklistValues
	 Description : This method retrieves the available Services, according to the Services used in the Org.
	 Parameters	 : Id, called from getServicePicklistValues, Account Id.
	 Return Type : List<Map<String, String>>
	 */
	@AuraEnabled(cacheable = false)
    public static List<Map<String, String>> getServicePicklistValues(Id idRecord) {
		Id idAccount;
		Set<String> setExcludedValues = new Set<String>();
		Set<String> setIgnoredValues = new Set<String>{
			'Additional Production org',
			'Pre-release',
			'Pre Release',
			'Pre-Release',
			'Pre release',
			'Sub-Org',
			'Sandbox',
			'Additional Production Org', 
			'Sub Org', 
			'Sandbox Orgs'
		};
		List<Map<String, String>> lstValues = new List<Map<String, String>>();

		//We get the Account Id.
		idAccount = getAccountId(idRecord);

		//Now we look for existing Services.
		for(IPU_Consumption_Goal__c objRecord : [SELECT Service__c FROM IPU_Consumption_Goal__c WHERE Account__c = :idAccount AND Is_Latest__c = TRUE LIMIT 50000]) {
			setExcludedValues.add(objRecord.Service__c);
		}
		for(Org_Service__c objRecord : [SELECT Name FROM Org_Service__c WHERE Org_ID__r.Account__c = :idAccount LIMIT 50000]) {
			setExcludedValues.add(objRecord.Name);
		}

		//Now we get the values.
		for(Product2 objRecord : [SELECT Name FROM Product2 WHERE IsActive = TRUE AND (IICS_Meter_ID__c != NULL OR Name = 'Pre-Release') AND GTM_Model__c = NULL ORDER BY Name LIMIT 50000]) {
			if((setExcludedValues==null || !setExcludedValues.contains(objRecord.Name)) && !setIgnoredValues.contains(objRecord.Name)) {
				lstValues.add(new Map<String, String> {
					'label' => objRecord.Name,
					'value' => objRecord.Name
				});
			}
		}
		return lstValues;
	}

	/*
	 Method Name : getObjectives
	 Description : This method returns the Objectives related to the given Account.
	 Parameters	 : Id, called from getObjectives, idRecord Plan Id.
	 Return Type : List of values.
	 */
	@AuraEnabled(cacheable = false)
	public static List<Map<String, String>> getObjectives(Id idRecord) {
		Id idAccount;
		Set<Id> setUniqueIds = new Set<Id>();
		List<Map<String, String>> lstRecords = new List<Map<String, String>>();

		//We get the Account Id.
		idAccount = getAccountId(idRecord);

		//Now we prepare the values.
		lstRecords.add(new Map<String, String> {
			'label' => 'None',
			'value' => 'None'
		});
		for(Objective__c objRecord : [SELECT Id, Name FROM Objective__c WHERE Plan__r.Account__c = :idAccount AND Status__c IN ('Yet to Start', 'In Progress') ORDER BY Name ASC LIMIT 50000]) {
			if(!setUniqueIds.contains(objRecord.Id)) {
				lstRecords.add(new Map<String, String> {
					'label' => objRecord.Name,
					'value' => objRecord.Id
				});
				setUniqueIds.add(objRecord.Id);
			}
		}
		return lstRecords;
	}

	/*
	 Method Name : getAccountId
	 Description : This method returns the account id, based on the given id.
	 Parameters	 : Object, called from getAccountId, idRecord Record id.
	 Return Type : Id
	 */
	@AuraEnabled(cacheable = false)
	public static Id getAccountId(Id idRecord) {
		Id idAccount = idRecord;
		if(idRecord.getSObjectType() == Plan__c.SObjectType) {
			for(Plan__c objRecord : [SELECT Account__c FROM Plan__c WHERE Id = :idRecord AND Account__c <> NULL LIMIT 1]) {
				idAccount = objRecord.Account__c;
			}
		}
		return idAccount;
	}

	/*
	 Method Name : getAccountNumber
	 Description : This method returns the account id, based on the given id.
	 Parameters	 : Object, called from LWC, idRecord Record id.
	 Return Type : String
	 */
	@AuraEnabled(cacheable = false)
	public static String getAccountNumber(Id idRecord) {
		String strAccountNumber = '';
		if(idRecord.getSObjectType() == Plan__c.SObjectType) {
			for(Plan__c objRecord : [SELECT Account__r.New_Org_Account_Number__c FROM Plan__c WHERE Id = :idRecord AND Account__c <> NULL LIMIT 1]) {
				strAccountNumber = objRecord.Account__r.New_Org_Account_Number__c;
			}
		}
		else{
			Account acc = [SELECT New_Org_Account_Number__c FROM Account WHERE Id = :idRecord LIMIT 1];
			strAccountNumber = acc.New_Org_Account_Number__c;
		}
		return strAccountNumber;
	}

	/*
	 Method Name : extractValueRecursively
	 Description : This method extracts a value recursively, from a parent-child relationship.
	 Parameters	 : Object, called from extractValueRecursively, objParent Parent sObject.
	 			   String, called from extractValueRecursively, strPath Relationship path.
	 Return Type : Object
	 */
	public static Object extractValueRecursively(sObject objParent, String strPath) {
		String strCurrentLevel;
		String strRestOfLevel;
		Object objValue;
		List<String> lstPaths = new List<String>();
		if(objParent != null) {
			if(!strPath.contains('.')) {
				objValue = objParent.get(strPath);
			}
		}
		return objValue;
	}

	/*
	 Method Name : defineInitialColumnWidth
	 Description : This method sets the column width, based on the field api name.
	 Parameters	 : Object, called from defineInitialColumnWidth, objRecord Column.
	 Return Type : Object
	 */
	public static void defineInitialColumnWidth(GlobalDataTableWrapperClass.ColumnWrapperClass objRecord) {
		switch on objRecord.fieldName {
			when 'Name' {
				objRecord.initialWidth = 570;
			}
			when 'Expected_Goal__c' {
				objRecord.initialWidth = 80;
			}
			when 'Objective_Name__c' {
				objRecord.initialWidth = 450;
			}
			when 'Expected_Date__c' {
				objRecord.initialWidth = 170;
			}
			when 'Comments__c' {
				objRecord.initialWidth = 250;
			}
		}
	}

	/*
	 Method Name : addOrgServiceRecord
	 Description : This method sets the Org Service record.
	 Parameters	 : Object, called from addOrgServiceRecord, objInnerRecord Org Service record.
	 			   Map, called from addOrgServiceRecord, mapRecordValues Record values.
	 Return Type : Object
	 */
	public static void addOrgServiceRecord(Org_Service__c objInnerRecord, Map<String, Object> mapRecordValues) {
		Decimal decActualTrend = 0;
		Decimal decActualUsage = 0;
		Integer intTotal;
		List<GlobalDataTableWrapperClass.ActionWrapper> lstActions;

		//We add the Estimated IPUs.
		if(objInnerRecord.Estimated_Number_of_entitlements__c != null) {
			intTotal = (Integer) mapRecordValues.get('Estimated IPUs');
			if(intTotal == null) {
				intTotal = 0;
			}
			mapRecordValues.put('Estimated IPUs', Integer.valueOf(objInnerRecord.Estimated_Number_of_entitlements__c + intTotal));
		}

		//We save the Last Billing Cycle Usage value. First we check if we have any previous value.
		if(objInnerRecord.Number_of_Entitlements_consumed__c != null) {
			lstActions = (List<GlobalDataTableWrapperClass.ActionWrapper>) mapRecordValues.get('Last Billing Cycle Usage');
			if(lstActions != null && !lstActions.isEmpty()) {
				for(GlobalDataTableWrapperClass.ActionWrapper objAction : lstActions) {
					if(String.isNotBlank(objAction.strLabel)) {
						decActualUsage = Decimal.valueOf(objAction.strLabel);
					}
					if(String.isNotBlank(objAction.strHelpText)) {
						decActualTrend = Decimal.valueOf(objAction.strHelpText);
					}
				}
			} else {
				lstActions = new List<GlobalDataTableWrapperClass.ActionWrapper>();
				lstActions.add(new GlobalDataTableWrapperClass.ActionWrapper());
			}
	
			//Now we set the Last Billing Usage Cycle value (Actual Usage).
			for(GlobalDataTableWrapperClass.ActionWrapper objAction : lstActions) {
				objAction.strLabel = String.valueOf(objInnerRecord.Number_of_Entitlements_consumed__c + decActualUsage);
		
				//Now we get the Trend.
				if(objInnerRecord.Previous_Number_of_Entitlements_consumed__c != null && objInnerRecord.Number_of_Entitlements_consumed__c != null) {
					decActualTrend = decActualTrend + Double.valueOf(objInnerRecord.Number_of_Entitlements_consumed__c) - Double.valueOf(objInnerRecord.Previous_Number_of_Entitlements_consumed__c);
				} else {
					decActualTrend = decActualTrend + Double.valueOf(objInnerRecord.Number_of_Entitlements_consumed__c);
				}
				if(decActualTrend < 0) {
					objAction.strIcon = 'utility:arrowdown';
				} else if(decActualTrend > 0) {
					objAction.strIcon = 'utility:arrowup';
				}
				objAction.strHelpText = String.valueOf(decActualTrend);
			}
			mapRecordValues.put('Last Billing Cycle Usage', lstActions);
		}
	}
}