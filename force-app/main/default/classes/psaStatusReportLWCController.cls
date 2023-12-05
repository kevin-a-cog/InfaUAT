/*
Name             : psaStatusReportLWCController 
@Author          : Rohit Niranjanamath
@Created Date    : Aug 12, 2023
@Description     : PSA-3061     

Change Log
**************************************************************************************************************************
ModifiedBy  Date            JIRA No.  Requested By  Description                             Tag

**************************************************************************************************************************
*/
public with sharing class psaStatusReportLWCController {
  public static globalApexManager GAM = new globalApexManager();
  //Wrapper class to store the Project's related objects details
  public class DataWrapper{
      @AuraEnabled        
    public List<pse__Issue__c> issuesList {get; set;}
      @AuraEnabled        
    public List<pse__Risk__c> risksList {get; set;}
      @AuraEnabled
    public List<pse__Assignment__c> assignmentList {get; set;}
    @AuraEnabled
    public List<Task> prjActList{get; set;}
      @AuraEnabled
    public List<pse__Milestone__c > milestoneList {get; set;}
  }

  //Method to get the Project and the related objects details
   @AuraEnabled(cacheable = true)
   public static DataWrapper getProjectData(String statusRecordId){
        DataWrapper wrapper = new DataWrapper();
        Id prjctId = [SELECT PSA_PM_Project__c FROM Status_report__c WHERE id=:statusRecordId LIMIT 1]?.PSA_PM_Project__c;
        wrapper.issuesList = [SELECT Id,pse__Issue_Name__c,pse__Issue_Description__c,pse__Date_Raised__c,PSA_Status__c,PSA_Priority__c,pse__Action_Plan__c FROM pse__Issue__c WHERE pse__Project__c=:prjctId AND PSA_Status__c ='OPEN'];
        wrapper.risksList = [SELECT Id,pse__Risk_Name__c,pse__Risk_Description__c, PSA_Status__c,PSA_Impact__c,pse__Mitigation_Plan__c FROM pse__Risk__c WHERE pse__Project__c=:prjctId AND PSA_Status__c ='OPEN'];
        wrapper.assignmentList = [SELECT Id,Name, pse__Planned_Hours__c,pse__Resource__r.Name,pse__Billable_Hours_Submitted__c FROM pse__Assignment__c  WHERE pse__Project__c=:prjctId AND pse__Project__r.pse__Billing_Type__c='Time and Materials' ];
        wrapper.prjActList = [SELECT Id,psa_Target_Date__c,psa_Actual_Date__c,psa_Comments__c,psa_Reason__c,psa_Critical_Path__c,psa_Status_Notes__c,psa_Status__c,subject,psa_Action_Plan__c FROM Task WHERE WhatId = :prjctId AND psa_Status__c IN ('Accomplished','Incomplete','Upcoming')];
        wrapper.milestoneList =[SELECT Id,Name,psa_pm_Project_Manager_Notes__c,pse__Status__c  FROM pse__Milestone__c WHERE pse__Status__c ='Approved' AND pse__Project__c =:prjctId];
        return wrapper;
   }

   //Method to insert the selected records to Status Report Detail
   @AuraEnabled
   public static Boolean insertSRDRecords(String statusReportId, List<String> issueRecords, List<String> riskRecords, List<String> assignmentRecords, List<String> prjActRecords, List<String> milestoneRecords){
    DataWrapper wrapper = new DataWrapper();
    List<Status_Report_Detail__c> srdRecordsList = new List<Status_Report_Detail__c>();
    List<Status_Report_Detail__c> delrecords = [SELECT Id FROM Status_Report_Detail__c WHERE PSA_Status_Report__c=:statusReportId];
    
    //Add the Issues to the SRD List
    for(Integer i = 0;i<issueRecords.size();i++){
      Status_Report_Detail__c newRecord = new Status_Report_Detail__c();
      newRecord.PSA_Issue__c = issueRecords[i];
      newRecord.PSA_Status_Report__c = statusReportId;
      srdRecordsList.add(newRecord);
    }
    //Store the Risks to the SRD List
    for(Integer i = 0;i<riskRecords.size();i++){
      Status_Report_Detail__c newRecord = new Status_Report_Detail__c();
      newRecord.PSA_Risk__c = riskRecords[i];
      newRecord.PSA_Status_Report__c = statusReportId;
      srdRecordsList.add(newRecord);
    }
    //Store the Assignments to the SRD List
    for(Integer i = 0;i<assignmentRecords.size();i++){
      Status_Report_Detail__c newRecord = new Status_Report_Detail__c();
      newRecord.PSA_Assignment__c = assignmentRecords[i];
      newRecord.PSA_Status_Report__c = statusReportId;
      srdRecordsList.add(newRecord);
    }
    //Store the Project Activities to the SRD List
    for(Integer i=0;i<prjActRecords.size();i++){
      Status_Report_Detail__c newRecord = new Status_Report_Detail__c();
      newRecord.PSA_Project_Activity__c	 = prjActRecords[i];
      newRecord.PSA_Status_Report__c = statusReportId;
      srdRecordsList.add(newRecord);
    }
    //Store the Milestones to the SRD List
    for(Integer i=0;i<milestoneRecords.size();i++){
      Status_Report_Detail__c newRecord = new Status_Report_Detail__c();
      newRecord.PSA_Milestone__c = milestoneRecords[i];
      newRecord.PSA_Status_Report__c = statusReportId;
      srdRecordsList.add(newRecord);
    }
    try{
      //Delete the existing Status Report Detail records
      if(delrecords.size()>0){
        delete delrecords;
      }
      //Insert the new Status Report Detail records
      if(srdRecordsList.size() > 0){
        insert srdRecordsList;
      }
    }
    catch(Exception e){
      GAM.CreateExceptionRecords('psaStatusReportLWCController.insertSRDRecords() -> ' + e.getCause(),e.getmessage(), statusReportId);
      throw new AuraHandledException(e.getMessage());
    }    
    return true;
   }
   
   //Method to generate PDF in the VF Page
   @AuraEnabled(cacheable = false)
   public static Boolean generatePDF(String statusReportId){
      //Generate PDF in new template 
        System.debug('It did get here');
        Status_Report__c statsRepRec = [Select Id,Status_Report_Name__c from Status_Report__c where Id=:statusReportId];
        List<ContentDocumentLink> delConDocument = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:statusReportId AND ShareType = 'I'];
        
        pageReference srPage;
        srPage = Page.psaGenerateStatusReportPDF;
        srPage.getParameters().put('id', statusReportId);
        Blob body;
        
        if(!test.isRunningTest()){  
            body = srPage.getContent();
        }else{
            body=blob.valueOf('I WANT TO TEST THIS OUT.....');
        }
        if(!delConDocument.isEmpty()){
            delete delConDocument;
        }
        
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = 'StatusReport.pdf';//File name with extention
        cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getuserid();//Owner of the file
        cVersion.Title = statsRepRec.Status_Report_Name__c+'_'+String.valueOf(Date.today()).removeEnd(' 00:00:00');//Name of the file
        cVersion.VersionData = body;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = statusReportId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;    
      return true;
   }

   
}