/*
 * Name			:	EngagementUnitServiceWrapper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2023
 * Description	:	Wrapper class for Engagement Unit Service class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2023		N/A				Initial version.			N/A
 */
public virtual class EngagementUnitServiceWrapper {

	//Public variables.
	@AuraEnabled
	public Boolean boolResult {get; set;}
	@AuraEnabled
	public Boolean boolIsInternalUser {get; set;}
	@AuraEnabled
	public Id idAccount {get; set;}
	@AuraEnabled
	public Id idContact {get; set;}
	@AuraEnabled
	public Id idUser {get; set;}
	@AuraEnabled
	public Integer intUnits {get; set;}
	@AuraEnabled
	public String strType {get; set;}
	@AuraEnabled
	public String strContextId {get; set;}
	@AuraEnabled
	public String strStatus {get; set;}
	@AuraEnabled
	public Engagement_Unit_Consumption__c objEngagementUnitConsumption {get; set;}
	@AuraEnabled
	public List<String> lstContextIds {get; set;}
	@AuraEnabled
	public List<Engagement_Unit__c> lstEngagementUnits {get; set;}
	@AuraEnabled
	public List<Engagement_Unit__c> lstEngagementUnitsTypeAll {get; set;}
	@AuraEnabled
	public List<Engagement_Unit_Consumption__c> lstEngagementUnitConsumptions {get; set;}
}