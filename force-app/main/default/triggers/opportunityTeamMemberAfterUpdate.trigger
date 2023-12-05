/*
        Trigger:        opportunityTeamMemberAfterUpdate
        @Author:        Thejaswini Sattenapalli
        @Created Date:  19 July 2017
        @Description:   To update the OpportunityTeamMembers in Secondary Opportunity after Update on primary Opportunity
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By          Description                                                 Tag
    ********************************************************************************************************************************************
    Vivek Warrier     13-May-2019   SALESRT-4203  Keerthana Shanmugam   Fixing bug related to Secondary Opportunity Removal         <T01>
    ********************************************************************************************************************************************  
   
*/

trigger opportunityTeamMemberAfterUpdate on OpportunityTeamMember (after Update) {
      if(globalApexManager.avoidRecursion('opportunityTeamMemberAfterUpdate') ) {
        return;
    }
	  // call the OpportunityTeamMemberTriggerHandler class Method
        //OpportunityTeamMemberTriggerHandler.updateOppotunityTeamOnSecondaryUpdate(Trigger.new); //<T01> Commented out
}