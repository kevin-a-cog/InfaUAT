/*
 * Name      :  GlobalZoomUtilitiesClass
 * Author    :  Monserrat Pedroza
 * Created Date  :   7/9/2021
 * Description  :  Utilities class for Zoom Integration.

 Change History
 **********************************************************************************************************
 Modified By      Date      Jira No.    Description          Tag
 **********************************************************************************************************
 Monserrat Pedroza    7/9/2021    N/A        Initial version.      N/A
 Vignesh D        11/24/2021    I2RT-4414    Send zoom invite for additional attendees  T01
 Venky K          04/27/2022     AR          Change sender address to customer success if what id
                       is plan T02
 Vignesh D            04/27/2021  I2RT-5749   Store zoom error status code on event       T03
 */ 
public without sharing class GlobalZoomUtilitiesClass implements Queueable {
     
  //Public variables.
  public List<Event> lstRecords;
  public static Meeting_Account__c objUpdatedTokenDetails;
    public static final String STRING_FROM_CS3DEV = 'customersuccess@informatica.com';
    public static final String FROMSIT = 'supportqa@informatica.com';
    public static final String FROMUAT = 'supportuat_local@informatica.com';
    public static final String FROMPROD = 'support@informatica.com';
    public static final String FROMNAME = 'Informatica Support';
    public static final String FROMSITSUCCESS = 'customersuccesssit@informatica.com'; //T02
    public static final String FROMUATSUCCESS = 'customersuccessuat@informatica.com';//T02
    public static final String FROMPRODSUCCESS = 'customersuccess@informatica.com';//T02
    public static final String FROMSUCCESSNAME = 'Customer Success';//T02

  /*
   Method Name : GlobalZoomUtilitiesClass
   Description : Constructor of the class.
   Parameters   : Object, called from execute, objContext Queueable context.
   Return Type : None
   */
    public GlobalZoomUtilitiesClass(List<Event> lstRecords) {
    this.lstRecords = lstRecords;
    if(this.lstRecords == null) {
      this.lstRecords = new List<Event>();
    }
    }

  /*
   Method Name : execute
   Description : This method processes the Events in a queueable mode.
   Parameters   : Object, called from execute, objContext Queueable context.
   Return Type : None
   */
    public void execute(QueueableContext objContext) {
    Integer intIndex = 0;
    Integer intAvailable = Limits.getLimitFutureCalls() - Limits.getFutureCalls();
    List<Event> lstRecordsNextToProcess = new List<Event>();
    
    //Now we iterate over the events and send them for processing.
    for(Event objEvent : lstRecords) {
      if(intIndex < intAvailable) {
        generateMeetingAndSendInviteInFuture(JSON.serialize(objEvent));
        intIndex++;
      } else {
        lstRecordsNextToProcess.add(objEvent);
      }
    }
    
    //If there are events left, we send them to a new batch.
    if(!lstRecordsNextToProcess.isEmpty() && !Test.isRunningTest()) {
      System.enqueueJob(new GlobalZoomUtilitiesClass(lstRecordsNextToProcess));
    }
    }

  /*
   Method Name : generateMeetingAndSendInvites
   Description : This method generates Zoom meetings, stores the details on the Events and sends the invites to the Atendees.
   Parameters   : List, called from generateMeetingAndSendInvites, lstNewRecords List of Event records.
   Return Type : None
   */
  public static void generateMeetingAndSendInvites(List<Event> lstNewRecords) {
    generateMeetingAndSendInvites(lstNewRecords, null);
  }

  /*
   Method Name : generateMeetingAndSendInvites
   Description : This method generates Zoom meetings, stores the details on the Events and sends the invites to the Atendees.
   Parameters   : List, called from generateMeetingAndSendInvites, lstNewRecords List of Event records.
            Map, called from generateMeetingAndSendInvites, mapOldRecords Map of Event records before being updated.
   Return Type : None
   */
  public static void generateMeetingAndSendInvites(List<Event> lstNewRecords, Map<Id, Event> mapOldRecords) {
    List<Event> lstRecords = new List<Event>();

    //First we make sure we received events.
    if(lstNewRecords != null && !lstNewRecords.isEmpty()) {

      //Now, if we received old records, we make sure we only process them if the Zoom Meeting checkbox was checked.
      if(mapOldRecords != null && !mapOldRecords.isEmpty()) {
        for(Event objRecord : lstNewRecords) {
          for(Event objOldRecord : mapOldRecords.values()) {
            if(objRecord.Id == objOldRecord.Id && objRecord.Generate_Zoom_Meeting__c != objOldRecord.Generate_Zoom_Meeting__c && objRecord.Generate_Zoom_Meeting__c) {
              lstRecords.add(objRecord);
            }
          }
        }
      } else {

        //If we only received new records, we check the checkbox conditions.
        for(Event objRecord : lstNewRecords) {
          if(objRecord.Generate_Zoom_Meeting__c) {
            lstRecords.add(objRecord);
          }
        }
      }

      //Now, we send the requests to be processed asynchronously, if more than one.
      if(!lstRecords.isEmpty()) {
        System.enqueueJob(new GlobalZoomUtilitiesClass(lstRecords));
      }
    }
  }

  /*
   Method Name : generateMeetingAndSendInviteInFuture
   Description : This method generates a Zoom meeting, stores the details on the Event and sends the invite to the Atendees.
   Parameters   : String, called from generateMeetingAndSendInviteInFuture, strEventSerialized List of Event records.
   Return Type : None
   */
  @future(callout = true)
  public static void generateMeetingAndSendInviteInFuture(String strEventSerialized) {
    if(String.isNotBlank(strEventSerialized)) {
      generateMeetingAndSendInvite((Event) JSON.deserialize(strEventSerialized, Event.class));
    }
  }

  /*
   Method Name : generateMeetingAndSendInvite
   Description : This method generates a Zoom meeting, stores the details on the Event and sends the invite to the Atendees.
   Parameters   : Object, called from generateMeetingAndSendInvite, objEvent Event.
   Return Type : None
   */
  public static void generateMeetingAndSendInvite(Event objEvent) {
    String strDial;
    Event objUpdatedEvent = new Event();
    HttpResponse objResponse = new HttpResponse();
    Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();
    Messaging.EmailFileAttachment objAttachment = new Messaging.EmailFileAttachment();
    GlobalZoomRequestWrapperClass objRequest = new GlobalZoomRequestWrapperClass();
    GlobalZoomResponseWrapperClass objWrappedResponse = new GlobalZoomResponseWrapperClass();
    Set<String> setIds = new Set<String>();
    List<String> lstEmails = new List<String>();
    Map<String, String> mapParticipants = new Map<String, String>();
    Map<String, String> mapTemplateVariables = new Map<String, String>();
        Boolean issandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String orgname = URL.getSalesforceBaseUrl().toExternalForm();
        String fromaddress = ' ';
    Set<String> setAdditionalAttendeesEmails = new Set<String>(); // <T01>
    if(issandbox) {
      if(orgname.contains('infa--cs3dev')) {
        fromaddress = STRING_FROM_CS3DEV;
      } else if(orgname.contains('infa--uat')) {
                fromaddress = FROMUAT;
            } else {
                fromaddress = FROMSIT;                
            }            
        } else {
           fromaddress = FROMPROD;           
        }
        
    //First we get all the Event details.
    if(objEvent != null) {

      //We get the event details.
      for(Event objRecord : [SELECT Id, Subject,WhatId, StartDateTime, DurationInMinutes, Description, OwnerId, Owner.Name, Owner.Email, Additional_Attendees__c, (SELECT 
          RelationId FROM EventRelations) FROM Event WHERE Id = :objEvent.Id LIMIT 1]) {
        objEvent = objRecord;
        objUpdatedEvent.Id = objRecord.Id;
        setIds.add(objRecord.OwnerId);

        //If the event has attendees.
        if(objRecord.EventRelations != null && !objRecord.EventRelations.isEmpty()) {
          for(EventRelation objRelation : objRecord.EventRelations) {
            setIds.add(objRelation.RelationId);
          }
        }
        //If the event has additional attendees. <T01>
        if(String.isNotEmpty(objRecord?.Additional_Attendees__c)){
          for(String strEmailId : objRecord.Additional_Attendees__c.split(';')){

        //If we received Name, we split it.
        if(String.isNotBlank(strEmailId) && strEmailId.contains(' - ')) {
          mapParticipants.put(strEmailId.split(' - ')[1], strEmailId.split(' - ')[0]);
        } else {

          //Otherwise, we follow the existing approach.
          setAdditionalAttendeesEmails.add(strEmailId);
        }
          }
        }
              
              if(objRecord != null && objRecord.WhatId != null && objRecord.WhatId.getSObjectType().getDescribe().getName() == 'Plan__c'){
                  if(issandbox) {
                      if(orgname.contains('infa--cs3dev')) {
                        fromaddress = STRING_FROM_CS3DEV;
                      } else if(orgname.contains('infa--uat')) {
                                fromaddress = FROMUATSUCCESS;
                      } else {
                                fromaddress = FROMSITSUCCESS;                
                      }            
                  } else {
                           fromaddress = FROMPRODSUCCESS;           
                  }
              } else {
                  if(issandbox) {
                      if(orgname.contains('infa--uat')) {
                                fromaddress = FROMUAT;
                      } else {
                                fromaddress = FROMSIT;                
                      }            
                  } else {
                           fromaddress = FROMPROD;           
                  }
              }
      }

      //Now we collect the emails.
      for(User objRecord : [SELECT Name, Email FROM User WHERE Id IN :setIds]) {
        mapParticipants.put(objRecord.Email, objRecord.Name);
      }
      for(Contact objRecord : [SELECT Name, Email FROM Contact WHERE Id IN :setIds]) {
        mapParticipants.put(objRecord.Email, objRecord.Name);
      }
      for(Lead objRecord : [SELECT Name, Email FROM Lead WHERE Id IN :setIds]) {
        mapParticipants.put(objRecord.Email, objRecord.Name);
      }
      for(String strEmail : mapParticipants.keySet()) {
        lstEmails.add(strEmail);
      }
      // <T01>
      if(setAdditionalAttendeesEmails.size() > 0){
        for(String strEmail : new List<String>(setAdditionalAttendeesEmails)){
          if(!mapParticipants.containsKey(strEmail)){
            mapParticipants.put(strEmail, strEmail);
          }
        }
      }
      lstEmails.addAll(setAdditionalAttendeesEmails); 
      // </T01>

      //Now, we set the request data.
      objRequest.agenda = objEvent.Description;
      objRequest.duration = objEvent.DurationInMinutes;
      objRequest.start_time = convertDateTimeToUsersTimezone(objEvent.StartDateTime);
      objRequest.timezone = UserInfo.getTimeZone().getID();
      objRequest.topic = objEvent.Subject;
      objRequest.type = 2;
      objRequest.strBody = JSON.serialize(objRequest);
      objRequest.datTStartTime = objEvent.StartDateTime;
      objRequest.strUserName = objEvent.Owner.Name;
      objRequest.strUserEmail = objEvent.Owner.Email;

      //Now we serialize the request and prepare it.
      objRequest.boolAuthenticationIsBearer = true;
      objRequest.strEndpointLabel = 'Create Meeting';
      objRequest.strUserId = objEvent.OwnerId;
      objRequest.mapHeaders = new Map<String, String>();
      objRequest.mapHeaders.put('Content-Type', 'application/json');

      //Now we execute the callout.
      objResponse = GlobalZoomUtilitiesClass.executeZoomCallout(objRequest);
            
      //Now we analyze the response.
      if(objResponse.getStatusCode() == 201 || Test.isRunningTest()) {
        objWrappedResponse = (GlobalZoomResponseWrapperClass) JSON.deserialize(objResponse.getBody().replace('"number"', '"strNumber"'), GlobalZoomResponseWrapperClass.class);

        //Now we update the Event record.
        objUpdatedEvent.Generate_Zoom_Meeting__c = false;
        objUpdatedEvent.Location = objWrappedResponse.join_url;
        objUpdatedEvent.Zoom_Meeting_Id__c = String.valueOf(objWrappedResponse.id);
        objUpdatedEvent.Zoom_Meeting_Password__c = objWrappedResponse.password;
        objUpdatedEvent.Zoom_H323_Password__c = objWrappedResponse.h323_password;
        strDial = objWrappedResponse.strDialNumbers;
        if(String.isNotBlank(strDial) && strDial.length() > 254) {
          strDial = strDial.substring(0, 253);
        }
        objUpdatedEvent.Zoom_Dial_Information__c = strDial;
        update objUpdatedEvent;
                
        //Now we send the emails, if needed.
        if(!lstEmails.isEmpty()) {

          //We first set the calendar data.
          objAttachment.contenttype = 'text/calendar; method=REQUEST';
          objAttachment.inline = true;
          objAttachment.filename = objRequest.topic + '.ics';
          objRequest.strUID = objUpdatedEvent.Zoom_Meeting_Id__c;
          objAttachment.body = generateMeetingInvite(objRequest, objWrappedResponse, mapParticipants);

          //Now we prepare the email.
          for(OrgWideEmailAddress objSender : [SELECT Id FROM OrgWideEmailAddress WHERE Address = :fromaddress]) {
            objMessage.orgwideemailaddressid = objSender.Id;
          }
          objMessage.toAddresses = lstEmails;
          objMessage.subject = objRequest.topic;
          objMessage.plainTextBody = '';
          objMessage.setSaveAsActivity(false);  
          objMessage.setTreatTargetObjectAsRecipient(false);
          mapTemplateVariables.put('{!relatedTo.Description}', objEvent.Description);
          mapTemplateVariables.put('{!relatedTo.Owner.Name}', objRequest.strUserName);
          mapTemplateVariables.put('{!relatedTo.Location}', objUpdatedEvent.Location);
          mapTemplateVariables.put('{!relatedTo.Zoom_Meeting_Password__c}', objUpdatedEvent.Zoom_Meeting_Password__c);
          mapTemplateVariables.put('{!relatedTo.Zoom_Meeting_Id__c}', objUpdatedEvent.Zoom_Meeting_Id__c);
          mapTemplateVariables.put('{!relatedTo.Zoom_H323_Password__c}', objUpdatedEvent.Zoom_H323_Password__c);
          mapTemplateVariables.put('{dialNumbers}', objWrappedResponse.strDialNumbers);
          if(objWrappedResponse.objPrimaryPhone != null) {
            mapTemplateVariables.put('{objPrimaryPhone.country_name}', objWrappedResponse.objPrimaryPhone.country_name);
            mapTemplateVariables.put('{objPrimaryPhone.strNumberNoSpaces}', objWrappedResponse.objPrimaryPhone.strNumberNoSpaces);
          }
          if(objWrappedResponse.objSecondaryPhone != null) {
            mapTemplateVariables.put('{objSecondaryPhone.strNumberNoSpaces}', objWrappedResponse.objSecondaryPhone.strNumberNoSpaces);
          }
          objMessage.setHtmlBody(replaceTemplateVariables(mapTemplateVariables));
          objMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { objAttachment });

          //Finally we send the email.
          Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { objMessage });
        }
      }
      else{
      //---------------------------------------<T03>-----------------------------
      objUpdatedEvent.Zoom_Error_Status_Code__c = objResponse.getStatusCode() != null ? String.valueOf(objResponse.getStatusCode()) : '';
      update objUpdatedEvent;
      //---------------------------------------<T03>-----------------------------
  }

      //Now we update the meeting account, if needed.
      if(objUpdatedTokenDetails != null) {
        update objUpdatedTokenDetails;
        objUpdatedTokenDetails = null;
      }
    }
  }
  /*
   Method Name : forwardZoominvite
   Description : This method forward calendar invite.
   Parameters   : Event record, List of email address
   Return Type : void
   */
  public static void forwardinvite(Event objUpdatedEvent, Id userid){
        Messaging.EmailFileAttachment objAttachment = new Messaging.EmailFileAttachment();
        Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();           
        GlobalZoomRequestWrapperClass objRequest = new GlobalZoomRequestWrapperClass();
        GlobalZoomResponseWrapperClass objWrappedResponse = new GlobalZoomResponseWrapperClass();
        objWrappedResponse.join_url = objUpdatedEvent.location;
        List<String> lstEmails = new List<String>();
        Map<String,String> mapParticipants = new Map<String,String>();
        Map<String, String> mapTemplateVariables = new Map<String, String>();
        Boolean issandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String orgname = URL.getSalesforceBaseUrl().toExternalForm();
        String fromaddress = ' ';
             if(issandbox){
                if(orgname.contains('infa--uat')){
                    fromaddress = FROMUAT;                
                } else {
                    fromaddress = FROMSIT;                
                }            
             } else {
               fromaddress = FROMPROD;           
             }
        for(User u : [Select Id,Email,Name from User where Id = :userid]){
            mapParticipants.put(u.Email,u.Name);
            lstEmails.add(u.Email);
        }
        objRequest.strUserName = mapParticipants.values().get(0);
        objRequest.strUserEmail = new List<String> (mapParticipants.keyset()).get(0);
        objRequest.topic = objUpdatedEvent.subject;
        objRequest.datTStartTime = objUpdatedEvent.StartDateTime;
        objRequest.duration = objUpdatedEvent.DurationInMinutes;
        objAttachment.contenttype = 'text/calendar; method=REQUEST';
          objAttachment.inline = true;
          objAttachment.filename = objUpdatedEvent.subject + '.ics';
          objRequest.strUID = objUpdatedEvent.Zoom_Meeting_Id__c;
          objAttachment.body = generateMeetingInvite(objRequest, objWrappedResponse, mapParticipants);
          //Now we prepare the email.
          for(OrgWideEmailAddress objSender : [SELECT Id FROM OrgWideEmailAddress WHERE Address = :fromaddress]) {
            objMessage.orgwideemailaddressid = objSender.Id;
          }
          objMessage.toAddresses = lstEmails;
          objMessage.subject = objRequest.topic;
          objMessage.plainTextBody = '';
          objMessage.setSaveAsActivity(false);  
          objMessage.setTreatTargetObjectAsRecipient(false);
          mapTemplateVariables.put('{!relatedTo.Description}', objUpdatedEvent.Description);
          mapTemplateVariables.put('{!relatedTo.Owner.Name}', objRequest.strUserName);
          mapTemplateVariables.put('{!relatedTo.Location}', objUpdatedEvent.Location);
          mapTemplateVariables.put('{!relatedTo.Zoom_Meeting_Password__c}', objUpdatedEvent.Zoom_Meeting_Password__c);
          mapTemplateVariables.put('{!relatedTo.Zoom_Meeting_Id__c}', objUpdatedEvent.Zoom_Meeting_Id__c);
          mapTemplateVariables.put('{!relatedTo.Zoom_H323_Password__c}', objUpdatedEvent.Zoom_H323_Password__c);
          mapTemplateVariables.put('{dialNumbers}', objUpdatedEvent.Zoom_Dial_Information__c);
          if(objWrappedResponse.objPrimaryPhone != null) {
            mapTemplateVariables.put('{objPrimaryPhone.country_name}', objWrappedResponse.objPrimaryPhone.country_name);
            mapTemplateVariables.put('{objPrimaryPhone.strNumberNoSpaces}', objWrappedResponse.objPrimaryPhone.strNumberNoSpaces);
          }
          if(objWrappedResponse.objSecondaryPhone != null) {
            mapTemplateVariables.put('{objSecondaryPhone.strNumberNoSpaces}', objWrappedResponse.objSecondaryPhone.strNumberNoSpaces);
          }
          objMessage.setHtmlBody(replaceTemplateVariables(mapTemplateVariables));
          objMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { objAttachment });
          //Finally we send the email.
                    system.debug('**objMessage'+json.serializePretty(objMessage));
          Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { objMessage });
  }

  /*
   Method Name : executeZoomCallout
   Description : This method executes callouts to the Zoom API.
   Parameters   : Object, called from executeZoomCallout, objWrappedRequest Request data.
   Return Type : Object
   */
  public static HttpResponse executeZoomCallout(GlobalZoomRequestWrapperClass objWrappedRequest) {
    Http objHttp = new Http();
    HttpRequest objRequest = new HttpRequest();
    HttpResponse objResponse = new HttpResponse();
    GlobalZoomEndpointWrapperClass objEndpoint;

    //We ensure the request is not null.
    if(objWrappedRequest != null) {

      //First we get the client id and client secret.
      objEndpoint = getEndpoint(objWrappedRequest.strEndpointLabel);

      //Now we replace the path variables, if any.
      if(objWrappedRequest.mapPathVariables != null && objEndpoint != null && String.isNotBlank(objEndpoint.strEndpoint)) {
        for(String strPathVariable : objWrappedRequest.mapPathVariables.keySet()) {
          objEndpoint.strEndpoint = objEndpoint.strEndpoint.replace(strPathVariable, objWrappedRequest.mapPathVariables.get(strPathVariable));
        }
      }

      //Now we set the HTTP parameters.
      objRequest.setMethod(objEndpoint.strMethod);      
      objRequest.setEndPoint(objEndpoint.strEndpoint);

      //Now we set the headers.
      if(objWrappedRequest.mapHeaders != null && !objWrappedRequest.mapHeaders.isEmpty()) {
        for(String strKey : objWrappedRequest.mapHeaders.keySet()) {
          objRequest.setHeader(strKey, objWrappedRequest.mapHeaders.get(strKey));
        }
      }

      //Now we identify the authentication type.
      if(objWrappedRequest.boolAuthenticationIsBearer != null && objWrappedRequest.boolAuthenticationIsBearer) {

        //First we get the refresh token.
        for(Meeting_Account__c objMeetingAccount : [SELECT Id, Access_Token__c, Refresh_Token__c, Expires_In__c, LastModifiedDate FROM Meeting_Account__c WHERE 
            OwnerId = :objWrappedRequest.strUserId ORDER BY LastModifiedDate DESC LIMIT 1]) {
          
          //We check if the Access token is still valid.
          objMeetingAccount.Access_Token__c = refreshAccessToken(objMeetingAccount);

          //Now we set the token.
          objRequest.setHeader('Authorization', 'Bearer ' + objMeetingAccount.Access_Token__c);
        }
      } else {
        objRequest.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(objEndpoint.strClientId + ':' + objEndpoint.strClientSecret)));
      }
      if(String.isNotBlank(objWrappedRequest.strBody)) {
        objRequest.setBody(objWrappedRequest.strBody);
      }

      //Now we execute the request.
      objResponse = objHttp.send(objRequest);
    }
    return objResponse;
  }

  /*
   Method Name : refreshAccessToken
   Description : This method refreshes the access token, if needed.
   Parameters   : Object, called from refreshAccessToken, Meeting_Account__c Token details.
   Return Type : String
   */
  public static String refreshAccessToken(Meeting_Account__c objMeetingAccount) {
    Id idMeetingAccount = objMeetingAccount.Id;
    Long lonLastModifiedTime = objMeetingAccount.LastModifiedDate.getTime();
    Long lonNow = DateTime.now().getTime();
    String strResult = objMeetingAccount.Access_Token__c;
    HttpResponse objResponse = new HttpResponse();
    GlobalZoomRequestWrapperClass objWrappedRequest = new GlobalZoomRequestWrapperClass();
    GlobalZoomResponseWrapperClass objWrappedResponse = new GlobalZoomResponseWrapperClass();
    
    //First we check if the expiration time is valid still.
    if(((lonNow - lonLastModifiedTime) / 1000) >= objMeetingAccount.Expires_In__c) {

      //First we define the HTTP request parameters.
      objWrappedRequest.strBody = 'refresh_token=' + objMeetingAccount.Refresh_Token__c + '&grant_type=refresh_token';
      objWrappedRequest.strEndpointLabel = 'Token';

      //Now we execute the callout.
      objResponse = GlobalZoomUtilitiesClass.executeZoomCallout(objWrappedRequest);
      
      //Now we analyze the response.
      if(objResponse.getStatusCode() == 200) {
        objWrappedResponse = (GlobalZoomResponseWrapperClass) JSON.deserialize(objResponse.getBody(), GlobalZoomResponseWrapperClass.class);

        //Now we update the Meeting Account record.
        objMeetingAccount = new Meeting_Account__c();
        objMeetingAccount.Id = idMeetingAccount;
        objMeetingAccount.Access_Token__c = objWrappedResponse.access_token;
        objMeetingAccount.Expires_In__c = objWrappedResponse.expires_in;
        objMeetingAccount.Refresh_Token__c = objWrappedResponse.refresh_token;
        objMeetingAccount.Scope__c = objWrappedResponse.scope;
        objMeetingAccount.Token_Type__c = objWrappedResponse.token_type;
        objUpdatedTokenDetails = objMeetingAccount;

        //Now we return the new access token.
        strResult = objMeetingAccount.Access_Token__c;
      }
    }
    return strResult;
  }

  /*
   Method Name : getEndpoint
   Description : This method returns an Endpoint record, depending on the provided Label.
   Parameters   : String, called from getEndpoint, strLabel Endpoint Label.
   Return Type : Object
   */
  public static GlobalZoomEndpointWrapperClass getEndpoint(String strLabel) {
    String strEnvironmentId = UserInfo.getOrganizationId();
    GlobalZoomEndpointWrapperClass objResult = new GlobalZoomEndpointWrapperClass();

    //Now we query the endpoint.
    for(Endpoint__mdt objEndpoint : [SELECT Credential__r.Client_Id__c, Credential__r.Client_Secret__c, URL__c, Method__c, Redirect_URI__c FROM Endpoint__mdt WHERE Label = :strLabel AND 
        Active__c = TRUE AND Environment__r.Id__c = :strEnvironmentId AND Environment__r.Active__c = TRUE LIMIT 1]) {

      //We set the credentials, if any.
      if(objEndpoint.Credential__r != null) {
        objResult.strClientId = objEndpoint.Credential__r.Client_Id__c;
        objResult.strClientSecret = objEndpoint.Credential__r.Client_Secret__c;
      }
      
      //Now we set the rest of the properties.
      objResult.strEndpoint = objEndpoint.URL__c;
      objResult.strMethod = objEndpoint.Method__c;
      objResult.strRedirectURI = objEndpoint.Redirect_URI__c;
    }
    return objResult;
  }

  /*
   Method Name : convertDateTimeToUsersTimezone
   Description : This method converts a UTC DateTime into the current user's timezone.
   Parameters   : Datetime, called from convertDateTimeToUsersTimezone, datTDateTimeToConvert Date Time to convert.
   Return Type : Object
   */
  public static Datetime convertDateTimeToUsersTimezone(Datetime datTDateTimeToConvert) {
    Datetime datTConverted = datTDateTimeToConvert.Date();
    datTConverted = datTConverted.addHours(datTDateTimeToConvert.hour());
    datTConverted = datTConverted.addMinutes(datTDateTimeToConvert.minute());
    datTConverted = datTConverted.addSeconds(datTDateTimeToConvert.second());
    return datTConverted;
  }

  /*
   Method Name : generateMeetingInvite
   Description : This method creates the metadata for the Calendar invite.
   Parameters   : Object, called from generateMeetingInvite, objRequest Invite request data.
            Object, called from generateMeetingInvite, objWrappedResponse Zoom Invite data.
           Map, called from generateMeetingInvite, mapParticipants List of email attendees and names.
   Return Type : Blob
   */
  public static Blob generateMeetingInvite(GlobalZoomRequestWrapperClass objRequest, GlobalZoomResponseWrapperClass objWrappedResponse, Map<String, String> mapParticipants) {
        String strMetadata = '';
    strMetadata += 'BEGIN:VCALENDAR\n';
        strMetadata += 'METHOD:REQUEST\n';
        strMetadata += 'PRODID:-//zoom.us//iCalendar Event//EN\n';
        strMetadata += 'VERSION:2.0\n';
        strMetadata += 'BEGIN:VEVENT\n';
        for(String strEmail : mapParticipants.keySet()) {
            strMetadata += 'ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=' + mapParticipants.get(strEmail) + ':MAILTO:' + strEmail + '\n';
        }
    strMetadata += 'DESCRIPTION;LANGUAGE=en-US:\n';
    strMetadata += 'UID:' + objRequest.strUID + '\n';
    strMetadata += 'SUMMARY;LANGUAGE=en-US:' + objRequest.topic + '\n';
    strMetadata += 'DTSTART' + getInviteDateTimeFormat(objRequest.datTStartTime) + '\n';
    strMetadata += 'DTEND' + getInviteDateTimeFormat(objRequest.datTStartTime.addMinutes(objRequest.duration)) + '\n';
    strMetadata += 'CLASS:PUBLIC\n';
    strMetadata += 'PRIORITY:5\n';
    strMetadata += 'DTSTAMP:' + objRequest.datTStartTime.format('yyyyMMdd\'T\'HHmmss') + 'Z' + '\n';
    strMetadata += 'TRANSP:OPAQUE\n';
    strMetadata += 'STATUS:CONFIRMED\n';
    strMetadata += 'SEQUENCE:0\n';
    strMetadata += 'LOCATION;LANGUAGE=en-US:' + objWrappedResponse.join_url + '\n';
    strMetadata += 'BEGIN:VALARM\n';
    strMetadata += 'DESCRIPTION:REMINDER\n';
    strMetadata += 'TRIGGER;RELATED=START:-PT15M\n';
    strMetadata += 'ACTION:DISPLAY\n';
    strMetadata += 'END:VALARM\n';
        strMetadata += 'END:VEVENT\n';
        strMetadata += 'END:VCALENDAR'; 
        return Blob.valueOf(strMetadata);
    }

  /*
   Method Name : generateMeetingCancellation
   Description : This method creates the metadata for the Calendar cancellation.
   Parameters   : Object, called from generateMeetingCancellation, objRequest Invite request data.
            Object, called from generateMeetingCancellation, objWrappedResponse Zoom Invite data.
           Map, called from generateMeetingCancellation, mapParticipants List of email attendees and names.
   Return Type : Blob
   */
  public static Blob generateMeetingCancellation(GlobalZoomRequestWrapperClass objRequest, GlobalZoomResponseWrapperClass objWrappedResponse, Map<String, String> mapParticipants) {
        String strMetadata = '';
    strMetadata += 'BEGIN:VCALENDAR\n';
        strMetadata += 'METHOD:CANCEL\n';
    strMetadata += 'PRODID:Microsoft Exchange Server 2010\n';
        strMetadata += 'VERSION:2.0\n';
        strMetadata += 'BEGIN:VEVENT\n';
        for(String strEmail : mapParticipants.keySet()) {
            strMetadata += 'ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=' + mapParticipants.get(strEmail) + ':mailto:' + strEmail + '\n';
        }
    strMetadata += 'DESCRIPTION;LANGUAGE=en-US:\n';
    strMetadata += 'UID:' + objRequest.strUID + '\n';
    strMetadata += 'SUMMARY;LANGUAGE=en-US:' + objRequest.topic + '\n';
    strMetadata += 'DTSTART' + getInviteDateTimeFormat(objRequest.datTStartTime) + '\n';
    strMetadata += 'DTEND' + getInviteDateTimeFormat(objRequest.datTStartTime.addMinutes(objRequest.duration)) + '\n';
    strMetadata += 'CLASS:PUBLIC\n';
    strMetadata += 'PRIORITY:5\n';
    strMetadata += 'DTSTAMP:' + objRequest.datTStartTime.format('yyyyMMdd\'T\'HHmmss') + 'Z' + '\n';
    strMetadata += 'TRANSP:OPAQUE\n';
    strMetadata += 'STATUS:CANCELLED\n';
    strMetadata += 'SEQUENCE:999999\n';
    strMetadata += 'LOCATION;LANGUAGE=en-US:' + objWrappedResponse.join_url + '\n';
    strMetadata += 'X-MICROSOFT-CDO-APPT-SEQUENCE:999999\n';
    strMetadata += 'X-MICROSOFT-CDO-OWNERAPPTID:2119651876\n';
    strMetadata += 'X-MICROSOFT-CDO-BUSYSTATUS:TENTATIVE\n';
    strMetadata += 'X-MICROSOFT-CDO-INTENDEDSTATUS:BUSY\n';
    strMetadata += 'X-MICROSOFT-CDO-ALLDAYEVENT:FALSE\n';
    strMetadata += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
    strMetadata += 'X-MICROSOFT-CDO-INSTTYPE:0\n';
    strMetadata += 'X-MICROSOFT-DONOTFORWARDMEETING:FALSE\n';
    strMetadata += 'X-MICROSOFT-DISALLOW-COUNTER:FALSE\n';
    strMetadata += 'X-MICROSOFT-LOCATIONDISPLAYNAME:' + objWrappedResponse.join_url + '\n';
    strMetadata += 'X-MICROSOFT-LOCATIONSOURCE:None\n';
    strMetadata += 'X-MICROSOFT-LOCATIONS:[{"DisplayName":"' + objWrappedResponse.join_url + '","LocationAnnotation":"","LocationUri":"","LocationStreet":"","LocationCity":"","LocationState":""' + 
        ',"LocationCountry":""' + ',"LocationPostalCode":"","LocationFullAddress":""}]\n';
    strMetadata += 'BEGIN:VALARM\n';
    strMetadata += 'DESCRIPTION:REMINDER\n';
    strMetadata += 'TRIGGER;RELATED=START:-PT15M\n';
    strMetadata += 'ACTION:DISPLAY\n';
    strMetadata += 'END:VALARM\n';
        strMetadata += 'END:VEVENT\n';
        strMetadata += 'END:VCALENDAR'; 
        return Blob.valueOf(strMetadata);
    }

  /*
   Method Name : getInviteDateTimeFormat
   Description : This method creates the metadata for the Calendar invite.
   Parameters   : DateTime, called from getInviteDateTimeFormat, datTDateTime Date Time to be formatted.
   Return Type : String
   */
  public static String getInviteDateTimeFormat(DateTime datTDateTime) {
    return ':' + datTDateTime.formatGmt('yyyyMMdd\'T\'HHmmss') + 'Z';
  }

  /*
   Method Name : replaceTemplateVariables
   Description : This method replaces the variables on the email template.
   Parameters   : Map, called from replaceTemplateVariables, mapVariablesToReplace Variables to replace.
   Return Type : String
   */
  public static String replaceTemplateVariables(Map<String, String> mapVariablesToReplace) {
    String strHTMLCode = '';
    for(EmailTemplate objTemplate : [SELECT Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Zoom_Invite']) {
      strHTMLCode = objTemplate.Body;
      if(String.isBlank(strHTMLCode)) {
        strHTMLCode = objTemplate.HTMLValue;
      }
    }
    if(mapVariablesToReplace != null && !mapVariablesToReplace.isEmpty()) {
      for(String strStringToReplace : mapVariablesToReplace.keySet()) {
        if(String.isBlank(mapVariablesToReplace.get(strStringToReplace))) {
          mapVariablesToReplace.put(strStringToReplace, '');
        }
        strHTMLCode = strHTMLCode.replace(strStringToReplace, mapVariablesToReplace.get(strStringToReplace));
      }
    }
    return strHTMLCode;
  }
}