/*
@created by       : Venky K
@created on       : 11/01/2020
@Purpose          : Case handler class.
@Testclass        : 
@JIRA             : 


Change History
****************************************************************************************************
ModifiedBy      Date            Jira No.    Tag     Description                                         
****************************************************************************************************
Deva M          03 Jun 2021     I2RT-2636   T01     added a mehtod in after update                      
balajip         09 Mar 2022     I2RT-5624   T02     made the notify method to be called during recursion
Sandeep Duggi   29 Mar 2022     I2RT-5777   T03     Tech debt - apex exceptions 
Vignesh D       21 Jun 2022     I2RT-6153   T04     Populate Segment based on Case Segmentation Criterias
Vignesh D       08 Jan 2023     I2RT-6778   T05     Recalculate segmentation on after update
balajip         31-Jan-2023     I2RT-7596   T06     cleanup and streamlining                            
balajip         06-Feb-2023     I2RT-7674   T07     updated method call updateCaseWeightage
Vignesh D       07 Nov 2023     I2RT-8841   T08     Replaced old with new tracker method
*/

public class CaseTriggerHandler extends TriggerHandler {
    
    //T02 - Contructor to accept the parameter recursionCheckNeeded
    public CaseTriggerHandler(Boolean recursionCheckNeeded){
        super(recursionCheckNeeded);
    }

    private CaseTriggerHelper helper = new CaseTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {   
        if(globalApexManager.avoidRecursion('casebeforeInsert',  'before', 'insert') ) {
            return;
        }
        System.debug('beforeInsert-->');
        
        helper.setCaseFields((List<Case>) newList);
        helper.setCaseTimezone((List<Case>) newList);    
        helper.setBusinessHours((List<Case>) newList);
        helper.setBusinessHoursIndicatorFields((List<Case>) newList,(Map<Id, Case> )oldMap,(Boolean) IsInsert,(Boolean) isUpdate); //T06
        helper.updateCaseOwnerManager((List<Case>) newList);
    }
    
    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.notify((List<Case>) newList, null); //T02 - moved the method before recursion check
        if(globalApexManager.avoidRecursion('caseIsAfterInsert',  'after', 'insert') ) {
            return;
        }
        System.debug('afterInsert-->');
        helper.checkAssignmentRules((List<Case>) newList); //T06
        helper.setQueueName((List<Case>) newList);
        helper.CalculateResolutionTargetDate((List<Case>) newList,(Map<Id, Case>) newMap);
        helper.updateCaseTeam((List<Case>) newList, null); //I2RT-4175
        helper.validatecasecontacts((Map<Id, Case>) newMap);
        helper.incrementTechnicalCaseCount((List<Case>) newList);
        helper.setSegment((List<Case>) newList, (Map<Id, Case>) newMap, (Map<Id, Case>) oldMap, (Boolean) IsAfter, (Boolean) IsInsert, (Boolean) IsUpdate); //<T04> //<T05>

        //Deva To Enable tracker Frame work on Case
        TrackerUtility.trackChanges(null, (Map<Id, Case>) newMap); //<T08>
    }
    
    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {    
        if(globalApexManager.avoidRecursion('caseIsBeforeUpdate',  'before', 'update') ) {
            return;
        } 
        System.debug('beforeUpdate call');      
        helper.updateCaseStatus( (Map<Id, Case> )oldMap, (List<Case>) newList); //T06
        
        //I2RT-4149
        helper.setCaseTimezone((List<Case>) newList);    
        
        //@Akhilesh 8 Aug 2021 -- start [based on timezone business hours need to be updated]
        helper.setBusinessHours((List<Case>) newList);
        //@Akhilesh 8 Aug 2021 -- end

        helper.setBusinessHoursIndicatorFields((List<Case>) newList,(Map<Id, Case> )oldMap,(Boolean) IsInsert,(Boolean) isUpdate); //T06
        // DEPRECATED: helper.updateCaseProductQueue((List<Case>) newList);
        helper.updateCaseOwnerManager((List<Case>) newList);
    }
    
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {          
        helper.notify((List<Case>) newList, (Map<Id, Case>) oldMap); //T02 - moved the method before recursion check
        if(globalApexManager.avoidRecursion('caseIsAfterUpdate',  'after', 'update') ) {
            return;
        }
        System.debug('afterUpdate call');
        
        helper.CalculateResolutionTargetDate((List<Case>) newList,(Map<Id, Case>) newMap);
        helper.validatecasecontacts((Map<Id, Case>) newMap);
        // DEPRECATED: helper.incrementTechnicalCaseCount((List<Case>) newList, (Map<Id, Case>) oldMap, (Boolean) IsInsert, (Boolean) isUpdate);
        helper.caseUpdates((List<Case>) newList, (Map<Id, Case>) oldMap);
        helper.updateCaseWeightage((List<Case>) newList,(Map<Id, Case> )oldMap); //T07

        //Deva: I2RT-2636 
        helper.updateCaseTeam((List<Case>) newList,(Map<Id, Case>) oldMap);
        
        // for lightning scheduler [AAE] piyush  
        helper.updateAaeEvent((List<Case>) newList,(Map<Id, Case>) oldMap);

        //I2RT-4787 - to take the actions required when Monitoring on the Case ends.
        helper.monitoringDisabled((List<Case>) newList, (Map<Id, Case>) oldMap);
        //I2RT-4219 - Added by Amit to capture the target dates of the milestones
        //I2RT 5777 & 5778 - added below if clause 
         if(!System.isfuture() || !System.isBatch()){
        helper.updateMilestoneFieldsOnCase( (Map<Id, Case> )oldMap, (Map<Id, Case>) newMap); //T06
         }
        
        helper.setSegment((List<Case>) newList, (Map<Id, Case>) newMap, (Map<Id, Case>) oldMap, (Boolean) IsAfter, (Boolean) IsInsert, (Boolean) IsUpdate); //<T05>

		 //Removing dynamic tagging.
		 helper.removeTagging((List<Case>) newList, (Map<Id, Case>) oldMap);

        //Deva To Enable tracker Frame work on Case record
        TrackerUtility.trackChanges((Map<Id, Case>) oldMap, (Map<Id, Case>) newMap); //<T08>
    }
}