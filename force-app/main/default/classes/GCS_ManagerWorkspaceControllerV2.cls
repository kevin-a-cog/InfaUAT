/*
Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.    Tag     Description
*********************************************************************************************************************
balajip        03/01/2022       NA          T01     updated getCount method to mitigate SOQL injection 
Vignesh D      03/29/2023       I2RT-7838   T02     Added FTO_Today__c to the query & updated the key format
Isha Bansal    25/10/2023       I2RT-9220   T03     Added P0 flag to the results
*/
public with sharing class GCS_ManagerWorkspaceControllerV2 {

    //Query maps.
    public static Map<Integer, QueryWrapper> mapQueries = fetchQueries();

    /*
     Method Name : getUserConfigurationRecord
     Description : This method returns the Subscription record related to the current user.
     Parameters  : None
     Return Type : Object
     */
    @AuraEnabled(cacheable = false)
    public static GCS_Subscription__c getUserConfigurationRecord() {
        GCS_Subscription__c objResult;
        for(GCS_Subscription__c objExistingRecord : [SELECT Id, All_Queue_Columns__c, All_Queue_Columns_Raise_Hand__c, My_Queue_Columns_Raise_Hand__c, My_Queue_Columns__c, Queues__c, 
                Queues_Raise_Hand__c,Selected_Teams__c,My_Team_Columns_Raise_Hand__c, My_Team_Columns__c, Teams__c, Teams_Raise_Hand__c, All_GEMS_Columns__c, My_GEMS_Columns__c,
                All_Queue_Columns_Urgent_Request__c,My_Queue_Columns_Urgent_Request__c,Queues_Urgent_Request__c, Manager_Workspace_Columns_Order__c,
                Manager_Workspace_Autorefresh__c, Engineer_Workspace_Autorefresh__c FROM GCS_Subscription__c WHERE User__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED ORDER BY 
                LastModifiedDate DESC LIMIT 1]) {
            objResult = objExistingRecord; 
        }
        return objResult; 
    }

    /*
     Method Name : getSubscriptionWithoutCache
     Description : This method returns the Subscription record.
     Parameters  : None
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static List<GCS_Subscription__c> getSubscriptionWithoutCache() {
        List<GCS_Subscription__c> subscriptionList;
        try {
            subscriptionList = new List<GCS_Subscription__c> { setColumnOrderPreviouslySavedOnSubscriptionRecord(getUserConfigurationRecord()) };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return subscriptionList; 
    }

    /**
     * @description Method to get the subscription record to get the user's configuraion for the columns to 
     *              display for the fields and queues
     */
    @AuraEnabled(cacheable=true)
    public static List<GCS_Subscription__c> getSubscription() {
        List<GCS_Subscription__c> subscriptionList;
        try {
            subscriptionList = new List<GCS_Subscription__c> { setColumnOrderPreviouslySavedOnSubscriptionRecord(getUserConfigurationRecord()) };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return subscriptionList; 
    }
    
    /**
     * @description Method to fetch data for all queues sent from the lightning component
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, ResultWrapper>> getAllQueuesData(List<String> queueList, Boolean isRaiseHand, Boolean isUrgentRequest) {
       Map<String, Map<String, ResultWrapper>> queueToDataMap = new Map<String, Map<String, ResultWrapper>>();
        for(String queue : queueList) {
            queueToDataMap.put(queue, new Map<String, ResultWrapper>());
        }
        if(isRaiseHand) {

            // Fetch data for Raise Hand records
            getCountAggregated(4, queueList, queueToDataMap);
            getCountAggregated(5, queueList, queueToDataMap);
            getCountAggregated(6, queueList, queueToDataMap);
            getCountAggregated(38, queueList, queueToDataMap);
        }
        else if(isUrgentRequest) {
            
            // Fetch data for Urgent Request(Case Comment) records
            getCountAggregated(16, queueList, queueToDataMap); 
        } else {
            // Fetch data for Case records
            getCountAggregated(1, queueList, queueToDataMap);            
            getCountAggregated(7, queueList, queueToDataMap);  
            getCountAggregated(9, queueList, queueToDataMap); 
            getCountAggregated(17, queueList, queueToDataMap); 
            getCountAggregated(18, queueList, queueToDataMap); 
            getCountAggregated(19, queueList, queueToDataMap); 
            getCountAggregated(20, queueList, queueToDataMap); 
            getCountAggregated(21, queueList, queueToDataMap); 
            getCountAggregated(22, queueList, queueToDataMap); 
            getCountAggregated(39, queueList, queueToDataMap); //T03
        }        
        return queueToDataMap;
    }
    
    /**
     * @description Method to fetch data for all queues sent from the lightning component
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Map<String, ResultWrapper>> getAllQueuesDataRefresh(List<String> queueList, Boolean isRaiseHand, Boolean isUrgentRequest) {        
        return getAllQueuesData(queueList, isRaiseHand, isUrgentRequest);
    }

    /**
     * @description Method to fetch data for the users in the team of the logged in user
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Map<String, ResultWrapper>> getMyTeamDataRefresh(Boolean isRaiseHand) {
        return getMyTeamData(isRaiseHand);
    }
 
    /**
     * @description Method to fetch data for the users in the team of the logged in user
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, ResultWrapper>> getMyTeamData(Boolean isRaiseHand) {
        ResultWrapper objResult;
        Map<String, Map<String, ResultWrapper>> queueToDataMap = new Map<String, Map<String, ResultWrapper>>();
        List<String> lstIds = new List<String>();
        List<User> userList = new List<User>();
        userList = [SELECT Id, Name, FTO_Today__c FROM User WHERE ManagerId = :UserInfo.getUserId() AND IsActive = TRUE LIMIT 1000]; //<T02>

        if(!userList.isEmpty()) {
            for(User userRecord : userList) {
                lstIds.add(userRecord.Id);
                queueToDataMap.put(userRecord.Name, new Map<String, ResultWrapper>());
                objResult = new ResultWrapper();
                objResult.intQuery = 0;
                objResult.intResult = 0;
                queueToDataMap.get(userRecord.Name).put('User>>Id' + '~' +userRecord.Id + '~' +userRecord.FTO_Today__c, objResult); //<T02>
            }
            if(isRaiseHand) {
                // Fetch data for Raise Hand records
                getCountAggregated(4, lstIds, queueToDataMap);
                getCountAggregated(5, lstIds, queueToDataMap);
                getCountAggregated(6, lstIds, queueToDataMap);
                getCountAggregated(38, lstIds, queueToDataMap);
            } else {

                // Fetch data for Raise Hand records
                getCountAggregated(2, lstIds, queueToDataMap);
                getCountAggregated(8, lstIds, queueToDataMap);
                getCountAggregated(10, lstIds, queueToDataMap);
                getCountAggregated(11, lstIds, queueToDataMap);
                getCountAggregated(12, lstIds, queueToDataMap);
                getCountAggregated(13, lstIds, queueToDataMap);
                getCountAggregated(14, lstIds, queueToDataMap);
                getCountAggregated(3, lstIds, queueToDataMap);
                getCountAggregated(15, lstIds, queueToDataMap);
                getCountAggregated(34, lstIds, queueToDataMap);
                getCountAggregated(35, lstIds, queueToDataMap);
                getCountAggregated(37, lstIds, queueToDataMap);
                getCountAggregated(40, lstIds, queueToDataMap); //T03
            }
            getLoginStatus(lstIds, queueToDataMap);
        }
        return queueToDataMap;
    }

    /**
     * @description Method to fetch data for the users in all of the teams sent by lightning component
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Map<String, Map<String, ResultWrapper>>> getAllTeamDataRefresh(String teams, Boolean isRaiseHand) {
        return getAllTeamData(teams, isRaiseHand);
    }

    /**
     * @description Method to fetch data for the users in all of the teams sent by lightning component
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, Map<String, ResultWrapper>>> getAllTeamData(String teams, Boolean isRaiseHand) {
        ResultWrapper objResult;
        List<String> lstIds = new List<String>();
        List<String> teamsList = new List<String>();
        teamsList = teams.split(';');
        Map<String, Map<String, Map<String, ResultWrapper>>> allDataMap = new Map<String, Map<String, Map<String, ResultWrapper>>>();
        Map<String, Map<String, Map<String, ResultWrapper>>> finalMap= new Map<String, Map<String, Map<String, ResultWrapper>>>();
        Map<String, Map<String, ResultWrapper>> queueToDataMap = new Map<String, Map<String, ResultWrapper>>();
        List<User> userList = new List<User>();
        userList = [SELECT GCS_Team__c, Id, Name, FTO_Today__c FROM User WHERE GCS_Team__c IN :teamsList AND IsActive = TRUE LIMIT 1000]; //<T02>
        Map<String, Set<String>> teamMemberMap = new Map<String, Set<String>>();
        if(!userList.isEmpty()) {
            for(User userRecord : userList) {
                lstIds.add(userRecord.Id);
                if(!teamMemberMap.containsKey(userRecord.GCS_Team__c)) {
                    teamMemberMap.put(userRecord.GCS_Team__c, new Set<String>());
                }
                teamMemberMap.get(userRecord.GCS_Team__c).add(userRecord.Name);
                queueToDataMap.put(userRecord.Name, new Map<String, ResultWrapper>());
                objResult = new ResultWrapper();
                objResult.intQuery = -1;
                objResult.intResult = 0;
                queueToDataMap.get(userRecord.Name).put('User>>Id' + '~' +userRecord.Id + '~' +userRecord.FTO_Today__c, objResult); //<T02>
            }
            if(isRaiseHand) {
                // Fetch data for Raise Hand records
                getCountAggregated(4, lstIds, queueToDataMap);
                getCountAggregated(5, lstIds, queueToDataMap);
                getCountAggregated(6, lstIds, queueToDataMap);
                getCountAggregated(38, lstIds, queueToDataMap);
            } else {
                // Fetch data for Raise Hand records
                getCountAggregated(2, lstIds, queueToDataMap);
                getCountAggregated(8, lstIds, queueToDataMap);
                getCountAggregated(10, lstIds, queueToDataMap);
                getCountAggregated(11, lstIds, queueToDataMap);
                getCountAggregated(12, lstIds, queueToDataMap);
                getCountAggregated(13, lstIds, queueToDataMap);
                getCountAggregated(23, lstIds, queueToDataMap);
                getCountAggregated(36, lstIds, queueToDataMap);
                getCountAggregated(37, lstIds, queueToDataMap);
                getCountAggregated(3, lstIds, queueToDataMap);
                getCountAggregated(40, lstIds, queueToDataMap); //T03
                
            }
            getLoginStatus(lstIds, queueToDataMap);
            for(String team: teamMemberMap.keyset()) {
                for(String mem : teamMemberMap.get(team)) {
                    if(!allDataMap.containsKey(team)) {
                        allDataMap.put(team, new Map<String, Map<String, ResultWrapper>>());
                    }
                    allDataMap.get(team).put(mem, queueToDataMap.get(mem));
                }
            }
        }
        if(teamsList != null) {
            for(string team :teamslist){
                if(allDataMap.get(team) != null) {
                    finalMap.put(team,allDataMap.get(team));
                } else {
                    finalMap.put(team, new Map<String, Map<String, ResultWrapper>>());
                }
            }
        }
        return finalMap;
    }

    /**
     * @description Method to fetch login status for each user if they're logged in
     */
    @AuraEnabled(cacheable=true)
    public static void getLoginStatus(List<Id> userIdSet, Map<String, Map<String, ResultWrapper>> queueToDataMap) {
        ResultWrapper objResult;
        Boolean issandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Set<String> loginTypeval = new Set<String>();
        
        String orgname = URL.getSalesforceBaseUrl().toExternalForm();

        if((issandbox && orgname.contains('infa--uat')) || !issandbox ){            
                loginTypeval.add('SAML Sfdc Initiated SSO');                       
                loginTypeval.add('SAML Idp Initiated SSO');                       
        } else {
            loginTypeval.add('Application');                       
        }

        for(AuthSession ase : [SELECT Id, Users.Name FROM AuthSession WHERE Users.IsActive = TRUE AND UsersId IN :userIdSet AND SessionType = 'UI' AND LoginType IN :loginTypeval]) {
            if(!queueToDataMap.get(ase.Users.Name).containsKey('LoginStatus')) {
                objResult = new ResultWrapper();
                objResult.intQuery = -2;
                objResult.intResult = 1;
                queueToDataMap.get(ase.Users.Name).put('LoginStatus', objResult);
            }
        }
    }

    /**
     * @description Method to fetch List View Id for the queues on Case/Raise_Hand__c object
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Id> getListViewId(List<String> queueList, Boolean isRaiseHand, Boolean isUrgentRequest, Boolean isEngagement) {
        Map<String, Id> queueListViewMap = new Map<String, Id>();
        try {
            if(isRaiseHand != null && isRaiseHand) {
                for(ListView lv : [SELECT Id, Name FROM ListVIew WHERE Name IN :queueList AND SobjectType = 'Raise_Hand__c']) {
                    queueListViewMap.put(lv.Name, lv.Id);
                }
            } 
            else if(isUrgentRequest != null && isUrgentRequest) {
                for(ListView lv : [SELECT Id, Name FROM ListVIew WHERE Name IN :queueList AND SobjectType = 'Case_Comment__c']) {
                    queueListViewMap.put(lv.Name, lv.Id);
                }
            }
            else if(isEngagement != null && isEngagement) {
                for(ListView lv : [SELECT Id, Name FROM ListVIew WHERE Name IN :queueList AND SobjectType = 'Engagement__c']) {
                    queueListViewMap.put(lv.Name, lv.Id);
                }
            }
            else {
                for(ListView lv : [SELECT Id, Name FROM ListVIew WHERE Name IN :queueList AND SobjectType = 'Case']) {
                    queueListViewMap.put(lv.Name, lv.Id);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return queueListViewMap;
    }

    /**
    * @description Method to fetch data for the users in the team of the logged in user
    */
    @AuraEnabled(cacheable=false)
    public static  Map<String, ResultWrapper> getGEMSDataRefresh(Boolean myGems) {
        return getGEMSData(myGems);
    }

     /**
     * @description Method to fetch data for the users in the team of the logged in user
     */
    @AuraEnabled(cacheable=true)
    public static  Map<String, ResultWrapper> getGEMSData(Boolean myGems) {
        QueryWrapper objRule;
        List<String> lstIds = new List<String>();
        Map<String, ResultWrapper> gemsToDataMap = new  Map<String, ResultWrapper>();
        lstIds.add(UserInfo.getUserId());

        //Now we execute the queries.
        if(myGems) {
            getCountAggregated(24, lstIds, gemsToDataMap);
            getCountAggregated(26, lstIds, gemsToDataMap);
            getCountAggregated(28, lstIds, gemsToDataMap);
            getCountAggregated(30, lstIds, gemsToDataMap);
            getCountAggregated(32, lstIds, gemsToDataMap);
        } else {
            getCountAggregated(25, lstIds, gemsToDataMap);
            getCountAggregated(27, lstIds, gemsToDataMap);
            getCountAggregated(29, lstIds, gemsToDataMap);
            getCountAggregated(31, lstIds, gemsToDataMap);
            getCountAggregated(33, lstIds, gemsToDataMap);
        }
        return gemsToDataMap;
    }

    /*
     Method Name : getSortingSaved
     Description : This method saves the current sorting selected.
     Parameters  : String, called from getSortingSaved, strField Field name.
                   String, called from getSortingSaved, strJSON JSON data.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getSortingSaved(String strField, String strJSON) {
        String strCurrentUserId = UserInfo.getUserId();
        GCS_Subscription__c objRecord = getUserConfigurationRecord();

        //If we received data.
        if(String.isNotBlank(strField)) {

            //First we set the data.
            if(objRecord == null) {
                objRecord = new GCS_Subscription__c();
                objRecord.User__c = strCurrentUserId;
            }
            objRecord.put(strField, strJSON);

            //Now we upsert the records.
            upsert objRecord;
        }
    }

    /*
     Method Name : getAutorefreshSaved
     Description : This method saves the current sorting selected.
     Parameters  : String, called from getAutorefreshSaved, strField Field name.
                   Boolean, called from getAutorefreshSaved, boolActive Autorefresh active.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getAutorefreshSaved(String strField, Boolean boolActive) {
        String strCurrentUserId = UserInfo.getUserId();
        GCS_Subscription__c objRecord = getUserConfigurationRecord();

        //If we received data.
        if(String.isNotBlank(strField)) {

            //First we set the data.
            if(objRecord == null) {
                objRecord = new GCS_Subscription__c();
                objRecord.User__c = strCurrentUserId;
            }
            objRecord.put(strField, boolActive);

            //Now we upsert the records.
            upsert objRecord;
        }
    }

    /*
     Method Name : getSortingPreviouslySaved
     Description : This method returns the latest sorting selected by the user, from the given field.
     Parameters  : String, called from getSortingPreviouslySaved, strField Field name.
     Return Type : String
     */
    @AuraEnabled(cacheable = false)
    public static String getSortingPreviouslySaved(String strField) {
        String strResult = '{}';
        String strCurrentUserId = UserInfo.getUserId();

        //We look for existing records.
        if(String.isNotBlank(strField)) {
            for(GCS_Subscription__c objExistingRecord : Database.query('SELECT ' + String.escapeSingleQuotes(strField) + ' FROM GCS_Subscription__c WHERE User__c = :strCurrentUserId WITH SECURITY_ENFORCED ' + 
                    'ORDER BY LastModifiedDate DESC LIMIT 1')) {
                strResult = (String) objExistingRecord.get(strField);
            }
        }
        return strResult;
    }

    /**
     * @description Method to fetch List View Id for the queues on Case/Raise_Hand__c object
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Id> getAllListViewId(List<String> queueList, Boolean isRaiseHand, Boolean isUrgentRequest, Boolean isEngagement) {
        Map<String, Id> queueListViewMap = new Map<String, Id>();
        try {
            for(ListView lv : [SELECT Id, Name, SobjectType FROM ListVIew WHERE Name IN :queueList AND (SobjectType = 'Raise_Hand__c' OR SobjectType = 'Case_Comment__c' OR 
                    SobjectType = 'Engagement__c' OR SobjectType = 'Case')]) {
                queueListViewMap.put(lv.Name + '...' + lv.SobjectType, lv.Id);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return queueListViewMap;
    }

    /*
     Method Name : getColumnOrderSaved
     Description : This method saves the current order selected.
     Parameters  : String, called from getColumnOrderSaved, strTable Field name.
                   String, called from getColumnOrderSaved, lstJSON Order.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getColumnOrderSaved(String strTable, List<String> lstJSON) {
        String strCurrentUserId = UserInfo.getUserId();
        GCS_Subscription__c objRecord = getUserConfigurationRecord();
        Map<String, List<String>> mapData;

        //If we received data.
        if(String.isNotBlank(strTable)) {

            //We set the initial data.
            if(objRecord == null) {
                objRecord = new GCS_Subscription__c();
                objRecord.User__c = strCurrentUserId;
            }
            if(String.isNotBlank(objRecord.Manager_Workspace_Columns_Order__c)) {
                mapData = (Map<String, List<String>>) JSON.deserialize(objRecord.Manager_Workspace_Columns_Order__c, Map<String, List<String>>.class);
            } else {
                mapData = new Map<String, List<String>>();
            }
            mapData.put(strTable, lstJSON);
            objRecord.Manager_Workspace_Columns_Order__c = JSON.serialize(mapData, true);

            //Now we upsert the records.
            upsert objRecord;
        }
    }

    /*
     Method Name : getColumnOrderPreviouslySaved
     Description : This method returns the latest order selected by the user, from the given table.
     Parameters  : String, called from getColumnOrderPreviouslySaved, strTable Table.
     Return Type : List
     */
    @AuraEnabled(cacheable = false)
    public static List<String> getColumnOrderPreviouslySaved(String strTable) {
        String strCurrentUserId = UserInfo.getUserId();
        GCS_Subscription__c objExistingRecord = getUserConfigurationRecord();
        List<String> lstResults = new List<String>();
        Map<String, List<String>> mapData;

        //We look for existing records.
        if(String.isNotBlank(strTable) && objExistingRecord != null && String.isNotBlank(objExistingRecord.Manager_Workspace_Columns_Order__c)) {
            mapData = (Map<String, List<String>>) JSON.deserialize(objExistingRecord.Manager_Workspace_Columns_Order__c, Map<String, List<String>>.class);
            lstResults = mapData.get(strTable);
        }
        return lstResults;
    }

    /*
     Method Name : setColumnOrderPreviouslySavedOnSubscriptionRecord
     Description : This method returns the latest order selected by the user, on the given Subscription records.
     Parameters  : Object, called from setColumnOrderPreviouslySavedOnSubscriptionRecord, objSubscriptionRecord Subscription record.
     Return Type : Object
     */
    @AuraEnabled(cacheable = false)
    public static GCS_Subscription__c setColumnOrderPreviouslySavedOnSubscriptionRecord(GCS_Subscription__c objSubscriptionRecord) {
        Map<String, List<String>> mapData;

        //We look for existing records.
        if(objSubscriptionRecord != null && String.isNotBlank(objSubscriptionRecord.Manager_Workspace_Columns_Order__c)) {
            mapData = (Map<String, List<String>>) JSON.deserialize(objSubscriptionRecord.Manager_Workspace_Columns_Order__c, Map<String, List<String>>.class);

            //Now we iterate over the map and set the list of fields.
            for(String strField : mapData.keySet()) {
                objSubscriptionRecord.put(strField, String.join(mapData.get(strField), ';'));
            }
        }
        return objSubscriptionRecord;
    }

    /*
     Method Name : getRecordAssigned
     Description : This method assigned the given record ids to the provided new owner id.
     Parameters  : Id, called from getRecordAssigned, idNewOwner New owner id.
                   List, called from getRecordAssigned, lstRecordIds Record Ids.
     Return Type : Object
     */
    @AuraEnabled(cacheable = false)
    public static void getRecordAssigned(Id idNewOwner, List<Id> lstRecordIds) {
        Id idFinalNewOrder = idNewOwner;
        SObject objRecord;
        Schema.SObjectType objDynamicObject;
        List<SObject> lstRecords = new List<SObject>();

        //If we received a record id.
        if(lstRecordIds != null && !lstRecordIds.isEmpty()) {

            //If we didn't receive a new owner, we assume the current one is the new owner.
            if(idFinalNewOrder == null) {
                idFinalNewOrder = UserInfo.getUserId();
            }

            //Now we update the records.
            for(Id idRecord : lstRecordIds) {
                objRecord = Schema.getGlobalDescribe().get(idRecord.getSObjectType().getDescribe().getName()).newSobject();
                objRecord.put('Id', idRecord);
                objRecord.put('OwnerId', idFinalNewOrder);
                lstRecords.add(objRecord);
            }
            update lstRecords;
        }
    }

    /*
     Method Name : getCountAggregated
     Description : This method returns the count of a given predefined query.
     Parameters  : Integer, called from getCountAggregated, intQuery Predefined query id.
                   List, called from getCountAggregated, lstIds Record Ids.
                   Map, called from getCountAggregated, mapResults Aggregated results.
     Return Type : Object
     */
    @AuraEnabled(cacheable = false)
    public static void getCountAggregated(Integer intQuery, List<String> lstIds, Map<String, ResultWrapper> mapResults) {
        getCount(true, intQuery, null, null, null, lstIds, null, mapResults);
    }

    /*
     Method Name : getCountAggregated
     Description : This method returns the count of a given predefined query.
     Parameters  : Integer, called from getCountAggregated, intQuery Predefined query id.
                   List, called from getCountAggregated, lstIds Record Ids.
                   Map, called from getCountAggregated, mapResults Aggregated results.
     Return Type : Object
     */
    @AuraEnabled(cacheable = false)
    public static void getCountAggregated(Integer intQuery, List<String> lstIds, Map<String, Map<String, ResultWrapper>> mapResults) {
        getCount(true, intQuery, null, null, null, lstIds, mapResults, null);
    }

    /*
     Method Name : getCount
     Description : This method returns the count or record of a given predefined query.
     Parameters  : Boolean, called from getCount, boolAggregateResults Defines if the query must be aggregated or not.
                   Integer, called from getCount, intQuery Predefined query id.
                   String, called from getCount, strFieldSetName Field Set Name of the normal query.
                   String, called from getCount, strFilterValue Value used to filter normal query.
                   List, called from getCount, lstIds Record Ids.
                   Map, called from getCount, mapResults Aggregated results.
                   Map, called from getCount, mapResults Aggregated results, simplified.
     Return Type : Object
     */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getCount(Boolean boolAggregateResults, Integer intQuery, String strFieldSetName, String strFilterValue, String strVariableOne, List<String> lstIds, 
            Map<String, Map<String, ResultWrapper>> mapResults, Map<String, ResultWrapper> mapResultsSimplified) {
        Integer intGroupValue;
        String strGroupKey;
        String strAdditionalWhereClause = '';
        ResultWrapper objResult;
        QueryWrapper objQuery;
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

        //If we received data.        
        if(intQuery != null) {
            objQuery = mapQueries.get(intQuery);
                        
            //If the query is valid.
            if(objQuery != null) {

                //Now we check if we need to aggregate the results.
                if(boolAggregateResults != null && boolAggregateResults) {
                    for(AggregateResult objRecord : Database.query('SELECT ' + objQuery.strReturnedFieldsAggregate + ' FROM ' + objQuery.strObject + ' WHERE ' + 
                            objQuery.strWhereConditions + ' GROUP BY ' + objQuery.strGroupFields)) {  

                        //If the Group Key is custom, we set it directly.
                        if(objQuery.boolIsCustomGroupKey != null && objQuery.boolIsCustomGroupKey) {
                            strGroupKey = objQuery.strGroupKey;
                        } else {

                            //Otherwise, we extract the field from the results.
                            strGroupKey = String.valueOf(objRecord.get(objQuery.strGroupKey));
                        }

                        //If the developer requested to limit the count.
                        if(objQuery.objLimits != null) {

                            //If the condition is GREATER THAN.
                            if(objQuery.objLimits.intLimitGreaterThan != null && Integer.valueOf(objRecord.get(objQuery.strGroupValue)) > objQuery.objLimits.intLimitGreaterThan) {
                                intGroupValue = objQuery.objLimits.intLimitCount;
                            }
                        } else {
                            intGroupValue = Integer.valueOf(objRecord.get(objQuery.strGroupValue));                            
                        }

                        //Now we save the result.
                        objResult = new ResultWrapper();
                        objResult.intQuery = intQuery;
                        objResult.intResult = intGroupValue;

                        //Now we decide where to send the response.
                        if(mapResults != null) {                            
                            mapResults.get(String.valueOf(objRecord.get(objQuery.strKey))).put(strGroupKey, objResult);                            
                        } else if(mapResultsSimplified != null) {
                            mapResultsSimplified.put(strGroupKey, objResult);                           
                        }                        
                    }
                } else {

                    //Now we get the table details.
                    objDataTable.strObjectName = objQuery.strObject;
                    objDataTable.strFielSetName = String.escapeSingleQuotes(strFieldSetName);//T01
                    objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

                    //If the Column Key is not custom, we include the additional where clause.
                    if(objQuery.boolIsCustomGroupKey != null && !objQuery.boolIsCustomGroupKey) {
                        strAdditionalWhereClause = ' AND ' + objQuery.strGroupKey + ' = \'' + String.escapeSingleQuotes(strFilterValue) + '\''; //T01
                    }

                    //Now we prepare the response.
                    objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + objQuery.strObject + 
                            ' WHERE (' + objQuery.strWhereConditions + ') ' + strAdditionalWhereClause + ' LIMIT 1000');
                }               
            }
        }
        return  objDataTable;
    }

    /*
     Method Name : fetchQueries
     Description : This method returns the queries to be used by all the methods on this class.
     Parameters  : None
     Return Type : Map
     */
    @AuraEnabled(cacheable = false)
    public static Map<Integer, QueryWrapper> fetchQueries() { 
        Id idRecordTypeEngagementSupportEscalation = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
        QueryWrapper objQuery;
        LimitWrapper objLimits;
        Map<Integer, QueryWrapper> mapQueries = new Map<Integer, QueryWrapper>();
        for(Manager_Workspace_Query__mdt objRecord : [SELECT Id__c, Is_Custom_Group_Key__c, Returned_Fields_Aggregate__c, Field_Set_Name__c, Object__c, Where_Conditions__c, 
                Group_Fields__c, Key__c, Group_Key__c, Group_Value__c, Limit_Count__c, Limit_Greater_Than__c FROM Manager_Workspace_Query__mdt WHERE Active__c = TRUE LIMIT 1000]) {
            
            //We first check the limits.
            objLimits = null;
            if(objRecord.Limit_Count__c != null || objRecord.Limit_Greater_Than__c != null) {
                objLimits = new LimitWrapper(Integer.valueOf(objRecord.Limit_Count__c), Integer.valueOf(objRecord.Limit_Greater_Than__c));
            }

            //Now we prepare the query.
            objQuery = new QueryWrapper(objRecord.Is_Custom_Group_Key__c, objRecord.Returned_Fields_Aggregate__c, objRecord.Field_Set_Name__c, objRecord.Object__c, 
                    objRecord.Where_Conditions__c, objRecord.Group_Fields__c, objRecord.Key__c, objRecord.Group_Key__c, objRecord.Group_Value__c, objLimits);

            //We replace any placeholder.
            if(objQuery.strWhereConditions.contains('{RecordType.Engagement.Support Escalation}')) {
                objQuery.strWhereConditions = objQuery.strWhereConditions.replace('{RecordType.Engagement.Support Escalation}', idRecordTypeEngagementSupportEscalation);
            }
            
            //Now we save it in the map.
            mapQueries.put(Integer.valueOf(objRecord.Id__c), objQuery);           
        }
        return mapQueries;
    }

    //Wrapper class for queries.
    public class QueryWrapper {

        //Public variables.
        @AuraEnabled
        public Boolean boolIsCustomGroupKey {get; set;}
        @AuraEnabled
        public Integer intLimitCount {get; set;}
        @AuraEnabled
        public Integer intLimitGreaterThan {get; set;}
        @AuraEnabled
        public String strReturnedFieldsAggregate {get; set;}
        @AuraEnabled
        public String strFieldSetName {get; set;}
        @AuraEnabled
        public String strObject {get; set;}
        @AuraEnabled
        public String strWhereConditions {get; set;}
        @AuraEnabled
        public String strGroupFields {get; set;}
        @AuraEnabled
        public String strKey {get; set;}
        @AuraEnabled
        public String strGroupKey {get; set;}
        @AuraEnabled
        public String strGroupValue {get; set;}
        @AuraEnabled
        public LimitWrapper objLimits {get; set;}

        /*
         Method Name : QueryWrapper
         Description : Constructor of the class.
         Parameters  : Boolean, called from QueryWrapper, boolIsCustomGroupKey Determines if the Group Key is custom.
                       String, called from QueryWrapper, strReturnedFieldsAggregate Selected fields for aggregation.
                       String, called from QueryWrapper, strFieldSetName Selected fields for normal query.
                       String, called from QueryWrapper, strObject Object to be queried.
                       String, called from QueryWrapper, strWhereConditions WHERE conditions.
                       String, called from QueryWrapper, strGroupFields GROUP BY fields.
                       String, called from QueryWrapper, strKey Group Key.
                       String, called from QueryWrapper, strGroupKey Column.
                       String, called from QueryWrapper, strGroupValue Value.
                       Object, called from QueryWrapper, objLimits Limits.
         Return Type : None
         */
        public QueryWrapper(Boolean boolIsCustomGroupKey, String strReturnedFieldsAggregate, String strFieldSetName, String strObject, String strWhereConditions, 
                String strGroupFields, String strKey, String strGroupKey, String strGroupValue, LimitWrapper objLimits) {
            this.boolIsCustomGroupKey = boolIsCustomGroupKey;
            this.strReturnedFieldsAggregate = strReturnedFieldsAggregate;
            this.strFieldSetName = strFieldSetName;
            this.strObject = strObject;
            this.strWhereConditions = strWhereConditions;
            this.strGroupFields = strGroupFields;
            this.strKey = strKey;
            this.strGroupKey = strGroupKey;
            this.strGroupValue = strGroupValue;
            this.objLimits = objLimits;
        }
    }

    //Wrapper class for limits.
    public class LimitWrapper {

        //Public variables.
        @AuraEnabled
        public Integer intLimitCount {get; set;}
        @AuraEnabled
        public Integer intLimitGreaterThan {get; set;}

        /*
         Method Name : LimitWrapper
         Description : Constructor of the class.
         Parameters  : Integer, called from LimitWrapper, intLimitCount Default value if the condition is met.
                       Integer, called from LimitWrapper, intLimitGreaterThan If the liit is greater than, then the default is applied.
         Return Type : None
         */
        public LimitWrapper(Integer intLimitCount, Integer intLimitGreaterThan) {
            this.intLimitCount = intLimitCount;
            this.intLimitGreaterThan = intLimitGreaterThan;
        }
    }

    //Wrapper class for results.
    public class ResultWrapper {

        //Public variables.
        @AuraEnabled
        public Integer intQuery {get; set;}
        @AuraEnabled
        public Integer intResult {get; set;}
    }
}