/*
Class:          SendGridResponse
@Author:        Venky K
@Created Date:  1-Feb-2021
@Description:   SendGridResponse class to handle response from sendgrid.

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@RestResource(urlMapping='/SendgridResponse')
global class SendGridResponse {

    @HttpPost
    global static void doPost() {
		Id idRecord;
		String strObjectName;
		PlanCommentEmailStat__c objPlanCommentEmailStatistics = new PlanCommentEmailStat__c();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Boolean ignoreevent = false;
            List<Case_Comment__c> cclist = new List<Case_Comment__c>();
            System.debug('---req ---'+req);
            System.debug('---res---'+res);
            string jsonbody = req.requestBody.toString();
            System.debug('---jsonbody---'+jsonbody);
            list<SendGridResponseJSON> objlist = (List<SendGridResponseJSON>) System.JSON.deserialize(jsonbody, List<SendGridResponseJSON>.class);
            SendGridResponseJSON obj = objlist[0];
            System.debug('---obj---'+obj);                     
            System.debug('email     = ' + obj.email);
            System.debug('event   = ' + obj.event);
            System.debug('ip  = ' + obj.ip);
            System.debug('contenttype  = ' + obj.sg_content_type);
            System.debug('event    = ' + obj.sg_event_id);
            System.debug('messageid     = ' + obj.sg_message_id); 
            System.debug('templateid     = ' + obj.sg_template_id); 
            System.debug('templatename     = ' + obj.sg_template_name); 
            System.debug('timestamp     = ' + obj.timestamp); 
            System.debug('useragent     = ' + obj.useragent); 
            System.debug('ccid     = ' + obj.ccid);

			//Now we determine the object of the record.
			if(obj != null && String.isNotBlank(obj.ccid)) {
				idRecord = obj.ccid;
				strObjectName = idRecord.getSObjectType().getDescribe().getName();
				switch on strObjectName {
					when 'Case_Comment__c' {       
						cclist = [SELECT Id from Case_Comment__c where id = :obj.ccid];
						if(cclist.size() > 0){
							Case_Comment__c cc = new Case_Comment__c();
							cc.Id = obj.ccid;
							cc.SendGrid_EventId__c = obj.sg_event_id;
							cc.Sendgrid_MessageId__c = obj.sg_message_id;
							cc.Sendgrid_Timestamp__c = obj.timestamp;
							CaseCommentEmailStat__c cce = new CaseCommentEmailStat__c();
							cce.Email__c = obj.email;
							cce.case_comment__c = obj.ccid;
							cce.Comment_Email_Id__c = obj.ccid+obj.email;
							switch on obj.event {
								when 'open' {       
									cc.Email_Opened__c = true;
									cce.Email_Opened__c = true;
								}
								when 'click' {      
									cc.Email_Clicked__c = true;
									cce.Email_Clicked__c = true;
								}
								when 'processed','bounce','delivered','dropped','deferred'{
									cc.Delivery__c = obj.event;
									cce.Delivery__c = obj.event;
								}                    
								when else {       
									
								}
							}
							upsert cce Comment_Email_Id__c;
						}
					}

					//Plan Comment related record.
					when 'Plan_Comment__c' {
						for(Plan_Comment__c objPlanComment : [SELECT Id FROM Plan_Comment__c WHERE Id = :idRecord LIMIT 1]) {

							//We update the plan comment.
							objPlanComment.SendGrid_EventId__c = obj.sg_event_id;
							objPlanComment.Sendgrid_MessageId__c = obj.sg_message_id;
							objPlanComment.Sendgrid_Timestamp__c = obj.timestamp;
							
							//Now we prepare the statistics.
							objPlanCommentEmailStatistics.Email__c = obj.email;
							objPlanCommentEmailStatistics.Plan_Comment__c = idRecord;
							objPlanCommentEmailStatistics.Comment_Email_Id__c = idRecord + obj.email;

							//We check the event.
							switch on obj.event {
								when 'open' {       
									objPlanComment.Email_Opened__c = true;
									objPlanCommentEmailStatistics.Email_Opened__c = true;
								}
								when 'click' {      
									objPlanComment.Email_Clicked__c = true;
									objPlanCommentEmailStatistics.Email_Clicked__c = true;
								}
								when 'processed', 'bounce', 'delivered', 'dropped', 'deferred' {
									objPlanComment.Delivery__c = obj.event;
									objPlanCommentEmailStatistics.Delivery__c = obj.event;
								}
							}

							//Finally, we upser the records.
							upsert objPlanCommentEmailStatistics Comment_Email_Id__c;
							update objPlanComment;
						} 
					}
				}
			}
        } catch (exception e) {
            system.debug('Exception occured'+e.getmessage());
        }
    }
	
    public class SendGridResponseJSON {
        public string email    {get;set;}
        public string event  {get;set;}
        public string ip    {get;set;}
        public string sg_content_type {get;set;}
        public string sg_event_id {get;set;}
        public string sg_message_id   {get;set;}
        public string sg_template_id   {get;set;}
        public string sg_template_name   {get;set;}
        public string timestamp   {get;set;}
        public string useragent   {get;set;}
        public string ccid   {get;set;}
    }
}