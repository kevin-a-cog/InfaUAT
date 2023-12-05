/**
 * @description       : 
 * @author            : Venky K
 * @group             : 
 * @last modified on  : 08-01-2021
 * @last modified by  : Venky K

Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.    Tag     Description
*********************************************************************************************************************
NA             NA               UTOPIA      NA      Initial Version
Vignesh D      07/28/22         I2RT-6864   T01     SOQL injection fixed
balajip        09/19/22         I2RT-7099   T02     added attribute addMembers
*/
public with sharing class MSTeamsServiceController {

    /**
    *————————————————————————————————————————————————————
    * @Description: HTTP Post callout to Microsoft flows and creates group chat with members passed as input. MS Flow calls API to update group chatid
    * 
    *————————————————————————————————————————————————————
    * @param    sobjectid (to hold the request id), responsefield (field api name to update the group chat id), 
    *            relationshipname (to retrieve team members), memberemailfield(email field of team member),
    *           calloutname (to hold what type of callout)
    * @return   String 
    *————————————————————————————————————————————————————
    **/

    @AuraEnabled
    public static String doCallout_instantmeeting(Id sobjectid, String responsefield, String relationshipname, String memberemailfield, String calloutname,String eventSubject){
        System.debug('@Developer -->doCallout_CreateGroupChat:' );
        System.debug('@Developer --> sobjectId :' + sobjectid);
        String teamMeetingEndpoint;
        if(sobjectid == null || string.isblank(calloutname)){
            throw new MSTeamException('Missing Information');
        }
        
        for(MS_Teams__mdt msteam : [Select Label,EndPoint__c,Type__c from MS_Teams__mdt where type__c = :calloutname]){            
                teamMeetingEndpoint = msteam.EndPoint__c;            
        }
        
        if(string.isblank(teamMeetingEndpoint)){
            throw new MSTeamException('Endpoint is not configured for this call');
        }
        
        String objType = sobjectid.getSObjectType().getDescribe().getName();      	

        
        String dynamicsoql = 'SELECT Id,' + String.escapeSingleQuotes(responsefield) +', (Select '+String.escapeSingleQuotes(memberemailfield) + ' From ' + String.escapeSingleQuotes(relationshipname) + ') From ' + String.escapeSingleQuotes(objType) + ' where Id = ' +' \'' + String.escapeSingleQuotes(sobjectid) + '\''; //<T01>
        List<Sobject> sobjlist = Database.query(dynamicsoql);
		
        //String teamMeetingEndpoint = 'https://prod-136.westus.logic.azure.com:443/workflows/2009574d61ef4239a308241cd9116ae1/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=sOzbFtZcoJTuWMj574ICKl6EYQ4oWv59MDwquAegVnQ';

        
             
        ImeetingInputPayload omeetingInputPayload = new ImeetingInputPayload();
        for(sObject sobj : sobjlist)
        {
            omeetingInputPayload.requestid = sobjectid;
            omeetingInputPayload.fieldname = responsefield;           
                
            for(sObject schildobj : sobj.getSObjects(relationshipname)){
                if(String.isNotBlank((string)schildobj.get(memberemailfield))){
                    omeetingInputPayload.email.add((string)schildobj.get(memberemailfield));
                }
            }
        }
        System.debug('@Developer --> omeetingInputPayload :' + omeetingInputPayload);

        if(omeetingInputPayload.requestid == null){
            throw new MSTeamException('Missing Request Id');
        }
        
        if(omeetingInputPayload.email.size() == 0){
            throw new MSTeamException('Missing Team Members');
        }
        
        omeetingInputPayload.eventsubject = eventSubject;
        String sInputPayload = JSON.serialize(omeetingInputPayload);
        
        return docallout(teamMeetingEndpoint,sInputPayload);
        
    }
    
   
    /**
    *————————————————————————————————————————————————————
    * @Description: HTTP Post callout to Microsoft flows and creates group chat with members passed as input. MS Flow calls API to update group chatid
    * 
    *————————————————————————————————————————————————————
    * @param    sobjectid (to hold the salesforce record id), responsefield (field api name to update the group chat id), relationshipname (to retrieve team members), memberemailfield(email field of team member)
    * @return   void
    *————————————————————————————————————————————————————
    **/

    @AuraEnabled
    public static String doCallout_CreateGroupChat(Id sobjectid, String responsefield, String relationshipname, String memberemailfield, String calloutname, String subj){
        System.debug('@Developer -->doCallout_CreateGroupChat:' );
        System.debug('@Developer --> sobjectId :' + sobjectid);
        String sGroupChatEndpoint;
         
        if(sobjectid == null || string.isblank(calloutname)){
            throw new MSTeamException('Missing Information');
        }
        
        for(MS_Teams__mdt msteam : [Select Label,EndPoint__c,Type__c from MS_Teams__mdt where type__c = :calloutname]){            
                sGroupChatEndpoint = msteam.EndPoint__c;            
        }
        
        if(string.isblank(sGroupChatEndpoint)){
            throw new MSTeamException('Endpoint is not configured for this call');
        }
        
        String objType = sobjectid.getSObjectType().getDescribe().getName();      	

        
        String dynamicsoql = 'SELECT Id,' + responsefield +', (Select '+memberemailfield + ' From ' + relationshipname + ') From ' + objType + ' where Id = ' +' \'' + sobjectid + '\'';
        List<Sobject> sobjlist = Database.query(dynamicsoql);
		
        //String sGroupChatEndpoint = 'https://prod-136.westus.logic.azure.com:443/workflows/2009574d61ef4239a308241cd9116ae1/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=sOzbFtZcoJTuWMj574ICKl6EYQ4oWv59MDwquAegVnQ';

        
             
        GroupChatInputPayload oGroupChatInputPayload = new GroupChatInputPayload();
        for(sObject sobj : sobjlist)
        {
            oGroupChatInputPayload.requestid = sobjectid;
            oGroupChatInputPayload.fieldname = responsefield;
            if(String.isblank((string)sobj.get(responsefield))){
                oGroupChatInputPayload.groupchat_id = '';
            } else {
            	oGroupChatInputPayload.groupchat_id = (string)sobj.get(responsefield);
            }
            if(!String.isblank(subj)){
                oGroupChatInputPayload.chatsubject = subj;
            } else {
                oGroupChatInputPayload.chatsubject = 'Group chat created';
            }
                
            for(sObject schildobj : sobj.getSObjects(relationshipname)){
                if(String.isNotBlank((string)schildobj.get(memberemailfield))){
                    oGroupChatInputPayload.email.add((string)schildobj.get(memberemailfield));
                }
            }
        }
        System.debug('@Developer --> oGroupChatInputPayload :' + oGroupChatInputPayload);

        if(oGroupChatInputPayload.requestid == null){
            throw new MSTeamException('Missing Request Id');
        }
        
        if(oGroupChatInputPayload.email.size() == 0){
            throw new MSTeamException('Missing Team Members');
        }
        
        String sInputPayload = JSON.serialize(oGroupChatInputPayload);
        
        return docallout(sGroupChatEndpoint,sInputPayload);
        
    }
    
    @AuraEnabled
    @future(callout=true)
    public static void doCallout_Channel(String channelinput, String calloutname){
        System.debug('@Developer -->doCallout_CreateWeekEndSupportChannel:' );
        System.debug('@Developer --> shiftPlanId :' + channelinput);
        String sChannelEndpoint;
		//MSTeamsServiceController.ChannelInputPayLoad msteamsinput = (MSTeamsServiceController.ChannelInputPayLoad)JSON.deserialize(channelinput, MSTeamsServiceController.ChannelInputPayLoad.class);
         
        for(MS_Teams__mdt msteam : [Select Label,EndPoint__c,Type__c from MS_Teams__mdt where type__c = :calloutname]){            
                sChannelEndpoint = msteam.EndPoint__c;            
        }
        
        if(string.isblank(sChannelEndpoint)){
            throw new MSTeamException('Endpoint is not configured for this call');
        }
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sChannelEndpoint);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
       
        //String sInputPayload = JSON.serialize(oChannelInputPayLoad);
        //System.debug('@Developer --> sInputPayload :' + sInputPayload);
        req.setBody(channelinput);

        HTTPResponse res = new Http().send(req);
        
        System.debug('@Developer --> res.getStatusCode() :' + res.getStatusCode());
        System.debug('@Developer --> res.getStatus() :' + res.getStatus());
        System.debug('@Developer --> res.getBody() :' + res.getBody());
        if(res.getStatusCode() == 200){
            
        }        
        //return res.getBody();
    }

    
   	
    public static String docallout(String sGroupChatEndpoint, String sInputPayload){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sGroupChatEndpoint);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        
        
        
        
        System.debug('@Developer --> sInputPayload :' + sInputPayload);
        req.setBody(sInputPayload);

        HTTPResponse res = new Http().send(req);
        
        System.debug('@Developer --> res.getStatusCode() :' + res.getStatusCode());
        System.debug('@Developer --> res.getStatus() :' + res.getStatus());
        System.debug('@Developer --> res.getBody() :' + res.getBody());
        if(res.getStatusCode() == 200){
            
        }
        return res.getBody();
    }
     

    public class GroupChatInputPayload{ 
        public String requestid {get;set;}
        public String fieldname {get;set;}
        public String groupchat_id {get;set;}
        public list<String> email {get;set;}
        public String chatsubject {get;set;}
        public GroupChatInputPayload(){
            email = new list<String>();
        }
    }
    
     public class ImeetingInputPayload{
        public String requestid {get;set;}
        public String fieldname {get;set;}
        public String groupchat_id {get;set;}
        public list<String> email {get;set;}
        public String eventsubject {get;set;}
        public ImeetingInputPayload(){
            email = new list<String>();
        }
    }
    
     public class ChannelInputPayLoad{
        public String channelid;
        public String teamsid;
        //T02 true indicates request to add members, false to remove members
        public Boolean addMembers;
        public List<memberInputPayload> payloaddata;
        public ChannelInputPayLoad(){
            payloaddata = new List<memberInputPayload>();
        }
        public ChannelInputPayLoad(Boolean isempty){
            
        }
    }


    public class memberInputPayload{
        public String name;
        public String email;
        public String phone;
        public String team;
        public String region;
        public memberInputPayload(){
            email = '';
            team = '';
            region = '';
            phone = '';
        }
    }
    
   
    public class MSTeamException extends Exception{}
}