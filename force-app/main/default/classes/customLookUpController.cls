/*
        Class:          customLookUpController 
        @Author:        Kiran Gudadinni
        @Created Date:  10/22/2018
        @Description:   Controller for the CustomLookup kightning component
*/

public class customLookUpController {
    public static globalApexManager GAM = new globalApexManager();
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String recordId) {
        //system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        String recordTypeName = 'Deal_Registration';
        //Get the Account Id from partner Relationship record 
        List <Partner_Relationship__c > lstOpptyPartner = [Select Id, Partner_Account__c,Partner_Role__c From Partner_Relationship__c where Id =: recordId];
        List < sObject > returnList = new List < sObject > ();
        Id accId = lstOpptyPartner[0].Partner_Account__c ;
        String leadType = lstOpptyPartner[0].Partner_Role__c;
        // Query all the DR's from the Acccount where the DR needs to be associated to Oppty Partner and display in descending  order
        //Replaced PartnerAccountId with Partner_Account__c - Kiran G
        String sQuery =  'select id, Name ,Deal_Registration_Number__c, Deal_Registration_Type__c, Account__r.Name, Deal_Registration_Name__c, RecordType.DeveloperName from ' + String.escapeSingleQuotes(ObjectName) + ' where Deal_Registration_Number__c LIKE: searchKey AND RecordType.DeveloperName =: recordTypeName AND Deal_Registration_Type__c =: leadType AND Partner_Account__c =:  accId ORDER BY Deal_Registration_Number__c DESC '  ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        //Create a list to be returned and displayed at component level 
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        GAM.InsertDebugLogs();
        
        return returnList;
        
    }
    
    // Associate the selected DR to the Oppty Partner
    @AuraEnabled
    public static String DRValue(String dealNumber, string prRecordId){
        //Query the OpptyPartner record and update the DR Id selected on the Oppty partner record 
        List <Partner_Relationship__c > lstOpptyPartner = [Select Id, Partner_Account__c From Partner_Relationship__c where Id =: prRecordId];
        lstOpptyPartner[0].Deal_Registration__c = dealNumber;  
        string error = 'SUCCESS';             
        if(lstOpptyPartner.size() > 0){
            Database.SaveResult[] updateOpptyPartner = Database.update(lstOpptyPartner, false);
            
            for (Database.SaveResult sr : updateOpptyPartner) {
                if (sr.isSuccess()){
                    return error;                    
                }
                else {
                    error = '';
                    for(Database.Error err : sr.getErrors()){                    
                        error = error + err.getMessage();
                    }
                    return error;
                }          
            } 
        }
        return error;
    }           
}