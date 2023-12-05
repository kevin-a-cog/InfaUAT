/*
 * Name         :   GlobalSchedulerController
 * Author       :   Monserrat Pedroza
 * Created Date :   7/22/2021
 * Description  :   Controller class for Scheduler feature.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      7/22/2021       N/A             Initial version.            N/A
 Vignesh D              11/24/2021      I2RT-4414       Include email only case contacts    T01
 Vignesh D              12/06/2021      I2RT-5110       Include primary case contactid to return    T02
 Amit Garg              03/02/2022      I2RT-5425       Added a check ShowAs!= Free                 T03
 Vignesh D              04/27/2022      I2RT-5749       Add Zoom Error Status Code to soql query    T04
 Harshita J             09/29/2022      AR-2841         Updated As Part of Time Conversion Issue    T05
 Harshita J             10/03/2022      AR-2841         Handled Time Conversion Issue Only For Plan records as part of CSM   T06
 Vignesh D              09/20/2023      I2RT-9063       Added method to fetch time slots for		T07
 														Ask An Expert scheduler
 Shashikanth            10/18/2023		I2RT-7702		Added method to get contact timezone					T08
 */
public without sharing class GlobalSchedulerController { 

  //Public variables.
  public static String STR_DATE_KEY_FORMAT = 'E dd';
  public static String STR_DATETIME_FORMAT = 'MM/dd/yyyy h:mm a';
  
  /*
   Method Name : getEmailTemplate
   Description : This method returns the HTML body of the email template to send to the parent.
   Parameters  : Object, called from getEmailTemplate, objRequest Request.
   Return Type : String.
   */
  @AuraEnabled(cacheable = false) 
  public static String getEmailTemplate(GlobalSchedulerWrapperClass objRequest) {
      Id idRecord;
  Id idRelatedToId;
      String strTemplateName;
      String strHTMLCode = '';
  String strTimezone;
  String strOriginalTimezoneSidKey = 'UTC';
  DateTime datTStart;
  TimeZone objTimezone;
      Schema.sObjectType objObjectType;
      Map<String, String> mapVariablesToReplace = new Map<String, String>();

      //Depending on the Id we received, we prepare different data.
      if(String.isNotBlank(objRequest.strRecordId)) {
          idRecord = objRequest.strRecordId;
          objObjectType = idRecord.getSObjectType();

          //If the record belongs to an Appointment Request.
          if(objObjectType == Event.sObjectType) {
              strTemplateName = 'Insert_Meeting';
      
              //Now we query the data.
              for(Event objRecord : [SELECT Location, StartDateTime, DurationInMinutes, WhatId FROM Event WHERE Id = :idRecord LIMIT 1]) {
                  mapVariablesToReplace.put('{!Event.Location}', objRecord.Location);

        //Now we define the object type.
        idRecord = objRecord.WhatId;
              objObjectType = idRecord.getSObjectType();

        //Now we check if the WhatId of the related Event is a Case, and it has a related Timezone.
        if(objObjectType == Case.sObjectType) {
          for(Case objRelatedCase : [SELECT Case_Timezone__r.TimeZoneSidKey__c FROM Case WHERE Id = :idRecord AND Case_Timezone__c <> NULL AND 
              Case_Timezone__r.TimeZoneSidKey__c <> NULL]) {
            if(String.isNotBlank(objRelatedCase.Case_Timezone__r.TimeZoneSidKey__c)) {
              objTimezone = TimeZone.getTimeZone(objRelatedCase.Case_Timezone__r.TimeZoneSidKey__c);
            }
          }
        } else if(objObjectType == Plan__c.sObjectType) {

          //It's not a case, but a Plan.
          for(Plan__c objRelatedCase : [SELECT Plan_Timezone__r.TimeZoneSidKey__c FROM Plan__c WHERE Id = :idRecord AND Plan_Timezone__c <> NULL AND 
              Plan_Timezone__r.TimeZoneSidKey__c <> NULL]) {
            if(String.isNotBlank(objRelatedCase.Plan_Timezone__r.TimeZoneSidKey__c)) {
              objTimezone = TimeZone.getTimeZone(objRelatedCase.Plan_Timezone__r.TimeZoneSidKey__c);
            }
          }
        }

        //Now we create the text including Timezone, if any.
        if(objTimezone != null) {
          mapVariablesToReplace.put('{!Event.ProposedEventTimeframe}', objRecord.StartDateTime.format(STR_DATETIME_FORMAT, objTimezone.getID()) + 
              ' - Duration (' + objRecord.DurationInMinutes + ' minutes) ' + objTimezone.getDisplayName().replace('(G', 'G').replace(') ', ' '));
        } else {
          mapVariablesToReplace.put('{!Event.ProposedEventTimeframe}', objRecord.StartDateTime.format(STR_DATETIME_FORMAT) + 
              ' - Duration (' + objRecord.DurationInMinutes + ' minutes)');
        }
              }
          } else {
              strTemplateName = 'Insert_Availability';

              //Now we query the data.
      if(objObjectType == Case_Comment__c.sObjectType) {
        for(Case_Comment__c objRecord : [SELECT Comment__c FROM Case_Comment__c WHERE Id = :idRecord LIMIT 1]) {
          mapVariablesToReplace.put('{{{Case.Calendar_Availability__c}}}', objRecord.Comment__c);
        }
      } else if(objObjectType == Plan_Comment__c.sObjectType) {
        for(Plan_Comment__c objRecord : [SELECT Comment__c FROM Plan_Comment__c WHERE Id = :idRecord LIMIT 1]) {
          mapVariablesToReplace.put('{{{Case.Calendar_Availability__c}}}', objRecord.Comment__c);
        }
      }
          }
      } else {

    //We received the slots URL directly, so we replace the variables.
    strTemplateName = 'Insert_Availability';
    mapVariablesToReplace.put('{{{Case.Calendar_Availability__c}}}', objRequest.strSlotsURL);

    //If the related record is a Plan, we replace the variables.
    idRelatedToId = objRequest.strRelatedToId;
    if(idRelatedToId != null && idRelatedToId.getSObjectType() == Schema.Plan__c.sObjectType) {
      for(Appointment_Request__c objRecord : [SELECT Time_Zone__c, (SELECT Start_Time__c, Duration__c FROM Time_Slots__r ORDER BY Start_Time__c ASC LIMIT 1000) FROM 
          Appointment_Request__c WHERE Id = :objRequest.strSlotsURL.split('id=')[1] LIMIT 1]) {
        mapVariablesToReplace.put('{{{Timezone}}}', getTimeZoneValues().get(objRecord.Time_Zone__c));

        //If we have time slots.
        strHTMLCode = '';
        if(objRecord.Time_Slots__r != null && !objRecord.Time_Slots__r.isEmpty()) {
          for(Time_Slot__c objSlot : objRecord.Time_Slots__r) {
            datTStart = getTimezoneChanged(objSlot.Start_Time__c, strOriginalTimezoneSidKey, objRecord.Time_Zone__c);
            strHTMLCode += '<li>' + datTStart.formatGmt('MMM d hh:mm a') + ' - ' + datTStart.addMinutes(Integer.valueOf(objSlot.Duration__c)).formatGmt('hh:mm a') + '</li>';
            
          }
        }
        mapVariablesToReplace.put('{{{Slots}}}', strHTMLCode);
      }

      //If we have contacts.
      strHTMLCode = '';
      if(objRequest.lstContacts != null && !objRequest.lstContacts.isEmpty()) {
        strHTMLCode = '</ul><br /><b>Contacts included in the Communication:</b><br /><ul>{{{Contacts}}}';
        for(Contact objAttendee : [SELECT Name FROM Contact WHERE Id IN :objRequest.lstContacts LIMIT 1000]) {
          strHTMLCode += '<li>' + objAttendee.Name + '</li>';
        }
      }
      mapVariablesToReplace.put('{{{Contacts}}}', strHTMLCode);
    }
  }

      //Now we query the template.
      for(EmailTemplate objTemplate : [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = :strTemplateName]) {
          strHTMLCode = objTemplate.HtmlValue;

    //We delete Cosmos variables, if needed.
    if(idRelatedToId == null || idRelatedToId.getSObjectType() != Schema.Plan__c.sObjectType) {
      strHTMLCode = strHTMLCode.replaceAll('(<cosmosonly>)([\\s\\S.]*?)(<\\/cosmosonly>)', '');
    }
      }
      if(String.isNotBlank(strHTMLCode)) {

          //Now we replace the variables.
          if(!mapVariablesToReplace.isEmpty()) {
              for(String strStringToReplace : mapVariablesToReplace.keySet()) {
                  if(String.isNotBlank(mapVariablesToReplace.get(strStringToReplace))) {
                      strHTMLCode = strHTMLCode.replace(strStringToReplace, mapVariablesToReplace.get(strStringToReplace));
                  }
              }
          }

    //we remove contacts variable, if needed.
    if(strHTMLCode.contains('{{{Contacts}}}')) {
      strHTMLCode = strHTMLCode.replace('{{{Contacts}}}', '');
    }
      }
      return strHTMLCode;
  }

  /*
   Method Name : getEventDetails
   Description : This method returns an Event record, if it has a location.
   Parameters  : String, called from getEventDetails, strRecordId Record Id.
   Return Type : List of Picklist Entries.
   */
  @AuraEnabled(cacheable = false)
  public static Event getEventDetails(String strRecordId) {
      return [SELECT Location,Zoom_Error_Status_Code__c FROM Event WHERE Id = :strRecordId]; // <T04>
  }

  /*
   Method Name : getTimeZoneValues
   Description : This method returns the list of available time zones.
   Parameters  : None
   Return Type : List of Picklist Entries.
   */
  @AuraEnabled(cacheable = true)
  public static Map<String, String> getTimeZoneValues() {
      Map<String, String> mapTimeZones = new Map<String, String>();
      for(PicklistEntry objTimeZone : User.TimeZoneSidKey.getdescribe().getPicklistValues()) {
          mapTimeZones.put(objTimeZone.getValue(), objTimeZone.getLabel());
      }
      return mapTimeZones;
  }

  /*
   Method Name : getIsReadOnly
   Description : This method returns if the current scenario is Read Only.
   Parameters  : String, called from getIsReadOnly, strRecordId Record Id.
   Return Type : Boolean
   */
  @AuraEnabled(cacheable = true)
  public static Boolean getIsReadOnly(String strRecordId) {
      Boolean boolResult = false;
      Id idRecord;
      Schema.sObjectType objObjectType;
      if(String.isNotBlank(strRecordId)) {
          idRecord = strRecordId;
          objObjectType = idRecord.getSObjectType();

          //If the record belongs to an Appointment Request.
          if(objObjectType == Appointment_Request__c.sObjectType) {
              boolResult = true;
          }
      }
      return boolResult;
  }

  /*
   Method Name : getRelatedUsers
   Description : This method returns the list of related users.
   Parameters  : String, called from getRelatedUsers, strRecordId Record Id.
   Return Type : Object
   */
  @AuraEnabled(cacheable = false)
  public static GlobalSchedulerWrapperClass getRelatedUsers(String strRecordId) {
      Boolean boolIsTeamMemberAlso = false;
      Id idRecord;
      Id idOwner;
      Schema.sObjectType objObjectType;
      GlobalSchedulerWrapperClass objResult = new GlobalSchedulerWrapperClass();
      Set<Id> setTeamMemberIds = new Set<Id>();
      List<Id> lstTeamMembers = new List<Id>();

      //First we set the default values.
      objResult.objUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
      objResult.lstTeamMembers = new List<User>();
      objResult.lstAdditionalUsers = new List<User>();
      objResult.lstAdditionalUsers.add(objResult.objUser);
      objResult.lstRecordContacts = (List<SObject>) Type.forName('List<SObject>').newInstance();
      objResult.lstEmailOnlyCaseContacts = (List<SObject>) Type.forName('List<SObject>').newInstance(); // <T01>
      objResult.lstSupportAccContacts = (List<SObject>) Type.forName('List<SObject>').newInstance();

      //Now, depending on the record id, we collect the data.
      if(String.isNotBlank(strRecordId)) {
          idRecord = strRecordId;
          objObjectType = idRecord.getSObjectType();

          //If the record belongs to a Case.
    objResult.strRecordType = objObjectType.getDescribe().getName();
          if(objObjectType == Case.sObjectType) {
              for(Case objCase : [SELECT OwnerId, Support_Account__c, ContactId, (SELECT User__c FROM Case_Teams__r), (SELECT Contact__r.Id, Contact__r.Name, Email__c FROM Case_Contacts__r) FROM Case WHERE Id = :idRecord LIMIT 1]) {
                  idOwner = objCase.OwnerId;
                  lstTeamMembers.add(idOwner);
                  objResult.strPrimaryContactId = objCase?.ContactId; // <T02>

                  //Now we get the Team Member Ids.
                  for(Case_Team__c objMember : objCase.Case_Teams__r) {
                      lstTeamMembers.add(objMember.User__c);

                      //If the Owner is also team member, we mark it.
                      if(objMember.User__c == idOwner) {
                          boolIsTeamMemberAlso = true;
                      }
                  }

                  //Now we get the Case Contacts.
                  Set<Id> setCaseContactId = new Set<Id>();//I2RT-4337
                  for(Case_Contact__c objContact : objCase.Case_Contacts__r) {
                      if(String.isNotEmpty(objContact.Contact__r.Id)){ // <T01>
                      objResult.lstRecordContacts.add(objContact);
                          setCaseContactId.add(objContact.Contact__r.Id);//I2RT-4337
                      }
                      else if(String.isNotEmpty(objContact.Email__c)){ // <T01>
                          objResult.lstEmailOnlyCaseContacts.add(objContact);
                      }
                  }
                  //I2RT-4337
                  for(AccountContactRelation objAccountContactRelationship : [SELECT ContactId, Contact.Name FROM AccountContactRelation WHERE AccountId = :objCase.Support_Account__c LIMIT 1000]) {
                      if(!setCaseContactId.contains(objAccountContactRelationship.ContactId)){
                          objResult.lstSupportAccContacts.add(objAccountContactRelationship);
                      }
                  }
              }
          } else if(objObjectType == Engagement__c.sObjectType) {

      //If the record belongs to an Engagement.
      for(Engagement__c objRecord : [SELECT OwnerId, (SELECT Team_Member__c FROM Engagement_Teams__r), (SELECT Contact__r.Id, Contact__r.Name FROM Engagement_Contacts__r) FROM Engagement__c WHERE 
          Id = :idRecord LIMIT 1]) {
                  idOwner = objRecord.OwnerId;
                  lstTeamMembers.add(idOwner);

                  //Now we get the Team Member Ids.
                  for(Engagement_Team__c objMember : objRecord.Engagement_Teams__r) {
                      lstTeamMembers.add(objMember.Team_Member__c);

                      //If the Owner is also team member, we mark it.
                      if(objMember.Team_Member__c == idOwner) {
                          boolIsTeamMemberAlso = true;
                      }
                  }

                  //Now we get the Case Contacts.
                  for(Engagement_Contacts__c objContact : objRecord.Engagement_Contacts__r) {
                      objResult.lstRecordContacts.add(objContact);
                  }
              }
          } else if(objObjectType == Plan__c.sObjectType) {
              for(Plan__c objPlan : [SELECT OwnerId, (SELECT User__c FROM Plan_Team__r), (SELECT Contact__r.Id, Contact__r.Name FROM Plan_Contacts__r) FROM Plan__c WHERE Id = :idRecord LIMIT 1]) {
                  idOwner = objPlan.OwnerId;
                  lstTeamMembers.add(idOwner);

                  //Now we get the Team Member Ids.
                  for(Plan_Team__c objMember : objPlan.Plan_Team__r) {
                      lstTeamMembers.add(objMember.User__c);

                      //If the Owner is also team member, we mark it.
                      if(objMember.User__c == idOwner) {
                          boolIsTeamMemberAlso = true;
                      }
                  }

                  //Now we get the Plan Contacts.
                  for(Plan_Contact__c objContact : objPlan.Plan_Contacts__r) {
                      objResult.lstRecordContacts.add(objContact);
                  }
              }
          }

          //Now, we query the names for the Team Members.
          setTeamMemberIds.addAll(lstTeamMembers);
          lstTeamMembers = new List<Id>();
          lstTeamMembers.addAll(setTeamMemberIds);
          for(User objUser : [SELECT Id, Name FROM User WHERE Id IN :lstTeamMembers LIMIT 1000]) {
              if(idOwner == objUser.Id) {
                  objResult.objUser = objUser;

                  //If the Owner is also a Team Member, we add it.
                  if(boolIsTeamMemberAlso) {
                      objResult.lstTeamMembers.add(objUser);
                  }
              } else {
                  objResult.lstTeamMembers.add(objUser);
              }
          }
      }
      return objResult;
  }

  /*
   Method Name : getUserName
   Description : This method returns the Name of the provided user.
   Parameters  : String, called from getUserName, strRecordId Record Id.
   Return Type : String
   */
  @AuraEnabled(cacheable = true)
  public static String getUserName(String strRecordId) {
      return [SELECT Name FROM User WHERE Id = :strRecordId].Name;
  }

  /*
   Method Name : getAppointmentRequestCreated
   Description : This method creates the Appointment request.
   Parameters  : Object, called from getAppointmentRequestCreated, objRequest Request data.
   Return Type : None
   */
  @AuraEnabled(cacheable = false)
  public static SObject getAppointmentRequestCreated(GlobalSchedulerWrapperClass objRequest) {
      Id idRecord;
  String strURL;
  String strOriginalTimezoneSidKey = UserInfo.getTimeZone().getId();
  String strTargetTimezoneSidKey = 'UTC';
      Schema.sObjectType objObjectType;
  ContentVersion objContentNote = new ContentVersion();
      Site objSite;
      Case_Comment__c objCaseComment = new Case_Comment__c();
  Plan_Comment__c objPlanComment = new Plan_Comment__c();
  SObject objResult;

  //First we check if we received a target timezone.
  if(String.isNotBlank(objRequest.strOriginalTimezoneSidKey)) {
    strOriginalTimezoneSidKey = objRequest.strOriginalTimezoneSidKey;
  }
      
      //Now we create the Appointment request.
      objRequest.objAppointmentRequest.Parent_Record_Id__c = objRequest.strRecordId;
  objRequest.objAppointmentRequest.Time_Zone__c = strOriginalTimezoneSidKey;
      insert objRequest.objAppointmentRequest;

      //Now we create the Attendees.
      if(objRequest.lstAttendees != null && !objRequest.lstAttendees.isEmpty()) {
          for(Attendee__c objAttendee : objRequest.lstAttendees) {
              objAttendee.Appointment_Request__c = objRequest.objAppointmentRequest.Id;
          }
          insert objRequest.lstAttendees;
      }

      //Now we create the Slots.
      if(objRequest.lstSlots != null && !objRequest.lstSlots.isEmpty()) {
          for(Time_Slot__c objSlot : objRequest.lstSlots) {
              objSlot.Appointment_Request__c = objRequest.objAppointmentRequest.Id;
      objSlot.Start_Time__c = getTimezoneChanged(objSlot.Start_Time__c, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);
          }
          insert objRequest.lstSlots;
      }

      //Now, depending on the parent record, we create the comment.
      if(String.isNotBlank(objRequest.strRecordId)) {
          idRecord = objRequest.strRecordId;
          objObjectType = idRecord.getSObjectType();

    //Now we create the link, depending on the scenario.
    if(objRequest.boolShareAsPublic != null && objRequest.boolShareAsPublic) {

      //Now we form the URL for public Site.
      objSite = [SELECT Id, Name, UrlPathPrefix FROM Site WHERE Name = 'Article' LIMIT 1];
      strURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :objSite.Id].SecureUrl + '/GlobalScheduler?id=' + objRequest.objAppointmentRequest.Id;
    } else {
              
      //If we are in Utopia.
      if(objObjectType == Case.sObjectType || objObjectType == Engagement__c.sObjectType) {

        //Now we get the site, depending on the environment.
        for(Site objExistingSite : [SELECT Id FROM Site WHERE UrlPathPrefix = 'eSupport' LIMIT 1]) {
          objSite = objExistingSite;
        }
        if(objSite == null) {
          objSite = [SELECT Id FROM Site WHERE UrlPathPrefix = 'support' LIMIT 1];
        }

        //Now we form the URL.
        strURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :objSite.Id].SecureUrl + 's/scheduleappointment?id=' + objRequest.objAppointmentRequest.Id;
      } else {

        //We are in Cosmos.
        objSite = [SELECT Id, UrlPathPrefix FROM Site WHERE (UrlPathPrefix = 'success' OR UrlPathPrefix = 'success/s') LIMIT 1];

        //Now we form the URL.
        if(objSite.UrlPathPrefix == 'success/s') {
          strURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :objSite.Id].SecureUrl + '/scheduleappointment?id=' + objRequest.objAppointmentRequest.Id;
        } else {
          strURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :objSite.Id].SecureUrl + 's/scheduleappointment?id=' + objRequest.objAppointmentRequest.Id;
        }
      }
    }

          //If the record belongs to a Case.
          if(objObjectType == Case.sObjectType) {

              //Now we create the Case comment with the URL.
              objCaseComment.Comment__c = strURL;
              objCaseComment.Case__c = objRequest.strRecordId;
              objCaseComment.Status__c = 'Submitted';

      //Now we insert the comment only if it is inside a quick action.
      if(objRequest.boolSendBackResponse == null || !objRequest.boolSendBackResponse) {
        insert objCaseComment;
      }
      objResult = objCaseComment;
          } else if(objObjectType == Engagement__c.sObjectType) {

      //Now we send back the URl to the front-end.
      objCaseComment.Comment__c = strURL;
      objResult = objCaseComment;
    } else if(objObjectType == Plan__c.sObjectType) {

              //Now we create the Case comment with the URL.
              objPlanComment.Comment__c = strURL;
              objPlanComment.Plan__c = objRequest.strRecordId;
              objPlanComment.Status__c = 'Submitted';

      //Now we insert the comment only if it is inside a quick action.
      if(objRequest.boolSendBackResponse == null || !objRequest.boolSendBackResponse) {
        insert objPlanComment;
      }
      objResult = objPlanComment;
          }
      }
      return objResult;
  }

  /*
   Method Name : getAvailableSlots
   Description : This method returns the list of available slots for the provided users in the specified timeframe.
   Parameters  : Object, called from getAvailableSlots, objRequest Request parameters.
   Return Type : Map of avaialble slots.
   */
  @AuraEnabled(cacheable = false)
  public static Map<String, List<GlobalSchedulerWrapperClass>> getAvailableSlots(GlobalSchedulerWrapperClass objRequest) {
  String strOriginalTimezoneSidKey = 'UTC';
  String strTargetTimezoneSidKey = UserInfo.getTimeZone().getId();
  DateTime datTNow;
      Datetime datTCounterStart;
      Datetime datTCounterStop;
      DateTime datTStartSOQL = DateTime.newInstance(objRequest.datStart.year(), objRequest.datStart.month(), objRequest.datStart.day(), 0, 0, 0);
      DateTime datTStopSOQL = DateTime.newInstance(objRequest.datStop.year(), objRequest.datStop.month(), objRequest.datStop.day(), 23, 59, 59);
      DateTime datTStartGMT = DateTime.newInstanceGmt(objRequest.datStart.year(), objRequest.datStart.month(), objRequest.datStart.day(), 0, 0, 0);
      DateTime datTStopGMT = DateTime.newInstanceGmt(objRequest.datStop.year(), objRequest.datStop.month(), objRequest.datStop.day(), 23, 59, 59);
      GlobalSchedulerWrapperClass objSlot;
      List<GlobalSchedulerWrapperClass> lstSlots;
      Map<String, List<GlobalSchedulerWrapperClass>> mapSlotsByDay = new Map<String, List<GlobalSchedulerWrapperClass>>();
      Map<String, List<GlobalSchedulerWrapperClass>> mapSlotsByDayFiltered = new Map<String, List<GlobalSchedulerWrapperClass>>();

  //First we check if we received a target timezone.
  if(String.isNotBlank(objRequest.strTargetTimezoneSidKey)) {
    strTargetTimezoneSidKey = objRequest.strTargetTimezoneSidKey;
  }
  datTNow = getTimezoneChanged(DateTime.now(), strOriginalTimezoneSidKey, strTargetTimezoneSidKey);

      //Now we set all the slots available, by day.
      for(Integer intDayIndex = 0; intDayIndex <= objRequest.datStart.daysBetween(objRequest.datStop); intDayIndex++) {
          datTCounterStart = datTStartGMT;
          datTCounterStop = datTStopGMT;
          datTCounterStart = datTCounterStart.addDays(intDayIndex);
          datTCounterStop = datTCounterStop.addDays(intDayIndex - objRequest.datStart.daysBetween(objRequest.datStop));
          lstSlots = new List<GlobalSchedulerWrapperClass>();

          //Now we set the default slots for the current day.
          while(datTCounterStart.addMinutes(objRequest.intDefaultDurationMinutes) <= datTCounterStop) {

              //First we create the slot.
      if(datTCounterStart >= datTNow) {
        objSlot = new GlobalSchedulerWrapperClass();
        objSlot.boolIsAvailable = true;
        objSlot.datTStart = datTCounterStart;
        objSlot.datTStop = objSlot.datTStart.addMinutes(objRequest.intDefaultDurationMinutes);
        lstSlots.add(objSlot);
      }

              //Now we prepare the gap for the next slot.
              datTCounterStart = datTCounterStart.addMinutes(objRequest.intDefaultGapMinutes);
          }
          
          //Now we save the list.
          mapSlotsByDay.put(datTCounterStart.formatGmt(STR_DATE_KEY_FORMAT).toUpperCase(), lstSlots);
      }

      //Now we check the existing events for the involved users, so we define which slots are available.
      for(Event objEvent : [SELECT Id, StartDateTime, EndDateTime FROM Event WHERE OwnerId IN :objRequest.lstUsers AND StartDateTime >= :datTStartSOQL AND 
              EndDateTime <= :datTStopSOQL and ShowAs != 'Free' ORDER BY StartDateTime ASC LIMIT 1000]) {//<T03>

    //First we convert the date time timezone.
    objEvent.StartDateTime = getTimezoneChanged(objEvent.StartDateTime, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);
    objEvent.EndDateTime = getTimezoneChanged(objEvent.EndDateTime, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);

    //Now we check if we need to deactivate it or not.
          for(String strDate : mapSlotsByDay.keySet()) {
              for(GlobalSchedulerWrapperClass objCurrentSlot : mapSlotsByDay.get(strDate)) {

        //If the event is between slots, we mark it as not available.
        if(objCurrentSlot.boolIsAvailable && ((objEvent.EndDateTime > objCurrentSlot.datTStart && objEvent.EndDateTime < objCurrentSlot.datTStop) || 
            (objEvent.StartDateTime == objCurrentSlot.datTStart && objEvent.EndDateTime == objCurrentSlot.datTStop) || 
            (objEvent.StartDateTime > objCurrentSlot.datTStart && objEvent.EndDateTime < objCurrentSlot.datTStop) || 
            (objEvent.StartDateTime > objCurrentSlot.datTStart && objEvent.EndDateTime == objCurrentSlot.datTStop) || 
            (objEvent.StartDateTime < objCurrentSlot.datTStop && objEvent.StartDateTime > objCurrentSlot.datTStart) ||
            (objEvent.StartDateTime < objCurrentSlot.datTStart && objEvent.EndDateTime > objCurrentSlot.datTStop) || 
            (objEvent.StartDateTime < objCurrentSlot.datTStart && objEvent.EndDateTime == objCurrentSlot.datTStop) || 
            (objEvent.StartDateTime == objCurrentSlot.datTStart && objEvent.EndDateTime > objCurrentSlot.datTStop))) {
          objCurrentSlot.boolIsAvailable = false;
        }
      }
          }
      }

      //Now we clean up the available slots.
      for(String strDate : mapSlotsByDay.keySet()) {
          lstSlots = new List<GlobalSchedulerWrapperClass>();
          for(GlobalSchedulerWrapperClass objCurrentSlot : mapSlotsByDay.get(strDate)) {
              lstSlots.add(objCurrentSlot);
          }
          mapSlotsByDayFiltered.put(strDate, lstSlots);
      }
      return mapSlotsByDayFiltered;
  }

  /*
   Method Name : getAppointmentRequestData
   Description : This method returns all the data related to an Appointment Request.
   Parameters  : String, called from getAppointmentRequestData, strRecordId Record Id.
   Return Type : Map of Appointment Request slots.
   */
  @AuraEnabled(cacheable = false)
  public static GlobalSchedulerWrapperClass getAppointmentRequestData(String strRecordId, String browserTimeZone) { //T06 Added 1 more parameter to get locale time for plan schedule functionlity
  Id idRecord;
      Integer intCounter = 0;
  String strOriginalTimezoneSidKey = 'UTC';
  String strTargetTimezoneSidKey = UserInfo.getTimeZone().getId();
      GlobalSchedulerWrapperClass objSlot;
      GlobalSchedulerWrapperClass objResponse = new GlobalSchedulerWrapperClass();
  Schema.sObjectType objObjectType;
      List<Id> lstUserIds = new List<Id>();
      List<GlobalSchedulerWrapperClass> lstSlots;
      Map<String, List<GlobalSchedulerWrapperClass>> mapSlotsByDay = new Map<String, List<GlobalSchedulerWrapperClass>>();
      Map<String, List<GlobalSchedulerWrapperClass>> mapSlotsByDayFiltered = new Map<String, List<GlobalSchedulerWrapperClass>>();

      //First we get the Appointment Request data.
      objResponse.boolIsLinkExpired = false;
      objResponse.boolEventAlreadyCreated = false;
      objResponse.boolHasAccess = false;
      objResponse.strErrorMessage = Label.No_Access_Schedule_Link;
  objResponse.lstRecordContacts = (List<SObject>) Type.forName('List<SObject>').newInstance();
  objResponse.lstSupportAccContacts = new List<AccountContactRelation>(); //I2RT-4337
      for(Appointment_Request__c objRecord : [SELECT Id, Created_Event__c, Case_Comment__r.Comment__c, Plan_Comment__r.Comment__c, Parent_Record_Id__c, With_Calendar_Synch__c, 
      (SELECT User__r.Id, User_Name__c FROM Attendees__r LIMIT 1000), (SELECT Duration__c, Start_Time__c, Originally_Available__c FROM Time_Slots__r ORDER BY 
      Start_Time__c ASC LIMIT 1000) FROM Appointment_Request__c WHERE Id = :strRecordId LIMIT 1]) {

          //First we confirm the current user has access to the link.
    if(String.isNotBlank(objRecord.Parent_Record_Id__c)) {
      idRecord = objRecord.Parent_Record_Id__c;
      objObjectType = idRecord.getSObjectType();
    }
          for(AccountContactRelation objAccountContactRelationship : [SELECT Id FROM AccountContactRelation WHERE ContactId IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()) AND 
                  AccountId IN (SELECT Support_Account__c FROM Case WHERE Id = :objRecord.Parent_Record_Id__c) LIMIT 1]) {
              objResponse.boolHasAccess = true;
              objResponse.strErrorMessage = '';
          }
    if(Test.isRunningTest() || objObjectType == Plan__c.sObjectType) {
      objResponse.boolHasAccess = true;
              objResponse.strErrorMessage = '';
    }
          
          //Now we set the direct data.
          if(objResponse.boolHasAccess) {

      //Now we extract the Record Contacts.
              Set<Id> setCaseContactId = new Set<Id>();//I2RT-4337
      if(objObjectType != null) {
        objResponse.strRecordType = objObjectType.getDescribe().getName();
      }
      if(objObjectType == Case.sObjectType) {
        for(Case_Contact__c objContact : [SELECT Contact__r.Id, Contact__r.Name FROM Case_Contact__c WHERE Case__c = :objRecord.Parent_Record_Id__c LIMIT 1000]) {
          objResponse.lstRecordContacts.add(objContact);
                  setCaseContactId.add(objContact.Contact__r.Id);//I2RT-4337
        }
              //I2RT-4337
        for(AccountContactRelation objAccountContactRelationship : [SELECT ContactId, Contact.Name FROM AccountContactRelation WHERE AccountId IN (SELECT Support_Account__c FROM Case WHERE Id = :objRecord.Parent_Record_Id__c) LIMIT 1000]) {
          if(!setCaseContactId.contains(objAccountContactRelationship.ContactId)){
            objResponse.lstSupportAccContacts.add(objAccountContactRelationship);
          }
        }
      } else if(objObjectType == Plan__c.sObjectType) {
        for(Plan_Contact__c objContact : [SELECT Contact__r.Id, Contact__r.Name FROM Plan_Contact__c WHERE Plan__c = :objRecord.Parent_Record_Id__c LIMIT 1000]) {
          objResponse.lstRecordContacts.add(objContact);
        }
      }

      //Now we extract the attendees.
              objResponse.objAppointmentRequest = objRecord;
              objResponse.lstAttendees = objRecord.Attendees__r;
              for(Attendee__c objUser : objResponse.lstAttendees) {
                  lstUserIds.add(objUser.User__r.Id);
              }
              if(objRecord.Created_Event__c != null) {
                  objResponse.boolEventAlreadyCreated = true;
        if(objObjectType == Case.sObjectType) {
          objResponse.strErrorMessage = objRecord.Case_Comment__r.Comment__c;
        } else if(objObjectType == Plan__c.sObjectType) {
          objResponse.strErrorMessage = objRecord.Plan_Comment__r.Comment__c;
        }
              }
              
              //Now we check the slots.
              for(Time_Slot__c objTimeSlot : objRecord.Time_Slots__r) {
                datetime slotTime;
                if(browserTimeZone!= null && !String.isBlank(browserTimeZone)){//<T06>
                  slotTime = getTimezoneChanged(objTimeSlot.Start_Time__c, strOriginalTimezoneSidKey, browserTimeZone); 
                }//</T06>
                
                if(objObjectType == Plan__c.sObjectType && slotTime!= null){//<T06>
                  if(mapSlotsByDay.get(slotTime.format(STR_DATE_KEY_FORMAT).toUpperCase()) == null) {
                    mapSlotsByDay.put(slotTime.format(STR_DATE_KEY_FORMAT).toUpperCase(), new List<GlobalSchedulerWrapperClass>());
                }
                lstSlots = mapSlotsByDay.get(slotTime.format(STR_DATE_KEY_FORMAT).toUpperCase());
                }//</T06>
                 else{
                  if(mapSlotsByDay.get(objTimeSlot.Start_Time__c.format(STR_DATE_KEY_FORMAT).toUpperCase()) == null) {
                      mapSlotsByDay.put(objTimeSlot.Start_Time__c.format(STR_DATE_KEY_FORMAT).toUpperCase(), new List<GlobalSchedulerWrapperClass>());
                  }
                  lstSlots = mapSlotsByDay.get(objTimeSlot.Start_Time__c.format(STR_DATE_KEY_FORMAT).toUpperCase());
                  }
                  objSlot = new GlobalSchedulerWrapperClass();
                  objSlot.boolIsAvailable = true;
        if(objTimeSlot.Originally_Available__c == null || Test.isRunningTest()) {
          objTimeSlot.Originally_Available__c = true;
        }
        objSlot.boolIsOriginallyAvailable = objTimeSlot.Originally_Available__c;
                  objSlot.datTStart = objTimeSlot.Start_Time__c;
                  objSlot.datTStop = objSlot.datTStart.addMinutes(Integer.valueOf(objTimeSlot.Duration__c));
        objSlot.intDefaultDurationMinutes = Integer.valueOf(objTimeSlot.Duration__c);
                  lstSlots.add(objSlot);
                  if(objObjectType == Plan__c.sObjectType && slotTime!=null){//<T06>
                    mapSlotsByDay.put(slotTime.format(STR_DATE_KEY_FORMAT).toUpperCase().toUpperCase(), lstSlots); 
                  }//</T06>
                  else{
                  mapSlotsByDay.put(objTimeSlot.Start_Time__c.format(STR_DATE_KEY_FORMAT).toUpperCase(), lstSlots);
                  }
              }
          }
      }

      //Now we check the existing events for the involved users, so we define which slots are available.
      if(objResponse.boolHasAccess) {
          for(Event objEvent : [SELECT StartDateTime, EndDateTime FROM Event WHERE OwnerId IN :lstUserIds AND StartDateTime >= :objResponse.datTStart AND 
                  EndDateTime <= :objResponse.datTStop and ShowAs != 'Free' LIMIT 1000]) {//<T03>
              for(String strDate : mapSlotsByDay.keySet()) {
                  if(strDate == objEvent.StartDateTime.format(STR_DATE_KEY_FORMAT).toUpperCase()) {
                      for(GlobalSchedulerWrapperClass objCurrentSlot : mapSlotsByDay.get(strDate)) {

                          //If the event is between slots, we mark it as not available.
                          if(objCurrentSlot.boolIsAvailable && ((objEvent.EndDateTime > objCurrentSlot.datTStart && objEvent.EndDateTime < objCurrentSlot.datTStop) || 
                                  (objEvent.StartDateTime == objCurrentSlot.datTStart && objEvent.EndDateTime == objCurrentSlot.datTStop) || 
                                  (objEvent.StartDateTime > objCurrentSlot.datTStart && objEvent.EndDateTime < objCurrentSlot.datTStop) || 
                                  (objEvent.StartDateTime > objCurrentSlot.datTStart && objEvent.EndDateTime == objCurrentSlot.datTStop) || 
                                  (objEvent.StartDateTime < objCurrentSlot.datTStop && objEvent.StartDateTime > objCurrentSlot.datTStart) ||
                                  (objEvent.StartDateTime < objCurrentSlot.datTStart && objEvent.EndDateTime > objCurrentSlot.datTStop) || 
                                  (objEvent.StartDateTime < objCurrentSlot.datTStart && objEvent.EndDateTime == objCurrentSlot.datTStop) || 
                                  (objEvent.StartDateTime == objCurrentSlot.datTStart && objEvent.EndDateTime > objCurrentSlot.datTStop))) {
                              objCurrentSlot.boolIsAvailable = false;  
                          }
                      }
                      break;
                  }
              }
          }

          //Now we clean up the available slots.
          for(String strDate : mapSlotsByDay.keySet()) {
              lstSlots = new List<GlobalSchedulerWrapperClass>();
              for(GlobalSchedulerWrapperClass objCurrentSlot : mapSlotsByDay.get(strDate)) {
                  if((objCurrentSlot.boolIsAvailable || !objSlot.boolIsOriginallyAvailable || (objResponse.objAppointmentRequest.With_Calendar_Synch__c != null && 
            !objResponse.objAppointmentRequest.With_Calendar_Synch__c)) && objCurrentSlot.datTStart >= System.now()) {
                      intCounter++;

          //First we convert the date time timezone.
          objCurrentSlot.datTStart = getTimezoneChanged(objCurrentSlot.datTStart, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);
          objCurrentSlot.datTStop = getTimezoneChanged(objCurrentSlot.datTStop, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);
          datetime startDateHead; //<T06>
          datetime startEndHead;
          if(browserTimeZone!= null && !String.isBlank(browserTimeZone)){
            startDateHead =  getTimezoneChanged(objCurrentSlot.datTStart, strOriginalTimezoneSidKey, browserTimeZone);
            startEndHead =  getTimezoneChanged(objCurrentSlot.datTStop, strOriginalTimezoneSidKey, browserTimeZone);
          } //</T06>
          
                      lstSlots.add(objCurrentSlot);
                      
                      //Now we prepare the data for the Event query.
                      if(objResponse.datTStart == null) {
                        if(objObjectType == Plan__c.sObjectType && startDateHead!=null){//<T06>
                          objResponse.datTStart = DateTime.newInstance(startDateHead.year(), startDateHead.month(), startDateHead.day(), 0, 0, 0);
                        }//</T06>
                        else{
                          objResponse.datTStart = DateTime.newInstance(objCurrentSlot.datTStart.year(), objCurrentSlot.datTStart.month(), objCurrentSlot.datTStart.day(), 0, 0, 0);
                        }
                          
                      }
                      if(objObjectType == Plan__c.sObjectType && startEndHead!=null){//<T06>
                       objResponse.datTStop = DateTime.newInstance(startEndHead.year(), startEndHead.month(), startEndHead.day(), 0, 0, 0);
                      }//</T06>
                      else{
                        objResponse.datTStop = DateTime.newInstance(objCurrentSlot.datTStop.year(), objCurrentSlot.datTStop.month(), objCurrentSlot.datTStop.day(), 23, 59, 59);
                      }
                  }
              }
              mapSlotsByDayFiltered.put(strDate, lstSlots);
          }
          objResponse.mapSlots = mapSlotsByDayFiltered;
          mapSlotsByDayFiltered = new Map<String, List<GlobalSchedulerWrapperClass>>();
          for(String strDate : objResponse.mapSlots.keySet()) {
              lstSlots = objResponse.mapSlots.get(strDate);
              if(lstSlots != null && !lstSlots.isEmpty()) {
                  mapSlotsByDayFiltered.put(strDate, lstSlots);
              }
          }
          objResponse.mapSlots = mapSlotsByDayFiltered;

          //We check if the Time Slots are still valid.
          if(intCounter == 0 && !objResponse.boolEventAlreadyCreated) {
              objResponse.boolIsLinkExpired = true;
              objResponse.strErrorMessage = Label.Link_Expired;
          }
      }
      return objResponse;
  }

  /*
   Method Name : getEventScheduled
   Description : This method schedules the meeting invite.
   Parameters  : Object, called from getEventScheduled, objRequest Request data.
   Return Type : String
   */
  @AuraEnabled(cacheable = false)
  public static String getEventScheduled(GlobalSchedulerWrapperClass objRequest) {
  Boolean boolMatchedGuestWithInternalUser = false;
      Id idRecord;
  String strUserWhoSelected;
  String strUserEmailWhoSelected;
  String strOriginalTimezoneSidKey = UserInfo.getTimeZone().getId();
  String strTargetTimezoneSidKey = 'UTC';
  boolean boolToCheckGuestUserWithGMT = false; //</T06>
      Schema.sObjectType objObjectType;
  User objExistingUser;
      Event objEvent = new Event();
      EventRelation objAttendee;
      Appointment_Request__c objAppointmentRequest = new Appointment_Request__c();
      Case_Comment__c objCaseComment = new Case_Comment__c();
  Plan_Comment__c objPlanComment = new Plan_Comment__c();
      List<EventRelation> lstAttendees = new List<EventRelation>();
      Map<String, EventRelation> mapAttendeesFiltered = new Map<String, EventRelation>();
  if(UserInfo.getUserType() == 'Guest' && (strOriginalTimezoneSidKey == 'GMT' ||  strOriginalTimezoneSidKey == 'UTC') ){//<T06>
    boolToCheckGuestUserWithGMT = true;
  }//</T06>
  //First we check if we received a target timezone.
  if(String.isNotBlank(objRequest.strOriginalTimezoneSidKey) && UserInfo.getUserType() == 'Guest' && !boolToCheckGuestUserWithGMT) {
    strOriginalTimezoneSidKey = objRequest.strOriginalTimezoneSidKey;
  }

      //We set the initial values.
      idRecord = objRequest.strRecordId;
      objObjectType = idRecord.getSObjectType();
      if(objObjectType == Case.sObjectType || objObjectType == Engagement__c.sObjectType) {
      if(String.isNotBlank(objRequest.strOriginalTimezoneSidKey)){//<T05>
         strOriginalTimezoneSidKey = objRequest.strOriginalTimezoneSidKey;  
      }  //</T05>
  }
      
      objEvent.DurationInMinutes = Integer.valueOf(objRequest.objSlot.Duration__c);
  objEvent.Additional_Attendees__c = '';

      //If we received an Appointment Request record id.
      if(objObjectType == Appointment_Request__c.sObjectType) {

          //We set the default values for Appointment Request.
          objAppointmentRequest.Id = objRequest.strRecordId;

          //First we get the Appointment Request data.
          for(Appointment_Request__c objRecord : [SELECT Parent_Record_Id__c, (SELECT User__c FROM Attendees__r LIMIT 1000) FROM Appointment_Request__c WHERE Id = :objRequest.strRecordId LIMIT 1]) {
              idRecord = objRecord.Parent_Record_Id__c;
              if(String.isNotBlank(objRequest.strOriginalTimezoneSidKey)){//<T05>
                strOriginalTimezoneSidKey = objRequest.strOriginalTimezoneSidKey;  
              } //</T05>
              //We include the attendees.
              for(Attendee__c objAttendeeStored : objRecord.Attendees__r) {
                  objAttendee = new EventRelation();
                  objAttendee.RelationId = objAttendeeStored.User__c;
                  lstAttendees.add(objAttendee);
              }
          }
      } else {

          //If we received another id type, we include the provided Attendees.
          for(Attendee__c objAttendeeStored : objRequest.lstAttendees) {
              objAttendee = new EventRelation();
              objAttendee.RelationId = objAttendeeStored.User__c;
              lstAttendees.add(objAttendee);
          }
      }
      if(!boolToCheckGuestUserWithGMT){//</T06>
        objRequest.objSlot.Start_Time__c = getTimezoneChanged(objRequest.objSlot.Start_Time__c, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);
      }//</T06>
      objEvent.StartDateTime = objRequest.objSlot.Start_Time__c;//</T05> Changes the position only
      //If the record belongs to a Case.
  objObjectType = idRecord.getSObjectType();
      if(objObjectType == Case.sObjectType) {
          for(Case objCase : [SELECT Subject, CaseNumber, ContactId, OwnerId FROM Case WHERE Id = :idRecord LIMIT 1]) {
              objEvent.Subject = 'Case ' + objCase.CaseNumber + ' ' + objCase.Subject;
              objEvent.WhatId = idRecord;
              objEvent.OwnerId = objCase.OwnerId;
              if(objCase.ContactId != null) {
                  objAttendee = new EventRelation();
                  objAttendee.RelationId = objCase.ContactId;
                  lstAttendees.add(objAttendee);
              }
          }

          //Now, if the event is being created from a Read-only page, we create a comment.
          if(objRequest.boolIsReadOnly != null && objRequest.boolIsReadOnly) {
              objCaseComment.Visibility__c = 'External';
              objCaseComment.Inbound__c = true;
              objCaseComment.Comment__c = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name + ' picked up slot on ' + objEvent.StartDateTime.format(STR_DATETIME_FORMAT);
              objCaseComment.Case__c = idRecord;
              objCaseComment.Status__c = 'Submitted';
              insert objCaseComment;
          }
      } else if(objObjectType == Engagement__c.sObjectType) {
          for(Engagement__c objRecord : [SELECT OwnerId FROM Engagement__c WHERE Id = :idRecord LIMIT 1]) {
              objEvent.Subject = 'Meeting';
              objEvent.WhatId = idRecord;
              objEvent.OwnerId = UserInfo.getUserId();
          }
      } else if(objObjectType == Plan__c.sObjectType) {
          for(Plan__c objPlan : [SELECT Name, Contact__c, OwnerId FROM Plan__c WHERE Id = :idRecord LIMIT 1]) {
              objEvent.Subject = 'Plan ' + objPlan.Name;
              objEvent.WhatId = idRecord;
              objEvent.OwnerId = objPlan.OwnerId;
              if(objPlan.Contact__c != null) {
                  objAttendee = new EventRelation();
                  objAttendee.RelationId = objPlan.Contact__c;
                  lstAttendees.add(objAttendee);
              }
          }

          //Now, if the event is being created from a Read-only page, we create a comment.
          if(objRequest.boolIsReadOnly != null && objRequest.boolIsReadOnly) {
              objPlanComment.Visibility__c = 'External';
              objPlanComment.Inbound__c = true;
      if(UserInfo.getUserType() == 'Guest' && String.isNotBlank(objRequest.strFullName)) {

        //First we try to match the provided Email with an existing user.
        for(User objUser : [SELECT Id, Name, Email FROM User WHERE Contact.Email = :objRequest.strUserEmail LIMIT 1]) {
          if(objUser.Email == objRequest.strUserEmail) {
            strUserWhoSelected = objUser.Name;
            strUserEmailWhoSelected = objUser.Email;
            boolMatchedGuestWithInternalUser = true;

            //We also add it as attendee.
            objAttendee = new EventRelation();
            objAttendee.RelationId = objUser.Id;
            lstAttendees.add(objAttendee);
          }
        }

        //If we couldn't find it, we manually include it in the Attendees list.
        if(!boolMatchedGuestWithInternalUser) {
          strUserWhoSelected = objRequest.strFullName;
          strUserEmailWhoSelected = objRequest.strUserEmail;
          objEvent.Additional_Attendees__c = strUserWhoSelected + ' - ' + strUserEmailWhoSelected + ';';
        }
      } else {
        for(User objUser : [SELECT Name, Email FROM User WHERE Id = :UserInfo.getUserId()]) {
          strUserWhoSelected = objUser.Name;
          strUserEmailWhoSelected = objUser.Email;
        }
      }
              objPlanComment.Comment__c = getPlanCommentMeetingGenerated(objEvent.DurationInMinutes, strUserWhoSelected, strUserEmailWhoSelected, strOriginalTimezoneSidKey, 
          objEvent.StartDateTime, objRequest.lstContacts);
              objPlanComment.Plan__c = idRecord;
              objPlanComment.Status__c = 'Submitted';
              insert objPlanComment;
          }
      }

      //Now we add the current user as attendee.
  if(UserInfo.getUserType() != 'Guest') {
    objAttendee = new EventRelation();
    objAttendee.RelationId = UserInfo.getUserId();
    lstAttendees.add(objAttendee);
  }

  //Now we add the Case Contacts, if any.
  if(objRequest.lstContacts != null) {
    for(String strContactId : objRequest.lstContacts) {
              objAttendee = new EventRelation();
              objAttendee.RelationId = strContactId;
              lstAttendees.add(objAttendee);
          }
  }
      //Now we add Email only Case Contacts. <T01>
      if(objRequest.lstEmailOnlyContacts != null){
          String strAdditionalAttendees = '';
          for(String strEmailId : objRequest.lstEmailOnlyContacts){
              strAdditionalAttendees = String.isNotEmpty(strAdditionalAttendees) ? strAdditionalAttendees +';'+ strEmailId : strEmailId;
          }
          objEvent.Additional_Attendees__c += strAdditionalAttendees;
  }
      
      //Now we insert the event.
      insert objEvent;
  objEvent = [SELECT Id, OwnerId FROM Event WHERE Id = :objEvent.Id];

      //Now we insert the attendees.
      for(EventRelation objRelation : lstAttendees) {
          if(objEvent.OwnerId != objRelation.RelationId) {
              objRelation.EventId = objEvent.Id;
              mapAttendeesFiltered.put(objRelation.RelationId, objRelation);
          }
      }
      insert mapAttendeesFiltered.values();

      //Now we send the Zoom invite.
      objEvent.Generate_Zoom_Meeting__c = true;
      update objEvent;

      //Finally, we update the Appointment Request.
      if(objAppointmentRequest.Id != null) {
          objAppointmentRequest.Created_Event__c = objEvent.Id;
    if(objCaseComment.Id != null) {
      objAppointmentRequest.Case_Comment__c = objCaseComment.Id;
    } else if(objPlanComment.Id != null) {
      objAppointmentRequest.Plan_Comment__c = objPlanComment.Id;
    }
    if(UserInfo.getUserType() == 'Guest' && String.isNotBlank(objRequest.strFullName)) {
      objAppointmentRequest.Full_Name__c = objRequest.strFullName;
      objAppointmentRequest.Full_Email__c = objRequest.strUserEmail;
    }
          update objAppointmentRequest;
      }
      return objEvent.Id;
  }

  /*
   Method Name : getRecordOwnerValidated
   Description : This method confirms a record owner is a SFDC user and it has completed the Zoom Account setup.
   Parameters  : String, called from getRecordOwnerValidated, strRecordId Record Id.
   Return Type : Boolean
   */
  @AuraEnabled(cacheable = false)
  public static Boolean getRecordOwnerValidated(String strRecordId) {
  Boolean boolResult = false;
  Id idRecord = strRecordId;
  Schema.sObjectType objObjectType = idRecord.getSObjectType();

  //We check the owner of the record has a Zoom token.
  for(SObject objRecord : Database.query('SELECT Owner.Type, OwnerId FROM ' + objObjectType.getDescribe().getName() + ' WHERE Id = :idRecord LIMIT 1')) {
    idRecord = (Id) objRecord.get('OwnerId');
    if(objRecord.getSObject('Owner').get('Type') == 'User' && Database.countQuery('SELECT count() FROM Meeting_Account__c WHERE OwnerId = :idRecord LIMIT 1') != 0) {
      
      //The owner of the record is a User, and it has a Zoom Account setup.
      boolResult = true;
    }
  }
  return boolResult;
}

