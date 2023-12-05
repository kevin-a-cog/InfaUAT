/*
 * Name			:	GCSCancelZoomMeetingController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/02/2021
 * Description	:	This controller cancels Zoom Meetings.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description										Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/02/2021		N/A				Initial version.								N/A
 Vignesh D				11/26/2021		I2RT-4414		Send cancel invites for additional attendees	T01
 Vignesh D				3/27/2023		I2RT-7749		Cancel Zoom meetings from future method			T02
 Vignesh D				4/04/2023		I2RT-8057		Updated correct email address for UAT			T03
 */
public without sharing class GCSCancelZoomMeetingController {

	//Public variables.
    public static final String FROMSIT = 'supportqa@informatica.com';
    public static final String FROMUAT = 'supportuat_local@informatica.com'; //<T03>
    public static final String FROMPROD = 'support@informatica.com';

	/*
	 Method Name : getMeetingCanceled
	 Description : This method cancels the zoom meeting related to the given Event Id.
	 Parameters	 : String, called from getMeetingCanceled, strRecordId Event Id.
	 Return Type : Boolean
	 */
	@AuraEnabled(cacheable = false)
    public static Boolean getMeetingCanceled(String strRecordId) {
		Boolean boolResult = false;
		String strFromAddress = ' ';  
		Messaging.EmailFileAttachment objAttachment = new Messaging.EmailFileAttachment();
		Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();
		HttpResponse objResponse = new HttpResponse();
		GlobalZoomRequestWrapperClass objRequest = new GlobalZoomRequestWrapperClass();
		GlobalZoomResponseWrapperClass objWrappedResponse = new GlobalZoomResponseWrapperClass();
		Set<String> setIds = new Set<String>();
		List<String> lstEmails = new List<String>();
		Map<String, String> mapParticipants = new Map<String, String>();
		Set<String> setAdditionalAttendeesEmails = new Set<String>(); // <T01>

		//First we make sure we received a record id.
		if(String.isNotBlank(strRecordId)) {

			//Now we obtain the Meeting Id.
			for(Event objEvent : [SELECT Id, Subject,ServiceAppointmentId, Zoom_Meeting_Id__c, OwnerId, StartDateTime, Owner.Name, Owner.Email, DurationInMinutes, Location, Additional_Attendees__c,
					(SELECT RelationId FROM EventRelations) FROM Event WHERE Id = :strRecordId AND Zoom_Meeting_Id__c <> NULL]) {
				setIds.add(objEvent.OwnerId);

				//If the event has attendees.
				if(objEvent.EventRelations != null && !objEvent.EventRelations.isEmpty()) {
					for(EventRelation objRelation : objEvent.EventRelations) {
						setIds.add(objRelation.RelationId);
					}
				}

				//If the event has additional attendees. <T01>
				if(String.isNotEmpty(objEvent?.Additional_Attendees__c)){
					for(String strEmailId : objEvent.Additional_Attendees__c.split(';')){
						setAdditionalAttendeesEmails.add(strEmailId);
					}
				}

				//Now we prepare the request.
				objRequest.duration = objEvent.DurationInMinutes;
				objRequest.topic = objEvent.Subject;
				objRequest.boolAuthenticationIsBearer = true;
				objRequest.strEndpointLabel = 'Cancel Meeting';
				objRequest.strUserId = objEvent.OwnerId;
				objRequest.strUID = objEvent.Zoom_Meeting_Id__c;
				objRequest.datTStartTime = objEvent.StartDateTime;
				objRequest.mapHeaders = new Map<String, String>();
				objRequest.mapHeaders.put('Content-Type', 'application/json');
				objRequest.mapPathVariables = new Map<String, String>();
				objRequest.mapPathVariables.put('{meetingId}', objEvent.Zoom_Meeting_Id__c);
				objRequest.strUserName = objEvent.Owner.Name;
				objRequest.strUserEmail = objEvent.Owner.Email;
				objWrappedResponse.join_url = objEvent.Location;

				//Now we execute the callout.
				objResponse = GlobalZoomUtilitiesClass.executeZoomCallout(objRequest);
        
				//Now we analyze the response.
				if(objResponse.getStatusCode() == 204 || Test.isRunningTest()) {
					boolResult = true;
                    //Now we delete the event.
                    
                    if(objEvent.ServiceAppointmentId != null){
                        delete [Select Id from Serviceappointment where Id = :objEvent.ServiceAppointmentId];                        
                    } else {
					
					delete objEvent;
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

					//Now we send the invite cancellation.
					if(!lstEmails.isEmpty()) {
	
						//We first set the calendar data.
						objAttachment.contenttype = 'text/calendar; method=CANCEL';
						objAttachment.inline = true;
						objAttachment.filename = objEvent.Subject + '.ics';
						objAttachment.body = GlobalZoomUtilitiesClass.generateMeetingCancellation(objRequest, objWrappedResponse, mapParticipants);
	
						//Now we prepare the email.
						if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
							if(URL.getSalesforceBaseUrl().toExternalForm().contains('infa--uat')){
								strFromAddress = FROMUAT;                
							} else {
								strFromAddress = FROMSIT;                
							}            
						} else {
							strFromAddress = FROMPROD;           
						}
						for(OrgWideEmailAddress objSender : [SELECT Id FROM OrgWideEmailAddress WHERE Address = :strFromAddress]) {
							objMessage.OrgWideEmailAddressId = objSender.Id;
						}
						objMessage.ToAddresses = lstEmails;
						objMessage.Subject = 'Canceled: ' + objEvent.Subject;
						objMessage.PlainTextBody = '';
						objMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { objAttachment });
	
						//Finally we send the email.
						Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { objMessage });
					}
				}
			}
		}
		return boolResult;
    }

	/*
	 Method Name : getMeetingCanceledInFuture
	 Description : This method cancels the zoom meeting related to the given Event Id in future method.
	 Parameters	 : String, called from getMeetingCanceledInFuture, strRecordId Event Id.
	 Return Type : Boolean
	 */
	@future(callout = true)
	public static void getMeetingCanceledInFuture(String strRecordId) { //<T02>
		getMeetingCanceled(strRecordId);
	}
}