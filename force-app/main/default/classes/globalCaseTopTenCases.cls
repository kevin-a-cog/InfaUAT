@RestResource(urlMapping='/globalTopTenCases')
global without sharing class globalCaseTopTenCases{

    private static Id uId = UserInfo.getUserId();

    
    //Get the data from the custom setting "Support Level Setting"
    //private static Map<String, Support_Level_Settings__c> mapSupportLevelToSettings = Support_Level_Settings__c.getAll();

    @HttpGet
    global static topFiveCaseWrapper userTopFiveCases() {
        
        Boolean errors = false;
        
        List<AccountContactRelation> projContact = new List<AccountContactRelation>();
        List<topFiveCases> getTopFiveList = new List<topFiveCases>();
        try{

            // Get the user details based on the User Id
            List<User> selectedUser = new List<User>([SELECT Id, Name, ContactId, isActive,UserName FROM User WHERE Id= :uId AND IsActive = true Limit 1]);

            if (selectedUser!= null && !selectedUser.isEmpty()){

                User selectedUserId = selectedUser[0];

                //System.debug('===== selectedUser = ' + selectedUserId + ' =====');

                if (selectedUserId != null && selectedUserId.IsActive == true){
                    // Get the Project Contact details of the selected user
                    //-------------------------------------------------------------<T01>
                    //replaced the field Support_Level_Rank__c with Support_Level__c in the SOQL
                    projContact = [SELECT Id, contact.Name, Accountid, account.Entitlement__r.EndDate, account.Entitlement__r.Status, account.Entitlement__r.Support_Level__c FROM AccountContactRelation WHERE contactId =: selectedUserId.contactId and account.RecordType.name = 'Support Account' AND IsActive = true];
                    //projContact = [SELECT Id, Name, Account, Account.Entitlement__r.EndDate, account.Entitlement__r.Status, account.Project__r.Entitlement__r.Support_Level__c FROM Project_Contact__c WHERE Contact__c = :selectedUserId.ContactId AND Status__c = 'Active'];
                    
                    //-------------------------------------------------------------</T01>
                    System.debug('===== projContact contains ' + projContact.size() + ' =====');
                }

               /* if (projContact!= null && !projContact.isEmpty()){                    
                    for (Account  contact :projContact){
                        //Add the code to return all the Project of the user is tagged
                    }
                }*/
                // Call  the method to get the Top 5 Cases
                getTopFiveList=getTopFiveCases(projContact);
            }
        }
        catch (exception e){
            System.debug('===== Error: ' + e.getMessage() + ' =====');
            errors = true;
        }

        topFiveCaseWrapper uc = new topFiveCaseWrapper(errors,getTopFiveList);
        return uc;
    }
    
    //Function to check if the entitlement is active using the EndDate and Status
    global static Boolean checkProjStatus(AccountContactRelation cont){
        if(cont!=null && cont.account.Entitlement__c!=null &&cont.account.Entitlement__r.EndDate!=null && cont.account.Entitlement__r.Status!=null){
            if (cont.account.Entitlement__r.EndDate >= Date.today() && cont.account.Entitlement__r.Status == 'Active'){
                return True;
            }
        }
        return false;
    }
    
    //Method to get the 5 cases
    global static List<topFiveCases> getTopFiveCases(List<AccountContactRelation> projectContact){
        List<topFiveCases> topFiveList = new List<topFiveCases>();

        try{

            Map<String, String> projAndProjConIds = new Map<String, String>();

            //Set<String> setProjIds = new Set<String>();
            //Set<String> setProjConIds = new Set<String>();
            for (AccountContactRelation con :projectContact){
                // Create a map with the only the active project details so as to get only the cases related to active projects
                if (checkProjStatus(con)){
                    projAndProjConIds.put(con.accountId,con.ContactId);
                    //setProjIds.add(con.Project__c);
                    //setProjConIds.add(con.Id);
                }
            }

            //String EscalationRT=Label.Escalation_Record_Type;
            //String CollaborationRT=Label.Collaboration_Record_Type;
            // Query for the Cases from the active projects of particular Project Contact and excluding the COllaboration
            // and Escalation cases with last modified data in descending order caseand priority ascending order

            for (Case c :[SELECT Id, Account.Name,support_account__r.name, support_account__c,AccountId, CaseNumber,  LastModifiedDate, Status, Subject ,Priority FROM Case WHERE Status != 'Closed' AND Status != 'Resolved' AND (NOT Record_Type_Name__c LIKE 'Collaboration%')  AND Support_Account__c In :projAndProjConIds.keyset() and ContactId In :projAndProjConIds.values()  Order by LastModifiedDate desc, Priority asc Limit 10]){
                //Create a URl so that on click of the case number user is redirected to eSupport
                String cURL = createURL(c.Id, c.support_account__c);
                String encodeURL = EncodingUtil.URLENCODE(cURL,'UTF-8');
                String URL = label.OKTA_SAML_UNO + '?RelayState=' + encodeURL;
                topFiveCases topFive = new topFiveCases(c.CaseNumber, URL, c.support_account__c, c.Status, c.Subject,c.Priority,c.support_account__r.name);

                topFiveList.add(topFive);
            }
        }
        catch (exception e){
            System.debug('===== getUser Error: ' + e.getMessage() + ' =====');
        }

        //System.debug('===== topFiveList = ' + topFiveList + ' =====');
        return topFiveList;
    }
    //Class to get and set the tp 5 case values
    global class topFiveCases {
        webService String caseNum {get;set;}
        webService String caseURL {get;set;}
        webService String projId {get;set;}
        webService String status {get;set;}
        webService String subject {get;set;}
        webService String priority {get;set;}
        webService String projName{get;set;}

        // Constructor
        public topFiveCases(String cCaseNum, String cCaseURL, String cProjId, String cStatus, String cSubject,String cPriority,String cName){
                caseNum = cCaseNum;
                caseURL = cCaseURL;
                projId = cProjId;
                status = cStatus;
                subject = cSubject;
                priority = cPriority;
                projName = cName;
        }
    }


    // Function to create the URL of each case returned as Top 5 Cases
    private static String createURL(String caseId, String projId){
        //Map<String, Service_Cloud_General_Setting__mdt> serCloudSettings = Service_Cloud_General_Setting__mdt.getAll();
        String urlBase = System.label.eSupport_Community_URL;//Informatica_Settings__c.getValues('CommunityBaseURL').Values__c;
       // String base = '/apex/CT_CommunityCaseDetail?id=';
        //String retURL = urlBase + base + projId + '&cid=' + caseId + '&mode=detail';
        String retURL = urlBase + 'casedetails?caseId=' + caseId;
        return retURL;
    }
    //Class to get and set the values of the flags and URL
    global class topFiveCaseWrapper{        
        List<topFiveCases> topFiveCaseList {get;set;}
         webservice Boolean hasErrors{get;set;}

        //Constructor
        public topFiveCaseWrapper(Boolean uHasErrors,List<topFiveCases> utopFiveCaseList){            
            topFiveCaseList = utopFiveCaseList;
            hasErrors = uHasErrors;
        }
    }
}