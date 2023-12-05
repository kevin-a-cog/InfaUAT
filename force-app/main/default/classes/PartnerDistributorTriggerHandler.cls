/****************************************************************************************************************************
*  @Class Name: PartnerDistributorTriggerHandler
*  @Author: Deloitte
*  @Date: 2017-12-21
*  @Description:This is a handler class for Partner_Distributor triggers
*****************************************************************************************************************************
ChangeHistory      
ModifiedBy          Date        Requested By        Description                 Tag
****************************************************************************************************************************/

public class PartnerDistributorTriggerHandler {
    
    /**
    * Method to implement managed sharing of the Partnerdistributor for all partner users of the account
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */
    
    public static void afterInsertSharing(List<Partner_Distributor__c> triggerNew, map<id,Partner_Distributor__c> triggerNewMap){
        //Fetch all unique Acc Ids
        Set<Id> accIdSet = new Set<Id>();
        List<User> userList;
        //Map of PD id and set of accounts related to the PD
        map<id, set<Id>> mapPDIdWiseAcc = new Map<id,set<Id>>();
        //Map of Account id and list of users
        map<id, List<User>> mapAccIdWiseUser = new Map<id,List<User>>();
        //Map of PD id and list of users
        map<id, List<User>> mapPDIdWiseUser = new Map<id,List<User>>();
        Set<Id> tempAccIdSet ;
        //Fetch current partner accounts of the PD
        for(Partner_Distributor__c PD : triggerNew){
            tempAccIdSet = new Set<id>();
            if(PD.Distributor__c != null){
                tempAccIdSet.add(PD.Distributor__c);
                accIdSet.add(PD.Distributor__c);
            }
            if(PD.Reseller_Account__c != null){
                tempAccIdSet.add(PD.Reseller_Account__c);
                accIdSet.add(PD.Reseller_Account__c);
            }
            mapPDIdWiseAcc.put(PD.Id,tempAccIdSet);  
        }
        
        //Fetch all active users for the accounts
        for(User u : [select id, contact.accountid from user where contact.accountid IN :accIdSet and contact.Is_Active__c = TRUE and isactive=true LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
            //Ignore current user
            if(UserInfo.getUserId() != u.id)
            {
                //populate mapAccIdWiseUser
                if(null == mapAccIdWiseUser.get(u.contact.accountid))
                {
                    userList = new List<User>();
                    userList.add(u);
                    mapAccIdWiseUser.put(u.contact.accountid,userList);
                }
                else
                {
                    userList = mapAccIdWiseUser.get(u.contact.accountid);
                    userList.add(u);
                    mapAccIdWiseUser.put(u.contact.accountid,userList);
                }
            }
        }
        
        
        //Populate mapPDIdWiseUser with PD Ids against the list of users
        List<User> lstTempUsers;
        for(Id partnerRelId : mapPDIdWiseAcc.keySet())
        {
            //consolidate all account wise user list tagged to PD
            lstTempUsers = new List<User>();
            if(null != mapPDIdWiseAcc.get(partnerRelId)){
                for (Id accId: mapPDIdWiseAcc.get(partnerRelId)){
                    if(mapAccIdWiseUser.containsKey(accId)){
                        lstTempUsers.addAll(mapAccIdWiseUser.get(accId));
                    }
                }
                mapPDIdWiseUser.put(partnerRelId,lstTempUsers);                
            }      
        }
        
        ApexSharingUtility.enablesharingForPartnerUsers(mapPDIdWiseUser, 'Partner_Distributor__Share', 'Read');
    }
    
    /**
    * Method to implement managed sharing of the PatnerDistributor for all partner users of the account on after update
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */
    
    public static void afterUpdateSharing(List<Partner_Distributor__c> triggerNew, map<id,Partner_Distributor__c> triggerNewMap,List<Partner_Distributor__c> triggerOld, map<id,Partner_Distributor__c> triggerOldMap){
        //Fetch all unique Acc Ids
        Set<Id> accIdSet = new Set<Id>();
        List<User> userList;
        //Map of PD id and set of accounts related to the PD
        map<id, set<Id>> mapPDIdWiseAcc = new Map<id,set<Id>>();
        //Map of Account id and list of users
        map<id, List<User>> mapAccIdWiseUser = new Map<id,List<User>>();
        //Map of PD id and list of users
        map<id, List<User>> mapPDIdWiseUser = new Map<id,List<User>>();
        map<id, Id> mapPDIdWiseAccInactiveDistributor = new Map<id,Id>();    
        map<id, Id> mapPDIdWiseAccInactiveReseller = new Map<id,Id>();    
        //Fetch current partner accounts of the PD
        Set<Id> tempAccIdSet;
        for(Partner_Distributor__c PD : triggerNew){
            
            tempAccIdSet = new Set<id>();
            if(PD.Distributor__c != triggerOldMap.get(PD.Id).Distributor__c){
                if(PD.Distributor__c != null){
                    tempAccIdSet.add(PD.Distributor__c);
                    accIdSet.add(PD.Distributor__c);
                }
                if(triggerOldMap.get(PD.Id).Distributor__c!=null){
                    mapPDIdWiseAccInactiveDistributor.put(PD.Id,triggerOldMap.get(PD.Id).Distributor__c);
                }
            }
            if(PD.Reseller_Account__c != triggerOldMap.get(PD.Id).Reseller_Account__c){
                if(PD.Reseller_Account__c != null){
                    tempAccIdSet.add(PD.Reseller_Account__c);
                    accIdSet.add(PD.Reseller_Account__c);
                }
                if(triggerOldMap.get(PD.Id).Reseller_Account__c!=null){
                    mapPDIdWiseAccInactiveReseller.put(PD.Id,triggerOldMap.get(PD.Id).Reseller_Account__c);
                }
            }
            mapPDIdWiseAcc.put(PD.Id,tempAccIdSet);
        }
        
        //Fetch all active users for the accounts
        for(User u : [select id, contact.accountid from user where contact.accountid IN :accIdSet and contact.Is_Active__c = TRUE and isactive=true LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
            //Ignore current user
            if(UserInfo.getUserId() != u.id)
            {
                //populate mapAccIdWiseUser
                if(null == mapAccIdWiseUser.get(u.contact.accountid))
                {
                    userList = new List<User>();
                    userList.add(u);
                    mapAccIdWiseUser.put(u.contact.accountid,userList);
                }
                else
                {
                    userList = mapAccIdWiseUser.get(u.contact.accountid);
                    userList.add(u);
                    mapAccIdWiseUser.put(u.contact.accountid,userList);
                }
            }
        }
        
        
        //Populate mapPDIdWiseUser with PD Ids against the list of users
        List<User> lstTempUsers;
        for(Id partnerRelId : mapPDIdWiseAcc.keySet())
        {
            //consolidate all account wise user list tagged to PD
            lstTempUsers = new List<User>();
            if(null != mapPDIdWiseAcc.get(partnerRelId)){
                if(null != mapPDIdWiseAcc.get(partnerRelId)){
                    for (Id accId: mapPDIdWiseAcc.get(partnerRelId)){
                        if(mapAccIdWiseUser.containsKey(accId)){
                            lstTempUsers.addAll(mapAccIdWiseUser.get(accId));
                        }
                    }
                    mapPDIdWiseUser.put(partnerRelId,lstTempUsers);
                }
            }      
        }
        
        if(mapPDIdWiseAccInactiveDistributor.size() > 0){
            ApexSharingUtility.disablesharingForPartnerUsers(mapPDIdWiseAccInactiveDistributor, 'Partner_Distributor__Share');
        }
        if(mapPDIdWiseAccInactiveReseller.size() > 0){
            ApexSharingUtility.disablesharingForPartnerUsers(mapPDIdWiseAccInactiveReseller, 'Partner_Distributor__Share');
        }
        ApexSharingUtility.enablesharingForPartnerUsers(mapPDIdWiseUser, 'Partner_Distributor__Share', 'Read');
    }  
}