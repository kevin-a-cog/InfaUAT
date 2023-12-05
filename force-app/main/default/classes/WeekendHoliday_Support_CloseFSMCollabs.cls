/**
 * @description       : 
 * @author            : Tejasvi Royal
 * @group             : 
 * @last modified on  : 09-15-2021
 * @last modified by  : Tejasvi Royal
**/
public without sharing class WeekendHoliday_Support_CloseFSMCollabs {

    private static String handoffType = 'Follow the Sun';
    
    @InvocableMethod(label='FSM Handoff Closure Handler' description='Method for closing Follow Sun Model Handoffs related to a Case.')
    public static void collabClosureHandler_FSM(List<Case> caseList) {
        
        handoffType = handoffType + '%';
        
        Set<Id> setOfCaseIDs = new Set<Id>();
        for(Case c : caseList) {
            setOfCaseIDs.add(c.Id);
        }
        
        List<Raise_Hand__c> collabsList = [SELECT Id, Status__c
                                           FROM Raise_Hand__c 
                                           WHERE Case__c IN :setOfCaseIDs
                                           AND Type__c = 'Handoff'
                                           AND Name LIKE :handoffType
                                           AND Status__c <> 'Closed'];
        
        List<Raise_Hand__c> collabsForClosure = new List<Raise_Hand__c>();
        
        for(Raise_Hand__c r : collabsList) {
            r.Status__c = 'Closed';
            collabsForClosure.add(r);
        }
        
        UPDATE collabsForClosure;
    }
}