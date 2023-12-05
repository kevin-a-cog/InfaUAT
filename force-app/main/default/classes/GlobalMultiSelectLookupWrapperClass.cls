/*
 * Name			:	GlobalMultiSelectLookupWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/3/2022
 * Description	:	Wrapper class for Multi Select Lookup feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/3/2022		N/A				Initial version.			N/A
 */
public class GlobalMultiSelectLookupWrapperClass {

	//Request variables.
	@AuraEnabled
	public Integer intLimitResults {get; set;}
	@AuraEnabled
	public String strObjectName {get; set;}
	@AuraEnabled
	public String strFilterFieldAPIName {get; set;}
	@AuraEnabled
	public String strKeyword {get; set;}
	@AuraEnabled
	public String strAdditionalFilters {get; set;}
	@AuraEnabled
	public String strValueFormat {get; set;}
	@AuraEnabled
	public Map<String, String> mapFilterFieldAPINames {get; set;}

	//Response variables.
	@AuraEnabled
	public String strKey {get; set;}
	@AuraEnabled
	public String strValue {get; set;}
}