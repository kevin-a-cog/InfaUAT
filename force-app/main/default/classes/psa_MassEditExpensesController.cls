/*
@created by       : Wasim Akram
@created on       : 08/24/2020
@Purpose          : Controller class for LWC Component massEditExpenses.

Change History
********************************************************************************************************************************
ModifiedBy      Date            Requested By         Description                                    Jira No.        Tag No:  
********************************************************************************************************************************
Vivek Warrier   03-02-2022      Diwan KC             Fixing issues with Record Locked               PSA-2244        T01
*/    

public without sharing class psa_MassEditExpensesController {
    /**
    * This method will get the Expense details on page load
    * @param String
    * @return List<pse__Expense__c>
    * @throws exception - NA
    */
    
    @AuraEnabled(Cacheable = true)
    public static List<pse__Expense__c> fetchExpenses(String recId) {
        return [SELECT Id, pse__Expense_Report__c,CurrencyIsoCode, Name, pse__Type__c,pse__Description__c, pse__Amount__c,pse__Expense_Date__c,PSA_EM_Audited__c,
                PSA_EM_Sent_To_ERP_For_Reimbursement__c, pse__Tax_Type__c, pse__Incurred_Tax__c, pse__Billable__c, pse__Amount_To_Reimburse__c FROM pse__Expense__c 
                WHERE pse__Expense_Report__c = :recId ];         
    }
    @AuraEnabled(Cacheable = true)
    public static pse__Expense_Report__c fetchExpenseReport(String recId){
        return [SELECT pse__Audit_Notes__c,psa_SSC_Reviewed_Date__c FROM pse__Expense_Report__c WHERE Id = :recId];
    }
    
  /**
    * This method will update the Expense details on save
    * @param Object
    * @return String
    * @throws exception - NA
    */
    @AuraEnabled
    public static String updateExpenses(Object data, String auditNotes, Date sscReviewedDate, String recordId) {   
        List<pse__Expense__c> expensesForUpdate = (List<pse__Expense__c>)JSON.deserialize(JSON.serialize(data),List<pse__Expense__c>.class);
        pse__Expense_Report__c expensesReport;
        List<pse__Expense_Report__c> expensesReportList = new List<pse__Expense_Report__c>();
        if(expensesForUpdate.size() > 0){
            expensesReport = new pse__Expense_Report__c(Id = recordId, psa_SSC_Reviewed_Date__c = sscReviewedDate,
                                                        pse__Audit_Notes__c = auditNotes);
            expensesReportList.add(expensesReport);
        }
        try{
            if(expensesReportList.size() > 0){
                List<Approval.UnlockResult> ulrList = Approval.unlock(expensesReportList, false);
                Database.SaveResult[] saveResultList = Database.update(expensesForUpdate);
                if (saveResultList[0].isSuccess()) {
                    update expensesReportList;
                }
                List<Approval.LockResult> lrList = Approval.lock(expensesReportList, false);
                return 'SUCCESS';
            }
            else{
              return 'No Expense record to process';
            }
        }
        catch(Exception e){
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    //<T01>
    @AuraEnabled
    public static String serviceNowEmailMethod(Id recordId, String email, String notes){   
                
        List<pse__Expense_Report__c> newList = [SELECT Id,pse__Resource__c,PSA_EM_Expense_Report_ID__c,pse__Total_Reimbursement_Amount__c,pse__Reimbursement_Currency__c,PSA_EM_Business_Unit__c,ServiceNow_Email_Sent__c FROM pse__Expense_Report__c WHERE Id =:recordId];
        Map<Id,Contact> mContact = new Map<Id,Contact>();
        List<Id> lContactId = new List<Id>();
        List<pse__Expense_Report__c> unlockList = new List<pse__Expense_Report__c>();
        List<Id> newIdList = new List<Id>();

        for(pse__Expense_Report__c er : newList){
            lContactId.add(er.pse__Resource__c);
            newIdList.add(er.Id);
        }

        for(Contact c : [SELECT Id,Name,Email FROM Contact WHERE Id IN :lContactId]){
            mContact.put(c.Id,c);
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<Id,List<Messaging.Emailfileattachment>> mapFileAttachments = new Map<Id,List<Messaging.Emailfileattachment>>();
        Map<Id,Id> ContentDocumentidsMap = new Map<Id,Id>();

        for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid IN :newIdList])
        {  
            ContentDocumentidsMap.put(CDLink.ContentDocumentId,CDLink.LinkedEntityid);
        }

        for (ContentVersion cversion : [SELECT title, PathOnClient, FileType, versiondata, ContentDocumentId FROM contentversion WHERE ContentDocumentId IN :ContentDocumentidsMap.keySet()])
        {
            blob WOCFbody = cversion.versiondata;
            system.debug('body : '+WOCFbody+'-----------'+cversion.title);
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(cversion.title+'.'+cversion.FileType);
            efa.setBody(WOCFbody);

            if(mapFileAttachments.containsKey(ContentDocumentidsMap.get(cversion.ContentDocumentId))){
                mapFileAttachments.get(ContentDocumentidsMap.get(cversion.ContentDocumentId)).add(efa);
            }
            else{
                mapFileAttachments.put(ContentDocumentidsMap.get(cversion.ContentDocumentId),new List<Messaging.Emailfileattachment>{efa});
            } 
        }

        /* for (Attachment a : [select Id, Name, Body, BodyLength, ContentType from Attachment where ParentId IN :oldMap.keySet()]){
            // Add to attachment file list
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            efa.setContentType(a.ContentType);
            efa.setInline(false);

            if(mapFileAttachments.containsKey(a.ParentId)){
                mapFileAttachments.get(a.ParentId).add(efa);
            }
            else{
                mapFileAttachments.put(a.ParentId,new List<Messaging.Emailfileattachment>{efa});
            }
        } */
        
        for(pse__Expense_Report__c er : newList){
            if(!er.ServiceNow_Email_Sent__c){
                List<String> str = new List<String>();
                str.add(email);
                System.debug('str: ' + str);
                //if((er.Email_for_ServiceNow__c != oldMap.get(er.Id).Email_for_ServiceNow__c || er.psa_ServiceNow_Notes__c != oldMap.get(er.Id).psa_ServiceNow_Notes__c) && er.ServiceNow_Email_Sent__c == false){
                unlockList.add(er);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(str);
                mail.setSenderDisplayName('Financialforce Expense Reports');
                mail.setSubject('Expense Report Approval ' + er.PSA_EM_Expense_Report_ID__c + ' for ' + mContact.get(er.pse__Resource__c).Name + '(' + er.pse__Total_Reimbursement_Amount__c + ' ' + er.pse__Reimbursement_Currency__c + ')');
                mail.setPlainTextBody('Caller: ' + mContact.get(er.pse__Resource__c).Name + '\nEmail: ' + mContact.get(er.pse__Resource__c).Email + '\nBusiness Unit: ' + er.PSA_EM_Business_Unit__c + '\nReport Key: ' + er.PSA_EM_Expense_Report_ID__c + '\nCategory: Expense - Financialforce\nComment: ' + notes);
                //Set email file attachments
                if(mapFileAttachments.get(er.Id) != null) mail.setFileAttachments(mapFileAttachments.get(er.Id));
                mails.add(mail);          
                er.ServiceNow_Email_Sent__c = true;
            }
            else{
                return 'MAIL_SENT';
            }
        }  
        
        try{
            System.debug('Going to send email: ' + mails);
            //Adding mails in a list and invoking it once
            if (!mails.isEmpty()) {
                Messaging.SendEmailResult[] r = Messaging.sendEmail(mails);
                System.debug('r :' + r);
            }

            Approval.UnlockResult[] ulList = Approval.Unlock(unlockList, false);
            if(!newList.isEmpty()){
                Database.SaveResult[] saveResultList = Database.update(unlockList);
            }
            Approval.LockResult[] lList = Approval.Lock(unlockList,false);
            return 'TRUE';
        }
        catch(Exception e){
            return 'FALSE';
        }
    }
}