/*
 * Name			:	CSMPlanProductsWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	1/28/2022
 * Description	:	Wrapper class for Grouped Plan Products.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		1/28/2022		N/A				Initial version.			N/A
 */
public class CSMPlanProductsWrapperClass {

	//Public variables.
	@AuraEnabled
	public Boolean boolRisk {get; set;}
	@AuraEnabled
	public String Id {get; set;}
	@AuraEnabled
	public String Name {get; set;}
	@AuraEnabled
	public String strProductName {get; set;}
	@AuraEnabled
	public String strContract {get; set;}
	@AuraEnabled
	public String strContractId {get; set;}
	@AuraEnabled
	public String strRenewalOpportunity {get; set;}
	@AuraEnabled
	public String strRenewalOpportunityId {get; set;}
	@AuraEnabled
	public String strPlanId {get; set;}
	@AuraEnabled
	public String strDeliveryMethod {get; set;}
	@AuraEnabled
	public String strOfferingType {get; set;}
	@AuraEnabled
	public String strStatus {get; set;}
	@AuraEnabled
	public List<IconWrapper> lstIcons {get; set;}
	@AuraEnabled
	public Map<String, String> mapStyles {get; set;}

	//Actions wrapper class.
	public class IconWrapper {

		//Public variables.
		//
		@AuraEnabled
		public Boolean boolIsStaticResource {get; set;}
		@AuraEnabled
		public Integer intAction {get; set;}
		@AuraEnabled
		public Integer intWidth {get; set;}
		@AuraEnabled
		public String strURL {get; set;}
	}
}