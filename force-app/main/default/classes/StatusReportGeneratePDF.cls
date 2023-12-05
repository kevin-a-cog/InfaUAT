/*
@created by       : RANJAN KISHORE
@created on       : 02/17/2021
@Purpose          : This class is used as controller in the Lightning component "StatusReportGeneratePDF" and "generateStatusReportPDF"

Change History
******************************************************************************************************************************************
ModifiedBy              Date                Requested By        Description                                     Jira No.       Tag
Wasim                   07-Aug-2023                             Update Status Report functionality              PSA-3086       <T1>
Rohit Niranjanamath     14-Oct-2023         PSA Oct Build '23   Status report start date logic update           PSA-3174       <T2>
******************************************************************************************************************************************
*/
public class StatusReportGeneratePDF {
    
    //Generate PDF in Old Template
    @AuraEnabled
    public static ContentDocumentLink generatePDF(String srRecordId){
        
        System.debug('It did get here');
        Status_Report__c statsRepRec = [Select Id,Status_Report_Name__c from Status_Report__c where Id=:srRecordId];
        List<ContentDocumentLink> delConDocument = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:srRecordId //<T1>
                                                    AND ShareType = 'I'];
        
        pageReference srPage;
        srPage = Page.psaViewStatusPDF;
        srPage.getParameters().put('id', srRecordId);
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
        cDocLink.LinkedEntityId = srRecordId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        return cDocLink;
    }
    
    /* Project Issues and Risk variables*/
    public  class IssueAndRiskWrapper { 
        @AuraEnabled
        public List<pse__Risk__c> lstOfUnattachedRisks { get; set; } 
        @AuraEnabled
        public List<pse__Issue__c> lstOfUnattchedIssues{ get; set; } 
        @AuraEnabled
        public List<pse__Risk__c> lstOfAttachedRisks { get; set; } 
        @AuraEnabled
        public List<pse__Issue__c> lstOfAttachedIssues { get; set; } 
        
    }
    
    @AuraEnabled
    public static IssueAndRiskWrapper getIssuesAndRisk(String srRecordId){
        
        IssueAndRiskWrapper issueAndRiskData = new IssueAndRiskWrapper();
        Set<Id> attachedIssueIds = new Set<Id>();
        Set<Id> attachedRiskIds = new Set<Id>();
        
        issueAndRiskData.lstOfUnattachedRisks = new  List<pse__Risk__c>();
        issueAndRiskData.lstOfUnattchedIssues = new  List<pse__Issue__c>();
        issueAndRiskData.lstOfAttachedRisks = new  List<pse__Risk__c>();
        issueAndRiskData.lstOfAttachedIssues = new  List<pse__Issue__c>();
        
        Status_Report__c statsReportRec = [Select Id,PSA_PM_List_of_Issues_Id__c,PSA_PM_List_of_Risks_Id__c,PSA_PM_Project__c from Status_Report__c where Id=:srRecordId];
        
        List<Status_Report_Detail__c> statsDetailRec = [Select Id,PSA_Issue__c, PSA_Risk__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c from Status_Report_Detail__c  where PSA_Status_Report__c=:srRecordId];
        
        for(Status_Report_Detail__c statRec : statsDetailRec){
            
            if(!String.isBlank(statRec.PSA_Issue__c)){
                attachedIssueIds.add(statRec.PSA_Issue__c); 
                
            }
            if(!String.isBlank(statRec.PSA_Risk__c)){
                attachedRiskIds.add(statRec.PSA_Risk__c);
            }
        }
        
        
        List<pse__Risk__c> lstOfRisk = [Select Id,pse__Mitigation_Plan__c,PSA_Risk_History__c,pse__Project__c,pse__Risk_Name__c,PSA_Impact__c,pse__Severity__c,pse__Risk_Description__c,pse__Date_Raised__c,PSA_Status__c,
                                        pse__Closed_Date__c from pse__Risk__c where pse__Project__c=:statsReportRec.PSA_PM_Project__c order by PSA_Impact__c asc];
        
        List<pse__Issue__c> lstOfIssue = [Select Id,pse__Closed__c,pse__Issue_Name__c,pse__Action_Plan__c,pse__Severity__c,PSA_Priority__c, pse__Issue_Description__c, pse__Date_Raised__c, pse__Closed_Date__c, PSA_Status__c 
                                          from pse__Issue__c  where pse__Project__c=:statsReportRec.PSA_PM_Project__c order by PSA_Priority__c asc];
        
        
        if(!lstOfRisk.isEmpty()){
            
            for(pse__Risk__c riskRec : lstOfRisk){
                if(!attachedRiskIds.isEmpty() && attachedRiskIds.contains(riskRec.Id)){
                    issueAndRiskData.lstOfAttachedRisks.add(riskRec);
                }else{
                    issueAndRiskData.lstOfUnattachedRisks.add(riskRec);
                }
            }
        }
        
        if(!lstOfIssue.isEmpty()){
            
            for(pse__Issue__c issueRec : lstOfIssue){
                if(!attachedIssueIds.isEmpty() && attachedIssueIds.contains(issueRec.Id)){
                    issueAndRiskData.lstOfAttachedIssues.add(issueRec);
                }else{
                    issueAndRiskData.lstOfUnattchedIssues.add(issueRec);
                }
            }
        }
        system.debug('value of issueAndRiskData '+issueAndRiskData); 
        return issueAndRiskData;
    } 
    
    @AuraEnabled
    public static boolean attachIssuesAndRisks(String srRecordId, List<pse__Risk__c> selectedRisks,List<pse__Issue__c> selectedIssues){
        
        boolean success;
        List<Status_Report_Detail__c> statsDetailLst = new List<Status_Report_Detail__c>();        
        Set<Id> issueIds = new Set<Id>();
        if(!selectedIssues.isEmpty()){
            issueIds.addAll(new Map<Id,pse__Issue__c>(selectedIssues).keySet());
            for(pse__Issue__c issueRec : selectedIssues){
                Status_Report_Detail__c newStatsDetail = new Status_Report_Detail__c();
                newStatsDetail.PSA_Status_Report__c=srRecordId;
                newStatsDetail.PSA_Issue__c=issueRec.Id;
                statsDetailLst.add(newStatsDetail);
            }
        }
        if(!selectedRisks.isEmpty()){
            for(pse__Risk__c riskRec : selectedRisks){
                Status_Report_Detail__c newStatsDetail = new Status_Report_Detail__c();
                newStatsDetail.PSA_Status_Report__c=srRecordId;
                newStatsDetail.PSA_Risk__c=riskRec.Id;
                statsDetailLst.add(newStatsDetail);
            }
        }
        if(!statsDetailLst.isEmpty()){
            success = inserStatsRepDetail(statsDetailLst); 
        }
        return success;
    }
    
    @AuraEnabled
    public static boolean removeIssuesAndRisks(String srRecordId, List<pse__Risk__c> selectedRisks,List<pse__Issue__c> selectedIssues){
        
        boolean success;
        List<Status_Report_Detail__c> statsDetailLst = new List<Status_Report_Detail__c>();        
        Map<Id,pse__Issue__c> selectedIssuesMap = new Map<Id,pse__Issue__c>(selectedIssues);
        Map<Id,pse__Risk__c> selectedRisksMap = new Map<Id,pse__Risk__c>(selectedRisks);
        List<Status_Report_Detail__c> statsDetailRec = [Select Id,PSA_Risk__c, PSA_Issue__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c from Status_Report_Detail__c  where PSA_Status_Report__c=:srRecordId];
        
        for(Status_Report_Detail__c statRec : statsDetailRec){
            
            if(selectedIssuesMap.containsKey(statRec.PSA_Issue__c)){
                statsDetailLst.add(statRec);
                
            }
            if(selectedRisksMap.containsKey(statRec.PSA_Risk__c)){
                statsDetailLst.add(statRec);
                
            }
        }
        
        if(!statsDetailLst.isEmpty()){
            success = deleteStatsRepDetail(statsDetailLst); 
        }
        return success;
    }
    
    /* Project timecards variables*/
    public  class TimecardWrapper { 
        @AuraEnabled
        public String resource { get; set; } 
        @AuraEnabled
        public String role { get; set; } 
        @AuraEnabled
        public String totalHours { get; set; }
        @AuraEnabled
        public String Id { get; set; } 
        @AuraEnabled
        public Date startDate { get; set; } 
        @AuraEnabled
        public Date endDate { get; set; } 
        @AuraEnabled
        public boolean isBillable { get; set; } 
    }
    /* Project timecards variables*/
    public  class TimecardWrapperList { 
        @AuraEnabled
        public List<TimecardWrapper> attachedTimecards { get; set; } 
        @AuraEnabled
        public List<TimecardWrapper> unAttachedTimecards { get; set; } 
        
    }
    
    
    
    @AuraEnabled
    public static TimecardWrapperList getTimecards(String srRecordId){
        
        TimeCardWrapperList allTimecardData = new TimeCardWrapperList();
        List<TimecardWrapper> attachedTimecards = new List<TimecardWrapper>();
        List<TimecardWrapper> unAttachedTimecards = new List<TimecardWrapper>();
        
        Status_Report__c statsReportRec = [Select Id,PSA_PM_Status_Report_Week__c,PSA_PM_List_of_Issues_Id__c,PSA_PM_List_of_Risks_Id__c,PSA_PM_Project__c from Status_Report__c where Id=:srRecordId];
        
        List<Status_Report_Detail__c> statsDetailRec = [Select Id,PSA_Timecard__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c from Status_Report_Detail__c  where PSA_Status_Report__c=:srRecordId and PSA_Timecard__c!=null];
        Set<Id> attachedTimecardIds = new Set<Id>();
        for(Status_Report_Detail__c statRec : statsDetailRec){
            attachedTimecardIds.add(statRec.PSA_Timecard__c); 
        }
        //<T2>
        DateTime dt = (DateTime)statsReportRec.PSA_PM_Status_Report_Week__c;
        /* Get the current weekday */ 
        Integer day = Integer.valueOf(dt.formatGMT('u'))+7;
        /* If Status Report Week is Sunday then get the previous Sunday date */
        if(day == 14){
            day = 7;
        }
        /* Get the previous week sunday date */
        Date timecardStartDate =  Date.valueof(statsReportRec.PSA_PM_Status_Report_Week__c.addDays(-day));//</T2> 
        //Date timecardStartDate = statsReportRec.PSA_PM_Status_Report_Week__c.addDays(-8);
        Date timecardEndDate = Date.valueof(timecardStartDate.addDays(6));
        List<pse__Timecard_Header__c> lstOfTimecards = new List<pse__Timecard_Header__c>();
        lstOfTimecards =  [Select Id,PSA_TM_Resource_Role__c,pse__Assignment__r.pse__Is_Billable__c, pse__Assignment__r.pse__Start_Date__c, pse__Assignment__r.pse__End_Date__c, pse__Resource__r.name, PSA_TM_Resource_Role_Override__c,
                           pse__Total_Hours__c,pse__Start_Date__c, pse__Status__c, pse__End_Date__c,pse__Project__c, pse__Project__r.Name 
                           from pse__Timecard_Header__c where  pse__Project__c =:statsReportRec.PSA_PM_Project__c
                           and pse__Start_Date__c =:timecardStartDate and pse__End_Date__c=:timecardEndDate];
        
        for(pse__Timecard_Header__c timecardRec : lstOfTimecards){
            TimecardWrapper timecardWrapper = new TimecardWrapper();
            timecardWrapper.resource = timecardRec.pse__Resource__r.name;
            timecardWrapper.role = timecardRec.PSA_TM_Resource_Role__c;
            timecardWrapper.totalHours = String.valueOf(timecardRec.pse__Total_Hours__c);
            timecardWrapper.Id = timecardRec.Id;
            timecardWrapper.startDate = timecardRec.pse__Assignment__r.pse__Start_Date__c;
            timecardWrapper.endDate = timecardRec.pse__Assignment__r.pse__End_Date__c;
            timecardWrapper.isBillable = timecardRec.pse__Assignment__r.pse__Is_Billable__c;
            if(attachedTimecardIds.contains(timecardRec.Id)){
                attachedTimeCards.add(timecardWrapper); 
            }else{
                unAttachedTimecards.add(timecardWrapper);
            }
            
        }   
        allTimecardData.attachedTimeCards = attachedTimeCards;
        allTimecardData.unAttachedTimecards = unAttachedTimecards;
        
        return allTimecardData; 
    }
    @AuraEnabled
    public static boolean attachTimecards(String srRecordId,List<TimecardWrapper> selectedTimecards){
        boolean success;
        Set<Id> timecardIds = new Set<Id>();
        system.debug('selectedTimecards'+selectedTimecards);
        for(TimecardWrapper timecardRec : selectedTimecards){
            timecardIds.add(timecardRec.Id);
        }
        List<Status_Report_Detail__c> statsDetailLst  = new List<Status_Report_Detail__c>();
        for(Id timecardId : timecardIds){
            Status_Report_Detail__c newStatsDetail = new Status_Report_Detail__c();
            newStatsDetail.PSA_Status_Report__c=srRecordId;
            newStatsDetail.PSA_Timecard__c=timecardId;
            statsDetailLst.add(newStatsDetail);
        }
        if(!statsDetailLst.isEmpty()){
            success = inserStatsRepDetail(statsDetailLst); 
        }
        return success;
    }
    @AuraEnabled
    public static boolean removeTimecards(String srRecordId,List<TimecardWrapper> selectedTimecards){
        boolean success;
        system.debug('selectedTimecards'+selectedTimecards);
        Set<Id> timecardIds = new Set<Id>();
        for(TimecardWrapper timecardRec : selectedTimecards){
            timecardIds.add(timecardRec.Id);
        }
        system.debug('timecardIds'+timecardIds);
        List<Status_Report_Detail__c> statsDetailLst = [Select Id,PSA_Timecard__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c from Status_Report_Detail__c  
                                                        where PSA_Status_Report__c=:srRecordId and PSA_Timecard__c IN:timecardIds];
        
        system.debug('statsDetailLst'+statsDetailLst);
        if(!statsDetailLst.isEmpty()){
            success = deleteStatsRepDetail(statsDetailLst); 
        }
        return success;
    }
    public static boolean inserStatsRepDetail(List<Status_Report_Detail__c> statsDetailLst){
        boolean success;
        try{
            insert statsDetailLst; 
            success = true; 
        }catch(exception ex){
            success = false;
        }
        return success;
    }
    public static boolean deleteStatsRepDetail(List<Status_Report_Detail__c> statsDetailLst){
        boolean success;
        try{
            delete statsDetailLst; 
            success = true; 
        }catch(exception ex){
            success = false;
        }
        return success;
    }
    
}