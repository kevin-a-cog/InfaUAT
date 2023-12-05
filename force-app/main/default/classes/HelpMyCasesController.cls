public without sharing class HelpMyCasesController {
  
    @AuraEnabled(cacheable=true)
    public static UserAccountInfo getSupportAccountInfoByContact(String contactId, Integer offset){
        Id supportAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
        Set<Id> accountIdsSet = new Set<Id>();
        for(AccountContactRelation acr : [Select Id,AccountId From AccountContactRelation where ContactId = :contactId and Account.RecordTypeId = :supportAccountRTId]){
            accountIdsSet.add(acr.AccountId);
        }
        if(!accountIdsSet.isEmpty()){
            return getSupportAccountInfo(accountIdsSet,offset);
        }else{
            return null;
        }
    }
    
    public static UserAccountInfo getSupportAccountInfo(Set<Id> accountIdsSet, Integer offset){
        
        System.debug('@accountIdsSet- '+accountIdsSet);
        UserAccountInfo accountInfoWrapper = new UserAccountInfo();
        List<Case> openCases = new List<Case>();
        List<Case> allOpenCases = new List<Case>();
        List<Case> allClosedCases = new List<Case>();
        
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() and ContactId!=null];//get contactid
        
        accountInfoWrapper.totalNumberOfRecords = [SELECT COUNT()
                                        FROM Case
                                        WHERE Support_Account__c in :accountIdsSet 
                                        And Is_Internal_Or_External_Case__c != 'Internal'
                                        AND isClosed = false  
                                        AND CreatedById = :UserInfo.getUserId()];
        //get all the cases
        for(Case caseObj : [SELECT Id, Subject, Support_Account__c, Description, CaseNumber,Old_Case_Number__c, isClosed,NextAction__c,
                            Priority, Status, RecordType.Name, Forecast_Product__c,Case_Type__c, CreatedById,Next_Action__c 
                            FROM Case
                            WHERE Support_Account__c in :accountIdsSet 
                            And Is_Internal_Or_External_Case__c != 'Internal'
                            AND isClosed = false  
                            AND CreatedById = :UserInfo.getUserId()
                            Order by NextAction__c   
                            DESC,Priority DESC NULLS LAST LIMIT 5 OFFSET :offset])
        {
            openCases.add(caseObj);//bind case created by loggedin user
        }
        
        accountInfoWrapper.myOpenCases = openCases;
        return accountInfoWrapper;
    }
    
    
    //get Support Accounts where the Contact has ReadWrite Access to display on eSupport CaseCreation
    @AuraEnabled
    public static list<AccountContactRelation> getSupportAccWithRWAccess(){
        //update all ACR record
        list<AccountContactRelation> lstACR=new list<AccountContactRelation>();
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<User> userContact = [SELECT Id, ContactId, Contact.AccountId FROM USER WHERE Id =: UserInfo.getUserId()and ContactId!=null];      
        for(AccountContactRelation account: [SELECT Id, Account.Name,favorite__c, Account.End_Date__c FROM AccountContactRelation 
                                             WHERE Account.RecordTypeId=: SupportAccountRecType AND Account.Active__c = true
                                             AND ContactId =: userContact[0].ContactId AND Access_Level__c = 'Read/Write'  Order By  favorite__c  desc,Account.Name asc]){
                                                 if(account.Account.End_Date__c!=null){
                                                     if(system.today() <=  account.Account.End_Date__c.addDays(10)){
                                                         lstACR.add(account);  
                                                     }
                                                 }
                                                 
                                             }
        System.debug(' all suppo '+lstACR);
        return lstACR; 
    }

    Public class UserAccountInfo{
        @AuraEnabled
        Public List<Case> myOpenCases{get; set;}
        @AuraEnabled
        Public List<Case> allOpenCases{get; set;}
        @AuraEnabled
        Public Integer totalNumberOfRecords{get; set;}
    }
}