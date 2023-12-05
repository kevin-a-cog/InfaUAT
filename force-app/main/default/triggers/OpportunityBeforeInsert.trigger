/*
        Trigger:        OpportunityBeforeInsert
        @Author:        Vishal Negandhi
        @Created Date:  01 November 2016
        @Description:   handles all logic on the before insert of an Opportunity
        Change History
        ******************************************************************
            ModifiedBy          Date        Requested By        Description                                         Tag
           
            rsampath           01-Feb-2017    Navya            Removed check for Integration profile so that        T01
                                                               the trigger will fire
        ------------------------------------------------------------------------------< T01>
   
*/
trigger OpportunityBeforeInsert on Opportunity (before insert) {

    // Condition to bypass Integration Profile [Vaishali Singh - 02/11/2016] 
        String integrationProfile = Label.Integration_Profile;    
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = :integrationProfile];
        //<T01>----- SALES-4372 : Commented check for Integration profile --------------------- -->
        //if(objProfile.Id != UserInfo.getProfileId()){
         //   if(globalApexManager.avoidRecursion('OpportunityBeforeInsert')) {
           //     return;
        //}
        
    //  invoke the before insert method from the trigger handler
        OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
    //}
    //<T01> ---------------------------------------------------------------------------------- -->
}