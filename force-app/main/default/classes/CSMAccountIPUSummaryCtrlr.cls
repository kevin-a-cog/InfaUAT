/*
 * Name			:	CSMAccountIPUSummaryCtrlr
 * Author		:	Karthi Gurusamy	
 * Created Date	: 	08/15/2023
 * Description	:	Account level IPU Summary controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		        Description					Tag
 **********************************************************************************************************
Karthi Gurusamy		  08/15/2023		 AR-3370				Initial version.			N/A
 */
public without sharing class CSMAccountIPUSummaryCtrlr {
    
    /*
	 Method Name : getAccountId
	 Description : This method returns the account id, based on the given id.
	 Parameters	 : idRecord Record id, String fieldname .
	 Return Type : Id
	 */
	@AuraEnabled(cacheable = true)
	public static Id getAccountId(Id idRecord, String fieldName) {
		Id idAccount = idRecord;
		if(idRecord.getSObjectType() != Account.SObjectType && fieldName != null) {
            String query = 'SELECT '+fieldName+' FROM '+idRecord.getSObjectType()+' WHERE Id=:idRecord LIMIT 1';
			for(SObject objRecord : Database.query(query)) {
				idAccount = (Id)objRecord.get(fieldName);
			}
		}
		return idAccount;
	}

    /*
	 Method Name : getEstimation
	 Description : This method returns the estimation from Active contracts related Opportunity's Primary IPu Estimator, based on the given Account id.
	 Parameters	 : idRecord Account id.
	 Return Type : Id
	 */
	@AuraEnabled(cacheable = true)
	public static integer getEstimation(Id idAccount) {
		Integer intEstimates=0;
		Set<String> inactiveOrgServices = new Set<String>();
		Set<String> icgSet = new Set<String>();
		String estimationQuery ='';
		String icgQuery ='';
		for(CSM_Static_Value__mdt mdt: [Select Value_Long_text__c,DeveloperName from CSM_Static_Value__mdt WHERE DeveloperName IN ('ICGInactiveOrgServices', 'IPU_ICGActiveQuery','IPU_EstimationQuery')]){
			if(mdt.DeveloperName =='ICGInactiveOrgServices'){
				inactiveOrgServices.addAll(mdt.Value_Long_text__c?.split(','));
			}
			else if(mdt.DeveloperName =='IPU_ICGActiveQuery'){
				icgQuery = mdt.Value_Long_text__c;
			}
			else if(mdt.DeveloperName =='IPU_EstimationQuery'){
				estimationQuery = mdt.Value_Long_text__c;
			}
		}

		for(IPU_Consumption_Goal__c objRecord : Database.query(icgQuery)) {
			icgSet.add(objRecord.Service__c);
		}

        for(AggregateResult aggr : Database.query(estimationQuery)) {	
            if(aggr.get('sumEstimates') !=null){
            	intEstimates += ((Decimal)aggr.get('sumEstimates'))?.intvalue(); 
            }
        }
		
		return intEstimates;
	}

     /*
	 Method Name : getTotalGoals
	 Description : This method returns the total goals from ICG, based on the given Account id.
	 Parameters	 : idRecord Account id.
	 Return Type : Id
	 */
	@AuraEnabled(cacheable = true)
	public static integer getTotalGoals(Id idAccount) {
		Integer intGoals=0;
        String query = [SELECT Value_Long_text__c from CSM_Static_Value__mdt WHERE DeveloperName='IPU_TotalGoalsQuery' LIMIT 1]?.Value_Long_text__c;
        for(AggregateResult aggr : Database.query(String.escapeSingleQuotes(query))) {
            intGoals += ((Decimal)aggr.get('sumGoals'))?.intvalue();            
        }
		
		return intGoals;
	}

     /*
	 Method Name : getTotalUsage
	 Description : This method returns the total usage from Orgs, based on the given Account id.
	 Parameters	 : idRecord Account id.
	 Return Type : Id
	 */
	@AuraEnabled(cacheable = true)
	public static integer getTotalUsage(Id idAccount) {
		Integer intUsage=0;
		Set<String> inactiveOrgServices = new Set<String>();
		Set<String> icgSet = new Set<String>();
		String usageQuery ='';
		String icgQuery ='';
		for(CSM_Static_Value__mdt mdt: [Select Value_Long_text__c,DeveloperName from CSM_Static_Value__mdt WHERE DeveloperName IN ('ICGInactiveOrgServices', 'IPU_ICGActiveQuery','IPU_TotalUsageQuery')]){
			if(mdt.DeveloperName =='ICGInactiveOrgServices'){
				inactiveOrgServices.addAll(mdt.Value_Long_text__c?.split(','));
			}
			else if(mdt.DeveloperName =='IPU_ICGActiveQuery'){
				icgQuery = mdt.Value_Long_text__c;
			}
			else if(mdt.DeveloperName =='IPU_TotalUsageQuery'){
				usageQuery = mdt.Value_Long_text__c;
			}
		}

		for(IPU_Consumption_Goal__c objRecord : Database.query(icgQuery)) {
			icgSet.add(objRecord.Service__c);
		}
		
        for(AggregateResult aggr : Database.query(usageQuery)) {
            intUsage += ((Decimal)aggr.get('sumUsage'))?.intvalue();            
        }
		
		return intUsage;
	}

     /*
	 Method Name : getEntitled
	 Description : This method returns the total entitled IPUs, based on the given Account id.
	 Parameters	 : idRecord Account id.
	 Return Type : Id
	 */
	@AuraEnabled(cacheable = true)
	public static Wrapper getEntitled(Id idAccount) {
		Integer intEntitled=0;
		Boolean isFlex = false;
		Boolean isIPU = false;
		Wrapper wrp = new Wrapper();
        String query = [SELECT Value_Long_text__c from CSM_Static_Value__mdt WHERE DeveloperName='IPU_EntitledQuery' LIMIT 1]?.Value_Long_text__c;
		
        for(AggregateResult aggr : Database.query(query)) {
            intEntitled += ((Decimal)aggr.get('sumEntitled'))?.intvalue();    
			if(!isFlex){
				isFlex =  (String)aggr.get('type')=='Flex IPU';
			}  
			if(!isIPU){
				isIPU =  (String)aggr.get('type')=='IPU';
			}      
        }
		wrp.entitled = intEntitled;
		if(isFlex && !isIPU){
			wrp.type =  Label.IPUFlex;
		}  
		if(!isFlex && isIPU){
			wrp.type =  Label.IPU1_0;
		} 
		if(isFlex && isIPU){
			wrp.type =  Label.Flex_1_0;
		} 

		return wrp;
	}

	public class Wrapper{
		@AuraEnabled
		public string type {get;set;}
		@AuraEnabled
		public Integer entitled {get;set;}
	}
}