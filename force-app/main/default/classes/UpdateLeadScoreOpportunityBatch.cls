/****************************************************************************************************************************
 *  @Class Name: UpdateLeadScoreOpportunityBatch
 *  @Author: Uday K Gangula
 *  @Date: 3rd Feb 2021
 *  @Description: Batch class for updating the Priority Score and Priority Group on Opportunity records by bringing the Priority Score and Priority Group values from the Primary Contact record of the OpportunityContactRole. JIRA : Salesrt-12797
************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                      Tag
************************************************************************************************************************************************************************
Uday Kumar         12-APR-2021     SALESRT-12972            To Stamp Contact Name, Contact Id and Score Created Date on Oppotunity.                               T<01> 

*/
 
global class UpdateLeadScoreOpportunityBatch implements Database.Batchable<sObject>{
    public static globalApexManager GAM = new globalApexManager();
    private final static string OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; // new sales record type name on Opportunity
    private Id newSalesoppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId();
    global list<Opportunity> opptyListToUpdate = new list<Opportunity>();
    global date goLiveDate=Date.valueOf(System.label.Lead_Scoring_Go_Live_Date);
    
    
    // Below start method will be executed as part of the batch class execuation
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {    

       String query = 'Select Id,OpportunityId,ContactId,Contact.Name,IsPrimary,LastModifiedDate,Contact.Priority_Score__c,Contact.Priority_Group__c from OpportunityContactRole where CreatedDate = LAST_N_DAYS:1 and IsPrimary=true and Opportunity.Priority_Score__c=null and Contact.Priority_Score__c!=null and Opportunity.CreatedDate>=: goLiveDate and Opportunity.RecordTypeId =: newSalesoppRecTypeId   and Opportunity.SBQQ__AmendedContract__c= Null';

    return Database.getQueryLocator(query);
    }
    
    // Below execute method is used to update the Priority_Score__c and Priority_Group__c fields on the Opportunity records
    
    global void execute(Database.BatchableContext BC,List<OpportunityContactRole> scope)
    {
        for(OpportunityContactRole ocr:scope){
            opptyListToUpdate.add(new Opportunity(Id=ocr.OpportunityId,Priority_Score__c=ocr.Contact.Priority_Score__c,Priority_Group__c=ocr.Contact.Priority_Group__c,Primary_Score_Contact__c=ocr.Contact.Name,Primary_Score_Contact_ID__c=ocr.ContactId,Priority_Score_Created_Date__c=datetime.now())); //T<01>
        }
        
        try{
            update opptyListToUpdate;
        }catch(exception e){
            GAM.CreateExceptionRecords('UpdateLeadScoreOpportunityBatch','Exception in UpdateLeadScoreOpportunityBatch: ',e.getMessage());
        }
        // Insert debug Logs
        GAM.Insertdebuglogs();
    }
    
    // Below Finish method is the final method called at the end of the batch class execution
    
    global void finish(Database.BatchableContext BC)
    {
      GAM.CreateLogs('OpportunityUpdated----> finish','timestamp:'+system.now());
     
      // Insert debug Logs
      GAM.InsertDebugLogs();
    }
    
}