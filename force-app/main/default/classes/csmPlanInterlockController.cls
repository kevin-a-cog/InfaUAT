/*
 * Name         :   csmPlanInterlockController
 * Author       :   Pavithra V
 * Created Date :   11/12/2021
 * Description  :   Controller class for interlock creation logic

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                   Tag
 **********************************************************************************************************
 Harshita J            15/09/2022       AR-2922         Added Renewal opp in filter    T1
 */
public without sharing class csmPlanInterlockController {
    
    public csmPlanInterlockController() {

    }

    public static String STRING_FIELD_SET_NAME = 'PlanInterlock';

	/*
	 Method Name : getRecords
	 Description : This method returns the Risks and Issues records related to the provided Id.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRecordId) {
		String strCleanRecordId;
		String strObjectName = Related_Opportunity_Plan__c.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

		//If we received a Risk Id.
		if(String.isNotBlank(strRecordId)) {

			//We clean the Risk Id.
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);

			//If we received Plan id, we get Plan Product records.
			objDataTable.strObjectName = strObjectName;
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME;			
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);		
			
			//Now we prepare the response.
			objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
					' WHERE Plan__c = :strCleanRecordId WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1000');
		}
		return objDataTable;
	}

	/*
	 Method Name : getRecordsDeleted
	 Description : This method deletes the provided list of records.
	 Parameters	 : List<Related_Opportunity_Plan__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Related_Opportunity_Plan__c> lstRecords) {
		delete lstRecords;
	}
	

	/** Custom Lookup search */
	@AuraEnabled(cacheable=true)
   public static List<LookupSearchResult> lookupSearch(String searchTerm, List<String> selectedIds, String objectName,string accId) {
       // Prepare query parameters
       searchTerm += '*';
	   String RenewalOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId(); //</T1>      
       String NNBOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Sales_Opportunity').getRecordTypeId();       
       
	   List<LookupSearchResult> results = new List<LookupSearchResult>();
       // Execute search query
	   if(objectName == 'Opportunity'){
			
			List<List<SObject>> searchResults = [
			FIND :searchTerm
			IN NAME FIELDS
			RETURNING
                Opportunity (Id, Name,Type,StageName,AccountId WHERE AccountId =:accId AND Id NOT IN :selectedIds AND (RecordTypeId =:NNBOpportunity OR  RecordTypeId =:RenewalOpportunity) AND StageName NOT IN ('Closed Won','Closed Lost','No Opportunity','Duplicate'))    //</T1> added renewal check in filter           
			LIMIT 10
		];
		
			String opptyIcon = 'standard:opportunity';
			Opportunity[] lOpportunity = (List<Opportunity>) searchResults[0];
			for (Opportunity oppty : lOpportunity) {
                String strSubHeading ='Type : '+oppty.Type+' , Stage : '+oppty.StageName;
				results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, strSubHeading));
			}
	   }

       // Sort all results on title
       results.sort();
       return results;
   }


   @AuraEnabled(cacheable = false)
    public static String getRecordsInserted( Related_Opportunity_Plan__c interlock) {
		String interlockId = '';
		if(interlock <> null){
			Id InterlockRecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();
			interlock.RecordTypeId =  InterlockRecordTypeId;

			insert interlock;

			interlockId = interlock.Id;
		}
		return interlockId;
	}
	
}