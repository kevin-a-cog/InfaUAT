/*
Class             : SendGridINWrapper
@Author           : Prashanth Bhat
@Created Date     : 09-Aug-2023
@Description      : SendGridINWrapper wrapper class for IN&KB sendgrid emails.
@Test Coverage by : INSendGridControllerTest
Change History
***********************************************************************************************************
ModifiedBy           Date           JIRA #           Description                                       Tag
***********************************************************************************************************
Prashanth Bhat       09-08-2023     I2RT-9050        New SendGrid INWrapper                            N/A                       

*/
public class SendGridINWrapper {
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
		public String SuccessURL {get; set;}
		public String KBURL {get; set;}	 
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
        public List<String> PollchoiceList {get; set;}
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