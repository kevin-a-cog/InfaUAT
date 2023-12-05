/*
        Class:          LeadTriggerHandler
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler class for Lead triggers

    Change History
******************************************************************
    ModifiedBy          Date        Requested By        Description                                          Tag
    Kiran G          17-May-2018    Priyanka K        Updated the code to check the 
                                                      duplicate leads only for the Lead RT                   T01
    Kiran G          12-Oct-2018    Richard L         On Insert and Update share the DR with the 
                                                      PSM and FSR                                             T02
 Chandana Gowda      06-Jun-2019    PrashanthG        PRMRT-385 Sharing DR records with PSM                  T03
                                                      with edit acess
  Kiran G            28-Aug-2019    PrasanthG         Replaced OOB PartnerAccountId with 
                                                      Lookup Partner_Account__c                                T04  
  Anusha K           10-Jan-2020    AnthonyFaure      Added a method to populate associated Campaign Series based on the
                                                      MQL Program Name on Lead before insert and before update        T05
 Puneet Lohia        04-Jun-2021    Poojary Hardik    Added a method to change outreach owner to Marketo Integration 
                                                      from Infogenie Integration User.JIRA : SALESRT-13060            <T06> 
  Wasim Akram     16-Jun-2021  Prashanth G      PRMRT 1050 : Ability for VADs to submit a DR and establish a 
                            partner relationship as 1-Tier Reseller Partners             <T07>
Puneet Lohia        1-Dec-2021      Priyanka K         Auto DQ Timestamp field                                  <T08>
Puneet          10/28/2022             SALESRT-14408       Account Predective Bucket Score         <SALESRT-14408>
KAPIL TILWANI     1 Nov-2022    SALESRT-14445 - Deal Registration & Partner Relationship - Enhancements
Puneet          01/02/2023          SALESRT-14990      Salesloft Cadence Automation      <SALESRT-14990>  
VENKATESH BALLA 05/22/2023			SALESRT-14919      Deal Registration Approval Enhancements
VENKATESH BALLA 07/05/2023			SALESRT-17007      Added FSR & PSM comparision to avoid Sharing record deletion if FSR and PSM are same. <SALESRT-17007>
VENKATESH BALLA 09/12/2023			SALESRT-17429      Added method invokeDRApproverVerifyAccess. <SALESRT-17429>
******************************************************************
*/

