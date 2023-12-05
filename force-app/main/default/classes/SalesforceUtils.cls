/**
 * Salesforce related helper classes that may be shared across multiple functional areas
 * @author Austin Turner - ATG		
 * 
 */
public with sharing class SalesforceUtils {

	public static Set<Id> getIdSetFromList(List<SObject> items, String prop) {
		Set<Id> ids = new Set<Id>();
		for(SObject obj : items) {
			try {
				if(obj.get(prop) != null) {
					ids.add((Id)obj.get(prop));
				}
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
			}
		}
		return ids;
	}

	/**
	 * Get a list of string properties, this supports nested objects up to 1 level deep
	 * @param  items [description]
	 * @param  prop  [description]
	 * @return       [description]
	 */
	public static Set<String> getStringSetFromList(List<SObject> items, String prop) {
		Set<String> strings = new Set<String>();
		for(SObject obj : items) {
			try {
				/** If nested object, then attempt to get field one level down */
				if(prop.contains('.')) {
					List<String> fields = prop.split('\\.');
					SObject nestedObj = (SObject)obj.getSobject(fields[0]);
					if(nestedObj != null) {
						String val = (String)(nestedObj).get(fields[1]);
						if (val != null) {
							strings.add(val);
						}
					}
				} else if(obj.get(prop) != null) {
					strings.add((String)obj.get(prop));
				}
			} catch (Exception ex) { 
				System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
				System.debug('Ex message: ' + ex.getMessage());
			}
		}
		return strings;
	}

	public static Map<String, String> getMapFromSObjectListProp(List<SObject> items, String prop1, String prop2) {
		Map<String, String> propToPropMap = new Map<String, String>();
		for(SObject obj : items) {
			try {
				if(obj.get(prop1) != null && obj.get(prop2) != null) {
					propToPropMap.put((String)obj.get(prop1), (String)obj.get(prop2));
				}
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
			}
		}
		return propToPropMap;
	}

	/**
	 * For a given list of sobjects and a property field, which must be a date field,
	 * Find either the largest or smallest date of all returned fields based on the getLargest parameter
	 * @param  items      [description]
	 * @param  prop       [description]
	 * @param  getLargest [description]
	 * @return            [description]
	 */
	public static Datetime getLargestOrSmallesDatetime(List<SObject> items, String prop, Boolean getLargest) {
		Datetime output;
		for(SObject obj : items) {
			try {
				Datetime currDate = (Datetime)obj.get(prop);
				if(currDate != null) {
					if(output == null) {
						output = currDate;
					} else {
						if(getLargest) {
							output = output < currDate ? currDate : output;
						} else {
							output = output > currDate ? currDate : output;
						}
					}
				}
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
			}
		}
		return output;
	}

	/**
	 * Get a map from two props. prop1 must be a string, prop2 can be any data type
	 * @param  items [description]
	 * @param  prop1 [description]
	 * @param  prop2 [description]
	 * @return       [description]
	 */
	public static Map<String, Object> getMapFromSObjectListPropAny(List<SObject> items, String prop1, String prop2) {
		Map<String, Object> propToPropMap = new Map<String, Object>();
		for(SObject obj : items) {
			try {
				if(obj.get(prop1) != null && obj.get(prop2) != null) {
					propToPropMap.put((String)obj.get(prop1), obj.get(prop2));
				}
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
			}
		}
		return propToPropMap;
	}

	/**
	 * For a list of records, create a map of lists of the records based on matching values of a field
	 * e.x. given 10 records with a picklist myVal__c, group into a map where the key is the value from the picklist and the value is a list of records
	 * @param  items [description]
	 * @param  prop [String value of a property that resolves to a string]
	 * @param  keyForNull [Key to use for records with no value in prop. if keyForNull is null, then ignore these records]
	 * @return       [description]
	 */
	public static Map<String, List<SObject>> getMapListsFromProp(List<SObject> items, String prop, String keyForNull) {
		Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
		for(SObject obj : items) {
			try {
				Object keyObj = obj.get(prop);
				String key;
				if(keyObj == null) {
					if(keyForNull != null) {
						key = keyForNull;
					} else {
						continue;
					}
				} else {
					key = (String)keyObj;
				}
				if(!propToPropMap.containsKey(key)) {
					propToPropMap.put(key, new List<SObject>());
				}
				propToPropMap.get(key).add(obj);
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
			}
		}
		return propToPropMap;
	}

	/**
	 * Build map based on any property from records
	 * If the prop is null, then it will be ignored
	 * If multiple records have the same value, then they will be overwritten with last occurrence
	 * @param  items [description]
	 * @param  prop  [description]
	 * @return       [description]
	 */
	public static Map<String, SObject> getMapByProp(List<SObject> items, String prop) {
		Map<String, SObject> propToSObjMap = new Map<String, SObject>();
		for(SObject obj : items) {
			try {
				if(obj.get(prop) != null) {
					propToSObjMap.put((String)obj.get(prop), obj);
				}
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
			}
		}
		return propToSObjMap;
	}

	/**
	 * Plucks all records that have the value passed in
	 * @param  items [List of SObject]
	 * @param  field [API name of SObject field]
	 * @param  value [Value to match - all records with a field value = value will be returned]
	 * @return       [description]
	 */
	public static List<SObject> findRecsWithSpecificValue(List<SObject> items, String field, Object value) {
		List<SObject> changedObjects = new List<SObject>();
		for(SObject obj : items) {
			if(obj.get(field) == value) {
				try {
					changedObjects.add(obj);
				} catch (Exception ex) {
					System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
				}
			}
			
		}
		return changedObjects;
	}

	/**
	 * Determine if a specific field was modified
	 * @param  items       [description]
	 * @param  oldItemsMap [description]
	 * @param  field       [description]
	 * @return             [description]
	 */
	public static List<SObject> findRecsWithChangedValues(List<SObject> items, Map<Id, SObject> oldItemsMap, String field) {
		return findRecsWithChangedValues(items, oldItemsMap, new List<String>{field});
	}

	/**
	 * Determine if a specific fields were modified
	 * @param  items       [description]
	 * @param  oldItemsMap [description]
	 * @param  fields      [description]
	 * @return             [description]
	 */
	public static List<SObject> findRecsWithChangedValues(List<SObject> items, Map<Id, SObject> oldItemsMap, List<String> fields) {
		List<SObject> changedObjects = new List<SObject>();
		for(SObject obj : items) {
			for(String field : fields) {
				try {
					Object newObjValue = obj.get(field);
					Object oldObjValue = oldItemsMap.get((Id)obj.get('Id')).get(field);
					if(newObjValue != oldObjValue) {
						changedObjects.add(obj);
						break; // do not need to continue checking for this record
					}
				} catch (Exception ex) {
					System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
				}
			}
			
		}
		return changedObjects;
	}

	/**
	 * Given a newList and oldMap, return a list of objects where the specified field equalies the expectedNewValue AND the old
	 * record field does not equal expectedNewValue
	 * @param  items            List of new records
	 * @param  oldItemsMap      Map of old records
	 * @param  field            The field on the SObject to check
	 * @param  expectedNewValue The value that is desired on the new records. IF the value on the new record equals this value, then the old record is checked
	 *                          to see if the value is set differently
	 * @return                  List of eligible objects, or an empy list
	 */
	public static List<SObject> findRecsWithChangedValues(List<SObject> items, Map<Id, SObject> oldItemsMap, String field, Object expectedNewValue) {
		List<SObject> changedObjects = new List<SObject>();
		for(SObject obj : items) {
			try {
				Object newObjValue = obj.get(field);
				//System.debug('newObjValue ' + newObjValue);
				//System.debug('expectedNewValue ' + expectedNewValue);
				//System.debug('newObjValue == expectedNewValue: ' + (newObjValue == expectedNewValue));
				if(newObjValue == expectedNewValue) {
					Object oldObjValue = oldItemsMap.get((Id)obj.get('Id')).get(field);
					//System.debug('oldObjValue ' + oldObjValue);
					//System.debug('newObjValue != oldObjValue: ' + (newObjValue != oldObjValue));
					if(newObjValue != oldObjValue) {
						changedObjects.add(obj);
					}
				}
			} catch (Exception ex) {
				System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
			}
		}
		return changedObjects;
	}

	public static String prepareMultiSelectPicklistVals(List<String> vals) {
		return String.join(vals, '; ');
	}
	public static String prepareMultiSelectPicklistVals(Set<String> vals) {
		return prepareMultiSelectPicklistVals(new List<String>(vals));
	}

	public static Date dateTimeToDate(Datetime dt) {
		return Date.newInstance(dt.year(), dt.month(), dt.day());
	}

	public static Datetime dateToDateTime(Date d) {
		return Datetime.newInstance(d.year(), d.month(), d.day());
	}

	public static Date getFirstDayOfMonth(Date d) {
		return Date.newInstance(d.year(), d.month(), 1);
	}

	public static Date getLastDayOfMonth(Date d) {
		return Date.newInstance(d.year(), d.month()+1, 1).addDays(-1);
	}

	public static DateTime getFirstDayOfMonthDt(Date d) {
		return DateTime.newInstance(d.year(), d.month(), 1);
	}

	public static DateTime getLastDayOfMonthDt(Date d) {
		return DateTime.newInstance(d.year(), d.month()+1, 1).addDays(-1);
	}

	/**
	 * Get a list of string properties, this supports nested objects up to 1 level deep
	 * @param  items [description]
	 * @param  prop  [description]
	 * @return       [description]
	 */
	public static List<String> getFieldsFromFieldSet(String fieldSetName, String ObjectName) {
		List<String> fieldsList = new List<String>();
		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
		Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
		Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();

		Schema.FieldSet fieldSetObj = describeSObjectResultObj.fieldSets.getMap().get(fieldSetName);
		for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
			fieldsList.add(fieldSetMemberObj.getFieldPath());
		}

		return fieldsList; 
	} 
	 
	/**
	 * Parse the text for the merge fields using the field values from the record havving the passed in record Id
	 * @param  messageBody test to parse
	 * @param  recId  Id of the reocrd to be used to parse the merge fields
	 * @return        Map of parsed text
	 */
	public static Map<String,String> mergeText(String messageBody, Id recId) {
		pattern p = Pattern.compile('\\{[!a-zA-Z0-9_\\s\\.]*\\}');
		String objectName = '';
		Matcher m = p.matcher(messageBody);
		String fieldName = '';
		Map<String,Set<String>> fieldMap = new Map<String,Set<String>>();
		Map<String,String> templateBodyMap = new Map<String,String>();
		if(recId != null){
			objectName = recId.getSObjectType().getDescribe().getName();
			fieldMap.put(objectName,new Set<String>{'Id'});
		}
	
		Set<String> fieldApiSet = new Set<String>();
	
		//find merge fieds and create map of objectApi and fieldApi for dynamic soql
		while(m.find()){
			fieldName = messageBody.substring(m.start()+2,m.end()-1);
	
			//Spliting Object API and field API
			String[] apiArry = fieldName.split('\\.');
			if(apiArry[0] == objectName){
				if(fieldMap.containsKey(apiArry[0])){
					fieldMap.get(apiArry[0]).add(apiArry[1]);
				}
				else{
					fieldMap.put(apiArry[0],new Set<String>{apiArry[1]});
				}  
			}else{
				System.debug('objectName>>'+objectName);
				System.debug('fieldName>>'+fieldName);
				System.debug('fieldMap>>'+fieldMap);
				fieldMap.get(objectName).add(fieldName);
			}
		}
	
		//iterate throught map and create soql query String
		List<String> fieldList = new List<String>();        
	
		for(Set<String> fields : fieldMap.values()){
			for(String f: fields){
				fieldList.add(f);
			}
		}
	
		String queryString = ' SELECT ' + String.join( fieldList, ',' )+' FROM '+ objectName +' WHERE Id =:recId';
		System.debug('query>>'+queryString);
	
		Database.QueryLocator q = Database.getQueryLocator(queryString);
		Database.QueryLocatorIterator it =  q.iterator();
	
		while (it.hasNext()) {
			SObject obj = (SObject )it.next();
			System.debug('obj>>'+obj);
			for(String field : fieldList) {
				String fieldValue = '';
				if(field.contains('.')) {
					List<String> fieldPathList = field.split('.');
					SObject tmp = obj;

					for(Integer i = 0; i < fieldPathList.size(); i++) {
						if(i != fieldPathList.size() - 1) {
							tmp = obj.getSobject(fieldPathList[i]);
						} else {
							fieldValue = String.valueOf(tmp.get(fieldPathList[i]));
						}
					}
				} else {
					fieldValue = String.valueOf(obj.get(field));
				}
				
				if(String.isNotEmpty(fieldValue)){
					messageBody = messageBody.replace('{!' + objectName + '.' + field + '}', fieldValue).trim();
				}else{
					messageBody = messageBody.replace('{!' + objectName + '.' + field + '}','').trim();
				}
	
				if(obj.get('id') != null){
					templateBodyMap.put(String.valueOf(obj.get('id')),messageBody);
				}
			}
		}
	
		return templateBodyMap;
	}

}