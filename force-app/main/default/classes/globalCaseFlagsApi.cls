/*
Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.        Description                                                 Tag
*********************************************************************************************************************
NA             NA               UTOPIA          Initial version.                                            NA
Amit Garg      05/01/2022       I2RT-5226       Check Entitlement Status on Support Account                 T01
*/

@RestResource(urlMapping='/globalCaseFlags')
global without sharing class globalCaseFlagsApi{

    private static Id uId = UserInfo.getUserId();
    //Get the data from the custom setting "Support Level Setting"
    //private static Map<String, Support_Level_Settings__c> mapSupportLevelToSettings = Support_Level_Settings__c.getAll();
    
    @HttpGet
    global static userCheck checkUser() {

        //String uName = RestContext.request.params.get('Username');
        //Id uId=UserInfo.getUserId();
        //System.debug('-----'+uId);
        Boolean activeUser = false;
        Boolean eLearningActive = false;
        Boolean errors = false;
        Boolean hotFix = false;

        List<AccountContactRelation > projContact = new List<AccountContactRelation>();
        List<userProjects> lstAllProjects = new List<userProjects>();
        
        try{

            // Get the user details based on the User Id
            List<User> selectedUser = new List<User>([SELECT Id, Name, ContactId, isActive,UserName FROM User WHERE Id= :uId AND IsActive = true Limit 1]);

            if (selectedUser!= null && !selectedUser.isEmpty()){

                User selectedUserId = selectedUser[0];

                //System.debug('===== selectedUser = ' + selectedUserId + ' =====');

                if (selectedUserId != null && selectedUserId.IsActive == true){
                    // Get the Project Contact details of the selected user                  
                    projContact = [SELECT Id, contact.Name,Access_Level__c, Accountid,account.name, account.Entitlement__r.EndDate, account.Entitlement__r.Status,account.Support_Account_Status__c, account.Entitlement__r.Support_Level__c FROM AccountContactRelation WHERE contactId =: selectedUserId.contactId and account.RecordType.name = 'Support Account' AND IsActive = true];//<T01>
                    System.debug('===== projContact contains ' + projContact.size() + ' =====');
                }

                if (projContact!= null && !projContact.isEmpty()){
                    activeUser = true;
                    for (AccountContactRelation contact :projContact){

                        //Check if the Project is active using the Entitlements End Date and Entitlement Status
                        if(!hotFix)
                          hotFix = checkProjStatus(contact) ? True : False ;

                        // Check if he has access to the eLearning using the Support Level Rank
                        if(!eLearningActive)
                          eLearningActive = checkElearningStatus(contact) ? True : False ;

                        if(hotFix && eLearningActive) Break;
                    }
                } 
                if (projContact!= null && !projContact.isEmpty()){                    
                    for (AccountContactRelation  cont :projContact){
                        if(cont.accountid !=null && cont.account.Entitlement__c!=null &&cont.account.Entitlement__r.EndDate!=null && cont.account.Support_Account_Status__c!=null){//<T01>
                            if (cont.account.Entitlement__r.EndDate >= Date.today() && cont.account.Support_Account_Status__c == 'Active'){//<T01>
                                userProjects projectsDetails = new userProjects(cont.accountId,cont.account.Name,cont.Access_Level__c,cont.contactId);
                                lstAllProjects.add(projectsDetails);
                            }
                        }
                    }
                }               
            }
        }
        catch (exception e){ errors = true;
        }

        userCheck uc = new userCheck(activeUser,eLearningActive,errors,hotFix,lstAllProjects);
        return uc;
    }
     //Function to check if the entitlement is active using the EndDate and Status
    global static Boolean checkProjStatus(AccountContactRelation cont){
        if(cont.accountId!=null && cont.account.Entitlement__c!=null &&cont.account.Entitlement__r.EndDate!=null && cont.account.Support_Account_Status__c!=null){//<T01>
            if (cont.account.Entitlement__r.EndDate >= Date.today() && cont.account.Support_Account_Status__c == 'Active'){ return True;//<T01>
            }
        }
        return false;
    }
    //Function to check if the eLearning is enabled for the user using the Support Level field
    global static Boolean checkElearningStatus(AccountContactRelation cont){        
        //replaced the field Support_Level_Rank__c with Support_Level__c
        if(cont!=null && cont.account.Entitlement__c!=null &&cont.account.Entitlement__r.Support_Level__c!=null){        
            //Get the information if elearning is enabled from the custom setting for the support level of the Contact Project Entitlement
           // Support_Level_Settings__c setting = mapSupportLevelToSettings.get(cont.Project__r.Entitlement__r.Support_Level__c);
            //if (setting != null){
             //   return setting.eLearning__c;
            //}
            return true;            
        }
        return false;
    }
    global class userProjects {
        webService String projId {get;set;}
        webService String projName{get;set;}
        webService String projContPermission{get;set;}
        webService String projContId{get;set;}
        public userProjects (String cProjId, String cProjName,String cProjContPermission,String cProjContId)
        {
            projId = cProjId;  projName = cProjName;
            projContPermission = cProjContPermission;
            projContId = cProjContId;
        }
    }
    //Class to get and set the values of the flags and URL
    global class userCheck{
        webservice Boolean userCheck{get;set;}
        webservice Boolean eLearningCheck{get;set;}
        webservice Boolean hasErrors{get;set;}
        webservice Boolean hotFixCheck{get;set;}         
        List<userProjects> userAllProjects{get;set;}       

        //Constructor
        public userCheck(Boolean uCheck,Boolean uElearningCheck,Boolean uHasErrors,Boolean uHotFixCheck,List<userProjects> uProjects){
            userAllProjects = uProjects;
            userCheck = uCheck;
            eLearningCheck = uElearningCheck;
            hasErrors = uHasErrors;
            hotFixCheck = uHotFixCheck;                       
        }
    }
    
}