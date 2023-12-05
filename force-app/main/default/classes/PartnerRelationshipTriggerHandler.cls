/****************************************************************************************************************************
*  @Class Name: PartnerRelationshipTriggerHandler
*  @Author: Deloitte
*  @Date: 2017-11-08 
*  @Description:This is a handler class for Partner_Relationship triggers
*****************************************************************************************************************************
ChangeHistory      
ModifiedBy          Date        Requested By       JIRA       Description                                                       Tag
Kiran G          9 Dec 2019     Prasanth Gowda    PRMRT-732   Default % allocation to 0% for subsequent Partner Relationships
                                                              from DR Conversion                                                 T01
Anusha Akella  29th Sep 2021    Prasanth Gowda  SALESRT-13274 Partner Source and Partner Influence information on Opportunity for Clari Reporting <SALESRT-13274>
Puneet             20-05-23     SALESRT-15144 & SALESRT-14918      Ability to access converted deal registrations               <T02>
Puneet             20-05-23     SALESRT-15120                    Bypass custom errors                         <SALESRT-15120>
****************************************************************************************************************************/

public class PartnerRelationshipTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /* this method called by before insert trigger helps in checking percentage allocation
    * @Method Name- partnerRelBeforeInsert
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */
    public static void partnerRelBeforeInsert(List<Partner_Relationship__c> triggernew){
        percentageAllocationCheck(triggernew,true);
        //check if multiple resellers exist for Oppty for manual Partner Relationship creation
        List<Partner_Relationship__c> updatedPRList=new List<Partner_Relationship__c>();
        for(Partner_Relationship__c oPrtnrRel : triggernew)
        {
            if(oPrtnrRel.DEV_PRM_IsConverted__c != TRUE)
            {
                updatedPRList.add(oPrtnrRel);
            }
        }
        validateOppty(updatedPRList);
        populatePartnerProgram(triggernew,null);
        checkCreateonClosedOpty(triggernew);
    }
    
    /* this method called by before update trigger helps in checking percentage allocation
    * @Method Name- partnerRelBeforeUpdate
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */
    public static void partnerRelBeforeUpdate(List<Partner_Relationship__c> triggernew, Map<Id, Partner_Relationship__c> newMap, Map<Id, Partner_Relationship__c> oldMap){
        List<Partner_Relationship__c> updatedPRList=new List<Partner_Relationship__c>();
        
        
        percentageAllocationCheck(triggernew,false);
        
        for(Partner_Relationship__c oPrtnrRel : triggernew)
        {   
            //If there is change in Opportunity or Partner Role
            if((null!=newMap.get(oPrtnrRel.id).Opportunity__c && newMap.get(oPrtnrRel.id).Opportunity__c != oldMap.get(oPrtnrRel.id).Opportunity__c) || (null != newMap.get(oPrtnrRel.id).Partner_Role__c && newMap.get(oPrtnrRel.id).Partner_Role__c != oldMap.get(oPrtnrRel.id).Partner_Role__c))
            {
                //If old Partner Role not Resell/Resell - Fulfillment/One-time Resell
                if(null != oldMap.get(oPrtnrRel.id).Partner_Role__c && !oldMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value) && !oldMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value) && !oldMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value))
                {
                    updatedPRList.add(oPrtnrRel);
                }
                else if(null == oldMap.get(oPrtnrRel.id).Partner_Role__c)
                {
                    updatedPRList.add(oPrtnrRel);
                }
            }
        }
        validateOppty(updatedPRList);
        
        //US-1925
        //validateDealRegPartnerProgramPartnerRole(triggernew,newMap,oldMap);
        //US-1925
        
        //US-2096
        updatedPRList.clear();
        for(Partner_Relationship__c oPrtnrRel : triggernew)
        {
            //check if Partner_Account__c is not null and there is change in Partner_Role__c
            if(oPrtnrRel.Partner_Account__c !=null && oPrtnrRel.Partner_Role__c != null && newMap.get(oPrtnrRel.id).Partner_Role__c != oldMap.get(oPrtnrRel.id).Partner_Role__c)
            {
                updatedPRList.add(oPrtnrRel);
                //set old partner program to null
                /*if(null != oPrtnrRel.Program_Membership__c)
                {
                    oPrtnrRel.Program_Membership__c = null;
                }*/
            }
        }
        populatePartnerProgram(updatedPRList,oldMap);
        //US-2096
    }
    
    /* this method called by after insert trigger helps in creating opportunity products from Deal Registration products
    * @Method Name- partnerRelAfterInsert
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */ 
    public static void partnerRelAfterInsert(List<Partner_Relationship__c> triggernew, map<id,Partner_Relationship__c> triggerNewMap){
        createOpptyPrdctFrmDealRegPrdct(triggernew); 
        System.debug('is it entering here');
        updateOpptyPartner(triggerNewMap,null); //SALESRT-13274
        //updateOpptyOnDealRegOnPRInsert(triggernew);
        updateLead(triggerNewMap, null);
    }
    
    /* this method called by after update trigger helps in adding opportunity to Deal Registration
    * @Method Name- partnerRelAfterInsert
    * @param triggernew - list of new Partner_Relationship__c
    * @param triggerNewMap - Map of new Partner_Relationship__c
    * @param triggerOld - list of old Partner_Relationship__c
    * @param triggerOldMap - Map of old Partner_Relationship__c
    * @return return- n/a
    * @throws exception-n/a
    */
    public static void partnerRelAfterUpdate(List<Partner_Relationship__c> triggerNew, map<id,Partner_Relationship__c> triggerNewMap,List<Partner_Relationship__c> triggerOld, map<id,Partner_Relationship__c> triggerOldMap){
        afterUpdateSharing(triggerNew, triggerNewMap, triggerOld, triggerOldMap, false);
        updateOpptyPartner(triggerNewMap,triggerOldMap);  //SALESRT-13274
        //updateOpptyOnDealRegOnPRUpdate(triggerNew, triggerNewMap, triggerOldMap);
        updateLead(triggerNewMap, triggerOldMap);
    }
    
    /* this method called by before delete trigger
    * @Method Name- partnerRelAfterDelete
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-n/a
    */ 
    public static void partnerRelAfterDelete(map<id,Partner_Relationship__c> triggerOldMap){
        updateOpptyPartner(null,triggerOldMap); //SALESRT-13274
    }
    
    /* this method creates opportunity products from Deal Registration products
    * @Method Name- createOpptyPrdctFrmDealRegPrdct
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    
    public static void createOpptyPrdctFrmDealRegPrdct(List<Partner_Relationship__c> triggernew){/*
        //set of partner relationship id for after insert  
        set<id> setOfPartnerRelId = new set<id>();
        
        //set of Deal Registration id related to PartnerRelationship
        set<id> setOfDealRegId = new set<id>();
        
        //set of Opportunity id related to PartnerRelationship
        set<id> setOfOpportunityId = new set<id>();
        
        //set of opportunity Id CurrencyIsoCode
        set<string> setOFOpptyCurrency = new set<string>();
        
        //set of Deal Registration products
        set<id> setOFDealRegPrdcts = new set<id>();
        
        //To store standard pricebook
        Pricebook2 stdPriceBook;
        
        //list of Deal Registration product related to Deal Reg in partner relationship
        list<Deal_Registration_Products__c> dealRegPrdcts =  new list<Deal_Registration_Products__c>();
        
        //list of Opportunity related to partner relationship
        list<Opportunity> PROpportunity =  new list<Opportunity>();
        
        
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            if(oPrtnrRel.id != null && oPrtnrRel.DEV_Is_Created_From_Flow__c == true){    
                setOfPartnerRelId.add(oPrtnrRel.Id);
            }
            if(oPrtnrRel.Opportunity__c != null && oPrtnrRel.DEV_Is_Created_From_Flow__c == true){
                setOfOpportunityId.add(oPrtnrRel.Opportunity__c);
            }
            if(oPrtnrRel.Deal_Registration__c != null && oPrtnrRel.DEV_Is_Created_From_Flow__c == true){
                setOfDealRegId.add(oPrtnrRel.Deal_Registration__c);
            }
        }
        
        if(setOfDealRegId != null && !setOfDealRegId.isEmpty())
        {
            //Query all the Deal Reg Products related to Deal Reg
            dealRegPrdcts = [Select Id, Name, Product__c From Deal_Registration_Products__c 
                             Where Deal_Registration__c In : setOfDealRegId];
        }
        if(setOfOpportunityId != null && !setOfOpportunityId.isEmpty())
        {  
            //Query the CurrencyIsoCode of the Opportunity related to Partner Relationship
            PROpportunity = [Select Id,CurrencyIsoCode From Opportunity Where Opportunity.Id In : setOfOpportunityId];
        }
        
        
        
        //Proceed to create OLI only if there are any Deal Reg Prdct and Opportunity
        if(dealRegPrdcts != null && !dealRegPrdcts.isEmpty() && PROpportunity != null && !PROpportunity.isEmpty()){
            
            //Query the standard pricebook which will be used to search pricebookentry
            stdPriceBook = [select id, name from Pricebook2 where isStandard = true limit 1];
            
            //Map to store key as Product,currencyIsoCode and its PriceBookEntry
            map<String, pricebookentry> productIdPriceBook = new map<String, pricebookentry>();
            
            //Map to store Oppty and its CurrencyIsoCode
            map<Id, Opportunity> opptyIdCurrency = new map<Id, Opportunity>();
            
            for(Opportunity opp : PROpportunity){
                opptyIdCurrency.put(opp.Id,opp);
                setOFOpptyCurrency.add(opp.CurrencyIsoCode);
            }
            
            
            for(Deal_Registration_Products__c oDealReg : dealRegPrdcts){
                setOFDealRegPrdcts.add(oDealReg.Product__c);  
            }
            
            //This variable is used as a holder for the testing block below
            String currencyCode = '';
            
            if(setOFDealRegPrdcts != null && !setOFDealRegPrdcts.isEmpty() && setOFOpptyCurrency != null && !setOFOpptyCurrency.isEmpty() 
               && stdPriceBook != null)
            {
                for(PricebookEntry record:[select id,product2id,product2.name,CurrencyIsoCode 
                                           from pricebookentry 
                                           where product2id in :setOFDealRegPrdcts 
                                           and pricebook2id = :stdPriceBook.id 
                                           and CurrencyIsoCode in :setOFOpptyCurrency])
                {
                    productIdPriceBook.put(record.product2id+','+record.CurrencyIsoCode, record);
                }
            }
            
            if (!productIdPriceBook.isEmpty()){
                
                //Set of Opportunity Product to be inserted.
                set<OpportunityLineItem>OLItoInsert = new set<OpportunityLineItem>();
                
                for(Partner_Relationship__c oPrtnrRel : triggernew){        
                    string currentOpptyIdCurrency = opptyIdCurrency.get(oPrtnrRel.Opportunity__c).CurrencyIsoCode;
                    for(Deal_Registration_Products__c oDealReg : dealRegPrdcts) 
                    {
                        if(productIdPriceBook.containsKey(oDealReg.Product__c+','+currentOpptyIdCurrency) && 
                           (opptyIdCurrency.containsKey(oPrtnrRel.Opportunity__c)))
                        {
                            if( (opptyIdCurrency.get(oPrtnrRel.Opportunity__c).CurrencyIsoCode == productIdPriceBook.get(oDealReg.Product__c+','+currentOpptyIdCurrency).CurrencyIsoCode))
                            {
                                //create opportunity line items and add them to list of oppty line item
                                OpportunityLineItem oli = new OpportunityLineItem();
                                oli.opportunityid = oPrtnrRel.Opportunity__c;
                                oli.pricebookentryid = productIdPriceBook.get(oDealReg.Product__c+','+currentOpptyIdCurrency).id;
                                OLItoInsert.add(oli);
                            }
                        }
                    }
                }
                List<OpportunityLineItem>OLItoInsertList = new list<OpportunityLineItem>(OLItoInsert);
                if(OLItoInsertList != null && !OLItoInsert.isEmpty() && 
                Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().isCreateable())
                {
                    try
                    {              
                        insert OLItoInsertList;
                    }
                    catch (System.DmlException e) 
                    {   
                        //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                        GAM.CreateLogs('PartnerRelationshipTriggerHandler:createOpptyPrdctFrmDealRegPrdct At 208','ApexClass:PartnerRelationshipTriggerHandler');            
                    }
                }
            }
        }*/  
    }  
    
    
    /**
    * @param triggernew - list of new Partner_Relationship
    * @return return-void
    * @throws exception - NA
    */
    
    public static void percentageAllocationCheck(List<Partner_Relationship__c> triggernew,Boolean InsertOnly){
        // create a set of opportunity id  
        set<id> setOfOpportunityId = new set<id>();
        
        // @13/11/17 set of partner relationship id for before update case  
        set<id> setOfPartnerRelId = new set<id>();
        
        // play a for loop on trigger.new [Partner_Relationship__c list]   
        for(Partner_Relationship__c oPrtnrRel : triggernew)
        {
            //US-2130 : Changes Begin
            if(InsertOnly && oPrtnrRel.Allocated__c == null) 
            {  
                If(oPrtnrRel.Partner_Role__c != label.PRM_Partner_Role_Referral_Value && oPrtnrRel.Partner_Role__c != label.PRM_Partner_Role_One_Time_Referral_Value)   
                oPrtnrRel.Allocated__c = 0;  
            }         
            //US-2130 : Changes End
            
            // @13/11/17 fill the 'setOfPartnerRelId' set in update event case when record id not equal to null  
            if(oPrtnrRel.id != null){  
                setOfPartnerRelId.add(oPrtnrRel.Id);
            }
            // fill the 'setOfOpportunityId' set with parent opportunity
            if(oPrtnrRel.Opportunity__c != null){
                setOfOpportunityId.add(oPrtnrRel.Opportunity__c);
            }
        }
        
        map<Id,Opportunity> mapIdWiseOpportunity = new map<Id,Opportunity>();
        
        // create a map of opportunity id with opportunites [with all related child partner relationships] 
        /*map<Id,Opportunity> mapIdWiseOpportunity = new map<Id, opportunity>([select id,Name,(select id,Allocated__c,Partner_Sourced__c from Partner_Relationships__r WHERE Id NOT IN: setOfPartnerRelId) 
                                                                                from opportunity WHERE id In : setOfOpportunityId]);*/
        if(!setOfOpportunityId.isEmpty()) 
        {                                                                    
        for(Opportunity opp : [select id,Name,(select id,Allocated__c,Partner_Sourced__c,Partner_Role__c from Partner_Relationships__r WHERE Id NOT IN: setOfPartnerRelId) 
                                                                             from opportunity WHERE id In : setOfOpportunityId])
        {
            mapIdWiseOpportunity.put(opp.Id,opp);
        }
        }
        // create temp. variables for count the total % of allocation  
        Integer nPartnerRelCount = 100;
        Decimal totalAllocated = 0;  
        Opportunity oppty;
        
        // play a for loop on trigger.new partner relationship list 
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            // check if opportunity not equal to null and context opportunity id contains in map    
            if(oPrtnrRel.Opportunity__c != null && mapIdWiseOpportunity.containsKey(oPrtnrRel.Opportunity__c)){
                // get the opportunity from map 
                oppty = mapIdWiseOpportunity.get(oPrtnrRel.Opportunity__c);
                nPartnerRelCount = 100;
                totalAllocated = 0;
                
                
                
                boolean bActivePartnerSource = false;
                if(oppty.Partner_Relationships__r != null){
                    for(Partner_Relationship__c PRExisting : oppty.Partner_Relationships__r){
                        //US: 2216 If PR is created from lead conversion, then if partner role for existing PR is referral, set nPartnerRelCount to 0
                        /* if(oPrtnrRel.DEV_PRM_IsConverted__c)
                        {
                            if(PRExisting.Partner_Role__c == label.PRM_Partner_Role_Referral_Value)
                            {
                                nPartnerRelCount = 0;
                                System.debug('KG - Line 324' + nPartnerRelCount);
                            }
                        }
                        else
                        {
                            nPartnerRelCount = 0;
                        }*/
                        totalAllocated +=  (PRExisting.Allocated__c != null) ? PRExisting.Allocated__c : 0 ;
                        //System.debug('KG - Total Allocated' + totalAllocated);
                        // @13/11/17 validation for partner_sourced field [not more then 1 partner relationship checked for a opportunity]  
                        if(PRExisting.Partner_Sourced__c == 'Yes' &&
                           oPrtnrRel.Partner_Sourced__c == 'Yes'){
                               bActivePartnerSource = true ;
                           } 
                    }
                } 
                
                // check if Allocated__c field equal to null then set the Allocated__c field with nPartnerRelCount variable else add the add Allocated__c value to existing Allocated__c field   
                    if(oPrtnrRel.Allocated__c == null)
                    { 
                        if(oPrtnrRel.DEV_PRM_IsConverted__c && InsertOnly && (oPrtnrRel.Partner_Role__c == label.PRM_Partner_Role_Referral_Value || oPrtnrRel.Partner_Role__c == label.PRM_Partner_Role_One_Time_Referral_Value)) 
                        {   
                            //Added extra if to check if the Total Allocated is more than 0 , only then allocate 100% for Referral PR or set to 0%
                            //----------------------------------------T01----------------------------------------------
                             if(totalAllocated < = 0)
                                oPrtnrRel.Allocated__c = 100 ;
                            else
                                oPrtnrRel.Allocated__c = 0 ;
                            //----------------------------------------T01----------------------------------------------
                            //oPrtnrRel.Allocated__c = nPartnerRelCount ;                              
                        }
                    }
                    else
                    {
                        totalAllocated += oPrtnrRel.Allocated__c ; 
                        //System.debug('KG - Total Allocated ' + totalAllocated);
                        
                    }
                
                // @13/11/17 throw an error msg if bActivePartnerSource have true                    
                
                if(bActivePartnerSource && !PartnerRelationshipTriggerHandler.getExemption()){ //<SALESRT-15120> Update
                    oPrtnrRel.addError(label.PRM_PartnerRelationship_PartnerSource_Error); 
                }
                
                if(totalAllocated > 100 && !PartnerRelationshipTriggerHandler.getExemption()){ //<SALESRT-15120> Update
                    oPrtnrRel.addError(label.PRM_PartnerRelationship_TotalSplit_Error); 
                }
                
            }
            //added as part of US: 2216 where if no existing opportunity exists for the Opportunity Partner, default % Allocated to 100% for referral only
            else
            {
                if(oPrtnrRel.DEV_PRM_IsConverted__c && oPrtnrRel.Allocated__c == null && InsertOnly && oPrtnrRel.Partner_Role__c == label.PRM_Partner_Role_Referral_Value )                   
                {
                    //Added extra if to check if the Total Allocated is more than 0 , only then allocate 100% for Referral PR or set to 0%
                    //----------------------------------------T01---------------------------------------------
                    if(totalAllocated < = 0)
                        oPrtnrRel.Allocated__c = 100 ;
                    else
                        oPrtnrRel.Allocated__c = 0 ;
                    //----------------------------------------T01----------------------------------------------
                }    
                else
                   oPrtnrRel.Allocated__c = 0 ; 
            }
        }
        
    }
    
    /**
    * Method to implement managed sharing of the Opportunities for all related partner accounts
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    
    public static void afterInsertSharing(List<Partner_Relationship__c> triggerNew, map<id,Partner_Relationship__c> triggerNewMap){
        //Fetch all unique Acc Ids
        Set<Id> accIdSet = new Set<Id>();
        List<User> userList;
        List<User> finalUserList;
        //Map of PR id and set of accounts related to the PR
        map<id, Partner_Relationship__c> mapPRIdWisePR = new Map<id,Partner_Relationship__c>();
        //Map of Account id and list of users
        map<id, List<User>> mapAccIdWiseUser = new Map<id,List<User>>();
        //Map of PR id and list of users
        map<id, List<User>> mapPRIdWiseUser = new Map<id,List<User>>();
        //map of Opportunity id and list of users
        map<id, List<User>> mapOppIdWiseUser = new Map<id,List<User>>(); 
        //map of Opportunity id and list of Portal Admin users
        map<id, List<User>> mapOppIdWiseAdminUser = new map<id, List<User>>();
        
        //Fetch current partner accounts of the PR
        for(Partner_Relationship__c pr : triggerNew){
            //check if status field is not set to Inactive- RFP Loss/Inactive DR Expired. If so, sharing should not be provided
            if(pr.Partner_Account__c != null && !(pr.Status__c == 'Inactive - RFP Loss' || pr.Status__c == 'Inactive - DR Expired')){
                accIdSet.add(pr.Partner_Account__c);
            }
            mapPRIdWisePR.put(pr.Id,pr);
        }
        id uId = UserInfo.getUserId();
        //Fetch all active users for the accounts
        for(User u : [select id, contact.accountid, contact.Partner_Role__c from user where contact.accountid IN :accIdSet and contact.Is_Active__c = TRUE and isactive=true]){
            //Ignore current user
            if(uId != u.id)
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
        //Populate mapPRIdWiseUser with PR Ids against the list of users
        for(Id partnerRelId : mapPRIdWisePR.keySet())
        {
            //consolidate all account wise user list tagged to PR
            List<User> lstTempUsers = new List<User>();
            if(null != mapPRIdWisePR.containsKey(partnerRelId)){
                Partner_Relationship__c pr = mapPRIdWisePR.get(partnerRelId);
                if(pr.Partner_Account__c!=null && mapAccIdWiseUser.containsKey(pr.Partner_Account__c)){
                    lstTempUsers.addAll(mapAccIdWiseUser.get(pr.Partner_Account__c));
                }
                if(pr.Opportunity__c!=null && lstTempUsers.size()>0){
                    if(null == mapOppIdWiseUser.get(pr.Opportunity__c))
                        mapOppIdWiseUser.put(pr.Opportunity__c,lstTempUsers);
                    else
                    {
                        List<User> existingUserList = mapOppIdWiseUser.get(pr.Opportunity__c);
                        existingUserList.addAll(lstTempUsers);
                        mapOppIdWiseUser.put(pr.Opportunity__c,existingUserList);
                    }
                }
                
            }
        }
        
        //Identify all partner portal admins, to be given Edit access
        for(ID optyId : mapOppIdWiseUser.keyset())
        {
            List<User> userListTemp = mapOppIdWiseUser.get(optyId);
            List<User> userListTemp1 = new List<User>(); 
            List<User> partnerAdminUserList = new List<User>();
            if(null != userListTemp && !userListTemp.isEmpty())
            {
                for(User user : userListTemp)
                {
                    if(null != user.contact && null != user.contact.Partner_Role__c && user.contact.Partner_Role__c != '' && user.contact.Partner_Role__c.equalsIgnoreCase('Partner Portal Admin'))
                    {
                        //add to partner admin list
                        partnerAdminUserList.add(user);
                    }
                    //remove from current list
                    else
                        userListTemp1.add(user);
                }
                if(!userListTemp1.isEmpty())
                {
                    mapOppIdWiseUser.put(optyId,userListTemp1);
                }
                if(!partnerAdminUserList.isEmpty())
                {
                    mapOppIdWiseAdminUser.put(optyId,partnerAdminUserList);
                }
            }
        }
        
        if(null != mapOppIdWiseUser && !mapOppIdWiseUser.isEmpty())
            ApexSharingUtility.enablesharingForPartnerUsers(mapOppIdWiseUser, 'OpportunityShare', 'Read');
        //partner portal admin should be provided Edit access
        if(null != mapOppIdWiseAdminUser && !mapOppIdWiseAdminUser.isEmpty())
            ApexSharingUtility.enablesharingForPartnerUsers(mapOppIdWiseAdminUser, 'OpportunityShare', 'Edit');
    }
    
    /**
    * Method to implement managed sharing of the Opportunities for all related partner accounts afterUpdate
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    
    public static void afterUpdateSharing(List<Partner_Relationship__c> triggerNew, map<id,Partner_Relationship__c> triggerNewMap,List<Partner_Relationship__c> triggerOld, map<id,Partner_Relationship__c> triggerOldMap, boolean oppOwnerChange){
        //Fetch all unique Acc Ids
        Set<Id> accIdSet = new Set<Id>();
        List<User> userList;
        List<User> finalUserList;
        //Map of PR id and set of accounts related to the PR
        //map<id, set<Id>> mapPRIdWiseAcc = new Map<id,set<Id>>();
        map<id, Partner_Relationship__c> mapPRIdWisePR = new Map<id,Partner_Relationship__c>();
        //Map of Account id and list of users
        map<id, List<User>> mapAccIdWiseUser = new Map<id,List<User>>();
        //Map of PR id and list of users
        // map<id, List<User>> mapPRIdWiseUser = new Map<id,List<User>>();
        map<id, Id> mapPRIdWiseAccInactive = new Map<id,Id>();
        map<id, List<User>> mapOppIdWiseUser = new Map<id,List<User>>();    
        //map of Opportunity id and list of Portal Admin users
        map<id, List<User>> mapOppIdWiseAdminUser = new map<id, List<User>>();
        
        //set of Opportunity Id
        set<Id> oppSet = new Set<Id>();
        //map of opportunity Id and list of Partner Relationship
        map<Id, List<Partner_Relationship__c>> mapOppWisePR = new Map<Id,List<Partner_Relationship__c>>();   
        //list of existing Partner Relationship
        List<Partner_Relationship__c> existingPRList;
        
        
        /*US-2247: If oppty partner is set to inactive - the partner will lose the visibility to the Oppty. 
        ** But if there exists oppty partner with same partner account, tagged to Oppty, do not revoke access for the Oppty.
        */
        for(Partner_Relationship__c pr : triggerNew){
            //check if status field is set to Inactive- RFP Loss/Inactive DR Expired. If so, access has to be removed.
            if(null != pr.Status__c && (pr.Status__c == 'Inactive - RFP Loss' || pr.Status__c == 'Inactive - DR Expired') && null != pr.Opportunity__c)
            {
                oppSet.add(pr.Opportunity__c);
            }
        }
        
        if(null != oppSet && !oppSet.isEmpty())
        {
            //check if the Opportunity has existing Partner Relationship
            for(Opportunity opp : [select id,(select id,Partner_Account__c,Status__c from Partner_Relationships__r where Id not in :triggerNew) from Opportunity where id in :oppSet])
            {
                if(null != opp && null != opp.Partner_Relationships__r && !opp.Partner_Relationships__r.isEmpty())
                {
                    mapOppWisePR.put(opp.id,opp.Partner_Relationships__r);
                }
            }
            
            for(Partner_Relationship__c pr : triggerNew){
                //flag to check if access for this oppty has to be removed
                boolean toRevoke = true;
                if(null != mapOppWisePR && null != mapOppWisePR.get(pr.Opportunity__c))
                {
                    existingPRList = mapOppWisePR.get(pr.Opportunity__c);
                    if(null != existingPRList && !existingPRList.isEmpty())
                    {
                        for(Partner_Relationship__c existingPR : existingPRList)
                        {
                            //If there exists PartnerRelationship with same account, access should not be revoked.
                            if(pr.Partner_Account__c == existingPR.Partner_Account__c && !(existingPR.Status__c == 'Inactive - RFP Loss' || existingPR.Status__c == 'Inactive - DR Expired'))
                            {
                                toRevoke = false;
                                break;
                            }
                        }
                    }
                }
                if(toRevoke)
                {
                    mapPRIdWiseAccInactive.put(pr.Opportunity__c,pr.Partner_Account__c);
                }
            }
        }
        //if access to be removed, no further check required
        if(!(mapPRIdWiseAccInactive.size() > 0))
        {
            //Fetch current partner accounts of the PR
            for(Partner_Relationship__c pr : triggerNew){
                //if opportunity owner field is changed, sharing should be updated
                if(null == triggerOldMap && oppOwnerChange)
                {
                    if(pr.Partner_Account__c != null){
                        accIdSet.add(pr.Partner_Account__c);
                    }
                }
                //if opportunity or status is changed, sharing should be updated
                else if(null != triggerOldMap && pr.Opportunity__c != triggerOldMap.get(pr.Id).Opportunity__c || (pr.Status__c != triggerOldMap.get(pr.Id).Status__c && !(pr.Status__c == 'Inactive - RFP Loss' || pr.Status__c == 'Inactive - DR Expired'))){
                    if(pr.Partner_Account__c != null){
                        accIdSet.add(pr.Partner_Account__c);
                    }
                    if(null != triggerOldMap && triggerOldMap.get(pr.Id).Opportunity__c!=null){
                        mapPRIdWiseAccInactive.put(triggerOldMap.get(pr.Id).Opportunity__c,pr.Partner_Account__c);
                    }
                }
                mapPRIdWisePR.put(pr.Id,pr);
                
            }
            
            if(!accIdSet.isEmpty())
            {
            //Fetch all active users for the accounts
            for(User u : [select id, contact.accountid, contact.Partner_Role__c from user where contact.accountid IN :accIdSet and contact.Is_Active__c = TRUE and isactive=true])
            {
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
            }
            //Populate mapPRIdWiseUser with PR Ids against the list of users
            /* @Developer-->'*/
            for(Id partnerRelId : mapPRIdWisePR.keySet())
            {
                //consolidate all account wise user list tagged to PR
                List<User> lstTempUsers = new List<User>();
                if(null != mapPRIdWisePR.containsKey(partnerRelId)){
                    Partner_Relationship__c pr = mapPRIdWisePR.get(partnerRelId);
                    if(pr.Partner_Account__c!=null && mapAccIdWiseUser.containsKey(pr.Partner_Account__c)){
                        lstTempUsers.addAll(mapAccIdWiseUser.get(pr.Partner_Account__c));
                    }
                    if(pr.Opportunity__c!=null && lstTempUsers.size()>0){
                        //append user list for all partner relationships of the opportunity
                        if(null != mapOppIdWiseUser.get(pr.Opportunity__c))
                        {
                            List<User> existingUserList = mapOppIdWiseUser.get(pr.Opportunity__c);
                            lstTempUsers.addAll(existingUserList);
                            mapOppIdWiseUser.put(pr.Opportunity__c,lstTempUsers);
                        }
                        else    
                            mapOppIdWiseUser.put(pr.Opportunity__c,lstTempUsers);
                    }
                    
                }
                
            }
            
            //Identify all partner portal admins, to be given Edit access
            for(ID optyId : mapOppIdWiseUser.keyset())
            {
                List<User> userListTemp = mapOppIdWiseUser.get(optyId);
                List<User> userListTemp1 = new List<User>(); 
                List<User> partnerAdminUserList = new List<User>();
                if(null != userListTemp && !userListTemp.isEmpty())
                {
                    for(User user : userListTemp)
                    {
                        if(null != user.contact && null != user.contact.Partner_Role__c && user.contact.Partner_Role__c != '' && user.contact.Partner_Role__c.equalsIgnoreCase('Partner Portal Admin'))
                        {
                            //add to partner admin list
                            partnerAdminUserList.add(user);
                        }
                        //remove from current list
                        else
                            userListTemp1.add(user);
                    }
                    if(!userListTemp1.isEmpty())
                    {
                        mapOppIdWiseUser.put(optyId,userListTemp1);
                    }
                    if(!partnerAdminUserList.isEmpty())
                    {
                        mapOppIdWiseAdminUser.put(optyId,partnerAdminUserList);
                    }
                }
            }
        }
        
        if(null != mapPRIdWiseAccInactive && mapPRIdWiseAccInactive.size() > 0){
            ApexSharingUtility.disablesharingForPartnerUsers(mapPRIdWiseAccInactive, label.PRM_Oppty_Share);
        }
        if(null != mapOppIdWiseUser && mapOppIdWiseUser.size() > 0)
        {
            ApexSharingUtility.enablesharingForPartnerUsers(mapOppIdWiseUser, label.PRM_Oppty_Share, 'Read');
        }
        //partner portal admin should be provided Edit access
        if(null != mapOppIdWiseAdminUser && !mapOppIdWiseAdminUser.isEmpty())
            ApexSharingUtility.enablesharingForPartnerUsers(mapOppIdWiseAdminUser, 'OpportunityShare', 'Edit');
    }
    
    /**
    * Method to implement managed sharing of the Opportunities for all related partner accounts afterdelete
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    public static void afterDeleteSharing(List<Partner_Relationship__c> triggerOld)
    {
        
        map<id, Id> mapPRIdWiseAccInactive = new Map<id,Id>();
        for(Partner_Relationship__c pr : triggerOld){
            if(pr.Opportunity__c!=null){
                mapPRIdWiseAccInactive.put(pr.Opportunity__c,pr.Partner_Account__c);
            }
        }
        
        if(mapPRIdWiseAccInactive.size() > 0){
            ApexSharingUtility.disablesharingForPartnerUsers(mapPRIdWiseAccInactive, label.PRM_Oppty_Share);
        }
        
    }   
    
    /**
    * Method to update Deal Registration Oppty lookup with Opportunity from Partner Relationship after update trigger
    * @param triggernew - list of Partner_Relationship__c
    * @param triggerNewMap - map of new Partner_Relationship__c ID,object
    * @param triggerOldMap - map of old Partner_Relationship__c ID,object
    * @return return-void
    * @throws exception - NA
    */     
    /*public static void updateOpptyOnDealRegOnPRUpdate(List<Partner_Relationship__c> triggernew, map<id,Partner_Relationship__c> triggerNewMap, map<id,Partner_Relationship__c> triggerOldMap){
        
        //Map to store Deal Registration id and PartnerRelationship
        map<Id, Id> dealRegIdOpptyId = new map<Id, Id>();
        
        //Map to store Deal Registration id and PartnerRelationship
        map<Id, Id> removeOldDealRegOpptyId = new map<Id, Id>();
        
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            
            Partner_Relationship__c oldPR = triggerOldMap.get(oPrtnrRel.ID);
            Partner_Relationship__c newPR = triggerNewMap.get(oPrtnrRel.ID);
            
            ID oldDealRegVal = oldPR.Deal_Registration__c;
            ID newDealRegVal = newPR.Deal_Registration__c;
            
            ID oldOpptyID = oldPR.Opportunity__c;
            ID newOpptyID = newPR.Opportunity__c;
            
            if(oldDealRegVal != newDealRegVal){
                if(oPrtnrRel.Deal_Registration__c !=null && oPrtnrRel.Opportunity__c !=null)
                {
                    dealRegIdOpptyId.put(oPrtnrRel.Deal_Registration__c,oPrtnrRel.Opportunity__c);
                }
                if(oldPR.Deal_Registration__c != NULL){
                    removeOldDealRegOpptyId.put(oldPR.Deal_Registration__c,oldPR.Opportunity__c);
                } 
            }
            //update opportunity look up on deal reg if opportunity is changed
            if(oldOpptyID != newOpptyID)
            {
                if(oPrtnrRel.Deal_Registration__c !=null && oPrtnrRel.Opportunity__c !=null)
                {
                    dealRegIdOpptyId.put(oPrtnrRel.Deal_Registration__c,oPrtnrRel.Opportunity__c);
                }
            }
            
            
        }
        
        if(dealRegIdOpptyId != null && !dealRegIdOpptyId.isEmpty())
        {
            //Pass map with deal Reg ID and Oppty ID to update Deal Registration with Opportunity ID.
            updateDealRegWithOppty(dealRegIdOpptyId, 'AddNewOpptyToNewDealReg');
        }
        if(removeOldDealRegOpptyId != null && !removeOldDealRegOpptyId.isEmpty())
        {
            //Pass map with old Deal Reg ID and Oppty ID to remove Opportunity from Deal Reg
            updateDealRegWithOppty(removeOldDealRegOpptyId, 'RemoveOldOpptyFromOldDealReg');
        }
    }*/
    
    /**
    * Method to update Deal Registration Oppty lookup with Opportunity from Partner Relationship after insert trigger
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    /*public static void updateOpptyOnDealRegOnPRInsert(List<Partner_Relationship__c> triggernew){
        
        //Map to store Deal Registration id and PartnerRelationship
        map<Id, Id> dealRegIdOpptyId = new map<Id, Id>();
        
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            if(oPrtnrRel.id != null && oPrtnrRel.Deal_Registration__c !=null && oPrtnrRel.Opportunity__c !=null)
            {
                dealRegIdOpptyId.put(oPrtnrRel.Deal_Registration__c,oPrtnrRel.Opportunity__c); 
            }
        }
        if(dealRegIdOpptyId != null && !dealRegIdOpptyId.isEmpty())
        {
            //Pass map with deal Reg ID and Oppty ID to update Deal Registration with Opportunity ID.
            updateDealRegWithOppty(dealRegIdOpptyId, 'AddNewOpptyToNewDealReg');
        }
    }*/
    
    /**
    * Method to update Deal Registration Oppty lookup with Opportunity from Partner Relationship
    * @param dealRegIdOpptyId - map of Deal Registration ID and Opportunity ID
    * @return return-void
    * @throws exception - NA
    */
    /*public static void updateDealRegWithOppty(map<Id, Id> dealRegIdOpptyId, String action){
        
        List<Deal_Registration__c> dealRegList = [SELECT Id, Opportunity__c FROM Deal_Registration__c WHERE ID IN :dealRegIdOpptyId.KeySet()];
        
        List<Deal_Registration__c> dealRegUpdateList = new List<Deal_Registration__c>();
        
        for(Deal_Registration__c dealReg : dealRegList){
            if(action == 'AddNewOpptyToNewDealReg'){
                ID opptyId = dealRegIdOpptyId.get(dealReg.Id);
                dealReg.Opportunity__c = opptyId;
                dealRegUpdateList.add(dealReg);
            }
            else if(action == 'RemoveOldOpptyFromOldDealReg'){
                dealReg.Opportunity__c = NULL;
                dealRegUpdateList.add(dealReg);
            }
            
        }
        if(dealRegUpdateList != null && !dealRegUpdateList.isEmpty() && 
        Schema.getGlobalDescribe().get('Deal_Registration__c').getDescribe().isUpdateable())
        {
            try
            {
                update dealRegUpdateList;
            }
            catch (System.DmlException e) 
            {   
                //Sending Method Name,Line Number and Apex Class name which caused the DML exception.                
                GAM.CreateLogs('PartnerRelationshipTriggerHandler:updateDealRegWithOppty At 558','ApexClass:PartnerRelationshipTriggerHandler');
            }
        }
    }*/
    
    /**
    * Method to ensure only one Partner Relationship of type Resell/Resell - Fulfillment/One-time Resell is tagged to an Opportunity.
    * This will not apply for RFP type Opp
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    public static void validateOppty(List<Partner_Relationship__c> triggernew){
        
        //set of Opportunity Id
        set<Id> oppSet = new Set<Id>();
        
        //set or Opportunity Ids that cannot be tagged to the dr
        set<Id> errorOppSet = new Set<Id>();
        //Check if Partner Relationship is created manually and Opportunity is not null and Role is of type Resell/Resell - Fulfillment/One-time Resell
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            if(oPrtnrRel.Opportunity__c !=null && oPrtnrRel.Partner_Role__c != null && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)))
            {
                //populate oppSet
                oppSet.add(oPrtnrRel.Opportunity__c);
            }
        }
        
        //check if the Opportunity has existing Partner Relationship
        for(Opportunity opp : [select id,Solicitation_RFP_or_Public_Tender__c,(select id,Partner_Role__c from Partner_Relationships__r) from Opportunity where id in :oppSet])
        {
            //check if opp is not RFP
            if(null != opp && null != opp.Partner_Relationships__r && !opp.Partner_Relationships__r.isEmpty() && opp.Solicitation_RFP_or_Public_Tender__c !=  TRUE)
            {
                for(Partner_Relationship__c oPrtnrRel : opp.Partner_Relationships__r)
                {
                    //check if partner Role is Resell
                    if(null != oPrtnrRel.Partner_Role__c && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)))
                    {
                        errorOppSet.add(opp.id);
                    }
                }
            }
        }
        
        for(Partner_Relationship__c oPrtnrRel : triggernew)
        {
            //If opportunity has existing Partner Relationship with type: Resell/Resell - Fulfillment, throw error
            if(oPrtnrRel.Opportunity__c !=null && !errorOppSet.isEmpty() && errorOppSet.contains(oPrtnrRel.Opportunity__c) && !PartnerRelationshipTriggerHandler.getExemption()) //<SALESRT-15120> Update
            {
                oPrtnrRel.addError(label.PRM_PartnerRelationship_OPP_Type_Error);
            }
        }
    }
    
    
    /**
    * Method to populate Partner Program
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    public static void populatePartnerProgram(List<Partner_Relationship__c> triggernew,Map<Id, Partner_Relationship__c> oldMap){
        
        //Map of Partner Relationship and Acc Id
        Map<Partner_Relationship__c, Id> prWiseAccMap = new Map<Partner_Relationship__c, Id>();
        
        //Map of Acc Id and List of Partner Program
        Map<Id, List<Partner_Program__c>> accWisePPMap = new Map<Id, List<Partner_Program__c>>();
        
        //Check if Partner Account is not null
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            if(oPrtnrRel.Partner_Account__c !=null)
            {
                //populate prWiseAccMap
                prWiseAccMap.put(oPrtnrRel,oPrtnrRel.Partner_Account__c);
            }
        }
        
        //Fetch all active partner programs tagged to the partner account
        for(Account acc : [select Id,(select Id,Program_Type__c,Program_Status__c from Program_Memberships__r where Program_Status__c = 'Active') from Account where id in :prWiseAccMap.values()])
        {
            if(null != acc && null != acc.Program_Memberships__r && !acc.Program_Memberships__r.isEmpty())
            {
                accWisePPMap.put(acc.Id,acc.Program_Memberships__r);
            }
        }
        
        for(Partner_Relationship__c oPrtnrRel : triggernew){
            if(null != accWisePPMap.get(prWiseAccMap.get(oPrtnrRel)))
            {
                List<Partner_Program__c> ppList = accWisePPMap.get(prWiseAccMap.get(oPrtnrRel));
                if(!ppList.isEmpty())
                {
                    for(Partner_Program__c pprog : ppList)
                    {
                        //For Resell/Resell – Fulfillment/One-time Resell type Partner Relationship, populate active Partner Program of type 1 Tier AIR/2 Tier AIR
                        if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)) && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_1_Tier_AIR_Value) || pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_2_Tier_AIR_Value)))
                        {
                            oPrtnrRel.Program_Membership__c = pprog.Id;
                            break;
                        }
                        //For Referral/One-time Referral type Partner Relationship, populate active Partner Program of type CSI
                        else if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Referral_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Referral_Value)) && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_CSI_Value)))
                        {
                            oPrtnrRel.Program_Membership__c = pprog.Id;
                            break;
                        }
                        //For Distributor type Partner Relationship, populate active Partner Program of type VAD
                        else if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c && oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Disti_Value) && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_VAD_Value)))
                        {
                            oPrtnrRel.Program_Membership__c = pprog.Id;
                            break;
                        }
                        //For ISV type Partner Relationship, populate active Partner Program of type ISV
                        else if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c && oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_ISV_Value) && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_ISV_Value)))
                        {
                            oPrtnrRel.Program_Membership__c = pprog.Id;
                            break;
                        }
                        //For OEM type Partner Relationship, populate active Partner Program of type OEM
                        else if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c && oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_OEM_Value) && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_OEM_Value)))
                        {
                            oPrtnrRel.Program_Membership__c = pprog.Id;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    /**
    * Method to ensure that Deal Registration Type , Partner Role and Partner Program are all of same type
    * @param triggernew - list of Partner_Relationship__c
    * @return return-void
    * @throws exception - NA
    */
    /*public static void validateDealRegPartnerProgramPartnerRole(List<Partner_Relationship__c> triggernew, map<id,Partner_Relationship__c> newMap, map<id,Partner_Relationship__c> oldMap){
        
        //Map of Partner Relationship and Acc Id
        Map<Partner_Relationship__c, Id> prWiseAccMap = new Map<Partner_Relationship__c, Id>();
        
        //Map of Acc Id and List of Partner Program
        Map<Id, List<Partner_Program__c>> accWisePPMap = new Map<Id, List<Partner_Program__c>>();
        
        //Map of Partner Relationship and Deal Registraton
        Map<Id, Deal_Registration__c> dealRegIdDealRegMap = new Map<Id, Deal_Registration__c>();
        
        //set of Partner Relationship Ids that cannot be updated
        set<Id> errorPRSetPP = new Set<Id>();
        
        //set of Deal Registration
        set<Id> dealRegSet = new Set<Id>();
        
        for(Partner_Relationship__c oPrtnrRel : triggernew)
        {
            //If there is change in Deal Registration or Partner Role 
            //to any resell type or any referral type
            system.debug('newMap.get(oPrtnrRel.id):'+newMap.get(oPrtnrRel.id));
            system.debug('oldMap.get(oPrtnrRel.id):'+oldMap.get(oPrtnrRel.id));
            if((null != newMap.get(oPrtnrRel.id).Partner_Role__c && newMap.get(oPrtnrRel.id).Partner_Role__c != oldMap.get(oPrtnrRel.id).Partner_Role__c)
               && (newMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value)
                   ||newMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value)
                   ||newMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)
                   ||newMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Referral_Value)
                   ||newMap.get(oPrtnrRel.id).Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Referral_Value)))
            {
                system.debug('PR after update:');
                //populate errorPRSetPP
                errorPRSetPP.add(oPrtnrRel.Id);
                
                
                prWiseAccMap.put(oPrtnrRel,oPrtnrRel.Partner_Account__c);
            }
            if((null != newMap.get(oPrtnrRel.id).Deal_Registration__c && newMap.get(oPrtnrRel.id).Deal_Registration__c != oldMap.get(oPrtnrRel.id).Deal_Registration__c))
            {
                dealRegSet.add(oPrtnrRel.Deal_Registration__c);
            }
        }
        
        if(null != prWiseAccMap && !prWiseAccMap.isEmpty())
        {   
            //Fetch all active partner programs tagged to the partner account
            for(Account acc : [select Id,(select Id,Program_Type__c,Program_Status__c from Program_Memberships__r where Program_Status__c = 'Active') from Account where id in :prWiseAccMap.values()])
            {
                if(null != acc && null != acc.Program_Memberships__r && !acc.Program_Memberships__r.isEmpty())
                {
                    accWisePPMap.put(acc.Id,acc.Program_Memberships__r);
                }
            }
            
            for(Partner_Relationship__c oPrtnrRel : triggernew){
                if(null != accWisePPMap.get(prWiseAccMap.get(oPrtnrRel)))
                {
                    List<Partner_Program__c> ppList = accWisePPMap.get(prWiseAccMap.get(oPrtnrRel));
                    if(!ppList.isEmpty())
                    {
                        for(Partner_Program__c pprog : ppList)
                        {
                            if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c 
                               && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value) 
                                   || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value) 
                                   || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)) 
                               && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_1_Tier_AIR_Value) 
                                   || pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_2_Tier_AIR_Value)))
                            {
                                errorPRSetPP.remove(oPrtnrRel.Id);
                            }
                            else if(null!= pprog.Program_Type__c && null != oPrtnrRel.Partner_Role__c 
                                    && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Referral_Value) 
                                        || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Referral_Value)) 
                                    && (pprog.Program_Type__c.equalsIgnoreCase(label.PRM_Prgrm_Type_CSI_Value)))
                            {
                                errorPRSetPP.remove(oPrtnrRel.Id);
                            }
                        }
                    }
                }
            }
            
            for(Partner_Relationship__c oPrtnrRel : triggernew)
            {
                //If account does not have active partner program for selected partner role throw error
                if(!errorPRSetPP.isEmpty() && errorPRSetPP.contains(oPrtnrRel.Id))
                {
                    oPrtnrRel.addError(label.PRM_PartnerRelationship_PP_Type_Error);
                }
            }
        }
        if(null != dealRegSet && !dealRegSet.isEmpty())
        {
            for(Deal_Registration__c dealReg : [SELECT Id,Deal_Registration_Type__c from Deal_Registration__c where Id in:dealRegSet])
            {
                dealRegIdDealRegMap.put(dealReg.Id,dealReg);
            }
            for(Partner_Relationship__c oPrtnrRel : triggernew)
            {
                if(null != dealRegIdDealRegMap && !dealRegIdDealRegMap.isEmpty())
                {
                    if((oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value)
                        ||oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value)
                        ||oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)) 
                       && !dealRegIdDealRegMap.get(oPrtnrRel.Deal_Registration__c).Deal_Registration_Type__c.equals(label.PRM_Deal_Reg_Type_Resell_Value))
                    {
                        oPrtnrRel.addError(label.PRM_PartnerRelationship_DR_Type_Error);
                    }
                    else if((oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Referral_Value)
                             ||oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Referral_Value)) 
                            && !dealRegIdDealRegMap.get(oPrtnrRel.Deal_Registration__c).Deal_Registration_Type__c.equals(label.PRM_Deal_Reg_Type_Referral_Value))
                    {
                        oPrtnrRel.addError(label.PRM_PartnerRelationship_DR_Type_Error);
                    }
                }
            }
        }
    }*/
    
    
    /* this method throws validation error if internal user except SOG
    *  creates Partner Relationship for a Closed Opportunity
    * @Method Name- checkCreateonClosedOpty
    * @param parameter- triggernew
    * @return return- n/a
    * @throws exception-
    */ 
    public static void checkCreateonClosedOpty(List<Partner_Relationship__c> triggernew){
        //set of Opportunity Id
        set<Id> oppSet = new Set<Id>();
        //set or Opportunity Ids that are closed and new PRs for which cannot be created
        set<Id> errorOppSet = new Set<Id>();
        
        //check user is not SOG
        Id userId = UserInfo.getUserid();
        Set < Id > permissionSetIds = new Set < Id >();
        List < User > userList = new List < User >();
        for ( SetupEntityAccess access : [  SELECT ParentId FROM SetupEntityAccess 
                                            WHERE SetupEntityId IN ( SELECT Id 
                                            FROM CustomPermission
                                            WHERE DeveloperName in (:label.PRM_CustomPerm_SOGPRMSuperUser, :label.PRM_CustomPerm_SOG_SuperUser) )])
        {
            permissionSetIds.add(access.ParentId);    
        }
        
        userList = [SELECT Username FROM User WHERE Id IN (
                    SELECT AssigneeId FROM PermissionSetAssignment
                    WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =: userId ) ];

        //user is non-SOG
        if(userList.isEmpty())
        {
            for(Partner_Relationship__c oPrtnrRel : triggernew)
            {
                if(null != oPrtnrRel.Opportunity__c)
                {
                    //populate oppSet
                    oppSet.add(oPrtnrRel.Opportunity__c);
                }
            }
            
            //check if the Opportunity is closed
            system.debug('limit.getQueries()'+Limits.getQueries());
            for(Opportunity opp : [select id,IsClosed from Opportunity where id in :oppSet])
            {
                if(opp.IsClosed)
                {
                    errorOppSet.add(opp.id);
                }
            }
            
            for(Partner_Relationship__c oPrtnrRel : triggernew)
            {
                //If opportunity is closed, throw error so that new Partner Relationship cannot be created
                if(null != oPrtnrRel.Opportunity__c && !errorOppSet.isEmpty() && errorOppSet.contains(oPrtnrRel.Opportunity__c) && !PartnerRelationshipTriggerHandler.getExemption()) //<SALESRT-15120> Update
                {
                    oPrtnrRel.addError('Partner Relationship cannot be created for Closed Opportunity');
                }
            }
        }   
    }
    /* this method updates fields on Opportunity "Partner source" & Partner Influence based on the criteria for
    *  AfterInsert, AfterUpdate & Afterdelete trigger context(s);
    * @Method Name- updateOpptyPartner
    * @param parameter- newMap & OldMap
    * @return return- n/a
    * @SALESRT-13274
    */ 
    public static void updateOpptyPartner (Map<Id,Partner_Relationship__c> newMap,  Map<Id,Partner_Relationship__c> oldMap) {
        Set<Id> opptyIds = new Set<Id>();
        Map<Id, List<Partner_Relationship__c>> oppToPartnerMap = new Map<Id, List<Partner_Relationship__c>>();
        List<Opportunity> updateOpptys = new List<Opportunity>();
        // Check for existing records, if so do they have updates.
        if(newMap != null && !newMap.values().isEmpty()) {    
            for(Partner_Relationship__c ptr : newMap.values()) {
                if(oldMap != Null) {
                    if(ptr.Partner_Sourced__c != oldMap.get(ptr.Id).Partner_Sourced__c && ptr.Partner_Sourced__c != Null || ptr.Allocated__c != oldMap.get(ptr.Id).Allocated__c || (ptr.Partner_Role__c != oldMap.get(ptr.Id).Partner_Role__c && (ptr.Partner_Role__c == 'EcoSystem' ||oldMap.get(ptr.Id).Partner_Role__c == 'EcoSystem'))) {
                        opptyIds.add(ptr.Opportunity__c);
                    }
                } else {
                    // new records insert
                    opptyIds.add(ptr.Opportunity__c);
                    system.debug('opptyIds'+opptyIds);
                }    
            }    
        } else {
            // deletion condition check
            if(oldMap != Null && !oldMap.values().isEmpty()) {
                for(Partner_Relationship__c ptr : oldMap.values()) {
                    opptyIds.add(ptr.Opportunity__c);
                }
            }
        }
        if(!opptyIds.isEmpty()) {
            system.debug('opptyIds'+opptyIds);
            //New/Update/Delete
            for(Partner_Relationship__c prtnr : [SELECT Id, Opportunity__c, Partner_Role__c, Allocated__c,Opportunity__r.Partner_Source__c,Opportunity__r.Partner_Influence__c,Partner_Sourced__c,Partner_Account__c,Partner_Account__r.Name FROM Partner_Relationship__c WHERE Opportunity__c IN :opptyIds]) {
                if(oppToPartnerMap.containsKey(prtnr.Opportunity__c)) {
                    oppToPartnerMap.get(prtnr.Opportunity__c).add(prtnr);
                } else {
                    oppToPartnerMap.put(prtnr.Opportunity__c, new List<Partner_Relationship__c>{prtnr});
                }
            }
            Boolean containsAllOpps = oppToPartnerMap.keyset().containsAll(opptyIds);
            //checking for Zero Records and updating Opty fields
            if(!containsAllOpps) {
                for(id oppId : opptyIds) {
                    if(!oppToPartnerMap.containsKey(oppId)){
                      Opportunity oppty = new Opportunity(id = oppId, Partner_Source__c = null, Partner_Influence__c = null) ;
                      updateOpptys.add(oppty); 
                    }  
                }
            }
            if(!oppToPartnerMap.keyset().isEmpty()){
                for(Id oppId : oppToPartnerMap.keyset()){
                    String source = '';
                    String influence = '';
                    Boolean onePartner = oppToPartnerMap.get(oppId).size()==1?true:false;
                    //Integer result = oldMap.get(oppId).Partner_Influence__c.length()!= null?true:false;
                    for(Partner_Relationship__c pt : oppToPartnerMap.get(oppId)) {
                        
                        //There can be only one partner Source
                        if(pt.Partner_Sourced__c =='Yes') {                            
                        	source = pt.Partner_Account__r.Name;    	                            
                        } else if(pt.Partner_Sourced__c == 'No' && (pt.Allocated__c > 0 || pt.Partner_Role__c == 'Ecosystem')) {
                            System.debug('Loop enter here --->influence');
                            	influence += pt.Partner_Account__r.Name+';'+' ';                            
                        }
                    }
                    Opportunity opp = new Opportunity(id = oppId, Partner_Source__c = source, Partner_Influence__c = influence.removeEnd('; '));
                    updateOpptys.add(opp);       
                }
                  
            }
            try{
                if(!updateOpptys.isEmpty()) {
                    update updateOpptys;
                }  
           	} catch (System.DmlException e) {
               GAM.CreateLogs('PartnerRelationshipTriggerHandler:updateOpptyPartner'+e.getMessage(), updateOpptys, 'OpportunityToUpdate');            
           	}
        }
    }
    //<T02> begin
    /**
     * @description : This method is used to update deal registration with the Partner Relationship Link
     * 
     * @param : newMap - new map of partner relationships
     * @param : oldMap - old Map of partner relationships
     * 
     * @return : void
     * */ 
    public static void updateLead(Map<Id,Partner_Relationship__c> newMap,  Map<Id,Partner_Relationship__c> oldMap){

        List<Lead> leadListToUpdate = new List<Lead>();
        Set<Id> leadIds = new Set<Id>();
        for(Partner_Relationship__c pr : newMap.values()){
            if((oldMap == null || (oldMap != null && oldMap.get(pr.Id).Deal_Registration__c != pr.Deal_Registration__c) ) && pr.Deal_Registration__c != null){
                leadIds.add(pr.Deal_Registration__c);
            }
        }

        if(!leadIds.isEmpty()){
            Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id,Partner_Relationship__c FROM Lead WHERE Id IN :leadIds]);
            Map<Id,List<Partner_Relationship__c>> partnerRelationMap = new Map<Id,List<Partner_Relationship__c>>();

            for(Partner_Relationship__c partRel : [SELECT Id,Deal_Registration__c,Deal_Registration__r.Partner_Relationship__c,Partner_Role__c FROM Partner_Relationship__c WHERE Deal_Registration__c IN :leadMap.keySet()]){

                if(!partnerRelationMap.containsKey(partRel.Deal_Registration__c)){
                    partnerRelationMap.put(partRel.Deal_Registration__c, new List<Partner_Relationship__c>());
                }
                partnerRelationMap.get(partRel.Deal_Registration__c).add(partRel);
            }

            Set<Id> leadsInForUpdate = new Set<Id>();

            for(Partner_Relationship__c pr : newMap.values()){

                if(!leadsInForUpdate.contains(pr.Deal_Registration__c) && leadMap != null && pr.Deal_Registration__c != null && leadMap.containsKey(pr.Deal_Registration__c) && pr.Deal_Registration__c != leadMap.get(pr.Deal_Registration__c).Partner_Relationship__c){
                    
                    Id finalPRId = pr.Id;
                    if(!partnerRelationMap.isEmpty() && partnerRelationMap.containsKey(pr.Deal_Registration__c) && partnerRelationMap.get(pr.Deal_Registration__c).size() > 1){

                        for(Partner_Relationship__c cPr : partnerRelationMap.get(pr.Deal_Registration__c)){
                            
                            if(cPr.Partner_Role__c == 'Resell' || cPr.Partner_Role__c == 'Resell - Fulfillment'){
                                finalPRId = cPr.Id;
                                break;
                            }
                        }
                    }
                    
                    Lead l = new Lead();
                    l.Id = pr.Deal_Registration__c;
                    l.Partner_Relationship__c = finalPRId;
                    leadListToUpdate.add(l);
                    leadsInForUpdate.add(pr.Deal_Registration__c);
                }
            }
            if(!leadListToUpdate.isEmpty()){
                try{
                    update leadListToUpdate;
                } catch (System.DmlException e) {
                    GAM.CreateLogs('PartnerRelationshipTriggerHandler:updateLead'+e.getMessage(), leadListToUpdate, 'LeadsToUpdate');            
                }
            }
        }
    }
    // <T02> End
    //<SALESRT-15120> Start
    /**
     * @description : This method is used to get custom permission assignment & user exemption
     * 
     * @return : Boolean
     * */ 
    public static Boolean getExemption(){
        User_Exemptions__c ue = User_Exemptions__c.getInstance();
        CustomPermissionsReader cpr = new CustomPermissionsReader();// to check the user permission
        Boolean IsExemptUser = (cpr.hasPermission('SystemAdmin') || cpr.hasPermission('IntegrationUser') || ue.Ignore_Validation_Rules__c);

        return IsExemptUser;
    }
    //<SALESRT-15120> End
}