Public Class LeadTriggerHandler{

    public static globalApexManager GAM = new globalApexManager(); // To create debug logs and exception logs
    public static CustomPermissionsReader csm = new CustomPermissionsReader();// to check the user permission
    public static Boolean IsExemptUser = (csm.hasPermission('SystemAdmin') || csm.hasPermission('IntegrationUser') || csm.hasPermission('SalesSuperUser'));//Check if the current user has Admin,Integration, Superuser permissions
    static List<RecordType> recordTypetList = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = :label.Lead_Record_Type];
    //-----------------------------------------------------------------------------------------<T01>
    public static Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.Marketo_Lead_Record_Type).getRecordTypeId();
    //-----------------------------------------------------------------------------------------</T01>
    /**
    * this method is invoked from before insert event of Lead
    *
    * @param lstNew - list of new leads
    * @return return-void
    * @throws exception - NA
    */
    Public static void LeadBeforeInsert(List<Lead> LstNew)
    { 
        populateOwner(LstNew);//<T06> 
         //-----------------------------------------------------------------------------------------<T01>
        //Added the Marketo Leads with RT as Lead to new list and passing for the duplicate checks
        List<Lead> lstDupeCheckEligible =  new List<Lead>();        
        for(Lead dlead : LstNew){
            if(dlead.RecordTypeId == leadRecordTypeId ){
                lstDupeCheckEligible.add(dlead);
            }
        }
        //-----------------------------------------------------------------------------------------</T01>
        //do not run if the current user is sys admin, integration user, superuser
        if(!IsExemptUser){
            DuplicateCheck(lstDupeCheckEligible);
        }
        updateDistributor(LstNew);
        
        //US-2191 Changes Begun
        DRTypeValidatior(LstNew);
        //US-2191 Changes Ended
        
        populatePSM(LstNew);
        populateCampaignSeries(LstNew, Null);
        autoDQProcess(LstNew,null);
        populateAutoDQTimestamp(LstNew,null); //<T08>
    }
    
    
    

    /**
    * this method is invoked from before update event of Lead
    *
    * @param mapOld- map of old leads
    * @param lstNew - list of new leads
    * @return return-void
    * @throws exception - NA
    */

    Public static void LeadBeforeUpdate( map<Id,Lead> mapOld, List<Lead> LstNew)
    {
        List<lead> LstUpdated = new List<lead>();// list of leads updated with email

        populateCampaignSeries(LstNew,mapOld);
        //do not run if the current user is sys admin, integration user, superuser
        if(!IsExemptUser){
            
            for(Lead l: LstNew){
                //check if the email is updated
                //-----------------------------------------------------------------------------------------<T01>
                //Added the Marketo Leads with RT as Lead to new list and passing for the duplicate checks
                if(mapOld!=null&&((mapOld.get(l.id).email!=null && !mapOld.get(l.id).email.equals(l.email)) || (mapOld.get(l.id).email==null&&l.email!=null)) && l.RecordTypeId == leadRecordTypeId)
                    LstUpdated.add(l);
                //-----------------------------------------------------------------------------------------</T01>
            }
            
            //Call method to check duplicates for the modified leads
            DuplicateCheck(LstUpdated);
            updateDistributor(LstNew);
            
            //US-2191 Changes Begun
            DRTypeValidatior(LstNew);
            //US-2191 Changes Ended
        }
        autoDQProcess(LstNew,mapOld);
        populateAutoDQTimestamp(LstNew,mapOld); //<T08>
    }
    //<T07>
    /**
    * this method is invoked from after insert event of Lead
    * @param lstNew - list of new leads
    * @return return-void
    * @throws exception - NA
    */
    public static void leadAfterInsert(List<Lead> LstNew){
        
        apexSharingAfterInsert(LstNew);
        //validate Reseller SI Deal Reg Type //<T07>
        validateRoleOfDistributor(LstNew);
        LeadTriggerHandler.calculatePredectiveScore(LstNew, null );
    }
    //<T07>
    /**
    * this method is invoked from after insert event of Lead - Allow only Distributor to edit the Role of Distributor field
    * @param triggerNew - list of new leads
    * @return return-void
    * @throws exception - NA
    */
     public static void validateRoleOfDistributor(List<Lead> triggerNew){
        String partnerType = [SELECT Contact.Account.Partner_Type__c FROM User WHERE Id = :userinfo.getUserId()]?.Contact?.Account?.Partner_Type__c;
        
        for(Lead l :triggerNew)
            if(partnerType != label.PRM_DistributorPartnerUserType && String.isNotBlank(l.Role_of_Distributor__c)){
                triggerNew[0].addError(label.PRM_DealRegistration_RoleOfDistributor);
            }
    }
    //<T07>
    /**
    * this method is invoked from after insert event of Lead
    * @param triggerNew - list of new leads
    * @param triggerNewMap - map of lead id and new leads
    * @param triggerOldMap - map of lead id and old leads
    * @return return-void
    * @throws exception - NA
    */
    public static void leadAfterUpdate(List<Lead> triggerNew, map<id,Lead> triggerNewMap,map<id,Lead> triggerOldMap){
        system.debug('leadAfterUpdate >>');
        apexSharingAfterUpdate(triggerNew, triggerNewMap,triggerOldMap);
        
        //US-2231 and 2226 Changes Begin
        LeadAndPrimaryContactValueSetterOnOpportunity(triggerNewMap);
        //US-2231 and 2226 Changes End
        
        //if there is change in country, check for distributor of matching country for reseller account
        updateDistributorMatchingCountry(triggerNew,triggerOldMap);
        LeadTriggerHandler.calculatePredectiveScore(triggerNew, triggerOldMap );
        //
        invokeDRApproverVerifyAccess(triggerNew, triggerOldMap);//<SALESRT-17429> 
    } 

    /**
     * this method is for after delete event
     */
    public static void leadAfterDelete(List<Lead> oldList, Map<id,Lead> oldMap){
        LeadTriggerHandler.calculatePredectiveScore(oldList, oldMap);
    }

    /**
     * this method is for after undelete event
     */
    public static void leadAfterUndelete(List<Lead> newList, Map<id,Lead> newMap){
        LeadTriggerHandler.calculatePredectiveScore(newList, newMap);
    }
    
    /**
    * This method checks for duplicate records . 
    * If leads or contacts are found with same email address display error with list of ids of duplicate leads and contacts 
    * @param parameter- LstNew- list of new Leads
    * @return return- void
    * @throws exception-captures exception in a Exception log record
    */
    public static void duplicatecheck(List<Lead> LstNew){
    
        Set<String> setNewEmail = new set<String>();// Set of possible duplicate emails
        map<String,set<id>>  mapdupLeads= new map<String,set<id>>();//duplicate leads
        map<String,set<id>> mapdupContacts = new map<String,set<id>>();//duplicate contacts
         
        if(LstNew!=null &&LstNew.size()>0){
        
        
           //Create debug logs
           GAM.Createlogs('LeadTriggerHandler- DuplicateCheck',LstNew,'LstNew');
        
              //Set of new emails to lookup for duplicates
              For(Lead L: LstNew){    
                  setNewEmail.add(L.email);  
              }
            
              try{
                          
                  //query for dulicate leads with same email
                  
                  //-----------------------------------------------------------------------------------------<T01>
                  // Added condition of Lead Record Type
                  For( Lead dl : [select id,name, email from lead where isconverted=false and email in :setNewEmail AND RecordTypeId =: leadRecordTypeId ]){
                  //-----------------------------------------------------------------------------------------</T01>          
                      //group duplicate leadIds by email             
                      if(mapdupLeads.keyset().contains(dl.email)){          
                          set<id> temp = mapdupLeads.get(dl.email);
                          temp.add(dl.id);                 
                          mapdupLeads.put(dl.email,temp);                        
                      }
                      else{ 
                          set<id> temp = new set<id>();
                          temp.add(dl.id);
                          mapdupLeads.put(dl.email, temp);
                      } 
                  }
                  
                  
                  //query for duplicate contacts with same email
                  For( Contact dc : [select id,name, email from contact where email in :setNewEmail ]){
                  
                      //group duplicate contactIds by email
                      if(mapdupContacts.keyset().contains(dc.email)){
                          set<id> temp = mapdupContacts.get(dc.email);
                          temp.add(dc.id);
                          mapdupContacts.put(dc.email,temp);
                      }
                      else{
                          set<id> temp = new set<id>();
                          temp.add(dc.id);
                          mapdupContacts.put(dc.email, temp);
                      }
           
                  }
                   
                  // Check if any duplicate present and pop up error message 
                  If  ((mapdupLeads!=null && mapdupLeads.keyset().size()>0)||(mapdupContacts !=null && mapdupContacts.keyset().size()>0) ){
                  
                       for(Lead Ld: LstNew){
                           string errormsg='';
                           
                           //Error msg when duplicates exist in both leads and contacts
                           if((mapdupLeads.keyset().contains(Ld.email))&&(mapdupContacts.keyset().contains(Ld.email)))
                           {  
                               errormsg = GAM.DisplayErrorMessage('DuplicateLeads')+ mapdupLeads.get(Ld.email)+ '\n'+ GAM.DisplayErrorMessage('DuplicateContacts')+ mapdupContacts.get(Ld.email) ;
                               ld.adderror (errormsg , false);
                           }
                           
                           //Error msg when duplicates exist in both leads 
                           if((mapdupLeads.keyset().contains(Ld.email))&&!(mapdupContacts.keyset().contains(Ld.email)))  
                           {
                               errormsg = GAM.DisplayErrorMessage('DuplicateLeads')+ mapdupLeads.get(Ld.email);
                               ld.adderror (errormsg , false);
                           }
                           
                           //Error msg when duplicates exist in both contacts
                           if(!(mapdupLeads.keyset().contains(Ld.email))&&(mapdupContacts.keyset().contains(Ld.email)))
                           {
                               errormsg = GAM.DisplayErrorMessage('DuplicateContacts')+ mapdupContacts.get(Ld.email);
                               ld.adderror (errormsg , false);
                           }
                       }      
                  }   
            }
            Catch(Exception ex){
                GAM.CreateExceptionRecords( 'LeadTriggerHandler', 'exception in duplicatecheck', ex.getMessage());
            }
        } 
        //Insert debug Logs
        GAM.Insertdebuglogs();
    }
    
    /**
    * PRM: This method returns the logged in partners related account and its type
    * @param parameter- loggedInUserId- list of new dealregistartions
    * @return return- Map<Id,String>
    */
    
    public static Map<Id,String> partnerAccountTypeChecker(Id loggedInUserId)
    {
        Map<Id,String> partnerAccountIdTypeMap = new Map<Id,String>();
        for(User u : [SELECT Id,Contact.AccountId,
                      Contact.Account.Partner_Type__c 
                      FROM User 
                      WHERE Id = :loggedInUserId 
                      AND Contact.AccountId <> null]) //AND Contact.Account.Partner_Type__c <> null])
        {  
            partnerAccountIdTypeMap.put(u.Contact.AccountId,(String)u.Contact.Account.Partner_Type__c);           
        }
        
        return partnerAccountIdTypeMap;
    }
    
    /**
    * PRM: Method to update Distributor based on Matching Country
    * @param triggernew - list of new Lead
    * @return return-void
    * @throws exception - NA
    */
    public static void updateDistributor(List<Lead> triggernew)
    {
        Map<String,Id> CountryDistributerMap = new Map<String,Id>();
        Map<Id,String> partnerAccountIdTypeMap = partnerAccountTypeChecker(UserInfo.getUserId()); 
        Map<Id, Partner_Distributor__c> partnerDistiMap = new Map<Id, Partner_Distributor__c>();
        Id AccId;
        String AccType; 
        
        //Iterate Over the User to get the AccountId and Account Type
        if(!partnerAccountIdTypeMap.isEmpty())
        {
            for(Id i : partnerAccountIdTypeMap.keySet())
            {
                AccId = i;           
                AccType = partnerAccountIdTypeMap.get(i);
            }
        }
        //Iterate Over the Partner Distributor if the Account Type is 'Reseller' and form a map with country as key and Account as Value.
        if(AccType != null && AccType!= '' && AccType.Contains(label.PRM_ResellerPartnerUserType))
        {
            for(Partner_Distributor__c pd : [SELECT Country__c,Distributor__c from Partner_Distributor__c where Reseller_Account__c=:AccId order by createdDate DESC])
            {
                CountryDistributerMap.put(pd.Country__c,pd.Distributor__c);
            }
        }
        List<ID> partnerDistiIDList = new List<Id>();
        if(AccType != null && AccType!= '' && AccType.Contains(label.PRM_DistributorPartnerUserType))
        {
            for(Lead lead : triggernew)
            {
                if(null != lead.Partner_Distributor__c)
                    partnerDistiIDList.add(lead.Partner_Distributor__c);
            }
        
            // Create a map of Partner Distributor ID and Partner Distributor record
            if(!partnerDistiIDList.isEmpty() && partnerDistiIDList != null)
            {
                for(Partner_Distributor__c pdc : [select Reseller_Account__c, Id from Partner_Distributor__c where ID IN: partnerDistiIDList])
                {
                    partnerDistiMap.put(pdc.Id,pdc);
                }
            }
        }  
        
        //Iterate Over the New Deal Registrations and Pre-Populate the Values
        for(Lead lead : triggernew)
        {            
            //Pre-Populate Reseller and Only if the new DR is of 'Resell' Type for Deal Registration Record type
            If(null!= lead.Deal_Registration_Type__c && lead.Deal_Registration_Type__c.equalsIgnoreCase(label.PRM_ResellPartnerProgramType) && lead.RecordTypeId == recordTypetList[0].id)
            {
                //Populate 'Reseller' if the Account Type is Reseller and Populate the Distributor if user Select a country for the new DR
                If(AccId != null && AccType != null && AccType!= '' && AccType.Contains(label.PRM_ResellerPartnerUserType))
                {                    
                    lead.Reseller_SI_Partner__c = AccId;                     
                    
                    if(lead.Country != null && !CountryDistributerMap.isEmpty() && CountryDistributerMap.containskey(lead.Country))
                    {                      
                        lead.Distributor__c = CountryDistributerMap.get(lead.Country);
                    }
                }
                
                //Populate the 'Reseller' and 'Distributor' if the Account Type is Distributor 
                If(AccType != null && AccType!= '' && AccType.Contains(label.PRM_DistributorPartnerUserType))
                {
                    If(AccId != null)
                    lead.Distributor__c = AccId;
                    If(lead.Partner_Distributor__c != null && partnerDistiMap != null && partnerDistiMap.containsKey(lead.Partner_Distributor__c))
                    {
                        lead.Reseller_SI_Partner__c = partnerDistiMap.get(lead.Partner_Distributor__c).Reseller_Account__c;      
                    }
                }
            }else if(null!= lead.Deal_Registration_Type__c && lead.Deal_Registration_Type__c.equalsIgnoreCase(label.PRM_ReferralPartnerProgramType) && lead.RecordTypeId == recordTypetList[0].id) {
                if(AccId != null && AccType != null && (AccType.equalsIgnoreCase(label.PRM_SIPartnerUserType) || 
                AccType.equalsIgnoreCase(label.PRM_SIandResellerPartnerUserType))){
                    lead.Reseller_SI_Partner__c = AccId;
                }
            } 
        }
    }
    
    /**
    * PRM: Method to update Distributor based on Matching Country
    * This method will be called if country is updated from ICRT job
    * @param triggernew - list of new Lead
    * @return return-void
    * @throws exception - NA
    */
    public static void updateDistributorMatchingCountry(List<Lead> triggernew,map<id,Lead> triggerOldMap)
    {
        //map of Partner_Distributor__c country wise Partner_Distributor__c
        Map<String,Id> CountryDistributerMap = new Map<String,Id>();
        
        //map of lead id wise reseller acc id
        Map<Id,id> leadIdwiseAcc = new Map<id,Id>();

        //list of leads to be updated
        list<lead> toUpdateList = new List<lead>();
        for(Lead Lead:triggernew)
        {
            //check if there is change in country and distributor is null
            if(null != Lead.Country && triggerOldMap.get(Lead.id).Country != Lead.Country && (Lead.Distributor__c == null) && null != Lead.Reseller_SI_Partner__c)
            {               
                leadIdwiseAcc.put(Lead.id,Lead.Reseller_SI_Partner__c);
            }
        }

        //Iterate Over the Partner Distributor if the Account Type is 'Reseller' and form a map with country as key and Account as Value.
        for(Partner_Distributor__c pd : [SELECT Country__c,Distributor__c from Partner_Distributor__c where Reseller_Account__c in :leadIdwiseAcc.values() order by createdDate DESC])
        {
            CountryDistributerMap.put(pd.Country__c,pd.Distributor__c);
        }
        
        for(lead lead : [select id,Country,Deal_Registration_Type__c,RecordTypeId,Reseller_SI_Partner__c from Lead where id in :leadIdwiseAcc.keyset()])
        {
            //If the new DR is of 'Resell' Type for Deal Registration Record type, check for matching country
            If(null!= lead.Deal_Registration_Type__c && lead.Deal_Registration_Type__c.equalsIgnoreCase(label.PRM_ResellPartnerProgramType) && lead.RecordTypeId == recordTypetList[0].id && null != leadIdwiseAcc.get(lead.id) && lead.Reseller_SI_Partner__c == leadIdwiseAcc.get(lead.id))
            {
                //Populate the Distributor if user Selects a country for the new DR
                    if(lead.Country != null && !CountryDistributerMap.isEmpty() && CountryDistributerMap.containskey(lead.Country))
                    {     
                        lead.Distributor__c = CountryDistributerMap.get(lead.Country);
                    }
                
            }
            toUpdateList.add(lead);
        }
        
        try
        {
            if(!toUpdateList.isEmpty())
            update toUpdateList;

        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('LeadTriggerHandler', 'Error from updateDistributorMatchingCountry',ex.getMessage());
            }
    }
    
    /**
    * PRM: This method checks for wrong deal registration types while Inserting. 
    * If a deal registration type doesn't match with the partner program type then it block the user from creating the new deal registration.
    * @param parameter- newRegs- list of new dealregistartions
    * @return return- void
    */
    
    public static void DRTypeValidatior(List<Lead> newRegs)
    {
        //Map<Id,String> programWithCSIRoleTypeMap = new Map<Id,String>();
        //Map<Id,String> programWithNonCSIRoleTypeMap = new Map<Id,String>(); 
        Map<Id,String> partnerAccountIdTypeMap = partnerAccountTypeChecker(UserInfo.getUserId()); 
        Map<Id,Boolean> dealsCreatedByResellersMap = new Map<Id,Boolean>();  
        Set<Id> drCreatedUserId = new Set<Id>();    
        
        Id AccId;
        String loggedinUserType;
        
        
        //Iterate Over the User to get the AccountId and Account Type
        if(!partnerAccountIdTypeMap.isEmpty()){
            for(Id i : partnerAccountIdTypeMap.keySet())
            {
                AccId = i;           
                loggedinUserType = partnerAccountIdTypeMap.get(i);
            }
        }else{
           for(Lead lds : newRegs){
                partnerAccountIdTypeMap.put(lds.Reseller_SI_Partner__c, null);
           } 
        }
        for(Account acc : [SELECT id, Partner_Type__c 
                           FROM Account WHERE Id IN: partnerAccountIdTypeMap.KeySet()]){
             if(partnerAccountIdTypeMap.containsKey(acc.Id)){
                 partnerAccountIdTypeMap.put(acc.Id, acc.Partner_Type__c);                
             }                    
        }
        
        for(SObject s : newRegs){
            Lead dr = (Lead)s;
            if(dr.RecordTypeId == recordTypetList[0].id){
                   
                if(dr.Deal_Registration_Type__c == Label.PRM_ResellPartnerProgramType  && 
                      (loggedinUserType == Label.PRM_SIPartnerUserType || 
                       (partnerAccountIdTypeMap.containsKey(dr.Reseller_SI_Partner__c) &&
                       partnerAccountIdTypeMap.get(dr.Reseller_SI_Partner__c) == Label.PRM_SIPartnerUserType )) ){
                      dr.addError(label.PRM_Integrator_Reseller_Type);
                   }else if(dr.Deal_Registration_Type__c == Label.PRM_ReferralPartnerProgramType  && 
                      (loggedinUserType == Label.PRM_Software_Reseller || 
                       (partnerAccountIdTypeMap.containsKey(dr.Reseller_SI_Partner__c) &&
                        partnerAccountIdTypeMap.get(dr.Reseller_SI_Partner__c) == Label.PRM_Software_Reseller) ) ){
                      dr.addError(label.PRM_Reseller_Referral_Type);
                   }else if(dr.Deal_Registration_Type__c == Label.PRM_Partner_Role_Ecosystem_Value 
                           && AccId != null && 
                           (loggedinUserType == Label.PRM_Software_Reseller || 
                           loggedinUserType == Label.PRM_SIPartnerUserType  || 
                           loggedinUserType == Label.PRM_SIandResellerPartnerUserType || 
                           loggedinUserType == Label.PRM_DistributorPartnerUserType )){
                      dr.addError(label.PRM_Ecosystem_Internal);          
                   }
            }
            
         }
        
        //Checks the above AccId(Partner Id) and forms 2 maps with Account Id and Value set to 'Resell' or 'Referral' accordingly.
        If(AccId != null)
        {   
            //Iterates over the Partner Programs and forms 2 maps with key as Account and Value as 'Resell' and 'Referral' Type      
            /*for(Partner_Program__c pp : [select Partner__c,Program_Type__c,Program_Status__c from Partner_Program__c WHERE Partner__c =:AccId AND Program_Status__c='Active' AND Program_Type__c <> null])
            {
                If(pp.Program_Type__c == label.PRM_CSIPartnerProgramType)
                {
                    programWithCSIRoleTypeMap.put(pp.Partner__c,label.PRM_ReferralPartnerProgramType);
                }
                else
                {
                    programWithNonCSIRoleTypeMap.put(pp.Partner__c,label.PRM_ResellPartnerProgramType);
                }
            }*/      
            
            //Iterates over the new deal registrations and validates with above Account Type Map and throws Error         
            /*for(SObject s : newRegs)
            {
                Lead dr = (Lead)s;
                if(dr.RecordTypeId == recordTypetList[0].id)
                {
                    drCreatedUserId.add(dr.CreatedById);
                
                    If(!programWithCSIRoleTypeMap.isEmpty() || !programWithNonCSIRoleTypeMap.isEmpty())
                    {                   
                        If(dr.Deal_Registration_Type__c != null){
                            //Condition to avoid if a partner has both CSI and NonCSI Programs Active
                            If(!(programWithNonCSIRoleTypeMap.containskey(AccId) && programWithCSIRoleTypeMap.containskey(AccId)))
                            {
                                If(dr.Deal_Registration_Type__c == label.PRM_ReferralPartnerProgramType && programWithNonCSIRoleTypeMap.containskey(AccId) && dr.Deal_Registration_Type__c != programWithNonCSIRoleTypeMap.get(AccId))
                                {
                                    dr.addError(label.PRM_DealRegistration_ReferralTypeCheck_Error);
                                }
                                
                                If(dr.Deal_Registration_Type__c == label.PRM_ResellPartnerProgramType && programWithCSIRoleTypeMap.containskey(AccId) && dr.Deal_Registration_Type__c != programWithCSIRoleTypeMap.get(AccId))
                                {
                                    dr.addError(label.PRM_DealRegistration_ResellTypeCheck_Error);
                                } 
                            }   
                        }
                    }
                    else
                    {
                        dr.addError(label.PRM_DealRegistration_NoneTypeCheck_Error);
                    } 
                }              
            }
      */
            
            //Iterate Over the User to get the AccountId and Account Type
            for(User u : [SELECT Id,Contact.AccountId,Contact.Account.Partner_Type__c 
                          FROM User 
                          WHERE Id = :drCreatedUserId 
                          AND Contact.AccountId <> null 
                          AND Contact.Account.Partner_Type__c <> null])
            {            
                if((u.Contact.Account.Partner_Type__c).Contains(label.PRM_ResellerPartnerUserType))
                dealsCreatedByResellersMap.put(u.Id,True);
            }
            
               if(!String.isBlank(loggedinUserType) && loggedinUserType.Contains(label.PRM_DistributorPartnerUserType))
               {
                   for(SObject s : newRegs)
                   {
                        Lead dr = (Lead)s;
                        if(dr.RecordTypeId == recordTypetList[0].id && null != Trigger.OldMap && null != (Lead)Trigger.OldMap.get(dr.Id))
                        {
                            Lead olddrRef = (Lead)Trigger.OldMap.get(dr.Id);
                            if(null != olddrRef.Partner_Distributor__c && null != dr.Partner_Distributor__c && olddrRef.Partner_Distributor__c != dr.Partner_Distributor__c)
                            {
                                if(dealsCreatedByResellersMap.containskey(dr.CreatedById) && dealsCreatedByResellersMap.get(dr.CreatedById))
                                dr.addError(label.PRM_DealReg_ResellerUpdateError);
                            }
                        }
                   }
               } 
           
        }
    }
    
    /**
    * PRM: Method to implement managed sharing of the Lead for all partner users of the account
    * @param triggernew - list of new Lead
    * @return return-void
    * @throws exception - NA
    */
    public static void apexSharingAfterInsert(List<Lead> triggerNew){
        //Fetch all unique Acc Ids
        Set<Id> accIdSet = new Set<Id>();
        List<User> userList;
        List<User> finalUserList;
        //Map of Lead id and set of accounts related to the Lead
        map<id, set<Id>> mapLeadIdWiseAcc = new Map<id,set<Id>>();
        //Map of Account id and list of users
        map<id, List<User>> mapAccIdWiseUser = new Map<id,List<User>>();
        //Map of Lead id and list of users
        map<id, List<User>> mapLeadIdWiseUser = new Map<id,List<User>>();
        //-----------------------------------------------------------------------------------------<T02>
        //set to store the internal users Id which needs to be shared manually
        Map<id,Id> mapEnableInternalUsersShareInsert = new Map<id,Id>();
        Map<id,Id> mapEnableFSRUsersShareInsert = new Map<id,Id>();//Deal registration enhancements SALESRT-14919
        //-----------------------------------------------------------------------------------------</T02>
        //Fetch current partner account, distributor and reseller accounts of the Lead
        for(Lead lead : triggerNew){
            Set<Id> tempAccIdSet = new Set<id>();
            
            /*if(lead.DEV_RelatedPartnerId__c != null){
                tempAccIdSet.add(lead.DEV_RelatedPartnerId__c);
                accIdSet.add(lead.DEV_RelatedPartnerId__c);
            }*/
            if(lead.RecordTypeId == recordTypetList[0].id)
            {
                if(lead.Distributor__c != null)
                {
                    tempAccIdSet.add(lead.Distributor__c);
                    accIdSet.add(lead.Distributor__c);
                }
                if(lead.Reseller_SI_Partner__c != null)
                {
                    tempAccIdSet.add(lead.Reseller_SI_Partner__c);
                    accIdSet.add(lead.Reseller_SI_Partner__c);
                }
                mapleadIdWiseAcc.put(lead.Id,tempAccIdSet);
            }
            //-----------------------------------------------------------------------------------------<T02>
            //Check if the PSM is populated on the Deal , if yes then share the DR record manually to PSM 
            if(lead.PSM__c != null){
                mapEnableInternalUsersShareInsert.put(lead.Id,lead.PSM__c);
            }
            //Deal registration enhancements SALESRT-14919
			if(lead.Field_Sales_Rep__c  != null){
                mapEnableFSRUsersShareInsert.put(lead.Id,lead.Field_Sales_Rep__c);
            }
         
            //-----------------------------------------------------------------------------------------</T02>
        }
        System.debug('mapEnableInternalUsersShareInsert.............'+mapEnableInternalUsersShareInsert);
        //Fetch all active users for the accounts
        for(User u : [select id, contact.accountid from user where contact.accountid IN :accIdSet and contact.Is_Active__c = TRUE and IsActive  = True and contact.View_All_Deal_Registrations__c = TRUE]){
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
        
        
        //Populate mapleadIdWiseUser with lead Ids against the list of users
        for(Id leadId : mapleadIdWiseAcc.keySet())
        {
            //consolidate all account wise user list tagged to lead
            finalUserList = new List<User>();
            if(null != mapleadIdWiseAcc.get(leadId))
            {
                for (Id accId: mapleadIdWiseAcc.get(leadId))
                {
                    if(mapAccIdWiseUser.containsKey(accId)){
                        finalUserList.addAll(mapAccIdWiseUser.get(accId));
                    }
                }
                mapleadIdWiseUser.put(leadId,finalUserList);
            }           
        }
        ApexSharingUtility.enablesharingForPartnerUsers(mapleadIdWiseUser, label.PRM_Lead_Share, 'Edit');
        //Deal registration enhancements SALESRT-14919
        if(mapEnableFSRUsersShareInsert.size() > 0){
            ApexSharingUtility.enableSharingForInternalUsers(mapEnableFSRUsersShareInsert,label.PRM_Lead_Share,'Read');
        }
        
        
        //-----------------------------------------------------------------------------------------<T02>
        if(mapEnableInternalUsersShareInsert.size() > 0)
            //------------------------------------------------------------------------------------------------------------<T03>
            ApexSharingUtility.enableSharingForInternalUsers(mapEnableInternalUsersShareInsert,label.PRM_Lead_Share,'Edit');
            //------------------------------------------------------------------------------------------------------------</T03>
        //-----------------------------------------------------------------------------------------</T02>
    }
    
    /**
    * PRM: Method to implement managed sharing of the Lead for all partner users of the account on after update
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
    public static void apexSharingAfterUpdate(List<Lead> triggerNew, map<id,Lead> triggerNewMap, map<id,Lead> triggerOldMap){
        //set of AccId that are newly added and need to be given share access
        set<id> tempAccId = new set<id>();
        List<User> userList;
        List<User> finalUserList;
        //-----------------------------------------------------------------------------------------<T02>
        //set to store the internal users Id which needs to be shared manually
        //-------------------------------------------------------------------------<T03>
        Map<id,Id> mapEnablePsmUsersShare = new Map<id,Id>();
        Map<id,Id> mapEnableFsrUsersShare = new Map<id,Id>();
        //-------------------------------------------------------------------------</T03>
        Map<id,Id> mapDisableInternalUsersShare = new Map<id,Id>();
        //-----------------------------------------------------------------------------------------</T02>
        
        //Map of lead id and set of accounts related to the lead
        map<id, set<Id>> mapleadIdWiseAcc = new Map<id,set<Id>>();
        
        //Map of lead Id and old Reseller Acc Id to be removed from share access
        map<id, Id> mapleadIdWiseAccInactiveReseller = new Map<id,Id>();
        //Map of lead Id and old Distributor Acc Id to be removed from share access
        map<id, Id> mapleadIdWiseAccInactiveDistributor = new Map<id,Id>();
        
        //Map of Account id and list of users
        map<id, List<User>> mapAccIdWiseUser = new Map<id,List<User>>();
        //Map of lead id and list of users
        map<id, List<User>> mapleadIdWiseUser = new Map<id,List<User>>();
        
        map<id, List<User>> mapleadIdWiseUserInactive = new Map<id,List<User>>();
        
        //Fetch current partner account, distributor and reseller accounts of the lead
        for(Lead lead : triggerNew){
            Set<Id> tempAccIdSet = new Set<id>();
            if(lead.RecordTypeId == recordTypetList[0].id)
            {
                if(lead.Distributor__c != triggerOldMap.get(lead.Id).Distributor__c){ 
                 if(lead.Distributor__c != null)
                 {
                    tempAccIdSet.add(lead.Distributor__c);
                    tempAccId.add(lead.Distributor__c);
                 }
                 if(triggerOldMap.get(lead.Id).Distributor__c != null)
                 {
                     //T04 replaced PartnerAccoutId with Partner_Account__c
                    //do not delete share records if old distributor account is equal to partner account(as records to be shared among all users of partner acc)
                    if(!(null != lead.Partner_Account__c && lead.Partner_Account__c == triggerOldMap.get(lead.Id).Distributor__c))
                    {
                        mapleadIdWiseAccInactiveDistributor.put(lead.Id,triggerOldMap.get(lead.Id).Distributor__c);
                    }
                 }
                }    
                if(lead.Reseller_SI_Partner__c != triggerOldMap.get(lead.Id).Reseller_SI_Partner__c){  
                 if(lead.Reseller_SI_Partner__c != null){
                   tempAccIdSet.add(lead.Reseller_SI_Partner__c);
                   tempAccId.add(lead.Reseller_SI_Partner__c);
                 }
                 if(triggerOldMap.get(lead.Id).Reseller_SI_Partner__c != null){
                     //T04 replaced PartnerAccoutId with Partner_Account__c
                     //do not delete share records if old reseller account is equal to partner account(as records to be shared among all users of partner acc)
                     if(!(null != lead.Partner_Account__c && lead.Partner_Account__c == triggerOldMap.get(lead.Id).Reseller_SI_Partner__c))
                     {
                         mapleadIdWiseAccInactiveReseller.put(lead.Id,triggerOldMap.get(lead.Id).Reseller_SI_Partner__c); 
                     }
                 }
                }
                mapleadIdWiseAcc.put(lead.Id,tempAccIdSet);
                //----------------------------------------------------------------------------------------------------------------<T02>                
                //check if the PSM is changed , if yes then new PSM should be manually shared and old user sharing must be deleted
                if(lead.PSM__c != triggerOldMap.get(lead.Id).PSM__c && lead.PSM__c != null){
                    mapEnablePsmUsersShare.put(lead.Id,lead.PSM__c);
                    //Before update PSM=FSR, PSM is updated - FSR should not lose access - to retain access added below condition.
                    if(triggerOldMap.get(lead.Id).PSM__c == lead.Field_Sales_Rep__c)
                    	mapEnableFsrUsersShare.put(lead.Id,lead.Field_Sales_Rep__c);
                    if(triggerOldMap.get(lead.Id).PSM__c != null && triggerOldMap.get(lead.Id).PSM__c <> lead.Field_Sales_Rep__c){
                        mapDisableInternalUsersShare.put(lead.Id,triggerOldMap.get(lead.Id).PSM__c);
                    }                   
                }
                
                //check if the PSM is removed from DR, then disable the sharing of the old user
                if(triggerOldMap.get(lead.Id).PSM__c != null && lead.PSM__c == null){
                        mapDisableInternalUsersShare.put(lead.Id,triggerOldMap.get(lead.Id).PSM__c);
                }
                //check if the FSR is changed , if yes then new PSM should be manually shared and old user sharing must be deleted
                if(lead.Field_Sales_Rep__c != triggerOldMap.get(lead.Id).Field_Sales_Rep__c && lead.Field_Sales_Rep__c != null){//<SALESRT-17007>
                    if(lead.Field_Sales_Rep__c <> lead.PSM__c) //FSR and PSM are not same - then only provide READ Access to FSR user
                    	mapEnableFsrUsersShare.put(lead.Id,lead.Field_Sales_Rep__c);
                    //PSM is not equal to old-FSR - then only remove the sharing access
                    if(triggerOldMap.get(lead.Id).Field_Sales_Rep__c != null && triggerOldMap.get(lead.Id).Field_Sales_Rep__c <> lead.PSM__c){
                        mapDisableInternalUsersShare.put(lead.Id,triggerOldMap.get(lead.Id).Field_Sales_Rep__c);
                    }
                }
                //check if the FSR is removed from DR, then disable the sharing of the old user
                if(triggerOldMap.get(lead.Id).Field_Sales_Rep__c != null && (lead.Field_Sales_Rep__c == null || (triggerOldMap.get(lead.Id).Field_Sales_Rep__c <> lead.Field_Sales_Rep__c && triggerOldMap.get(lead.Id).Field_Sales_Rep__c <> lead.PSM__c))){//<SALESRT-17007>
                        mapDisableInternalUsersShare.put(lead.Id,triggerOldMap.get(lead.Id).Field_Sales_Rep__c);
                }
                
                //-----------------------------------------------------------------------------------------------------------------</T02>
            }
            
        }
        
        //Fetch all active users for the accounts
        for(User u : [select id, contact.accountid from user where contact.accountid IN : tempAccId and contact.Is_Active__c = TRUE and IsActive  = True and contact.View_All_Deal_Registrations__c = TRUE]){
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
        
        
        //Populate mapleadIdWiseUser with lead Ids against the list of users
        for(Id lead : mapleadIdWiseAcc.keySet())
        {
            //consolidate all account wise user list tagged to lead
            finalUserList = new List<User>();
            if(null != mapleadIdWiseAcc.get(lead))
            {
                if(null != mapleadIdWiseAcc.get(lead))
                {
                    for (Id accId: mapleadIdWiseAcc.get(lead))
                    {
                        if(mapAccIdWiseUser.containsKey(accId)){
                            finalUserList.addAll(mapAccIdWiseUser.get(accId));
                        }
                    }
                    mapleadIdWiseUser.put(lead,finalUserList);
                }
            }           
        }
        if(mapleadIdWiseAccInactiveReseller.size() > 0){
          ApexSharingUtility.disablesharingForPartnerUsers(mapleadIdWiseAccInactiveReseller, label.PRM_Lead_Share);
        }
        if(mapleadIdWiseAccInactiveDistributor.size() > 0){ 
         ApexSharingUtility.disablesharingForPartnerUsers(mapleadIdWiseAccInactiveDistributor, label.PRM_Lead_Share);
        }
        ApexSharingUtility.enablesharingForPartnerUsers(mapleadIdWiseUser, label.PRM_Lead_Share, 'Edit');
        //-----------------------------------------------------------------------------------------<T02>
        if(mapEnablePsmUsersShare.size() > 0)
            ApexSharingUtility.enableSharingForInternalUsers(mapEnablePsmUsersShare,label.PRM_Lead_Share,'Edit');
        if(mapEnableFsrUsersShare.size() > 0)
            ApexSharingUtility.enableSharingForInternalUsers(mapEnableFsrUsersShare,label.PRM_Lead_Share,'Read');
        if(mapDisableInternalUsersShare.size() > 0)
            ApexSharingUtility.disableSharingForInternalUsers(mapDisableInternalUsersShare,label.PRM_Lead_Share);
        
        //-----------------------------------------------------------------------------------------</T02>
    }
    
    /*
    PRM: method Name : LeadAndPrimaryContactValueSetterOnOpportunity
    return Type : Void
    Definition : This method tags the Lead and Primary Contact to the new converted opportunity, or existing opportunity when leads assigned to existing oppty.
    */
    public static void LeadAndPrimaryContactValueSetterOnOpportunity(Map<Id,Lead> NewleadMap)
    {
        Map<Id,Id> OpptyToLeadIdMap = new Map<Id,Id>();
        List<Opportunity> opptyListToUpdate = new List<Opportunity>();       
        Set<Id> partnersOnLead = new Set<Id>();
        Map<Id,Id> PartnerAccountToPrimaryContactMap = new Map<Id,Id>();
        Map<Id,Id> LeadToPrimaryContactMap = new Map<Id,Id>();
               
        if(!NewleadMap.isEmpty())
        {
            for(Lead ld : [Select id,ConvertedOpportunityId,Reseller_SI_Partner__c from Lead where IsConverted=true AND recordtype.developername=:label.Lead_Record_Type AND Id IN :NewleadMap.KeySet()])
            {   
                if(ld.ConvertedOpportunityId != null)
                OpptyToLeadIdMap.put(ld.ConvertedOpportunityId,ld.id);
                if(ld.Reseller_SI_Partner__c != null)
                partnersOnLead.add(ld.Reseller_SI_Partner__c);
            }
        }
        
        //Fetching the Primary Contacts using Partner Accounts present on Converted Leads
        if(!partnersOnLead.isEmpty())
        {
            for(Contact con : [SELECT Id,AccountId from Contact where Is_Primary__c = true AND AccountId IN :partnersOnLead])
            {
                PartnerAccountToPrimaryContactMap.put(con.AccountId,con.Id);
            }
        }
        
        //Forming a map with 'Lead Ids' as Key and 'Primary Contact Ids' as value to be used while updating the opportunities
        if(!PartnerAccountToPrimaryContactMap.isEmpty())
        {
            for(Lead ld : [Select id,Reseller_SI_Partner__c from Lead where Reseller_SI_Partner__c <> null AND IsConverted=true AND recordtype.developername=:label.Lead_Record_Type AND Id IN :NewleadMap.KeySet()])
            {
                if(PartnerAccountToPrimaryContactMap.containsKey(ld.Reseller_SI_Partner__c))
                LeadToPrimaryContactMap.put(ld.Id,PartnerAccountToPrimaryContactMap.get(ld.Reseller_SI_Partner__c));
            }
        }
        
        if(!OpptyToLeadIdMap.isEmpty())
        {
            for(Opportunity op : [SELECT Id,DEV_Primary_Partner_Contact__c from Opportunity where Id IN :OpptyToLeadIdMap.KeySet()])
            {
                if(OpptyToLeadIdMap.ContainsKey(op.Id))
                {  
                    if(LeadToPrimaryContactMap.containsKey(OpptyToLeadIdMap.get(op.Id)))
                    {
                        op.DEV_Primary_Partner_Contact__c = LeadToPrimaryContactMap.get(OpptyToLeadIdMap.get(op.Id));
                    }
                    
                    opptyListToUpdate.add(op);
                }
            }
        }
        try
        {
            if(!opptyListToUpdate.isEmpty())
            update opptyListToUpdate;

        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('LeadTriggerHandler', 'Exception in LeadValueSetterOnOpportunity',ex.getMessage());
            }
    }
    
    /**
    * PRM: Method to populate PSM on Lead
    ** with the PSM from the Partner Account of the user creating the deal registration
    * @param triggernew - List of Lead
    * @return return-void
    * @throws exception - NA
    */ 
    public static void populatePSM(List<Lead> triggerNew){
        
        Map<Id,String> partnerAccountIdTypeMap = partnerAccountTypeChecker(UserInfo.getUserId()); 
        Id AccId;
        String psmUserId; 
        
        //Iterate Over the User to get the AccountId
        if(!partnerAccountIdTypeMap.isEmpty())
        {
            for(Id i : partnerAccountIdTypeMap.keySet())
            {
                AccId = i;           
            }
        }
        
        //Fetch the PSM user id from Account Team 
        for (AccountTeamMember atm : [SELECT ID,UserId FROM AccountTeamMember WHERE TeamMemberRole = 'PSM' AND AccountId = :AccId limit 1])
        {
            psmUserId = atm.UserId;
        }
        
        //For Deal Registraion Layout, set PSM field
        for(Lead newLead:triggerNew)
        {
            if(newLead.RecordTypeId == recordTypetList[0].id && psmUserId != null && psmUserId != '')
            {
                newLead.PSM__c = psmUserId;
                newLead.Approver1__c = psmUserId; //added for <SALESRT-14919>
            }
        }
        
    }
    
    /*
    PRM: Method Name : populateCampaignSeries
    Return Type : void
    Definition : This method populates related Campaign Series of the MQL Program Name on the Lead
    */
    public static void populateCampaignSeries(List<Lead> triggerNew, Map<Id, Lead> oldMap){
        Set<String> assocCampaigns=new Set<String>();
        Map<string, Campaign> campSeriesNames = new Map<string, Campaign>();
        List<Lead> leadList=new List<Lead>();
        
        for(Lead campLead:triggerNew){
         
            if(campLead.MQL_Program_Name__c != null && campLead.MQL_Program_Name__c != '' && (trigger.isinsert || (trigger.isupdate && campLead.MQL_Program_Name__c != oldMap.get(campLead.Id).MQL_Program_Name__c))){
                
                assocCampaigns.add(campLead.MQL_Program_Name__c);
                leadList.add(campLead);
            }
        } 
        
        List<Campaign> campList = 
            [SELECT Id, Name, Campaign_Series__c,Salesloft_Cadence__c FROM Campaign WHERE Name IN :assocCampaigns];

        for(Campaign c:campList){
            campSeriesNames.put(c.Name,c);
        }
        System.debug('campList'+campList);

        for(Lead updateLead:leadList){
            
            if(campSeriesNames != null && campSeriesNames.containsKey(updateLead.MQL_Program_Name__c)){
                
                updateLead.Campaign_Series__c = campSeriesNames.get(updateLead.MQL_Program_Name__c).Campaign_Series__c;
                updateLead.Salesloft_Cadence__c = campSeriesNames.get(updateLead.MQL_Program_Name__c).Salesloft_Cadence__c;
            }
        } 
    }
    
 /**
    * This method is used to populate Outreach Owner from Infogenie Integration User to Marketo Integration 
    * @param triggernew - List of Lead
    * @return return-void
    * @throws exception - NA
    */    
    public static void populateOwner(List<Lead> triggerNew){ //<T06>
        Id fromUserId = Id.valueOf(System.Label.LeadFromUsername);
        Id toUserId = Id.valueOf(System.Label.LeadToUsername);
        for(Lead l : triggerNew){
            if(fromUserId != null && fromUserId.getSObjectType() == Schema.User.SObjectType && toUserId != null && 
               toUserId.getSObjectType() == Schema.User.SObjectType && l.OwnerId == fromUserId){
                l.OwnerId = toUserId;
            }
        }
    }

    /**
    * This method is used to empty disqualified reason if the status is changed. 
    * @param triggernew - List of Lead, old map
    * @return return-void
    * @throws exception - NA
    */   
    public static void autoDQProcess(List<Lead> newList, Map<Id,Lead> oldMap){
        for(Lead lead : newList){
            if(((oldMap == null) || (oldMap != null && oldMap.get(lead.Id).Status != lead.Status)) && lead.Status != 'Disqualified' && lead.Disqualified_Reason__c != null){
                lead.Disqualified_Reason__c = '';
            }
            if(((oldMap == null) || (oldMap != null && oldMap.get(lead.Id).SL_Person_Stage__c != lead.SL_Person_Stage__c )) && 
                (lead.SL_Person_Stage__c == 'Completed' && (lead.Status == 'Working' || lead.Status == 'New'))){

                    lead.Auto_DQ__c = true;
                    lead.Status = 'Disqualified';
                    lead.Disqualified_Reason__c = 'Auto DQ from completed cadence';
            }
        }
    }

    /**
    * This method is used to populate autodq timestamp field
    * @param triggernew - List of Lead, old map
    * @return return-void
    * @throws exception - NA
    */   
    //<T08> start
    public static void populateAutoDQTimestamp(List<Lead> newList, Map<Id,Lead> oldMap){
        Set<String> statusStageSet = new Set<String>{'Working:New','Working:Working','Replied:New','Replied:Working','Bounced:New','Bounced:Working'};
        for(Lead lead : newList){
            if(((oldMap == null) || (oldMap != null && (oldMap.get(lead.Id).Status != lead.Status || oldMap.get(lead.Id).SL_Person_Stage__c != lead.SL_Person_Stage__c )))){
                String key = lead.SL_Person_Stage__c + ':' + lead.Status;
                if(statusStageSet.contains(key)){
                    lead.Auto_DQ_Timestamp__c = System.now();
                }
                else{
                    lead.Auto_DQ_Timestamp__c = null;
                }
            }
        }
    }
    //<T08> end

    /**
    * This method is used to populate LS predective score bucket.
    * @param triggernew - List of Lead, old map
    * @return return-void
    * @throws exception - NA
    */   
    //<SALESRT-14408> start 
    public static void calculatePredectiveScore(List<Lead> leadList, Map<Id,Lead> oldMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
            for(Lead lead : leadList){
                if((
                    (oldMap == null) || 
                        (oldMap != null && 
                            (
                                oldMap.get(lead.Id).LS_Person_Predictive_Score__c != lead.LS_Person_Predictive_Score__c || 
                                oldMap.get(lead.Id).Account__c != lead.Account__c 
                            )
                        )
                    )
                    ){
    
                    accountIdSet.add(lead.Account__c);
    
                    if(oldMap != null && oldMap.get(lead.Id).Account__c != null){
                        accountIdSet.add(oldMap.get(lead.Id).Account__c);
                    }
                }
            }
        }
        if(Trigger.isDelete){
            for(Lead lead : leadList){
                if(lead.Account__c != null){
                    accountIdSet.add(lead.Account__c);
                }
            }
        }

        if(!accountIdSet.isEmpty()){
            ApexUtilitySales.calculateAccountPredectiveBucket(accountIdSet);
        }
    }
    //<SALESRT-14408> end
    


    /**
    * This method is used to call verify DR Approval User access. Added for SALESRT-17429
    * @param triggernew - List of Lead, old map
    * @return return-void
    * @throws exception - NA
    */   
    //<SALESRT-14408> start
    public static void invokeDRApproverVerifyAccess(List<Lead> leadList, Map<Id,Lead> oldMap){
        List<Id> leadIds = new List<Id>();
        List<String> leadCompleteStatus = new List<String>{'Approved', 'Rejected', 'Received'};//to filter DRs with these statuces.
        for(Lead lead : leadList){
            if(lead.RecordTypeId == recordTypetList[0].id && lead.Status <> oldMap.get(lead.Id).Status && !leadCompleteStatus.contains(lead.Status)){
                leadIds.add(lead.Id);
            }
        }
        if(!leadIds.isEmpty()){
            InfaApprovalProcessUtil.asyncEnableApproversAccess(leadIds);
        }
    }
    
}