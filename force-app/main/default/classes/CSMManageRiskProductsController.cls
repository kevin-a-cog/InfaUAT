/*
 * Name			:	CSMManageRiskProductsController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/12/2021
 * Description	:	Manage Risk Products controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/12/2021		N/A				Initial version.			N/A
 */
public without sharing class CSMManageRiskProductsController {

	//Public variables.
	public static String STRING_RECORD_TYPE_NAME = 'Risk';
	public static String STRING_FIELD_SET_NAME_RISK_PRODUCTS = 'Risk_Products';
	//public static String STRING_FIELD_SET_NAME_PLAN_PRODUCTS = 'Related_Account_Plan';
	public static String STRING_FIELD_SET_NAME_PLAN_PRODUCTS_ALIAS = 'Plan_Product_Alias';
	
	/*
	 Method Name : getRiskRecordType
	 Description : This method returns the default records type for the feature.
	 Parameters	 : None
	 Return Type : Record Type Id
	 */
    @AuraEnabled(cacheable = false)
    public static String getRiskRecordType() {
		return Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get(STRING_RECORD_TYPE_NAME).getRecordTypeId();
	}

	/*
	 Method Name : getRecords
	 Description : This method returns the Risk or Plan Product records related to the provided Risk Id and Plan Id.
	 Parameters	 : String, called from getRecords, strRiskId Risk Id.
	 			   String, called from getRecords, strPlanId Plan Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRiskId) {
		String strCleanRiskId;
		String strCleanPlanId;
		String strObjectNameRiskProduct = Risk_Product_Alias__c.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		//If we received a Risk Id.
		if(String.isNotBlank(strRiskId)) {
			//We clean the Risk Id.
			strCleanRiskId = String.escapeSingleQuotes(strRiskId);
			//Otherwise we process Risk Product records.
			objDataTable.strObjectName = strObjectNameRiskProduct;
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME_RISK_PRODUCTS;
			objDataTable.mapCustomColumnLabels = new Map<String, String>();
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
			//Now we prepare the response.
			objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Plan_Product_Alias__r.Name__c FROM ' + strObjectNameRiskProduct + 
					' WHERE Risk__c = :strCleanRiskId LIMIT 1000');
		}
		return objDataTable;
	}

	/*
	 Method Name : getRecordsDeleted
	 Description : This method deletes the provided list of records.
	 Parameters	 : List<Related_Risk_Product__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Risk_Product_Alias__c> lstRecords) {
		delete lstRecords;
	}

	/*
	 Method Name : insertRisk
	 Description : This method creates a new Risk Issue record.
	 Parameters	 : Risk_Issue__c, called from insertRisk, Record to be inserted.
	 Return Type : String
	 */
    @AuraEnabled(cacheable = false)
    public static String insertRisk(Risk_Issue__c objRecord) {
		//objRecord.RecordTypeId = getRiskRecordType();
		insert objRecord;
		return objRecord.Id;
	}

	/*
	 Method Name : getRecordsUpdated
	 Description : This method updates the provided records.
	 Parameters	 : List<Risk_Product_Alias__c>, called from getRecordsUpdated, lstRecords Records to be updated.
	 Return Type : None
	*/
    @AuraEnabled
    public static void getRecordsUpdated(List<Risk_Product_Alias__c> lstRecords){
        update lstRecords;
    }

	/*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsRelated, strRecordId Plan to be related to the records.
	 			   List<Plan_Product_Alias__c>, called from getRecordsRelated, lstRecords Records to be related.
	 Return Type : None
	
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<Plan_Product_Alias__c> lstRecords) {
		String strCleanRecordId;
		Risk_Product_Alias__c objRiskProduct;
		List<Risk_Product_Alias__c> lstRiskProducts = new List<Risk_Product_Alias__c>();

		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for(Plan_Product_Alias__c objRecord : lstRecords) {
				objRiskProduct = new Risk_Product_Alias__c(); 
				//objRiskProduct.Plan_Product__c = objRecord.id;
				objRiskProduct.Plan_Product_Alias__c = objRecord.id;
				objRiskProduct.Risk__c = strRecordId;
				lstRiskProducts.add(objRiskProduct);
			}
			insert lstRiskProducts;
		}
	}*/
}