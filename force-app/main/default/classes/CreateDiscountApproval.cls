/*
Class:          CreateDiscountApproval
@Author:        Abhishek Yadav
@Created Date:  18th July 2013
@Description:   To populate the initial fields required to initiate in the approval process.

Updated By       :- Abhishek
Updated On       :- Oct-08-2013
Purpose          :- SS-3239 - Email Alerts for Sales Specialist Discount Approval Alerts
Tag               : - T01        

Updated By      :- Balaji Prabhakaran
Updated On      :- Nov-22-2013
Purpose         :- SS-3411 - Automate the insert of ELA Negotiator into approval chain. 
Added logic to shift the approvers if there are any empty approvers in between.
Tag             :- T02        

Updated By      :- Balaji Prabhakaran
Updated On      :- Feb-14-2014
Purpose         :- SS-4196 - Automate the insert of SS SVP into approval chain 
Tag             :- T03 

Updated By      :- Prasanth Sagar
Updated On      :- Mar-03-2014
Purpose         :- Error in quering the User records after Service cloud data migration of Customer Portal Users. 
Added a condition in the query to retrieve only the users with Standard and CsnOnly license.
Tag             :- T04 

*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.        Requested By        Description                                                 Tag
********************************************************************************************************************************************
rsampath    27-Apr-2015         SALES-2299      April               Add AVP before SVP as Approver to accomodate new
Territory hierarchy changes for Americas                    T05

rsampath    26-June-2015        SALES-2637      ansrivastava        Added logic for SS Director approval                        T06 

rsampath    07-Aug-2015         SALES-2907      ansrivastava        Added logic for Maintenance Exception Approval              T07    

rsampath    12-Oct-2015         SALES-3200      Arijit              Handle larger prefixes in Custom Settings and
Code optimization to remove redundant code                  T08              

rsampath    14-Jun-2016         SALES-3919      Sunil               Discount Approval Matrix Enhancement to 
include Subscription                                        T09

rsampath    4-Jul-2016          SALES-4021      Sunil               Discount Approval Driven By should default to SS, 
if not opty Driven By = Field or Inside Sales.              T10

Vaishali Singh  (Deloitte)                                          Logic for Approver Assignment .                                                                                    

vwarrier    5-Oct-2018          SALESRT-3773    Liz Mathews         Changing logic to accommodate three levels of territory
specification                                               T11  

vwarrier    27-Dec-2018         SALESRT-3965    Prashanth Gowda     Changing logic to accommodate the changing territory system T12

cgowda      3-Aug-2021          SALESRT-13213   Liz                Update AVP to Meric Tukoglu for DA when Driven By is Inside Sales T13

Ndevdhar  26-Aug-2021      SALESRT-12317  Chitra        Adding Tim Boe as compliance Approver T14

ramravi      28-Oct-2021      SALESRT-13254  Chitra        Replace Alison Walton with "Da-Thao Becker' when Alison is one of the approvers for APAC opportunity Discount Approval  <SALESRT-13254>
plohia      1-Mar-2022          SALESRT-13632   Ramya J             Replace Alison Walton with Karin Bartha for Tier 2 (EMEA related) opportunity discount approval <SALESRT-13632>
VENKATESH BALLA 10-19-2023      SALESRT-17746                       Route EVP level approvals to ChiefOfStaff.
*/    

/**
* For initail setup to Populate all the fields required for Approval Proccess
*
* @param :List of DiscountApproval and Set Of Opportunity ID's
* @return Void
* @throws exception-N/A
*/

