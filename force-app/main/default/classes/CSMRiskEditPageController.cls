/*
* Name			:	CSMRiskEditPageController
* Author		:	Deva M
* Created Date	: 	17/01/2021
* Description	:	Helper class risk create/Edit page

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		        Description					Tag
Deva M              17/01/2021      AR-2132/1572            Initial Version     
**********************************************************************************************************
*/
public with sharing class CSMRiskEditPageController {
    public final static String PAF_FINAL = 'Final';
    public final static String RISK_FIELD_SET = 'Risks_And_Issues';


     /*
	 Method Name : getRiskRecord
	 Description : This method called from risk edit page 
	 Parameters	 : String strRiskId, record id from Risk PAge        
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static Risk_Issue__c getRiskRecord(String strRiskId){  
        String strCleanRecordId;
        List<Risk_Issue__c> lstRiskRecords;
        //If we have plan record Id
        if(String.isNotBlank(strRiskId)) {
            strCleanRecordId = String.escapeSingleQuotes(strRiskId);
            lstRiskRecords=new List<Risk_Issue__c>([SELECT Id, Reason__c,Milestone__c,Milestone__r.Name,Milestone__r.Objective__r.Name FROM Risk_Issue__c WHERE Id=:strCleanRecordId]);
        }
        return (lstRiskRecords!=null && lstRiskRecords.size()>0)?lstRiskRecords[0]:null;
    }

    /*
	 Method Name : getActiveRiskRecord
	 Description : This method called from risk edit page 
	 Parameters	 : String strRiskId, record id from Risk PAge        
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static Risk_Issue__c getActiveRiskRecord(String strPlanRecordId){  
        String strCleanRecordId;
        List<Risk_Issue__c> lstRiskRecords;        
        Set<String> setCloseRiskStage = new Set<String>{CSMUtilities.RISK_RESOLVED,CSMUtilities.RISK_UNRESOLVED};
        //If we have plan record Id
        if(String.isNotBlank(strPlanRecordId)) {
            strCleanRecordId = String.escapeSingleQuotes(strPlanRecordId);
            lstRiskRecords=new List<Risk_Issue__c>([SELECT Id, Reason__c,Milestone__c,Milestone__r.Name,Milestone__r.Objective__r.Name FROM Risk_Issue__c WHERE Plan__c=:strCleanRecordId AND Risk_Stage__c NOT IN:setCloseRiskStage ]);
        }
        return (lstRiskRecords!=null && lstRiskRecords.size()>0)?lstRiskRecords[0]:null;
    }

    /*
	 Method Name : getRecords
	 Description : This method will fetcht the list open risk records associated with plan
	 Parameters	 : String strPlanId, record id from plan 
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId,Boolean filterCloseRisk){  
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        Set<String> setCloseRiskStage = new Set<String>{CSMUtilities.RISK_RESOLVED,CSMUtilities.RISK_UNRESOLVED};
        String strCleanRecordId;
        String strObjectName = Risk_Issue__c.class.getName();
        //First we make sure we received an id.
		if(String.isNotBlank(strPlanId)) {
            strCleanRecordId = String.escapeSingleQuotes(strPlanId);
            //Now we get the table details.
            objDataTable.strObjectName = strObjectName;
            objDataTable.strFielSetName = RISK_FIELD_SET;
            objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
            String riskQuery='SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + ' WHERE Plan__c = :strCleanRecordId';
            if(filterCloseRisk){
                riskQuery+=' AND Risk_Stage__c NOT IN:setCloseRiskStage WITH SECURITY_ENFORCED LIMIT 1000';
            }else{
                riskQuery+=' WITH SECURITY_ENFORCED LIMIT 1000';
            }
            
            //Now we prepare the response.
            objDataTable.lstRecords = Database.query(riskQuery);
		 }
        return objDataTable;
    }


     /*
	 Method Name : lookupMilestoneSearch
	 Description : This method will fetcht the list of milestones associated with given plan and id and search
	 Parameters	 : String strPlanId, record id from plan 
                    String searchTerm, String with given input
                    List<String> selectedIds, Selected recordid
	 Return Type : List<LookupSearchResult> , search results list of custom wrapper type 
	 */
	@AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupMilestoneSearch(String strPlanId, String searchTerm, List<String> selectedIds) {
        // Prepare query parameters      
        String strCleanRecordId;
        List<LookupSearchResult> results = new List<LookupSearchResult>();
         //First we make sure we received an id.
        if(String.isNotBlank(strPlanId)) {
            strCleanRecordId = String.escapeSingleQuotes(strPlanId);
            // Execute search query
            String iconMilestone = 'standard:entity_milestone';
            //When Search string provided
            if(String.isNotBlank(searchTerm)) {
                searchTerm += '*';
                List<List<SObject>> searchResults = [
                    FIND :searchTerm
                    IN NAME FIELDS
                    RETURNING
                    Milestone__c (Id, Name,Objective__r.Name WHERE Id NOT IN :selectedIds AND Objective__r.Plan__c=:strCleanRecordId)
                ];            
                Milestone__c[] lstMilestone = (List<Milestone__c>) searchResults[0];
                for (Milestone__c objMile : lstMilestone) {
                    String strSubHeading ='Objective : '+objMile.Objective__r.Name;
                    results.add(new LookupSearchResult(objMile.Id, 'Milestone', iconMilestone, objMile.Name, strSubHeading));
                }
            }
        } 
        // Sort all results on title
        results.sort();
        return results;
    }

    /*
	 Method Name : getDefaultRecords
	 Description : This method returns the dfault records of lookup.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : LookupSearchResult
	 */
    @AuraEnabled(cacheable = false)
    public static List<LookupSearchResult> getDefaultRecords(String strRecordId) {
		String strCleanRecordId;
		List<LookupSearchResult> results = new List<LookupSearchResult>();
		String iconMilestone = 'standard:entity_milestone';	
		//If we received a Risk Id.
		if(String.isNotBlank(strRecordId)) {
			//We clean the plan Id.
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for (Milestone__c objMile : [SELECT Id, Name,Objective__r.Name FROM Milestone__c WHERE  Objective__r.Plan__c=:strCleanRecordId]) {
                String strSubHeading ='Objective : '+objMile.Objective__r.Name;
                results.add(new LookupSearchResult(objMile.Id, 'Milestone', iconMilestone, objMile.Name, strSubHeading));
			}
		}		
		return results;	
	}
}