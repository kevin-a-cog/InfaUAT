/*
 * Name			:	CSMObjectivesAndMilestonesController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/6/2021
 * Description	:	Manage Risk Products controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/6/2021		N/A				Initial version.						N/A
 Deva M					26/11/2021		AR-1740			Initial version.						N/A
 Karthi 				27/07/2022		AR-2150			Added External Icon	for milestones		T1
 */
public without sharing class CSMObjectivesAndMilestonesController {

	//Public variables.
	public static String STR_DATETIME_FORMAT = 'MMM dd yyyy';

	/*
	 Method Name : getRecords
	 Description : This method returns the Risks and Issues records related to the provided Id.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRecordId) {
		Boolean boolIsCSMSuccessCommunity = isCSMSuccessCommunity();
		Integer intRemainingQueryRows;
		String strCleanRecordId;
		CSMObjectivesAndMilestonesWrapper objAdditionalInformation;
		CSMObjectivesAndMilestonesWrapper objRecord;
		CSMObjectivesAndMilestonesWrapper.ProductWrapper objProduct;
		CSMObjectivesAndMilestonesWrapper.ActionWrapper objAction;
		CSMObjectivesAndMilestonesWrapper.ActionWrapper objSubaction;
		CSMObjectivesAndMilestonesWrapper.IconWrapper objIcon;
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		Set<Id> setMilestones = new Set<Id>();
		Set<Id> setMilestoneRisks = new Set<Id>();
		List<Id> lstIds = new List<Id>();
		List<String> lstObjectiveFields = new List<String>();
		List<String> lstMilestoneFields = new List<String>();
		List<String> lstObjectiveProductFields = new List<String>();
		List<String> lstMilestoneProductFields = new List<String>();
		List<String> lstEngagementFields = new List<String>();
		List<String> lstTaskFields = new List<String>();
		List<Objective__c> lstObjectives;
		Map<String, Object> mapEngagementTaskRecord;
		Map<String, String> mapIcons = new Map<String, String>();
		Map<String, String> mapParentChildRelationship = new Map<String, String>();
		Map<Id, List<Map<String, Object>>> mapMilestoneChildRecords = new Map<Id, List<Map<String, Object>>>();

		//First we make sure we received an id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			objDataTable.lstRecordsCustomStructure = new List<Object>();
			objDataTable.lstRecords = new List<sObject>();
			objDataTable.boolRecordLocked = Approval.isLocked(strCleanRecordId);
			//We get the static resource icons.
			mapIcons.put('BusinessIcon', '');
			mapIcons.put('TechnicalIcon', '');
			mapIcons.put('KeyMilestone', '');
			mapIcons.put('Risk', '');
			mapIcons.put('SignedOff', '');
			mapIcons.put('DetailsOn', '');
			mapIcons.put('DetailsOff', '');
			mapIcons.put('ExternalIcon', ''); //T1
			for(StaticResource objStaticResource : [SELECT Name, SystemModStamp FROM StaticResource WHERE Name IN :mapIcons.keySet() LIMIT 1000]) {
				mapIcons.put(objStaticResource.Name, '/resource/' + objStaticResource.SystemModStamp.getTime() + '/' + objStaticResource.Name);
			}

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
			lstObjectiveFields.add('Is_Internal__c'); //T1

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
			lstMilestoneFields.add('Is_Internal__c'); //T1

			//We define the fields for Engagement.
			lstEngagementFields.addAll(getFieldSetList(SObjectType.Engagement__c.FieldSets.Objectives_Milestones_Engagements));

			//We define the fields for Tasks.
			lstTaskFields.addAll(getFieldSetList(SObjectType.Task.FieldSets.Objectives_Milestones_Tasks));

			//We define the fields for Objective Products.
			lstObjectiveProductFields.add('Plan_Product_Alias__r.Name__c');

			//We define the fields for Milestone Products.
			lstMilestoneProductFields.add('Milestone__c');
			lstMilestoneProductFields.add('Milestone__r.Name');//added for 2177
			lstMilestoneProductFields.add('Plan_Product_Alias__r.Name__c');

            String dynamicsoql;
            
            if(boolIsCSMSuccessCommunity){
                dynamicsoql = 'SELECT Id, ' + String.join(lstObjectiveFields, ',') + ', (SELECT Id, ' + String.join(lstMilestoneFields, ',') + 
					' FROM Milestones__r WHERE Is_Internal__c = false ORDER BY Planned_Completion_Date__c ASC), (SELECT ' + String.join(lstObjectiveProductFields, ',') + ' FROM ' + 
					'Objective_Products__r ORDER BY Plan_Product_Alias__r.Name__c ASC),Plan__r.CSM_isAutoPilot__c FROM Objective__c WHERE Is_Internal__c = false and Plan__c = :strCleanRecordId ORDER BY CSM_Planned_Completion_Date__c ASC LIMIT 1000';            
            } else {
                dynamicsoql = 'SELECT Id, ' + String.join(lstObjectiveFields, ',') + ', (SELECT Id, ' + String.join(lstMilestoneFields, ',') + 
					' FROM Milestones__r ORDER BY Planned_Completion_Date__c ASC), (SELECT ' + String.join(lstObjectiveProductFields, ',') + ' FROM ' + 
					'Objective_Products__r ORDER BY Plan_Product_Alias__r.Name__c ASC),Plan__r.CSM_isAutoPilot__c FROM Objective__c WHERE Plan__c = :strCleanRecordId ORDER BY CSM_Planned_Completion_Date__c ASC LIMIT 1000';            
            }
                
			//We query the objectives.
			lstObjectives = Database.query(dynamicsoql);
                
			//If we have records.
			if(lstObjectives != null && !lstObjectives.isEmpty()) {

				//We get all the Engagements and Tasks related to the Milestones.
				for(Objective__c objObjective : lstObjectives) {
					if(objObjective.Milestones__r != null && !objObjective.Milestones__r.isEmpty()) {
						for(Milestone__c objMilestone : objObjective.Milestones__r) {
							mapMilestoneChildRecords.put(objMilestone.Id, new List<Map<String, Object>>());

							//We save the Milestone Id, to query the Milestone Product later.
							setMilestones.add(objMilestone.Id);
						}
					}
				}
				if(!boolIsCSMSuccessCommunity && !mapMilestoneChildRecords.isEmpty()) {
					intRemainingQueryRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
					for(Engagement__c objEngagement : Database.query('SELECT Id, Milestone__c, ' + String.join(lstEngagementFields, ',') + ' FROM Engagement__c WHERE ' + 
							'Milestone__c IN :setMilestones WITH SECURITY_ENFORCED LIMIT :intRemainingQueryRows')) {

						//We create the mapping.
						mapEngagementTaskRecord = new Map<String, Object>();
						mapEngagementTaskRecord.put('Id', objEngagement.Id);
						mapEngagementTaskRecord.put('Name', objEngagement.Name);
						mapEngagementTaskRecord.put('CreatedDate', objEngagement.CreatedDate.format(STR_DATETIME_FORMAT));
						mapEngagementTaskRecord.put('LastModifiedDate', objEngagement.LastModifiedDate.format(STR_DATETIME_FORMAT));
						mapEngagementTaskRecord.put('LastModifiedDateFull', objEngagement.LastModifiedDate.getTime());
						mapEngagementTaskRecord.put('Status', objEngagement.Status__c);
						mapEngagementTaskRecord.put('DueDate', '');
						mapEngagementTaskRecord.put('Type', Engagement__c.getSObjectType().getDescribe().label);

						//We add the record to the list.
						mapMilestoneChildRecords.get(objEngagement.Milestone__c).add(mapEngagementTaskRecord);
					}
					intRemainingQueryRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
					for(Task objTask : Database.query('SELECT Id, WhatId, ' + String.join(lstTaskFields, ',') + ' FROM Task WHERE ' + 
							'WhatId IN :setMilestones WITH SECURITY_ENFORCED LIMIT :intRemainingQueryRows')) {

						//We create the mapping.
						mapEngagementTaskRecord = new Map<String, Object>();
						mapEngagementTaskRecord.put('Id', objTask.Id);
						mapEngagementTaskRecord.put('Name', objTask.Subject);
						mapEngagementTaskRecord.put('CreatedDate', objTask.CreatedDate.format(STR_DATETIME_FORMAT));
						mapEngagementTaskRecord.put('LastModifiedDate', objTask.LastModifiedDate.format(STR_DATETIME_FORMAT));
						mapEngagementTaskRecord.put('LastModifiedDateFull', objTask.LastModifiedDate.getTime());
						mapEngagementTaskRecord.put('Status', objTask.Status);
						if(objTask.ActivityDate != null) {
							mapEngagementTaskRecord.put('DueDate', Datetime.newInstance(objTask.ActivityDate.year(), objTask.ActivityDate.month(), 
									objTask.ActivityDate.day()).format(STR_DATETIME_FORMAT));
						} else {
							mapEngagementTaskRecord.put('DueDate', '');
						}
						mapEngagementTaskRecord.put('Type', Task.getSObjectType().getDescribe().label);

						//We add the record to the list.
						mapMilestoneChildRecords.get(objTask.WhatId).add(mapEngagementTaskRecord);
					}
				}

				//Now we prepare the response.
				for(Objective__c objObjective : Database.query(dynamicsoql)) {
					objDataTable.lstRecords.add(objObjective);

					//First we obtain the Objective records.
					objRecord = new CSMObjectivesAndMilestonesWrapper();
					objRecord.mapStyles = new Map<String, String>();
					objRecord.Id = objObjective.Id;
					objRecord.strName = objObjective.Name;
					objRecord.mapStyles.put('strName', 'font-size: 14px; min-width: 240px;');
					if(objObjective.CSM_Planned_Completion_Date__c != null) {
						objRecord.strPlannedCompletionDate = Datetime.newInstance(objObjective.CSM_Planned_Completion_Date__c.year(), objObjective.CSM_Planned_Completion_Date__c.month(), 
								objObjective.CSM_Planned_Completion_Date__c.day()).format(STR_DATETIME_FORMAT);
					}
					objRecord.datPlannedCompletionDate = objObjective.CSM_Planned_Completion_Date__c;
					objRecord.objStatus = new CSMObjectivesAndMilestonesWrapper.StatusWrapper();
					objRecord.objStatus.strValue = objObjective.Status__c;

					//We create the Products.
					objRecord.lstProducts = new List<CSMObjectivesAndMilestonesWrapper.ProductWrapper>();
					for(Objective_Product__c objObjectiveProduct : objObjective.Objective_Products__r) {
						if(objObjectiveProduct.Plan_Product_Alias__r != null) {
							objProduct = new CSMObjectivesAndMilestonesWrapper.ProductWrapper();
							objProduct.intAction = 6;
							objProduct.strValue = objObjectiveProduct.Plan_Product_Alias__r.Name__c;
							objRecord.lstProducts.add(objProduct);
						}
					}

					//Now we define the actions.
					objRecord.lstIcons = new List<CSMObjectivesAndMilestonesWrapper.IconWrapper>();
					objRecord.lstActions = new List<CSMObjectivesAndMilestonesWrapper.ActionWrapper>();
					if(objObjective.Sign_Off_Date__c != null) {
						objIcon = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
						objIcon.boolIsStaticResource = true;
						objIcon.intWidth = 20;
						objIcon.strURL = mapIcons.get('SignedOff');
						//added for 2177 - starts
						objIcon.strTitle ='Objective Signed off';
						//added for 2177 - ends
						objRecord.lstIcons.add(objIcon);
					}

					// <T1>
					// Prepare the E icon for external milestones
					if(!objObjective.Is_Internal__c && !boolIsCSMSuccessCommunity) {
						objIcon = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
						objIcon.boolIsStaticResource = true;
						objIcon.intWidth = 20;
						objIcon.strURL = mapIcons.get('ExternalIcon');
						//added for 2177 - starts
						objIcon.strTitle ='External';
						//added for 2177 - ends
						objRecord.lstIcons.add(objIcon);
					}
					// </T1>

					objAction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
					objAction.intAction = 1;
					objAction.boolIsStaticResource = true;
					objAction.intWidth = 20;
					objAction.strURL = mapIcons.get('DetailsOn');
					objAction.strInverseURL = mapIcons.get('DetailsOff');
					objRecord.lstActions.add(objAction);

					//Deva M added if check to hide actions for the autopilot flow and  readonly users
					if(!Approval.isLocked(strCleanRecordId) && CSMUtilities.hasCSMPermisson(objObjective.Plan__r.CSM_isAutoPilot__c)){
						objAction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
						objAction.strIcon = 'utility:threedots_vertical';
						objAction.lstSubactions = new List<CSMObjectivesAndMilestonesWrapper.ActionWrapper>();
						objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
						objSubaction.intAction = 2;
						objSubaction.strLabel = 'Edit Objective';
						objAction.lstSubactions.add(objSubaction);
						//Deva M added -  check and hide delete button for CSM and CSM Manager
						if(CSMUtilities.hasCSMPermisson(false) && !boolIsCSMSuccessCommunity){
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 3;
							objSubaction.strLabel = 'Delete Objective';
							objAction.lstSubactions.add(objSubaction);
						}
						if(!boolIsCSMSuccessCommunity) {
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 4;
							objSubaction.strLabel = 'Apply Template';
							objAction.lstSubactions.add(objSubaction);
						
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 5;
							objSubaction.strLabel = 'Add Milestone';
							objAction.lstSubactions.add(objSubaction);
						}
						objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
						objSubaction.intAction = 6;
						objSubaction.strLabel = 'Manage Objective Products';
						objAction.lstSubactions.add(objSubaction);
						if(!boolIsCSMSuccessCommunity) {
							objRecord.lstActions.add(objAction);
						}
					}

					//Now we prepare the Objective Details record.
					objAdditionalInformation = new CSMObjectivesAndMilestonesWrapper();
					objAdditionalInformation.boolHasValidId = false;
					objAdditionalInformation.boolCustomLayout = true;
					objAdditionalInformation.intRecordLayoutType = 1;
					objAdditionalInformation.intColumnsConfiguration = 1;
					objAdditionalInformation.intMapLabelContentPairsNumberOfColumns = 2;
					objAdditionalInformation.mapLabelContentPairs = new Map<String, String>();
					objAdditionalInformation.mapLabelContentPairs.put('Business Goal', objObjective.Business_Goal__c);
					objAdditionalInformation.mapLabelContentPairs.put('Technical Goal', objObjective.Technical_Goal__c);
					if(objObjective.Sign_Off_Date__c != null && objObjective.Customer_Sign_off_Contact__r != null && objObjective.Customer_Sign_off_Contact__r.Name != null) {
						objAdditionalInformation.mapLabelContentPairs.put('Signed off by', objObjective.Customer_Sign_off_Contact__r.Name);
						objAdditionalInformation.mapLabelContentPairs.put('Signed off date', Datetime.newInstance(objObjective.Sign_Off_Date__c.year(), 
								objObjective.Sign_Off_Date__c.month(), objObjective.Sign_Off_Date__c.day()).format(STR_DATETIME_FORMAT));
					}
					objAdditionalInformation.mapLabelContentPairs.put('Target KPI', objObjective.Target_KPI__c);
					objAdditionalInformation.mapLabelContentPairs.put('Actual KPI', objObjective.Actual_KPI__c);
					objAdditionalInformation.mapLabelContentPairs.put('Created By', objObjective.CreatedBy.Name + ' - ' + objObjective.CreatedDate.format(STR_DATETIME_FORMAT));
					objAdditionalInformation.mapLabelContentPairs.put('Last Modified By', objObjective.LastModifiedBy.Name + ' - ' + objObjective.LastModifiedDate.format(STR_DATETIME_FORMAT));

					//Now we include the additional information to the record.
					objRecord.objAdditionalInformation = objAdditionalInformation;

					//We add the objective.
					objDataTable.lstRecordsCustomStructure.add(objRecord);

					//Now we save the Goals.
					for(Milestone__c objMilestone : objObjective.Milestones__r) {

						//We prepare the business icon / technical icon.
						objIcon = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
						objIcon.boolIsStaticResource = true;
						objIcon.intWidth = 20;

						//First we obtain the Objective records.
						objRecord = new CSMObjectivesAndMilestonesWrapper();
						objRecord.mapStyles = new Map<String, String>();
						objRecord.mapStyles.put('strName', 'font-size: 14px; min-width: 240px;');
						objRecord.lstIcons = new List<CSMObjectivesAndMilestonesWrapper.IconWrapper>();
						objRecord.lstProducts = new List<CSMObjectivesAndMilestonesWrapper.ProductWrapper>();
						objRecord.Id = objMilestone.Id;
						objRecord.strName = objMilestone.Name;
						if(objMilestone.Milestone_Type__c == 'Business Milestone') {
							objIcon.strURL = mapIcons.get('BusinessIcon');
							//added for 2177 - starts
							objIcon.strTitle ='Business Milestone';
							//added for 2177 - ends
							objRecord.lstIcons.add(objIcon);
						} else if(objMilestone.Milestone_Type__c == 'Technical Milestone') {
							objIcon.strURL = mapIcons.get('TechnicalIcon');
							//added for 2177 - starts
							objIcon.strTitle ='Technical Milestone';
							//added for 2177 - ends
							objRecord.lstIcons.add(objIcon);
						}
						// <T1>
						// Prepare the E icon for external milestones
						if(!objMilestone.Is_Internal__c && !boolIsCSMSuccessCommunity) {
							objIcon = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
							objIcon.boolIsStaticResource = true;
							objIcon.intWidth = 20;
							objIcon.strURL = mapIcons.get('ExternalIcon');
							//added for 2177 - starts
							objIcon.strTitle ='External';
							//added for 2177 - ends
							objRecord.lstIcons.add(objIcon);
						}
						// </T1>

						objRecord.strType = objMilestone.Milestone_Type__c;
						if(objMilestone.Planned_Completion_Date__c != null) {
							objRecord.strPlannedCompletionDate = Datetime.newInstance(objMilestone.Planned_Completion_Date__c.year(), objMilestone.Planned_Completion_Date__c.month(), 
									objMilestone.Planned_Completion_Date__c.day()).format(STR_DATETIME_FORMAT);
						}
						objRecord.datPlannedCompletionDate = objMilestone.Planned_Completion_Date__c;
						objRecord.objStatus = new CSMObjectivesAndMilestonesWrapper.StatusWrapper();
						objRecord.objStatus.strValue = objMilestone.Status__c;

						//Now we define the actions.
						objRecord.lstActions = new List<CSMObjectivesAndMilestonesWrapper.ActionWrapper>();
						if(objMilestone.Key_Milestone__c != null && objMilestone.Key_Milestone__c) {
							objIcon = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
							objIcon.boolIsStaticResource = true;
							objIcon.intWidth = 20;
							objIcon.strURL = mapIcons.get('KeyMilestone');
							//added for 2177 - starts
							objIcon.strTitle ='Key Milestone';
							//added for 2177 - ends
							objRecord.lstIcons.add(objIcon);
						}
						objAction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
						objAction.intAction = 1;
						objAction.boolIsStaticResource = true;
						objAction.intWidth = 20;
						objAction.strURL = mapIcons.get('DetailsOn');
						objAction.strInverseURL = mapIcons.get('DetailsOff');
						objRecord.lstActions.add(objAction);

						//Deva M added if check to hide actions for the autopilot flow and  readonly users
						if(!Approval.isLocked(strCleanRecordId)  && CSMUtilities.hasCSMPermisson(objObjective.Plan__r.CSM_isAutoPilot__c)){
							objAction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objAction.strIcon = 'utility:threedots_vertical';
							objAction.lstSubactions = new List<CSMObjectivesAndMilestonesWrapper.ActionWrapper>();
							//Deva M added -  check and hide delete button for CSM and CSM Manager
							if(!boolIsCSMSuccessCommunity){
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 7;
							objSubaction.strLabel = 'Edit Milestone';
							objAction.lstSubactions.add(objSubaction);

								
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 8;
							objSubaction.strLabel = 'Delete Milestone';
							objAction.lstSubactions.add(objSubaction);
								}
								if(!boolIsCSMSuccessCommunity) {
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 4;
							objSubaction.strLabel = 'Apply Template';
							objAction.lstSubactions.add(objSubaction);
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 9;
							objSubaction.strLabel = 'Manage Milestone Products';
							objAction.lstSubactions.add(objSubaction);
									/*objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
									objSubaction.intAction = 10;
									objSubaction.strLabel = 'Create Risk';
									objAction.lstSubactions.add(objSubaction);*/
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 11;
							objSubaction.strLabel = 'Create Task';
							objAction.lstSubactions.add(objSubaction);
							objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
							objSubaction.intAction = 12;
							objSubaction.strLabel = 'Create Engagement';
							objAction.lstSubactions.add(objSubaction);
								}
							if(!boolIsCSMSuccessCommunity) {
								objRecord.lstActions.add(objAction);
							}
							else if(objMilestone.Status__c =='Yet to Start' || objMilestone.Status__c =='In Progress'){
								objSubaction = new CSMObjectivesAndMilestonesWrapper.ActionWrapper();
								objSubaction.intAction = 13;
								objSubaction.strLabel = Label.EC_Success_ButtonLabel;
								objAction.lstSubactions.add(objSubaction);
								objRecord.lstActions.add(objAction);
							}
						}

						//Now we save the additional information.
						objAdditionalInformation = new CSMObjectivesAndMilestonesWrapper();
						objAdditionalInformation.boolHasValidId = false;
						objAdditionalInformation.boolCustomLayout = true;
						objAdditionalInformation.intRecordLayoutType = 1;
						objAdditionalInformation.intColumnsConfiguration = 2;
						objAdditionalInformation.intMapLabelContentPairsNumberOfColumns = 2;
						objAdditionalInformation.mapLabelContentPairs = new Map<String, Object>();
						objAdditionalInformation.mapLabelContentPairs.put('Description', new CSMObjectivesAndMilestonesWrapper.CellWrapper(objMilestone.Description__c));
						if(objMilestone.Actual_Completion_Date__c != null) {
							objAdditionalInformation.mapLabelContentPairs.put('Actual Completion Date', Datetime.newInstance(objMilestone.Actual_Completion_Date__c.year(), 
									objMilestone.Actual_Completion_Date__c.month(), objMilestone.Actual_Completion_Date__c.day()).format(STR_DATETIME_FORMAT));
						}
						objAdditionalInformation.mapLabelContentPairs.put('Created By', new CSMObjectivesAndMilestonesWrapper.CellWrapper(objMilestone.CreatedBy.Name + ' - ' + objMilestone.CreatedDate.format(STR_DATETIME_FORMAT)));
						objAdditionalInformation.mapLabelContentPairs.put('Last Modified By', objMilestone.LastModifiedBy.Name + ' - ' + objMilestone.LastModifiedDate.format(STR_DATETIME_FORMAT));

						//We add possible child records of the milestone.
						objAdditionalInformation.lstChildRecordsCustomStructure = mapMilestoneChildRecords.get(objRecord.Id);

						//We add the milestone.
						objRecord.objAdditionalInformation = objAdditionalInformation;
						objDataTable.lstRecordsCustomStructure.add(objRecord);

						//We also save the parent-child relationships.
						mapParentChildRelationship.put(objMilestone.Id, objObjective.Id);
					}
				}
			}

			//We set the parent-child final mapping.
			objDataTable.mapParentChildRelationship = mapParentChildRelationship;

			//We also include the Milestone Products and Risks.
			if(!setMilestones.isEmpty()) {

				//First we check the Products.
				for(Milestone_Product__c objMilestoneProduct : Database.query('SELECT Id, ' + String.join(lstMilestoneProductFields, ',') + 
						' FROM Milestone_Product__c WHERE Milestone__c IN :setMilestones ORDER BY Plan_Product_Alias__r.Name__c ASC LIMIT 1000 ')) {
					for(Object objCustomRecord : objDataTable.lstRecordsCustomStructure) {
						objRecord = (CSMObjectivesAndMilestonesWrapper) objCustomRecord;
						if((objRecord.boolHasValidId == null || objRecord.boolHasValidId) && objRecord.Id == objMilestoneProduct.Milestone__c && objMilestoneProduct.Plan_Product_Alias__r != null) {
							
							//Now we save the Product.
							objProduct = new CSMObjectivesAndMilestonesWrapper.ProductWrapper();
							objProduct.intAction = 9;
							objProduct.strValue = objMilestoneProduct.Plan_Product_Alias__r.Name__c;
							objRecord.lstProducts.add(objProduct);
						}
					}
				}

				//Now we check the Risks.
				for(Risk_Issue__c objRisk : Database.query('SELECT Id, Milestone__c FROM Risk_Issue__c WHERE Milestone__c IN :setMilestones LIMIT 1000')) {
					for(Object objCustomRecord : objDataTable.lstRecordsCustomStructure) {
						objRecord = (CSMObjectivesAndMilestonesWrapper) objCustomRecord;
						if((objRecord.boolHasValidId == null || objRecord.boolHasValidId) && objRecord.Id == objRisk.Milestone__c) {
							setMilestoneRisks.add(objRecord.Id);
						}
					}
				}
				for(String strMilestoneId : setMilestoneRisks) {
					for(Object objCustomRecord : objDataTable.lstRecordsCustomStructure) {
						objRecord = (CSMObjectivesAndMilestonesWrapper) objCustomRecord;
						if(!boolIsCSMSuccessCommunity && ((objRecord.boolHasValidId == null || objRecord.boolHasValidId) && objRecord.Id == strMilestoneId)) {
							objIcon = new CSMObjectivesAndMilestonesWrapper.IconWrapper();
							objIcon.boolIsStaticResource = true;
							objIcon.intWidth = 20;
							objIcon.strURL = mapIcons.get('Risk');
							//added for 2177 - starts
							objIcon.strTitle ='Risk Associated';
							//added for 2177 - ends
							objRecord.lstIcons.add(objIcon);
						}
					}
				}
			}
		}
		return objDataTable;
	}

	/*
	 Method Name : isInternalUser
	 Description : This method returns TRUE if the current user is internal.
	 Parameters	 : None
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static Boolean isInternalUser() {
		Boolean boolIsInternalUser = true;
		if(UserInfo.getUserType() != 'Standard' || Test.isRunningTest()) {
			boolIsInternalUser = false;
		}
		return boolIsInternalUser;
	}

	/*
	 Method Name : isCSMSuccessCommunity
	 Description : This method returns TRUE if the current community is CSM Success.
	 Parameters	 : None
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static Boolean isCSMSuccessCommunity() {
		Boolean boolIsCSMSuccessComunity = false;
		for(Site objSite : [SELECT Id FROM Site WHERE Id = :Site.getSiteId() AND (UrlPathPrefix = 'success' OR UrlPathPrefix = 'success/s') LIMIT 1]) {
			boolIsCSMSuccessComunity = true;
		}
		return boolIsCSMSuccessComunity;
	}

	/*
	 Method Name : hasMilestoneRecordsRelated
	 Description : This method returns TRUE if the given record id (milestone) is related to IPU Consumption Goal records.
	 Parameters	 : Id, called from hasMilestoneRecordsRelated, idRecord Milestone Id.
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static Boolean hasMilestoneRecordsRelated(Id idRecord) {
		Boolean boolResult = false;
		for(Milestone__c objRecord : [SELECT Id FROM Milestone__c WHERE Id = :idRecord LIMIT 1]) {
			for(Engagement__c objInnerRecord : [SELECT Id FROM Engagement__c WHERE Milestone__c = :objRecord.Id LIMIT 1]) {
				boolResult = true;
			}
			if(!boolResult) {
				for(Risk_Issue__c objInnerRecord : [SELECT Id FROM Risk_Issue__c WHERE Milestone__c = :objRecord.Id AND Risk_Stage__c IN ('Open', 'Planning', 'Under Mitigation') LIMIT 1]) {
					boolResult = true;
				}
			}
		}
		return boolResult;
	}

	/*
	 Method Name : getFieldSetList
	 Description : This method returns a list of strings of the fields contained in the given FieldSet.
	 Parameters	 : Schema.FieldSet, called from getFieldSetList, objFieldSet FieldSet.
	 Return Type : List
	 */
    public static List<String> getFieldSetList(Schema.FieldSet objFieldSet) {
		List<String> lstFieldAPINames = new List<String>();
		if(objFieldSet != null) {
			for(Schema.FieldSetMember objFieldSetMember : objFieldSet.getFields()) {
				lstFieldAPINames.add(objFieldSetMember.getFieldPath());
			}
		}
		return lstFieldAPINames;
	}
}