Public Class CreateDiscountApproval{
    
    
    //-------------------------------------------------------T01
    Public static Map<id,user> mapUsers =  new Map<id,user>();
    
    //<T08>---------------------------------------------------------------------
    public static Map<id,Opportunity> mapOpportunity = new Map<id,Opportunity>();
    public static Map<String, Id> mapOfUserNameId = new Map<String,Id>();
    public static final String OPPLICENSE_SMALL = 'Lic-S';
    public static final String OPPLICENSE_MED = 'Lic-M';
    public static final String OPPLICENSE_LARGE = 'Lic-L';
    public static final String OPPLICENSE_XLARGE = 'Lic-XL';
    public static final String OPPLICENSE_XXLARGE = 'Lic-XXL';
    //<T09>-----------------------------------------------------------------------------------------------
    // Initialize variables for 'Subscription' sizing
    public static final String OPPSUB_SMALL = 'Sub-S';
    public static final String OPPSUB_MED = 'Sub-M';
    public static final String OPPSUB_LARGE = 'Sub-L';
    public static final String OPPSUB_XLARGE = 'Sub-XL';
    public static final String OPPSUB_XXLARGE = 'Sub-XXL';
    //</T09>----------------------------------------------------------------------------------------------
    //</T08>---------------------------------------------------------------------
    
    public static Map<id,user> users()
    {
        //----------------------------------------------T04
        // Query changed by Prasanth to retrieve only standard users and CsnOnly users.
        // return new Map<id,user>([select id,Managerid,isActive from user]);
        return new Map<id,user>([select id,Managerid,isActive from user where UserType in ('Standard', 'CsnOnly')]);
        //----------------------------------------------T04
    }
    //-------------------------------------------------------T01
    
    public static void createApproval(List<DiscountApproval__c> approval,Set<id> opportunityId, Boolean fire)
    {    
        try
        {
            //-------------------------------------------------------T01
            mapUsers = users();
            //-------------------------------------------------------T01
            
            Decimal intLicenseCost;
            
            for(Opportunity opp:[SELECT OwnerID,Territory2Id,Territory2.Name,Amount,currencyIsoCode,closeDate,PT_INFA_License_Compliance__c, Account.Account_Hold_Reasons__c from Opportunity WHERE id in : opportunityId])
            {
                mapOpportunity.put(opp.Id,opp);
            }           
            Map<String,id> terrMap = new Map<String,id>();
            Map<String,Id> mapOfTerrArea = new Map<String,Id>();
            //<T06>------------------------------------------------------------
            Map<String,String> mapOfTerritorySSApprover = new Map<String,String>();
            List<String> listOfSSDirectorApprovers = new List<String>();
            
            //-------------------------------------------------------------</T06>
            
            //<T07>----------------------------------------------------
            Map<String,String> mapOfTerritoryMaintExcApprover = new Map<String,String>();
            List<String> listOfMainExcApprovers = new List<String>();
            //------------------------------------------------------</T07>
            
            if(fire)
            { 
                // Update the approvers on the Discount approval record [Vaishali Singh]
                CreateDiscountApproval.approverAssignment(approval, true, false, false);
                
                // Get all the value of SS Director Approvers and create a map of Territory Name and corresponding Approver
                for(DiscountApproval_SS_Director__c terrApprover : [SELECT Territory_Prefix__c, SS_Director__c, Maintenance_Term_Exception_Approver__c FROM DiscountApproval_SS_Director__c])
                {
                    String terrPrefix = terrApprover.Territory_Prefix__c;
                    mapOfTerritorySSApprover.put(terrPrefix, terrApprover.SS_Director__c);
                    mapOfTerritoryMaintExcApprover.put(terrPrefix, terrApprover.Maintenance_Term_Exception_Approver__c);
                }
                
                
                for(User usr :[SELECT Name, Username, Id FROM User WHERE Username IN :mapOfTerritorySSApprover.values() OR Username IN :mapOfTerritoryMaintExcApprover.values()])
                {
                    mapOfUserNameId.put(usr.Username, usr.Id);
                }                
            }
            
            for(DiscountApproval__c approve:approval){
                
                
                intLicenseCost = 0;                                        
                
                system.debug(approve);
                system.debug(mapOpportunity.get(approve.opportunity__c).ownerId);
                system.debug(fire);
                //should be calculated only upon creation    
                if(fire)
                {
                    if(mapOpportunity.get(approve.opportunity__c).Territory2Id!=null){
                        approve.SS_Director__c  = getApprover(approve.Opportunity__c, mapOfTerritorySSApprover);
                    }                                         
                    //<T14>--------------------------------------------------------------------------------
                    //Setting the Compliance Approver if INFA License Compliance is true 
                    if(mapOpportunity.get(approve.opportunity__c).PT_INFA_License_Compliance__c == true){
                       approve.Compliance_Approver__c = system.Label.Compliance_Approver; 
                    }
                    
                    //---------------------------------------------------------------------------------</T14>                    
                    //Setting the Opportunity Owner
                    approve.OpportunityOwner__c = mapOpportunity.get(approve.opportunity__c).ownerId;  
                    
                    //Setting the Discount Approval Currency
                    approve.currencyIsoCode = mapOpportunity.get(approve.opportunity__c).currencyIsoCode;                                                                                                                                                     
                }
                
                //Calculating the Opportunity Size based on Discount Estimated List Price
                if(approve.estimateListPrice__c!=null)
                {
                    if(!approve.currencyIsoCode.equalsIgnoreCase('USD')){
                        intLicenseCost = convertCurrency(approve.estimateListPrice__c,approve.currencyIsoCode,'USD').SetScale(2);
                    }   
                    else
                        intLicenseCost = approve.estimateListPrice__c;
                }
                
                //<T08> -----------------------------------------------------------------------------------------------------------
                //Used constant variables instead of hardcoding the constants
                //<T09>-----------------------------------------------------------------------------------------------------------
                //SALES-3919 : Set Size variables based on Estimate List Price and Discount Approval Type
                if(approve.Discount_Approval_Type__c != null && approve.Discount_Approval_Type__c == 'License'){
                    if(intLicenseCost<=100000)
                        approve.OpportunityLicense__c = OPPLICENSE_SMALL;
                    else if(intLicenseCost>=100000.01 && intLicenseCost <=350000.00)
                        approve.OpportunityLicense__c = OPPLICENSE_MED;
                    else if(intLicenseCost>=350000.01 && intLicenseCost <=1000000.00)
                        approve.OpportunityLicense__c = OPPLICENSE_LARGE;
                    else if(intLicenseCost>=1000000.01 && intLicenseCost<=5000000.00)   
                        approve.OpportunityLicense__c = OPPLICENSE_XLARGE;  
                    else if(intLicenseCost>=5000000.01)   
                        approve.OpportunityLicense__c = OPPLICENSE_XXLARGE;   
                } 
                if(approve.Discount_Approval_Type__c != null && approve.Discount_Approval_Type__c == 'Subscription'){
                    if(intLicenseCost<=10000)
                        approve.OpportunityLicense__c = OPPSUB_SMALL;
                    else if(intLicenseCost>=10000.01 && intLicenseCost <=35000.00)
                        approve.OpportunityLicense__c = OPPSUB_MED;
                    else if(intLicenseCost>=35000.01 && intLicenseCost <=100000.00)
                        approve.OpportunityLicense__c = OPPSUB_LARGE;
                    else if(intLicenseCost>=100000.01 && intLicenseCost<=250000.00)   
                        approve.OpportunityLicense__c = OPPSUB_XLARGE;  
                    else if(intLicenseCost>=250000.01)   
                        approve.OpportunityLicense__c = OPPSUB_XXLARGE;   
                } 
                //</T09>--------------------------------------------------------------------------------------------------------------
                //</T08>-------------------------------------------------------------------------------------------------------------
            }
        }   
        catch(Exception ex)
        {            
            approval[0].addError(ex.getMessage());
        } 
        system.debug(approval[0].OpportunityOwner__c);                                                      
    }
    
    
    /**
* To autoPopulate all the approvers required for Approval Proccess
*
* @param :List of DiscountApproval
* @return Void
* @throws exception-N/A
*/
    
    public static void addApprovers(List<DiscountApproval__c> approval,Boolean fire)
    {
        
        try 
        {    
            //-------------------------------------------------------T01
            if(mapUsers==null || mapUsers.isEmpty())
            {
                mapUsers =  users();
            } 
            //-------------------------------------------------------T01
           
            //  <SALESRT-13254> starts
            String Approverlist = label.FindReplaceApprovers; 
            Map<String,String> Find_Replace_Map = new Map<String,String>();
            if(Approverlist!=null)
            {               
                for(String str : Approverlist.split(';'))
                {Find_Replace_Map.put(str.split('-')[0].trim(),str.split('-')[1].trim());}                         
            }
            
            //SALESRT-13832
            set<Id> oppIdSet = new set<Id>();

            if(mapOpportunity.size() == 0) {

                for(DiscountApproval__c approve : approval) {
                    if(approve.Opportunity__c != null) {
                        oppIdSet.add(approve.Opportunity__c);
                    }
                }
                for(Opportunity opp: [SELECT OwnerID,Territory2Id,Territory2.Name,Amount,currencyIsoCode,closeDate,PT_INFA_License_Compliance__c, Account.Account_Hold_Reasons__c 
                                      FROM Opportunity 
                                      WHERE Id IN : oppIdSet]) 
                {
                    mapOpportunity.put(opp.Id,opp); 
                }
            }
            
            //  <SALESRT-13254> ends
            for(DiscountApproval__c approve:approval){               
                
                //for SS - 3181 Notifying Additional Approvers    
                approve.AdditionalNotification__c = false;  
                //End of update 
                //-------------------------------------------------------T01   
                approve.NotifySVP__c = false;
                //-------------------------------------------------------T01  
                
                //<T03>-------------------------------------------------------
                //First reset the value
                approve.SVP_Approval_Required__c = false;
                //-------------------------------------------------------</T03>  
                
                //User Set To prevent Multiple addition of a single user                
                Set<String> userSet = new Set<String>();
                
                //Addition of approvers based on the custom Setting   
                String owner1up,owner2up,FR1UP,FR2up;
                
                system.debug(approve.OpportunityOwner__c);
                system.debug(approve);
               
                //Discount requests to EVP should only occur for the specific hardcoded Tiers, SIzes, Discount levels.
                if(mapUsers.get(approve.OpportunityOwner__C).ManagerID!=label.EVP && approve.OpportunityOwner__C!=label.EVP && 
                   mapUsers.get(approve.OpportunityOwner__C).ManagerID!=label.CEO && approve.OpportunityOwner__C!=label.CEO)
                    owner1up = mapUsers.get(approve.OpportunityOwner__c).managerId; 
                
                if(owner1up!=null && mapUsers.get(owner1Up).ManagerID!=label.EVP && 
                   mapUsers.get(owner1Up).ManagerID!=label.CEO)
                    owner2up =  mapUsers.get(owner1Up).ManagerID;   
                
                if(approve.FieldRep__c!=null && mapUsers.get(approve.FieldRep__c).ManagerID!=label.EVP && 
                   mapUsers.get(approve.FieldRep__c).ManagerID!=label.CEO)
                    FR1up = mapUsers.get(approve.FieldRep__c).ManagerID;
                
                if(fr1up!=null && mapUsers.get(FR1up).ManagerID!=label.EVP && 
                   mapUsers.get(FR1up).ManagerID!=label.CEO)
                    FR2up = mapUsers.get(FR1up).ManagerID;
                
                //End of Discount requests to EVP should only occur for the specific hardcoded Tiers, SIzes, Discount levels.              
                for(Discount_Approval_Matrix__c disc:[SELECT ApproverSeq__c,DrivenBy__C, MinDiscount__c, OpportunitySize__c, OpportunityTier__c, RecordApprover__c, TopApprover__c FROM Discount_Approval_Matrix__c])
                {   
                    
                    
                    //Addition of Approvers   
                    if(disc.DrivenBy__C.equalsIgnorecase(approve.DrivenBy__C)
                       && disc.OpportunitySize__c.eQualsIgnoreCase(approve.opportunityLicense__c)
                       && disc.OpportunityTier__c==approve.Tier__c
                       && approve.discount__c > disc.MinDiscount__c)
                    {
                        System.debug('   to assign approver users');
                        //<T08>--------------------------------------------------------------------------------------------------------------------------
                        // Code optimization done to modularize the logic inside each of the approver loops
                        //addtional check to ensure EVP approval only for hardcoded scenario's
                        if(disc.RecordApprover__c.equalsIgnoreCase('OppOwner') && approve.OpportunityOwner__C!=label.EVP
                           && approve.OpportunityOwner__C!=label.CEO)
                        {
                            //approve.put('Approver'+integer.valueOf(disc.ApproverSeq__c)+'__c', approve.OpportunityOwner__C); 
                            setApproverSeq(disc.ApproverSeq__c, approve.OpportunityOwner__C, approve);
                        }                        
                        if( owner1up!=null && disc.RecordApprover__c.equalsIgnoreCase('Owner1up'))
                        {
                            setApproverSeq(disc.ApproverSeq__c, Owner1up, approve);              
                        }
                        else if(Owner2up!=null && disc.RecordApprover__c.equalsIgnoreCase('Owner2up'))
                        {
                            setApproverSeq(disc.ApproverSeq__c, Owner2up, approve);                          
                        }
                        else if(approve.FieldRep__c!=null && disc.RecordApprover__c.equalsIgnoreCase('FR') && approve.FieldRep__c!=Label.EVP
                                && approve.FieldRep__c!=Label.CEO)
                        {
                            setApproverSeq(disc.ApproverSeq__c, approve.FieldRep__c, approve); 
                        }
                        else if(FR1up!=null && disc.RecordApprover__c.equalsIgnoreCase('FR1up'))
                        {
                            setApproverSeq(disc.ApproverSeq__c, FR1up, approve); 
                        }
                        else if(FR2up!=null && disc.RecordApprover__c.equalsIgnoreCase('FR2up'))
                        {
                            setApproverSeq(disc.ApproverSeq__c, FR2up, approve);
                        }
                        
                        //<T06>---------------------------------------------------------------------
                        // Add SS Director as one of the Approvers to the list of Approver fields in Discount Approval
                        else if(disc.RecordApprover__c.equalsIgnoreCase('SSDirector'))
                        {                                     
                            //addtional check to ensure EVP approval only for hardcoded scenario's
                            if(approve.SS_Director__c!=null && approve.SS_Director__c!=label.EVP && approve.SS_Director__c!=label.CEO){
                                setApproverSeq(disc.ApproverSeq__c, approve.SS_Director__c, approve); 
                            }
                            
                        }
                        
                        //----------------------------------------------------------------------</T06>
                        
                        //<T05>------------------------------------------------------------------------------
                        else if(disc.RecordApprover__c.equalsIgnoreCase('AVP'))
                        { 
                            
                            //addtional check to ensure EVP approval only for hardcoded scenario's
                            if(approve.AVP__c!=null && approve.AVP__c!=label.EVP && approve.AVP__c!=label.CEO){
                                setApproverSeq(disc.ApproverSeq__c, approve.AVP__c, approve); 
                                
                            }
                            
                        }
                        
                        //</T09>-------------------------------------------------------------------------------------------------------
                        //----------------------------------------------------------------------</T07>
                        
                        else if(disc.RecordApprover__c.equalsIgnoreCase('SVP'))
                        { 
                            //<T03>-------------------------------------------------------
                            approve.SVP_Approval_Required__c = true;
                            //-------------------------------------------------------</T03>  
                            
                            //addtional check to ensure EVP approval only for hardcoded scenario's
                            if(approve.svp__c!=null && approve.svp__c!=label.EVP && approve.svp__c!=label.CEO){
                                setApproverSeq(disc.ApproverSeq__c, approve.svp__c, approve);
                                
                                //-------------------------------------------------------T01   
                                approve.NotifySVP__c = true;
                                //-------------------------------------------------------T01  
                            }
                            
                        }
                        else if(disc.RecordApprover__c.equalsIgnoreCase('EVP'))
                        {
                            //Commented for <SALESRT-17746>
                            //setApproverSeq(disc.ApproverSeq__c, label.EVP, approve);
                            setApproverSeq(disc.ApproverSeq__c, label.ChiefOfStaff, approve);
                            //for SS - 3181 Notifying Additional Approvers                         
                            
                            approve.AdditionalNotification__c =true;                       
                            
                            // End Of Update 
                        }  
                        else if(disc.RecordApprover__c.equalsIgnoreCase('CEO'))
                        {
                            setApproverSeq(disc.ApproverSeq__c, label.ChiefOfStaff, approve);
                        }
                        //</T08>-------------------------------------------------------------------------------
                    }                 
                    //End Of Addition Of Approver
                    
                    //Removal Of Approvers
                    
                    if(disc.DrivenBy__c.equalsIgnorecase(approve.DrivenBy__C)
                       && disc.OpportunitySize__c.eQualsIgnoreCase(approve.opportunityLicense__c)
                       && disc.OpportunityTier__c==approve.Tier__c
                       && approve.discount__c <= disc.MinDiscount__c)
                    {
                        //<T08>----------------------------------------------------------------------------------
                        //SALES-3200 : The code here is moved to a method since the logic is used repeatedly
                        removalOfApprovers(disc.ApproverSeq__c, approve);
                        //</T08>---------------------------------------------------------------------------------
                    }
                    //End of removal of approvers
                    
                    //Removing approvers Beyond the Top Approver
                    
                    if(disc.DrivenBy__c.equalsIgnorecase(approve.DrivenBy__C)
                       && disc.OpportunitySize__c.eQualsIgnoreCase(approve.opportunityLicense__c)
                       && disc.OpportunityTier__c==approve.Tier__c
                       && disc.TopApprover__c)
                    {
                        //<T08>----------------------------------------------------------------------------------
                        //SALES-3200 : The code here is moved to a method since the logic is used repeatedly
                        removalOfApprovers(disc.ApproverSeq__c+1, approve); 
                        //</T08>---------------------------------------------------------------------------------  
                    }
                    //End of removal of approvers beyond Top Approver
                }                
               
                    /*  <SALESRT-13254>  starts
                         Replace Alison Walton with "Da-Thao Becker' 
                         when Alison is one of the approvers for APAC opportunity Discount Approval */                    
                    if( approve.tier__c!= null && approve.tier__c == decimal.valueOf(3) && Find_Replace_Map!=null )                                      
                    {
                        for(integer i=1; i< 11 ; i++)
                        {
                            String approverSeq = 'Approver'+integer.valueOf(i)+'__c' ;
                            system.debug(approve.get(approverSeq));
                            string approverIDToFind = string.valueOf(approve.get(approverSeq));
                            if( approve.get(approverSeq) != null && Find_Replace_Map.containsKey('3_'+approverIDToFind) )
                            {
                                setApproverSeq(i,Find_Replace_Map.get('3_'+approverIDToFind),approve); 
                            }     
                        }                                             
                    }              
                    //  <SALESRT-13254>  ends
                    // <SALESRT-13632> start
                    if( approve.tier__c!= null && approve.tier__c == decimal.valueOf(2) && Find_Replace_Map!=null )                                      
                    {
                        for(integer i=1; i< 11 ; i++)
                        {
                            String approverSeq = 'Approver'+integer.valueOf(i)+'__c' ;
                            system.debug(approve.get(approverSeq));
                            string approverIDToFind = string.valueOf(approve.get(approverSeq));
                            if( approve.get(approverSeq) != null && Find_Replace_Map.containsKey('2_'+approverIDToFind) )
                            {
                                setApproverSeq(i,Find_Replace_Map.get('2_'+approverIDToFind),approve); 
                            }     
                        }                                             
                    } 
                    // <SALESRT-13632> end
                //Remove Inactive Users Begins
                List<Id> lstValidApprovers = new List<Id>();
                //<T08>---------------------------------------------------------------------------------------------------------------------
                //Commented code for removing approvers being added twice and added condition here
                if(approve.Approver1__c != null && mapUsers.get(approve.Approver1__c).isactive){
                    lstValidApprovers.add(approve.Approver1__c);
                }
                
                if(approve.Approver2__c != null && mapUsers.get(approve.Approver2__c) != null && mapUsers.get(approve.Approver2__c).isactive && !userSet.contains(approve.Approver2__c)){
                    userSet.add(approve.Approver2__c);
                    lstValidApprovers.add(approve.Approver2__c);
                }
                
                if(approve.Approver3__c != null && mapUsers.get(approve.Approver3__c).isactive && !userSet.contains(approve.Approver3__c)){
                    userSet.add(approve.Approver3__c);
                    lstValidApprovers.add(approve.Approver3__c);
                }
                
                if(approve.Approver4__c != null && mapUsers.get(approve.Approver4__c).isactive && !userSet.contains(approve.Approver4__c)){
                    userSet.add(approve.Approver4__c);
                    lstValidApprovers.add(approve.Approver4__c);
                }
                
                if(approve.Approver5__c != null && mapUsers.get(approve.Approver5__c).isactive && !userSet.contains(approve.Approver5__c)){
                    userSet.add(approve.Approver5__c);
                    lstValidApprovers.add(approve.Approver5__c);
                }
                
                if(approve.Approver6__c != null && mapUsers.get(approve.Approver6__c).isactive && !userSet.contains(approve.Approver6__c)){
                    userSet.add(approve.Approver6__c);
                    lstValidApprovers.add(approve.Approver6__c);
                }
                
                if(approve.Approver7__c != null && mapUsers.get(approve.Approver7__c).isactive && !userSet.contains(approve.Approver7__c)){
                    userSet.add(approve.Approver7__c);
                    lstValidApprovers.add(approve.Approver7__c);
                }
                
                if(approve.Approver8__c != null && mapUsers.get(approve.Approver8__c).isactive && !userSet.contains(approve.Approver8__c)){
                    userSet.add(approve.Approver8__c);
                    lstValidApprovers.add(approve.Approver8__c);
                }
                
                if(approve.Approver9__c != null && mapUsers.get(approve.Approver9__c).isactive && !userSet.contains(approve.Approver9__c)){
                    //userSet.add(approve.Approver9__c);
                    //lstValidApprovers.add(approve.Approver9__c);
                }
                
                //<T07>--------------------------------------------    
                if(approve.Approver10__c != null && mapUsers.get(approve.Approver10__c).isactive && !userSet.contains(approve.Approver10__c)){
                    //userSet.add(approve.Approver10__c);
                    //lstValidApprovers.add(approve.Approver10__c);
                }
                
                //---------------------------------------------------</T07>   
                
                //Remove Inactive Users Ends                                    
                
                //-------------------------------------------------------------------</T08>
                
                //Assigning Approvers from the list after NULL removal     
                approve.Approver1__c =  null; 
                approve.Approver2__c =  null; 
                approve.Approver3__c =  null; 
                approve.Approver4__c =  null;  
                approve.Approver5__c =  null;  
                approve.Approver6__c =  null;  
                approve.Approver7__c =  null;  
                approve.Approver8__c =  null;  
                //approve.Approver9__c =  null;
                //<T07>------------------------------
                //approve.Approver10__c =  null; 
                //-------------------------------</T07>  
                
                if (lstValidApprovers.size()>=1){
                    approve.Approver1__c = lstValidApprovers.get(0);
                }
                if (lstValidApprovers.size()>=2){
                    approve.Approver2__c = lstValidApprovers.get(1);
                }
                
                if (lstValidApprovers.size()>=3){
                    approve.Approver3__c = lstValidApprovers.get(2);
                }
                
                if (lstValidApprovers.size()>=4){
                    approve.Approver4__c = lstValidApprovers.get(3);
                }
                
                if (lstValidApprovers.size()>=5){
                    approve.Approver5__c = lstValidApprovers.get(4);
                }
                
                if (lstValidApprovers.size()>=6){
                    approve.Approver6__c = lstValidApprovers.get(5);
                }
                
                if (lstValidApprovers.size()>=7){
                    approve.Approver7__c = lstValidApprovers.get(6);
                }
                
                if (lstValidApprovers.size()>=8){
                    approve.Approver8__c = lstValidApprovers.get(7);
                }
                
                /*if (lstValidApprovers.size()>=9){
                    approve.Approver9__c = lstValidApprovers.get(8);
                }*/
                //<T07>-------------------------------------------------------
                /*if (lstValidApprovers.size()>=10){
                    approve.Approver10__c = lstValidApprovers.get(9);
                }*/
                //---------------------------------------------------------</T07>

                //SALESRT-13832 -For Credit Hold & Legal Hold Approver (Approver 9 & 10)
                if(mapOpportunity != null && mapOpportunity.containsKey(approve.opportunity__c) && mapOpportunity.get(approve.opportunity__c).Account.Account_Hold_Reasons__c != null && approve.tier__c != null ) {
                                    
                    if(mapOpportunity.get(approve.opportunity__c).Account.Account_Hold_Reasons__c.contains( 'Credit&Collections' )) {
                        for(String creditHoldApprover : label.Credit_Hold_Approver.split(';')) {
                            if(creditHoldApprover != null && creditHoldApprover !='' && approve.tier__c == Integer.valueOf(creditHoldApprover.left(creditHoldApprover.length() -(creditHoldApprover.length() -1))) ) {
                                approve.Approver10__c = creditHoldApprover.right(creditHoldApprover.length()-2); 
                            }
                        }     
                    } 

                    if(mapOpportunity.get(approve.opportunity__c).Account.Account_Hold_Reasons__c.contains( 'Legal' )) {
                        for(String legalHoldApprover : label.Legal_Hold_Approver.split(';')) {
                            if(legalHoldApprover != null && legalHoldApprover !='' && approve.tier__c == Integer.valueOf(legalHoldApprover.left(legalHoldApprover.length() -(legalHoldApprover.length() -1)))) {
                                approve.Approver9__c = legalHoldApprover.right(legalHoldApprover.length()-2); 
                            }
                        }    
                        
                    } 
                }// end


            }                              
        }catch(Exception ex){
            approval[0].addError(ex.getMessage());    
        }
    } 

    public static void skipApprover1(list<DiscountApproval__c> approval)
    {
        //If Opportunity Owner and Discount requestor are same Skipping Approver1.
        for(DiscountApproval__c approve:approval)
        {
            if(approve.Approver1__c==userInfo.getUserID())
            {
                approve.Approver1__C = approve.Approver2__C;
                approve.Approver2__C = approve.Approver3__C;
                approve.Approver3__C = approve.Approver4__C;
                approve.Approver4__C = approve.Approver5__C;
                approve.Approver5__C = approve.Approver6__C;
                approve.Approver6__C = approve.Approver7__C;
                approve.Approver7__C = approve.Approver8__C;
                //approve.Approver8__C = approve.Approver9__C;
                //<T07>---------------------------------------------------------
                //approve.Approver9__C = approve.Approver10__C;
                //---------------------------------------------------------</T07>
            }
            //End of skipping  
        }
    }
    
    //<T08>--------------------------------------------------------------------------------------------------------------------
    private static void removalOfApprovers(decimal discApproverSequence, DiscountApproval__c approve){
        /*if(discApproverSequence <= 10){
            approve.Approver10__c =  null; 
        }
        if(discApproverSequence <= 9){
            approve.Approver9__c =  null; 
        }*/
        if(discApproverSequence <= 8){ 
            approve.Approver8__c =  null;  
            
        }
        if(discApproverSequence <= 7){ 
            approve.Approver7__c =  null;  
        }
        if(discApproverSequence <= 6){
            approve.Approver6__c =  null;  
        }
        if(discApproverSequence <= 5){
            approve.Approver5__c =  null;  
            
        }
        if(discApproverSequence <= 4){
            approve.Approver4__c =  null;  
        }
        if(discApproverSequence <= 3){
            approve.Approver3__c =  null;
        }
        if(discApproverSequence <= 2){
            approve.Approver2__c=null;
        } 
        
    }
    // uncommented as a part of relaese1 - as the ss director was not getting populated
    private static Id getApprover(Id opptyId, Map<String, String> mapPrefixToApprover){
        Id idApprover;
        system.debug(opptyId);
        if(mapOpportunity.get(opptyId) != null && mapOpportunity.get(opptyId).Territory2Id!=null ){
            
            String terrName = mapOpportunity.get(opptyId).Territory2.Name;
            
            idApprover = mapOfUserNameId.get(mapPrefixToApprover.get('Others'));
            for(String terrPrefix : mapPrefixToApprover.keySet()){
                if(terrName.startsWith(terrPrefix) && mapPrefixToApprover.get(terrPrefix) != null && mapOfUserNameId.get(mapPrefixToApprover.get(terrPrefix)) != null){
                    idApprover = mapOfUserNameId.get(mapPrefixToApprover.get(terrPrefix));
                    break;
                }
                
            }
        }
        return idApprover;
    }
    
    private static void setApproverSeq(Decimal approverSeq, String approverLabel, DiscountApproval__c approvalRecord){
        approvalRecord.put('Approver'+integer.valueOf(approverSeq)+'__c', approverLabel);
        
    }
    
    //</T08>----------------------------------------------------------------------------------------------------------------------------
    
    /*Code For Currency Conversion */
    
    public static map<string, decimal> currencyMap = getCOnvertedRates();
    
    public static Map<string, decimal> getCOnvertedRates(){
        currencyMap = new map<string, double>();
        list<CurrencyType> currLst = [Select IsoCode, IsCorporate, IsActive, ConversionRate From CurrencyType];
        for(CurrencyType curr : currLst)
            currencyMap.put(curr.IsoCode, curr.ConversionRate);
        return currencyMap;
    }
    
    public static decimal convertCurrency(decimal sorRate, string sorCurr, string destCurr){
        decimal val =(sorRate /  currencyMap.get(sorCurr))*(currencyMap.get(destCurr));
        return val;     
    }
    
    /*
*  @author           Vaishali Singh (Deloitte) 
*  @description      Approver Assignment based on the Account Role
*  @param            List of DiscountApproval records
*  @return           void
*/
    
    public static void approverAssignment(List<DiscountApproval__c> lstApproval, Boolean bolOppTrigger, Boolean bolOppTMTrigger, Boolean bolUpdate){
        
        // get all the assocaiated account ids from the DiscountApproval records
        Set<Id> setAccId = new Set<Id>();
        Set<Id> setOppId = new Set<Id>();
        //Map<Id, List<DiscountApproval__c>> mapAccIdDiscAppr = new Map<Id, List<DiscountApproval__c>>();
        Map<Opportunity, List<DiscountApproval__c>> mapOppDiscAppr = new Map<Opportunity, List<DiscountApproval__c>>();
        Map<Id, Opportunity> mapIdOpp = new Map<Id,Opportunity>();
        List<DiscountApproval__c> lstUpdateDiscApp = new List<DiscountApproval__c>();
        String strSalesRep = Label.DA_Field_Sales_Rep;
        for(DiscountApproval__c sobjDiscApproval : lstApproval){
            setOppId.add(sobjDiscApproval.Opportunity__c);
        }
        for(Opportunity objOpp:[SELECT Id,AccountId, Territory2.Name from Opportunity WHERE id in : setOppId]){
            mapIdOpp.put(objOpp.Id,objOpp);
        }
        List<DiscountApproval__c> lstDiscApp = new List<DiscountApproval__c>();
        Opportunity objOppFromMap = new Opportunity();
        for(DiscountApproval__c sobjDiscApproval : lstApproval){
            objOppFromMap = mapIdOpp.get(sobjDiscApproval.Opportunity__c);
            // create a map of opportunity record and all the discount approvals
            if(mapOppDiscAppr.containskey(objOppFromMap)){
                lstDiscApp =  mapOppDiscAppr.get(objOppFromMap);
                lstDiscApp.add(sobjDiscApproval);
                mapOppDiscAppr.put(objOppFromMap,lstDiscApp);
            }
            else{
                mapOppDiscAppr.put(objOppFromMap, new List<DiscountApproval__c> {sobjDiscApproval});
            }
        }
        
        // get all the custom setting values to populate SVP and AVP
        if(bolOppTrigger && !bolOppTMTrigger){
            Map<String,Discount_Approver_Matrix__c> mapDisApprValues = Discount_Approver_Matrix__c.getAll();
            List<Discount_Approver_Matrix__c> lstDiscAppMatrix = Discount_Approver_Matrix__c.getAll().values();
            Set<String> setStringEmails = new Set<String>();
            for(Discount_Approver_Matrix__c sobjAppMatrix : lstDiscAppMatrix){
                setStringEmails.add(sobjAppMatrix.AVP__c);
                setStringEmails.add(sobjAppMatrix.SVP__c);
                setStringEmails.add(sobjAppMatrix.Inside_Sales_AVP__c);
            }
            List<User> lstUser = [Select id, Email, Username from User where Username IN:setStringEmails];
            Map<String,Id> mapUsernameUserId = new Map<String,Id>();
            for(User sobjUser : lstUser){
                mapUsernameUserId.put(sobjUser.Username,sobjUser.Id);   
            }
            String strTerrName = '';
            Integer firstIndex = 0;
            Integer secondIndex = 0;
            Integer thirdIndex = 0;
            String strTerrPrefix = '';
            Opportunity objOpp = new Opportunity();
            for(DiscountApproval__c sobjDiscApproval : lstApproval){
                objOpp = mapIdOpp.get(sobjDiscApproval.Opportunity__c);
                
                if(objOpp.Territory2 != null){
                    strTerrName = objOpp.Territory2.Name; //Fetching the territory name from the Opportunity
                    
                    firstIndex = strTerrName.indexOf('_'); 
                    secondIndex = strTerrName.indexOf('_', firstIndex + 1);
                    thirdIndex = strTerrName.indexOf('_', secondIndex + 1); //Storing the index of the third '_'
                    strTerrPrefix = strTerrName.left(thirdIndex); //Got the territory prefix upto the third level 
                    
                    //</T12>
                    if(mapDisApprValues.get(strTerrPrefix) != null){ //Checking if the third level exists in the Custom Setting 'mapDisApprValues' or Discount Approver Matrix
                        if(strTerrPrefix == mapDisApprValues.get(strTerrPrefix).Name){ //Get name and compare
                            sobjDiscApproval.SVP__c = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).SVP__c); //Get SVP Value
                            //----------Added the If condition to check for Driven BY----------------<T13>
                            if(sobjDiscApproval.DrivenBy__c == 'Inside Sales'){
                                sobjDiscApproval.AVP__c = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).Inside_Sales_AVP__c);
                            }else{
                                sobjDiscApproval.AVP__c = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).AVP__c); //Get AVP Value
                            }
                            //-----------------------------------------------------------------<T13/>
                            lstUpdateDiscApp.add(sobjDiscApproval);
                        }
                    }
                    else{ //there are no matches for the three-levelled territory prefix in the Custom setting
                        strTerrPrefix = strTerrName.left(secondIndex); //Getting the two-levelled Territory prefix 
                        if(mapDisApprValues.get(strTerrPrefix) != null){ //Comparing the two-levelled territory prefix with the Custom setting 'mapDisApprValues' or Discount Approver Matrix
                            if(strTerrPrefix == mapDisApprValues.get(strTerrPrefix).Name){ //Get name and compare
                                sobjDiscApproval.SVP__c = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).SVP__c); //Get SVP Value
                                //----------Added the If condition to check for Driven BY----------------<T13>
                                if(sobjDiscApproval.DrivenBy__c == 'Inside Sales'){
                                    sobjDiscApproval.AVP__c = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).Inside_Sales_AVP__c);
                                }else{
                                    sobjDiscApproval.AVP__c = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).AVP__c); //Get AVP Value
                                }
                                //-----------------------------------------------------------------<T13/>
                                lstUpdateDiscApp.add(sobjDiscApproval);
                            }
                        }
                    }
                    //</T12>
                }
            }
        }
        // get the team member roles for the opportunity
        if((!bolOppTrigger && !bolOppTMTrigger) || bolOppTrigger){
            List<OpportunityTeamMember> lstOppTeamMem = [Select id, OpportunityId, TeamMemberRole, UserId from OpportunityTeamMember where opportunityId IN : setOppId and TeamMemberRole =:strSalesRep];
            
            // create a map of Opportunity id and Opportunity Team Members
            if(lstOppTeamMem!= null && lstOppTeamMem.size()>0){
                Map<Id, List<OpportunityTeamMember>> mapOppIdOppTeamMem = new Map<Id, List<OpportunityTeamMember>>();
                List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
                for(OpportunityTeamMember objOppTeamMem : lstOppTeamMem){
                    // create a map of account id and all the account members
                    if(mapOppIdOppTeamMem.containskey(objOppTeamMem.OpportunityId)){
                        lstOppTeamMember =  mapOppIdOppTeamMem.get(objOppTeamMem.OpportunityId);
                        lstOppTeamMember.add(objOppTeamMem);
                        mapOppIdOppTeamMem.put(objOppTeamMem.OpportunityId,lstOppTeamMember);
                    }
                    else{
                        mapOppIdOppTeamMem.put(objOppTeamMem.OpportunityId, new List<OpportunityTeamMember> {objOppTeamMem});
                    }
                }
                Opportunity objOpp = new Opportunity();
                for(DiscountApproval__c sobjDiscApproval : lstApproval){
                    objOpp = mapIdOpp.get(sobjDiscApproval.Opportunity__c);
                    for(OpportunityTeamMember objOppMem : mapOppIdOppTeamMem.get(sobjDiscApproval.Opportunity__c)){
                        
                        if(objOppMem.TeamMemberRole == strSalesRep){
                            sobjDiscApproval.FieldRep__c = objOppMem.UserId;
                            lstUpdateDiscApp.add(sobjDiscApproval);
                        }
                    }
                }
            }
        }
        if(bolUpdate){
            if(lstUpdateDiscApp!= null && lstUpdateDiscApp.size()>0){
                try{
                    update lstUpdateDiscApp;
                }catch(Exception e){
                    
                }
                
            }
        }
    }
    //----------Method to update the AVP and approver when Drvien By is updated to Inside Sales----------------<T13>
    public static void updateAVP( Map<Id,DiscountApproval__c> mapUpdateAVP, Map<Id,Id> mapDAOldAVP){
    
        
        Map<String,Discount_Approver_Matrix__c> mapDisApprValues = Discount_Approver_Matrix__c.getAll();
        List<Discount_Approver_Matrix__c> lstDiscAppMatrix = Discount_Approver_Matrix__c.getAll().values();
        Set<String> setStringEmails = new Set<String>();
        for(Discount_Approver_Matrix__c sobjAppMatrix : lstDiscAppMatrix){
            setStringEmails.add(sobjAppMatrix.AVP__c);
            setStringEmails.add(sobjAppMatrix.Inside_Sales_AVP__c);
        }
        List<User> lstUser = [Select id, Email, Username from User where Username IN:setStringEmails];
        Map<String,Id> mapUsernameUserId = new Map<String,Id>();
        for(User sobjUser : lstUser){
            mapUsernameUserId.put(sobjUser.Username,sobjUser.Id);   
        }
        
        Set<Id> setOppId = new Set<Id>();
        Map<Id, Opportunity> mapIdOpp = new Map<Id,Opportunity>();
        for(DiscountApproval__c approval: mapUpdateAVP.values()){
            setOppId.add(approval.Opportunity__c);
        }
        for(Opportunity objOpp:[SELECT Id,AccountId, Territory2.Name from Opportunity WHERE id in : setOppId]){
            mapIdOpp.put(objOpp.Id,objOpp);
        }
    
        
        
        String strTerrName = '';
        Integer firstIndex = 0;
        Integer secondIndex = 0;
        Integer thirdIndex = 0;
        String strTerrPrefix = '';
        for(DiscountApproval__c approval: mapUpdateAVP.values()){
            
            if(mapIdOpp.get(approval.Opportunity__c).Territory2.Name != null){
                strTerrName = mapIdOpp.get(approval.Opportunity__c).Territory2.Name;
                firstIndex = strTerrName.indexOf('_'); 
                secondIndex = strTerrName.indexOf('_', firstIndex + 1);
                thirdIndex = strTerrName.indexOf('_', secondIndex + 1); //Storing the index of the third '_'
                strTerrPrefix = strTerrName.left(thirdIndex);
                String newAvp = '';
                if(mapDisApprValues.get(strTerrPrefix) != null){
                    if(approval.DrivenBy__c == 'Inside Sales'){
                        newAvp = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).Inside_Sales_AVP__c);
                    }else{
                        newAvp = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).AVP__c); //Get AVP Value
                    }
                }else {
                    strTerrPrefix = strTerrName.left(secondIndex);
                    if(mapDisApprValues.get(strTerrPrefix) != null){
                        if(approval.DrivenBy__c == 'Inside Sales'){
                            newAvp = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).Inside_Sales_AVP__c);
                        }else{
                            newAvp = mapUsernameUserId.get(mapDisApprValues.get(strTerrPrefix).AVP__c); //Get AVP Value
                        }
                    }
                }
                
                if(!String.isblank(newAvp)){
                    for(Integer i=1;i<=10;i++){
                        if(approval.get('Approver'+integer.valueOf(i)+'__c') == mapDAOldAVP.get(approval.Id)){
                            approval.put('Approver'+integer.valueOf(i)+'__c',newAvp);
                        }
                    }
                    approval.AVP__c = newAvp;
                }
            }            
        }
    }
    //-----------------------------------------------------------------<T13/>
}