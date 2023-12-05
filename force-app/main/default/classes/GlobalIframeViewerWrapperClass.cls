/*
 * Name			:	GlobalIframeViewerWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/12/2021
 * Description	:	Wrapper class for Global Iframe Viewer

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/12/2021		N/A				Initial version.			N/A
 */
public class GlobalIframeViewerWrapperClass {

	//Public variables.
	@AuraEnabled
	public User objUser {get; set;}
	@AuraEnabled
	public sObject objRecord {get; set;}
}