/**
 * BSD 3-Clause License
 * Copyright (c) 2020, Justin Lyon
 * All rights reserved.
 *
 ****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
Isha Bansal     30/06/2023  I2RT-8234   T01    handled duplicates in title and subtitle field
 */
public with sharing class GlobalLookupController { 

	@AuraEnabled
	public static String getOneRecordById(Searchable searcher, Id recordId) {
		List<String> expr = new List<String>();
		
		expr.add('SELECT ');		
		expr.add(joinfields(searcher.fields));// T01 call method to join fields and handle duplicates
		//expr.add(String.join(searcher.fields, ', '));
		expr.add('FROM ' + String.escapeSingleQuotes(searcher.objectName));
		expr.add('WHERE Id = \'' + recordId + '\'');
		expr.add('LIMIT 1');

		String queryString = String.join(expr, ' ');
		System.debug('query string: ' + queryString);
		return JSON.serialize(Database.query(queryString));
	}

	@AuraEnabled(cacheable=true)
	public static String getRecent(Searchable searcher) {		
		Set<Id> recentIds = new Set<Id>();
		for(RecentlyViewed rv : queryRecentByType(searcher.objectName)) {
			recentIds.add(rv.Id);
		}

		List<String> expr = new List<String>();
		expr.add('SELECT ');
		expr.add(joinfields(searcher.fields));//T01 call method to join fields
		// + String.join(searcher.fields, ', '));
		expr.add('FROM ' + String.escapeSingleQuotes(searcher.objectName));
		expr.add('WHERE Id IN (\'' + String.join(new List<Id>(recentIds), '\', \'') + '\')');
		return JSON.serialize(Database.query(String.join(expr, ' ')));
	}

	@AuraEnabled(cacheable=true)
	public static String getRecords(Searchable searcher) {
		String find = 'FIND \'' + String.escapeSingleQuotes(searcher.searchTerm) + '*\' IN ALL FIELDS';
		String returning = 'RETURNING ' + getReturning(searcher.objectName, searcher.fields);
		String limitter = 'LIMIT ' + 5;
		String query = find + ' ' + returning + ' ' + limitter;
		system.debug('--search sosl query---'+query);//T01
		return JSON.serialize(System.Search.query(query));
	}

	private static String getReturning(String objectName, List<String> fields) {
		List<String> returning = new List<String>();
		String objectWithFields = objectName + (fields.isEmpty() ? '' : joinReturnFields(fields));		
		returning.add(objectWithFields);
		return String.join(returning, ', ');
	}

	private static String joinReturnFields(List<String> fields) {
		//return ' (' + String.escapeSingleQuotes(String.join(fields, ', ')) + ')';
		return ' (' + String.escapeSingleQuotes(joinfields(fields)) + ')';//T01
		
	}

	private static List<RecentlyViewed> queryRecentByType(String objectName) {
		return [
			SELECT Id
			FROM RecentlyViewed
			WHERE Type = :objectName
			LIMIT 5];
	}


	private static string joinfields(List<String> fields){//T01
		Set<String> fieldSet=new Set<String>();
				String fieldStr='';
				system.debug('--searcher.fields in lookupaura--'+fields);
				for(String field:fields){
					if(String.isNotBlank(field)&&!fieldSet.contains(field)){
						fieldStr+=String.valueOf(field) + ',';
						fieldSet.add(String.valueOf(field));
					}					
				}//for loop ends here
				if(fieldStr.endsWith(',')) {
					fieldStr = fieldStr.substring(0, fieldStr.length() - 1);
				}
				system.debug('--fieldStr--'+fieldStr);
				return fieldStr;
			}

	public class Searchable {

		@AuraEnabled
		public String searchTerm {get;set;}
		@AuraEnabled
		public String objectName {get;set;}
		@AuraEnabled
		public List<String> fields {get;set;}
	}
}