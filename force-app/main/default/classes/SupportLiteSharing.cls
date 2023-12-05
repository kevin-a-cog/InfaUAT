/*
 * Name         :   SupportLiteSharing
 * Author       :   Vignesh Divakaran
 * Created Date :   8/30/2022
 * Description  :   Utility class to validate user access for all Support Lite functionalities.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      8/30/2022       I2RT-6872       Initial version.            N/A
 */
public without sharing class SupportLiteSharing {

    public static final String CASE_LITE_RECORDTYPE = 'Case_Lite';
    public static final String ECOMMERCE_ACCOUNT_RECORDTYPE = 'eCommerce';
    
    /*
     Method Name : validateUserAccess
     Description : This method routes access check based on the object.
     Parameters  : String, called from getEventDetails, strRecordId Record Id.
     Return Type : List of Picklist Entries.
     */
    public static Boolean validateUserAccess(String strObjectName, String strAccessType, String strRecordId){
        if(strObjectName == 'Case')
            return caseAccess(strAccessType, strRecordId);
        if(strObjectName == 'Account')
            return accountAccess(strAccessType, strRecordId);
        if(strObjectName == 'Contact')
            return isReadWriteContact(strRecordId);
        return false;
    }

    /*
     Method Name : caseAccess
     Description : This method routes case access check based on the CRUD access type.
     Parameters  : (String, String), called from validateUserAccess, strAccessType & strRecordId.
     Return Type : Boolean
     */
    private static Boolean caseAccess(String strAccessType, String strRecordId){
        switch on strAccessType{
            when 'CREATE'{
                return caseCreateAccess(strRecordId);
            }
            when 'READ'{
                return caseReadAccess(strRecordId);
            }
            when else{
                return false;
            }
        }
    }

    /*
     Method Name : caseCreateAccess
     Description : This method validates user's access to create a case nad returns true, 
                   if the org is active for support and the contact associated to the org's account is R/W.
     Parameters  : String, called from caseAccess, strOrgUUID Org UUID.
     Return Type : Boolean
     */
    private static Boolean caseCreateAccess(String strOrgUUID){
        Org__c objOrg = getOrg(strOrgUUID);
        if(objOrg?.Support_Lite__c && isReadWriteContact(objOrg?.Account__c)){
            return true;
        }
        return false;
    }

    /*
     Method Name : caseReadAccess
     Description : This method validates user's access to view a case and returns true, 
                   if the org associated to the case is active for support and 
                   the community user contact associated to the org's account is R/W.
     Parameters  : String, called from caseAccess, strCaseId record id.
     Return Type : Boolean
     */
    private static Boolean caseReadAccess(String strCaseId){
        Case objCase = [SELECT Org__c,Org__r.Support_Lite__c,Org__r.Account__c FROM Case WHERE Id =: strCaseId AND RecordType.DeveloperName =: CASE_LITE_RECORDTYPE LIMIT 1];
        if(objCase?.Org__r?.Support_Lite__c && isReadWriteContact(objCase?.Org__r.Account__c)){
            return true;
        }
        return false;
    }

    /*
     Method Name : accountAccess
     Description : This method routes account access check based on the CRUD access type.
     Parameters  : (String, String), called from validateUserAccess, strAccessType & strOrgUUID.
     Return Type : Boolean
     */
    private static Boolean accountAccess(String strAccessType, String strOrgUUID){
        switch on strAccessType{
            when 'READ'{
                return accountReadAccess(strOrgUUID);
            }
            when else{
                return false;
            }
        }
    }

    /*
     Method Name : accountReadAccess
     Description : This method validates user's access to view an account and returns true, 
                   if the org associated to the account is active for support and 
                   the community user contact associated to the org's account is R/W.
     Parameters  : String, called from accountAccess, strOrgUUID Org UUID.
     Return Type : Boolean
     */
    private static Boolean accountReadAccess(String strOrgUUID){
        Org__c objOrg = getOrg(strOrgUUID);
        if(objOrg?.Support_Lite__c && isReadWriteContact(objOrg?.Account__c)){
            return true;
        }
        return false;
    }

    /*
     Method Name : getOrg
     Description : This method returns the org record based on the given orgUUID.
     Parameters  : String, called from caseCreateAccess, strOrgUUID Org UUID.
     Return Type : Boolean
     */
    private static Org__c getOrg(String strOrgUUID){
        Org__c objOrg = new Org__c();
        for(Org__c objOrgQueried : [SELECT Id,Account__c,Support_Lite__c FROM Org__c WHERE Id IN (SELECT Org__c FROM Org_User__c WHERE Contact__c =: GlobalUtility.getCommunityUserContactId()) AND OrgID__c =: strOrgUUID]){
            objOrg = objOrgQueried;
        }
        return objOrg;
    }

    /*
     Method Name : isReadWriteContact
     Description : This method validates community user's contact R/W access to the given account.
     Parameters  : Id, called from caseCreateAccess & caseReadAccess, accountId record id.
     Return Type : Boolean
     */
    private static Boolean isReadWriteContact(Id accountId){
        return [SELECT Id FROM AccountContactRelation WHERE AccountId =: accountId AND Access_Level__c = 'Read/Write' AND ContactId =: GlobalUtility.getCommunityUserContactId() AND Account.RecordType.DeveloperName =: ECOMMERCE_ACCOUNT_RECORDTYPE LIMIT 1]?.Id != null ? true : false;
    }
}