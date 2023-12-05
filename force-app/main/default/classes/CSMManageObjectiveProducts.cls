/*
 * Name			:	CSMManageObjectiveProducts
 * Author		:	Deva M
 * Created Date	: 	31-08-2021
 * Description	:	CSMManageObjectiveProducts controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		31-08-2021		N/A				Initial version.			N/A
 */
public without sharing class CSMManageObjectiveProducts {   
    public static String UNASSINGED_PLAN_PRODUCTS = 'Plan_Product_Alias_Objective';
    public static String ASSIGNED_OBJECTIVE_PLAN_PRODUCTS = 'CSM_Assinged_Objectuive_Plan_Products';

       /*
	 Method Name : getRecords
	 Description : This method returns the Plan Partner records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 			   Boolean, called from getRecords, boolGetAssingedRecords If we should get Assigned records or Unassiged records.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId, Boolean boolGetAssingedRecords,String strObjectiveId) {
        String strCleanPlanId;
        String strCleanObjectiveId;
        String strObjectName = Plan_Product_Alias__c.class.getName();
        String strAssingedObjectName = Objective_Product__c.class.getName();
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        //If we received a Plan Id.
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            if(String.isNotBlank(strObjectiveId)) {
                strCleanObjectiveId = String.escapeSingleQuotes(strObjectiveId);
                //First, we get all the fields and properties from the Field Set of Assigned records.
                if(boolGetAssingedRecords) {
                        //Now we get the table details.
                        objDataTable.strObjectName = strAssingedObjectName;
                        objDataTable.strFielSetName = ASSIGNED_OBJECTIVE_PLAN_PRODUCTS;
                        objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
                        //Now we prepare the response.
                        objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Plan_Product_Alias__r.Name__c FROM ' + strAssingedObjectName + 
								' WHERE Objective__c = :strCleanObjectiveId order by Plan_Product_Alias__r.Name__c  LIMIT 1000');
                                    
                }else{
                    //Now we get the table details.
                    objDataTable.strObjectName = strObjectName;
                    objDataTable.strFielSetName = UNASSINGED_PLAN_PRODUCTS;
                    objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
                    Set<Id> setProduct = new Set<Id>();
                    for(Objective_Product__c obj:[SELECT Id, Plan_Product_Alias__c, Objective__c FROM Objective_Product__c WHERE Objective__c=:strCleanObjectiveId]){
                        setProduct.add(obj.Plan_Product_Alias__c);
                    }
                    //Now we prepare the response.
                    objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Name__c FROM ' + strObjectName + 
							' WHERE Plan__c = :strCleanPlanId AND Id NOT in :setProduct order by Name__c LIMIT 1000');
                }
            }
        }
        return objDataTable;
    }
    /*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsRelated, strRecordId Plan to be related to the records.
	 			   List<Plan_Contact__c>, called from getRecordsRelated, lstRecords Records to be related.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<String> lstRecords) {
		String strCleanRecordId;
        List<Objective_Product__c> objectiveProducts = new List<Objective_Product__c>();
		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for(String planProduct : lstRecords) {
				Objective_Product__c op = new Objective_Product__c();
                op.Objective__c = strCleanRecordId;
                op.Plan_Product_Alias__c = planProduct;              
                objectiveProducts.add(op);
			}
			insert objectiveProducts;
		}
	}

    /*
	 Method Name : getRecordsDeleted
	 Description : This method deletes the plan contacts
	 Parameters	 : List<Objective_Product__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Objective_Product__c> lstRecords) {
		delete lstRecords;
	}
}