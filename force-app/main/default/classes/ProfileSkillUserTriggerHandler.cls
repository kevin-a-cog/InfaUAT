/*
    @created by       : balajip
    @created on       : 08/07/2020
    @Purpose          : ProfileSkillUser handler class.
    @Testclass        : 
    @JIRA : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description           Jira No.       Tag
 ****************************************************************************************************
Sandeep         11/24/2021                     Handle delete, insert      I2RT-4839      T01
												operations
 */

public class ProfileSkillUserTriggerHandler extends TriggerHandler {

    //Iniitialize the helper method to be called
    private ProfileSkillUserTriggerHelper helper = new ProfileSkillUserTriggerHelper();

    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         

    }

    //-------------------------------------------Start of T01--------------------------
    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.addUserToGroups((Map<Id, ProfileSkillUser>) newMap);
        TrackerUtility.track((Map<Id, ProfileSkillUser>) newMap);
    }
    //-------------------------------------------End of T01--------------------------
    
    //Methods related to the module to be called in after update context
    public override void beforeUpdate() {        

    }
    
    //Methods related to the module to be called in before insert context
    public override void afterUpdate() {
        helper.removeUserFromGroups((Map<Id, ProfileSkillUser>) oldMap,'Update');
    }
    
    //-------------------------------------------Start of T01--------------------------
    //Methods related to the module to be called in before Delete context
    public override void beforeDelete() {
         TrackerUtility.track((Map<Id, ProfileSkillUser>) oldMap);
    }
	//-------------------------------------------End of T01--------------------------
	
    //Methods related to the module to be called in before insert context
    public override void afterDelete() {
        helper.removeUserFromGroups((Map<Id, ProfileSkillUser>) oldMap, 'Delete');
    }
}