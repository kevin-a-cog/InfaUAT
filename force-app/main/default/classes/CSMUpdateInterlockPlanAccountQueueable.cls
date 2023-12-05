/*
 * Name			:	CSMUpdateInterlockPlanAccountQueueable
 * Author		:	Narpavi P
 * Created Date	: 	27/02/2023
 * Description	:	Queueable class for Update Account in Interlock and Plan record when update in Opportunity

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Narpavi P        		27/02/2023		AR-2866			Initial version.			N/A
 */
public with sharing class CSMUpdateInterlockPlanAccountQueueable implements Queueable{
   
    Public string PLAN_STATUS='Active';
    Set<Id> setOpportunity;
  
    public CSMUpdateInterlockPlanAccountQueueable(Set<Id> setOpportunity) {      
        this.setOpportunity=setOpportunity;

    }
   
    public void execute(System.QueueableContext qc) {
        updatePlanInterlock(setOpportunity);
    }


     /*
	 Method Name : updatePlanInterlock
	 Description : This method will update the account in the interlock and plan for active plan
                   Called from Opportunity Trigger Handler
	 */
    public void updatePlanInterlock(set<Id> setOpportunity )
    {
        List<Related_Opportunity_Plan__c> lstRelatredOpportunity=new List<Related_Opportunity_Plan__c>();
        List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Map<Id,Plan__c> mapPlanUpdate = new Map<Id,Plan__c>();
        set <Id> setAccId=new Set<Id>();
        Map<Id,Messaging.SingleEmailMessage> accEmailMap = new Map<id,Messaging.SingleEmailMessage>();
        Map<Id,Id> newOldAccMap = new Map<Id,Id>();
        Map<Id,String> accOptyOwnerMap = new Map<Id,String>();

        string NewAccountName; 
        string oldAccountId;   
        string OldAccountName;
        string PlanName; 
        String optyOwnerMail;
        
        if(setOpportunity.size()>0)
        {
            
            //Query the Interlock Record for only Active Plan
            Map<Id,Related_Opportunity_Plan__c> mapRelatedOpportunity=new Map<Id,Related_Opportunity_Plan__c>([Select id,Opportunity__r.Account.Name,Original_Opportunity__r.Account.Name,Plan__r.Name,Account__r.Name,Opportunity__c,Opportunity__r.AccountId, Opportunity__r.Owner.Email, Original_Opportunity__c,Original_Opportunity__r.AccountId, Original_Opportunity__r.Owner.Email, Plan__c from Related_Opportunity_Plan__c where Plan__r.Status__c=:PLAN_STATUS AND Plan__r.CSM_isAutoPilot__c=:false AND ( Original_Opportunity__c =:setOpportunity OR Opportunity__c=:setOpportunity )]);           

                for(Related_Opportunity_Plan__c obj:mapRelatedOpportunity.values())
                {
                    if((obj.Opportunity__c != null || obj.Original_Opportunity__c !=null) && obj.Plan__c != null)
                    {   
                        OldAccountName = obj.Account__r.Name;   
                        obj.Contact__c=null; 
                        PlanName = obj.Plan__r.Name;
                        oldAccountId =obj.Account__c;
                        setAccId.add(obj.Account__c);                  

                        //Update the Account in Plan Record 
                        Plan__c plan=new Plan__c();
                        plan.id=obj.Plan__c;
                        

                        if(obj.Opportunity__c!=null && setOpportunity.contains(obj.Opportunity__c)){
                            obj.Account__c= obj.Opportunity__r.AccountId;
                            NewAccountName=obj.Opportunity__r.Account.Name;
                            plan.Account__c= obj.Opportunity__r.AccountId;
                            optyOwnerMail=obj.Opportunity__r.Owner.Email;
                            setAccId.add(obj.Opportunity__r.AccountId);
                            

                        }
                        if(obj.Original_Opportunity__c !=null && setOpportunity.contains(obj.Original_Opportunity__c)){
                            obj.Account__c=obj.Original_Opportunity__r.AccountId;
                            NewAccountName=obj.Original_Opportunity__r.Account.Name;                          
                            plan.Account__c=obj.Original_Opportunity__r.AccountId;
                            optyOwnerMail=obj.Original_Opportunity__r.Owner.Email;
                            setAccId.add(obj.Original_Opportunity__r.AccountId);
                        }   

                        //Add the Plan Record
                        mapPlanUpdate.put(plan.id,plan);
                        //Add Related Opportunity Record to the list                   
                        lstRelatredOpportunity.add(obj);  

                        // Post an Internal Comment in Plan Record
                        String strComment='Plan is now updated with the'+' '+NewAccountName;
                        lstPlanComments.add(preparePlanCommentforAccountUpdate(obj.Plan__c,strComment));   
                        accEmailMap.put(plan.Account__c,getEmail(OldAccountName,NewAccountName,PlanName));  
                        accOptyOwnerMap.put(plan.Account__c,optyOwnerMail);
                        newOldAccMap.put(oldAccountId,plan.Account__c); 

                    }
                }
            if(setAccId!=null){
                // Query the Account Team Member and CSM Manager
                for(AccountTeamMember accmmember : [SELECT Id,TeamMemberRole,UserId,User.Email,User.ManagerId,User.Manager.Email,AccountId from AccountTeamMember where AccountId IN :setAccId])
                {                   
                    Messaging.SingleEmailMessage msg;
                    Id accId;
                    List<String> toemail = new List<String>();
                
                    if(accEmailMap.containsKey(accmmember.AccountId)){
                        accId=accmmember.AccountId;
                    }
                    else{
                        accId=newOldAccMap.get(accmmember.AccountId);
                    }           
                    msg = accEmailMap.get(accId);       
                    if(msg.toAddresses!=null && !msg.toAddresses.isEmpty()){
                        toemail.addAll(msg.toAddresses);
                    }
                    if( accmmember.TeamMemberRole =='CSM')
                    {
                        toemail.add(accmmember.User.Email);                                            
                        if(accmmember.User.Manager.Email!=null){
                            toemail.add(accmmember.User.Manager.Email);
                        }     
                        toemail.add(accOptyOwnerMap.get(accId));           
                    }else{

                        toemail.add(accOptyOwnerMap.get(accId));  
                    }                                    
                    msg.setTargetObjectId(accmmember.UserId);              
                    msg.toAddresses = toemail; 
                    accEmailMap.put(accId,msg);
                }                                           
                    
            }
               
            //Update Plan Record
            if(mapPlanUpdate.size()>0)
            {
                update mapPlanUpdate.values();
            }
            //Update Interlock Record
            if(lstRelatredOpportunity.size()>0)
            {
                 update lstRelatredOpportunity;
            }
            //Insert Plan Comment
            if(lstPlanComments.size()>0)
            {
                insert lstPlanComments;
            }
            // Send email to Account Team
            if(accEmailMap.size()>0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(accEmailMap.values());
            }
        }
    }

    /*
	 Method Name : preparePlanCommentforAccountUpdate
	 Description : This method to create plan comment when the account is updated in plan
	 */

    public static Plan_Comment__c preparePlanCommentforAccountUpdate(Id planRecordId, string strComment){

        return CSMUtilities.createPlanComment(planRecordId,strComment,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE);
    }

    public static Messaging.SingleEmailMessage getEmail(String oldAccname, String newAccName, String planName){

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
        String strMetadata ='';

        strMetadata +='This is to bring to your attention about the change in this account from'+' '+ oldAccname+' ' +'to '+' '+ newAccName +'.';
        strMetadata +='Your Success plan'+' '+planName+' '+'will now reflect the'+' '+ newAccName +' '+'effective immediately.';
        strMetadata +='<br><br>';
        strMetadata += 'This change could have occurred due to a merger or acquisition or an entity name change and has been updated to maintain the alignment of the Success plan to the new Account.';
        strMetadata += 'Kindly review the new Account and alignment of the Success plan.'; 
        strMetadata += 'If the new Account already has an allotted CSM, ';
        strMetadata +='kindly collaborate to decide on the new owner of the Success plan to avoid disrupting our engagement with our customers.';
        strMetadata +='<br><br><br>';
        strMetadata +='Thank You';

        message.setSenderDisplayName(UserInfo.getName());             
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTreatTargetObjectAsRecipient(false);
        message.setSubject('Account Update in Plan Record'+' '+PlanName); 
        message.setHtmlBody(strMetadata);   

        return message;
    }


}