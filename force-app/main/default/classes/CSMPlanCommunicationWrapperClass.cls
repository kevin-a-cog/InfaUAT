/*
 * Name			:	CSMPlanCommunicationWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	2/10/2022
 * Description	:	Wrapper class for Plan Comments.

 Change History
 ************************************************************************************************************************
 Modified By			Date			Jira No.		Description											Tag
 ************************************************************************************************************************
 Monserrat Pedroza		2/10/2022		N/A				Initial version.								    N/A
 Harshita j             07/11/2022      AR-2817         Added hasSignOffAccess,hasSignOffRecords boolean    <t1>
 Harshita j             07/20/2022      AR-2840         Added needToSignOff boolean 						<t2>
 Karthi                 07/25/2022      AR-2770         Added PlanCommentEmailStats List					T3
 */
public class CSMPlanCommunicationWrapperClass implements Comparable {

	//Public variables.
	@AuraEnabled
	public Boolean Is_Automated {get; set;}
	@AuraEnabled
	public Boolean Request_Sign_Off {get; set;}
	@AuraEnabled
	public Boolean hasSignOffAccess {get; set;} //<t1></t1>
	@AuraEnabled
	public Boolean hasSignOffRecords {get; set;} //<t1></t1>
	@AuraEnabled
	public Boolean needToSignOff {get; set;} //<t2></t2>
	@AuraEnabled
	public Boolean boolExternalSorting {get; set;}
	@AuraEnabled
	public Boolean Inbound {get; set;}
	@AuraEnabled
	public Id Id {get; set;}
	@AuraEnabled
	public Id Parent_Comment {get; set;}
	@AuraEnabled
	public Id CreatedById {get; set;}
	@AuraEnabled
	public Id PlanId {get; set;}
	@AuraEnabled
	public String strSortDirection {get; set;}
	@AuraEnabled
	public String Subject {get; set;}
	@AuraEnabled
	public String Comment {get; set;}
	@AuraEnabled
	public String Type {get; set;}
	@AuraEnabled
	public String Sub_Type {get; set;}
	@AuraEnabled
	public String Status {get; set;}
	@AuraEnabled
	public String Visibility {get; set;}
	@AuraEnabled
	public String Importance {get; set;}
	@AuraEnabled
	public String CreatedByName {get; set;}
	@AuraEnabled
	public Datetime LastModifiedDate {get; set;}
	@AuraEnabled
	public Datetime CreatedDate {get; set;}
	@AuraEnabled
	public Datetime Date_Time_Scheduled {get; set;}
	@AuraEnabled
	public User CreatedBy {get; set;}
	@AuraEnabled
	public Plan__c Plan {get; set;}
	@AuraEnabled
	public Plan_Comment__c objPlanComment {get; set;}
	@AuraEnabled
	public List<ContentDocumentLink> ContentDocumentLinks {get; set;}
	@AuraEnabled
	public List<PlanCommentEmailStat__c> PlanCommentEmailStats {get; set;} // T3
	@AuraEnabled
	public List<Plan_Comment__c> Plan_Comments {get; set;}
	@AuraEnabled
	public List<CSMPlanCommunicationWrapperClass> lstChildComments {get; set;}

	/*
	 Method Name : compareTo
	 Description : This method helps with the custom sorting of the class.
	 Parameters	 : Object, called from compareTo, objCompareTo Wrapped record to compare to.
	 Return Type : Integer
	 */
	public Integer compareTo(Object objCompareTo) {
		Integer intResult = 0;
        CSMPlanCommunicationWrapperClass objComparedBucketTo = (CSMPlanCommunicationWrapperClass) objCompareTo;

		//We check if this request is coming from external community.
		if(boolExternalSorting != null && boolExternalSorting) {
			if(String.isBlank(strSortDirection) || strSortDirection.toLowerCase() == 'desc') {
				if(CreatedDate > objComparedBucketTo.CreatedDate) {
					intResult = -1;
				} else if(CreatedDate < objComparedBucketTo.CreatedDate) {
					intResult = 1;
				}
			} else {
				if(CreatedDate > objComparedBucketTo.CreatedDate) {
					intResult = 1;
				} else if(CreatedDate < objComparedBucketTo.CreatedDate) {
					intResult = -1;
				}
			}
		} else {
			if(CreatedDate > objComparedBucketTo.CreatedDate) {
				intResult = 1;
			} else if(CreatedDate < objComparedBucketTo.CreatedDate) {
				intResult = -1;
			}
		}
        return intResult;       
    }
}