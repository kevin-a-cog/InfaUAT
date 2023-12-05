/*
@created by       : Sandeep Duggi
@created on       : 11/06/2021
@Purpose          : Async Helper to send Emails through Send Grid API 
@Testclass        : 
@JIRA             : 



Change History
****************************************************************************************************
ModifiedBy      Date        Requested By        Description               Jira No.       Tag
****************************************************************************************************

*/
public class BulkConfigureEmail implements Queueable, Database.AllowsCallouts{
    
    @TestVisible private   List<Case_Comment__c> CaseComments ; 
    @TestVisible private   Map<Id, Case_Comment__c> oldMapOfCaseComments ;
    @TestVisible private   Integer index;
    public static globalApexManager GAM = new globalApexManager();
    
    public BulkConfigureEmail(List<Case_Comment__c> CaseCommentsToSendEmail , Map<Id, Case_Comment__c> oldMapOfCaseComments){
        init(CaseCommentsToSendEmail, oldMapOfCaseComments, 0); 
        //this.index = this.CaseComments.indexOf(this.CaseComments.get(this.CaseComments.size() - 1));   
        
    }  
    
    public BulkConfigureEmail(List<Case_Comment__c> CaseCommentsToSendEmail , Map<Id, Case_Comment__c> oldMapOfCaseComments, Integer index) {
        init(CaseCommentsToSendEmail, oldMapOfCaseComments, index); 
    }
    private void init(List<Case_Comment__c> CaseCommentsToSendEmail , Map<Id, Case_Comment__c> oldMapOfCaseComments, Integer index){
        this.CaseComments = CaseCommentsToSendEmail;
        this.oldMapOfCaseComments = oldMapOfCaseComments;
        this.index = index;
    }
    
    public void execute(QueueableContext qc){
        
        Case_Comment__c casecomm;
        if(index < CaseComments.size()){
            casecomm = CaseComments.get(index);            
            Map<String, String> emaillist = new Map<String, String>();
            Case c1 = new Case();
            c1 = [Select ContactId,Is_Internal_Or_External_Case__c,Contact.Name,casenumber,Record_Type_Name__c,Status,Support_Account__c,RecordTypeId,RCA_Pending_flag__c from Case where Id = :casecomm.case__c];
            for(Case_Contact__c cc : [Select Id,Case__c,Email__c,Contact__c,Case__r.ContactId,Case__r.casenumber,Contact__r.Name,Contact__r.Email  from Case_Contact__c where Case__c = :casecomm.Case__c]){
                
                if(cc.Contact__r?.Email != null){ emaillist.put(cc.Contact__r.Email,cc.Contact__r.Name);} 
                else if(cc.Email__c != null) {  emaillist.put(cc.Email__c,cc.Email__c); }
            }
            if(casecomm.Sub_Type__c == 'Initial Response'){
                for(AccountContactRelation acr : [Select Id,ContactId,Contact.Email from AccountContactRelation where AccountId = :c1.Support_Account__c and Primary__c = true and IsActive = true]){
                    if(acr.ContactId != null && acr.Contact.Email != null){emaillist.put(acr.Contact.Email,acr.Contact.Email);}
                }
            }
            system.debug('casecomm.Visibility__c'+casecomm.Visibility__c);
            system.debug('casecomm.Inbound__c '+casecomm.Inbound__c );
            system.debug('c1.Is_Internal_Or_External_Case__c'+c1.Is_Internal_Or_External_Case__c);
            system.debug('casecomm.Status__c'+casecomm.Status__c);    
            system.debug('c1.casenumber'+c1.casenumber);
            system.debug('c1.Contact.Name.' + c1.Contact.Name);
            
            Boolean closecase = false;
            if(casecomm.type__c == 'Close Case'){closecase  = true;}
            
            if(casecomm.Visibility__c == 'External' && !casecomm.Inbound__c && !casecomm.Email_Sent__c &&  Label.triggeremails == 'true'  && emaillist != null &&  emaillist.size() > 0 && c1.Is_Internal_Or_External_Case__c != 'Internal' && ((oldMapOfCaseComments == null && casecomm.Status__c == 'Submitted') || (oldMapOfCaseComments != null && oldMapOfCaseComments?.get(casecomm.Id)?.Status__c != casecomm.Status__c && casecomm.Status__c == 'Submitted') || (oldMapOfCaseComments != null && oldMapOfCaseComments?.get(casecomm.Id)?.Visibility__c  != casecomm.Visibility__c) || (oldMapOfCaseComments != null && closecase))){
                SendGridGCSController.SendGridrequestwrapper sgs = new SendGridGCSController.SendGridrequestwrapper();
                sgs.casenum = c1.casenumber;if(c1.Contact.Name != null){ sgs.conname = c1.Contact.Name.replace('\'', '&#39;');} sgs.priority = casecomm.Importance__c; 
                sgs.ccomentid = casecomm.Id; sgs.emaillist = emaillist;
                if(casecomm.Sub_Type__c == 'Initial Response' && c1.Record_Type_Name__c == 'Ask An Expert'){ sgs.usecase = 'GCS Initial Response AAE'; }
                else if(casecomm.Sub_Type__c == 'Initial Response'){ sgs.usecase = 'GCS Initial Response'; } 
                else { sgs.usecase = 'GCS General Response'; } 
                
				 if(!Test.isRunningTest()){SendGridGCSController.configureEmail(JSON.serialize(sgs));}
            }
            
            if(index < CaseComments.size() - 1){
                try{ 
                    BulkConfigureEmail emailQueue = new BulkConfigureEmail(CaseComments, oldMapOfCaseComments, ++index);
                    if(!Test.isRunningTest()){Id jobId = System.enqueueJob(emailQueue);}
                }catch (Exception e){ GAM.CreateExceptionRecords('CaseCommentTriggerHelper', 'Exception in callSendGridService',e.getMessage());}
            }
            
            
            
        }
        
        
        
        
    }
    
    
}