/*
 * Name			:	GlobalNextBestActionWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/14/2021
 * Description	:	Wrapper class for Global Next Best Action.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/14/2021		N/A				Initial version.			N/A
 */
public class GlobalNextBestActionWrapperClass {

	//Public variables.
	@AuraEnabled
	public Boolean boolAccepted {get; set;}
	@AuraEnabled
	public Id idRecord {get; set;}
	@AuraEnabled
	public Id idParentRecord {get; set;}
	@AuraEnabled
	public String strRecommendation {get; set;}
	@AuraEnabled
	public String strActionType {get; set;}
	@AuraEnabled
	public String strActionTarget {get; set;}
	@AuraEnabled
	public String strActionData {get; set;}
	@AuraEnabled
	public GlobalNextBestActionWrapperClass objAcceptedAction {get; set;}
	@AuraEnabled
	public GlobalNextBestActionWrapperClass objRejectedAction {get; set;}
}