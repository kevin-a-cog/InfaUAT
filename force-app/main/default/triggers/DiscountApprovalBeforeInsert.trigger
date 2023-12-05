/*
        Trigger:        DiscountApprovalBeforeInsert
        @Author:        Abhishek Yadav
        @Created Date:  18th July 2013
        @Description:   To populate the initial fields required to initiate in the approval process.
*/

trigger DiscountApprovalBeforeInsert on DiscountApproval__c (Before Insert) {
    
    // Condition to bypass Integration Profile [Vaishali Singh - 02/11/2016] 
    String integrationProfile = Label.Integration_Profile;
    Profile objProfile = [SELECT Id FROM Profile WHERE Name =:integrationProfile];
    if(globalApexManager.avoidRecursion('DiscountApprovalBeforeInsert')) {
            return;
        }
    if(objProfile.Id != UserInfo.getProfileId()){
        Set<id> setOpportunityId  = new Set<id>();     
        
            for(DiscountApproval__c approval:trigger.new){
                setOpportunityId.add(approval.opportunity__c);                                      
            }
            
        if(!setOpportunityId.isEmpty())
        {
            CreateDiscountApproval.createApproval(trigger.new,setOpportunityId,true);
            CreateDiscountApproval.addApprovers(trigger.new,true);
        }
        
    }
}