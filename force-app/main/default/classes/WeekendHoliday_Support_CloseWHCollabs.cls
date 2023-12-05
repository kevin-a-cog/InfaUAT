/**
 * @description       : 
 * @author            : Tejasvi Royal
 * @group             : 
 * @last modified on  : 09-15-2021
 * @last modified by  : Tejasvi Royal
**/
public without sharing class WeekendHoliday_Support_CloseWHCollabs {
    
    private static String handoffType = 'Weekend/Holiday';
    
    @InvocableMethod(label='W/H Handoff Closure Handler' description='Method for closing Weekend/Holiday Handoffs related to a Case.')
    public static void collabClosureHandler_WH(List<Case> caseList) {
        
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