/*
@created by       : Wasim
@created on       : 10/27/2023
@Purpose          : Helper class for PSA_EngagementTriggerHandler.

Change History
**********************************************************************************************************************************************************
ModifiedBy      |Date           |Requested By   |Description                                                                    |  Jira No.     | Tag No:
**********************************************************************************************************************************************************
Wasim Akram    22-Aug-2023      Neha Kumari       Approval process to be built for PSA Engagement                                 PSA-3111        T1
Wasim          27-Oct-2023      Neha Kumari       PS Engagement SOW/Proposal documentation workflow                               PSA-3173        T2
**********************************************************************************************************************************************************
*/
public class PSA_EngagementTriggerHelper {
    public static globalApexManager gam = new globalApexManager();
    
    //<T1>
    /*
    Method to send email on Engagment Approval Rejection - to be sent to the Owner and previous approvers with the rejection comments.
    */
    /** 
    * @description - Method to send email on Engagment Approval Rejection - to be sent to the Owner and previous approvers with the rejection comments.
    * @param newMap - map of new Engagements
    * @param oldMap - map of old Engagements
    * @throws exception - NA
    */
    public void onApprovalRejection(Map<Id,Engagement__c> newMap, Map<Id,Engagement__c> oldMap){
        Map<Id,Engagement__c> rejectedEngagements = new Map<Id,Engagement__c>();
        List<Engagement__c> rejectedEngagementList = new List<Engagement__c>();
        for(Engagement__c eng : newMap.values()){
            //Validate if Signatory details are filled when the Status is changed to Ready to Docusign
            if(eng.psa_Status__c == 'Ready for Docusign' && (String.isBlank(eng.PSA_Signatory_Name__c) || String.isBlank(eng.PSA_Signatory_email_address__c)) && eng.psa_Status__c <> oldMap.get(eng.Id).psa_Status__c){
                eng.addError(Label.PSA_Eng_Signatory_Error_message);
            }
            //When the Engagment is Rejected
            if(!eng.PSA_Submit_for_Approval__c && eng.PSA_Submit_for_Approval__c <> oldMap.get(eng.Id).PSA_Submit_for_Approval__c){
                rejectedEngagements.put(eng.Id, eng);
                rejectedEngagementList.add(eng);
            }
        }
        
        //Send Rejection Email to the Owner and previous approvers
        if(rejectedEngagementList.size() == 1 && rejectedEngagementList[0].PSA_Engagement_Approval_Matrix__c != null){
            Set<Id> userSet = new Set<Id>();
            //Get the Previous approvers list
            PSA_Engagement_Approval_Matrix__c matrix = [SELECT Commercial_Review__c,Delivery_Review__c,DM_Review__c,Technical_Review__c,VP_Review__c FROM PSA_Engagement_Approval_Matrix__c WHERE Id = :rejectedEngagementList[0].PSA_Engagement_Approval_Matrix__c];
            if(matrix != null){
                //Add Owner to user list
                userSet.add(rejectedEngagementList[0].OwnerId);
                //Add previous approvers to the user list
                if(oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending Delivery Review'){
                    userSet.add(matrix.Technical_Review__c);
                }
                else if(oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending DM Review'){
                    userSet.add(matrix.Technical_Review__c);
                    userSet.add(matrix.Delivery_Review__c);
                }
                else if(oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending Commercial Review'){
                    userSet.add(matrix.Technical_Review__c);
                    userSet.add(matrix.Delivery_Review__c);
                    userSet.add(matrix.DM_Review__c);
                }
                else if(oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending VP Review'){
                    userSet.add(matrix.Technical_Review__c);
                    userSet.add(matrix.Delivery_Review__c);
                    userSet.add(matrix.DM_Review__c);
                    userSet.add(matrix.Commercial_Review__c);
                }            
                else if(oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending OPS Review'){
                    userSet.add(matrix.Technical_Review__c);
                    userSet.add(matrix.Delivery_Review__c);
                    userSet.add(matrix.DM_Review__c);
                    userSet.add(matrix.Commercial_Review__c);
                    if(rejectedEngagementList[0].psa_Requires_VP_Approval__c){
                      userSet.add(matrix.VP_Review__c);
                    }
                }
                else if(oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending Legal Review' || oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending Finance Review'
                        || oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Pending Customer Approval' || oldMap.get(rejectedEngagementList[0].Id).psa_Status__c == 'Ready for Docusign'){
                    //Get the Queue members from the list and add them to the User List
                    List<GroupMember> membersList = new List<GroupMember>();
                    if(rejectedEngagementList[0].psa_Region_GEO__c == 'North America' || rejectedEngagementList[0].psa_Region_GEO__c == 'Latin America'){
                        membersList  = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'PSA_NA_Deal_Desk'];                                 
                    }
                    else if (rejectedEngagementList[0].psa_Region_GEO__c == 'EMEA'){
                        membersList  = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'PSA_EMEA_Deal_Desk'];
                    }
                    else if (rejectedEngagementList[0].psa_Region_GEO__c == 'APJ'){
                        membersList  = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'PSA_APJ_Deal_Desk'];
                    }
                    for(GroupMember member : membersList){
                        userSet.add(member.UserOrGroupId);
                    }  
                    userSet.add(matrix.Technical_Review__c);
                    userSet.add(matrix.Delivery_Review__c);
                    userSet.add(matrix.DM_Review__c);
                    userSet.add(matrix.Commercial_Review__c);
                    if(rejectedEngagementList[0].psa_Requires_VP_Approval__c){
                      userSet.add(matrix.VP_Review__c);
                    }
                }     
                if(userSet.size() > 0){
                    sendEmailToUsers(userSet,rejectedEngagementList[0].Id);                   
                }
            }
        }
    }   
   
   /** 
    * @description -  Method to send email to users - using future method because Rejection comments will not be available during trigger context
    * @param userIdSet - list of user Ids to send the email
    * @param engagementId - engagement Id
    * @throws exception - NA
    */
    @future
    public static void sendEmailToUsers(Set<Id> userIdSet, Id engagementId){
        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>();        
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'PSA_Engagement_Rejection' LIMIT 1];
        for(Id userId : userIdSet){
            if(userId != null){
                Messaging.SingleEmailMessage emailMsg = Messaging.renderStoredEmailTemplate(et.Id,null,engagementId);  
                emailMsg.setTargetObjectId(userId);
                emailMsg.setWhatId(engagementId);
                if(et != null){
                    emailMsg.setTemplateId(et.Id);
                }                
                //must be false if sending to internal user    
                emailMsg.setSaveAsActivity(false);  
                emailMsg.setSubject('Engagement Request rejected');  
                emailMsg.setBccSender(false);  
                emailMsg.setUseSignature(false);  
                emailMsgList.add(emailMsg);
            }
        }   
        try{
            Messaging.sendEmail(emailMsgList);   
        }
        catch(Exception e){
            gam.CreateExceptionRecords('PSA_EngagementTriggerHelper.sendEmailToUsers--> sending Engagement rejection email failed', e.getMessage(),engagementId);
        }  
    }    
    /** 
    * @description - Method to unlock the Engagement record to edit the Signatory name, email and Sales notes details
    * @param flowDetails - list of flowDetails wrapper Class
    * @throws exception - NA
    */
    @InvocableMethod(label='Unlock Engagement record')
    public static void unlockRecord(List<FlowDetailParams> flowDetails)
    {
        Approval.Unlock(flowDetails[0].engId, false);
        Engagement__c eng = [SELECT Id FROM Engagement__c WHERE Id = :flowDetails[0].engId];
        eng.PSA_Signatory_Name__c = flowDetails[0].signName;
        eng.PSA_Signatory_email_address__c = flowDetails[0].signEmail;
        eng.PSA_Sales_Notes__c = flowDetails[0].notes;
        update eng;
        Approval.Lock(flowDetails[0].engId, false);
    }
    /**
    * @description - wrapper class to get the invocable variables from the flow
    */
    public class FlowDetailParams{
        @InvocableVariable(required=true)
        public String engId;
        
        @InvocableVariable
        public String signName;
        
        @InvocableVariable
        public String signEmail;
        
        @InvocableVariable
        public String notes;
    }
    //</T1>
    /** <T2>
    * @description - Method to alert the users to attach the file before submitting the Engagement for approval
    * @param listNew - list of Engagements
    * @param mapNew - map of new Engagements
    * @param mapOld - map of old Engagements
    * @throws exception - NA
    */
    public void validationOnEngagement(List<Engagement__c> listNew, Map<Id,Engagement__c> mapNew, Map<Id,Engagement__c> mapOld){
        Set<Id> engIdSet = new Set<Id>();//store all the engagement Ids that belongs to record type PSA
        String recordTypeId;//hold the record type id of the engagement
        Boolean fileAttached = false; //boolean to check if the file is attached
        String engRecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Professional_Services_SOW_Review').getRecordTypeId();
        for(Engagement__c eng : listNew){
            recordTypeId = eng.RecordTypeId;
            //When the Engagement is submitted for approval
            if(recordTypeId.contains(engRecordTypeId) && eng.PSA_Submit_for_Approval__c && mapNew.get(eng.Id).PSA_Submit_for_Approval__c != mapOld.get(eng.Id).PSA_Submit_for_Approval__c){
                engIdSet.add(eng.Id);
            }
        }
        if(engIdSet.size() > 0){
            for(AggregateResult agr : [SELECT LinkedEntityId, COUNT(ContentDocumentId) fileCount FROM ContentDocumentLink 
                            WHERE LinkedEntityId IN :engIdSet 
                            GROUP BY LinkedEntityId]){
                if(Integer.valueOf(agr.get('fileCount')) > 0){
                    fileAttached = true;
                    
                }
            }
            if(!fileAttached){
                listNew[0].addError('Attach the SOW document before submitting for approval');
            }
        }        
    }
    //</T2>
}