/*
Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.    Tag     Description
*********************************************************************************************************************
NA             NA               UTOPIA      NA      Initial Version
Vignesh D      07/28/22         I2RT-6864   T01     SOQL injection fixed
*/
public class CustomLookupLwcController {
    @AuraEnabled(cacheable=true)
   public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
       List < sObject > returnList = new List < sObject > ();
       string sWildCardText = '%' + String.escapeSingleQuotes(searchKey) + '%'; //<T01>
       string sQuery = 'Select Id,Name From ' + String.escapeSingleQuotes(sObjectApiName) + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
       
       if(String.escapeSingleQuotes(sObjectApiName) == 'User'){
           string userType = userinfo.getusertype();
           sQuery = 'Select Id,Name From ' + String.escapeSingleQuotes(sObjectApiName) + ' Where Name Like : sWildCardText and userType =:usertype order by createdDate DESC LIMIT 5';
       
       }
       system.debug('@@--sQuery--->>'+sQuery);
       for (sObject obj: database.query(sQuery)) {
           returnList.add(obj);
       }
       return returnList;
   }
   @AuraEnabled(cacheable=true)
   public static List<sObject> search(String searchTerm, string myObject, String filter , String filterVariable) {
       system.debug('searchTerm -->'+searchTerm);
       system.debug('myObject -->'+myObject);
       system.debug('filter -->'+filter);
       system.debug('filterVariable -->'+filterVariable);
       String SearchKey = '%'+String.escapeSingleQuotes(searchTerm)+'%';
        String objName = String.escapeSingleQuotes(myObject);
        String filterField = String.escapeSingleQuotes(filterVariable);
       if(filter != null && filter != ''){
            String query = 'Select Id, Name from '+objName+' Where Name Like :SearchKey AND '+ filterField+' = :filter';
          
           system.debug('query -->'+query);
           List<sObject> lookUpList = Database.query(query);
           System.debug('lookUpList -->'+lookUpList);
           return lookUpList;
       }
       else{
           return null;
       }
   }
}