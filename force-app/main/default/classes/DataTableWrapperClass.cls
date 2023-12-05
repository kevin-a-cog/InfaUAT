/*
 * Name			:	Public class DataTableWrapperClass
 * Author		:	Deva M
 * Created Date	: 	08/07/2021
 * Description	:	Utilities class for  Data Tables.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		            08/07/2021 		N/A				Initial version.			N/A
 */
Public class DataTableWrapperClass{
    @AuraEnabled
    public List<TableRowWrapper> lstRecords {get; set;}
    @AuraEnabled
    public List<ColumnWrapper> lstColumns {get; set;}
    @AuraEnabled
    public List<String> lstFieldNames {get; set;}
    /*Column wrapper to match generic component */
    Public class ColumnWrapper{
        @AuraEnabled
		public String label {get; set;}       
        @AuraEnabled
		public String fieldName {get; set;} 
        @AuraEnabled
		public Boolean sortable {get; set;}  
        @AuraEnabled
		public String type {get; set;}                   
    }        


     /*Wrapper class to hold the table records */
     public class TableRowWrapper{
        @AuraEnabled
        public String memberName{get;set;}
        @AuraEnabled
        public String memberEmail{get;set;}
        @AuraEnabled
        public String memberRole{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
		public String userId {get; set;}
        @AuraEnabled
		public String source {get; set;}

        //Plan Partner Table
        @AuraEnabled
		public String accountName {get; set;}
        @AuraEnabled
		public String accountId {get; set;}
        @AuraEnabled
		public String createdDate {get; set;}
        @AuraEnabled
		public String opportunityName {get; set;}

        //Objectives and Milestone Products
      /*  @AuraEnabled
        public String ForecastProduct {get;set;}
        @AuraEnabled
        public String OfferingType {get;set;}
        @AuraEnabled
        public String DeliveryMethod {get;set;}
        @AuraEnabled
        public String PricingBusinessModel {get;set;}
        @AuraEnabled
        public String PlanProduct {get;set;}*/
    }
  
}