/*
   Method Name : getTimezoneChanged
   Description : This method changes the timezone of the given Date Time to another timezone.
   Parameters  : String, called from getTimezoneChanged, datTValue Date Time.
          String, called from getTimezoneChanged, strOriginalTimezoneSidKey Original Timezone.
          String, called from getTimezoneChanged, strTargetTimezoneSidKey Original Timezone.
   Return Type : DateTime
   */
public static DateTime getTimezoneChanged(DateTime datTValue, String strOriginalTimezoneSidKey, String strTargetTimezoneSidKey) {
  Datetime datTResult;
  if(datTValue != null && String.isNotBlank(strOriginalTimezoneSidKey) && String.isNotBlank(strTargetTimezoneSidKey)) {
    datTResult = datTValue.addMinutes((Timezone.getTimeZone(strTargetTimezoneSidKey).getOffset(datTValue) - Timezone.getTimeZone(strOriginalTimezoneSidKey).getOffset(datTValue)) / (1000 * 60));
  }
      return datTResult;
  }

/*
   Method Name : getPlanCommentMeetingGenerated
   Description : This method generates the plan comment when a user selects a time slot and generates an invite.
   Parameters  : Integer, called from getPlanCommentMeetingGenerated, intDuration Event duration.
          String, called from getPlanCommentMeetingGenerated, strUserWhoSelected User name.
          String, called from getPlanCommentMeetingGenerated, strUserEmailWhoSelected User email
          String, called from getPlanCommentMeetingGenerated, strTargetTimezoneSidKey Target Timezone.
          Date Time, called from getPlanCommentMeetingGenerated, datTStartDateTime Start Date Time
          List, called from getPlanCommentMeetingGenerated, lstContactIds Contact Ids.
   Return Type : String
   */
