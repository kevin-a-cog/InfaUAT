/*
 * Name			:	CSMManagePlanContacts
 * Author		:	Manuraj
 * Created Date	: 	07/07/2021
 * Description	:	Manage Plan Contacts apex controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Manuraj		        07/07/2021	    AR-1560			Initial version.			N/A
 */

public with sharing class CSMManagePlanContacts {
    public static String STRING_FIELD_SET_NAME = 'Plan_Contacts';
    public static String UNAASINGED_PLAN_CONTACT_FIELD_SET_NAME = 'UnAssinged_Plan_Contact';
    /*
	 Method Name : getRecords
	 Description : This method returns the Plan Partner records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 			   Boolean, called from getRecords, boolGetAssingedRecords If we should get Assigned records or Unassiged records.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId, Boolean boolGetAssingedRecords, String supportAcc) {
		//String strPartnerAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(STRING_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
		String strCleanPlanId;
		String strObjectName = Plan_Contact__c.class.getName();
        String strObjectNameA = Contact.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		//If we received a Plan Id.
		if(String.isNotBlank(strPlanId)) {
			strCleanPlanId = String.escapeSingleQuotes(strPlanId);
			//First, we get all the fields and properties from the Field Set of Assigned records.
			if(boolGetAssingedRecords) {

				//Now we get the table details.
				objDataTable.strObjectName = strObjectName;
				objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
				objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
				//Now we prepare the response.
				objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Contact__r.Account.Type,Contact__c,Contact_Name__c FROM ' + strObjectName + ' WHERE Plan__c = :strCleanPlanId ORDER BY Contact__r.Name ASC LIMIT 1000');
			} else {               
                String strCleanAccountId;
                Map<Id,SObject> accounTeamMap = new Map<Id,SObject>();
                List<DataTableWrapperClass.TableRowWrapper> planObjList = new List<DataTableWrapperClass.TableRowWrapper>();
                List<AccountContactRelation> contacts = new List<AccountContactRelation>();
                List<Id> accountids = new List<Id>();
                set<Id> plancontactsSet = new Set<Id>();
                set<Id> partnerAccSet = new Set<Id>();
                Set<Id> allContactsset=new Set<Id>();
                if(String.isNotBlank(strPlanId)) {
                    strCleanPlanId = String.escapeSingleQuotes(strPlanId);
                    for(Plan_Contact__c cc: [Select Contact__c from Plan_Contact__c where Plan__c = :strCleanPlanId]){
                        if(cc.Contact__c!=null){
                            plancontactsSet.add(cc.Contact__c);
                        }
                    }
                    for(Partner_Relationship__c partnerData:[SELECT Partner_Account__c FROM Partner_Relationship__c  WHERE Plan__c =: strCleanPlanId] ){
                        if(partnerData.Partner_Account__c!=null){
                            partnerAccSet.add(partnerData.Partner_Account__c);                          
                        }
                    }
                    //TO DO : Deva Check original requirement if the below code is not required then remove
                    for(Plan__c planData:[SELECT Id,Account__c  FROM Plan__c where Id=:strCleanPlanId]){
                        if(planData.Account__c !=null){
                            partnerAccSet.add(planData.Account__c );                          
                        }
                    }
                    
                    if(string.isnotBlank(supportAcc) && !partnerAccSet.isEmpty()){ 
                        strCleanAccountId  = String.escapeSingleQuotes(supportAcc);     
                        partnerAccSet.add(strCleanAccountId);
                        objDataTable.strObjectName = strObjectNameA;
                        objDataTable.strFielSetName = UNAASINGED_PLAN_CONTACT_FIELD_SET_NAME;
				        objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
                        objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Account.Type FROM ' + strObjectNameA + ' WHERE AccountId IN: partnerAccSet and Id Not in :plancontactsSet ORDER BY Name ASC');
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
    public static void getRecordsDeleted(List<Plan_Contact__c> lstRecords) {
		delete lstRecords;
	}
    /*
	 Method Name : getRecordsUpdated
	 Description : This method updates the provided records.
	 Parameters	 : List<Plan_Contact__c>, called from getRecordsUpdated, lstRecords Records to be updated.
	 Return Type : None
	*/
    @AuraEnabled
    public static void getRecordsUpdated(List<Plan_Contact__c> lstRecords){
        update lstRecords;
    }
    /*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsDeleted, strRecordId Plan to be related to the records.
	 			   List<Plan_Contact__c>, called from getRecordsDeleted, lstRecords Records to be related.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<Contact> lstRecords) {
		String strCleanRecordId;
        List<Plan_Contact__c> plancontacts = new List<Plan_Contact__c>();
		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for(Contact c : lstRecords) {
				Plan_Contact__c cc = new Plan_Contact__c();
                cc.Plan__c = strCleanRecordId;
                cc.Contact__c = c.Id;
                cc.Contact_email__c = c.Email;                
                plancontacts.add(cc);
			}
			insert plancontacts;
		}
	}

}