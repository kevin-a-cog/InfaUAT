/*
Class:          AssociatePlanToInterlock 
@Author:        Chandana Gowda 
@Created Date:  20-Jan-2020
@Description:   Invocable class to Update Plan On Interlock when plan is created
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
*************************************************************************************************************************************
*/
public with sharing class AssociatePlanToInterlock {

    public static globalApexManager GAM = new globalApexManager();        

    /*Method to link Plan to Interlock
    * @param Name - ObjIds:Plan REcord Ids
    * @throws exception -n/a
    * @return- void
    */    
    @InvocableMethod(label='Associate Plan To Interlock' description='Associate Plan To Interlock')
    public static void linkPlanAndInterlock(List<Id> objIds){
        
        Map<Id,Id> mapAccPlan = new Map<Id,Id>();
        List<Related_Opportunity_Plan__c> lstInterlocksUpdate = new List<Related_Opportunity_Plan__c>();

        //Creating a map of Account and plan
        List<Plan__c> lstPlan = [SELECT Id,Account__c FROM Plan__c WHERE Id IN :objIds];
        for(Plan__c plan:lstPlan){
            if(!mapAccPlan.keySet().contains(plan.Account__c))
            mapAccPlan.put(plan.Account__c,plan.Id);
        }

        //List of Interlock to Update
        Map<Id,Related_Opportunity_Plan__c> mapInterlockRecs = new Map<Id,Related_Opportunity_Plan__c>([SELECT Id,Account__c from Related_Opportunity_Plan__c WHERE RecordType.DeveloperName = 'Renewal' AND Account__c IN :mapAccPlan.keySet() AND Plan__c=null]);
        for(Related_Opportunity_Plan__c interlock:mapInterlockRecs.values()){
            interlock.put('Plan__c',mapAccPlan.get(interlock.Account__c));
            lstInterlocksUpdate.add(interlock);
        }
        
        try{
            if(lstInterlocksUpdate.size()>0)
                Database.SaveResult[] saveRes = Database.update(lstInterlocksUpdate, false);
        }
        catch(Exception e){
            GAM.CreateLogs('AssociatePlanToInterlock.linkPlanAndInterlock', lstInterlocksUpdate, 'lstInterlocksUpdate');
        }
        GAM.InsertDebugLogs();        
    }
}