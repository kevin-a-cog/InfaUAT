/*
*@created by       : Anil Sahu
@created on       : 12July21
@Purpose          : Controller class for Case Lightning components -esCaseList
@Description      : fetch all (all support account) the cases tagged to custmer
*/
public with sharing class ManageAlltheCase {
    
    public ManageAlltheCase() {
        
    }
    
    @AuraEnabled(cacheable=true)
    public static UserAccountInfo getSupportAccountInfo(){
        UserAccountInfo accountInfoWrapper = new UserAccountInfo();
        set<id> setSupAccId=new set<id>();
        set<id> setSupAcc=new set<id>();
        for(AccountContactRelation account:caseController.getAllSupportAcc()){
            setSupAcc.add(account.Account.Id);                             
        }
        
        List<Case> openCases = new List<Case>();
        List<Case> allOpenCases = new List<Case>();
        List<Case> allClosedCases = new List<Case>();
        map<id,id> mapcaseId=new map<id,id>();//map to store caseid 
        if(setSupAcc.size()>0){
            //get logged user's contact id.
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() and  ContactId!=null];//get contactid  
            for(Case_Contact__c varCCon:[select id,Contact__c,Case__c,Case__r.Support_Account__c FROM Case_Contact__c where
                                         Contact__c=:currentUser.ContactId and Case__r.Support_Account__c in :setSupAcc
                                         and case__r.isClosed = false]){
                                             mapcaseId.put(varCCon.Case__c,varCCon.Case__c);
                                         }
            //get all the cases
            For(Case caseObj : [SELECT Id, Subject,isClosed,NextAction__c, Support_Account__c,  Support_Account__r.name,Description, CaseNumber, 
                                Priority, Status, RecordType.Name, Forecast_Product__c, CreatedById,Next_Action__c 
                                FROM Case WHERE  Support_Account__c in : setSupAcc  and Is_Internal_Or_External_Case__c != 'Internal' 
                                Order by NextAction__c DESC,Priority DESC NULLS LAST limit 50000]){
                                    if(caseObj.isClosed ){
                                        allClosedCases.add(caseObj);//add closed case
                                    }else{
                                        //check case created by logged-in user
                                        if(caseObj.CreatedById == UserInfo.getUserId()){
                                            openCases.add(caseObj);//bind case created by loggedin user
                                        }else{
                                            if(mapcaseId.size()>0){
                                                if(mapcaseId.get(caseObj.id)!=null){
                                                    openCases.add(caseObj);//bind the  case list tagged to loggedin user
                                                }
                                            }
                                            
                                        }
                                        
                                        // add all the cases assciated with supprt account
                                        allOpenCases.add(caseObj);
                                    }
                                }
            accountInfoWrapper.myOpenCases = openCases;
            accountInfoWrapper.allOpenCases = allOpenCases; 
            accountInfoWrapper.allClosedCases=allClosedCases;
            //getAllFilteredCases('Closed',setSupAcc);// display default closed cases
        }
        System.debug(openCases+' openCases '+allOpenCases+'   allOpenCases '+ allClosedCases);
        return accountInfoWrapper;
    }
    public static List<Case> getAllFilteredCases(string strStatus ,set<string> lstSuppAccIds){
        List<Case>  lstCase=new List<Case> ();
        string strQuert='select id from case ';
        if(strStatus!='')
            strQuert+='where status =:strStatus ';
        if(lstSuppAccIds!=null && lstSuppAccIds.size()>0)
            strQuert+=' and Support_Account__c in :lstSuppAccIds';
        System.debug(' data '+strQuert);
        for(case cs:Database.query(strQuert)){
            lstCase.add(cs);
        }
        return lstCase;
    }
    
    Public class UserAccountInfo{
        @AuraEnabled
        Public List<Case> myOpenCases{get; set;}//list to add all my open cases
        @AuraEnabled
        Public List<Case> allOpenCases{get; set;} //list to add all   open cases
        @AuraEnabled         
        Public List<Case> allClosedCases{get; set;}//list to add all closed cases
    } 
}