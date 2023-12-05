/* 
@created by       : Wasim Akram
@created on       : 5/2/2023
@Purpose          : Class for mapping the Quote Line to the Billing Event Items for PS Deferred Revenue
@Testclass        : psa_BEI_QLI_ControllerTest
@JIRA             : PSA-2998

******************************************************************************************************
Modified by        JIRA No        Date         Comment                                            Tag
******************************************************************************************************

*****************************************************************************************************/
public with sharing class psa_BEI_QLI_Controller{
	public class QuoteLinewrapper{
        @AuraEnabled        
		public Id quoteLineId {get; set;}
        @AuraEnabled        
		public String quoteLineName {get; set;}
        @AuraEnabled
		public String oppProductName {get; set;}
        @AuraEnabled
		public String budgetName {get; set;}
		@AuraEnabled
		public String errorMsg {get; set;}
	}
	/*
	 @Description: Method to fetch the details to be displayed in the LWC datatable
	 @Parameters: String
	 @return type: List<QuoteLinewrapper>
	*/
	@AuraEnabled(cacheable=true)
	public static List<QuoteLinewrapper> fetchColumnDetails(String recordId){
		List<QuoteLinewrapper> quoteLinewrapperList = new List<QuoteLinewrapper>();
		List<pse__Budget__c> budgetList = new List<pse__Budget__c>();
		Map<Id, pse__Budget__c> budgetMap = new Map<Id, pse__Budget__c>();
		Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> quoteLineIdSet = new Set<Id>();
		//Get the count of Billing Line Items for the Billing event
		AggregateResult agr = [SELECT count(Id) childCount FROM pse__Billing_Event_Item__c WHERE pse__Billing_Event__c = :recordId];
        Integer childSize = (Integer)agr.get('childCount');
		Id projId = [SELECT pse__Project__c FROM pse__Billing_Event__c WHERE Id =:recordId]?.pse__Project__c;
        
		//Display error when the Billing Event does not have any Billing Line Items
		if(childSize == 0){
			QuoteLinewrapper qlw = new QuoteLinewrapper();
			qlw.errorMsg = 'No Billing Event Item record found';
			quoteLinewrapperList.add(qlw);
		}
		//Process only when there any Billing Event Item present for the Billing Event
		if(projId != null && childSize > 0){
			//Get all the Change Request Budgets for the Project
			budgetList = [SELECT Id,pse__Opportunity__c,Name FROM pse__Budget__c WHERE pse__Type__c = 'Customer Purchase Order Change Request' 
                          AND pse__Project__c = :projId AND pse__Approved__c = TRUE]; 
			//Store a map of Opportunity Id and its related budget
			for (pse__Budget__c budget : budgetList) {
				if(budget.pse__Opportunity__c != null){
					budgetMap.put(budget.pse__Opportunity__c, budget);
				}
			}
		}
        //If there is no budget that is matching
		if(childSize > 0 && budgetMap.size() == 0){
			QuoteLinewrapper qlw = new QuoteLinewrapper();
			qlw.errorMsg = 'No budget matching the criteria found';
			quoteLinewrapperList.add(qlw);
		}
		//Get the Change Request opportunity Ids
		if(budgetMap.size() > 0){
			opptyIdSet.addAll(budgetMap.keySet());	
		}	
        
		if(opptyIdSet.size() > 0){					
			//Get the Opportunity Line Items and Quote Lines for the Opportunities that is related to Change Request Budgets
			for(OpportunityLineItem oli : [SELECT Id,Product2.name,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.Name,OpportunityId FROM OpportunityLineItem 
                                           WHERE OpportunityId IN :opptyIdSet ORDER BY SBQQ__QuoteLine__r.Name]){
				pse__Budget__c budget = budgetMap.get(oli.OpportunityId);
				//Do not include the Quote Line Item if already added
				if(budget != null && oli.SBQQ__QuoteLine__c !=null && !quoteLineIdSet.Contains(oli.SBQQ__QuoteLine__c)){
					QuoteLinewrapper qlw = new QuoteLinewrapper();
					qlw.quoteLineId = oli.SBQQ__QuoteLine__c;
					qlw.quoteLineName = oli.SBQQ__QuoteLine__r.Name;
					qlw.oppProductName = oli.Product2.name;
					qlw.budgetName = budget.Name;	
					quoteLineIdSet.add(oli.SBQQ__QuoteLine__c);					
					quoteLinewrapperList.add(qlw);
				}
			}
			//If there is no Opportunity product under the Opportunity for the matching budget
			if(quoteLinewrapperList.size() == 0){
				QuoteLinewrapper qlw = new QuoteLinewrapper();
				qlw.errorMsg = 'No opportunity product is found for the matching budget';
				quoteLinewrapperList.add(qlw);
			}
		}        
		return quoteLinewrapperList;
	}
	/*
	 @Description: Method to update the selected Quote Line to the Billing Event Items
	 @Parameters: String, String
	 @return type: String
	*/
	@AuraEnabled
	public static String updateBillingEventItems(String recordId, String quoteLineId){
		List<pse__Billing_Event_Item__c> beiList = new List<pse__Billing_Event_Item__c>();
		for(pse__Billing_Event_Item__c bei : [SELECT Id FROM pse__Billing_Event_Item__c WHERE pse__Billing_Event__c = :recordId]){
			beiList.add(new pse__Billing_Event_Item__c (Id = bei.Id, CR_Quote_Line_Item__c = quoteLineId));
		}
		try{
			update beiList;
            return 'SUCCESS';
		}
		catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}        
	}

	@AuraEnabled(cacheable=true)
    public static Boolean areChildRecordsEqual(String parentId) {
            List<SObject> childRecords = new List<SObject>();
            childRecords = [SELECT Id, CR_Quote_Line_Item__c FROM pse__Billing_Event_Item__c WHERE 	pse__Billing_Event__c = :parentId];
            if(childRecords.size() == 1 || childRecords.size() == 0)
            {
                return true;
            }else
            {
                Set<String> fieldValues = new Set<String>();
                for (SObject childRecord : childRecords) {
                        fieldValues.add(String.valueOf(childRecord.get('CR_Quote_Line_Item__c')));
                    }
                return fieldValues.size() == 1;
            }
            
        }
}