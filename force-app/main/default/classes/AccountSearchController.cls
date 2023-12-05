/*
Class:          AccountSearchController
@Author:        Jiju
@Created Date:  18 Nov 2021
@Description:   call to MDM API to search Account on New Account creation - SALESRT-13355

************************************************************************************************************************************
ModifiedBy        Date         JIRA NO        Requested by      Description                       Tag
Jiju            01/01/23      SALESRT-14242   Jan Build 23      add Website and Phone Number     <T01>
Sreerekha       26/08/23      SALESRT-13356   Nov Build 23      Polaris - Revisit of the entire Lead Conversion Button  <T02>
************************************************************************************************************************************
*/
public class AccountSearchController {
    public static globalApexManager GAM = new globalApexManager();
    /*
    * get List of Accounts from MDM API
    * @param searchKey - Account to be searched
    * @return return - List<AccountSearchResultWrapper>
    */
    @AuraEnabled
    public static List<AccountSearchResultWrapper> searchAccounts(Map<String, String> searchParamsMap, Integer countOfResult, Boolean leadConversion) {
        List<AccountSearchResultWrapper> searchResultList = new List<AccountSearchResultWrapper>();
        //SALESRT-13356
        List<AccountSearchResultWrapper> sortedResultList = new List<AccountSearchResultWrapper>(); 
        List<string> recordTypes = String.valueOf(Label.Account_RecordType_Hierarchy_for_Lead_conversion).split(';');
        //
        List<Object> lst_JsonParse;
        if(String.isNotBlank(searchParamsMap.get('account_number')) || String.isNotBlank(searchParamsMap.get('address')) || String.isNotBlank(searchParamsMap.get('city')) || String.isNotBlank(searchParamsMap.get('country'))
          || String.isNotBlank(searchParamsMap.get('gduns')) || String.isNotBlank(searchParamsMap.get('name')) || String.isNotBlank(searchParamsMap.get('postal_code')) || String.isNotBlank(searchParamsMap.get('state'))||String.isNotBlank(searchParamsMap.get('phoneNumber'))||String.isNotBlank(searchParamsMap.get('website'))){
            String response = getAccountSearchResult(searchParamsMap,countOfResult);
            if(response != 'Error'){
                searchResultList = AccountSearchResultWrapper.parse(response);
            } else {
                throw new AuraHandledException('MDM API Failed to return results');
            }
        }
        //SALESRT-13356
        if(leadConversion == true){
            for(Integer i= 0;i< recordTypes.size();i++){
                for(AccountSearchResultWrapper obj:searchResultList){
                    if(!sortedResultList.contains(obj)){
                        if(!string.isBlank(obj.salesforce_id)){
                            obj.isSalesforceRecord = true;
                        }
                        if(obj.source == 'SFDC' && obj.Account_Type == recordTypes[i]){
                            sortedResultList.add(obj);                                        
                        }
                    }                    
                }
            }
            for(AccountSearchResultWrapper obj:searchResultList){
                if(!sortedResultList.contains(obj) && obj.source == 'MDM'){
                    if(!string.isBlank(obj.salesforce_id)){
                        obj.isSalesforceRecord = true;
                    }
                    sortedResultList.add(obj);
                }
            }
            return sortedResultList;
        }else {
            for(AccountSearchResultWrapper obj:searchResultList){
                if(!string.isBlank(obj.salesforce_id)){
                    obj.isSalesforceRecord = true;
                }
            }
            return searchResultList;
        }
    }
    /*
    * get List fo Accounts from MDM API
    * @param searchKey - Account to be searched
    * @return return - string
    */
    private static string getAccountSearchResult(Map<String, String> searchParamsMap, Integer countOfResult){
        String returnResp;
        String restAPIURL = '?rows='+countOfResult;
        for(String key: searchParamsMap.keySet() ){
            if(String.isNotBlank(searchParamsMap.get(key))){
                restAPIURL += '&'+key+'='+EncodingUtil.urlEncode(searchParamsMap.get(key), 'UTF-8');
            }
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:MDM_Account_Search_API'+restAPIURL);
        request.setMethod('GET');
        HTTPResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            returnResp = response.getBody();
        } else {
            returnresp = 'Error';
            GAM.CreateExceptionRecords('AccountSearchController', 'Exception in return code',String.valueof(response.getStatusCode()));
        }
        return returnResp;
    }
}