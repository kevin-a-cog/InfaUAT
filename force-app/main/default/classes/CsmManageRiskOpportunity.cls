/*
 * Name			:	CsmManageRiskOpportunity
 * Author		:	Karthi Gurusamy
 * Created Date	: 	22/09/2023
 * Description	:	This Apex exposes the Manage Risk related Opportunities controller for LWC.

 Change History
 **********************************************************************************************************
 Modified By			    Date			Jira No.		    Description					Tag
 **********************************************************************************************************
 Karthi Gurusamy		22/09/2023		    AR-3444				Initial version.			N/A
 */

public with sharing class CsmManageRiskOpportunity {
    public static String STRING_FIELD_SET_NAME = 'Risk_Opportunities';
    public static String UNAASINGED_RISK_OPTY_FIELD_SET_NAME = 'Risk_Opportunity_Unassigned';
    /*
	 Method Name : getRecords
	 Description : This method returns the opportunity records related to the provided Risk.
	 Parameters	 : String, called from getRecords, strRiskId Record Id.
	 			   Boolean, called from getRecords, boolGetAssingedRecords If we should get Assigned records or Unassiged records.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRiskId, Boolean boolGetAssingedRecords, String planAcc) {
        
		String strCleanRiskId;
		String strObjectName = Risk_Product_Alias__c.class.getName();
        String strObjectNameA = Opportunity.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		//If we received a Plan Id.
		if(String.isNotBlank(strRiskId)) {
			strCleanRiskId = String.escapeSingleQuotes(strRiskId);
			//First, we get all the fields and properties from the Field Set of Assigned records.
			if(boolGetAssingedRecords) {

				//Now we get the table details.
				objDataTable.strObjectName = strObjectName;
				objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
				objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
				//Now we prepare the response.
				objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Opportunity__r.StageName ,Opportunity__r.CloseDate, Opportunity__r.Cloud_Churn_Forecast_Percent__c, Opportunity__r.Cloud_Churn_Forecast__c, Opportunity__r.On_Prem_Churn_Forecast_Percent__c, Opportunity__r.On_Premise_Churn_Forecast__c, Opportunity__r.Cloud_Swing_Forecast_Percent__c, Opportunity__r.Cloud_Swing_Forecast__c, Opportunity__r.On_Prem_Swing_Forecast_Percent__c, Opportunity__r.On_Premise_Swing_Forecast__c, Opportunity__r.CSM_Comments__c FROM ' + strObjectName + ' WHERE Risk__c = :strCleanRiskId ORDER BY Opportunity__r.Name ASC LIMIT 1000');
			} else {               
                String strCleanAccountId;                
                set<Id> setRiskOpties = new Set<Id>();
                if(String.isNotBlank(strRiskId)) {
                    strCleanRiskId = String.escapeSingleQuotes(strRiskId);
                    for(Risk_Product_Alias__c cc: [Select Opportunity__c from Risk_Product_Alias__c where Risk__c = :strCleanRiskId]){
                        if(cc.Opportunity__c!=null){
                            setRiskOpties.add(cc.Opportunity__c);
                        }
                    }
                    
                    if(string.isnotBlank(planAcc)){ 
                        strCleanAccountId  = String.escapeSingleQuotes(planAcc); 
                        objDataTable.strObjectName = strObjectNameA;
                        objDataTable.strFielSetName = UNAASINGED_RISK_OPTY_FIELD_SET_NAME;
				        objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
                        objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectNameA + ' WHERE AccountId = :strCleanAccountId and Id Not in :setRiskOpties AND RecordType.DeveloperName = \'Renewal_Opportunity\' AND StageName NOT IN (\'Closed Won\',\'Closed Lost\', \'No Opportunity\',\'Duplicate\') ORDER BY Name ASC');
                    }
                }				
			}
		}
		return objDataTable;
    }

    /*
	 Method Name : getRecordsDeleted
	 Description : This method deletes the plan contacts
	 Parameters	 : List<Plan_Contact__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Risk_Product_Alias__c> lstRecords) {
		delete lstRecords;
	}
    
    /*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsDeleted, strRecordId Plan to be related to the records.
	 			   List<Plan_Contact__c>, called from getRecordsDeleted, lstRecords Records to be related.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<Opportunity> lstRecords) {
		String strCleanRecordId;
        List<Risk_Product_Alias__c> lstRiskOpty = new List<Risk_Product_Alias__c>();
		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for(Opportunity c : lstRecords) {
				Risk_Product_Alias__c cc = new Risk_Product_Alias__c();
                cc.Risk__c = strCleanRecordId;
                cc.Opportunity__c = c.Id;             
                lstRiskOpty.add(cc);
			}
			insert lstRiskOpty;
		}
	}
}