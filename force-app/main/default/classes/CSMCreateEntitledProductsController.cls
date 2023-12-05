/*
 * Name			:	CSMCreateEntitledProductsController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/24/2022
 * Description	:	Controller class for Create Entitled Products feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/24/2022		N/A				Initial version.			N/A
 */
public with sharing class CSMCreateEntitledProductsController implements Database.Batchable<sObject> {

	//Private variables.
	private Id idRecord;

	/*
	 Method Name : CSMCreateEntitledProductsController
	 Description : Constructor of the class.
	 Parameters	 : Id, called from CSMCreateEntitledProductsController, idRecord Technical Product Line id.
	 Return Type : Object.
	 */
	public CSMCreateEntitledProductsController(Id idRecord) {
		this.idRecord = idRecord;
	}
	
	/*
	 Method Name : start
	 Description : This method sets the query that will extract the records.
	 Parameters	 : Object, called from start, objContext Batchable context.
	 Return Type : Object.
	 */
    public Database.QueryLocator start(Database.BatchableContext objContext) {
		List<String> lstProductNames = new List<String>();
		List<String> lstDeliveryMethods = new List<String>();

		//First we get the Technical Product Line parameters.
		for(Technical_Product_Line__c objRecord : [SELECT Delivery_Method__c, Forecast_Product__c FROM Technical_Product_Line__c WHERE Id = :idRecord AND Delivery_Method__c <> NULL AND 
				Forecast_Product__c <> NULL LIMIT 1]) {
			lstProductNames = objRecord.Forecast_Product__c.split(';');
			lstDeliveryMethods = objRecord.Delivery_Method__c.split(';');
		}

		//Now we query the records.
		return Database.getQueryLocator('SELECT Id FROM Asset WHERE Product2.Name IN :lstProductNames AND Delivery_Method__c IN :lstDeliveryMethods AND Entitled_Product__c = NULL AND ' + 
				'Id IN (SELECT AssetId FROM Entitlement WHERE EndDate > TODAY) AND Account.RecordType.Name = \'Support Account\'');
	}
	
	/*
	 Method Name : execute
	 Description : This method starts the batch.
	 Parameters	 : Object, called from execute, objContext Batchable context.
	 			   Object, called from execute, lstRecords Asset records.
	 Return Type : None
	 */
    public void execute(Database.BatchableContext objContext, List<Asset> lstRecords) {
		Set<Id> setRecordIds = new Set<Id>();

		//First we extract the Ids.
		if(lstRecords != null && !lstRecords.isEmpty()) {
			for(Asset objRecord : lstRecords) {
				setRecordIds.add(objRecord.Id);
			}
	
			//If we have Asset Ids.
			if(!setRecordIds.isEmpty()) {
				EntitledProductService.createEntitledProducts(setRecordIds, null);
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
			Database.executebatch(new CSMCreateEntitledProductsController(idRecord), 100);
		}
    }
}