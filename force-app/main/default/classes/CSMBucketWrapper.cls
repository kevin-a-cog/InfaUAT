/*
 * Name			:	CSMBucketWrapper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/6/2021
 * Description	:	Wrapper class for Buckets.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/6/2021		N/A				Initial version.			N/A
 */
public class CSMBucketWrapper implements Comparable {

	//Public variables.
	@AuraEnabled
	public Integer intOrder {get; set;}
	@AuraEnabled
	public String strObjectName {get; set;}
	@AuraEnabled
	public String strPreSelectedObjectiveId {get; set;}
	@AuraEnabled
	public String strPreSelectedMilestoneId {get; set;}
	@AuraEnabled
	public List<String> lstRecordIds {get; set;}

	/*
	 Method Name : compareTo
	 Description : This method helps with the custom sorting of the class.
	 Parameters	 : Object, called from getSelectedRecordsCloned, objCompareTo Wrapped record to compare to.
	 Return Type : Integer
	 */
	public Integer compareTo(Object objCompareTo) {
		Integer intResult = 0;
        CSMBucketWrapper objComparedBucketTo = (CSMBucketWrapper) objCompareTo;
        if(intOrder > objComparedBucketTo.intOrder) {
            intResult = 1;
        } else if(intOrder < objComparedBucketTo.intOrder) {
            intResult = -1;
        }
        return intResult;       
    }
}