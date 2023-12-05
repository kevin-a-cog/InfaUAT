/*
 * Name			:	GlobalZoomEndpointWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	Endpoint wrapper class for Zoom Integration.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalZoomEndpointWrapperClass {
    
	//Public variables.
	@AuraEnabled
	public String strClientId {get; set;}
	@AuraEnabled
	public String strClientSecret {get; set;}
	@AuraEnabled
	public String strEndpoint {get; set;}
	@AuraEnabled
	public String strMethod {get; set;}
	@AuraEnabled
	public String strRedirectURI {get; set;}
}