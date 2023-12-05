/*
Author Name   : Akhilesh Soni
Class Name    : TrackerUtility
Created Date  : Nov 11, 2020
Description   : helper class for tracking any object custom criteria via process builder

Change History
***************************************************************************************************
ModifiedBy          Date          Description                                   Jira No.       Tag
***************************************************************************************************
Sandeep             11/24/2021    Handle delete, insert operation               I2RT-4839      T01
Narpavi Prabu       4/04/2023     Capture the old and new value                 AR-3141        T02
Vignesh Divakaran   11/7/2023     Added exception handling logic                I2RT-8841      T03
Vignesh Divakaran   11/7/2023     Combined conditions to remove duplicate code  I2RT-8841      T04
*/

public class TrackerUtility { 
    /*Method to return Sobject Name*/
    public static string getSobjectName(Id sObjectId){
        return sObjectId.getSObjectType().getDescribe().getName();
    }
    /*Method to query metadata records based on object name*/
    public static list<Tracker_Config__mdt> getMetaData(String sObjectAPI){
        return [SELECT Id,sObjectAPI__c,Filter_Criteria__c,Parent_Field_API__c,Entry_Criteria__c,Exit_Criteria__c,Trigger_Context1__c,Trigger_Context2__c,
                Description__c,DeveloperName,Field_Name_New__c,Record_Type__c
                FROM Tracker_Config__mdt    
                WHERE IsActive__c = true
                AND sObjectAPI__c =:sObjectAPI];
    }
   
