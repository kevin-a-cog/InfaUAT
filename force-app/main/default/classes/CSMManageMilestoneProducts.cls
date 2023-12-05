/*
 * Name			:	CSMManageMilestoneProducts
 * Author		:	Deva M
 * Created Date	: 	31-08-2021
 * Description	:	CSMManageMilestoneProducts controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		31-08-2021		N/A				Initial version.			N/A
 */
public without sharing class CSMManageMilestoneProducts {
    public static String UNASSINGED_PLAN_PRODUCTS = 'CSM_Assinged_Objectuive_Plan_Products';
    public static String ASSINGED_MILESTONE_PRODUCTS = 'CSM_Assinged_Milestone_Products'; 

    /*
	 Method Name : getRecords
	 Description : This method returns the Plan Partner records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 			   Boolean, called from getRecords, boolGetAssingedRecords If we should get Assigned records or Unassiged records.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId, Boolean boolGetAssingedRecords,String strMilestoneId) {
        String strCleanPlanId;
        String strCleanMilestoneId;
        String strAssingedObjectName = Milestone_Product__c.class.getName();
        String strUnAssingedObjectName = Objective_Product__c.class.getName();
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        //If we received a Plan Id.
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            if(String.isNotBlank(strMilestoneId)) {
                strCleanMilestoneId = String.escapeSingleQuotes(strMilestoneId);
                //First, we get all the fields and properties from the Field Set of Assigned records.
                if(boolGetAssingedRecords) {
                        //Now we get the table details.
                        objDataTable.strObjectName = strAssingedObjectName;
                        objDataTable.strFielSetName = ASSINGED_MILESTONE_PRODUCTS;
                        objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
                        //Now we prepare the response.
                        objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Plan_Product_Alias__r.Name__c FROM ' + strAssingedObjectName + 
								' WHERE MIlestone__c = :strCleanMilestoneId order by Plan_Product_Alias__r.Name__c LIMIT 1000');
                                    
                }else{
                    //Now we get the table details.
                    objDataTable.strObjectName = strUnAssingedObjectName;
                    objDataTable.strFielSetName = UNASSINGED_PLAN_PRODUCTS;
                    objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
                    Set<Id> setObjectiveProduct = new Set<Id>();
                    Set<Id> objectiveIdSet = new Set<Id>();
                    for(Milestone__c mileStone:[SELECT Id, Plan__c, Objective__c FROM Milestone__c WHERE Id=:strCleanMilestoneId]){
                        objectiveIdSet.add(mileStone.Objective__c);
                    }
                    for(Milestone_Product__c obj:[SELECT Id, MIlestone__c, Objective_Product__c, Plan_Product_Alias__c FROM Milestone_Product__c WHERE MIlestone__c=:strCleanMilestoneId]){
                        setObjectiveProduct.add(obj.Objective_Product__c);
                    }
                    //Now we prepare the response.
                    objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Plan_Product_Alias__r.Name__c FROM ' + strUnAssingedObjectName + 
							' WHERE objective__c=:objectiveIdSet AND Id NOT in :setObjectiveProduct order by Plan_Product_Alias__r.Name__c LIMIT 1000');
                }
            }
        }
        return objDataTable;
    }

    /*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsRelated, strRecordId Plan to be related to the records.
	 			   List<Related_Account_Plan__c>, called from getRecordsRelated, lstRecords Records to be related.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<String> lstRecords) {
        System.debug(lstRecords+strRecordId);
        Set<Id> objectiveIdSet = new Set<Id>();
		String strCleanRecordId;
        List<Milestone_Product__c> milestoneProducts = new List<Milestone_Product__c>();
        Map<Id,Objective_Product__c> objectiveProductMap = new  Map<Id,Objective_Product__c>();
		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
            for(Milestone__c mileStone:[SELECT Id, Plan__c, Objective__c FROM Milestone__c WHERE Id=:strCleanRecordId]){
                objectiveIdSet.add(mileStone.Objective__c);
            }
            if(objectiveIdSet.size()>0){
                for(Objective_Product__c op:[SELECT Id, Objective__c, Plan_Product_Alias__c FROM Objective_Product__c WHERE Objective__c=:objectiveIdSet]){
                    objectiveProductMap.put(op.Id,op);
                }
            }
			for(String planProductId : lstRecords) {
				Milestone_Product__c mp = new Milestone_Product__c();
                mp.MIlestone__c = strCleanRecordId;               
                //TO Do associate objective product if required.
                if(objectiveProductMap.size()>0 && objectiveProductMap.get(planProductId)!=null){
                    mp.Objective_Product__c =objectiveProductMap.get(planProductId).Id;
                    mp.Plan_Product_Alias__c = objectiveProductMap.get(planProductId).Plan_Product_Alias__c;   
                }         
                milestoneProducts.add(mp);
			}
			insert milestoneProducts;
		}
	}

    /*
	 Method Name : getRecordsDeleted
	 Description : This method deletes the plan contacts
	 Parameters	 : List<Milestone_Product__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Milestone_Product__c> lstRecords) {
		delete lstRecords;
	}

}