/*
* Name         :   helpGroupCommunityPostMail
* Author       :   Saumya Gaikwad
* Created Date :   03-AUG-2022
* Description  :   Class for sending email to all the members in a group.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Saumya Gaikwad        03-AUG-2022      I2RT-6640         Initial version.                                             NA
Deeksha Shetty        21-Oct-2022      I2RT-7391         Event: Discussions are not getting posted in larger groups   NA
Deeksha Shetty        21-Feb-2023      I2RT-7756         Special Characters are displaying in the email instead of    NA
                                                         Japanese characters for both create/update discussion.

Deeksha Shetty        21-Apr-2023     I2RT-7440          Product community: New discussion notification email         T1
Deeksha Shetty        08-May-2023     I2RT-8346          New User - Ask a Question - Email trigger is not             T2
                                                         happening when user create or update a discussion
Deeksha Shetty       15-June-2023    I2RT-8423           Provision to create poll in product community                T3
														 
*/
public without sharing class helpGroupCommunityPostMail {
    /* T1 starts*/
    @InvocableMethod(label='Send Community Post Email Notification') 
    public static void getParamsFromFlow(List<EmailDetailsWrapper> EmailDataFromFlow){ 
        try{
            system.debug('EmailDataFromFlow='+EmailDataFromFlow[0]);            
            Id networkId = System.label.IN_NetworkID;
            //T2 if block condition. Added networkscope check
            if(EmailDataFromFlow[0].NetworkScope == networkId && (EmailDataFromFlow[0].UGId!=null || EmailDataFromFlow[0].TopicId!=null)){
                system.debug('EmailDataFromFlow Inside IF='+EmailDataFromFlow[0]);
                INSendGridController.sendMailOnFeedCreationOrUpdation(EmailDataFromFlow[0].DiscussionID,EmailDataFromFlow[0].UGId,EmailDataFromFlow[0].TopicId,
                                                                      EmailDataFromFlow[0].ProductOrUGLink,EmailDataFromFlow[0].Subject,
                                                                      EmailDataFromFlow[0].isDiscussionCreated,EmailDataFromFlow[0].TopicOrUsrGrpName,
                                                                      EmailDataFromFlow[0].DiscussionTitle,EmailDataFromFlow[0].DiscussionDesc,
                                                                      EmailDataFromFlow[0].DiscussionCreator,EmailDataFromFlow[0].DiscussionLink,
                                                                      EmailDataFromFlow[0].CreatorLink,EmailDataFromFlow[0].isPoll);                                
            }       
        }
        Catch(Exception e){
            system.debug('Send Email Failed : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }              
    }
    
    
    Public class EmailDetailsWrapper{
        
        @InvocableVariable(label='UG ID')
        public String UGId;        
        @InvocableVariable(label='Topic Id')
        public String TopicId;                
        @InvocableVariable(label='TopicOrUsrGrpName')
        public String TopicOrUsrGrpName;
        @InvocableVariable(label='DiscussionTitle')
        public String DiscussionTitle;
        @InvocableVariable(label='DiscussionDesc')
        public String DiscussionDesc;
        @InvocableVariable(label='DiscussionCreator')
        public String DiscussionCreator;
        @InvocableVariable(label='DiscussionLink')
        public String DiscussionLink;
        @InvocableVariable(label='CreatorLink')
        public String CreatorLink;        
        @InvocableVariable(label='isDiscussionCreated')
        public Boolean isDiscussionCreated;
        @InvocableVariable(label='Subject')
        public String Subject;
        @InvocableVariable(label='ProductOrUGLink')
        public String ProductOrUGLink;
        @InvocableVariable(label='NetworkScope')
        public String NetworkScope; //T2
        @InvocableVariable(label='DiscussionID')
        public String DiscussionID; 
        @InvocableVariable(label='isPoll')
        public Boolean isPoll; //T3
        /*T1 ends*/
    }
    
}