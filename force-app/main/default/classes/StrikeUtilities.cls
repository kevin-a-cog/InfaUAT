/*********************************************************************************
Class Name      : StrikeLookupController 
Description     : Utility class for strike_looup lightning component 
Created By      : Deloitte               
Created Date    : April 04, 2018    
Modification Log:
---------------------------------------------------------------------------------- 
Developer                   Date                   Description
-----------------------------------------------------------------------------------            
Deloitte Consulting         April 04, 2018        Initial Version
*********************************************************************************/
public with sharing class StrikeUtilities {
    private static FINAL String MY_NAMESPACE = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'StrikeUtilities' LIMIT 1].NamespacePrefix;
    public static FINAL String NAMESPACE = String.isBlank(MY_NAMESPACE) ? '' : MY_NAMESPACE;
    public static FINAL String NAMESPACE_API = String.isBlank(MY_NAMESPACE) ? '' : MY_NAMESPACE + '__';

    /*********************************************************************************
    Method Name     : getRecentRecords
    Description     : Returns JSON for the SObject 
    Return Type     : String
	Parameter		: myObject
    *********************************************************************************/
    public static String serializeWithoutNamespace(Object myObject) {
        return JSON.serialize(myObject).replaceAll(StrikeUtilities.NAMESPACE_API, '');
    }

    /*********************************************************************************
    Method Name     : convertObjectToMap
    Description     : Returns Map of field, value for the sobject
    Return Type     : Map<String, Object>
	Parameter		: myObject
    *********************************************************************************/
    public static Map<String, Object> convertObjectToMap(Object myObject) {
        return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(myObject));
    }
}