/*
        Trigger:        DiscountApprovalBeforeUpdate
        @Author:        Abhishek Yadav
        @Created Date:  23rd July 2013
        @Description:   To populate the initial fields required to initiate in the approval process.
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
    rsampath        11-Jul-2016    SALES-4043    Sunil Mirapuri    Trigger the setting of DA approvers when 
                                                                   Discount Approval Type changes                               T01
    cgowda          3-Aug-2021    SALESRT-13213   Liz              Update AVP to Meric Tukoglu for DA when Driven By is 		T02
																   Inside Sales 
    nmane			19-Jan-2021   SALESRT-13292   				   Refresh approver list if Driven By is updated on             T03
																   Discount Approval
*/
trigger DiscountApprovalBeforeUpdate on DiscountApproval__c (Before Update) {
    // Condition to bypass Integration Profile [Vaishali Singh - 02/11/2016]
    String integrationProfile = Label.Integration_Profile;
    Profile objProfile = [SELECT Id FROM Profile WHERE Name=: integrationProfile];
    if(globalApexManager.avoidRecursion('DiscountApprovalBeforeUpdate')) {
            return;
        }
    if(objProfile.Id != UserInfo.getProfileId()){
    
        
    
        list<DiscountApproval__c> approvals = new list<DiscountApproval__c>();
        list<DiscountApproval__c> estlistApprovals = new list<DiscountApproval__c>();
        list<DiscountApproval__c> removeApprover1 = new list<DiscountApproval__c>();
        Map<Id,DiscountApproval__c> mapUpdateAVP = new Map<Id,DiscountApproval__c>(); 
        Map<Id,Id> mapDAOldAVP = new Map<Id,Id>();  //<T02>  
        Set<id> setOpportunityId  = new Set<id>(); //<T02>
        list<DiscountApproval__c>  lstApprovals = new list<DiscountApproval__c>();  //<T03>
        
        
            for(DiscountApproval__c approval:trigger.new){
                 //<T03>------------------------------------------------------
                 if(approval.DrivenBy__c != trigger.oldmap.get(approval.Id).DrivenBy__c && approval.Status__c == 'New'){
                    lstApprovals.add(approval);
                 }
                //------------------------------------------------------------<T03>
                //<T02>
                if(approval.DrivenBy__c != trigger.oldmap.get(approval.Id).DrivenBy__c && approval.AVP__c != null){
                    mapDAOldAVP.put(approval.Id,trigger.oldmap.get(approval.Id).AVP__c);
                    mapUpdateAVP.put(approval.Id,approval);
                }
                
                if(approval.discount__c!=null && trigger.OldMap.get(approval.id).discount__c!=approval.discount__c)
                    approvals.add(approval);                
                 //<T01>------------------------------------------------------------------------------------------------------------------------------------------------</T01>
                 if(approval.EstimateListPrice__c!=trigger.OldMap.get(approval.id).EstimateListPrice__c || approval.Discount_Approval_Type__c!=trigger.OldMap.get(approval.id).Discount_Approval_Type__c)
                 {
                     estlistApprovals.add(approval);
                     setOpportunityId.add(approval.opportunity__c);
                 }  
                 if((approval.status__c!= trigger.oldmap.get(approval.id).status__c) && approval.approver1__c!=null && (approval.approver1__c==userinfo.getuserID()))
                     removeApprover1.add(approval); 
            }
        if(!mapUpdateAVP.isEmpty()){
            CreateDiscountApproval.updateAVP(mapUpdateAVP,mapDAOldAVP);
        }
         
        //<T03>------------------------------------------------------       
        if(!lstApprovals.isEmpty()){
            CreateDiscountApproval.addApprovers(lstApprovals,true);    
        }
        //------------------------------------------------------------<T03>

        if(!estlistApprovals.isEmpty())
        {
                CreateDiscountApproval.createApproval(estlistApprovals,setOpportunityId,False); 
                CreateDiscountApproval.addApprovers(estlistApprovals,false);    
        }    
        
        if(!approvals.isEmpty())
            CreateDiscountApproval.addApprovers(approvals,false);        
            
        if(!removeApprover1.isEmpty())
            CreateDiscountApproval.skipApprover1(removeApprover1);
        
    }
}