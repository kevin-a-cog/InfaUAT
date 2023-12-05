/*
 * Name			:	GlobalRecordCompletionWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/10/2021
 * Description	:	Wrapper class for Global Record Completion.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description									Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/10/2021		N/A				Initial version.							N/A
 VENKATESH BALLA		10/20/2023		SALESRT-17407   Additional changes to support Opportunity   <SALESRT-17407>
 														substage progression.
 */
public class GlobalRecordCompletionWrapperClass {

	//Public variables.
	@AuraEnabled
	public Double intNumerator {get; set;}
	@AuraEnabled
	public Double intDenominator {get; set;}
	@AuraEnabled
	public Double dblPercentage {get; set;}
	@AuraEnabled
	public List<EvaluationWrapperClass> lstEvaluations {get; set;}
	@AuraEnabled
	public List<EvaluationWrapperClass> lstEvaluationsInComplete {get; set;}//<SALESRT-17407>


	//Evaluation Wrapper class.
	public class EvaluationWrapperClass {

		//Public variables.
		@AuraEnabled
		public Boolean boolHasAction {get; set;}
		@AuraEnabled
		public String strId {get; set;}
		@AuraEnabled
		public String strLabel {get; set;}
		@AuraEnabled
		public String strIcon {get; set;}
		@AuraEnabled
		public String strActionType {get; set;}
		@AuraEnabled
		public String strActionTarget {get; set;}
		@AuraEnabled
		public String strActionData {get; set;}
		
	}
}