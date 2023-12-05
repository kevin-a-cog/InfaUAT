/*
Trigger:        GetInfoPanoptaAPI
@Author:        Pavithra V
@Created Date:  18 March 2021
@Description:   Get call to Panopta API


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************

*/
public class GetInfoPanoptaAPI {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /*
    * posts message on alert timeline
    * @param messagecontent - Message to be sent
    * @return return - void
    * @throws exception - NA
    */
	@AuraEnabled
    public static String checkuser(String caseownerid) {
        String resp = 'ERROR';
        try {             
            String apikey = ' ';            
            String getuserendpoint = ' ';            
            for(Panopta__mdt pmdt : [Select Id,Label,APIKey__c,EndPoint__c from Panopta__mdt where Label = 'contactinfo']){
                apikey = pmdt.APIKey__c;                
                getuserendpoint = pmdt.EndPoint__c;               
            }
            system.debug('endpoint:'+getuserendpoint);
            
            String username = [Select Id,Email,Name FROM User where Id = :caseownerid].Email;
            String userid = getUserURL(username,getuserendpoint,apikey);
            
            //----------------------------<T01 -- BEGIN>--------------------
            if(string.isBlank(userid) || userid == 'Error'){
                username = Label.PanoptaIntegration;
                userid = getUserURL(username,getuserendpoint,apikey);
        	}
            //----------------------------<T01 -- END>--------------------
          
                        
            if(!string.isBlank(userid) && userid != 'Error')
                resp = userid;                 
            
        } catch( System.Exception e) {  
             
            GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in getInfo',e.getMessage()+e.getlinenumber()); 
        }  
         return resp;
    }
        
        
    public static String postOutageLog(String messagecontent, String incidentid,String userurl ) {        
        String resp = ' ';        
        try {             
            String apikey = ' ';
            String outageendpoint = ' ';       
            for(Panopta__mdt pmdt : [Select Id,Label,APIKey__c,EndPoint__c from Panopta__mdt where Label = 'Outage Log']){
                apikey = pmdt.APIKey__c;                
                outageendpoint = pmdt.EndPoint__c;                
            }
                OutagelogJSON olj = new OutagelogJSON();
                olj.entry = messagecontent;
                olj.user = userurl;
                String requestbody = JSON.serialize(olj);                
                String restAPIURL = outageendpoint + '/' + string.escapeSingleQuotes(incidentid) + '/outage_log';           
                 System.debug('endpoint url:'+restAPIURL);   
				 System.debug('request body:'+requestbody);               
                HttpRequest httpRequest = new HttpRequest();  
                httpRequest.setMethod('POST');               
                httpRequest.setHeader('Content-Type', 'application/json');        
                httpRequest.setHeader('Authorization', apikey); 
                httpRequest.setBody(requestbody); 
                httpRequest.setEndpoint(restAPIURL);  
                String response = '';
         
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequest);  
                if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {  
                   // response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
                    System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );
                    String setleadendpoint = outageendpoint + '/' + string.escapeSingleQuotes(incidentid) + '/lead';                    
                    Boolean leadresponse =  setIncidentLead(olj.user,setleadendpoint,apikey);
                    system.debug('lead response'+leadresponse);
                    setleadendpoint = outageendpoint + '/' + string.escapeSingleQuotes(incidentid) + '/acknowledge';                  
                    
                    Boolean ackresponse = acknowledgeIncident(olj.user,setleadendpoint,apikey);
                    system.debug('ack response'+ackresponse);
                    if(leadresponse && ackresponse){
                        system.debug('Response is set to success');
                        resp = 'SUCCESS';
                	}
                } else {  
                    resp =  'ERROR';
                    System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );  
                    throw new CalloutException( httpResponse.getBody());  
                    
                } 
             
        } catch( System.Exception e) {  
             resp = 'ERROR';
            GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in getInfo',e.getMessage()+e.getLineNumber()); 
        }  
       
        return resp;
    }
    
    /*
    * Set Incident lead in panopta
    * @params User, Endpoint, Requesttoken 
    * @return return - void
    * @throws exception - NA
    */
    
    public static Boolean setIncidentLead(String user, String outageendpoint, string requesttoken ) {               
            Boolean resp = true;
        	SetIncidentLeadJSON sil = new SetIncidentLeadJSON();
        	sil.who = user;
            String requestbody = JSON.serialize(sil);
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod('PUT');   
            httpRequest.setHeader('Content-Type', 'application/json');        
            httpRequest.setHeader('Authorization', requesttoken); 
            httpRequest.setBody(requestbody); 
            httpRequest.setEndpoint(outageendpoint);  
            String response = '';
         
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 204 ) {  
               // response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
                System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );
                
            } else {  
                resp = false;
                System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }  
        
        return resp;
       
        }  
    
    /*
    * Acknowledge incident in panopta
    * @param messagecontent - Message to be sent
    * @return return - void
    * @throws exception - NA
    */
    
    public static Boolean  acknowledgeIncident(String user, String outageendpoint, string requesttoken ) {               
            Boolean resp = true;
        	SetAcknowledgeJSON sil = new SetAcknowledgeJSON();
        	sil.who = user;
            String requestbody = JSON.serialize(sil);
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod('PUT');   
            httpRequest.setHeader('Content-Type', 'application/json');        
            httpRequest.setHeader('Authorization', requesttoken); 
            httpRequest.setBody(requestbody); 
            httpRequest.setEndpoint(outageendpoint);  
            String response = '';
         
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 204 ) {  
               // response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
                System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );
               
            } else {  
                resp = false;
                System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }   
       	return resp;
        }  
       

    /*
    * Set Incident Summary from case closing notes
    * @param messagecontent - Message to be sent
    * @return return - void
    * @throws exception - NA
    */
   @future(callout = true)
   public  static void setIncidentSummary (String outageid, String closingnotes, String userid) {
    
    try {  
    String apikey = ' ';
    String endpoint = ' '; 

    for(Panopta__mdt pmdt : [Select Id,Label,APIKey__c,EndPoint__c from Panopta__mdt where Label = 'Outage Log']){
        apikey = pmdt.APIKey__c;                
        endpoint = pmdt.EndPoint__c;                
    }

    String userurl = checkuser(userid);    
       
    if(userurl.contains('ERROR')){
        //GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in setincidentsummary user does not exist',' '); 
        userid = Label.PanoptaIntegration;
        userurl = checkuser(userid);   
    }
         String restAPIURL = endpoint + '/' + outageid + '/summary';  
         String authorizationToken = apikey;             
         
         SetIncidentbody sil = new SetIncidentbody();
         sil.summary = closingnotes;
         sil.who = userurl;
         String requestbody = JSON.serialize(sil);

         HttpRequest httpRequest = new HttpRequest();  
         httpRequest.setMethod('PUT');   
         httpRequest.setHeader('Content-Type', 'application/json');        
         httpRequest.setHeader('Authorization', authorizationToken); 
         httpRequest.setBody(requestbody); 
             
         httpRequest.setEndpoint(restAPIURL);  
         String response = '';
      
         Http http = new Http();   
         HttpResponse httpResponse = http.send(httpRequest);  
         if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 204) {  
            
         } else{
            GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in setincidentsummary callout',string.valueof(httpResponse.getStatusCode())); 
         }
     
     } catch( System.Exception e) {  
         GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in setincidentsummary',e.getMessage()+':'+e.getLineNumber()); 
         
     }  
    
    }
 
    
    
    /*
    * get URL of the user
    * @param messagecontent - Message to be sent
    * @return return - void
    * @throws exception - NA
    */
    
   public  static String getUserURL	(String username, String endpoint, String apikey ) {
        
       String returnresp;
        try {                   
            //username = username.replaceall(' ','%20');
            String restAPIURL = endpoint + '=' + username;  
            String authorizationToken = apikey;              
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod('GET');   
            httpRequest.setHeader('Content-Type', 'application/json');        
            httpRequest.setHeader('Authorization', authorizationToken); 
                
            httpRequest.setEndpoint(restAPIURL);  
            String response = '';
         
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                PanoptaUserResponseWrapper uir = new PanoptaUserResponseWrapper();              
                
                uir = (PanoptaUserResponseWrapper)JSON.deserialize(httpResponse.getBody(), PanoptaUserResponseWrapper.class);
                system.debug('uir'+uir);
                if(uir.user_list.size()>0)
                system.debug('uir list'+uir.user_list[0].url);                
                System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );
                if(uir != null && uir.user_list != null && uir.user_list.size() > 0 && uir.user_list[0].url != null)
                	returnresp = uir.user_list[0].url;
                else
                    {
                        returnresp = 'Error';
                       // GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'User does not exist',String.valueof(httpResponse.getStatusCode())); 
                    }
                system.debug('returnresp'+returnresp);
            } else {  
                returnresp = 'Error';
                System.debug(' httpResponse ' + httpResponse.getStatusCode() + ' body:' + httpResponse.getBody() );  
                GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in return code',String.valueof(httpResponse.getStatusCode())); 
                throw new CalloutException( httpResponse.getBody() );  
               
            }   
        } catch( System.Exception e) {  
            GAM.CreateExceptionRecords('GetInfoPanoptaAPI', 'Exception in getInfo',e.getMessage()+e.getLineNumber()); 
            returnresp = 'Error';
        }  
       return returnresp;
    }
        
    /*     
    * @property entry - Will hold the message to be posted on alert timeline
    * @property user -  Will hold the url of the user   
    */
    public class OutagelogJSON{
        public string entry;
       // public string public;
        public string user;
        
    }

	/*         
    * @property user -  Will hold the url of the user   
    */
    public class SetIncidentLeadJSON{        
        public string who;        
    }
    
    /*        
    * @property user -  Will hold the url of the user   
    */
    public class SetAcknowledgeJSON{        
        public string who;        
    }

    /*        
    * @property user -  Will hold the url of the user   
    */
    public class SetIncidentbody{ 
        public string summary;               
        public string who;        
    }
    
    
   
    
}