/*
Class:          SendGridWrapper
@Author:        Venky K
@Created Date:  1-Feb-2021
@Description:   SendGridWrapper wrapper class for sendgrid emails.

Change History
***********************************************************************************************************
ModifiedBy          Date        JIRA #      Description                                             Tag
***********************************************************************************************************
Narpavi Prabu       06-07-2022  AR-2740     Add user Nickname in send grid email                    T01
balajip             22-08-2022  I2RT-6867   added attribute isCaseLite                              T02
Deeksha Shetty      21-11-2022  I2RT-7272   Event: Notification email for cloud release events      T03
Deeksha Shetty      18-04-2023  I2RT-7440   Product community: New discussion notification email    T04
Deeksha Shetty      15-06-2023  I2RT-8423   Provision to create poll in product community           T05
*/

public class SendGridWrapper {
    
    public class SendGridRequestWrapper {
        public List<Personalizations> personalizations {get;set;} 
        public EmailIdWrapper from_z {get;set;}
        public EmailIdWrapper reply_to {get;set;}   
        public List<Content> content {get;set;}       
        public Mail_settings mail_settings {get;set;} 
        public Tracking_settings tracking_settings {get;set;}
        public Header headers {get;set;}
        public String template_id{get;set;}      
        public List<FileObject> attachments {get; set;}  
    }
    
    public class Mail_settings {
        public Enable_Mode sandbox_mode {get;set;} 
    } 
    
    public class Tracking_settings {
        public Enable_Mode click_tracking {get;set;} 
    }
    
    public class EmailIdWrapper {
        public String email {get;set;} 
        public String name {get;set;} 
    }
    
    public class Personalizations {
        public List<EmailIdWrapper> to {get;set;} 
        public String subject {get;set;}         
        //This is needed if we build template in SendGrid. We can pass the merge fields as attribute like below
        public Dynamictemplate dynamic_template_data {get;set;}           
        public uniqueargs custom_args{get;set;}    
    }
    
    //This is needed if we build template in SendGrid. We can pass the merge fields as attribute like below
    public class Dynamictemplate {   
        //Start Variable for GCS 
        public String name{get;set;}
        public String casenumber{get;set;}
        public String EngineerName{get;set;}
        public Date todaydate{get;set;}
        public String emailbody{get;set;}
        public String timezone{get;set;}        
        public String subject{get;set;} 
        public String priority{get;set;}
        public String product{get;set;}
        public String sendersignature{get;set;}
        public String accname{get;set;}
        public String primaryname{get;set;}
        public String responsetime{get;set;}
        public String viewcaseurl{get;set;}
        public String esupporturl{get;set;}
        public String acceptsolution{get;set;}
        public String declinesolution{get;set;}
        public String needmoretime{get;set;}
        public String salutation{get;set;} 
        public String version{get;set;}
        public String successoffering{get;set;}
        public String primaryconname{get;set;}
        public String sessiondetails{get;set;}
        public String productarea{get;set;}
        public String alternatecontacts{get;set;}
        public Boolean isaae{get;set;}
        public String casetype{get;set;}
        public Boolean showprodversion{get;set;}
        public Boolean showaccept{get;set;}
        
        //Ask An Expert Case status variables
        public Boolean aaebooked{get;set;}
        public Boolean aaescheduled{get;set;}
        public Boolean aaedelivered{get;set;}
        public Boolean aaecancelled{get;set;}
        
        //Case status variables
        public Boolean isnew{get;set;}
        public Boolean isassess{get;set;}
        public Boolean isresearch{get;set;}
        public Boolean issolution{get;set;}        
        public Boolean isclosed{get;set;}
        
        public Boolean isCaseLite{get;set;} //T02
        
        //End Variable for GCS 
        //Template General Response

		//Cosmos Variables.
		public Boolean boolHasProfilePicture {get; set;}
		public Boolean boolIsStage1 {get; set;}
		public Boolean boolIsStage2 {get; set;}
		public Boolean boolIsStage3 {get; set;}
		public Boolean boolIsStage4 {get; set;}
		public String strPlanComment {get; set;}
		public String strPlanName {get; set;}
		public String strAccountName {get; set;}
		public String strPlanStage {get; set;}
		public String strCSMPhotoURL {get; set;}
		public String strCSMEmail {get; set;}
		public String strCSMPhone {get; set;}
		public String strMilestoneDescription {get; set;}
		public String strMilestoneDueDate {get; set;}
		public String strPlanCommentDate {get; set;}
		public String strCSMName {get; set;}
		public String strPlanURL {get; set;}
		public String strRefId {get; set;}
		public String strPlanOwnerName {get; set;}
        //<T01>
        public String strPlanOwnerNickName {get; set;}
        
        //T03 - IN External Event variables  
    	public String EventTitle {get; set;}
        public String EventDetailUrl {get; set;}
		public String INURL {get; set;}
		public String SuccessURL {get; set;}
		public String KBURL {get; set;}	
        //T03 ends
        
        
        
        //T04 - IN Discussion variables  
        public String TopicOrUsrGrpName {get; set;}
		public String DiscussionTitle {get; set;}
		public String DiscussionDesc {get; set;}
		public String DiscussionCreator {get; set;}
        public String DiscussionLink {get; set;}
        public String CreatorLink {get; set;}
        public String DisSubject {get; set;}
        public String ProductOrUGLink {get; set;}
        public Boolean isDiscussionCreated {get; set;}
        public Integer currentYear {get; set;}
        public List<String> PollchoiceList {get; set;} //T05
        //T04 ends
    }
    

    public class uniqueargs {
        public String ccid{get;set;}        
    }

    public class Enable_Mode {
        public Boolean enable {get;set;} 
    }
     
    public class Header {
        public string priority {get;set;}
        public string importance {get;set;}
    }

    public class Content {
        public String type {get;set;} // in json: type
        public String value {get;set;} 
    }

    public class FileObject {
        public String filename {get; set;}
        public String type {get; set;}
        public String content_id {get; set;}
        public String content {get; set;}
        public String disposition {get; set;}
    }
}