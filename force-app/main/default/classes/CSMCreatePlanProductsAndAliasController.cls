/*
 * Name			:	CSMCreatePlanProductsAndAliasController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/24/2022
 * Description	:	Controller class for Create Plan Products and Alias feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/24/2022		N/A				Initial version.			N/A
 */
public with sharing class CSMCreatePlanProductsAndAliasController implements Database.Batchable<sObject>, Database.Stateful {

	//Private variables.
	private Id idRecord;
	private Map<String, Subscription_Line__c> mapForecastProductDeliveryMethodCombinations = new Map<String, Subscription_Line__c>();

	/*
	 Method Name : CSMCreatePlanProductsAndAliasController
	 Description : Constructor of the class.
	 Parameters	 : Id, called from CSMCreatePlanProductsAndAliasController, idRecord Technical Product Line id.
	 Return Type : Object.
	 */
	public CSMCreatePlanProductsAndAliasController(Id idRecord) {
		this.idRecord = idRecord;
	}
	
	/*
	 Method Name : start
	 Description : This method sets the query that will extract the records.
	 Parameters	 : Object, called from start, objContext Batchable context.
	 Return Type : Object.
	 */
    public Database.QueryLocator start(Database.BatchableContext objContext) {
		String strQuery;
		List<String> lstProductNames = new List<String>();
		List<String> lstDeliveryMethods = new List<String>();

		//First we get the Technical Product Line parameters.
		for(Technical_Product_Line__c objRecord : [SELECT Delivery_Method__c, Forecast_Product__c, Alias__c FROM Technical_Product_Line__c WHERE Id = :idRecord AND Delivery_Method__c <> NULL AND 
				Forecast_Product__c <> NULL LIMIT 1]) {
			lstProductNames = objRecord.Forecast_Product__c.split(';');
			lstDeliveryMethods = objRecord.Delivery_Method__c.split(';');

			//Now we get Subscription Lines.
			for(Subscription_Line__c objSubscriptionLine : [SELECT Id, Product__r.Forecast_Product__c, Product__r.Delivery_Method__c, ARR__c, Contract__c, End_Date__c, Start_Date__c FROM 
					Subscription_Line__c WHERE Product__r.Forecast_Product__c IN :lstProductNames AND Product__r.Delivery_Method__c IN :lstDeliveryMethods AND End_Date__c > TODAY LIMIT 50000]) {
				for(String strForecastProduct : lstProductNames) {
					for(String strDeliveryMethod : lstDeliveryMethods) {
						if(objSubscriptionLine.Product__r.Forecast_Product__c == strForecastProduct && objSubscriptionLine.Product__r.Delivery_Method__c == strDeliveryMethod) {
							mapForecastProductDeliveryMethodCombinations.put(strForecastProduct + '&&&' + strDeliveryMethod, objSubscriptionLine);
						}
					}
				}
			}
		}

		//Now we query the records.
		strQuery = 'SELECT Id, (SELECT Id, Forecast_Product__c, Delivery_Method__c FROM Related_Account_Plans__r WHERE Forecast_Product__c IN :lstProductNames AND ' + 
					'Delivery_Method__c IN :lstDeliveryMethods) FROM Plan__c';
		return Database.getQueryLocator(strQuery);
	}
	
	/*
	 Method Name : execute
	 Description : This method starts the batch.
	 Parameters	 : Object, called from execute, objContext Batchable context.
	 			   Object, called from execute, lstSObjectRecords Records.
	 Return Type : None
	 */
    public void execute(Database.BatchableContext objContext, List<SObject> lstSObjectRecords) {
		Boolean boolShouldCreateNewRecord;
		String strCurrentForecasteProduct;
		String strCurrentDeliveryMethod;
		Related_Account_Plan__c objNewRecord;
		Subscription_Line__c objSubscriptionLine;
		List<Plan__c> lstPlanRecords;
		List<Related_Account_Plan__c> lstRecordsToUpsert = new List<Related_Account_Plan__c>();

		//If we received data.
		if(lstSObjectRecords != null && !lstSObjectRecords.isEmpty() && mapForecastProductDeliveryMethodCombinations != null && !mapForecastProductDeliveryMethodCombinations.isEmpty()) {

			//New record creation.
			for(Plan__c objRecord : (List<Plan__c>) lstSObjectRecords) {
				for(String strCombination : mapForecastProductDeliveryMethodCombinations.keySet()) {

					//We set the initial values.
					boolShouldCreateNewRecord = true;
					strCurrentForecasteProduct = strCombination.split('&&&')[0];
					strCurrentDeliveryMethod = strCombination.split('&&&')[1];

					//We review if the combination already exists.
					if(objRecord.Related_Account_Plans__r != null && !objRecord.Related_Account_Plans__r.isEmpty()) {
						for(Related_Account_Plan__c objExistingPlanProduct : objRecord.Related_Account_Plans__r) {
							if(objExistingPlanProduct.Forecast_Product__c == strCurrentForecasteProduct && objExistingPlanProduct.Delivery_Method__c == strCurrentDeliveryMethod) {
								boolShouldCreateNewRecord = false;
							}
						}
					}

					//If we should create the record.
					if(boolShouldCreateNewRecord) {
						objSubscriptionLine = mapForecastProductDeliveryMethodCombinations.get(strCombination);
						objNewRecord = new Related_Account_Plan__c();
						objNewRecord.Forecast_Product__c = strCurrentForecasteProduct;
						objNewRecord.Delivery_Method__c = strCurrentDeliveryMethod;
						objNewRecord.ARR__c = objSubscriptionLine.ARR__c;
						objNewRecord.Contract__c = objSubscriptionLine.Contract__c;
						objNewRecord.End_Date__c = objSubscriptionLine.End_Date__c;
						objNewRecord.Start_Date__c = objSubscriptionLine.Start_Date__c;
						objNewRecord.Account_Plan__c = objRecord.Id;
						lstRecordsToUpsert.add(objNewRecord);
					}
				}
			}

			//If we have records to upsert.
			if(!lstRecordsToUpsert.isEmpty()) {
				upsert lstRecordsToUpsert;
			}
		}
    }

	/*
	 Method Name : finish
	 Description : This method gets executed once the current batch is done.
	 Parameters	 : Object, called from finish, objContext Batchable context.
	 Return Type : None
	 */
    public void finish(Database.BatchableContext objContext) {
	}

	/*
	 Method Name : createRecords
	 Description : This method creates Entitled Products.
	 Parameters	 : Id, called from createRecords, idRecord Record Id.
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
    public static void createRecords(Id idRecord) {

		//If we received data.
		if(idRecord != null) {
			Database.executebatch(new CSMCreatePlanProductsAndAliasController(idRecord), 1);
		}
    }
}