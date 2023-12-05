/*
Class:          notifyMqlOnNewLead
@Author:        Chandana Gowda
@Created Date:  09-Oct-2019
@Description:   Class to notify BDM/CFR of New MQL on New Lead

Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Jira No         Description                                                                             Tag
**********************************************************************************************************************************************************
Chandana Gowda      17-May-22   SALESRT-13870   Addition of a new Territory User Role 'SDR' to help route One B trials                  <T01>  
**********************************************************************************************************************************************************
*/
public with sharing class notifyMqlOnNewLead{
    
    public static final Integer MAX_CHATTER_POST_LENGTH=5000;
    public static final String TEAMMEMBERROLE_BDM = 'BDM';
    public static final String TEAMMEMBERROLE_CFR = 'CFR';    
    public static final String TEAMMEMBERROLE_SDR = 'SDR'; //<T01>
    public final static string UNASSIGNED_USER = Label.Unassigned_User_Id;
    public final static string PARTNER_USER = Label.Partner_User_Id;
    public static Map<ID, ID> mapObjBDM = new map<Id, ID>();  // Map of Account and BDM users assigned to Account
    public static Map<ID, ID> mapObjCFR = new map<Id, Id>();  // Map of Account and CFR users assigned to Account
    public static Map<ID, ID> mapObjSDR = new map<Id, Id>();  // Map of Account and SDR users assigned to Account //<T01>
    public static List<sObject> lstObj = new List<sObject>();    
    //public static final String leadFieobjSetName='Notify_BDM_CFR';

    public static void init(List<Id> objIds){

        Map<Id,Id> mapAccToObj = new Map<Id,Id>();
        Map<Id,Id> mapTerritoryToAcc = new Map<Id,Id>();
        Map<Id,List<UserTerritory2Association>> mapTerritoryToUsers = new Map<Id,List<UserTerritory2Association>>();
        
        if(objIds[0].getSobjectType().getDescribe().getName()=='Lead'){
            lstObj = Database.query('SELECT Id,Name,Account__c,OwnerId,MQL_Source__c,Notify_CFR_Date__c,Owner_Notification__c,Chatter_Program__c FROM Lead WHERE Id IN :objIds');
            for(sObject obj:lstObj){
                mapAccToObj.put((Id)obj.get('Account__c'), obj.Id);
            }
        }
        else if(objIds[0].getSobjectType().getDescribe().getName()=='Contact'){
            lstObj = Database.query('SELECT Id,Name,AccountId,OwnerId,MQL_Source__c,Notify_CFR_Date__c,Owner_Notification__c,Chatter_Program__c FROM Contact WHERE Id IN :objIds');
            for(sObject obj:lstObj){
                mapAccToObj.put((Id)obj.get('AccountId'), obj.Id);
            }
        }
        
        List<ObjectTerritory2Association> lstObjTerrAssoc=[SELECT Territory2Id,ObjectId FROM ObjectTerritory2Association WHERE ObjectId IN :mapAccToObj.keySet() WITH SECURITY_ENFORCED];
        for(ObjectTerritory2Association obj:lstObjTerrAssoc){
            mapTerritoryToAcc.put(obj.Territory2Id,mapAccToObj.get(obj.ObjectId));
        }
        
        List<UserTerritory2Association> lstUserTerrAssoc=[SELECT UserId,RoleInTerritory2,Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN :mapTerritoryToAcc.keySet() AND RoleInTerritory2 IN ('BDM','CFR','SDR') WITH SECURITY_ENFORCED]; //<T01>: Added SDR
        for(UserTerritory2Association obj: lstUserTerrAssoc){
            List<UserTerritory2Association> lstObj= new List<UserTerritory2Association>();
            if(mapTerritoryToUsers.keySet().contains(obj.Territory2Id)){
                lstObj=mapTerritoryToUsers.get(obj.Territory2Id);
                lstObj.add(obj);
                mapTerritoryToUsers.put(obj.Territory2Id,lstObj);
            }
            else{
                lstObj.add(obj);
                mapTerritoryToUsers.put(obj.Territory2Id,lstObj);
            }
        }

        for(Id territoryId:mapTerritoryToUsers.keySet())
        {             
            for(UserTerritory2Association user:mapTerritoryToUsers.get(territoryId)){
                Set<Id>  setuserid= new set<Id>();
                //If BDM add it to mapObjBDM
                if(user.RoleInTerritory2 == TEAMMEMBERROLE_BDM){ 
                    mapObjBDM.put(mapTerritoryToAcc.get(territoryId),user.UserId );
                }
                //If CFR add it to mapObjCFR
                if(user.RoleInTerritory2 == TEAMMEMBERROLE_CFR){
                    mapObjCFR.put(mapTerritoryToAcc.get(territoryId),user.UserId );
                }
                //If SDR add it to mapObjSDR - <T01>
                if(user.RoleInTerritory2 == TEAMMEMBERROLE_SDR){
                    mapObjSDR.put(mapTerritoryToAcc.get(territoryId),user.UserId );
                }
            }            
        }
    }
    
    //Message to post on the chatter content
    public static String getpostContent(Sobject sobj){
        String msg='New MQL was generated.\nProgram Name: '+sobj.get('Chatter_Program__c')+'\n';
        return msg;
    }

    public static String getChatterFeedItem(String postContent,String mentions){
        String chatterMessageString = postContent+mentions;
        if(String.isNotBlank(chatterMessageString) && chatterMessageString.length()>MAX_CHATTER_POST_LENGTH){
            chatterMessageString = chatterMessageString.substring(0,MAX_CHATTER_POST_LENGTH-50);
            chatterMessageString += ' \\n' + '.........Chatter post content truncated due to 5000 max character limit';
        }
        return chatterMessageString;    
    }

    public static List<ConnectApi.BatchInput> getChatterFeed(Map<Id,String> mapObjIdtoMsg){
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for(Id objId:mapObjIdtoMsg.keySet()){
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = objId;                
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();                
            body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(mapObjIdtoMsg.get(objId));                   
            input.body = body;
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);                        
        }        
        return batchInputs;
    }

    public static String returnMentionFormat(Id userId){
        if(userId != null || !String.ISBLANK(userId)){
            return '{'+userId+'} ';
        }
        return '';
    }

    @InvocableMethod(label='Notify BDM/CFR of new Mql' description='Notifying BDM and/or CFR of new MQL on New Lead')
    public static void notifyOnNewMql(List<Id> objIds){
        
        Map<Id,String> mapObjIdtoMsg=new Map<Id,String>();
                
        init(objIds);

        for(sObject obj:lstObj){
            String mentions='';
            String postContent=getpostContent(obj);
            if(!mentions.contains(returnMentionFormat(mapObjBDM.get((Id)obj.Id))) && mapObjBDM.get((Id)obj.Id)!=null){
                mentions+= returnMentionFormat(mapObjBDM.get((Id)obj.Id));
            }
            if(!mentions.contains(returnMentionFormat((ID)obj.get('OwnerId'))) && (ID)obj.get('OwnerId')!=null && obj.get('OwnerId')!=UNASSIGNED_USER && obj.get('OwnerId')!=PARTNER_USER){              
                mentions+= returnMentionFormat((ID)obj.get('OwnerId'));
            }
            if(mentions!=null && !String.ISBLANK(mentions)){               
                mapObjIdtoMsg.put(obj.Id,getChatterFeedItem(postContent,mentions));
            }
        }

        List<ConnectApi.BatchInput> batchInputs = getChatterFeed(mapObjIdtoMsg);

        if(!Test.isRunningTest() && batchInputs!=null && batchInputs.size()>0){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }       
}