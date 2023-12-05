/*
 * Name			:	OrgDetailController
 * Author		:	Vignesh Divakaran
 * Created Date	:   10/21/2022
 * Description	:	Controller class for esOrgDetails LWC.

 Change History
 ***********************************************************************************************************************
 Modified By			Date			Jira No.		Description												   Tag
 ***********************************************************************************************************************
 Vignesh Divakaran		10/21/2022		I2RT-7256		Initial version.										   N/A
 */

public with sharing class OrgDetailController {
    
    /*
	 Method Name : getOrgDetails
	 Description : This method returns the org details.
	 Parameters	 : Id, called from getOrgDetails, orgId record id
	 Return Type : Object
	 */
    @AuraEnabled(cacheable = false)
	public static OrgDetailWrapperClass getOrgDetails(Id orgId){
        Boolean boolHasAccess = false;
        OrgDetailWrapperClass objResponse = new OrgDetailWrapperClass();
        objResponse.lstOrgUsers = new List<Org_User__c>();

        //Now, we verify user's access to see the org
        for(Org__c objOrg : CaseControllerWithoutSharing.getOrgs()){
            if(objOrg.Id == orgId && objOrg.Support_Lite__c){
                boolHasAccess = true;
                break;
            }
        }

        if(boolHasAccess){
            //Now, we query the org
            String strQuery = 'SELECT Id,OrgID__c,Name,Pod_Location__c,Pod_Name__c,Pod_Region__c FROM Org__c WHERE Id = \''+orgId+'\' LIMIT 1';
            List<Org__c> lstOrgs = (List<Org__c>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
            objResponse.objOrg = lstOrgs.size() >= 1 ? lstOrgs[0] : new Org__c();

            //Now, we query org users
            strQuery = 'SELECT Id,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.Phone,Contact__r.INFA_Language__c,Contact__r.TimeZone_Lookup__r.Name,FirstName__c,LastName__c,Email__c,PhoneNumber__c FROM Org_User__c WHERE Org__c = \''+orgId+'\' AND (Contact__c != null OR Email__c != null) LIMIT 2000';
            objResponse.lstOrgUsers = (List<Org_User__c>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
        }

        objResponse.boolShowInvalidAccessMessage = objResponse.objOrg != null ? false : true;

        return objResponse;
    }

    /* Wrapper classes */
    public class OrgDetailWrapperClass{
        @AuraEnabled
        public Org__c objOrg {get; set;}
        @AuraEnabled
        public List<Org_User__c> lstOrgUsers {get; set;}
        @AuraEnabled
        public Boolean boolShowInvalidAccessMessage {get; set;}
    }
}