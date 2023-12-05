/*
Class:          OpportunityBannersController
@Author:        Sreerekha
@Created Date:  25 May 2023
@Description:   Controller class for OpportunityBanner LWC component - Used on Opportunity Record Page
@Jira:          SALESRT-15120
*/
public class OpportunityBannersController {
    /* Method Name : checkAllocationPR
    * @param mapNew - recordId - Opportunity RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - SALESRT-15120 - Return true if sum of Allocation % on Partner Relationships is greater than 100
    */
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkAllocationPR(String recordId){
       Boolean result = false;
        AggregateResult totalPRAllocation = [SELECT SUM(Allocated__c)totalPR from Partner_Relationship__c where Opportunity__c =:recordId ];
        Integer totalPR = Integer.ValueOf(totalPRAllocation.get('totalPR'));
        if(totalPR > 100){
            result = true;
        }
       return result;
    }

    @AuraEnabled
    public static Boolean checkOutOfSync(Id opportunityId){
        List<Opportunity> optyList = [
            SELECT Id, SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.CreatedDate,
                SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.Amendment_Contracted_Date_Time__c
            FROM Opportunity 
            WHERE Id =: opportunityId];

        if(!optyList.isEmpty() && optyList[0].SBQQ__PrimaryQuote__c != null){

            List<Contract> contractList = [SELECT Id,Amendment_Contracted_Date_Time__c FROM Contract WHERE SBQQ__RenewalOpportunity__c = :opportunityId];
            Boolean check = false;

            for(Contract contr : contractList){
                if(contr.Amendment_Contracted_Date_Time__c != null && optyList[0].SBQQ__PrimaryQuote__r.CreatedDate <= contr.Amendment_Contracted_Date_Time__c){
                    check = true;
                    break;
                }
            }
            return check;
        }
        return false;
    }
    
    
}