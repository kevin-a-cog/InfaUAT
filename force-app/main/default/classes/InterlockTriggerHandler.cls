/*
    @created by       : Venky K
    @created on       : 4/29/2020
    @Purpose          : Interlock handler class.
    @Testclass        : 
    @JIRA             : 
    @Tag              : T01
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 */

public class InterlockTriggerHandler extends TriggerHandler {

    //Iniitialize the helper method to be called
    private InterlockTriggerHelper interlockHelper = new InterlockTriggerHelper();
    private psa_om_InterlockTriggerHelper psaInterlockHelper = new psa_om_InterlockTriggerHelper();
    private CSMInterlockTriggerHelper csminterlockHelper = new CSMInterlockTriggerHelper();

        
    //Methods related to the module to be called in after insert context
    public override void afterInsert() {            
        psaInterlockHelper.handleInterLockAfterInsert((List<Related_Opportunity_Plan__c>) newList);     
        csminterlockHelper.processAfterInsert((List<Related_Opportunity_Plan__c>) newList,(Map<Id, Related_Opportunity_Plan__c>) oldMap);                        
    }
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {   
        System.debug('BEFORE INSERT INTERLOCK ');
            interlockHelper.populateInterlockName((List<Related_Opportunity_Plan__c>) newList);
    }
        
    //Methods related to the module to be called in after update context
    public override void beforeUpdate() {        
           // interlockHelper.updateIPSOwner((Map<Id,Related_Opportunity_Plan__c>)newMap,(Map<Id,Related_Opportunity_Plan__c>)oldMap);    
            
    }
    
    //Methods related to the module to be called in before insert context
    public override void afterUpdate() {                              
        csminterlockHelper.processAfterUpdate((List<Related_Opportunity_Plan__c>) newList,(Map<Id,Related_Opportunity_Plan__c>) oldMap);     
    }
    
    public override void beforeDelete() {  
        csminterlockHelper.processBeforeDelete((List<Related_Opportunity_Plan__c>) oldList);
    } 
   
}