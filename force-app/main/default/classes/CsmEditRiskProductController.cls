/*
* Name			:	CsmEditRiskProductController
* Author		:	Deva M
* Created Date	: 	20/01/2021
* Description	:	Helper class risk product create/Edit page

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		        Description					Tag
Deva M              20/01/2021      AR-2132/1572            Initial Version
Harshita J          15/09/2022      AR-2920                 Initial Version              T1      
**********************************************************************************************************
*/
public with sharing class CsmEditRiskProductController {
    static String renewalOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();     
      /*
	 Method Name : getRecords
	 Description : This method called from risk Product create page to get the list of products associated
	 Parameters	 : String strRiskId, record id from plan on risk crreationn page        
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static RiskProductWrapper getRecords(String strRiskId, String strRiskProductId){ 
        RiskProductWrapper obj = new RiskProductWrapper();
        Set<Id>  setPlanIdSet = new Set<Id>();
        List<Plan_Product_Alias__c> lstPlanProductList = new List<Plan_Product_Alias__c>();
        String strCleanRecordId;
        //If we have plan record Id
        if(String.isNotBlank(strRiskId)) {
            strCleanRecordId = String.escapeSingleQuotes(strRiskId);
            
            for(Risk_Issue__c objRisk:[SELECT Id, Risk_Reason__c,Reason__c,Plan__c FROM Risk_Issue__c where id=:strCleanRecordId]){
                if(objRisk.Plan__c!=null){
                    setPlanIdSet.add(objRisk.Plan__c);
                }
            }
            if(setPlanIdSet.size()>0){
                for(Plan_Product_Alias__c objPlan:[SELECT Id, Plan_Product__c, Name__c, Plan__c FROM Plan_Product_Alias__c WHERE Plan__c=:setPlanIdSet]){
                    lstPlanProductList.add(objPlan);
                }
                obj.lstPlanProdut = lstPlanProductList;
                if(String.isNotBlank(strRiskProductId)){
                    List<Risk_Product_Alias__c> lstRiskProduct = new List<Risk_Product_Alias__c>([SELECT Id, Opportunity__c,Opportunity__r.Name, Plan_Product_Alias__c, Risk__c, Renewal_Probability__c FROM Risk_Product_Alias__c
                    WHERE Risk__c=:strCleanRecordId AND id=:strRiskProductId]);                    
                    obj.objRiskProduct = lstRiskProduct.size()>0?lstRiskProduct[0]:null;
                }
            }
        } 
        return obj;
    }
    /*
	 Method Name : getOpportunityRecords
	 Description : This method called from risk Product create page to get the list of products associated
	 Parameters	 : String strSelectedProductId, record id from of plan product alias        
	 Return Type : List<Related_Account_Plan__c>
	 */
    @AuraEnabled(cacheable = false)
    public static List<Related_Account_Plan__c> getOpportunityRecords(String strSelectedProductId){
        String strCleanRecordId;
        Set<Id> setPlanProductAlias = new Set<Id>();
        List<Related_Account_Plan__c> lstPlanProduct= new List<Related_Account_Plan__c>();
        if(String.isNotBlank(strSelectedProductId)) {
            strCleanRecordId = String.escapeSingleQuotes(strSelectedProductId);
            for(Plan_Product_Alias__c objPpa:[SELECT Id, Plan_Product__c, Name__c, Plan__c FROM Plan_Product_Alias__c WHERE Id=:strCleanRecordId]){
                setPlanProductAlias.add(objPpa.Id);
            }
            if(setPlanProductAlias.size()>0){
                for(Related_Account_Plan__c objPpa:[SELECT Id, Opportunity__c, Opportunity__r.Name,Opportunity__r.Type,Opportunity__r.StageName FROM Related_Account_Plan__c WHERE Plan_Product_Alias__c =:setPlanProductAlias AND Opportunity__r.RecordTypeId=:renewalOpportunity AND Opportunity__r.StageName NOT IN ('Closed Won','Closed Lost','No Opportunity','Duplicate')]){//T1 
                    lstPlanProduct.add(objPpa);
                }
            }
        }
        return lstPlanProduct;        
    }
/*@AuraEnabled(cacheable=true)
   public static List<LookupSearchResult> lookupSearch(String searchTerm, List<String> selectedIds, String strSelectedProductId,String strRiskId) {
       // Prepare query parameters
          

        Set<Id>  setPlanIdSet = new Set<Id>();        
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> setPlanProductAlias = new Set<Id>();
        List<Plan_Product_Alias__c> lstPlanProductList = new List<Plan_Product_Alias__c>();       
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String strCleanRecordId;

        // Execute search query
        searchTerm = '%'+searchTerm+'%';
        String opptyIcon = 'standard:opportunity';		
        //If we have plan record Id
        if(String.isNotBlank(strSelectedProductId)) {           
            strCleanRecordId = String.escapeSingleQuotes(strSelectedProductId);
            for(Plan_Product_Alias__c objPpa:[SELECT Id, Plan_Product__c, Name__c, Plan__c FROM Plan_Product_Alias__c WHERE Id=:strCleanRecordId]){
                setPlanProductAlias.add(objPpa.Plan_Product__c);
            }
            if(setPlanProductAlias.size()>0){
                for(Related_Account_Plan__c objPpa:[SELECT Id, Opportunity__c FROM Related_Account_Plan__c WHERE Id =:setPlanProductAlias]){
                    opptyIdSet.add(objPpa.Opportunity__c);
                }
            }
        }
        if(opptyIdSet.size()>0){
            for (Opportunity oppty : [Select Id,Name,StageName,Type from Opportunity where Id in :opptyIdSet AND RecordTypeId=:renewalOpportunity and Name like:searchTerm]) {
                String strSubTitle = 'Type: '+oppty.Type+' Stage: '+oppty.StageName;
                results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name,strSubTitle ));
            }
        }
        return results;
    }*/

  
    @AuraEnabled(cacheable = false)
    public static RiskProductAliasWrapper saveRiskProduct(String strRiskId,String strProductId, String strOpportunityId, String strProbability,String strRiskProductId){
        RiskProductAliasWrapper obj = new RiskProductAliasWrapper();
       List<Risk_Product_Alias__c> lstUpsertRiskProduct = new List<Risk_Product_Alias__c>();
        List<Risk_Product_Alias__c> lstRiskProduct = new List<Risk_Product_Alias__c>([SELECT Id, Opportunity__c, Plan_Product_Alias__c, Risk__c, Renewal_Probability__c FROM Risk_Product_Alias__c
                                                                                    WHERE Plan_Product_Alias__c=:strProductId AND Opportunity__c=:strOpportunityId AND Risk__c=:strRiskId]);
        if(lstRiskProduct.size()>0 && String.isBlank(String.escapeSingleQuotes(strRiskProductId))){
            obj.strErrorMessage='There is already risk product added with this combination, kinldy update the exisitng one';
        }else{
            Risk_Product_Alias__c objRiskProduct = new Risk_Product_Alias__c(Plan_Product_Alias__c=strProductId,
            Opportunity__c=strOpportunityId,
            Risk__c=strRiskId,
            Renewal_Probability__c =strProbability);
            if(String.isNotBlank(String.escapeSingleQuotes(strRiskProductId))){
                objRiskProduct.Id = strRiskProductId;
            }
            lstUpsertRiskProduct.add(objRiskProduct);
            List<Database.upsertResult> uResults = Database.upsert(lstUpsertRiskProduct,false);
            for(Database.upsertResult result:uResults) {
                if (result.isSuccess() && result.isCreated()){
                    obj.recordId=result.getId();
                    break;
                }
            }            
        }
        return obj;
    }

    public class RiskProductAliasWrapper{
        @AuraEnabled
        public String recordId{get; set;}
        @AuraEnabled
        public String strErrorMessage{get; set;}
    }

    public class RiskProductWrapper{
        @AuraEnabled
        public List<Plan_Product_Alias__c> lstPlanProdut{get; set;}
        @AuraEnabled
        public Risk_Product_Alias__c objRiskProduct {get; set;}
    }
}