/*
 * Name         :   CaseControllerWithoutSharing
 * Author       :   Vignesh Divakaran
 * Created Date :   17/9/2021
 * Description  :   This class is used to execute SOQL & DML operations for objects in "Without Sharing" context
                    for community users.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.            Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      17/9/2021       I2RT-4527           Initial version.            NA
 Vignesh Divakaran      08/12/2021      I2RT-5134           Contact Duplicate check     T01
 Amarender              13/12/2021      I2RT-4793           SOQL Query update - 
                                                            Open JIRA's that belongs to 
                                                            FR, EBF,CR of a 
                                                            Support Account.            T02     
 Piyush                 15/12/2021      I2RT-5025           move DML logic for Event    T03
                                                            and EventRelation from
                                                            caseTriggerHandler
 Vignesh Divakaran      05/01/2022      I2RT-5218           Create entitled product     T04

 Amit Garg              28/02/2022      I2RT-5361           update the query logic to   T05
                                                            include the bug type JIras

 Sandeep Duggi           03/10/22       I2RT-5368                                        T06
 Vignesh Divakaran      15/03/2022      I2RT Mar build      Checkmarx security fixes    T07
 Amit GArg              30/03/22        I2RT-5361           Check in Jira Issues        T08
 Amit GArg              26/04/22        I2RT-5633           Get the Account related     t09
                                                             cases for reportsController
 balajip                14/06/2022      I2RT-5562           To show the Support Account 
                                                             name in the initial response   T10
 Amit GArg              30/06/22        I2RT-5996           Insert ACR                    T11
 balajip                01/08/2022      I2RT-5562           To separate the Primary Contact names 
                                                                in the Intial Response with a space character   T12
 
 Amit GArg     			30/07/2022  	I2RT-6508     		Customer editing a contact	  T13
															from esupport is not reflecting on contact records
 Amit Garg				05/08/2022		I2RT-6736			contacts under another acc	T14
 Amit Garg				30/08/2022		I2RT-6103			Admin: eSupport - Informatica Account Field Sales Rep displaying incorrectly T15
 balajip                01/09/2022      I2RT-6867           Initial Response update for Case Lite  T16
 Vignesh Divakaran      31/08/2022      I2RT-6865           Added new methods to fetch records T17
                                                            related to Support Lite features
 Amit GArg     			28/08/2022  	I2RT-6870   	    PayGo: eSupport - My eComm Account(s) & eComAccount (Org ID) details page T18
 Sandeep Duggi          09/11/2022      I2RT-6869           PayGo: eSupport - My Lite Cases & Case Details page   T19
 Vignesh Divakaran      29/09/2022      I2RT-6880           Added generic method getSObjectRecords() to query records and getOrgs() to return T20
 															all orgs the community user has access to.
 balajip                09/29/2022      I2RT-7200           PayGo: eSupport - Fixed Accept/Decline Solution and Need More Time actions   T21
 Vignesh Divakaran      07/10/2022      I2RT-7179      		Refactored and updated method to validate for both
 															Read Only  & Read/Write users T22
 Vignesh Divakaran      07/10/2022      I2RT-7197      		Added method to get SOSL search results T23
 Amit Garg              10/22/2022      I2RT-7295           Relabel label name of record Type to "Technical" instead of Case Lite        T24
 Vignesh Divakaran      25/10/2022      I2RT-7256      		Added Id field to the query T25
 Vignesh Divakaran      31/10/2022      I2RT-7424      		Added Org__r.Name field to the query T26
 Vignesh Divakaran      31/10/2022      I2RT-7210      		Updated method to remove all access checks 	T27
 Vignesh Divakaran      28/03/2023      I2RT-7749      		Added method to get the event id from case 	T28
 Vignesh Divakaran      28/04/2023      I2RT-6895      		Added method to query orgs with child orgs of upto two level 	T29
 Shashikanth            05/22/2023      I2RT-8140          	Attention Requests and Escalations: Avoid multiple requests.    T30
 Vignesh Divakaran      16/05/2023      I2RT-7832      		Commented code 	T31
 Vignesh Divakaran      10/08/2023      I2RT-9063      		Added generic method to delete sobjects T32
 Shashikanth            10/31/2023      I2RT-8987           Added Case Timezone field in getCase method     T33
 Vignesh Divakaran      11/24/2023      I2RT-9461      		Removed unused method T34
 */

 public without sharing class CaseControllerWithoutSharing {

	public static final String ECOMMERCE_ACCOUNT_RECORDTYPE = 'eCommerce'; //<T20>
    public static final String READ_ONLY = 'Read Only'; //<T22>
    public static final String READ_WRITE = 'Read/Write'; //<T22>

    /*
        Called from CaseController.createCase(), CaseController.getCaseIRDateTime()
    */
    public static list<case> GetAllCases(string query, string accountId, string filters){
        query = query + ' where support_account__c  =: accountId and Is_Internal_Or_External_Case__c =\'External\'';
        if(filters != null){
            query += filters;
        }
        return database.Query(query);
    }
    public static List<Account> getSupportAccount(Id supportAccId){
        List<Account> lstSupportAccounts = new List<Account>();

        if(String.isNotEmpty(supportAccId)){
            lstSupportAccounts = [SELECT Id,OwnerId, Name, ParentId, Parent.BillingCountry, Parent.OwnerId, BillingCountry, Entitlement__c,
            Entitlement__r.Support_Level__c,TimeZone__c,TimeZone__r.Name,Support_Add_On__c,TimeZone__r.TimeZoneSidKey__c from Account WHERE Id =: supportAccId];
        }

        return lstSupportAccounts;
    }

    /*
          Called from CaseController.reOpenCase() , CaseController.getCaseDetails() & CaseController.getISacces()
          T19 added fields on the query
    */
    public static Case getCase(Id caseId){
        List<Case> lstCases = new List<Case>();

        if(String.isNotEmpty(caseId)){
            lstCases = [SELECT ID, CaseNumber, Subject, Description, Error_Message__c, Priority, Forecast_Product__c, Version__c, Component__c,
            Subcomponent__c, Problem_Type__c, AccountId, ContactId, Support_Account__c, Entitled_Product__c, EntitlementId, Org__c, Secure_Agent__c, 
            RecordTypeId ,Activity_Type__c,Environment__c,Org_ID__c,Org__r.OrgID__c ,GCS_AAE_Session_Time__c, Status,  Next_Action__c,  ClosedDate,
            CreatedDate, LastmodifiedDate, Support_Account__r.Name,Support_Account__r.AccountNumber,
            Support_Account__r.Entitlement__r.EndDate, Support_Account__r.Entitlement__r.Status, Support_Account__r.Success_Offering__c,
            Support_Account__r.TimeZone__r.Name, Support_Account__r.Max_Customer_R_W_Contacts__c, Support_Account__r.Active_Customer_R_W_Contacts__c,
            Support_Account__r.Description, Recordtype.Name, Contact.Phone, Contact.Name, Contact.INFA_Language__c, Old_Case_Number__c, Escalated_Date__c, RCA_Pending_flag__c, CreatedBy.Name,
            CreatedBy.Email, ContactEmail, Service_Appointment_AAE__c, Org_Formula_Id__c,Business_Impact__c,Estimated_Date_for_Milestone__c, Problem_Statement__c, Closing_Notes__c,RecordType.DeveloperName,Org__r.Name, //<T26>
            Attention_Request__c, Case_Timezone__r.TimeZoneSidKey__c        //<T30>     <T33>
            FROM Case WHERE ID =: caseId
            ];
        }
        return !lstCases.isEmpty() ? lstCases[0] : new Case();
    }

    /*
        Called from CaseController.reOpenCase()
    */
    public static Contact getContact(Id contactId){
        Contact c = new Contact();

        if(String.isNotEmpty(contactId)){
            c = [Select Id,TimeZone_Lookup__c from Contact where Id =: contactId];
        }
        return c;
    }

    /*
        Called from CaseController.createCase()
    */
    public static void createCase(Case c){
        insert c;
    }

    /*
        Called from CaseController.createCase()
    */
    public static void createCaseContacts(List<Case_Contact__c> caseContacts){
        insert caseContacts;
    }

    /*
        Called from CaseController.createCase(), CaseController.reOpenCase()
    */
    public static void initialResponseCaseComment(Id caseId){
        Case createdCase = [SELECT Id, Is_Internal_Or_External_Case__c,AAE_Area_of_expertise__c,GCS_AAE_Session_Time__c, Category__c,
                                    Record_Type_Name__c,ContactId,Contact.Name,casenumber,Priority,Success_Offering__c,Forecast_Product__c,
                                    Version__c,Contact.Salutation, Support_Account__r.Name, CreatedBy.Name, AccountId, 
                                    Intial_Response_time__c, Resolution_Target_DateTime__c,
                                    Subject, Description, Support_Account__c, Problem_Area__c, RecordTypeId,
                                    Case_Timezone__r.TimeZoneSidKey__c,RecordType.DeveloperName 
                                    FROM Case 
                                    WHERE Id=: caseId];
                
        String consalution = 'Hi';
        String alternatecon = ' ';
        if(createdCase.Contact != null && !string.isblank(createdCase.Contact.Salutation)){
            consalution = createdCase.Contact.Salutation;
        }
        List<AccountContactRelation> acclist = new List<AccountContactRelation> ([Select Id,Contact.Name from AccountContactRelation where AccountId = :createdCase.Support_Account__c and Primary__c = true and IsActive = true]);
        String primaryconname = ' ';
        for(AccountContactRelation acrelation: acclist){
            if(string.isblank(primaryconname)){
                primaryconname = acrelation.Contact.Name;
            } else{
                primaryconname = primaryconname + ', ' + acrelation.Contact.Name; //T12
            }                    
        }
        /*if(createdCase.Record_Type_Name__c == 'Ask An Expert'){

            for(Case_Contact__c casecon: [Select Id,Contact__r.Name,Contact__c from Case_Contact__c where Case__c = :createdCase.Id]){
            if(casecon.Contact__c != createdCase.ContactId && !string.isblank(casecon.Contact__c)){
            if(String.isblank(alternatecon)){
            alternatecon  = casecon.Contact__r.Name;
            }else {
            alternatecon  = alternatecon  + ',' + casecon.Contact__r.Name;
            }
            }
            }    
            }*/
                            String commentBody; /*= '<p>Hi <b>'+createdCase.Contact.Name+'</b></p>';
            commentBody += '<p style="font-weight: 400; font-size: 12px;">The issue you reported has been logged as Case <b>'+createdCase.Casenumber+'</b> Please take a moment to check the environment details are accurate. A copy of this email is also marked to the primary contact on the project <b>' +primaryconname+ '</b></p>';
            //commentBody += '<p style="font-weight: 400; font-size: 12px;"> This case has been opened for this project by <b>'+createdCase.CreatedBy.Name+'.</b></p>';
            commentBody +=  '<table border="0" cellpadding="0" cellspacing="0" width="100%"> <tbody> <tr>';
            commentBody +=  '<td style="vertical-align:top;"><div style="border: 2px solid #F3F1F2; width: 600px; margin: 0 auto 0px">&nbsp;</div></td></tr>    <tr><td><h2 style="font-size: 16px; font-weight: 400">Case Details</h2>';
            commentBody += '<div style="margin-bottom: 12px;"><span style="width: 100%;">Case Number :</span> <span style="font-weight:bold">'+createdCase.casenumber+'</span></div>';
            commentBody += '<div style="margin-bottom: 12px;"><span style="width: 100%;">Priority :</span> <span style="font-weight:bold">'+createdCase.priority+'</span></div>';
            commentBody += '<div style="margin-bottom: 12px;"><span style="width: 100%;">Subject :</span> <span style="font-weight:bold">'+createdCase.subject+'</span></div>';
            commentBody += '<div style="margin-bottom: 12px;"><span style="width: 100%;">Estimated Response Time :</span> <span style="font-weight:bold">'+(createdCase.Intial_Response_time__c != null ? createdCase.Intial_Response_time__c : '')+'</span></div></td></tr></tbody></table>';
            */
        
        //Updated IR Comment Template
        if(createdCase.Is_Internal_Or_External_Case__c != 'Internal'){
            commentBody = '<table align="center" border="0" cellpadding="0" cellspacing="0" width="600"><tbody><tr><td style="padding-bottom: 18px;">';
            commentBody += '<p>'+consalution+'<b> '+createdCase.Contact.Name+'</b></p><br>';
            if(createdCase.Record_Type_Name__c == 'Ask An Expert'){
                commentBody += 'Thank you for booking an ' + '\''+ 'Ask An Expert'+'\'' +' session with informatica Global Customer Support.<br><br>';
                commentBody += '<p>Please find the session details as follows. Please do not reply to this email. To view the details of upcoming session or to modify the timings, please click on the button below.</p></td></tr><br>';
                commentBody += '<tr><td><h2 style="font-size: 16px; font-weight: 400;">Ask An Expert Session Details</h2>';
                commentBody += '<div style="margin-bottom:12px"><span style="width: 25%;display: inline-block;">Session Details :</span><span style="font-weight:bold;">'+createdCase.GCS_AAE_Session_Time__c+'</span></div>';
                commentBody += '<div style="margin-bottom:12px"><span style="width: 25%;display: inline-block;">Session Summary :</span><span style="font-weight:bold;">'+createdCase.Subject+'</span></div>';
                commentBody += '<div style="margin-bottom:12px"><span style="width: 25%;display: inline-block;">Product :</span><span style="font-weight:bold;">'+createdCase.Forecast_Product__c+'</span></div>';
                commentBody += '<div style="margin-bottom:12px"><span style="width: 25%;display: inline-block;">Product Area :</span><span style="font-weight:bold;">'+(String.isNotEmpty(createdCase?.AAE_Area_of_expertise__c) ? createdCase?.AAE_Area_of_expertise__c : '')+'</span></div>';
                commentBody += '<div style="margin-bottom:12px"><span style="width: 25%;display: inline-block;">Product Category :</span><span style="font-weight:bold;">'+(String.isNotEmpty(createdCase?.Category__c) ? createdCase?.Category__c : '')+'</span></div>';
                // commentBody += '<div style="margin-bottom:12px"><span style="width: 25%;display: inline-block;">Alternate Contacts :</span><span style="font-weight:bold;">'+(String.isNotEmpty(alternatecon) ? alternatecon : '')+'</span></div>';
                
            }else{
                commentBody += 'Thank you for contacting Informatica Global Customer Support.<br><br>';
                commentBody += '<p>The issue you reported has been logged as Case <b> '+createdCase.casenumber+'</b>. Please take a moment to check the environment details are accurate.'; //T10
                //T16 - exclude this statement for Lite cases
                if(createdCase.RecordType.DeveloperName != 'Case_Lite'){//<T22>
                    commentBody += ' A copy of this email has been sent to the primary contact <b>'+primaryconname+'</b> for the Support Account <b>'+createdCase.Support_Account__r.Name+'</b>.</p></td></tr>';
                }
                commentBody += '<tr><td><h2 style="font-size: 16px; font-weight: 400;">Case Details</h2>';
                commentBody += '<p><span style="width: 25%;display: inline-block;">Case Number :</span><span style="font-weight:bold;">'+createdCase.casenumber+'</span></p>';
                commentBody += '<p><span style="width: 25%;display: inline-block;">Case Summary :</span><span style="font-weight:bold;">'+createdCase.Subject+'</span></p>';
                if(createdCase.RecordType.DeveloperName != 'Case_Lite'){ //<T22>
                    commentBody += '<p><span style="width: 25%;display: inline-block;">Priority :</span><span style="font-weight:bold;">'+createdCase.Priority+'</span></p>';
                    commentBody += '<p><span style="width: 25%;display: inline-block;">Success Offering :</span><span style="font-weight:bold;">'+(String.isNotEmpty(createdCase?.Success_Offering__c) ? createdCase?.Success_Offering__c : '')+'</span></p>';
                }
                if(createdCase.Record_Type_Name__c != 'Administrative'){
                    commentBody += '<p><span style="width: 25%;display: inline-block;">Product :</span><span style="font-weight:bold;">'+(String.isNotEmpty(createdCase?.Forecast_Product__c) ? createdCase.Forecast_Product__c : '')+'</span></p>';
                    if(createdCase.RecordType.DeveloperName != 'Case_Lite'){ //<T22>
	                    commentBody += '<p><span style="width: 25%;display: inline-block;">Version :</span><span style="font-weight:bold;">'+(String.isNotEmpty(createdCase?.Version__c) ? createdCase.Version__c : '')+'</span></p>';
                    }
                }
            }
            if(String.isNotEmpty(createdCase?.Intial_Response_time__c) && createdCase.Record_Type_Name__c != 'Ask An Expert'){
                commentBody += '<br>An Informatica support engineer will contact you by '+ createdCase.Intial_Response_time__c +'. This response time is based on the priority of the Case and your level of support.<br><br>';
                commentBody += '<b>Kind Regards, <br>Informatica Global Customer Support</b><br></td></tr></tbody></table>';
                
            } else if(createdCase.Record_Type_Name__c == 'Ask An Expert'){
                commentBody += '<br>One of our Subject Matter Experts will contact you with further details.<br></td></tr></tbody></table>';
            }
            else{
                commentBody += '<br><b>Kind Regards, <br>Informatica Global Customer Support</b><br><br></td></tr></tbody></table>';
            }
            
            Case_Comment__c newCaseComment= new Case_Comment__c();
            newCaseComment.Sub_Type__c = 'Initial Response';
            newCaseComment.Comment__c = commentBody;
            newCaseComment.Status__c = 'Submitted';
            newCaseComment.Visibility__c = 'External';
            newCaseComment.Case__c = caseId;
            Insert newCaseComment;
        }                
        createIcareReferral(createdCase);
    }

    /*
        Called from CaseController.doCaseRecordTypeChange(), CaseControllerWithoutSharing.initialResponseCaseComment()
    */
    public static void createIcareReferral(Case c){
        //Creating the iCase refferel record if case recordtype is Admin and Problem Area is End of Support
        Id AdministrativeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
        if(c.RecordTypeId == AdministrativeRecordTypeId && c.Problem_Area__c == 'End of Support'){
            iCare_Referral__c iCareReferral = new iCare_Referral__c();
            iCareReferral.Case__c = c.Id;
            iCareReferral.Customer_Account__c = c.AccountId;
            iCareReferral.Description__c = c.Description;
            iCareReferral.Subject__c = c.Subject;
            iCareReferral.Support_Account__c = c.Support_Account__c;
            iCareReferral.Referrer__c = UserInfo.getUserId();
            insert iCareReferral;
        }
    }

    /*
        Called from CaseController.getSupportAccountInfo()
    */
    public static List<AccountTeamMember> getAccountTeamMembers(Id supportAccId, List<String> lstAccTeamRoleName) {
        List<AccountTeamMember> ATMs = new List<AccountTeamMember>();

        if(String.isNotEmpty(supportAccId)){
            Id customerAccId = [SELECT Id, ParentId  FROM Account WHERE Id =: supportAccId]?.ParentId;
            ATMs = String.isNotEmpty(customerAccId) ? [Select Id, AccountId, Account.Success_Offering__c, TeamMemberRole, User.Name, User.FirstName, User.LastName, User.Email
                FROM AccountTeamMember where accountId = :customerAccId and TeamMemberRole in:lstAccTeamRoleName order by TeamMemberRole asc] : null;
        }
        
        return (ATMs != null && ATMs.size() > 0) ? ATMs : new List<AccountTeamMember>();
    }

    /*
        Called from CaseController.getSupportAccountInfo()
    */
    public static List<AccountContactRelation> getPrimarySupportAccountContacts(Id supportAccId){
        List<AccountContactRelation> ACRs = new List<AccountContactRelation>();

        if(String.isNotEmpty(supportAccId)){
            ACRs = [SELECT Id, Contact.Name,Account.Success_Offering__c, Contact.Email FROM AccountContactRelation WHERE AccountId =: supportAccId AND Primary__c = true];
        }

        return (ACRs != null && ACRs.size() > 0) ? ACRs : new List<AccountContactRelation>();
    }

    /*
        Called from - SupportAccountController.getSupportAccount(), CaseController.getAccountRelatedContacts()
        // tag t05 , added isactive condition on query 
    */
    public static List<AccountContactRelation> getSupportAccountContacts(Id supportAccId){
        List<AccountContactRelation> SupportAccountContacts = new List<AccountContactRelation>();

        SupportAccountContacts = [Select Id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email,Phone__c,Access_Level__c,Timezone__c,Language__c,Contact_Language__c,Contact_Timezone__c,Primary__c,
        Account.Success_offering__c,Contact.Name,Contact.Phone FROM AccountContactRelation where AccountId =: supportAccId and Account.RecordType.Name = 'Support Account' and IsActive = true];

        return (SupportAccountContacts != null && SupportAccountContacts.size() > 0) ? SupportAccountContacts : new List<AccountContactRelation>();
    }

    /*
        Called from CaseController.getCaseDetails()
    */
    public static List<AccountContactRelation> getAssignedSupportAccountContacts(Id supportAccId, Set<Id> contactIds){
        List<AccountContactRelation> ACRs = new List<AccountContactRelation>();

        ACRs = [Select Id,ContactId,Access_Level__c from AccountContactRelation where ContactId IN :contactIds and AccountId =: supportAccId];
        
        return (ACRs != null && ACRs.size() > 0) ? ACRs : new List<AccountContactRelation>();
    }

    /*
        Called from ManageCaseContacts.getAlternateContacts()
        t06 - added isactive condition in query
    */
    public static List<AccountContactRelation> getUnAssignedSupportAccountContacts(Id supportAccId, Set<Id> contactIds){
        List<AccountContactRelation> ACRs = new List<AccountContactRelation>();

        ACRs = [Select Id,Primary__c,ContactId,AccountId,Contact.Name,Contact.Email,Contact.Phone from AccountContactRelation where AccountId = :supportAccId and ContactId NOT IN :contactIds  and  IsActive = true order by Contact.FirstName ASC];
        
        return (ACRs != null && ACRs.size() > 0) ? ACRs : new List<AccountContactRelation>();
    }

    /*
        Called from ManageCaseContacts.updateContactRelation()
    */
    public static List<SObject> updateAccountContactRelation(String firstName, String lastName, String contactId,String nameChanged,String phone,String language,String timezone,String privilege,string primary,string acrId,string acrChanged, String accountId){
        
        //---------------------------------------<T07>-----------------------------
        firstName = escapeQuotes(firstName);
        lastName = escapeQuotes(lastName);
        contactId = escapeQuotes(contactId);
        nameChanged = escapeQuotes(nameChanged);
        phone = escapeQuotes(phone);
        language = escapeQuotes(language);
        timezone = escapeQuotes(timezone);
        privilege = escapeQuotes(privilege);
        primary = escapeQuotes(primary);
        acrId = escapeQuotes(acrId);
        acrChanged = escapeQuotes(acrChanged);
        accountId = escapeQuotes(accountId);
        //---------------------------------------</T07>-----------------------------
        List<SObject> records = new List<SObject>();
        /*<T31>if(Boolean.valueOf(acrChanged) && Boolean.valueOf(primary)){
            for (AggregateResult agr : [SELECT count(Id) countPrimary, AccountId SupportAccount FROM AccountContactRelation where AccountId = :accountId and Primary__c = true and isActive = true  group by AccountId]){
                if((Integer)agr.get('countPrimary')>=2){
                    string errorMessage = 'Max 2 Primary Contacts is allowed';
                    AuraHandledException auraEx = new AuraHandledException(errorMessage);
                    auraEx.setMessage(errorMessage);
                    throw auraEx;
                }
                } 
        }*/
        if(Boolean.valueOf(acrChanged)){
            AccountContactRelation acr = new AccountContactRelation();
            acr.Id = acrId;
            acr.Phone__c = phone;
            acr.Language__c = language;
            
            acr.Timezone__c = timezone;
            acr.Access_Level__c = privilege;
            acr.Primary__c = Boolean.valueOf(primary);
            records.add(acr);
        }
        if(Boolean.valueOf(nameChanged)){
            Contact con = new Contact();
            con.Id = contactId;
            con.FirstName = firstName;
            con.LastName = lastName;
            con.Phone = phone;//<T13>
            con.INFA_Language__c = language;//<T13>
            
            con.Timezone__c = timezone;//<T13>
            records.add(con);
        }
        update records;
        return records;
    }

    /*
        Called from ManageCaseContacts.removeContacts()
    */
    public static String deleteAccountContactRelation(Id accountContactId){
        String returnMessage;
        AccountContactRelation ACR = [Select Id,AccountId from AccountContactRelation where Id =: accountContactId AND Account.RecordType.Name = 'Support Account'];
        Id supportAccId = ACR?.AccountId;

        if(String.isNotEmpty(supportAccId) && isPrimaryContact(supportAccId)){
            if(ACR != null){
                DELETE  ACR;
                returnMessage = 'SUCCESS';
            }
        }
        return String.isNotEmpty(returnMessage) ? returnMessage : 'Error';
    }

    /*
        Called from CaseController.getCaseDetails(), CaseController.updateCaseContacts()
    */
    public static List<Case_Contact__c> getCaseContacts(Id caseId){
        List<Case_Contact__c> CaseContacts = new List<Case_Contact__c>();

        CaseContacts = [Select Id,Contact__c,Case__r.ContactId, Contact__r.Firstname, Contact__r.Lastname, contact__r.Timezone__c, Email_Formula__c, Primary__c, 
        Contact__r.INFA_Language__c, Contact__r.Phone,Contact__r.Access_Level__c,Email__c,contact__r.TimeZone_Lookup__c,contact__r.TimeZone_Lookup__r.Name FROM Case_Contact__c WHERE Case__c =: caseId];

        return (CaseContacts != null && CaseContacts.size() > 0) ? CaseContacts : new List<Case_Contact__c>();
    }

    /*
        Called from ManageCaseContacts.createcasecontactcontr()
    */
    public static void createCaseContacts(List<Case_Contact__c> caseContacts, Id supportAccId){
        Set<Id> primaryContactIds = new Set<Id>();
        Id caseId;
        Id supportAccountId = supportAccId;
        Boolean isExternalUser = [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;

        if((isExternalUser && isValidUser(caseId, supportAccountId, READ_WRITE)) || !isExternalUser){ //<T22>
            for(AccountContactRelation acr : [Select Id,ContactId from AccountContactRelation where AccountId =: supportAccId and Primary__c = true]){
                primaryContactIds.add(acr.ContactId);
            }
            for(Case_Contact__c cc : caseContacts){
                if(cc.Contact__c != null){
                    cc.Primary__c = primaryContactIds.contains(cc.Contact__c) ? true : false;
                }
            }             
            insert new List<Case_Contact__c>(new Set<Case_Contact__c>(caseContacts));
        }
    }

    /*
        Called from CaseController.removeCaseContact()
    */
    public static void deleteCaseContact(Id caseContactId){
		delete [SELECT Id FROM Case_Contact__c WHERE Id =: caseContactId]; //<T27>
    }

    public static Boolean isValidUser(Id caseId, Id supportAccId, String strAccessLevel){ //<T22>
        Id caseSupportAccId;
        Boolean HasAccess = false;
        Id ContactId = GlobalUtility.getCommunityUserContactId();

        if(String.isNotEmpty(caseId)){
            caseSupportAccId = [Select Support_Account__c from Case where Id =: caseId]?.Support_Account__c;
        }

        if(String.isEmpty(caseSupportAccId) && String.isNotEmpty(supportAccId)){
            caseSupportAccId = supportAccId;
        }

        if(String.isNotEmpty(caseSupportAccId) && String.isNotEmpty(ContactId)){
            String strContactAccessLevel = [Select Access_Level__c from AccountContactRelation where AccountId =: caseSupportAccId AND ContactId =: ContactId LIMIT 1]?.Access_Level__c;

            if(String.isNotEmpty(strContactAccessLevel)){
                if(strContactAccessLevel == strAccessLevel && String.isNotEmpty(strAccessLevel)){
                    HasAccess = true;
                }
                else if(String.isEmpty(strAccessLevel) && (strContactAccessLevel == READ_ONLY || strContactAccessLevel == READ_WRITE)){
                    HasAccess = true;
                }
            }
        }

        return HasAccess;
    }

    public static Boolean isPrimaryContact(Id supportAccountId){
        Id contactId = [Select Id, ContactId from User where Id =: UserInfo.getUserId()]?.ContactId;
        return [Select Id, Primary__c from AccountContactRelation where AccountId =: supportAccountId and ContactId != null and ContactId =: contactId limit 1]?.Primary__c ? true : false;
    }

    /*
        Called from CaseTeamService.getCaseSubscribers()
    */
    public static User getUser(Id caseOwnerId){
        List<User> usr = [Select Id, ManagerId From User Where Id = :caseOwnerId];
        return usr[0];
    }

    /*
        Called from CaseService.escalate()
    */
    public static void insertCaseComments(List<Case_Comment__c> lstCaseComment){
        Boolean isExternalUser = [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;

        if(!isExternalUser){
            insert lstCaseComment;
        }else if((isExternalUser && isValidUser(lstCaseComment[0].Case__c, null, READ_WRITE))){ //<T22>
            insert lstCaseComment;
        }
    }

    /*
        SupportAccountController.createContact()
    */
    public static void createContact(Contact con){
        insert con;
    }
    //<t11>
    public static AccountContactRelation createACR(AccountContactRelation acr){
        insert acr;
        return [Select Id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email,Phone__c,Access_Level__c,Timezone__c,Language__c,Primary__c,AccountId from AccountContactRelation where Id = :acr.Id limit 1];
    }
    public static string createCaseContact(Case_Contact__c cc){
        Database.SaveResult sr = Database.insert(cc);
        return sr.getId();
    }
    public static Timezone__c queryTimezone(String region, string Location){
        timezone__c tz = [select id,Timezone__c from timezone__c where region__c =: region and location__c =:location limit 1];
        return tz;
    }

    /*
        SupportAccountController.createContact()
    */
    public static Boolean isLeadExists(String email){
        Id leadId = [Select Id from Lead Where Email =: email LIMIT 1]?.Id;
        Id contactId = [Select Id from Contact Where Email =: email LIMIT 1]?.Id;
        
        return String.isNotEmpty(leadId) && String.isEmpty(contactId) ? true : false;
    }

    /*
        SupportAccountController.createContact()
    */
    public static Boolean isContactExists(String email){ // <T01>
        Id contactId = [Select Id from Contact Where Email =: email LIMIT 1]?.Id;
        return String.isNotEmpty(contactId) ? true : false;
    }
	//<T14> starts
    public static Boolean CheckIFACRExists(String email,string AccountId){
        id acrId = [select id,contact.email, account.name from accountContactRelation where contact.email =:email and accountId =: AccountId limit 1]?.id;
        return String.isNotEmpty(acrId) ? true : false;
    }
	public static Boolean isContactUnderDifferentAccountExists(String email,string AccountId){
        account acc = [select id, parentId from account where id= :accountId];
        Id contactId = [Select Id from Contact Where Email =: email and accountId != :AccountId and accountId != :acc.parentId LIMIT 1]?.Id;
        return String.isNotEmpty(contactId) ? true : false;
    }
	//<T14> ends
    // <T02>
    /*
        Called from - SupportAccountController.getSupportAccount()
    */
    public static List<zsfjira__ZIssue_Case__c> getSupportAccountJiras(Id supportAccId){
        Service_Cloud_General_Setting__mdt jiraMeta = [SELECT Issue_Types_to_Include__c, Projects_To_Exclude__c
                                                                FROM Service_Cloud_General_Setting__mdt 
                                                                WHERE DeveloperName = 'Community_JIRAS'
                                                                LIMIT 1];
        list<string> IssueTypeToInclude = jiraMeta.Issue_Types_to_Include__c.split(',');
        list<string> ProjectsToExclude = jiraMeta.Projects_To_Exclude__c.split(',');
        List<zsfjira__ZIssue_Case__c> SupportAccountJiras = new List<zsfjira__ZIssue_Case__c>();
        //<T08>
        SupportAccountJiras = [Select Id,zsfjira__ZIssueId__r.zsfjira__IssueKey__c,zsfjira__ZIssueId__r.zsfjira__Summary__c,zsfjira__ZIssueId__r.zsfjira__IssueType__c,zsfjira__ZIssueId__r.zsfjira__Project__c,zsfjira__ZIssueId__r.zsfjira__Status__c,zsfjira__ZIssueId__r.zsfjira__AffectsVersions__c,zsfjira__ZIssueId__r.zsfjira__FixVersions__c,zsfjira__ZIssueId__r.zsfjira__Created__c,zsfjira__ZIssueId__r.zsfjira__DueDate__c From zsfjira__ZIssue_Case__c where zsfjira__CaseId__r.Support_Account__c = :supportAccId and zsfjira__ZIssueId__r.zsfjira__Status__c!='Closed' and ( zsfjira__ZIssueId__r.zsfjira__Project__c not in : ProjectsToExclude ) and zsfjira__ZIssueId__r.zsfjira__IssueType__c in :IssueTypeToInclude  ];
        //<T08>
        return (SupportAccountJiras != null && SupportAccountJiras.size() > 0) ? SupportAccountJiras : new List<zsfjira__ZIssue_Case__c>();
    }
    // </T02>

 // <T03>
 /*
    Called from - CaseTriggerHelper.updateAaeEvent()
 */
    public static void updateEventRelation(list<EventRelation> lstEventRelation){
       insert lstEventRelation;
    }

    public static void updateEvent(list<event> lstEvent){
        insert lstEvent;
     }
// </T03>

    //---------------------------------------<T04>-----------------------------

    /*
        Called from CaseController.createCase()
    */
    public static void createEntitledProduct(Entitled_Product__c objEntitledProduct){
        insert objEntitledProduct;
    }

    //---------------------------------------</T04>-----------------------------

    //---------------------------------------<T07>-----------------------------

    /*
        Called from CaseControllerWithoutSharing.updateAccountContactRelation()
    */
    private static String escapeQuotes(String s){        
        return (s != null) ? String.escapeSingleQuotes(s) : s;
    }

    //---------------------------------------</T07>-----------------------------

    //---------------------------------------<T08>-----------------------------
    /*
        Called from CaseController.getSupportAccountInfoByContact()
    */
    public static List<AccountContactRelation> getSupportAccountInfoByContact(String contactId){
        Id supportAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
        List<AccountContactRelation> acrLst = [Select Id,AccountId From AccountContactRelation where ContactId = :contactId and Account.RecordTypeId = :supportAccountRTId];
        
        return (acrLst != null && acrLst.size() > 0) ? acrLst : new List<AccountContactRelation>();
    }
    //---------------------------------------</T08>-----------------------------
   
    //<T15> starts
    public static string getAccountManagerName(String accountId){
        string salesRepName;
        id TerritoryId = [select id, objectId, Territory2Id from ObjectTerritory2Association where objectId =: accountId ]?.Territory2Id;
        if(TerritoryId != null){
            list<UserTerritory2Association> userTerritories = [SELECT Id, user.firstname, user.lastname FROM UserTerritory2Association where RoleInTerritory2 = 'Account Manager' and Territory2Id =:TerritoryId];
            if(!userTerritories.isEmpty()){
                salesRepName = userTerritories[0].user.firstName + ' '+ userTerritories[0].user.LastName;
            }
        }
        return salesRepName;
    }
    //<T15> ends
   
  	//---------------------------------------<T17>-----------------------------
    /*
        Called from CaseController.createCase()
    */
    public static Org__c getOrg(String strOrgUUID){
        List<Org__c> lstOrgs = [SELECT Id,Account__c FROM Org__c WHERE OrgID__c =: strOrgUUID];
        return !lstOrgs.isEmpty() ? lstOrgs[0] : new Org__c(); 
    }

    /*
        Called from CaseController.createCase()
    */
    public static List<Org__c> getOrgs(String strProductName){
        Set<Id> setOrgIds = new Set<Id>();
        List<Org__c> lstOrgs = new List<Org__c>();
        for(Org_User__c objOrgUser : [SELECT Org__c FROM Org_User__c WHERE Contact__c =: GlobalUtility.getCommunityUserContactId() AND Org__r.Support_Lite__c = true]){
            setOrgIds.add(objOrgUser.Org__c);
        }
        lstOrgs = [SELECT Id,Org_Name__c,OrgID__c,Account__c,Number_of_Cases_Created__c FROM Org__c WHERE Id IN (SELECT Org_ID__c FROM Org_Service__c WHERE Org_Service_Name__c =: strProductName AND Org_ID__c IN :setOrgIds)]; //<T25>
        return lstOrgs;
    }

    /*
        Called from CaseController.getAccountContacts()
    */
    public static List<AccountContactRelation> getEcommerceAccountContacts(String strAccountId){
        return [SELECT Id,ContactId,Contact.FirstName,Contact.LastName,Contact.Email,Phone__c,Access_Level__c,Timezone__c,Language__c,Contact_Language__c,Contact_Timezone__c,Primary__c,
        Account.Success_offering__c,Contact.Name,Contact.Phone FROM AccountContactRelation WHERE AccountId =: strAccountId AND Account.RecordType.DeveloperName = 'eCommerce' AND IsActive = true AND ContactId !=: GlobalUtility.getCommunityUserContactId()];
    }
    //---------------------------------------</T17>-----------------------------
    //<T18> starts
    public static Org__c getOrgId(id accountId){
        return [select id, OrgID__c,Name, Pod_Location__c, Pod_Name__c, Pod_Region__c
                from Org__c where account__c =: accountId order by createddate desc limit 1];
    }
    public static list<account> getEcommerceAccountInfo(string accountId){
        return [Select Id,Type, Name, New_Org_Account_Number__c,Support_Account_Status__c,End_Date__c, Entitlement__r.EndDate, Entitlement__r.Status,Success_Offering__c,Support_Account_Type__c, TimeZone__r.Name,Max_Customer_R_W_Contacts__c,Active_Customer_R_W_Contacts__c,Description,Owner.FirstName,Owner.LastName,ParentId, RecordType.DeveloperName
                                   From Account 
                                   Where Id = :accountId  and RecordType.DeveloperName = 'eCommerce'];
    }
    //<T18> ends
  
  	//---------------------------------------</T20>-----------------------------
    /*
        Called from ManageCasesController.getFilters(),getRecords() & CaseDownloadController.getFilters,getRecords()
    */
    public static List<Org__c> getOrgs(){
        Set<Id> setAccountIds = new Set<Id>();
        List<Org__c> lstOrgs = new List<Org__c>();
        Id contactId = GlobalUtility.getCommunityUserContactId();
        Map<Id, List<Org__c>> mapAccountIdOrgs = new Map<Id, List<Org__c>>();

        //Now, we get all orgs where there is an org user record for the community user contact
        for(Org__c objOrg : [SELECT Id,OrgID__c,Account__c,Support_Lite__c FROM Org__c WHERE Id IN (SELECT Org__c FROM Org_User__c WHERE Contact__c =: contactId) AND OrgID__c != null LIMIT 2000]){
            if(mapAccountIdOrgs.containsKey(objOrg.Account__c)){
                List<Org__c> lstOldOrgs = mapAccountIdOrgs.get(objOrg.Account__c);
                lstOldOrgs.add(objOrg);
                mapAccountIdOrgs.put(objOrg.Account__c, lstOldOrgs);
                setAccountIds.add(objOrg.Account__c);
            }
            else{
                setAccountIds.add(objOrg.Account__c);
                mapAccountIdOrgs.put(objOrg.Account__c, new List<Org__c>{objOrg});
            }
        }
        //Now, we check if user has a R/W contact to the eCommerce account which is associated to the org
        for(AccountContactRelation objAccountContactRelation : [SELECT Id,AccountId FROM AccountContactRelation WHERE AccountId =: setAccountIds AND Access_Level__c = 'Read/Write' AND ContactId =: contactId AND Account.RecordType.Name =: ECOMMERCE_ACCOUNT_RECORDTYPE LIMIT 2000]){
            if(mapAccountIdOrgs.containsKey(objAccountContactRelation.AccountId)){
                lstOrgs.addAll(mapAccountIdOrgs.get(objAccountContactRelation.AccountId));
            }
        }

        return lstOrgs;
    }

    /*
        Called from ManageCasesController.getRecords(), CaseDownloadController.getRecords() & getAccountContacts()
    */
    public static List<SObject> getSObjectRecords(String strQuery){
        return Database.query(strQuery);
    }
    //---------------------------------------</T20>-----------------------------

    //T21 - to update a Case in without sharing context
    public static void updateCase(Case cse){
        update cse;
    }

    //T21 - to insert a Case Comment in without sharing context
    public static void insertCaseComment(Case_Comment__c cseComment){
        insert cseComment;
    }
  
    //---------------------------------------<T23>-----------------------------
    /*
        Called from CaseCommentController.getCaseCommentsSOSL()
    */
    public static Search.SearchResults getSearchResults(String strQuery){
        return Search.find(strQuery);
    }
    //---------------------------------------</T23>-----------------------------

    //---------------------------------------<T28>-----------------------------
    /*
        Called from CaseController.CancelAaeAppointmentHandler()
    */
    public static Id getEventFromCase(Id caseId){
        return [SELECT Id FROM Event WHERE IsChild = false AND WhatId =: caseId AND Cancel_Allowed__c = true LIMIT 1]?.Id;
    }
    //---------------------------------------</T28>-----------------------------

    //---------------------------------------<T29>-----------------------------
    /*
        Called from CaseController.getOrgIds()
    */
    public static List<Org__c> getAllOrgs(Set<Id> setOrgIds){
        List<Org__c> lstOrgs = new List<Org__c>();
        if(!setOrgIds.isEmpty()){
            lstOrgs = [SELECT Id,Name,OrgID__c FROM Org__c WHERE (EditionExpirationDate__c = null OR EditionExpirationDate__c >= TODAY) AND (Id IN :setOrgIds OR ParentOrg__c IN :setOrgIds OR ParentOrg__r.ParentOrg__c IN :setOrgIds)];
        }
        return !lstOrgs.isEmpty() ? lstOrgs : new List<Org__c>(); 
    }
    //---------------------------------------</T29>-----------------------------

    //---------------------------------------<T32>-----------------------------
    /*
        Called from CaseController.CancelAaeAppointmentHandler()
    */
    public static void deleteSobjects(List<SObject> lstSobjects){
        if(!lstSobjects.isEmpty())
            delete lstSobjects; 
    }
    //---------------------------------------</T32>-----------------------------
}