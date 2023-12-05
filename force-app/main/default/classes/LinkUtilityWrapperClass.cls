/*
 * Name			:	LinkUtilityWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/25/2021
 * Description	:	Wrapper class for Quick Links.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/25/2021		N/A				Initial version.			N/A
 */
public class LinkUtilityWrapperClass {

	//Public variables.
	@AuraEnabled
	public Boolean boolDisplayDropDown {
		get {
			Boolean boolResult = false;
			if(boolCanAdd || boolCanEdit || boolCanDelete) {
				boolResult = true;
			}
			return boolResult;
		}
	}
	@AuraEnabled
	public Boolean boolHasAllAccess {get; set;}
	@AuraEnabled
	public Boolean boolCanAdd {get; set;}
	@AuraEnabled
	public Boolean boolCanEdit {get; set;}
	@AuraEnabled
	public Boolean boolCanDelete {get; set;}
	@AuraEnabled
	public Link__c objLink {get; set;}
}