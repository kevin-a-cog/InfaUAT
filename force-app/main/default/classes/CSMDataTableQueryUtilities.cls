/*
 * Name			:	CSMDataTableQueryUtilities
 * Author		:	Deva M
 * Created Date	: 	08/02/2021
 * Description	:	This will hold query selector methiods for various queries

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					08/02/2021		N/A				Initial version.			N/A
 */
public with sharing class CSMDataTableQueryUtilities {
    /*
	 Method Name : getAccountUserTerritory2ViewByAccountId
	 Description : This method returns the list of  AccountUserTerritory2View recogetAccountTeamMemberByAccountIdrds related to the provided accountid.
	 Parameters	 : Set<String> , called from getAccountUserTerritory2ViewByAccountId, set of account Record Id.                   
	 Return Type : list of AccountUserTerritory2View records.
	 */
    public static List<AccountUserTerritory2View> getAccountUserTerritory2ViewByAccountId(Set<String> strplanAccountId){
        return [SELECT Id, AccountId, UserId,User.Name, User.Email,RoleInTerritory2 FROM AccountUserTerritory2View where AccountId=:strplanAccountId ORDER By User.Name ASC];
    }

     /*
	 Method Name : getAccountTeamMemberByAccountId
	 Description : This method returns the list of  AccountTeamMember records related to the provided accountid.
	 Parameters	 : Set<String> , called from getAccountTeamMemberByAccountId, Set of account Record Id.                   
	 Return Type : List of Account team member records
	 */
    public static List<AccountTeamMember> getAccountTeamMemberByAccountId(Set<String>  strplanAccountId){
        return [SELECT Id, AccountId, UserId,User.Name, User.Email,TeamMemberRole FROM AccountTeamMember where AccountId=:strplanAccountId ORDER By User.Name ASC];
    }

     /*
	 Method Name : getPlanTeamByPlanId
	 Description : This method returns the list of  Plan Team records related to the provided planid.
	 Parameters	 : Set<String> , called from getPlanTeamByPlanId, set of plan Record Id.                   
	 Return Type : List of Plan Team records
	 */
    public static List<Plan_Team__c> getPlanTeamByPlanId(Set<String>  strPlanId){
        return [SELECT Id, Plan__c, User__c,User__r.Email,User__r.Name,Role__c,Name FROM Plan_Team__c where Plan__c =:strPlanId ORDER By User__r.Name ASC];
    }

	/*
	 Method Name : getPlanContractByPlanId
	 Description : This method returns the list of  Plan Contract records related to the provided planid.
	 Parameters	 : Set<String> , called from getPlanContractByPlanId, set of plan Record Id.                   
	 Return Type :  List of Plan_Contract__c records
	 */
    public static List<Plan_Contract__c> getPlanContractByPlanId(Set<String>  strPlanId){
        return [SELECT Id, Contract__c, Opportunity__c, Plan__c FROM Plan_Contract__c where Plan__c =:strPlanId];
    }

	/*
	 Method Name : getOpportunityTeamMemberByOpportunity
	 Description : This method returns the list of  OpportunityTeamMember records related to the provided opportunity Id.
	 Parameters	 : Set<String> , called from getOpportunityTeamMemberByOpportunity, set of opportunity Record Id.                   
	 Return Type : List of OpportunityTeamMember records
	 */
    public static List<OpportunityTeamMember> getOpportunityTeamMemberByOpportunity(Set<String>  strOpportunityId){
        return [SELECT Id,UserId,User.Name, User.Email,TeamMemberRole FROM OpportunityTeamMember where OpportunityId =:strOpportunityId ORDER By User.Name ASC];
    }

	/*	
	 Method Name : getPartnerRelationShipRecords
	 Description : This method returns the list of  Partner Relationship records related to the provided opportunity Id of provided record type associated to plan
	 Parameters	 : Set<String> , called from getPartnerRelationShipRecords, set of opportunity Record Id.     
	 			   Set<String> , called from getPartnerRelationShipRecords, set of plan Record Id.  
				   String , called from getPartnerRelationShipRecords, Account record type Record Id.                
	 Return Type : List of Partner_Relationship__c records
	 */
	public static List<Partner_Relationship__c> getPartnerRelationShipRecords(Set<String>  opportunityIdset,Set<String>  strPlanId,String strPartnerAccountRecordType){
		return [SELECT Id, CreatedDate, Partner_Account__c, Opportunity__c,
				Partner_Account__r.Name,Opportunity__r.Name FROM Partner_Relationship__c
		 		WHERE Opportunity__c IN :opportunityIdset AND Plan__c <> :strPlanId AND Partner_Account__r.Status__c = 'Active' WITH SECURITY_ENFORCED LIMIT 1000];
	}
	/*	
	 Method Name : getPartnerRelationShipRecords
	 Description : This method returns the list of  Partner Relationship records related to the Plan Record
	 Parameters	 : Set<String> , called from getPartnerRelationShipRecords, set of plan Record Id.  
				   String , called from getPartnerRelationShipRecords, Account record type Record Id.                
	 Return Type : List of Partner_Relationship__c records
	 */
	public static List<Partner_Relationship__c> getPartnerRelationShipRecords(Set<String> strPlanId,String strPartnerAccountRecordType){
		return [SELECT Id, CreatedDate, Partner_Account__c, Opportunity__c,
				Partner_Account__r.Name,Opportunity__r.Name FROM Partner_Relationship__c
		 		WHERE Plan__c IN :strPlanId AND Partner_Account__r.RecordTypeId = :strPartnerAccountRecordType WITH SECURITY_ENFORCED LIMIT 1000];
	}
	/*
	 Method Name : getOrderByContractId
	 Description : This method returns the list of  order  records related to the provided contract Id.
	 Parameters	 : Set<String> , called from getOrderByContractId, set of contract Record Id.                   
	 Return Type : List of order records
	 */
	public static List<Order> getOrderByContractId(Set<String>  contractIdSet){
		Set<Id> orderIdSet = new Set<Id>();
		for(Contract c : [SELECT Id,SBQQ__Order__c FROM Contract where Id in:contractIdSet]){
			orderIdSet.add(c.SBQQ__Order__c);
		}
		return [SELECT Id,Opportunity.Name,BilltoAccount__r.Name,ShipToAccount__r.Name,
				EndUserAccount__r.Name,SoldToAccount__r.Name,SoldToAccount__c,EndUserAccount__c,
				ShipToAccount__c,BilltoAccount__c,BilltoAccount__r.RecordTypeId,ShipToAccount__r.RecordTypeId,
				EndUserAccount__r.RecordTypeId,SoldToAccount__r.RecordTypeId,SoldToAccount__r.Status__c,EndUserAccount__r.Status__c,
				ShipToAccount__r.Status__c,BilltoAccount__r.Status__c FROM Order WHERE Id IN : orderIdSet];
	}

	/*
	 Method Name : getParnerAccountByAccountId
	 Description : This method returns the list of  partner account  records related to the provided account Id.
	 Parameters	 : Set<String> , called from getParnerAccountByAccountId, set of acount Record Id.      
	 			   String , called from getParnerAccountByAccountId, Account record type Record Id.              
	 Return Type : List of order records
	 */
	/** 
	public static List<Account> getParnerAccountByAccountId(Set<String>  accountIdSet,String strPartnerAccountRecordType){
		return [ SELECT Id,  Name, CreatedDate  FROM Account WHERE Id IN : accountIdSet AND RecordTypeId = :strPartnerAccountRecordType];
	}
	**/
}