    /*Method to evaulate the records using dynamic script engine and return true if the criteia configured in meta data with record passed to this*/
    private static Boolean evaluateCondition(SObject record, String condition){
        Boolean returnValue = false;
        Map<String, Object> context = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));    
        try{
            ScriptEngine scriptEngine = ScriptEngine.getInstance();
            Object result = scriptEngine.eval(condition, context);
            System.debug('result = ' + result);
            returnValue = (Boolean)result;
        }catch(Exception ex){             system.debug('@Developer  evaluateCondition --> Error Message'+ex.getMessage() + ex.getStackTraceString());            new globalApexManager().CreateLogs('TrackerUtility - evaluateCondition',ex.getMessage());
        }        
        return returnValue;
    }
    
    //Create Tracker instance and return the record
    private static Tracked_Details__c getTrackerRecord(String sObjectAPI, String sObjectId,Tracker_Config__mdt tc){
        Tracked_Details__c oTD = new Tracked_Details__c();
        oTD.sObjectAPI__c = sObjectAPI;
        oTD.RecordId__c = sObjectId;
        oTD.Tracker_Config_Record_id__c = tc.Id;
        //Deva : added the null check for filter criteria field
        if(String.isNotBlank(tc.Filter_Criteria__c)){            oTD.Filter_Criteria__c = tc.Filter_Criteria__c;
        }
        oTD.Entry_Criteria__c = tc.Entry_Criteria__c;
        oTD.Exit_Criteria__c = tc.Exit_Criteria__c;
        oTD.Description__c = tc.Description__c;
        oTD.Enter_Timestamp__c = system.now();
        oTD.Tracker_Config_Name__c = tc.DeveloperName;
        
        //  
        //
        return oTD;
    } 
    /*Method to accept the new map instance record and create tracker record if the condition matches.*/
    public static void track(Map<Id, SObject> newMap){
        
        //Return if the newmap instance is null
        if(newMap.isEmpty())
            return;
        try{
            //Get the api name of sobject based in the id
            String sObjectAPI = getSobjectName(new List<Id>(newMap.keySet())[0]);
            //Get the metadata records configured for the sobject        
            List<Tracker_Config__mdt>  lstTrackerConfig = getMetaData(sObjectAPI);
            //To Map the Existing Records
            Map<String,Tracked_Details__c> mapTD_Existing = new Map<String,Tracked_Details__c>();
            //List used to insert new records
            List<Tracked_Details__c> lstTD_New = new List<Tracked_Details__c>();
            //List used to update existing records
            List<Tracked_Details__c> lstTD_Update = new List<Tracked_Details__c>();
            //Query Exisitng records if any for the new Map Instance
            for(Tracked_Details__c td : [SELECT Id, sObjectAPI__c,RecordId__c,Description__c,
                                         Filter_Criteria__c,Entry_Criteria__c,Exit_Criteria__c,
                                         Enter_Timestamp__c,Exit_Timestamp__c
                                         FROM Tracked_Details__c
                                         WHERE RecordId__c = :newMap.keySet()
                                         AND Exit_Timestamp__c = null
                                         Order By CreatedDate Desc
                                         Limit:Limits.getLimitQueryRows()]){
                                             if(td.Filter_Criteria__c != null){
                                                 mapTD_Existing.put(td.Filter_Criteria__c + '-' + td.Entry_Criteria__c + '-' + td.Exit_Criteria__c,td);
                                             }
                                             else{
                                                 mapTD_Existing.put(td.Entry_Criteria__c + '-' + td.Exit_Criteria__c,td);
                                             }
                                         }
            //Iterate new Map records
            for(SObject newRecord:newMap.Values()){
                system.debug('newRecord'+json.serializePretty(newRecord));
                Sobject oldRecord;
                for(Tracker_Config__mdt tc:lstTrackerConfig){
                    String sKey;
                    if(tc.Filter_Criteria__c != null){                        sKey = tc.Filter_Criteria__c + '-' + tc.Entry_Criteria__c  + '-' + tc.Exit_Criteria__c;
                    }
                    else{
                        sKey = tc.Entry_Criteria__c + '-' + tc.Exit_Criteria__c;
                    } 
                    //Boolean varaible to store if the recoed already available
                    Boolean recordAvailable=mapTD_Existing.containsKey(sKey);
                    //Entry Critera Matched and tracker record in system then create a record
                    if(tc.Entry_Criteria__c != null && evaluateCondition(newRecord,tc.Entry_Criteria__c) && !recordAvailable){
                        Tracked_Details__c td = getTrackerRecord(sObjectAPI,newRecord.Id,tc);
                        lstTD_New.add(td);       
                    }
                    //Entry Critera Matched and tracker record already been there
                    // with both entry and exit time stamp populated create andother tracker record
                    if(tc.Entry_Criteria__c != null && evaluateCondition(newRecord,tc.Entry_Criteria__c) && recordAvailable && mapTD_Existing.get(sKey).Exit_Timestamp__c!=null){
                        Tracked_Details__c td = getTrackerRecord(sObjectAPI,newRecord.Id,tc);                        lstTD_New.add(td);       
                    }
                    //If Entry critera Matched and record already created and exit timestamp blank then update tracker record 
                    if(tc.Entry_Criteria__c != null && evaluateCondition(newRecord,tc.Entry_Criteria__c) && recordAvailable && mapTD_Existing.get(sKey).Exit_Timestamp__c==null){
                        Tracked_Details__c oTD = mapTD_Existing.get(sKey);
                        oTD.Exit_Timestamp__c = system.now();
                        lstTD_Update.add(oTD);       
                    }
                    //If exit criteria matched and tracker record available and exit time stamp blank then update tracker record
                    if(tc.Exit_Criteria__c != null && evaluateCondition(newRecord,tc.Exit_Criteria__c) && recordAvailable && mapTD_Existing.get(sKey).Exit_Timestamp__c==null){
                        Tracked_Details__c oTD = mapTD_Existing.get(sKey); oTD.Exit_Timestamp__c = system.now();                        lstTD_Update.add(oTD);       
                    }
                    //If both Entry and exit criteria matched and exit timestamp blank then update tracker record
                    if(tc.Entry_Criteria__c != null && evaluateCondition(newRecord,tc.Entry_Criteria__c) && recordAvailable && mapTD_Existing.get(sKey).Exit_Timestamp__c==null && evaluateCondition(newRecord,tc.Exit_Criteria__c)
                      ){
                          Tracked_Details__c oTD = mapTD_Existing.get(sKey); oTD.Exit_Timestamp__c = system.now();
                          lstTD_Update.add(oTD);       
                      } 
                    
                    //-------------------------------------------Start of T01--------------------------
                    // Validate if trigger context is populated 
                    system.debug('context:'+trigger.isinsert);
                     if((tc.Trigger_Context1__c == 'after' && tc.Trigger_Context2__c == 'insert' && trigger.isafter && trigger.isinsert) || (trigger.isbefore && trigger.isdelete && tc.Trigger_Context1__c == 'before' && tc.Trigger_Context2__c == 'delete')){                         
                         system.debug('tc'+json.serialize(tc));
                         Tracked_Details__c td = getTrackerRecord(sObjectAPI,newRecord.Id,tc);
                           td.OwnerId = String.valueof(newRecord.get('UserId'));
                          if(tc.Parent_Field_API__c != null && newRecord.get(tc.Parent_Field_API__c) != null){                             
                           td.Description__c = tc.Description__c + ', Associated Parent Record:' + newRecord.get(tc.Parent_Field_API__c) + ', Skill Name: ' + newRecord.get('Profile_Skill_Name__c') + '. Owner of the record will be user that got removed/Inserted on ProfileskillUser';
                         
                         }                  
                         lstTD_New.add(td); 
                     }                  
                     //-------------------------------------------End of T01--------------------------
                         
                }            
                
            }
            //Update or insert records insert based on the size
            
            if(lstTD_New.size() > 0){
                insert lstTD_New;
            }
            if(lstTD_Update.size() > 0){
                update lstTD_Update;
            }    
        }
        catch(Exception ex){
            system.debug('@Developer --> Error Message'+ex.getMessage()+ex.getStackTraceString());
            new globalApexManager().CreateLogs('TrackerUtility - Track',ex.getMessage());
        }   
    }

    //<T02>
    public static void trackChanges(Map<Id,sObject> oldMap, Map<Id, SObject> newMap) {
        /* Retrieve custom metadata records for the sObject*/
        String sObjectAPI = getSobjectName(new List<Id>(newMap.keySet())[0]);
        Id recordId =new List<Id>(newMap.keySet())[0];
        String queryString = 'SELECT RecordTypeId FROM '+sObjectAPI+' WHERE Id =:recordId' ;
        SObject recordTypeInfo = Database.query(queryString);
        String recordTypename = Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().getRecordTypeInfosById().get((Id)recordTypeInfo.get('RecordTypeId')).getDeveloperName();
        system.debug('recordTypename'+recordTypename);
        List<Tracker_Config__mdt>  fieldTracker = getMetaData(sObjectAPI);

        /*fields to track*/
        System.debug('Metadata'+fieldTracker);
        Set<String> fieldsToTrack = new Set<String>();
        String mtdrecordtype ;
        for(Tracker_Config__mdt track : fieldTracker ){
            if(track.Field_Name_New__c!=null){
                String fieldName = track.Field_Name_New__c;
                String[] subfieldNames = fieldName.split(',');
                for(String s :subfieldNames)
                fieldsToTrack.add(s);
                
            }
            if(track.Record_Type__c!=null)
            {
                mtdrecordtype = track.Record_Type__c;             
            }
           
        }

        /* To store the field history records */
        List<Tracked_Details__c> changedFieldHistoryList = new List<Tracked_Details__c>();
        if(oldMap != null && !newMap.isEmpty())
        {
            for (SObject newRecord : newMap.Values()) {
            SObject oldRecord = oldMap.get(newRecord.Id);
            for (String field : fieldsToTrack) {
                if (newRecord.get(field) != oldRecord.get(field)  ) {
                    if(mtdrecordtype == null || (mtdrecordtype != null && recordTypename == mtdrecordtype)) //<T04>
                    {
                        Tracked_Details__c fieldHistory = new Tracked_Details__c();
                        fieldHistory.Object_Name__c = sObjectAPI;
                        fieldHistory.Parent_Record_Id__c = newRecord.Id;               
                        fieldHistory.Field_Name__c = (String)Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
                        fieldHistory.Old_Value__c = String.valueOf(oldRecord.get(field));
                        fieldHistory.New_Value__c = String.valueOf(newRecord.get(field));
                        changedFieldHistoryList.add(fieldHistory);
                    }
                }
            }
            }
        }
        if(oldMap == null && !newMap.isEmpty())
        {
            for (SObject newRecord : newMap.Values()) {
                SObject oldRecord = null;
    
                for (String field : fieldsToTrack) { 
                    if(String.valueOf(newRecord.get(field)) !=null ){  
                        if( mtdrecordtype != null && recordTypename == mtdrecordtype)
                        {
                            Tracked_Details__c fieldHistory = new Tracked_Details__c();
                            fieldHistory.Object_Name__c = sObjectAPI;
                            fieldHistory.Parent_Record_Id__c = newRecord.Id;
                            fieldHistory.Field_Name__c =  (String)Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
                            fieldHistory.Old_Value__c = null;
                            fieldHistory.New_Value__c = String.valueOf(newRecord.get(field));
                            changedFieldHistoryList.add(fieldHistory);
                        }   
                        else if(mtdrecordtype == null)
                        {
                            Tracked_Details__c fieldHistory = new Tracked_Details__c();
                            fieldHistory.Object_Name__c = sObjectAPI;
                            fieldHistory.Parent_Record_Id__c = newRecord.Id;
                            fieldHistory.Field_Name__c =  (String)Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
                            fieldHistory.Old_Value__c = null;
                            fieldHistory.New_Value__c = String.valueOf(newRecord.get(field));
                            changedFieldHistoryList.add(fieldHistory); 
                        }    
                      
                    }                  
                }
                }
        }
        try{ //<T03>
            insert changedFieldHistoryList;
        }
        catch(Exception ex){
            new globalApexManager().CreateExceptionRecords('TrackerUtility.trackChanges', 'Error while creating tracked details records ', ex.getMessage());
        }
    }   
    //</T02>
    
    
    /*Deva - As suggestd by Venkatesh Kotapati commented the code as it not required as above logic implemented for Tracker fucntionlity on trigger
    @InvocableMethod(label='Track' description='Tracks criteria based entry & exit timestamps' category = 'sObject')
    public static void track(List<Id> lstSObjId){
        System.debug('@Developer -->track:' );
        System.debug('@Developer --> lstSObjId :' + lstSObjId);
        
        Id sObjectId = lstSObjId[0];
        System.debug('@Developer --> sObjectId :' + sObjectId);
        
        String sObjectAPI = sObjectId.getSObjectType().getDescribe().getName();
        System.debug('@Developer --> sObjectAPI :' + sObjectAPI);
        
        list<Tracker_Config__mdt> lstTrackerConfig = [SELECT Id,sObjectAPI__c,Filter_Criteria__c,Entry_Criteria__c,Exit_Criteria__c,
                                                      Description__c 
                                                      FROM Tracker_Config__mdt  
                                                      WHERE IsActive__c = true
                                                      AND sObjectAPI__c =:sObjectAPI
                                                     ];
        System.debug('@Developer --> lstTrackerConfig :' + lstTrackerConfig);
        
        if(lstTrackerConfig.size() > 0){
            map<String,Tracked_Details__c> mapTD_Existing = new map<String,Tracked_Details__c>();
            list<Tracked_Details__c> lstTD_New = new list<Tracked_Details__c>();
            list<Tracked_Details__c> lstTD_Update = new list<Tracked_Details__c>();
            
            for(Tracked_Details__c td : [SELECT Id, sObjectAPI__c,RecordId__c,Description__c,
                                         Filter_Criteria__c,Entry_Criteria__c,Exit_Criteria__c,
                                         Enter_Timestamp__c,Exit_Timestamp__c
                                         FROM Tracked_Details__c
                                         WHERE RecordId__c = :sObjectId
                                         AND Exit_Timestamp__c = null
                                         Order By CreatedDate Desc
                                         Limit 50000])
            {
                if(td.Filter_Criteria__c != null){
                    mapTD_Existing.put(td.Filter_Criteria__c + '-' + td.Entry_Criteria__c + '-' + td.Exit_Criteria__c,td);
                }
                else{
                    mapTD_Existing.put(td.Entry_Criteria__c + '-' + td.Exit_Criteria__c,td);
                }
            }
            
            for(Tracker_Config__mdt tc: lstTrackerConfig){
                String sKey;
                if(tc.Filter_Criteria__c != null){
                    sKey = tc.Filter_Criteria__c + '-' + tc.Entry_Criteria__c  + '-' + tc.Exit_Criteria__c;
                }
                else{
                    sKey = tc.Entry_Criteria__c + '-' + tc.Exit_Criteria__c;
                }
                
                //When entry criteria already exists only check for exit criteria
                if(mapTD_Existing.containsKey(sKey)){
                    String sSOQL_OBJ = '';
                    sSOQL_OBJ = ' SELECT Id ' ;
                    sSOQL_OBJ += ' FROM ' + sObjectAPI ;
                    sSOQL_OBJ += ' WHERE Id = :sObjectId ';
                    sSOQL_OBJ += ' AND ' + tc.Exit_Criteria__c;
                    System.debug('@Developer --> sSOQL_OBJ>Exit Criteria :' + sSOQL_OBJ);
                    
                    Tracked_Details__c oTD = mapTD_Existing.get(sKey);
                    for(SObject so : database.query(sSOQL_OBJ)){
                        oTD.Exit_Timestamp__c = system.now();
                        lstTD_Update.add(oTD);
                    }    
                }
                //When entry criteria doesnot exists verify entry criteria match and create if found
                else{
                    String sSOQL_OBJ = '';
                    sSOQL_OBJ = ' SELECT Id ' ;
                    sSOQL_OBJ += ' FROM ' + sObjectAPI ;
                    sSOQL_OBJ += ' WHERE Id = :sObjectId ';
                    if(tc.Filter_Criteria__c != null){
                        sSOQL_OBJ += ' AND ' + tc.Filter_Criteria__c;    
                    }
                    sSOQL_OBJ += ' AND ' + tc.Entry_Criteria__c;
                    System.debug('@Developer --> sSOQL_OBJ>Entry Criteria :' + sSOQL_OBJ);
                    
                    Tracked_Details__c oTD = new Tracked_Details__c();
                    oTD.sObjectAPI__c = sObjectAPI;
                    oTD.RecordId__c = sObjectId;
                    oTD.Filter_Criteria__c = tc.Filter_Criteria__c;
                    oTD.Entry_Criteria__c = tc.Entry_Criteria__c;
                    oTD.Exit_Criteria__c = tc.Exit_Criteria__c;
                    oTD.Description__c = tc.Description__c;
                    
                    for(SObject so : database.query(sSOQL_OBJ)){
                        oTD.Enter_Timestamp__c = system.now();
                        lstTD_New.add(oTD);
                    } 
                }
            }
            
            try{
                System.debug('@Developer --> lstTD_New :' + lstTD_New);
                if(lstTD_New.size() > 0){
                    insert lstTD_New;
                }
                
                System.debug('@Developer --> lstTD_Update :' + lstTD_Update);
                if(lstTD_Update.size() > 0){
                    update lstTD_Update;
                }    
            }
            catch(Exception ex){
                System.debug('@Developer --> Exception :' + ex.getStackTraceString());
                System.debug('@Developer --> Exception :' + ex.getMessage());
            }
        }
    }
    */
}