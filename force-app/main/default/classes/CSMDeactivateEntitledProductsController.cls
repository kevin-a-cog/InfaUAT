/*
 * Name			:	CSMDeactivateEntitledProductsController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/23/2022
 * Description	:	Controller class for Deactivate Entitled Products feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/23/2022		N/A				Initial version.			N/A
 */
public with sharing class CSMDeactivateEntitledProductsController {

	/*
	 Method Name : deactivateRecords
	 Description : This method deactivates the Entitled Products.
	 Parameters	 : Id, called from deactivateRecords, idRecord Record Id.
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
    public static void deactivateRecords(Id idRecord) {
		Set<Id> setEntitledProductIds = new Set<Id>();
		List<Asset> lstAssets = new List<Asset>();
		List<Entitled_Product__c> lstEntitledProducts = new List<Entitled_Product__c>();

		//If we received data.
		if(idRecord != null) {
			for(Technical_Product_Line__c objTechnicalProductLine : [SELECT Id, Name FROM Technical_Product_Line__c WHERE Id = :idRecord LIMIT 1]) {
				for(Entitled_Product__c objRecord : [SELECT Id FROM Entitled_Product__c WHERE Forecast_Product__c = :objTechnicalProductLine.Name LIMIT 50000]) {
					objRecord.End_Date__c = System.today();
					setEntitledProductIds.add(objRecord.Id);
					lstEntitledProducts.add(objRecord);
				}

				//If we have Entitled Products.
				if(!setEntitledProductIds.isEmpty()) {
					for(Asset objAsset : [SELECT Id FROM Asset WHERE Entitled_Product__c IN :setEntitledProductIds LIMIT 50000]) {
						objAsset.Entitled_Product__c = null;
						lstAssets.add(objAsset);
					}

					//Now we update the Assets, if any.
					if(!lstAssets.isEmpty()) {
						update lstAssets;
					}

					//Now we update the Entitled Products.
					update lstEntitledProducts;
				}

				//Now we update the Technical Product Line.
				objTechnicalProductLine.Status__c = 'In-Active';
				update objTechnicalProductLine;
			}
		}
    }

	/*
	 Method Name : getForecastProduct
	 Description : This method retrieves the Forecast Product of the given Technical Product Line.
	 Parameters	 : Id, called from getForecastProduct, idRecord Record Id.
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
    public static String getForecastProduct(Id idRecord) {
		return [SELECT Forecast_Product__c FROM Technical_Product_Line__c WHERE Id = :idRecord LIMIT 1].Forecast_Product__c;
	}

	/*
	 Method Name : getReportIds
	 Description : This method returns the Ids of the reports.
	 Parameters	 : None.
	 Return Type : Map<Id, String>
	 */
	@AuraEnabled(cacheable = false)
    public static Map<Id, String> getReportIds() {
		String strName;
		Map<Id, String> mapResults = new Map<Id, String>();

		//If the reports exits.
		for(Report objRecord : [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName IN ('New_Plan_Products_with_Plan_Report_C4B', 'New_Cases_and_Entitled_Product_Report_4xJ')]) {
			switch on objRecord.DeveloperName {
				when 'New_Plan_Products_with_Plan_Report_C4B' {
					strName = Label.New_Plan_Products_with_Plan_Report_C4B;
				}
				when 'New_Cases_and_Entitled_Product_Report_4xJ' {
					strName = Label.New_Cases_and_Entitled_Product_Report_4xJ;
				}
			}
			mapResults.put(objRecord.Id, strName);
		}
		return mapResults;
	}
}