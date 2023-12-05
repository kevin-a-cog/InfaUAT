/*
 * Name         :   PlanProductTriggerHelper
 * Author       :   Monserrat Pedroza
 * Created Date :   1/17/2022
 * Description  :   Trigger helper for Plan Product trigger handler.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 			Tag
 **********************************************************************************************************
 Monserrat Pedroza      1/17/2022        N/A             Initial version.            			N/A
 Narpavi Prabu         09/22/2022      AR-2933       Query only Active TPL for PPA creation   	T01
 Narpavi Prabu         02/10/2023      AR-3072       Fix the issue for plan product name is not  T02
 													  updated in Creation T02
 */
public without sharing class PlanProductTriggerHelper implements Queueable {

	//Public variables.
	public String strQueueableRequest;
	
    /*
	 Method Name : createPlanProductAliasRecords
	 Description : This method generates the Alias records for the given Plan Products.
	 Parameters	 : List, called from createPlanProductAliasRecords, lstPlanProductRecords Plan Product records.
	 Return Type : None
	 */
	public static void createPlanProductAliasRecords(List<Related_Account_Plan__c> lstPlanProductRecords) {
		createPlanProductAliasRecords(lstPlanProductRecords, null);
	}
	
    /*
	 Method Name : createPlanProductAliasRecords
	 Description : This method generates the Alias records for the given Plan Products.
	 Parameters	 : List, called from createPlanProductAliasRecords, lstPlanProductRecords Plan Product records.
	 			   Map, called from createPlanProductAliasRecords, mapOldPlanProductRecords Plan Product records before the update.
	 Return Type : None
	 */
	public static void createPlanProductAliasRecords(List<Related_Account_Plan__c> lstPlanProductRecords, Map<Id, Related_Account_Plan__c> mapOldPlanProductRecords) {
		Boolean boolShouldProceed;
		Boolean boolHasTechnicalProductLine;
		Plan_Product_Alias__c objTemporaryNewAliasRecord;
		PlanProductTriggerHelper objQueueableController;
		List<String> lstDeliveryMethods = new List<String>();
		List<String> lstForecastProducts = new List<String>();
		List<Id> lstPlans = new List<Id>();
		List<Plan_Product_Alias__c> lstExistingAliasRecords;
		List<Technical_Product_Line__c> lstTechnicalProductLines;
		List<Plan_Product_Alias__c> lstNewAliasRecords = new List<Plan_Product_Alias__c>();
		List<Plan_Product_Alias__c> lstTemporaryNewAliasRecords = new List<Plan_Product_Alias__c>();
		List<Related_Account_Plan__c> lstPlanProductRecordsToBeAnalyzed = new List<Related_Account_Plan__c>();
		Map<Id, Id> mapLookupRelationships = new Map<Id, Id>();

		//First we make sure we received data.
		if(lstPlanProductRecords != null && !lstPlanProductRecords.isEmpty()) {

			//Now we extract what we need to analyze.
			if(mapOldPlanProductRecords == null) {
				lstPlanProductRecordsToBeAnalyzed.addAll(lstPlanProductRecords);
				for(Related_Account_Plan__c objPlanProductRecord : lstPlanProductRecords) {
					if(objPlanProductRecord.Account_Plan__c != null) {
						lstPlanProductRecordsToBeAnalyzed.add(objPlanProductRecord);
					}
				}
			} else {
				for(Related_Account_Plan__c objPlanProductRecord : lstPlanProductRecords) {
					if(objPlanProductRecord.Account_Plan__c != null && objPlanProductRecord.Account_Plan__c != mapOldPlanProductRecords.get(objPlanProductRecord.Id).Account_Plan__c) {
						lstPlanProductRecordsToBeAnalyzed.add(objPlanProductRecord);
					}
				}
			}

			//Now we collect the conditions needed for the Technical Product Lines.
			for(Related_Account_Plan__c objPlanProductRecord : lstPlanProductRecordsToBeAnalyzed) {
				if(String.isNotBlank(objPlanProductRecord.Delivery_Method__c)) {
					lstDeliveryMethods.add('\'' + objPlanProductRecord.Delivery_Method__c + '\'');
				}
				if(String.isNotBlank(objPlanProductRecord.Forecast_Product__c)) {
					lstForecastProducts.add('\'' + objPlanProductRecord.Forecast_Product__c + '\'');
				}

				//We also collect the plans, to check the existing records.
				lstPlans.add(objPlanProductRecord.Account_Plan__c);
			}

			//Now we query any existing Alias records.
			lstExistingAliasRecords = [SELECT Id, Forecast_Product__c, Technical_Product_Line__c, Plan__c FROM Plan_Product_Alias__c WHERE Plan__c IN :lstPlans LIMIT 10000];
			if(lstExistingAliasRecords == null || lstExistingAliasRecords.isEmpty()) {
				lstExistingAliasRecords = new List<Plan_Product_Alias__c>();
			}

			//<T01> - Updated to query to get only Active TPL for PPA creation
			//Now, if we have values to look for in Technical Product Line, we execute the query.
			if(!lstDeliveryMethods.isEmpty() && !lstForecastProducts.isEmpty()) {
				String tplstatus ='Active';
				lstTechnicalProductLines = Database.query('SELECT Id, Delivery_Method__c, Forecast_Product__c,Status__c, Alias__c FROM Technical_Product_Line__c where Status__c =:tplstatus LIMIT 10000');

				//Now we check which Technical Product Lines are related to the given Plan Product Records.
				for(Related_Account_Plan__c objPlanProductRecord : lstPlanProductRecordsToBeAnalyzed) {
					boolHasTechnicalProductLine = false;
					if(lstTechnicalProductLines != null) {

						//First we look for L3 matches.
						for(Technical_Product_Line__c objTechnicalProductLine : lstTechnicalProductLines) {
							if(String.isNotBlank(objTechnicalProductLine.Delivery_Method__c) && String.isNotBlank(objTechnicalProductLine.Alias__c) && 
									objTechnicalProductLine.Delivery_Method__c.split(';').contains(objPlanProductRecord.Delivery_Method__c) && 
									objTechnicalProductLine.Alias__c.split(';').contains(objPlanProductRecord.Forecast_Product__c)) {
								boolHasTechnicalProductLine = true;
								objTemporaryNewAliasRecord = new Plan_Product_Alias__c();
								objTemporaryNewAliasRecord.Plan__c = objPlanProductRecord.Account_Plan__c;
								objTemporaryNewAliasRecord.Technical_Product_Line__c = objTechnicalProductLine.Id;
								lstTemporaryNewAliasRecords.add(objTemporaryNewAliasRecord);
								break;
							}
						}

						//If not found, we look for Forecast Product matches.
						if(!boolHasTechnicalProductLine) {
						for(Technical_Product_Line__c objTechnicalProductLine : lstTechnicalProductLines) {
							if(String.isNotBlank(objTechnicalProductLine.Delivery_Method__c) && String.isNotBlank(objTechnicalProductLine.Forecast_Product__c) && 
									objTechnicalProductLine.Delivery_Method__c.split(';').contains(objPlanProductRecord.Delivery_Method__c) && 
									objTechnicalProductLine.Forecast_Product__c.split(';').contains(objPlanProductRecord.Forecast_Product__c)) {
								boolHasTechnicalProductLine = true;
								objTemporaryNewAliasRecord = new Plan_Product_Alias__c();
								objTemporaryNewAliasRecord.Plan__c = objPlanProductRecord.Account_Plan__c;
								objTemporaryNewAliasRecord.Technical_Product_Line__c = objTechnicalProductLine.Id;
								lstTemporaryNewAliasRecords.add(objTemporaryNewAliasRecord);
								break;
							}
						}
					}
					}
					
					//If there's no Technical Product Line, we just check if there's no existng alias, so we create it directly based on the Plan Product.
					if(!boolHasTechnicalProductLine) {
						objTemporaryNewAliasRecord = new Plan_Product_Alias__c();
						objTemporaryNewAliasRecord.Plan__c = objPlanProductRecord.Account_Plan__c;
						objTemporaryNewAliasRecord.Forecast_Product__c = objPlanProductRecord.Forecast_Product__c;
						lstTemporaryNewAliasRecords.add(objTemporaryNewAliasRecord);
					}
				}

				//Now we create the new alias records, if any.	
				if(!lstTemporaryNewAliasRecords.isEmpty()) {
							
					//Now we confirm this combination is not already related to this plan.
					for(Plan_Product_Alias__c objTemporaryNewAliasRecordToBeAnalyzed : lstTemporaryNewAliasRecords) {
						boolShouldProceed = true;
						for(Plan_Product_Alias__c objExistingAliasRecord : lstExistingAliasRecords) {
							if(objExistingAliasRecord.Plan__c == objTemporaryNewAliasRecordToBeAnalyzed.Plan__c && 
									objExistingAliasRecord.Forecast_Product__c == objTemporaryNewAliasRecordToBeAnalyzed.Forecast_Product__c &&
									objExistingAliasRecord.Technical_Product_Line__c == objTemporaryNewAliasRecordToBeAnalyzed.Technical_Product_Line__c) {
								boolShouldProceed = false;
							}
						}

						//If the new record doesn't exist in the Data Base, we make sure we only insert one of its kind.
						if(boolShouldProceed) {
							for(Plan_Product_Alias__c objNewAliasRecord : lstNewAliasRecords) {
								if(objNewAliasRecord.Plan__c == objTemporaryNewAliasRecordToBeAnalyzed.Plan__c && 
										objNewAliasRecord.Forecast_Product__c == objTemporaryNewAliasRecordToBeAnalyzed.Forecast_Product__c &&
										objNewAliasRecord.Technical_Product_Line__c == objTemporaryNewAliasRecordToBeAnalyzed.Technical_Product_Line__c) {
									boolShouldProceed = false;
								}
							}

							//If no duplicates, we add it to the final list, for insertion.
							if(boolShouldProceed) {
								lstNewAliasRecords.add(objTemporaryNewAliasRecordToBeAnalyzed);
							}
						}
					}
					
					//If we have new records to insert.
					if(!lstNewAliasRecords.isEmpty()) {
						Database.insert(lstNewAliasRecords, false);
					}

					//Now we include the previously existing records in the list, in case we need to update a Plan Product record with a previously existing Alias record.
					lstNewAliasRecords.addAll(lstExistingAliasRecords);

					//Now we update back the Plan Products, so we know to which Alias they are tied to.
					for(Related_Account_Plan__c objPlanProductRecord : lstPlanProductRecordsToBeAnalyzed) {
						boolHasTechnicalProductLine = false;
						if(lstTechnicalProductLines != null) {

							//First we look for L3 matches.
							for(Technical_Product_Line__c objTechnicalProductLine : lstTechnicalProductLines) {
								if(String.isNotBlank(objTechnicalProductLine.Delivery_Method__c) && String.isNotBlank(objTechnicalProductLine.Alias__c) && 
										objTechnicalProductLine.Delivery_Method__c.split(';').contains(objPlanProductRecord.Delivery_Method__c) && 
										objTechnicalProductLine.Alias__c.split(';').contains(objPlanProductRecord.Forecast_Product__c)) {
									boolHasTechnicalProductLine = true;
									for(Plan_Product_Alias__c objNewAliasRecord : lstNewAliasRecords) {
										if(objNewAliasRecord.Plan__c == objPlanProductRecord.Account_Plan__c && objNewAliasRecord.Technical_Product_Line__c == objTechnicalProductLine.Id &&
												objNewAliasRecord.Id != null) {
											mapLookupRelationships.put(objPlanProductRecord.Id, objNewAliasRecord.Id);
											break;
										}
									}
									break;
								}
							}

							//If not found, we look for Forecast Product matches.
							if(!boolHasTechnicalProductLine) {
							for(Technical_Product_Line__c objTechnicalProductLine : lstTechnicalProductLines) {
								if(String.isNotBlank(objTechnicalProductLine.Delivery_Method__c) && String.isNotBlank(objTechnicalProductLine.Forecast_Product__c) && 
										objTechnicalProductLine.Delivery_Method__c.split(';').contains(objPlanProductRecord.Delivery_Method__c) && 
										objTechnicalProductLine.Forecast_Product__c.split(';').contains(objPlanProductRecord.Forecast_Product__c)) {
									boolHasTechnicalProductLine = true;
									for(Plan_Product_Alias__c objNewAliasRecord : lstNewAliasRecords) {
										if(objNewAliasRecord.Plan__c == objPlanProductRecord.Account_Plan__c && objNewAliasRecord.Technical_Product_Line__c == objTechnicalProductLine.Id &&
												objNewAliasRecord.Id != null) {
											mapLookupRelationships.put(objPlanProductRecord.Id, objNewAliasRecord.Id);
											break;
										}
									}
									break;
								}
							}
						}
						}
						
						//If there's no Technical Product Line, we just check if there's no existng alias, so we create it directly based on the Plan Product.
						if(!boolHasTechnicalProductLine) {
							for(Plan_Product_Alias__c objNewAliasRecord : lstNewAliasRecords) {
								if(objNewAliasRecord.Plan__c == objPlanProductRecord.Account_Plan__c && objNewAliasRecord.Forecast_Product__c == objPlanProductRecord.Forecast_Product__c && 
										objNewAliasRecord.Id != null) {
									mapLookupRelationships.put(objPlanProductRecord.Id, objNewAliasRecord.Id);
									break;
								}
							}
						}
					}

					//Finally we update the Plan Product records, making reference to the Alias records, in a queueable process.
					if(!mapLookupRelationships.isEmpty()) {
						objQueueableController = new PlanProductTriggerHelper();
						objQueueableController.strQueueableRequest = JSON.serialize(mapLookupRelationships);

						//Now we clean up the data in a queue, only if we are not already in a queue.
						if(!System.isBatch() && !System.isQueueable()) {
							System.enqueueJob(objQueueableController);
						} else {
							updatePlanProductLookupAlias(objQueueableController.strQueueableRequest);
						}
					}
					}
				}
			}
		}

	/*
	 Method Name : execute
	 Description : This method starts the queueable process.
	 Parameters	 : Object, called from execute, objContext Queueable context.
	 Return Type : None
	 */
    public void execute(QueueableContext objContext) {
		updatePlanProductLookupAlias(strQueueableRequest);
	}
	
    /*
	 Method Name : updatePlanProductLookupAlias
	 Description : This method updates the given Plan Product Ids with their corresponding Alias record id.
	 Parameters	 : String, called from updatePlanProductLookupAlias, strJSONMap Serialized map that contains the Plan Product Ids and their Alias record id.
	 Return Type : None
	 */
	public static void updatePlanProductLookupAlias(String strJSONMap) {
		Related_Account_Plan__c objPlanProductRecord;
		List<Id> lstPlanIds = new List<Id>();
		List<Related_Account_Plan__c> lstPlanProductRecords = new List<Related_Account_Plan__c>();
		Map<Id, String> mapPlanProductAliasNames = new Map<Id, String>();
		Map<Id, Id> mapLookupRelationships = (Map<Id, Id>) JSON.deserialize(strJSONMap, Map<Id, Id>.class);

		//First we get the Plan Product Alias names and ids.
		for(Plan_Product_Alias__c objPlanProductAliasNewRecord : [SELECT Id, Plan__c, Name__c FROM Plan_Product_Alias__c WHERE Id IN :mapLookupRelationships.values() AND Plan__c <> NULL LIMIT 10000]) {
			lstPlanIds.add(objPlanProductAliasNewRecord.Plan__c);
			mapPlanProductAliasNames.put(objPlanProductAliasNewRecord.Id, objPlanProductAliasNewRecord.Name__c);
		}

		//Now we update the Plan Product records with their corresponding Alias.
		for(Id idPlanProduct : mapLookupRelationships.keySet()) {
			objPlanProductRecord = new Related_Account_Plan__c();
			objPlanProductRecord.Id = idPlanProduct;
			objPlanProductRecord.Plan_Product_Alias__c = mapLookupRelationships.get(idPlanProduct);
			//<T02>
			//objPlanProductRecord.Product_Name__c = mapPlanProductAliasNames.get(objPlanProductRecord.Plan_Product_Alias__c);
			//</T02>
			lstPlanProductRecords.add(objPlanProductRecord);
		}
		Database.update(lstPlanProductRecords, false);

		//Now we clean up any orphan alias records.
		cleanUpAliasRecords(lstPlanIds);
	}
	
    /*
	 Method Name : cleanUpAliasRecords
	 Description : This method deletes the Alias records that are not tied to any Plan Product.
	 Parameters	 : List, called from cleanUpAliasRecords, lstPlanProductRecords Plan Product records.
	 Return Type : None
	 */
	public static void cleanUpAliasRecords(List<Related_Account_Plan__c> lstPlanProductRecords) {
		List<Id> lstPlanIds = new List<Id>();

		//First, we make sure we received data.
		if(lstPlanProductRecords != null && !lstPlanProductRecords.isEmpty()) {
			for(Related_Account_Plan__c objPlanProductRecord : lstPlanProductRecords) {
				if(objPlanProductRecord.Account_Plan__c != null) {
					lstPlanIds.add(objPlanProductRecord.Account_Plan__c);
				}
			}

			//If we have Plan records to analyze, we start the clean up process.
			if(!lstPlanIds.isEmpty()) {
				cleanUpAliasRecords(lstPlanIds);
			}
		}
	}
	
    /*
	 Method Name : cleanUpAliasRecords
	 Description : This method deletes the Alias records that are not tied to any Plan Product.
	 Parameters	 : List, called from cleanUpAliasRecords, lstNewPlanProductAliasRecords Plan Product Alias records.
	 Return Type : None
	 */
	public static void cleanUpAliasRecords(List<Id> lstPlanIds) {
		List<Plan_Product_Alias__c> lstPlanProductAliasRecordsToBeDeleted = new List<Plan_Product_Alias__c>();
		
		//First, we make sure we received data.
		if(lstPlanIds != null && !lstPlanIds.isEmpty()) {
			for(Plan_Product_Alias__c objPlanProductAliasNewRecord : [SELECT Id, (SELECT Id FROM Plan_Products__r LIMIT 10000) FROM Plan_Product_Alias__c WHERE Plan__c IN :lstPlanIds LIMIT 10000]) {
				if(objPlanProductAliasNewRecord.Plan_Products__r == null || objPlanProductAliasNewRecord.Plan_Products__r.isEmpty()) {
					lstPlanProductAliasRecordsToBeDeleted.add(objPlanProductAliasNewRecord);
				}
			}

			//Finally, we delete the orphan records, if any.
			if(!lstPlanProductAliasRecordsToBeDeleted.isEmpty()) {
				Database.delete(lstPlanProductAliasRecordsToBeDeleted, false);
			}
		}
	}
}