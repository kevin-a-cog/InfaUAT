/**
 * @description       : 
 * @author            : Tejasvi Royal
 * @group             : 
 * @last modified on  : 09-22-2021
 * @last modified by  : Tejasvi Royal
**/
public without sharing class WeekendHoliday_Support_CaseTeamHandler {

	@InvocableMethod(label='Case Team Handler' description='Method for removing the current owner from the Case Team.')
    public static void caseTeamHandler_OwnerRemoval(List<Case> caseList) {
        
        Set<Id> setOfCaseIDs = new Set<Id>();
        for(Case c : caseList) {
            setOfCaseIDs.add(c.Id);
        }
        
        List<Case_Team__c> ownersOfCase = [SELECT Id, Name, Case__c, Role__c, User__c
                                           FROM Case_Team__c
                                           WHERE Case__c IN :setOfCaseIDs
                                           AND Role__c = 'Owner'];
        DELETE ownersOfCase;
    }
}