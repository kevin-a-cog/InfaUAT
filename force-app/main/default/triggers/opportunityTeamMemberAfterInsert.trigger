/*
        Trigger:        opportunityTeamMemberAfterInsert
        @Author:        Thejaswini Sattenapalli
        @Created Date:  19 July 2017
        @Description:   To update the OpportunityTeamMembers in Secondary Opportunity after Insert on Primary opportunity
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By          Description                                                 Tag
    ********************************************************************************************************************************************
    Vivek Warrier     13-May-2019   SALESRT-4203  Keerthana Shanmugam   Fixing bug related to Secondary Opportunity Removal         <T01>
    ********************************************************************************************************************************************
   
*/
trigger opportunityTeamMemberAfterInsert on OpportunityTeamMember (after Insert) {
      // call the OpportunityTeamMemberTriggerHandler class Method
         if(globalApexManager.avoidRecursion('opportunityTeamMemberAfterInsert')  ) {
                return;
    }
        //OpportunityTeamMemberTriggerHandler.updateOppotunityTeamOnSecondaryInsert(Trigger.new); //<T01> Commented Out
}