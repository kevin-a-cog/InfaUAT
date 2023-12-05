/*
 * Name			:	LookupSearchHelper
 * Author		:	Deva M
 * Created Date	: 	08/02/2021
 * Description	:	This class used to search user and queue for lookup records

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					TagLookupSearchResult
 **********************************************************************************************************
 Deva M					08/006/2021		N/A				Initial version.			N/A
 */
public with sharing class LookupSearchHelper {
    /*
    Method Name : lookupCombinedSearch
    Description : This method returns the list of LookupSearchResult results
    Parameters	 : String searchTerm, search string     
                   List<String> , list of selected records 
                   String sObjectApiName , obj api name                
    Return Type : list of LookupSearchResult records.
    */
   @AuraEnabled(cacheable=true)
   public static List<LookupSearchResult> lookupCombinedSearch(String searchTerm, List<String> selectedIds) {
       // Prepare query parameters
       searchTerm += '*';
       
       // Set for GroupIds (QueueId)
       Set<Id> setOfGroupIds = new Set<Id>();

       // Adding GroupIds (QueueId) from QueueSobject to above Set
       for(QueueSobject q : [SELECT QueueId FROM QueueSobject WHERE SobjectType ='Plan__c']) {
           setOfGroupIds.add(q.QueueId);
       }

       // Execute search query
       List<List<SObject>> searchResults = [
           FIND :searchTerm
           IN NAME FIELDS
           RETURNING
               User (Id, Name, Title WHERE Id NOT IN :selectedIds AND UserType='Standard'),
               Group (Id, Name WHERE Type = 'Queue' AND Id IN :setOfGroupIds AND Id NOT IN :selectedIds)
           LIMIT 10
       ];

       // Prepare results
       List<LookupSearchResult> results = new List<LookupSearchResult>();

       // Extract Users & convert them into LookupSearchResult
       String userIcon = 'standard:user';
       User[] users = (List<User>) searchResults[0];
       for (User u : users) {
           String subtitle = u.Title == null ? '' : + u.Title;
           results.add(new LookupSearchResult(u.Id, 'User', userIcon, u.Name, subtitle));
       }
       
       // Extract Groups & convert them into LookupSearchResult
       String icon = 'standard:orders';
       Group[] groups = (List<Group>) searchResults[1];
       for (Group g : groups) {
           results.add(new LookupSearchResult(g.Id, 'Group', icon, g.Name, ''));
       }

       // Sort all results on title
       results.sort();

       return results;
   }
   
    /*
    Method Name : lookupCombinedSearch
    Description : This method returns the list of LookupSearchResult results
    Parameters	 : String searchTerm, search string     
                   List<String> , list of selected records 
                   String sObjectApiName , obj api name                
    Return Type : list of LookupSearchResult records.
    */
   @AuraEnabled(cacheable=true)
   public static List<LookupSearchResult> lookupQueueSearch(String searchTerm, List<String> selectedIds) {
       // Prepare query parameters
       searchTerm += '*';

       // Set for GroupIds (QueueId)
       Set<Id> setOfGroupIds = new Set<Id>();

       // Adding GroupIds (QueueId) from QueueSobject to above Set
       for(QueueSobject q : [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Plan__c']) {
           setOfGroupIds.add(q.QueueId);
       }

       // Execute search query
       List<List<SObject>> searchResults = [
           FIND :searchTerm
           IN NAME FIELDS
           RETURNING
               Group(Id, Name WHERE Type = 'Queue' AND Id IN :setOfGroupIds AND Id NOT IN :selectedIds)
           LIMIT 10
       ];

       // Prepare results
       List<LookupSearchResult> results = new List<LookupSearchResult>();

       // Extract Groups & convert them into LookupSearchResult
       String icon = 'standard:orders';
       Group[] groups = (List<Group>) searchResults[0];
       for (Group g : groups) {
           results.add(new LookupSearchResult(g.Id, 'Group', icon, g.Name, ''));
       }

       // Sort all results on title
       results.sort();

       return results;
   }
}