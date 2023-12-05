/*
 * Name			:	CaseDownloadController
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/28/2022
 * Description	:	Controller class for esCaseDownload LWC.

 Change History
 ***********************************************************************************************************************
 Modified By			Date			Jira No.		Description												   Tag
 ***********************************************************************************************************************
 Vignesh Divakaran		9/28/2022		I2RT-6880		Initial version.										   N/A
 Vignesh Divakaran		10/20/2022		I2RT-7295		Replace	Case Lite record type label to refer custom label  T01
                                                        name
 Isha Bansal            06/15/2023      I2RT-8503       Status changed to multi-select.Handled in getRecords method  T02 
 Isha Bansal            08/08/2023      I2RT-8821       Fixed the datetime in the dateTo filter                      T03
 
                                                        
 */

public with sharing class CaseDownloadController {

    public static final String CASE_LITE_RECORDTYPE_DEVELOPERNAME = 'Case_Lite';
    public static final String CASE_LITE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Lite').getRecordTypeId();

    /*
	 Method Name : getFilters
	 Description : This method returns filters that will be used in case download widget.
	 Parameters	 : None
	 Return Type : List
	 */
    @AuraEnabled(cacheable = false)
	public static DownloadFilter getFilters(Boolean boolShowSupportAccount){
        DownloadFilter objResponse = new DownloadFilter();
        objResponse.lstOrgs = new List<FilterOption>();
        objResponse.lstPriority = new List<FilterOption>();
        objResponse.lstProducts = new List<FilterOption>();
        objResponse.lstCaseTypes = new List<FilterOption>();
        objResponse.lstSupportAccounts = new List<FilterOption>();
        objResponse.boolShowSupportAccount = boolShowSupportAccount;

        Id communityContactId = GlobalUtility.getCommunityUserContactId();

        //Now, we get priority from case schema
        for(Schema.PicklistEntry objPicklistValue : Case.Priority.getDescribe().getPicklistValues()) {
            objResponse.lstPriority.add(new FilterOption(objPicklistValue.getLabel(), objPicklistValue.getLabel()));
		}

        if(boolShowSupportAccount){

            //Now, we get record types from case schema
            for(Schema.RecordTypeInfo objRecordType : Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(objRecordType.getDeveloperName() != 'Master' && objRecordType.getDeveloperName() != CASE_LITE_RECORDTYPE_DEVELOPERNAME){
                    objResponse.lstCaseTypes.add(new FilterOption(objRecordType.getName(), objRecordType.getRecordTypeId()));
                }
            }
            //Now, we add the products
            for(Schema.PicklistEntry objPicklistValue : Case.Forecast_Product__c.getDescribe().getPicklistValues()){
                objResponse.lstProducts.add(new FilterOption(objPicklistValue.getLabel(), objPicklistValue.getLabel()));
            }
            //Now, we add support accounts
            for(AccountContactRelation objAccountContactRelation : getAccountContacts()){
                objResponse.lstSupportAccounts.add(new FilterOption(objAccountContactRelation.Account.Name, objAccountContactRelation.AccountId));
                if(objAccountContactRelation.favorite__c){
                    objResponse.favoriteSupportAccountId = objAccountContactRelation.AccountId;
                }
            }
        }
        else{

            //Now, we get record types from case schema
            for(Schema.RecordTypeInfo objRecordType : Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                //Now, we set case lite as the only record type
                if(objRecordType.getDeveloperName() == CASE_LITE_RECORDTYPE_DEVELOPERNAME){
                    objResponse.lstCaseTypes.add(new FilterOption(System.Label.Case_Lite_RecordType_Name, objRecordType.getRecordTypeId())); //<T01>
                }
            }

            //Now, we add the products
            for(Support_Lite_Product__mdt objSupportLiteProduct : Support_Lite_Product__mdt.getAll().values()){
                if(objSupportLiteProduct.Active__c && objSupportLiteProduct.Is_Case_Creation_Allowed__c && String.isNotBlank(objSupportLiteProduct?.Product_Name_on_Support__c)){
                    for(String strProduct : objSupportLiteProduct.Product_Name_on_Support__c.split(';')){
                        objResponse.lstProducts.add(new FilterOption(strProduct, strProduct));
                    }
                }
            }
            //Now, we add orgs
            for(Org__c objOrg : CaseControllerWithoutSharing.getOrgs()){
                if(objOrg.Support_Lite__c){
                    objResponse.lstOrgs.add(new FilterOption(objOrg.OrgID__c, objOrg.Id));
                }
            }

        }

        return objResponse;
    }

    /*
	 Method Name : getRecords
	 Description : This method returns the cases related to the current user.
	 Parameters	 : Boolean, called from getRecords, boolDescendentOrder TRUE if descendent, FALSE if ascendent.
	 Return Type : List
	 */
    @AuraEnabled(cacheable = false)
    public static List<Case> getRecords(DownloadFilter objRequest) {
        
        Boolean boolExecuteQuery = false;
        List<Case> lstRecords = new List<Case>();
        List<String> lstFilters = new List<String>();
        String strQuery = 'SELECT Id,CaseNumber,Contact.Name,Subject,Description,Forecast_Product__c,Version__c,CreatedDate,Status,Next_Action__c,Record_Type_Name__c,LastModifiedDate,ClosedDate,Closing_Notes__c,Account.Name,Entitled_Product__r.Name,Type,Priority  FROM Case '; 

        //Now, we add the filters from objRequest
        if(String.isNotBlank(objRequest?.strCaseNumber)){
            lstFilters.add('CaseNumber IN ' + '(\''+GlobalUtility.escapeSingleQuotes(objRequest.strCaseNumber)+'\')');
        }
        if(objRequest?.strStatus!=null){//T02 changes for status field.
            String strStatusFilter='';           
            for(String status: objRequest.strStatus){                
                    strStatusFilter+='\''+GlobalUtility.escapeSingleQuotes(status)+'\''+',';
            }            
            if(String.isNotBlank(strStatusFilter) && strStatusFilter.length()>=1){
                strStatusFilter = strStatusFilter.substring(0, strStatusFilter.length() - 1); //removing the last ','
                lstFilters.add('Status IN ' + '('+strStatusFilter+')');                
            }
        }
        
        if(String.isNotBlank(objRequest?.strPriority)){
            lstFilters.add('Priority IN ' + '(\''+GlobalUtility.escapeSingleQuotes(objRequest.strPriority)+'\')');
        }
        if(String.isNotBlank(objRequest?.strProduct)){
            lstFilters.add('Forecast_Product__c IN ' + '(\''+GlobalUtility.escapeSingleQuotes(objRequest.strProduct)+'\')');
        }
        if(String.isNotBlank(objRequest?.strCaseRecordTypeId)){
            lstFilters.add('RecordTypeId IN ' + '(\''+GlobalUtility.escapeSingleQuotes(objRequest.strCaseRecordTypeId)+'\')');
        }
        if(objRequest.dtFrom != null){ 
            lstFilters.add('CreatedDate >= '+DateTime.newInstance(objRequest.dtFrom, Time.newInstance(0, 0, 0, 0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'');
        }
        if(objRequest.dtTo != null ){ //T03 ->changed datetotime to 23.59.59
                lstFilters.add('CreatedDate <= '+DateTime.newInstance(objRequest.dtTo, Time.newInstance(23, 59, 59, 0)).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+''); 
        }        
        if(objRequest.boolShowSupportAccount){
            //We add the selected support account, if it's in one of the support accounts the user has access to.
            for(AccountContactRelation objAccountContactRelation : getAccountContacts()){
                if(objAccountContactRelation.AccountId == objRequest.strSupportAccountId){
                    lstFilters.add('Support_Account__c IN ' + '(\''+GlobalUtility.escapeSingleQuotes(objRequest.strSupportAccountId)+'\')');
                    boolExecuteQuery = true;
                    break;
                }
            }
        }
        else{
            //We add the selected org id, if it's in one of the orgs the user has access to.
            for(Org__c objOrg : CaseControllerWithoutSharing.getOrgs()){
                if(objOrg.Id == objRequest.strOrgId){
                    lstFilters.add('Org__c IN ' + '(\''+GlobalUtility.escapeSingleQuotes(objRequest.strOrgId)+'\')');
                    boolExecuteQuery = true;
                    break;
                }
            }
        }

        //Now, we add all the filters
        if(!lstFilters.isEmpty()){
            strQuery += 'WHERE ' +String.join(lstFilters, ' AND ');
        }

        strQuery += ' ORDER BY CreatedDate DESC LIMIT 40000';       
        if(boolExecuteQuery){
            lstRecords = (List<Case>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
        }
      
        return lstRecords;
    }

    /*
	 Method Name : getAccountContacts
	 Description : This method returns the AccountContactRelation for the community contact.
	 Parameters	 : None
	 Return Type : List
	 */
    private static List<AccountContactRelation> getAccountContacts(){
        String strQuery = 'SELECT Id,AccountId,Account.Name,Account.End_Date__c,favorite__c FROM AccountContactRelation WHERE ContactId =\''+ GlobalUtility.getCommunityUserContactId() +'\' AND Access_Level__c IN (\'Read Only\',\'Read/Write\') AND IsActive = true AND Account.End_Date__c != null ORDER BY  favorite__c  DESC, Account.Name ASC LIMIT 200';
        List<AccountContactRelation> lstAccountContacts = (List<AccountContactRelation>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
        List<AccountContactRelation> lstAccountContactsToReturn = new List<AccountContactRelation>();

        for(AccountContactRelation objAccountContactRelation : lstAccountContacts){
            if(System.today() <= objAccountContactRelation.Account.End_Date__c.addDays(10)){
                lstAccountContactsToReturn.add(objAccountContactRelation);
            }
        }        
        return lstAccountContactsToReturn;
    }

    
    /* Wrapper classes */
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

    public class DownloadFilter{
        @AuraEnabled
        public Date dtFrom {get; set;}
        @AuraEnabled
        public Date dtTo {get; set;}
        @AuraEnabled
        public String strOrgId {get; set;}
        @AuraEnabled
        public String strSupportAccountId {get; set;}
        @AuraEnabled
        public String[] strStatus {get; set;} //T02 convert string to list of string.
        @AuraEnabled
        public String strProduct {get; set;}
        @AuraEnabled
        public String strPriority {get; set;}
        @AuraEnabled
        public String strCaseNumber {get; set;}
        @AuraEnabled
        public String strCaseRecordTypeId {get; set;}
        @AuraEnabled
        public List<FilterOption> lstOrgs {get; set;}
        @AuraEnabled
        public List<FilterOption> lstSupportAccounts {get; set;}
        @AuraEnabled
        public List<String> lstStatus {get; set;}
        @AuraEnabled
        public List<FilterOption> lstProducts {get; set;}
        @AuraEnabled
        public List<FilterOption> lstPriority {get; set;}
        @AuraEnabled
        public List<FilterOption> lstCaseTypes {get; set;}
        @AuraEnabled
        public Id favoriteSupportAccountId {get; set;}
        @AuraEnabled
        public Boolean boolShowSupportAccount {get; set;}
    }
}