/*
 * Name			:	ManageCasesController
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/26/2022
 * Description	:	Controller class for Manage Cases page.

 Change History
 ***********************************************************************************************************************
 Modified By			Date			Jira No.		Description												   Tag
 ***********************************************************************************************************************
 Vignesh Divakaran		9/26/2022		N/A				Initial version.										   N/A
 balajip        		1/12/2023		I2RT-7537		Updated the sorting order logic							   T01
 */

public with sharing class ManageCasesController {
    
    public static final String CASE_LITE_RECORDTYPE = 'Case_Lite';
    public static final List<String> lstStatus = new List<String>{'New','Assess','Research','Solution','Closed'};

    //T01 the number of Cases loaded at a time
    public static final Integer PAGE_SIZE = 20;

    /*
	 Method Name : getFilters
	 Description : This method returns filters & options that will be used in manage cases page.
	 Parameters	 : None
	 Return Type : List
	 */
    @AuraEnabled(cacheable = false)
	public static Filter getFilters(){
        Filter objResponse = new Filter();
        objResponse.lstOrgs = new List<FilterOption>();
        objResponse.lstStatus = new List<FilterOption>();

        //Now, we prepare org filter options
        for(Org__c objOrg : CaseControllerWithoutSharing.getOrgs()){
            if(objOrg.Support_Lite__c){
                objResponse.lstOrgs.add(new FilterOption(objOrg.OrgID__c, objOrg.Id));
            }
        }
        //Now, we prepare status filter options
        for(String strStatus : lstStatus){
            objResponse.lstStatus.add(new FilterOption(strStatus, strStatus));
        }
        
        return objResponse;
    }

    /*
	 Method Name : getRecords
	 Description : This method returns the cases related to the current user.
	 Parameters	 : Object, called from getRecords, objRequest Request parameters.
	 Return Type : Object of cases.
	 */
    @AuraEnabled(cacheable = false)
    public static CasesPageWrapperClass getRecords(CasesPageWrapperClass objRequest) {
        Id userId = UserInfo.getUserId();
        Set<Id> setActiveOrgIds = new Set<Id>();
        List<Org__c> lstOrgs = CaseControllerWithoutSharing.getOrgs();
        CasesPageWrapperClass objResponse = new CasesPageWrapperClass();
        String strQuery = 'SELECT Id, CaseNumber, Priority, Org_Formula_Id__c, Subject, Forecast_Product__c, Next_Action__c, Status, RecordType.Name,Record_Type_Name__c FROM Case WHERE RecordType.DeveloperName = \''+CASE_LITE_RECORDTYPE+'\' ';

        if(objRequest.intSearchType == null || objRequest.intSearchType == 1) {
            strQuery += 'AND CreatedById = \''+userId+'\' ';
        }

        for(Org__c objOrg : lstOrgs){
            if(objOrg.Support_Lite__c){
                setActiveOrgIds.add(objOrg.Id);
            }
        }

        //Now, we add the filters received from objRequest
        if(!objRequest.lstOrgs.isEmpty()){
            List<String> lstOrgsAfterCleanup = new List<String>();
            for(String strOrgId : objRequest.lstOrgs){
                if(setActiveOrgIds.contains(strOrgId)){
                    lstOrgsAfterCleanup.add(strOrgId);
                }
            }
            strQuery += 'AND Org__c IN ' + '(\''+String.join(GlobalUtility.escapeSingleQuotes(lstOrgsAfterCleanup),'\',\'')+'\') ';
        }
        else{
            strQuery += 'AND Org__c IN ' + '(\''+String.join(new List<Id>(setActiveOrgIds),'\',\'')+'\') ';
        }

        if(!objRequest.lstStatus.isEmpty()){
            strQuery += 'AND Status IN ' + '(\''+String.join(GlobalUtility.escapeSingleQuotes(objRequest.lstStatus),'\',\'')+'\') ';
        }
        else{
            strQuery += 'AND (NOT Status IN (\'Closed\')) ';
        }

        //T01 to sort based on Next Action and Priority by default.
        //Now we set the order.
        if(objRequest.strCaseNumberSorting == '') {
			strQuery += 'ORDER BY NextAction__c DESC, Priority NULLS LAST ';
        }else{
            strQuery += 'ORDER BY CaseNumber ' + objRequest.strCaseNumberSorting + ' ';
		}

        //T01 load more using OFFSET
        //We set the limit and offset
		strQuery += 'LIMIT ' + PAGE_SIZE + ' OFFSET ' + objRequest.intLastViewedRecordCount;
        
        if(!setActiveOrgIds.isEmpty()){
            objResponse.lstRecords = (List<Case>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
            objResponse.boolShowViewMore = objResponse.lstRecords.size() >= PAGE_SIZE ? true : false;
            objResponse.intLastViewedRecordCount = objRequest.intLastViewedRecordCount + PAGE_SIZE;
        }

        objResponse.boolShowInvalidAccessMessage = lstOrgs.isEmpty();
        objResponse.boolShowExpiredSubscriptionMessage = !lstOrgs.isEmpty() && setActiveOrgIds.isEmpty() ? true : false;

        return objResponse;
    }

    /* Wrapper classes */
    public class Filter{
        @AuraEnabled
        public List<FilterOption> lstOrgs {get; set;}
        @AuraEnabled
        public List<FilterOption> lstStatus {get; set;}
    }

    public class FilterOption{
        @AuraEnabled
        public String strLabel {get; set;}
        @AuraEnabled
        public String strValue {get; set;}
        public FilterOption(String label, String value){
            this.strLabel = label;
            this.strValue = value;
        }
    }

    public class CasesPageWrapperClass{
        @AuraEnabled
        public Integer intSearchType {get; set;}
        @AuraEnabled
        public List<String> lstOrgs {get; set;}
        @AuraEnabled
        public List<String> lstStatus {get; set;}
        @AuraEnabled
        public String strCaseNumberSorting {get; set;} //T01
        @AuraEnabled
        public Boolean boolShowExpiredSubscriptionMessage {get; set;}
        @AuraEnabled
        public Boolean boolShowInvalidAccessMessage {get; set;}
        @AuraEnabled
        public Boolean boolShowViewMore {get; set;}
        @AuraEnabled
        public Integer intLastViewedRecordCount {get; set;} //T01
        @AuraEnabled
        public List<Case> lstRecords {get; set;}
    }

}