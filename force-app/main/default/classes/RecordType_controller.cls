/*
Class:          RecordType_controller 
@Author:        Chandana Gowda  
@Created Date:  19/4/2019
@Description:   Controller class for RecordType_Rendering Lightning component
                This controller holds method for fetching the Record types for a paticular object and also for defaulting the value of 
				Account related Plan to plan on Related.
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
    Chandana Gowda        01-20-2020      AR-1042            Querying Account LOB from plan                       T1
************************************************************************************************************************************
*/

public class RecordType_controller{
    
    public static globalApexManager GAM = new globalApexManager();
    
    /*Method to fetch the account related to the plan.
    * @param Name - Id planId
    * @throws exception -n/a
    * @return Id----Account Id
    */ 
    @AuraEnabled
    public static Map<String,Id> FetchAccData(Id planId){
        
        Map<String,Id> res = new Map<String,Id>();
        String SOQL='Select Account__c,Line_of_Business__c from Plan__c where id= :planId'; //<T1/>
        GAM.CreateLogs('FetchAccData','SOQL:','Plan SOQL',SOQL);
        SObject Rec=Database.query(SOQL);
        res.put('Account__c', (Id)Rec.get('Account__c'));
        res.put('Line_of_Business__c', (Id)Rec.get('Line_of_Business__c'));
        try {
            GAM.InsertDebugLogs();  
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('FetchAccData', e.GetMessage(), Rec.Id);
        }
        
        return res;
    }
    
    /*Method to fetch the Record types given the object name.
    * @param Name - String objectName
    * @throws exception -n/a
    * @return Map<Id, String>----Map of record type id and record type name
    */
    @AuraEnabled 
    public static Map<Id, String> fetchRecordTypeValues(String objectName){

        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        Map<Id, String> recordtypemap = new Map<Id, String>();

        for(RecordTypeInfo rt : recordtypes){
            if (rt.isAvailable()&& !rt.isMaster())
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }
        return recordtypemap;
    }
    
    /*Method to fetch the Record types given the object name.
    * @param Name - String objectName
    * @throws exception -n/a
    * @return List<RecordType>----List of available record types
    */
    @AuraEnabled(Cacheable = true)
    public static List<RecordType> fetchRecordTypeDetails(String objectName){
        List<RecordType> recordtypelist = new List<RecordType>();
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        List<Id> recordtypeset = new List<Id>();
        Id defaultRecordTypeId;

        for(RecordTypeInfo rt : recordtypes){
            if (rt.isAvailable() && !rt.isMaster() && rt.isDefaultRecordTypeMapping())
                defaultRecordTypeId = rt.getRecordTypeId();
            if (rt.isAvailable() && !rt.isMaster())
                recordtypeset.add(rt.getRecordTypeId());
        }
        Map<Id, RecordType> recordtypemap = new Map<Id, RecordType>([Select Id,Name,Description From RecordType where Id IN: recordtypeset order by name]);
        recordtypelist.add(recordtypemap.get(defaultRecordTypeId));
        for(RecordType rt : recordtypemap.values()){
            if(rt.Id != defaultRecordTypeId){
                recordtypelist.add(rt);
            }
        }
        return recordtypelist;
    }
}