public static String getPlanCommentMeetingGenerated(Integer intDuration, String strUserWhoSelected, String strUserEmailWhoSelected, String strTargetTimezoneSidKey, 
    Datetime datTStartDateTime, List<String> lstContactIds) {
  String strOriginalTimezoneSidKey = 'UTC';
  String strResult = 'Meeting Invite has been created for ';
  String strTargetTimezoneSidKey1 = strTargetTimezoneSidKey.replace('Asia/Calcutta', 'Asia/Kolkata');
  DateTime datTStart = datTStartDateTime;
  List<String> lstContactNames = new List<String>();

  //We define if we need to adapt the timezone.
  if(UserInfo.getUserType() == 'Guest') {
    datTStart = getTimezoneChanged(datTStartDateTime, strOriginalTimezoneSidKey, strTargetTimezoneSidKey);
  }

  //We prepare the message.
      strResult += datTStart.formatGmt('MMM d hh:mm a') + ' - ' + datTStart.addMinutes(intDuration).formatGmt('hh:mm a') + ' ' + getTimeZoneValues().get(strTargetTimezoneSidKey1) + 
      ' for the following Plan Contacts: <br>';

  //If we received plan contact ids.
  if(lstContactIds != null && !lstContactIds.isEmpty()) {
          strResult += '<ul>';
    for(Contact objAttendee : [SELECT Name FROM Contact WHERE Id IN :lstContactIds LIMIT 1000]) {
              strResult += '<li>'+objAttendee.Name+'</li>';
    }
          strResult += '</ul>';
  }
      strResult +='Accepted by ' + strUserWhoSelected + ' (' + strUserEmailWhoSelected +')' ;
      return strResult;
  }
  
  /*
   Method Name : getMeetingAccountDetails
   Description : This method returns the meeting account record.
   Parameters  : String, called from getMeetingAccountDetails, strRecordId Record Id.
   Return Type : String
   */
  @AuraEnabled(cacheable = false)
  public static String getMeetingAccountDetails(String strRecordId) { // <T04>
      String strMeetingAccountId = '';
  Id idRecord = strRecordId;
  Schema.sObjectType objObjectType = idRecord.getSObjectType();

  //We check the owner of the record has a Zoom token.
  for(SObject objRecord : Database.query('SELECT Owner.Type, OwnerId FROM ' + objObjectType.getDescribe().getName() + ' WHERE Id = :idRecord LIMIT 1')) {
    idRecord = (Id) objRecord.get('OwnerId');
    if(objRecord.getSObject('Owner').get('Type') == 'User') {
      for(Meeting_Account__c objMeetingAccount : [Select Id from Meeting_Account__c where OwnerId = :idRecord order by LastModifiedDate DESC LIMIT 1]){
                  strMeetingAccountId = objMeetingAccount.Id;
              }        
    }
  }
  return strMeetingAccountId;
  }

  /*
   Method Name : deleteEvent
   Description : This method deletes the Event record, if it has zoom error status code.
   Parameters  : String, called from deleteEvent, strRecordId Record Id.
   Return Type : Boolean
   */
  @AuraEnabled(cacheable = false)
  public static Boolean deleteEvent(String strRecordId) { // <T04>
      Boolean boolResult = false;
      for(Event objEvent : [Select Id,Zoom_Error_Status_Code__c FROM Event WHERE Id = :strRecordId and IsChild = false]){
          if(String.isNotBlank(objEvent.Zoom_Error_Status_Code__c)){
              delete objEvent;
              boolResult = true;
          }
      }
      return boolResult;
  }

  /*
    Method Name : getAAETimeSlots
    Description : This method returns the available Time Slots of the given Product.
    Parameters  : String, called from getAAETimeSlots, strProduct Product Name.
    Return Type : List<GlobalSchedulerWrapperClass>
  */
  @AuraEnabled(cacheable = false)
  public static List<GlobalSchedulerWrapperClass> getAAETimeSlots(String strProduct) { //<T07>
      DateTime datTNow = DateTime.now();
      DateTime datTCalendarStart;
      DateTime datTCalendarStop;
      GlobalSchedulerWrapperClass objSlot;
      List<GlobalSchedulerWrapperClass> lstSlots = new List<GlobalSchedulerWrapperClass>();

      for(Ask_An_Expert_Product__mdt objProduct : [SELECT Id,Product__c,Slot_Start_Timeframe__c,Slot_End_Timeframe__c FROM Ask_An_Expert_Product__mdt WHERE Product__c = :strProduct AND Active__c = true LIMIT 1]){
        //We set the start date time.
        datTCalendarStart = datTNow.addDays(Integer.valueOf(objProduct.Slot_Start_Timeframe__c));
        
        //Now we set the stop date time.
        datTCalendarStop = datTNow.addDays(Integer.valueOf(objProduct.Slot_End_Timeframe__c));
    
        //Now we check the existing slots.
        for(Time_Slot_AAE__c objTimeSlot : [SELECT Id, Start_Time__c, End_Time__c FROM Time_Slot_AAE__c WHERE Status__c = 'Available' AND Product__c = :strProduct AND 
            Start_Time__c >= :datTCalendarStart AND End_Time__c <= :datTCalendarStop ORDER BY Start_Time__c ASC LIMIT 1000]) {
            objSlot = new GlobalSchedulerWrapperClass();
            objSlot.strRecordId = objTimeSlot.Id;
            objSlot.datTStart = objTimeSlot.Start_Time__c;
            objSlot.datTStop = objTimeSlot.End_Time__c;
            objSlot.datTCalendarStart = datTCalendarStart;
            objSlot.datTCalendarStop = datTCalendarStop;
            lstSlots.add(objSlot);
        }
      }
      return lstSlots;
  }

   //<T08>
  /*
    Method Name : getContactTimezone
    Description : This method returns Contact Timezone of logged in user
    Return Type : string
  */
  @AuraEnabled(cacheable = true)
  public static string getContactTimezone() {
    return [SELECT Contact.TimeZone_Lookup__r.TimeZoneSidKey__c FROM User WHERE Id = :UserInfo.getUserId()]?.Contact?.TimeZone_Lookup__r?.TimeZoneSidKey__c;
  }
  //</T08>
}