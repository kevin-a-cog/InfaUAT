/*
 * Name         :   OrgServiceTriggerHelper
 * Author       :   Vignesh Divakaran
 * Created Date :   8/29/2022
 * Description  :   This is an helper class.

 Change History
 ***********************************************************************************************************************************
 Modified By            Date            Jira No.        Tag     Description                                
 ***********************************************************************************************************************************
 Vignesh Divakaran      8/29/2022       I2RT-6149       N/A     Initial version.
 */

 public class OrgServiceTriggerHelper {
    
    public static globalApexManager GAM = new globalApexManager();

    /*
    * this method rollsup Expiration Date onto support account.
    * @param lstNewOrgServices
    * @return return-void
    * @throws exception - NA
    */
    public void rollupExpirationDateToOrg(List<Org_Service__c> lstNewOrgServices){
        Set<Id> setOrgIds = new Set<Id>();
        Set<String> setOrgServiceNames = new Set<String>();
        Map<Id, Org__c> mapOrgs = new Map<Id, Org__c>();

        //Get Org Id from Org Service
        for(Org_Service__c objOrgService : lstNewOrgServices){
            setOrgIds.add(objOrgService.Org_ID__c);
        }

        //Get support lite product custom metadata type records
        Map<String, Support_Lite_Product__mdt> mapSupportLiteProduct = Support_Lite_Product__mdt.getAll();
        for(Support_Lite_Product__mdt objSupportLiteProduct : mapSupportLiteProduct.values()){

            //Now, we check if the support lite product is active
            if(objSupportLiteProduct.Active__c && objSupportLiteProduct.Is_Case_Creation_Allowed__c){
                setOrgServiceNames.add(objSupportLiteProduct.Org_Service_Name__c);
            }
        }

        AggregateResult[] lstAggregateResult = [SELECT max(Expiration_Date__c) maxEndDate, Org_ID__c orgId FROM Org_Service__c where Org_Service_Name__c IN :setOrgServiceNames AND Expiration_Date__c >= Today AND Org_ID__c IN :setOrgIds GROUP BY Org_ID__c];
        for(AggregateResult objAggregateResult : lstAggregateResult){
            Org__c objOrg = new Org__c(Id = (Id) objAggregateResult.get('orgId'));
            objOrg.Support_Lite_End_Date__c = (Date) objAggregateResult.get('maxEndDate');
            mapOrgs.put(objOrg.Id, objOrg);
        }

        //If there is no active org service, reset Support Lite End Date on org
        for(Id orgId : new List<Id>(setOrgIds)){
            if(!mapOrgs.containsKey(orgId)){
                Org__c objOrg = new Org__c(Id = orgId);
                objOrg.Support_Lite_End_Date__c = null;
                mapOrgs.put(objOrg.Id, objOrg);
            }
        }

        if(!mapOrgs.values().isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(mapOrgs.values(), false);             
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('OrgServiceTriggerHelper.rollupExpirationDateToOrg', 'Error while updating orgs: ', e.getMessage());
            } 
        }
    }

	/*
	 Method Name : trackingHistory
	 Description : This method keeps track of the changes on specified fields.
	 Parameters	 : List, called from trackingHistory, lstNewRecords New records.
	 			   Map, called from trackingHistory, mapOldRecords Old records.
	 Return Type : None
	 */
    public static void trackingHistory(List<Org_Service__c> lstNewRecords, Map<Id, Org_Service__c> mapOldRecords) {
		Org_Service__c oldRecord;

		//If we received data.
		if(lstNewRecords != null && !lstNewRecords.isEmpty() && mapOldRecords != null && !mapOldRecords.isEmpty()) {
			for(Org_Service__c objRecord : lstNewRecords) {
				oldRecord = mapOldRecords.get(objRecord.Id);
				if(objRecord.Number_of_Entitlements_consumed__c != oldRecord.Number_of_Entitlements_consumed__c || objRecord.Last_Completed_Billing_Cycle__c != oldRecord.Last_Completed_Billing_Cycle__c) {
					objRecord.Previous_Number_of_Entitlements_consumed__c = oldRecord.Number_of_Entitlements_consumed__c;
				}
			}
		}
	}
}