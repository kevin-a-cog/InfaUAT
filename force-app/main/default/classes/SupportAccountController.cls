/*
@created by       : balajip
@created on       : 01/02/2020
@Purpose          : Controller class for Support Account Lightning components
@Testclass        : 
@JIRA             : 

Change History
*****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
*****************************************************************************************************
Vignesh D      24/9/2021   I2RT-4611   T01     Execute AccountContactRelation related operations 
performed on eSupport Support Account page in 
"Without Sharing" context
Vignesh D      05/11/2021  UTOPIA-FF1  T02     Create new contact only when there is no existing
lead for the email
Amarender      29/11/2021  I2RT-4793   T03     SOQL Query update - Open JIRA's that belongs to FR, EBF,CR of a Support Account.   
Vignesh D      08/12/2021  I2RT-5134   T04     Duplicate contact check                                           
balajip        16/12/2021  I2RT-5014   T05     updated the Case Comment creation logic on associating a Case to an Engagement
Sandeep Duggi   03/10/22    I2RT-5368   T06
Vignesh D      24/05/2022  I2RT-6149   T07     Added method to query latest approved certification
request under the support account
Vignesh D      6/6/2022    I2RT-6149   T08     Added invocable method to rollup certification request
onto support account from flow.
Amit GArg      21/06/2022  I2RT-5996   T09     eSupport - Reduce Timezone selection list to avoid incorrect selections
Amit GArg      21/07/2022  I2RT-6766   T10     eSupport - Location and Region field to be sorted alphabetically
Amit GArg      21/07/2022  I2RT-6736   T11     Admin: Primary Contact not able to create new contact who is already part of another customer account
Amit GArg      24/08/2022  I2RT-6103   T12     Admin: eSupport - Informatica Account Field Sales Rep displaying incorrectly
Amit GArg      28/08/2022  I2RT-6870   T13     PayGo: eSupport - My eComm Account(s) & eComAccount (Org ID) details page
Vignesh D      16/05/2023  I2RT-7832   T14     Update error message to check
Isha B         15/05/2023  I2RT-8339   T15     Added fields in the return statement of  assignContactsToSupportAccount method 
Vignesh D      7/21/2023   I2RT-8640   T16     Commented the code to rollup certification request onto 
                                               support account.
Vignesh D      7/21/2023   I2RT-8640   T17     Updated logic to query the latest active certification request from all 
                                               segmentation types 
Isha B         26/09/2023  I2RT-9075   T18     eSupport Change Request section 
Isha B         12/10/2023  I2RT-9075   T19     Handle Idea linked to multiple accounts  
Isha B         24/10/2023  I2RT-9399   T20     Sort CRs by created date

*/
public with sharing class SupportAccountController {
    
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}
    
    public static globalApexManager GAM = new globalApexManager(); //<T08>
    
    public SupportAccountController() {
        
    }
    //<T09> starts
    @AuraEnabled(Cacheable=true)
    public static list<timezoneDetails> getPicklistValuesforRegionAndLocation(){
        list<timezoneDetails> timeZones = new list<timezoneDetails>();
        map<string, list<locAndTimezone >> RegionToLocationMap = new map<string, list<locAndTimezone >>();
        for(timezone__c tz:[select id, location__c, Region__c,timezone__c  from timezone__c where location__c != null order by region__c,location__c]){//<T10>
            locAndTimezone lc = new locAndTimezone();
            lc.loc = tz.location__c;
            lc.Tz = tz.timezone__c;
            if(!RegionToLocationMap.containsKey(tz.Region__c)){
                
                RegionToLocationMap.put(tz.Region__c, new list<locAndTimezone >{lc});
            }else{
                RegionToLocationMap.get(tz.Region__c).add(lc);
            }
        }
        for(string st:RegionToLocationMap.keyset()){
            timezoneDetails tz = new timezoneDetails();
            tz.Region = st;
            tz.location = RegionToLocationMap.get(st);
            timeZones.add(tz);
        }
        return timeZones;
    }
    public class timezoneDetails{
        @AuraEnabled
        public string Region{get; set;}
        @AuraEnabled
        public list<locAndTimezone> location{get; set;}
    }
    public class locAndTimezone{
        @AuraEnabled
        public string Loc{get; set;}
        @AuraEnabled
        public string TZ{get; set;}
    }
    
    //<T09> ends
    
    public class AccountDetail{
        @AuraEnabled
        public Account acc{get; set;}
        @AuraEnabled
        public String accOwnerName{get;set;}
        @AuraEnabled
        public List<AccountContactRelation> contacts{get; set;}
        @AuraEnabled
        public List<zsfjira__ZIssue__c> jiraIssues{get; set;}
        @AuraEnabled
        public List<ContentDocument> projectDocuments{get; set;}
        @AuraEnabled
        public User loggedUser{get; set;}
        @AuraEnabled
        public Boolean isEcomAcc{get; set;} //<T13>
        @AuraEnabled
        public Org__c orgDetails{get; set;} //<T13>
    }
    
    //---------------------------------------<T07>-----------------------------
    
    /* Wrapper class to store certification request along with approval history */
    public class CertificationRequestWrapper{
        @AuraEnabled
        public Certification_Request__c objCertificationRequest {get; set;}
        @AuraEnabled
        public ProcessInstance objProcessInstance {get; set;}
    }
    
    //---------------------------------------</T07>-----------------------------
    
    //Amarender -> I2RT-636: eSupport: Support Account Details Page - Start
    @AuraEnabled
    public static AccountDetail getSupportAccount(String accountId){
        try 
        {
            AccountDetail accDetail = new AccountDetail();
            accDetail.isEcomAcc = false;
            List<AccountContactRelation> acrList = new list<AccountContactRelation>();
            system.debug('@@--accountId--->>'+accountId);
            User userDetail = [Select Id,ContactId From User where Id = :UserInfo.getUserId() Limit 1];
            List<Account> accts = CaseControllerWithoutSharing.getEcommerceAccountInfo(accountId);
            system.debug('accts -------- '+accts);
            //<T13> starts
            if(accts.isEmpty()){
                accts = [Select Id, Name, New_Org_Account_Number__c,Support_Account_Status__c,End_Date__c, Entitlement__r.EndDate, Entitlement__r.Status,Success_Offering__c,Support_Account_Type__c, TimeZone__r.Name,Max_Customer_R_W_Contacts__c,Active_Customer_R_W_Contacts__c,Description,Owner.FirstName,Owner.LastName,ParentId, RecordType.DeveloperName
                         From Account 
                         Where Id = :accountId And Support_Account_Status__c = 'Active'  and RecordType.DeveloperName = 'Support_Account' and ParentId != null];
            }
            if(accts[0].RecordType.DeveloperName == 'eCommerce'){
                accDetail.isEcomAcc = true;
                accDetail.orgDetails = CaseControllerWithoutSharing.getOrgId(accountId);
                if( !SupportLiteSharing.validateUserAccess('Account','READ', accDetail.orgDetails.orgId__c)){
                    throw new CustomException('Insufficient access to view account');
                }
                acrList = CaseControllerWithoutSharing.getEcommerceAccountContacts((Id) accountId);
            }else{
                acrList = CaseControllerWithoutSharing.getSupportAccountContacts((Id) accountId);
                //<T03>
                List<zsfjira__ZIssue_Case__c> jiraCaseIssues = CaseControllerWithoutSharing.getSupportAccountJiras((Id) accountId);
                //</T03>
                List<ContentDocumentLink> accountDocumentLinks = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId = :accountId ];
                System.debug(' accountDocumentLinks :: '+ accountDocumentLinks.size());
                List<Id> cdIds = new List<Id>();
                for(ContentDocumentLink cdl : accountDocumentLinks){
                    cdIds.add(cdl.ContentDocumentId);
                }
                
                List<Contact> contacts =  new List<Contact>();
                List<zsfjira__ZIssue__c> jiraList = new List<zsfjira__ZIssue__c>();
                List<ContentDocument> projectDocs = [SELECT Id, Title,Description,FileType,LastModifiedDate,CreatedBy.FirstName,CreatedBy.LastName FROM ContentDocument WHERE Id in :cdIds];
                System.debug(' projectDocs :: '+ projectDocs.size());
                accDetail.projectDocuments = projectDocs;       //Amarender - Changes made as part of I2RT-2940
                
                for(zsfjira__ZIssue_Case__c caseIssue: jiraCaseIssues){
                    zsfjira__ZIssue__c jira = new zsfjira__ZIssue__c();
                    jira.zsfjira__IssueKey__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__IssueKey__c;
                    jira.zsfjira__Summary__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__Summary__c;
                    jira.zsfjira__IssueType__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__IssueType__c;
                    jira.zsfjira__Project__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__Project__c;
                    jira.zsfjira__Status__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__Status__c;
                    jira.zsfjira__AffectsVersions__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__AffectsVersions__c;
                    jira.zsfjira__FixVersions__c  = caseIssue.zsfjira__ZIssueId__r.zsfjira__FixVersions__c;
                    jira.zsfjira__Created__c  = caseIssue.zsfjira__ZIssueId__r.zsfjira__Created__c;
                    jira.zsfjira__DueDate__c = caseIssue.zsfjira__ZIssueId__r.zsfjira__DueDate__c;
                    jiraList.add(jira);
                }
                accDetail.jiraIssues = jiraList;
                //<T12> starts
                String salesRepName = '';
                if(accts[0].parentId != null){
                   salesRepName = CaseControllerWithoutSharing.getAccountManagerName(accts[0].parentId);
                }
                //<T12> ends 
                accDetail.accOwnerName = salesRepName;           //Amarender - Changes made as part of I2RT-2946
            }
                       
            accDetail.acc = accts[0];
            accDetail.contacts = acrList;         
            accDetail.loggedUser = userDetail;
            system.debug(accDetail);
            return accDetail;
        } catch (Exception e) {
            //Amarender - Made changes as part of I2RT-2947
            new globalApexManager().CreateLogs('SupportAccountController - getSupportAccount',e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Amarender -> I2RT-636: eSupport: Support Account Details Page - End
    
    //To get all unassigned contacts under the customer account.
    @AuraEnabled
    public static List<Contact> getUnassignedContacts(String accountId, String supportAcc){
        
        if(String.isNotBlank(accountId) && String.isNotBlank(supportAcc)){
            String SOQL;
            List<Contact> contacts = new List<Contact>();
            List<Id> contactIds = new List<Id>();
            List<Id> requiredIds = new List<Id>();
            for(AccountContactRelation acr : [Select ContactId from AccountContactRelation where AccountId =: supportAcc]){
                contactIds.add(acr.ContactId);
            }
            // start of t06 
            // SOQL = 'Select Id,Name,Is_Primary__c,AccountId,Account.Name,Phone,Email from Contact where Id NOT IN (Select ContactId from AccountContactRelation where AccountId =: supportAcc) And AccountId =: accountId And Is_Active__c = true order by Name ASC ';
            for(AccountContactRelation rIDs : [Select Id,contact.Name,contact.Is_Primary__c,AccountId,Account.Name,contact.Phone,contact.Email from AccountContactRelation where contactid NOT IN :contactIds And AccountId =: accountId And IsActive = true order by contact.Name ASC ]){
                requiredIds.add(rIDs.ContactId);
            }
            SOQL = 'Select Id,Name,Is_Primary__c,AccountId,Account.Name,Phone,Email from Contact where Id IN :requiredIds order by Name ASC ';
            system.debug('SOQL querty =>'+ SOQL);
            // end of T06
            contacts = Database.query(SOQL);
            return contacts;
        }
        else{ 
            return null;
        }
    }
    
    @AuraEnabled
    public static AccountContactRelation createContact(String firstName,String lastName,String email,String phone,String language,String Region,String Location,String primary,String privilege,String accountId){
        try {
            if(!CaseControllerWithoutSharing.isPrimaryContact((Id) accountId)){
                throw new CustomException('INSUFFICIENT ACCESS TO CREATE CONTACT');
            }
            //<T02>
            if(CaseControllerWithoutSharing.CheckIFACRExists(email,accountId)){//<T11>
                throw new CustomException('Contact already exist in the System');
            }
            if(CaseControllerWithoutSharing.isContactUnderDifferentAccountExists(email,accountId)){//<T11>
                throw new CustomException(System.label.ErrorMessageForSupportAccount);//<T11>
            }
            if(CaseControllerWithoutSharing.isContactExists(email)){
                throw new CustomException('Contact already exist in the System');
            }
            if(CaseControllerWithoutSharing.isLeadExists(email)){
                throw new CustomException(System.label.Potential_Duplicate_Lead_Validation_Message);//<T11>
            }
            timezone__c tz = [select id,Timezone__c from timezone__c where region__c =: region and location__c =:location limit 1];//<T09>
            List<Account> lstAccCountry = new List<Account>();
            lstAccCountry = CaseControllerWithoutSharing.getSupportAccount((Id) accountId);
            Boolean isExternalUser = [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;
            Contact con = new Contact();
            con.FirstName = firstName;
            con.LastName = lastName;
            con.Email = email;
            con.Phone = phone;
            con.INFA_Language__c = language;
            con.Timezone__c = tz.Timezone__c;//<T09>
            con.Access_Level__c = privilege;
            con.AccountId = lstAccCountry[0].ParentId;
            con.MailingCountry = lstAccCountry[0].BillingCountry;
            if(isExternalUser){ //Fix for standard error "portal users cannot own partner accounts" when enforcing sharing on class. Default owner of the contact will be set to Support Account's Parent Account's Owner
                con.OwnerId = lstAccCountry[0].Parent.OwnerId;
            }
            CaseControllerWithoutSharing.createContact(con); //</T01>
            AccountContactRelation acr = new AccountContactRelation();
            acr.Phone__c = phone;
            acr.Language__c = language;
            acr.ContactId = con.Id;
            acr.Timezone__c = tz.Timezone__c ;//<T09>
            acr.Access_Level__c = privilege;
            acr.AccountId = accountId;
            acr.Primary__c = Boolean.valueOf(primary);
            
            system.debug('--acr--'+acr);
            AccountContactRelation acrRecord =caseControllerWithoutSharing.createACR(acr);//<T09>
            return acrRecord;
            
            
            
        } catch (Exception e) {
            system.debug(e.getStackTraceString());
            String message =e.getMessage();//<T11>
            system.debug(message);
            //Amarender - Made changes as part of I2RT-2947
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Please enter Firstname')){
                message = 'Please Enter First Name';
            }
            if(e.getMessage().contains('REQUIRED_FIELD_MISSING, Required fields are missing: [Last Name]')){
                message = 'Please Enter Last Name';
            }
            
            //Amarender - Made changes as part of I2RT-2947
            message = message != '' ? message : 'Please Contact your System Administrator';
            if(!Test.isRunningTest())throw new AuraHandledException(message);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<SObject> updateContactRelation(String firstName, String lastName, String contactId,String nameChanged,String phone,String language,String Region, string Location,String privilege,string primary,string acrId,string acrChanged, String accountId){
        try {
            system.debug('@@--region -->>'+Region);
            system.debug('@@--location -->>'+Location);
            //<T09>
            timezone__c tz = [select id,Timezone__c from timezone__c where region__c =: region and location__c =:location limit 1];
            system.debug('@@--tz-->>'+tz);
            string timezone = tz.timeZone__c;
            system.debug('@@--timezone -->>'+timezone );
            //<T09>
            return  CaseControllerWithoutSharing.updateAccountContactRelation(firstName, lastName, contactId, nameChanged, phone, language, timezone, privilege, primary, acrId, acrChanged, accountId);//</T01>
        } catch (Exception e) {
            system.debug('@@@--->>>'+e.getMessage());
            String message ='';
            //Amarender - Made changes as part of I2RT-2947
            new globalApexManager().CreateLogs('SupportAccountController - updateContactRelation',e.getMessage());
            
            if(e.getMessage().contains('Primary Contact should be Read/Write')){
                message = 'Primary Contact should have Read/Write Privilege';
            }
            if(e.getMessage().contains('Max Read/Write contacts limit reached')){
                message = 'Support Account already have Maximum Read/Write Contacts available';
            }
            if(e.getMessage().contains('Max Two Primary Contacts are allowed')){ //<T14>
                message = 'Support Account already have Maximum 2 Primary Contacts available';
            }
            //Amarender - Made changes as part of I2RT-2947
            message = message != '' ? message : 'Please Contact your System Administrator';
            throw new AuraHandledException(message);
        }
    }
    
    @AuraEnabled
    public static List<AccountContactRelation> assignContactsToSupportAccount(String supportAccount, List<string> contacts){
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        try{
            for(string conId: contacts){
                AccountContactRelation acr = new AccountContactRelation();
                acr.ContactId = conId;
                acr.AccountId = supportAccount;
                acrList.add(acr);
            }
            upsert acrList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return [Select Id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email,Contact.INFA_Language__c,Contact.Timezone__c,Contact.Phone,Phone__c,Access_Level__c,Timezone__c,Language__c,Primary__c from AccountContactRelation where Id in :acrList]; // T15 I2RT-8339 added fields
    }
    
    @AuraEnabled
    public static List<Account> getAccounts(String customerAccountId){
        return [Select Id, Name, AccountNumber, New_Org_Account_Number__c, Support_Account_Status__c, OwnerId, Owner.Name, (SELECT CaseNumber FROM Cases), (SELECT CaseNumber FROM Cases__r)   
                From Account 
                Where ParentId = :customerAccountId And Support_Account_Status__c = 'Active' And RecordType.DeveloperName = 'Support_Account'];
    }
    
    @AuraEnabled
    public static List<Engagement__c> getEngagements(String supportAccountId){
        Id recordTypeId = EngagementService.getRecordTypeId(EngagementService.RECORD_TYPE_NAME_SUPPORT_ESCALATION);
        return [Select Id, Name, Engagement_Number__c, Title__c, Priority__c, Severity__c, Source__c, 
                Category__c, Status__c, OwnerId, Owner.Name, RecordType.Name, Plan__c, Plan__r.Name
                From Engagement__c 
                Where Support_Account__c = :supportAccountId And Status__c != 'Closed' And RecordTypeId = :recordTypeId];
    }
    
    @AuraEnabled
    public static List<Case> getCasesNotEscalated(String supportAccountId){
        return [Select Id, Subject, CaseNumber, Case_Number__c, Status, Engagement__c, Engagement__r.Title__c, Engagement__r.Engagement_Number__c, OwnerId, Owner.Name, 
                Priority, Forecast_Product__c, Version__c, CreatedDate, ClosedDate, IsClosed,
                Closing_Notes__c, Escalation_Notes__c, RecordType.Name, IsEscalated, Engagement__r.Plan__c, Engagement__r.Plan__r.Name
                From Case
                Where Support_Account__c = :supportAccountId And IsClosed=false And Engagement__c = null];
    }
    
    @AuraEnabled
    public static List<Case> getCasesEscalated(String supportAccountId){
        return [Select Id, Subject, CaseNumber, Case_Number__c, Status, Engagement__c, Engagement__r.Title__c, Engagement__r.Engagement_Number__c, OwnerId, Owner.Name, 
                Priority, Forecast_Product__c, Version__c, CreatedDate, ClosedDate, IsClosed,
                Closing_Notes__c, Escalation_Notes__c, RecordType.Name, IsEscalated, Engagement__r.Plan__c, Engagement__r.Plan__r.Name
                From Case
                Where Support_Account__c = :supportAccountId And IsClosed=false And Engagement__c != null];
    }
    
    @AuraEnabled
    public static List<Case> getCasesOpen(String supportAccountId){
        return [Select Id, Subject, CaseNumber, Case_Number__c, Status, Engagement__c, Engagement__r.Title__c, Engagement__r.Engagement_Number__c, OwnerId, Owner.Name, 
                Priority, Forecast_Product__c, Version__c, CreatedDate, ClosedDate, IsClosed,
                Closing_Notes__c, Escalation_Notes__c, RecordType.Name, IsEscalated
                From Case 
                Where Support_Account__c = :supportAccountId And IsClosed=false];
    }
    
    @AuraEnabled
    public static List<Case> getCases(String supportAccountId){
        return [Select Id, Subject, CaseNumber, Case_Number__c, Status, Engagement__c, Engagement__r.Title__c, Engagement__r.Engagement_Number__c, OwnerId, Owner.Name, 
                Priority, Forecast_Product__c, Version__c, CreatedDate, ClosedDate, IsClosed,
                Closing_Notes__c, Escalation_Notes__c, RecordType.Name, IsEscalated
                From Case 
                Where Support_Account__c = :supportAccountId];
    }
    
    @AuraEnabled
    public static String createEngagement(String supportAccountId, String engTitle, String priority, String severity, String source, String category, String detail,String contact,String caseIds, String reason,String sobjectRecordId){
        Id strCleanRecordId;
        String engId = '';
        System.debug('caseIds - ' + caseIds);
        Type typeListString = Type.forName('List<String>');
        List<String> lstCaseId = (List<String>)JSON.deserialize(caseIds, typeListString);
        System.debug('lstCaseId - ' + lstCaseId);
        
        Engagement__c engagement = EngagementService.createSupportEscalation(supportAccountId, engTitle, priority, severity, source, category,detail,contact);
        //Deva: Added to associate plan record to engagement
        if(String.isNotBlank(sobjectRecordId)){
            strCleanRecordId = Id.valueOf(String.escapeSingleQuotes(sobjectRecordId));
            if(strCleanRecordId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Plan__c')){
                engagement.Plan__c = Id.valueOf(strCleanRecordId);
            } 
            if(strCleanRecordId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Milestone__c')){
                //engagement.Milestone__c=Id.valueOf(strCleanRecordId);
                //List<Milestone__c> milestoneList = new List<Milestone__c>([SELECT Id,Objective__c,Objective__r.Plan__c FROM Milestone__c WHERE Id=:strCleanRecordId]);
                //if(milestoneList.size()>0 && milestoneList[0].Objective__c != null && milestoneList[0].Objective__r.Plan__c!=null){
                //    engagement.Plan__c = milestoneList[0].Objective__r.Plan__c ; 
                //}
            }           
        }
        insert engagement;
        RaiseHandService.raiseEscalation(engagement.Id);
        
        associateCasesToEngagement(engagement.Id, caseIds, reason);
        if(engagement.Id != null){
            engId = engagement.Id;
        }
        return engId;
    }
    
    @AuraEnabled
    public static void associateCasesToEngagement(String engagementId, String caseIds, String reason){
        associateCasesToEngagement(engagementId, caseIds, reason, null, null);
    }
    
    @AuraEnabled
    public static void associateCasesToEngagement(String engagementId, String caseIds, String reason, String strPlanId, Boolean boolIsSuccessApp) {
        Id idPlan;
        Engagement__c objEngagement = new Engagement__c();
        System.debug('caseIds - ' + caseIds);
        Type typeListString = Type.forName('List<String>');
        List<String> lstCaseId = (List<String>)JSON.deserialize(caseIds, typeListString);
        System.debug('lstCaseId - ' + lstCaseId);
        
        List<Case_Comment__c> lstCaseComment = new List<Case_Comment__c>();
        List<Case> lstCaseToUpdate = new List<Case>();
        for(String caseId : lstCaseId){
            Case cse = new Case();
            cse.Id = caseId;
            cse.IsEscalated = true;
            cse.Engagement__c = engagementId;
            lstCaseToUpdate.add(cse);
            
            //create a Case Comment 
            if(String.isNotEmpty(reason)){
                //T05
                //Case_Comment__c caseComment = CaseCommentService.createEscalationComment(cse.Id, reason, '');
                Case_Comment__c caseComment = new Case_Comment__c();
                caseComment.Case__c = cse.Id;
                caseComment.Inbound__c = false;               
                caseComment.Status__c = CaseCommentService.STATUS_SUBMITTED;    
                caseComment.Visibility__c = CaseCommentService.VISIBILITY_INTERNAL;  
                caseComment.Comment__c = 'Escalation - ' + reason;
                caseComment.Created_By__c = UserInfo.getName(); //Deva check this
                system.debug('caseComment ---- '+caseComment);
                lstCaseComment.add(caseComment);    
            }
        }
        
        if(!lstCaseToUpdate.isEmpty()){
            update lstCaseToUpdate;
        }
        
        if(!lstCaseComment.isEmpty()){
            insert lstCaseComment;
        }
        
        //Now we update the Engagement, if needed.
        if(String.isNotBlank(strPlanId) && String.isNotBlank(engagementId)) {
            idPlan = strPlanId;
            if(idPlan.getSObjectType() == Schema.Plan__c.getSObjectType()) {
                objEngagement.Id = engagementId;
                objEngagement.Plan__c = strPlanId;
                update objEngagement;
            }
        }
    }
    
    //Amarender - UAT Issues - Start
    //Documents Add/Update on Support Account Details Page
    @AuraEnabled
    public static List<ContentDocumentLink> updateDocVersion(String docToDelete, String docToUpdate, String docDescription, String accountId){
        try {
            List<ContentDocumentLink> documentsToShow =  new List<ContentDocumentLink>();
            if(!string.isEmpty(docToDelete)){
                Delete [Select Id FROM ContentDocument WHERE Id=: docToDelete];
            }
            if(!String.isEmpty(docToUpdate)){
                ContentDocument document = [SELECT Id, Description FROM ContentDocument WHERE Id=: docToUpdate];
                document.Description = docDescription;
                Update document;
            }
            
            documentsToShow = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.LastmodifiedDate, ContentDocument.CreatedBy.Name,ContentDocument.CreatedBy.FirstName,ContentDocument.CreatedBy.LastName, ContentDocument.FileType from ContentDocumentLink Where LinkedEntityId =: accountId order by ContentDocument.LastModifiedDate asc];
            return documentsToShow;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> removeFile(String documentId,String accountId){
        try {
            List<ContentDocument> contentDocuments = new List<ContentDocument>();
            List<contentDocumentLink> documentLinks = new List<contentDocumentLink>();
            
            contentDocuments = [SELECT Id FROM  ContentDocument WHERE Id=: documentId];
            if(!contentDocuments.isEmpty()){
                delete contentDocuments;
            }
            return getUploadedFiles(accountId,documentId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> getUploadedFiles(String accountId,String documentId){
        try {
            List<ContentDocumentLink> documentsToShow =  new List<ContentDocumentLink>();
            documentsToShow = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.LastmodifiedDate, ContentDocument.CreatedBy.Name,ContentDocument.CreatedBy.FirstName,ContentDocument.CreatedBy.LastName, ContentDocument.FileType from ContentDocumentLink Where LinkedEntityId =: accountId order by ContentDocument.LastModifiedDate asc];
            return documentsToShow;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Delete Support Account contact
    @AuraEnabled
    public static string removeContacts(Id accContact){
        String returnMessage;
        
        if(accContact != null){            
            try{
                //List<Id> conids = (List<Id>)JSON.deserialize(casecon, List<Id>.class);               
                returnMessage = CaseControllerWithoutSharing.deleteAccountContactRelation(accContact);//</T01>
                //returnMessage = 'SUCCESS';
            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }
        
        return returnMessage;
    }
    
    /*
Method Name : isSuccessApp
Description : This method determines if the current app is the Success app.
Parameters  : None
Return Type : Boolean
*/
    @AuraEnabled
    public static Boolean isSuccessApp() {
        Boolean boolResult = false;
        for(UserAppInfo objUserAppInfo : [SELECT AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1]) {
            for(AppDefinition objAppDefinition : [SELECT Id FROM AppDefinition WHERE DurableId = :objUserAppInfo.AppDefinitionId AND Label = 'Success' LIMIT 1]) {
                boolResult = false;
            }
        }
        return boolResult;
    }
    
    //---------------------------------------<T07>-----------------------------
      /*
    Method Name : getCertificationRequest
    Description : This method returns the latest approved certification request under the support account.
    Parameters  : String, called from getCertificationRequest, strSupportAccountId.
    Return Type : Map<String, List<CertificationRequestWrapper>>
    */
    @AuraEnabled
    public static Map<String, List<CertificationRequestWrapper>> getCertificationRequest(String strSupportAccountId){ //<T17>
        Date dtToday = GlobalUtility.getOrganizationDate();
        Map<Id, Certification_Request__c> certificationRequests = new Map<Id, Certification_Request__c>([SELECT Id,
                                                                                                               Request_Type__c,
                                                                                                               Certification_Type__c,
                                                                                                               Business_Justification__c,
                                                                                                               Product__c,
                                                                                                               Start_Date__c,
                                                                                                               End_Date__c,
                                                                                                               Owner__c,
                                                                                                               Owner__r.Name,
                                                                                                               Status__c,
                                                                                                               CreatedDate 
                                                                                                               FROM Certification_Request__c 
                                                                                                               WHERE Support_Account__c = :strSupportAccountId AND
                                                                                                               Status__c = 'Approved' AND
                                                                                                               Start_Date__c <= :dtToday AND
                                                                                                               End_Date__c >= :dtToday
                                                                                                               ORDER BY CreatedDate DESC]); 
        Map<String, Certification_Request__c> certificationRequestMap = new Map<String, Certification_Request__c>();
        Map<String, List<CertificationRequestWrapper>> certificationRequestWrapperMap = new Map<String, List<CertificationRequestWrapper>>();

        //Now query all active certification request
        for(Certification_Request__c objCertificationRequest : certificationRequests.values()){
            if(!certificationRequestMap.containsKey(objCertificationRequest.Request_Type__c) || (certificationRequestMap.containsKey(objCertificationRequest.Request_Type__c) && certificationRequestMap.get(objCertificationRequest.Request_Type__c)?.CreatedDate < objCertificationRequest.CreatedDate)){
                certificationRequestMap.put(objCertificationRequest.Request_Type__c, objCertificationRequest);
            }
        }

        //Now, we query process instance for all certification requests
        for(ProcessInstance objProcessInstance : [SELECT Id,
                                                         Status,
                                                         TargetObjectId,
                                                         (SELECT Id, 
                                                                 StepStatus,
                                                                 ActorId,
                                                                 Actor.Name,
                                                                 Comments,
                                                                 CreatedDate 
                                                                 FROM StepsAndWorkitems 
                                                                 ORDER BY CreatedDate DESC)
                                                         FROM ProcessInstance 
                                                         WHERE TargetObjectId IN :certificationRequests.keySet() 
                                                         ORDER BY CreatedDate DESC LIMIT 1000]){
            Certification_Request__c objCertificationRequest = certificationRequests.get(objProcessInstance.TargetObjectId);
            if((!certificationRequestWrapperMap.containsKey(objCertificationRequest.Request_Type__c) && objCertificationRequest.Request_Type__c == 'Hypercare') || objCertificationRequest.Request_Type__c != 'Hypercare'){
                List<CertificationRequestWrapper> lstCertificationRequestWrapper = certificationRequestWrapperMap.containsKey(objCertificationRequest.Request_Type__c) ? certificationRequestWrapperMap.get(objCertificationRequest.Request_Type__c) : new List<CertificationRequestWrapper>();
                CertificationRequestWrapper wrapper = new CertificationRequestWrapper();
                wrapper.objCertificationRequest = objCertificationRequest;
                wrapper.objProcessInstance = objProcessInstance;
                lstCertificationRequestWrapper.add(wrapper);
                certificationRequestWrapperMap.put(objCertificationRequest.Request_Type__c, lstCertificationRequestWrapper);
            }
        }
        return certificationRequestWrapperMap;
    }
    
    //---------------------------------------</T07>-----------------------------
    
    //---------------------------------------<T08>-----------------------------
    
  /*
    Method Name : rollupCertificationRequest
    Description : This method will rollup certification request details onto support account.
    Parameters  : List<Id>, called from "Remove GCS Segment on Support Account" Flow, lstSupportAccountIds.
    Return Type : none.
    */
    /*@InvocableMethod(label='Rollup Certification Request to Support Account' description='This method will rollup certification request details onto support account')
    public static void rollupCertificationRequest(List<Id> lstSupportAccountIds){
        try{
            if(!lstSupportAccountIds.isEmpty()){
                
                Date dToday = GlobalUtility.getOrganizationDate();
                Set<String> setRequestTypes = new Set<String>();
                Set<Id> setSupportAccountIds = new Set<Id>(lstSupportAccountIds);
                Map<Id, Account> mapSupportAccounts = new Map<Id, Account>();
                
                Schema.DescribeFieldResult objFieldDescribe = Certification_Request__c.Request_Type__c.getDescribe();
                for (Schema.PicklistEntry objPickList : objFieldDescribe.getPickListValues()) {
                    //Add an entry for each request type
                    setRequestTypes.add(objPickList.getValue());
                }
                
                //Now, we query support account with all active approved certification Requests
                for(Account objSupportAccount : [SELECT Id, Certification_Request_Start_Date__c, Certification_Request_End_Date__c, Certification_Request__c, GCS_Segment__c,
                                                 (SELECT Id, Start_Date__c, End_Date__c, Request_Type__c,CreatedDate,Product__c FROM Certification_Requests__r 
                                                  WHERE Status__c = 'Approved' AND ((Start_Date__c <= :dToday AND End_Date__c >= :dToday) OR (Start_Date__c >= :dToday AND End_Date__c >= :dToday))
                                                  ORDER BY Start_Date__c ASC, End_Date__c DESC) 
                                                 FROM Account WHERE Id IN :setSupportAccountIds]){    
                                                     
                                                     Certification_Request__c objActiveCertificationRequest;
                                                     for(Certification_Request__c objCertificationRequest : objSupportAccount.Certification_Requests__r){
                                                         if(objActiveCertificationRequest == null){
                                                             objActiveCertificationRequest = objCertificationRequest;
                                                         }
                                                         else{
                                                             if(objCertificationRequest.Start_Date__c <= dToday && objCertificationRequest.End_Date__c >= dToday && objCertificationRequest.CreatedDate > objActiveCertificationRequest.CreatedDate){
                                                                 objActiveCertificationRequest = objCertificationRequest;
                                                             }
                                                         }
                                                     }
                                                     if(objActiveCertificationRequest != null){
                                                         Account objSupportAccountNew = new Account(Id = objSupportAccount.Id);
                                                         objSupportAccountNew.Certification_Request__c = objActiveCertificationRequest?.Id;
                                                         objSupportAccountNew.Certification_Request_Start_Date__c = objActiveCertificationRequest?.Start_Date__c;
                                                         objSupportAccountNew.Certification_Request_End_Date__c = objActiveCertificationRequest?.End_Date__c;
                                                         objSupportAccountNew.Product__c = objActiveCertificationRequest?.Product__c;
                                                         //Now, we check for inprogress certification request and update GCS Segment
                                                         if((objActiveCertificationRequest.Start_Date__c <= dToday && objActiveCertificationRequest.End_Date__c >= dToday) && objSupportAccount.GCS_Segment__c != objActiveCertificationRequest.Request_Type__c){
                                                             objSupportAccountNew.GCS_Segment__c = objActiveCertificationRequest.Request_Type__c;
                                                         }
                                                         //Now, we check for future certification request and reset the GCS Segment to null
                                                         if((objActiveCertificationRequest.Start_Date__c > dToday && objActiveCertificationRequest.End_Date__c >= dToday) && setRequestTypes.contains(objSupportAccount?.GCS_Segment__c)){
                                                             objSupportAccountNew.GCS_Segment__c = null;
                                                         }
                                                         mapSupportAccounts.put(objSupportAccount.Id, objSupportAccountNew);
                                                     }
                                                 }
                
                //If there is no active approved certification request, reset fields on support account
                for(Id supportAccountId : new List<Id>(setSupportAccountIds)){
                    if(!mapSupportAccounts.containsKey(supportAccountId)){
                        Account objSupportAccount = new Account(Id = supportAccountId);
                        objSupportAccount.GCS_Segment__c = null;
                        objSupportAccount.Certification_Request__c = null;
                        objSupportAccount.Certification_Request_Start_Date__c = null;
                        objSupportAccount.Certification_Request_End_Date__c = null;
                        objSupportAccount.Product__c = null;
                        mapSupportAccounts.put(supportAccountId, objSupportAccount);
                    }
                }
                
                if(!mapSupportAccounts.values().isEmpty()){
                    try{
                        Database.SaveResult[] updateResult = Database.update(mapSupportAccounts.values(), false);             
                    }        
                    catch(DmlException e){
                        GAM.CreateExceptionRecords('SupportAccountController.rollupCertificationRequest', 'Error while updating support accounts: ', e.getMessage());
                    } 
                }
            }
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('SupportAccountController.rollupCertificationRequest', 'Error while rolling up certification request', e.getMessage());
        }
    }*/ //<T16>
    //---------------------------------------</T08>-----------------------------

    /*
    Method Name : eSupportAccountCRDetails
    Description : This method is called from the esSupportAccountDetails LWC on page load 
    Parameters  : Support account Id and authorization token for coveo pipeline.
    Return Type : List<eSupportCRWrapper>.
    */
    @AuraEnabled
        public static List<eSupportCRWrapper> eSupportAccountCRDetails(String accountId, String token){ //<T18>
            List<String> selectedStatus = new List<String>();  
            List<String> supportAccList = new List<String>();
            supportAccList.add(String.valueOf(accountId));
                return getCoveoCRData(supportAccList, token, 'Latest', selectedStatus);

        }
        /*
    Method Name : getCoveoCRData
    Description : This method will make callout to coveo end point to fetch esupport CR information for the filtered support accounts
    Parameters  : List of support accounts, authorization token , sorting direction 
    Return Type : List of eSupportCRWrapper .
    */

        public static List<eSupportCRWrapper> getCoveoCRData(List<String> supportAccList, String token, String sortBy, List<String> selectedStatus) {  //<T18>
            List<eSupportCRWrapper> esupportcrlisttemp = new List<eSupportCRWrapper>();
            
            
            String suppAccString = string.join(supportAccList,'; ');
            
            String authorizationHeader = 'Bearer ' +token;
            help_Infa_Custom_Label__mdt   endptDetail = [SELECT  Endpoint__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='esupportChangeRequest'];
            String endpoint = suppAccString.replace('; ', '%2C%20');
            String sortString = ')&sortCriteria=sfcreateddate%20descending';  //T20          
                if(sortBy == 'Latest'){
                    sortString = ')&sortCriteria=sfcreateddate%20descending'; //T20   
                }
            
            String finalEndpoint = endptDetail.Endpoint__c + endpoint + sortString ;   
            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json', finalEndpoint,
                                                                         '',authorizationHeader,'','','',token); 
            String responseString = dataResponse.getBody(); 
            responseString = responseString.replace('"sfupvote_count__c":', '"sfupvotecount":');        
            responseString = responseString.substringAfter('results" :');  
            responseString = responseString.substring(0,responseString.lastIndexOf('}'));
            responseString = responseString.replace('sfsupport_account_id__c','sfsupportAccountId');
            responseString = responseString.replace('sfbug_enhancement_number__c','sfbugenhancementnumber');
            responseString = responseString.replace('sfissue_type__c','sfissuetype');
            responseString = responseString.replace('sfto_be_fixed_in_version__c','sftobefixedversion');
            
            List<displayWrapper> resultList = (List<displayWrapper>)JSON.deserialize(responseString, List<displayWrapper>.class);
            
            List<rawWrapper> rawList = new List<rawWrapper>();
            if(!resultList.isEmpty() || test.isRunningTest()){               
                for(displayWrapper vwrap : resultList){
                    rawList.add(vwrap.raw);
                }
            }
                     
            for(rawWrapper rwrap : rawList){
                eSupportCRWrapper req = new eSupportCRWrapper();                
                req.Name = rwrap.systitle != null ? rwrap.systitle : '';
                req.Category = rwrap.sfcategories != null ? rwrap.sfcategories : '';                
                req.Link = rwrap.sysprintableuri != null ? rwrap.sysprintableuri : '';              
                if(rwrap.sfsupportAccountId !=null && rwrap.sfsupportAccountId.size()>0){ //T19
                    req.SupportAccountId = rwrap.sfsupportAccountId;
                }        
                req.requestNumber=rwrap.sfbugenhancementnumber !=null ? rwrap.sfbugenhancementnumber : '';  
                req.requestType=rwrap.sfissuetype !=null ? rwrap.sfissuetype : ''; 
                req.productName=rwrap.sfcategories != null ? rwrap.sfcategories : '';  
                if(rwrap.sfcategories != null && rwrap.sfcategories.contains('Change Request') ){
                   
                    req.productName= req.productName.remove(';Change Request') ;
                    req.productName= req.productName.remove('Change Request;') ; 
                    req.productName= req.productName.remove('Change Request') ; 
                }
                req.Status = rwrap.sfstatus != null ? rwrap.sfstatus : '';
                req.tobefixedversion=rwrap.sftobefixedversion !=null ? rwrap.sftobefixedversion : '';                 
                esupportcrlisttemp.add(req);
            }
            
            return esupportcrlisttemp;
        }
        
        public class eSupportCRWrapper{ // <T18> 
            @AuraEnabled public String Id;
            @AuraEnabled public String Name;
            @AuraEnabled public String Status;
            @AuraEnabled public String Category;   
            @AuraEnabled public decimal upvoteCount;
            @AuraEnabled public String Description;
            @AuraEnabled public String Link;
            @AuraEnabled public String CreatorName;
            @AuraEnabled public String createddate;
            @AuraEnabled public List<String> SupportAccountId; //T19
            @AuraEnabled public String SupportAccountName; 
            
            @AuraEnabled public String requestNumber; 
            @AuraEnabled public String requestType; 
            @AuraEnabled public String productName; 
            @AuraEnabled public String tobefixedversion;  
            
        }
        
       
        public class displayWrapper { // <T18> 
            @AuraEnabled public rawWrapper raw;        
        }
        
        public class rawWrapper{ // <T18> 
            @AuraEnabled public String sfid;
            @AuraEnabled public String systitle;
            @AuraEnabled public String sfstatus;
            @AuraEnabled public String sfcategories;
            @AuraEnabled public decimal sfupvotecount;
            @AuraEnabled public String sfbody;
            @AuraEnabled public String sysprintableuri;
            @AuraEnabled public String sfcreatorname;
            @AuraEnabled public String syssfcreateddate;
            @AuraEnabled public List<String> sfsupportAccountId  ;// T19 converting to List 
            @AuraEnabled public String sfbugenhancementnumber  ;
            @AuraEnabled public String sfissuetype  ;
            @AuraEnabled public String sftobefixedversion  ;
        }
      
}