/*
 * Name			:	CSMPlanRisksController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/14/2021
 * Description	:	Plan Risks controller. 

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/14/2021		N/A				Initial version.			N/A
 */
public with sharing class CSMPlanRisksController {

	//Public variables.
	public static String STRING_FIELD_SET_NAME = 'Risks_And_Issues';
	//@AuraEnabled
	//public Boolean boolOnePAFCycleCompleted = false;
	@AuraEnabled
	public Boolean boolOpenRiskAvailable = false;
	/*
	 Method Name : validateRisk
	 Description : This method returns boolean if one paf cycle completed
	 Parameters	 : String strPlanId, called from validateRisk, strPlanId plan Record Id.
	 Return Type : boolean
	 */
	@AuraEnabled(cacheable = false)
    public static CSMPlanRisksController validateRisk(String strPlanId){
		CSMPlanRisksController objCont = new CSMPlanRisksController();
		Set<String> setCloseRiskStage = new Set<String>{CSMUtilities.RISK_RESOLVED,CSMUtilities.RISK_UNRESOLVED};
		String strCleanRecordId;
		//objCont.boolOnePAFCycleCompleted = false;
		objCont.boolOpenRiskAvailable = false;
		//If we received a Risk Id.
		if(String.isNotBlank(strPlanId)) {
			//We clean the Plan Id.
			strCleanRecordId = String.escapeSingleQuotes(strPlanId);
		/*	for(Adoption_Factor__c obj:[SELECT Id, Status__c, Impact_Reason__c, Impact__c, Engagement__c, Product__c, Project__c, Plan__c,Plan_Health_Score__c  FROM Adoption_Factor__c WHERE Plan__c=:strCleanRecordId]){
				if(String.isNotBlank(obj.Plan_Health_Score__c)){
					objCont.boolOnePAFCycleCompleted=true;
					break;
				}
			} */
			//Ceck if open risks are available on plan
			for(Risk_Issue__c objRisk:[SELECT Id, Plan__c, Risk_Stage__c FROM Risk_Issue__c WHERE Plan__c=:strCleanRecordId AND Risk_Stage__c NOT IN :setCloseRiskStage]){
				objCont.boolOpenRiskAvailable=true;
				break;
			}
		}
		return objCont;
	}
	/*
	 Method Name : getRecords
	 Description : This method returns the Risks and Issues records related to the provided Id.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRecordId) {
		String strCleanRecordId;
		String strObjectName = Risk_Issue__c.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

		String sObjectType = Id.valueOf(strRecordId).getSObjectType().getDescribe().getName();

		//If we received a Risk Id.
		if(String.isNotBlank(strRecordId)) {

			//We clean the Risk Id.
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);

			//If we received Plan id, we get Plan Product records.
			objDataTable.strObjectName = strObjectName;
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

			//Now we change the field type of Risk Type column.
			for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objDataTable.lstColumns) {
				if(objColumn.fieldName == Schema.Risk_Issue__c.Risk_Type__c.getDescribe().getName()) {
					objColumn.boolContainsHTML = true;
				}
			}

			//Now we prepare the response.
			Set<Id> setPlanIds = new Set<Id>();
			Set<Id> setRiskIds = new Set<Id>();
			if(sObjectType =='Plan__c'){
				setPlanIds.add(strCleanRecordId);
			}
			else if(sObjectType =='Risk_Issue__c'){
				for(Risk_Issue__c objRI : [SELECT Id, Plan__c from Risk_Issue__c WHERE Id=:strRecordId LIMIT 1]){
					setPlanIds.add(objRI.Plan__c);
				}
			}
			else if(sObjectType =='Opportunity'){
				for(Related_Opportunity_Plan__c objROP : [Select Plan__c from Related_Opportunity_Plan__c where Opportunity__c =:strRecordId AND Plan__c!=null]){
					setPlanIds.add(objROP.Plan__c);
				}
				for(Risk_Product_Alias__c objRPA : [Select Risk__c from Risk_Product_Alias__c where Opportunity__c =:strRecordId]){
					setRiskIds.add(objRPA.Risk__c);
				}
			}

			objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Plan__r.Plan_Status_Reason__c,Plan__r.CSM_isAutoPilot__c,Plan__r.Status__c FROM ' + strObjectName + 
					' WHERE (Plan__c IN :setPlanIds OR Id IN :setRiskIds) AND Id <> :strCleanRecordId ORDER BY Createddate desc LIMIT 1000');
		}
		return objDataTable;
	}

	/*Depricated
	 Method Name : getRecordsDeleted
	 Description : This method deletes the provided list of records.
	 Parameters	 : List<Risk_Issue__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Risk_Issue__c> lstRecords) {
		delete lstRecords;
	}*/
}