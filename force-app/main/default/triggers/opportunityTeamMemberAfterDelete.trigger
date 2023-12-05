/*
        Trigger:        opportunityTeamMemberAfterDelete
        @Author:        Thejaswini Sattenapalli
        @Created Date:  19 July 2017
        @Description:   To update the OpportunityTeamMembers in Secondary Opportunity after Delete on Primary opportunity
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By          Description                                                 Tag
    ********************************************************************************************************************************************
    Vivek Warrier     13-May-2019   SALESRT-4203  Keerthana Shanmugam   Fixing bug related to Secondary Opportunity Removal         <T01>
    ********************************************************************************************************************************************
   
*/
trigger opportunityTeamMemberAfterDelete on OpportunityTeamMember (after Delete) {
    
    if(globalApexManager.avoidRecursion('opportunityTeamMemberAfterDelete') ) {
        return;
    }
    
    // call the OpportunityTeamMemberTriggerHandler class Method
    //OpportunityTeamMemberTriggerHandler.updateOppotunityTeamOnSecondaryDelete(Trigger.old); //<T01> Commented out
}