public class installBaseLookupController {

    public static globalApexManager GAM = new globalApexManager();
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String recordId) {

        String searchKey = '%'+searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        String sQuery = 'Select Id, Name from '+ObjectName + ' where Name LIKE: searchKey ' ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        //Create a list to be returned and displayed at component level 
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        GAM.InsertDebugLogs();
        return returnList;
    }         
}