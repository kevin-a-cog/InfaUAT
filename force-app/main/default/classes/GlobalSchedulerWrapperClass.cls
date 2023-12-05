/*
 * Name			:	GlobalSchedulerWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/22/2021
 * Description	:	Wrapper class for Scheduler feature.

 Change History
 *************************************************************************************************************
 Modified By			Date			Jira No.		Description										Tag
 *************************************************************************************************************
 Monserrat Pedroza		7/22/2021		N/A				Initial version.								N/A
 Vignesh D				11/24/2021		I2RT-4414		Wrapper variables to store email				T01
 														only case contacts
 Vignesh D				12/06/2021		I2RT-5110		Wrapper variable to store primary				T02
														case contact
 Vignesh D				9/20/2023		I2RT-9063		Wrapper variable to store Slot Start Timeframe	T03
 														& Slot End Timeframe for Ask An Expert
                                                      	scheduler
 */
public class GlobalSchedulerWrapperClass {

	//Public variables.
	@AuraEnabled
	public Boolean boolShareAsPublic {get; set;}
	@AuraEnabled
	public Boolean boolIsOriginallyAvailable {get; set;}
	@AuraEnabled
	public Boolean boolHasAccess {get; set;}
	@AuraEnabled
	public Boolean boolEventAlreadyCreated {get; set;}
	@AuraEnabled
	public Boolean boolIsReadOnly {get; set;}
	@AuraEnabled
	public Boolean boolSendBackResponse {get; set;}
	@AuraEnabled
	public Boolean boolIsLinkExpired {get; set;}
	@AuraEnabled
	public Boolean boolIsAvailable {get; set;}
	@AuraEnabled
	public Integer intDefaultDurationMinutes {get; set;}
	@AuraEnabled
	public Integer intDefaultGapMinutes {get; set;}
	@AuraEnabled
	public String strRecordType {get; set;}
	@AuraEnabled
	public String strRelatedToId {get; set;}
	@AuraEnabled
	public String strOriginalTimezoneSidKey {get; set;}
	@AuraEnabled
	public String strTargetTimezoneSidKey {get; set;}
	@AuraEnabled
	public String strSlotsURL {get; set;}
	@AuraEnabled
	public String strErrorMessage {get; set;}
	@AuraEnabled
	public String strRecordId {get; set;}
	@AuraEnabled
	public String strPrimaryContactId {get; set;} // <T02>
	@AuraEnabled
	public String strStartTime {get; set;}
	@AuraEnabled
	public String strStopTime {get; set;}
	@AuraEnabled
	public String strFullName {get; set;}
	@AuraEnabled
	public String strUserEmail {get; set;}
	@AuraEnabled
	public Date datStart {get; set;}
	@AuraEnabled
	public Date datStop {get; set;}
	@AuraEnabled
	public DateTime datTStart {get; set;}
	@AuraEnabled
	public DateTime datTStop {get; set;}
	@AuraEnabled
	public DateTime datTCalendarStart {get; set;} // <T03>
	@AuraEnabled
	public DateTime datTCalendarStop {get; set;} // <T03>
	@AuraEnabled
	public User objUser {get; set;}
	@AuraEnabled
	public Time_Slot__c objSlot {get; set;}
	@AuraEnabled
	public Appointment_Request__c objAppointmentRequest {get; set;}
	@AuraEnabled
	public List<String> lstContacts {get; set;}
	@AuraEnabled
	public List<String> lstEmailOnlyContacts {get; set;} // <T01>
	@AuraEnabled
	public List<String> lstUsers {get; set;}
	@AuraEnabled
	public List<User> lstAdditionalUsers {get; set;}
	@AuraEnabled
	public List<User> lstTeamMembers {get; set;}
	@AuraEnabled
	public List<SObject> lstRecordContacts {get; set;}
	@AuraEnabled
	public List<SObject> lstEmailOnlyCaseContacts {get; set;} // <T01>
	@AuraEnabled
	public List<SObject> lstSupportAccContacts {get; set;} //I2RT-4337
	@AuraEnabled
	public List<Attendee__c> lstAttendees {get; set;}
	@AuraEnabled
	public List<Time_Slot__c> lstSlots {get; set;}
	@AuraEnabled
	public Map<String, List<GlobalSchedulerWrapperClass>> mapSlots {get; set;}
}