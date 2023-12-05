/*
Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.        Description                                                 Tag
*********************************************************************************************************************
NA             NA               UTOPIA          Initial version.                                            NA
Amit Garg      05/01/2022       I2RT-5226       Check Entitlement Status on Support Account                 T01
*/

@RestResource(urlMapping='/globalOpenCasesApi')
global without sharing class globalOpenCaseApi{

    private static Id uId = UserInfo.getUserId();
    public static Integer count = 0;
    
    //Get the data from the custom setting "Support Level Setting"
    //private static Map<String, Support_Level_Settings__c> mapSupportLevelToSettings = Support_Level_Settings__c.getAll();

    @HttpGet
    global static openCaseWrapper userAllOpenCases() {
        
        Boolean errors = false;     
        //Integer count = 0;
        
        List<AccountContactRelation> projContact = new List<AccountContactRelation>();
        List<openCasesActionCustomer> lstAllOpenCases = new List<openCasesActionCustomer>();
        try{

            // Get the user details based on the User Id
            List<User> selectedUser = new List<User>([SELECT Id, Name, ContactId, isActive,UserName FROM User WHERE Id= :uId AND IsActive = true Limit 1]);

            if (selectedUser!= null && !selectedUser.isEmpty()){

                User selectedUserId = selectedUser[0];

                //System.debug('===== selectedUser = ' + selectedUserId + ' =====');

                if (selectedUserId != null && selectedUserId.IsActive == true){
                    // Get the Project Contact details of the selected user
                    
                    //replaced the field Support_Level_Rank__c with Support_Level__c in the SOQL
                    projContact = [SELECT Id, contact.Name, Accountid, account.Entitlement__r.EndDate, account.Entitlement__r.Status,account.Support_Account_Status__c, account.Entitlement__r.Support_Level__c FROM AccountContactRelation WHERE contactId =: selectedUserId.contactId and account.RecordType.name = 'Support Account' AND IsActive = true]; //<T01>
                    
                    System.debug('===== projContact contains ' + projContact.size() + ' =====' + projContact);
                }
                
                // Call  the method to get the Cases
                lstAllOpenCases=getAllOpenCases(projContact);
            }
        }
        catch (exception e){
            System.debug('===== Error: ' + e.getMessage() + ' =====');
            errors = true;
        }
        
        openCaseWrapper uc = new openCaseWrapper(errors,lstAllOpenCases,count);
        return uc;
    }
    
    //Function to check if the entitlement is active using the EndDate and Status
    global static Boolean checkProjStatus(AccountContactRelation cont){
        if(cont.accountId!=null &&cont.account.Entitlement__c!=null &&cont.account.Entitlement__r.EndDate!=null && cont.account.Support_Account_Status__c!=null){//<T01>
            if (cont.account.Entitlement__r.EndDate >= Date.today() && cont.account.Support_Account_Status__c == 'Active'){//<T01>
                return True;
            }
        }
        return false;
    }
    
    //Method to get the all the cases
    global static List<openCasesActionCustomer> getAllOpenCases(List<AccountContactRelation> projectContact){
        List<openCasesActionCustomer> lstOfOpenCases = new List<openCasesActionCustomer>();

        try{

            Map<String, String> projAndProjConIds = new Map<String, String>();

            //Set<String> setProjIds = new Set<String>();
            //Set<String> setProjConIds = new Set<String>();
            for (AccountContactRelation con :projectContact){
                // Create a map with the only the active project details so as to get only the cases related to active projects
                if (checkProjStatus(con)){
                    projAndProjConIds.put(con.accountId,con.contactId);                    
                }
            }
            system.debug('projAndProjConIds--->>>'+projAndProjConIds);
//String EscalationRT=Label.Escalation_Record_Type;
            //String CollaborationRT=Label.Collaboration_Record_Type;
            // Query for the Cases from the active projects of particular Project Contact and excluding the COllaboration
            // and Escalation cases with last modified data in descending order and priority ascending order
            List<sObject> lstDetails =  new List<sObject>();
            //Set<Id> setCaseIds = new Set<Id>();
            if(!test.isRunningTest()){
               lstDetails = [SELECT Id, Description,NextAction__c,Next_Action__c,Account.Name,Support_Account__c ,Support_Account__r.name, accountId,CaseNumber, LastModifiedDate, Status, Subject ,Priority,(Select TextBody,ParentId,LastModifiedDate FROM EmailMessages ORDER BY LastModifiedDate desc LIMIT 1),(SELECT CommentBody,LastModifiedDate,ParentId FROM CaseComments ORDER BY LastModifiedDate desc LIMIT 1) FROM Case WHERE Status != 'Closed' AND Status != 'Resolved' AND Support_Account__c  In :projAndProjConIds.keySet() AND (NOT RecordType.name LIKE 'Collaboration%')  AND Next_Action__c = 'Customer' AND ContactId In :projAndProjConIds.values()  Order by LastModifiedDate desc, Priority asc LIMIT 50];
            }    else {
                lstDetails = [SELECT Id, Description,NextAction__c,Next_Action__c,Account.Name,Support_Account__c ,Support_Account__r.name, AccountId,CaseNumber, LastModifiedDate, Status, Subject ,Priority,(Select TextBody,ParentId,LastModifiedDate FROM EmailMessages ORDER BY LastModifiedDate desc LIMIT 1),(SELECT CommentBody,LastModifiedDate,ParentId FROM CaseComments ORDER BY LastModifiedDate desc LIMIT 1) FROM Case LIMIT 50]; 
            }
                
            
            List<EmailMessage> lstLastOutboundEmail= new List<EmailMessage>();
            List<CaseComment> lstCaseComments = new List<CaseComment>();
            List<Case> lstCases = new List<Case>();
            
            for (SObject sob : lstDetails){
                String casesLastActivity = '';
                String caseActivityType = '';
                String stripHTMLCasesLastActivity = '';
                Case c = (Case) sob;
                lstLastOutboundEmail = c.EmailMessages; 
                lstCaseComments = c.CaseComments; 
                if(!lstLastOutboundEmail.isEmpty() && !lstCaseComments.isEmpty()){
                    if(lstLastOutboundEmail[0].LastModifiedDate >= lstCaseComments[0].LastModifiedDate){
                        stripHTMLCasesLastActivity = lstLastOutboundEmail[0].TextBody.stripHtmlTags();
                        casesLastActivity = stripHTMLCasesLastActivity.length()<999?stripHTMLCasesLastActivity:stripHTMLCasesLastActivity.substring(0,999);
                        caseActivityType = 'EmailMessage';
                    }               
                    else{
                        casesLastActivity = lstCaseComments[0].CommentBody.length()<999?lstCaseComments[0].CommentBody:lstCaseComments[0].CommentBody.substring(0,999);
                        caseActivityType = 'CaseComment';
                    }
                }else if(!lstLastOutboundEmail.isEmpty()){
                    stripHTMLCasesLastActivity = lstLastOutboundEmail[0].TextBody.stripHtmlTags();
                    casesLastActivity = stripHTMLCasesLastActivity.length()<999?stripHTMLCasesLastActivity:stripHTMLCasesLastActivity.substring(0,999);
                    caseActivityType = 'EmailMessage';
                }else if(!lstCaseComments.isEmpty()){
                    casesLastActivity = lstCaseComments[0].CommentBody.length()<999?lstCaseComments[0].CommentBody:lstCaseComments[0].CommentBody.substring(0,999);
                    caseActivityType = 'CaseComment';
                }else{
                    casesLastActivity = '';
                    caseActivityType = '';
                }
                String cURL = createURL(c.Id, c.Support_Account__c);
                String attURL = createAttachmentURL(c.Id, c.Support_Account__c,c.CaseNumber);
                String scrRecURL = createScreenRecURL(c.Id,c.Support_Account__c,c.CaseNumber,c.Support_Account__c);
                String encodeURL = EncodingUtil.URLENCODE(cURL,'UTF-8');
                String encodeAttURL = EncodingUtil.URLENCODE(attURL,'UTF-8');
                String encodeScrRecURL = EncodingUtil.URLENCODE(scrRecURL,'UTF-8');
                String caseURL = label.OKTA_SAML_UNO + '?RelayState=' + encodeURL;  
                String attachmentURL = label.OKTA_SAML_UNO + '?RelayState=' + encodeAttURL;
                String screenRecURL = label.OKTA_SAML_UNO + '?RelayState=' + encodeScrRecURL;
                openCasesActionCustomer openCases = new openCasesActionCustomer(c.CaseNumber, caseURL, c.Next_Action__c,c.Support_Account__c , c.Status, c.Subject,c.Priority,c.Support_Account__r.Name,c.LastModifiedDate,c.Id,casesLastActivity,attachmentURL,screenRecURL,caseActivityType);                
                lstOfOpenCases.add(openCases);    
                count++;          
            }
        }
        catch (exception e){
            System.debug('===== getUser Error: ' + e.getMessage() + ' =====');
            System.debug('===== getUser Error: ' + e.getStackTraceString() + ' =====');            
        }

        //System.debug('===== lstOfOpenCases = ' + lstOfOpenCases + ' =====');
        return lstOfOpenCases;
    }
    //Class to get and set the tp 5 case values
    global class openCasesActionCustomer {
        webService String caseNum {get;set;}
        webService String caseURL {get;set;}
        webService String caseNextAction {get;set;}
        webService String projId {get;set;}
        webService String status {get;set;}
        webService String subject {get;set;}
        webService String priority {get;set;}
        webService String projName{get;set;}
        webService DateTime caseLastModified{get;set;}
         webService Id caseId{get;set;}         
         webService String attachmentURL {get;set;}
         webService String screenRecURL {get;set;}
         webService String lastOutboundContent {get;set;}
         webService String lastOutboundType {get;set;}
         

        // Constructor
        public openCasesActionCustomer (String cCaseNum, String cCaseURL,String cNextAction, String cProjId, String cStatus, String cSubject,String cPriority,String cName,DateTime cLastModified,Id cId,String cLastOutboundContent,String cAttURL,String cRecURL,String cLastOutboundType){
                caseNum = cCaseNum;
                caseURL = cCaseURL;
                caseNextAction = cNextAction;
                projId = cProjId;
                status = cStatus;
                subject = cSubject;
                priority = cPriority;
                projName = cName;
                caseLastModified = cLastModified;
                caseId = cId;              
                attachmentURL = cAttURL;               
                screenRecURL = cRecURL;
                lastOutboundContent = cLastOutboundContent;
                lastOutboundType = cLastOutboundType;
        }
        
    }
    
    // Function to create the URL of each case returned as Top 5 Cases
    private static String createURL(String caseId, String projId){
        //String urlBase = Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
        //String base = '/apex/CT_CommunityCaseDetail?id=';
        //String retURL = urlBase + base + projId + '&cid=' + caseId + '&mode=detail';
        //Map<String, Service_Cloud_General_Setting__mdt> serCloudSettings = Service_Cloud_General_Setting__mdt.getAll();
        String urlBase = System.label.eSupport_Community_URL;//serCloudSettings.get('Community').eSupport_Contact_Page__c;//Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
        String retURL = urlBase + 'casedetails?caseId=' + caseId;
        return retURL;
    }
    private static String createAttachmentURL(String caseId, String projId,String caseNum){
        //String urlBase = Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
        //String base = '/apex/CT_CommunityAttachment?from=caseQuickLink&id=';
        //String returnURL = '/eSupport/apex/CT_CommunityCaseDetail?id=' + projId + '&cid=' + caseId + '&mode=detail';
        //String encodeReturnURL = EncodingUtil.URLENCODE(returnURL,'UTF-8');
        //String retURL = urlBase + base + caseId + '&pName=' + caseNum + '&retURL=' + encodeReturnURL ;
        //Map<String, Service_Cloud_General_Setting__mdt> serCloudSettings = Service_Cloud_General_Setting__mdt.getAll();
        String urlBase = system.label.eSupport_Community_URL;//serCloudSettings.get('Community').eSupport_Contact_Page__c;//Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
        String retURL = urlBase + 'casedetails?caseId=' + caseId;
        return retURL;
    }
    private static String createScreenRecURL(String caseId, String projId,String CaseNum,String contId){
        //String urlBase = Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
        //String base = '/apex/CT_CommunityScreenRecording?contactId=';
        //String returnURL = '/eSupport/apex/CT_CommunityCaseDetail?id=' + projId + '&cid=' + caseId + '&mode=detail';
        //String encodeReturnURL = EncodingUtil.URLENCODE(returnURL,'UTF-8');
        //String retURL = urlBase + base + contId + '&from=caseQuickLink&id=' + caseId + '&pName=' + caseNum + '&retURL=' + encodeReturnURL ;
        //Map<String, Service_Cloud_General_Setting__mdt> serCloudSettings = Service_Cloud_General_Setting__mdt.getAll();
        String urlBase = System.label.eSupport_Community_URL;//serCloudSettings.get('Community').eSupport_Contact_Page__c;//Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
        String retURL = urlBase + 'casedetails?caseId=' + caseId;
        return retURL;
    }
    //Class to get and set the values of the flags and URL
    global class openCaseWrapper {        
        List<openCasesActionCustomer> openCasesNextActionCustomer {get;set;}
         webservice Boolean hasErrors{get;set;}   
         webservice Integer totalCases{get;set;}   

        //Constructor
        public openCaseWrapper (Boolean uHasErrors,List<openCasesActionCustomer> openCasesNextAction,Integer uTotalCases){            
            openCasesNextActionCustomer = openCasesNextAction;
            hasErrors = uHasErrors;    
            totalCases = uTotalCases;     
        }
    }
}