/**************************************************************************************
* Apex Class Name     : ApexSharingUtility
* Version             : 1.0 
* Created Date        : 14 December 2017
* Function            : This class is a Apex sharing utility.
* Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 

  Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                        Tag
Kiran G           12-Oct-2018   Richard L       Created 2 new generic methods to enable 
                                                sharing for internal(PSM & FSR) users    T01
Kiran G           28-Aug-2019   PrasanthG       Replace OOB PartnerAccountId field to
                                                Lookup Partner_Account__c                 T02                               
******************************************************************

*************************************************************************************/
public class ApexSharingUtility {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /**************************************************
        *Method Name: enablesharingForPartnerUsers
        *Description: This method enables share by inserting share records
        *Date: 14 Dec 2017
     ***************************************************/
    public Static void enablesharingForPartnerUsers(Map <id, List<User>> shareMap , String shareobjectName , String AccessLevel){
        GAM.CreateLogs('Entered method: enablesharingForPartnerUsers','ApexClass:ApexSharingUtility');            
        List<sObject> shareRecLst = new List<sObject>();
        Map<String,Schema.SObjectType> shareobjMap = Schema.getGlobalDescribe();
        Schema.SObjectType shareobj = shareobjMap.get(shareobjectName); 
        Sobject shareobjInstance; 
        for(ID i : shareMap.keyset()){
            for(User u : shareMap.get(i)){
                shareobjInstance = shareobj.newSObject(); 
                shareobjInstance.put('userorgroupid' , u.id);
                if(shareobjectName == label.PRM_Oppty_Share){
                    shareobjInstance.put('Opportunityid' , i);
                    shareobjInstance.put('OpportunityAccessLevel' , AccessLevel);
                }
                else if(shareobjectName == label.PRM_Lead_Share)
                {
                    shareobjInstance.put('Leadid' , i);
                    shareobjInstance.put('LeadAccessLevel' , AccessLevel);
                }
                else{
                    shareobjInstance.put('parentid' , i);
                    shareobjInstance.put('AccessLevel' , AccessLevel);
                }
                    
                shareRecLst.add(shareobjInstance);
            }
        }
        system.debug('insert shareRecLst: '+shareRecLst);
        GAM.CreateLogs('This is a check shareRecList@@@@@@' + shareRecLst,'ApexClass:ApexSharingUtility');            
        //checking if the shareRecList is empty
        if(!shareRecLst.isEmpty())
        {
            try
            {
                insert shareRecLst ;
            }
        
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('Error while inserting share object list','ApexClass:ApexSharingUtility, method: enablesharingForPartnerUsers');            
            }
            
        }
    }


    /**************************************************
        *Method Name: disablesharingForPartnerUsers
        *Description: This method disables share by deleting Share records
        *Date: 20 Dec 2017
      ***************************************************/
        public Static void disablesharingForPartnerUsers(Map< ID , ID >  shareMap , String shareobjectName){
        GAM.CreateLogs('Entered method: disablesharingForPartnerUsers','ApexClass:ApexSharingUtility');            
        Set<ID> userId = new Set<ID>();
        Set<ID> recID  = new Set<ID>();
                recID  = shareMap.keySet();
        //looping over Users
        for(User u : [select Id , contact.accountid  from user where contact.accountid IN :shareMap.values() AND IsActive  = True]){
            userId.add(u.id);
        }
         String queryVar;
         if(shareobjectName==label.PRM_Oppty_Share){
            queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE Opportunityid IN:recID  AND UserOrGroupId IN:userId';
         }
         else if(shareobjectName==label.PRM_Lead_Share)
         {
             queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE Leadid IN:recID  AND UserOrGroupId IN:userId';
         }
         else{
             queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE ParentId IN:recID  AND UserOrGroupId IN:userId';
         }
         //Querying share records
         List<sObject> oldshareRecLst = Database.query(queryVar);
         system.debug('oldshareRecLst: '+oldshareRecLst);
         GAM.CreateLogs('This is a oldshareRecLst@@@@@@' + oldshareRecLst,'ApexClass:ApexSharingUtility');            
         //checking if oldshareRecLst is not empty;
         if(!oldshareRecLst.isEmpty())
         {
            try
            {
                delete oldshareRecLst ;
            }
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('Error while deleting share object list','ApexClass:ApexSharingUtility, method: disablesharingForPartnerUsers');            
            }
         }
    }


    /**************************************************
        *Method Name: disablesharingForInactiveUsers
        *Description: This method disables sharing if user is inactivated
        *Date: 20 Dec 2017
      ***************************************************/
        @future
        public Static void disablesharingForInactiveUsers(List<id> shareUserList){
        GAM.CreateLogs('Entered method: disablesharingForInactiveUsers','ApexClass:ApexSharingUtility');            
         
         string shareobjectName;
         List<sObject> finalListtoDelete = new List<sObject>();
         string rowCause='Manual';
         String queryVar;
         List<sObject> oldshareRecLst;
         
         //Delete share records for Deal Registration
         /*shareobjectName = label.PRM_DR_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }*/
         
         //Delete share records for Project Registration
         shareobjectName = label.PRM_ProjectReg_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }
         
         //Delete share records for Engagement
         shareobjectName = label.PRM_Engagement_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }
         
         //Delete share records for Opportunity
         shareobjectName = label.PRM_Oppty_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }
         
         //Delete share records for Partner Distributor
         shareobjectName = label.PRM_ParnterDisti_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }
         
         //Delete share records for Lead
         shareobjectName = label.PRM_Lead_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }
         
         GAM.CreateLogs('This is a finalListtoDelete@@@@@@' + finalListtoDelete,'ApexClass:ApexSharingUtility');            
         //checking if oldshareRecLst is not empty;
         if(!finalListtoDelete.isEmpty())
         {
            try
            {
                delete finalListtoDelete ;
            }
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('Error while deleting share object list','ApexClass:ApexSharingUtility, method: disablesharingForInactiveUsers');            
            }
         }
    }
    
    
    /**************************************************
        *Method Name: enablesharingForActiveUsers
        *Description: This method enables sharing for Active users.
        *Date: 20 Dec 2017
      ***************************************************/
        @future
        public Static void enablesharingForActiveUsers(List<id> shareUserList){
        GAM.CreateLogs('Entered method: enablesharingForActiveUsers','ApexClass:ApexSharingUtility');            
        
        //Map of Acc Id and list of users
        Map<Id,List<User>> accWiseUsersMap = new Map<Id,List<User>>();
        List<User> userList = new List<User>();
        system.debug('shareUserList: '+shareUserList);
        //Fetch all related accounts of users and populate accWiseUsersMap
        for(User u: ([select contact.accountid from user where Id IN : shareUserList and contact.Is_Active__c = TRUE]))
        {
            system.debug('user: '+u);
            if(null == accWiseUsersMap.get(u.contact.accountid))
            {
                userList = new List<User>();
                userList.add(u);
                accWiseUsersMap.put(u.contact.accountid,userList);
            }
            else
            {
                userList = accWiseUsersMap.get(u.contact.accountid);
                userList.add(u);
                accWiseUsersMap.put(u.contact.accountid,userList);
            }
            system.debug('accWiseUsersMap: '+accWiseUsersMap);
        }
        //Map of DR Id and list of users
        //Map<Id,List<User>> drWiseUsersMap = new Map<Id,List<User>>();
        List<User> finalUserList;
        
        //Map of PR Id and list of users
        Map<Id,List<User>> prWiseUsersMap = new Map<Id,List<User>>();
        
        //Map of Engagement Id and list of users
        Map<Id,List<User>> engWiseUsersMap = new Map<Id,List<User>>();
        
        
        Map<Id,List<User>> oppWiseUsersMap = new Map<Id,List<User>>();
        
        Map<Id,List<User>> pdWiseUsersMap = new Map<Id,List<User>>();
        
        //Map of Lead Id and list of users
        Map<Id,List<User>> leadWiseUsersMap = new Map<Id,List<User>>();
        
        if(!accWiseUsersMap.isEmpty())
        {
            //Fetch all DR that have accounts fetched from above
            /*for (Deal_Registration__c dr: [select Id,DEV_RelatedPartnerId__c,Distributor__c,Reseller__c from Deal_Registration__c where (DEV_RelatedPartnerId__c IN :accWiseUsersMap.keySet() OR Distributor__c IN :accWiseUsersMap.keySet() OR Reseller__c IN :accWiseUsersMap.keySet()) AND OwnerId NOT IN :shareUserList])
            {
                //Populate drWiseUsersMap with DR id and related user of all fetched accounts
                finalUserList = new List<User>();
                if(null != dr.DEV_RelatedPartnerId__c && null != accWiseUsersMap.get(dr.DEV_RelatedPartnerId__c))
                {
                    finalUserList.addAll(accWiseUsersMap.get(dr.DEV_RelatedPartnerId__c));
                }
                if(null != dr.Distributor__c && null != accWiseUsersMap.get(dr.Distributor__c))
                {
                    finalUserList.addAll(accWiseUsersMap.get(dr.Distributor__c));
                }
                if(null != dr.Reseller__c && null != accWiseUsersMap.get(dr.Reseller__c))
                {
                    finalUserList.addAll(accWiseUsersMap.get(dr.Reseller__c));
                }
                
                drWiseUsersMap.put(dr.Id,finalUserList);
            }
            enablesharingForPartnerUsers(drWiseUsersMap, label.PRM_DR_Share, 'Edit');*/
            
            //Fetch all Project Registrations that have accounts fetched from above
            for (Project_Registration__c pr: [select Id,Partner_Account__c from Project_Registration__c where Partner_Account__c IN :accWiseUsersMap.keySet() AND OwnerId NOT IN :shareUserList])
            {
                system.debug('pr: '+pr);
                if(null != pr.Partner_Account__c && null != accWiseUsersMap.get(pr.Partner_Account__c))
                {
                    prWiseUsersMap.put(pr.Id,accWiseUsersMap.get(pr.Partner_Account__c));
                }
            }
            system.debug('prWiseUsersMap: '+prWiseUsersMap);
            enablesharingForPartnerUsers(prWiseUsersMap, label.PRM_ProjectReg_Share, 'Edit');
            
            //Fetch all Engagements that have accounts fetched from above
            for (Engagement__c eng: [select Id,Account__c from Engagement__c where Account__c IN :accWiseUsersMap.keySet() AND OwnerId NOT IN :shareUserList])
            {
                if(null != eng.Account__c && null != accWiseUsersMap.get(eng.Account__c))
                {
                    engWiseUsersMap.put(eng.Id,accWiseUsersMap.get(eng.Account__c));
                }
            }
            enablesharingForPartnerUsers(engWiseUsersMap, label.PRM_Engagement_Share, 'Edit');
            
            //Fetch all Opportunities that have accounts fetched from above
            for(Partner_Relationship__c oPartnerRelationship:[select id,Opportunity__c,Partner_Account__c from Partner_Relationship__c where    Partner_Account__c in :accWiseUsersMap.keySet() and Opportunity__r.OwnerId NOT IN :shareUserList]){
                if(oPartnerRelationship.Opportunity__c!=null){
                    list<User> lstTempUsers = new list<User>();
                    if(oppWiseUsersMap.containsKey(oPartnerRelationship.Opportunity__c)){
                        lstTempUsers = oppWiseUsersMap.get(oPartnerRelationship.Opportunity__c);
                    }
                    lstTempUsers.addAll(accWiseUsersMap.get(oPartnerRelationship.Partner_Account__c));
                    oppWiseUsersMap.put(oPartnerRelationship.Opportunity__c,lstTempUsers);
                }
            }
            enablesharingForPartnerUsers(oppWiseUsersMap, label.PRM_Oppty_Share, 'Read');
            
            //Fetch all Partner Distributor that have accounts fetched from above
            for(Partner_Distributor__c oPartnerDistributor:[Select id,Distributor__c,Reseller_Account__c From Partner_Distributor__c Where OwnerId NOT IN :shareUserList and (Distributor__c in :accWiseUsersMap.keySet() or Reseller_Account__c in : accWiseUsersMap.keySet())]){
                list<User> lstTempUsers = new list<User>();
                if(oPartnerDistributor.Distributor__c!=null && accWiseUsersMap.containsKey(oPartnerDistributor.Distributor__c)){
                    lstTempUsers.addAll(accWiseUsersMap.get(oPartnerDistributor.Distributor__c));
                }
                if(oPartnerDistributor.Reseller_Account__c!=null && accWiseUsersMap.containsKey(oPartnerDistributor.Reseller_Account__c)){
                    lstTempUsers.addAll(accWiseUsersMap.get(oPartnerDistributor.Reseller_Account__c));
                }
                pdWiseUsersMap.put(oPartnerDistributor.Id,lstTempUsers);
            }
            enablesharingForPartnerUsers(pdWiseUsersMap, label.PRM_ParnterDisti_Share, 'Read'); 
            
            //For Leads, check if contact has View_All_Deal_Registrations__c set as True
            //Map of Acc Id and list of users
            Map<Id,List<User>> accWiseUsersLeadMap = new Map<Id,List<User>>();
            List<User> userLeadList = new List<User>();
            system.debug('shareUserList: '+shareUserList);
            //Fetch all related accounts of users and populate accWiseUsersLeadMap
            for(User u: ([select contact.accountid from user where Id IN : shareUserList and contact.Is_Active__c = TRUE and contact.View_All_Deal_Registrations__c = TRUE]))
            {
                system.debug('user: '+u);
                if(null == accWiseUsersLeadMap.get(u.contact.accountid))
                {
                    userLeadList = new List<User>();
                    userLeadList.add(u);
                    accWiseUsersLeadMap.put(u.contact.accountid,userLeadList);
                }
                else
                {
                    userLeadList = accWiseUsersLeadMap.get(u.contact.accountid);
                    userLeadList.add(u);
                    accWiseUsersLeadMap.put(u.contact.accountid,userLeadList);
                }
                system.debug('accWiseUsersLeadMap: '+accWiseUsersLeadMap);
            }
            
            //T02 Replaced PartnerAccoutId with Partner_Account__c 
            //Fetch all Leads that have accounts fetched from above
            for (Lead lead: [select Id,Distributor__c,Reseller_SI_Partner__c,Partner_Account__c from Lead where (Distributor__c IN :accWiseUsersLeadMap.keySet() OR Reseller_SI_Partner__c IN :accWiseUsersLeadMap.keySet() OR Partner_Account__c IN :accWiseUsersLeadMap.keySet()) AND OwnerId NOT IN :shareUserList])
            {
                //Populate leadWiseUsersMap with Lead id and related user of all fetched accounts
                finalUserList = new List<User>();
                if(null != lead.Partner_Account__c && null != accWiseUsersLeadMap.get(lead.Partner_Account__c))
                {
                    finalUserList.addAll(accWiseUsersLeadMap.get(lead.Partner_Account__c));
                }
                if(null != lead.Distributor__c && null != accWiseUsersLeadMap.get(lead.Distributor__c))
                {
                    finalUserList.addAll(accWiseUsersLeadMap.get(lead.Distributor__c));
                }
                if(null != lead.Reseller_SI_Partner__c && null != accWiseUsersLeadMap.get(lead.Reseller_SI_Partner__c))
                {
                    finalUserList.addAll(accWiseUsersLeadMap.get(lead.Reseller_SI_Partner__c));
                }
                
                leadWiseUsersMap.put(lead.Id,finalUserList);
            }
            enablesharingForPartnerUsers(leadWiseUsersMap, label.PRM_Lead_Share, 'Edit');
        }
    }
    
    /**************************************************
    *Method Name: enableDRsharingForActiveUsers
    *Description: This method enables sharing of Deal Registration 
    ** on the basis of field: View_All_Deal_Registrations__c for Active users.
    *Date: 22 March 2018
    ***************************************************/
    @future
    public Static void enableDRsharingForActiveUsers(List<id> shareUserList){
        GAM.CreateLogs('Entered method: enableDRsharingForActiveUsers','ApexClass:ApexSharingUtility'); 
        system.debug('shareUserList:: '+shareUserList);
        
        //For Leads, check if contact has View_All_Deal_Registrations__c set as True
        //Map of Acc Id and list of users
        Map<Id,List<User>> accWiseUsersLeadMap = new Map<Id,List<User>>();
        List<User> userLeadList = new List<User>();
        List<User> finalUserList;
        //Map of Lead Id and list of users
        Map<Id,List<User>> leadWiseUsersMap = new Map<Id,List<User>>();
        system.debug('shareUserList: '+shareUserList);
        //Fetch all related accounts of users and populate accWiseUsersLeadMap
        for(User u: ([select contact.accountid from user where Id IN : shareUserList and contact.Is_Active__c = TRUE and contact.View_All_Deal_Registrations__c = TRUE]))
        {
            system.debug('user: '+u);
            if(null == accWiseUsersLeadMap.get(u.contact.accountid))
            {
                userLeadList = new List<User>();
                userLeadList.add(u);
                accWiseUsersLeadMap.put(u.contact.accountid,userLeadList);
            }
            else
            {
                userLeadList = accWiseUsersLeadMap.get(u.contact.accountid);
                userLeadList.add(u);
                accWiseUsersLeadMap.put(u.contact.accountid,userLeadList);
            }
            system.debug('accWiseUsersLeadMap: '+accWiseUsersLeadMap);
        }
        
        //T02 Replaced PartnerAccoutId with Partner_Account__c 
        //Fetch all Leads that have accounts fetched from above
        for (Lead lead: [select Id,Distributor__c,Reseller_SI_Partner__c,Partner_Account__c from Lead where (Distributor__c IN :accWiseUsersLeadMap.keySet() OR Reseller_SI_Partner__c IN :accWiseUsersLeadMap.keySet() OR Partner_Account__c IN :accWiseUsersLeadMap.keySet()) AND OwnerId NOT IN :shareUserList])
        {
            //Populate leadWiseUsersMap with Lead id and related user of all fetched accounts
            finalUserList = new List<User>();
            if(null != lead.Partner_Account__c && null != accWiseUsersLeadMap.get(lead.Partner_Account__c))
            {
                finalUserList.addAll(accWiseUsersLeadMap.get(lead.Partner_Account__c));
            }
            if(null != lead.Distributor__c && null != accWiseUsersLeadMap.get(lead.Distributor__c))
            {
                finalUserList.addAll(accWiseUsersLeadMap.get(lead.Distributor__c));
            }
            if(null != lead.Reseller_SI_Partner__c && null != accWiseUsersLeadMap.get(lead.Reseller_SI_Partner__c))
            {
                finalUserList.addAll(accWiseUsersLeadMap.get(lead.Reseller_SI_Partner__c));
            }
            
            leadWiseUsersMap.put(lead.Id,finalUserList);
        }
        enablesharingForPartnerUsers(leadWiseUsersMap, label.PRM_Lead_Share, 'Edit');
    }
    
    /**************************************************
    *Method Name: disablesharingForInactiveUsers
    *Description: This method disables sharing of Deal Registration 
    ** on the basis of field: View_All_Deal_Registrations__c
    *Date: 22 Mar 2018
    ***************************************************/
        @future
        public Static void disableDRsharingForInactiveUsers(List<id> shareUserList){
        GAM.CreateLogs('Entered method: disablesharingForInactiveUsers','ApexClass:ApexSharingUtility');            
         
         string shareobjectName;
         List<sObject> finalListtoDelete = new List<sObject>();
         string rowCause='Manual';
         String queryVar;
         List<sObject> oldshareRecLst;
         
         //Delete share records for Lead
         shareobjectName = label.PRM_Lead_Share;
         queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+' WHERE UserOrGroupId IN:shareUserList and RowCause = :rowCause';
         //Querying share records
         oldshareRecLst = Database.query(queryVar);
         if(!oldshareRecLst.isEmpty())
         {
             finalListtoDelete.addAll(oldshareRecLst);
         }
         
         GAM.CreateLogs('This is a finalListtoDelete@@@@@@' + finalListtoDelete,'ApexClass:ApexSharingUtility');            
         //checking if oldshareRecLst is not empty;
         if(!finalListtoDelete.isEmpty())
         {
            try
            {
                delete finalListtoDelete ;
            }
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('Error while deleting share object list','ApexClass:ApexSharingUtility, method: disablesharingForInactiveUsers');            
            }
         }
    }
    //----------------------------------------------------------------------------------------------------------------------<T01>
    // Passing on Record Id, User Id and Access for the sharing
    public Static void enableSharingForInternalUsers(Map <id,Id> shareMap , String shareobjectName , String AccessLevel){
        GAM.CreateLogs('Entered method: enableSharingForInternalUsers','ApexClass:ApexSharingUtility');            
        List<sObject> shareRecLst = new List<sObject>();
        Map<String,Schema.SObjectType> shareobjMap = Schema.getGlobalDescribe();
        Schema.SObjectType shareobj = shareobjMap.get(shareobjectName); 
        Sobject shareobjInstance; 
        for(ID i : shareMap.keyset()){
        
            shareobjInstance = shareobj.newSObject();                 
            shareobjInstance.put('userorgroupid' , shareMap.get(i));                        
            if(shareobjectName == label.PRM_Lead_Share)
            {
                shareobjInstance.put('Leadid' , i);
                shareobjInstance.put('LeadAccessLevel' , AccessLevel);
            }                                    
            shareRecLst.add(shareobjInstance);
            
        }
        system.debug('insert shareRecLst: '+shareRecLst);
        GAM.CreateLogs('This is a check shareRecList@@@@@@' + shareRecLst,'ApexClass:ApexSharingUtility');            
        //checking if the shareRecList is empty
        if(!shareRecLst.isEmpty())
        {
            try
            {
                insert shareRecLst ;
            }
        
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('Error while inserting share object list','ApexClass:ApexSharingUtility, method: enableSharingForInternalUsers');            
            }
            
        }
    }
    // Passing on Record Id, User Id and Access for the sharing
    public Static void disableSharingForInternalUsers(Map<id,Id> shareMap , String shareobjectName){
        GAM.CreateLogs('Entered method: disableSharingForInternalUsers','ApexClass:ApexSharingUtility');            
        Set<ID> userId = new Set<ID>();
        Set<ID> recID  = new Set<ID>();
        recID  = shareMap.keySet();        
        userId.addAll(shareMap.values()) ;
        String queryVar;
        if(shareobjectName==label.PRM_Lead_Share)
        {
            queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+ ' WHERE Leadid IN:recID  AND UserOrGroupId IN:userId ';
        }
        else{
             queryVar = 'select id FROM '+String.escapeSingleQuotes(shareobjectName)+ ' WHERE ParentId IN:recID  AND UserOrGroupId IN:shareMap.values()';
        }
        //Querying share records
        List<sObject> oldshareRecLst = Database.query(queryVar);
        system.debug('oldshareRecLst: '+oldshareRecLst);
        GAM.CreateLogs('This is a oldshareRecLst@@@@@@' + oldshareRecLst,'ApexClass:ApexSharingUtility');            
        //checking if oldshareRecLst is not empty;
        if(!oldshareRecLst.isEmpty())
        {
            try
            {
                delete oldshareRecLst ;
            }
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('Error while deleting share object list','ApexClass:ApexSharingUtility, method: disablesharingForInternalUsers');            
            }
        }
    }
    //----------------------------------------------------------------------------------------------------------------------</T01>
}