/*
 * Name			:	IPUConsumptionGoalsWrapper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	5/10/2023
 * Description	:	Wrapper class for IPU Consumption Goals.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		5/10/2023		N/A				Initial version.						N/A
 */
public class IPUConsumptionGoalsWrapper implements Comparable {

	//Public variables.
	@AuraEnabled
	public Integer intSortTarget {get; set;}
	@AuraEnabled
	public String strServiceName {get; set;}
	@AuraEnabled
	public String strObjectiveName {get; set;}
	@AuraEnabled
	public Map<String, String> mapObjectives {get; set;}
	@AuraEnabled
	public Map<String, Object> mapRecordValues {get; set;}

	/*
	 Method Name : compareTo
	 Description : This method sorts the records in ascendent order.
	 Parameters	 : Object, called from compareTo, objCompareTo Object to be compared.
	 Return Type : Integer.
	 */
	public Integer compareTo(Object objCompareTo) {
		Integer intResult = 0;
		IPUConsumptionGoalsWrapper objCompareToWrapped = (IPUConsumptionGoalsWrapper) objCompareTo;

		//We do the comparison.
		switch on intSortTarget {

			//Service Names.
			when 1 {
				if(strServiceName > objCompareToWrapped.strServiceName) {
					intResult = 1;
				} else if(strServiceName < objCompareToWrapped.strServiceName) {
					intResult = -1;
				}
			}

			//Objectives.
			when 2 {
				if(strObjectiveName == 'None') {
					intResult = 0;
				} else if(strObjectiveName > objCompareToWrapped.strObjectiveName) {
					intResult = 1;
				} else if(strObjectiveName < objCompareToWrapped.strObjectiveName) {
					intResult = -1;
				}
			}
		}
		return intResult;
	}
}