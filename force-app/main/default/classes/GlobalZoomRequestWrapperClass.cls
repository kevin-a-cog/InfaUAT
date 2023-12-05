/*
 * Name			:	GlobalZoomRequestWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	Request wrapper class for Zoom Integration.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalZoomRequestWrapperClass {
    
	//Public variables. 
	@AuraEnabled
	public Boolean boolAuthenticationIsBearer {get; set;} 
	@AuraEnabled
	public String strEndpointLabel {get; set;}
	@AuraEnabled
	public String strBody {get; set;}
	@AuraEnabled
	public String strUserId {get; set;}
	@AuraEnabled
	public String strUserName {get; set;}
	@AuraEnabled
	public String strUserEmail {get; set;}
	@AuraEnabled
	public String strUID {get; set;}
	@AuraEnabled
	public DateTime datTStartTime {get; set;}
	@AuraEnabled
	public Map<String, String> mapHeaders {get; set;}
	@AuraEnabled
	public Map<String, String> mapPathVariables {get; set;}

	//Meetng parameters.
	@AuraEnabled
	public Integer type {get; set;}
	@AuraEnabled
	public Integer duration {get; set;}
	@AuraEnabled
	public String topic {get; set;}
	@AuraEnabled
	public String timezone {get; set;}
	@AuraEnabled
	public String agenda {get; set;}
	@AuraEnabled
	public DateTime start_time {get; set;}
}