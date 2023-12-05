/*
Class:          ContactTriggerHandler
@Author:        Ambica Pyati
@Created Date:  08/7/2017
@Description:   handler class for Contact triggers

Change History
********************************************************************************************************************************************************
ModifiedBy              Date                Requested By        Description                                                             Tag
Deloitte                26-10-2017          PRM                 Contact sharing and Primary contact check 
Deloitte                5/06/2018           PRM                 Removed method contactShareValidation as it is no longer needed
Uday Gangula            19-Mar-2021         SALESRT-12936       Stamp Campaign Series based on MQL Program Name                         <T01>                                                                                                        
Puneet Lohia            1-Dec-2021          Priyanka K          Auto DQ Timestamp field                                                 <T02>
Puneet                  10/28/2022          SALESRT-14408       Account Predective Bucket Score                                         <SALESRT-14408>    
Puneet                  01/02/2023          SALESRT-14990       Salesloft Cadence Automation                                            <SALESRT-14990> 
Rohit Niranjanamath     09-09-2023          PSA-3079            Resource Manager field addition to RR and PSA Contact Page layouts      <PSA-3079>
Wasim Akram             16-10-2023          PSA-3234            Tech Debt- PSA Contact restriction for duplicate record                 <T03>
*********************************************************************************************************************************************************
*/

Public without sharing Class ContactTriggerHandler{
    
    public static globalApexManager gam = new globalApexManager(); // To create debug logs and exception logs
    public static CustomPermissionsReader csm = new CustomPermissionsReader();// to check the user permission
    public static Boolean isPartnerUser = [SELECT IsActive,IsPortalEnabled FROM User where Id =:UserInfo.getUserId()].IsPortalEnabled;
    public static Boolean isExemptUser = (isPartnerUser || csm.hasPermission(label.PRM_Permission_SystemAdmin) || csm.hasPermission(label.PRM_Permission_IntegrationUser) || csm.hasPermission(label.PRM_Permission_SalesSuperUser));//Check if the current user has Admin,Integration, Superuser permissions
    
    /**
* @description - this method is invoked from before insert event of Contacts  
* @param lstNew - list of new contacts
* @throws exception - NA
*/
    Public static void contactBeforeInsert(List<Contact> lstNew)
    {
        
        // Added Logic To Prevent multiple Primary Contacts for Same Account
        //US-1741 Starts
        contactPrimaryInsertionDupeChecker(lstNew);
        //US-1741 Ends
        
        //do not run if the current user is sys admin, integration user, superuser
            if(!isExemptUser){
            DuplicateCheck(lstNew);
        }   
          //<T01>
        populateCampaignSeries(lstNew,null);
        autoDQProcess(lstNew,null);
        populateAutoDQTimestamp(lstNew,null); //<T02>
        //<PSA-3079> - Start
        psa_us_ContactTriggerHelper.updateOnRMOContactfieldOnContact(null, lstNew);
        psa_us_ContactTriggerHelper.avoidDuplicatePSContact(lstNew); //<T03>
        //<PSA-3079> - End
    }
    
    
    /**
* @description - this method is invoked from before update event of Contacts
* @param mapOld - map of old Contacts
* @param mapNew - map of new Contacts
* @param lstNew - list of new Contacts
* @throws exception - NA
*/    
    Public static void contactBeforeUpdate(Map <ID, Contact> mapOld, Map <ID, Contact> mapNew, List <Contact> lstNew) {
        
        // Added Logic To Prevent multiple Primary Contacts for Same Account
        //US-1741 Starts
        contactPrimaryUpdationDupeChecker(mapOld, mapNew);
        //<T01>>Added the below logic to update the campaignseries 
        populateCampaignSeries(lstNew,mapOld);                                                                 
                                              
        //US-1741 Ends
        List<Contact> lstUpdated = new List<Contact>();// list of contacts updated with email  
        
        //do not run if the current user is sys admin, integration user, superuser
        if(!isExemptUser){
            for(Contact c: lstNew){
                //check if the email is updated
                if(mapOld!=null && ((mapOld.get(c.id).email!=null&&!mapOld.get(c.id).email.equals(c.email))|| (mapOld.get(c.id).email==null&&c.email!=null))){
                    lstUpdated.add(c);
                }
            }          
            
            //Call method to check duplicates for the modified contacts
            DuplicateCheck(lstUpdated);
        }
        autoDQProcess(lstNew,mapOld);    
        populateAutoDQTimestamp(lstNew,mapOld); //<T02>
        //<PSA-3079> - Start
        psa_us_ContactTriggerHelper.updateOnRMOContactfieldOnContact(mapOld,lstNew);
        //<PSA-3079> - End 
    }
    
 /**
  * @description - this method is invoked from afterInsert event of Contacts
  * @param newContList - list of new contacts
  * @param newConMap - map of new contacts
  * @throws exception - NA
  */
  public static void contactAfterInsert(List<Contact> newContList, Map<Id, Contact> newConMap) {
        
    //system.debug('**Handler-newContList**________'+newContList);
    //system.debug('**Handler-newConMap**________'+newConMap);
   
   // @Akhilesh 17 Aug 2021 - start
   //commented as there is no "psa_us_ContactTriggerHelper" exists, code merged on request of Kiran Gudadinni
    psa_us_ContactTriggerHelper.handlePSEAfterContactInsertActions(newContList,newConMap);
   // @Akhilesh 17 Aug 2021 - end
   calculatePredectiveScore(newContList,null);

}

 /**
  * @description - this method is invoked from afterDelete event of Contacts
  * @param oldList - list of old contacts
  * @param oldMap - map of old contacts
  * @throws exception - NA
  */
    public static void contactAfterDelete(List<Contact> oldList, Map<Id,Contact> oldMap){
        calculatePredectiveScore(oldList,oldMap);
    }

 /**
  * @description - this method is invoked from afterUnDelete event of Contacts
  * @param newList - list of new contacts
  * @param newMap - map of new contacts
  * @throws exception - NA
  */
    public static void contactAfterUndelete(List<Contact> newList, Map<Id,Contact> newMap){
        calculatePredectiveScore(newList,null);
    }

   /**
  * @description - this method is invoked from afterupdate event of Contacts
  * @param lstNew - list of new contacts
  * @param mapNew - map of new contacts
  * @param mapOld - map of old contacts
  * @throws exception - NA
  */
    Public static void contactAfterUpdate(List<Contact> lstNew, Map<Id, Contact> mapNew, Map<Id, Contact> mapOld) {
    
    sharingDRAfterUpdate(lstNew, mapNew, mapOld);
    psa_us_ContactTriggerHelper.handlePSEAfterContactUpdateActions(lstNew, mapNew, mapOld);                                                                                                                  
       // updateCaseTimezone(LstNew, mapNew, mapOld);
    calculatePredectiveScore(lstNew,mapOld);
  }
    
    
    /**
  * @description - This method checks for duplicate records . 
  * If leads or contacts are found with same email address display error with list of ids of duplicate leads and contacts 
  * @param lstNew - list of new contacts
  * @throws exception-captures exception in a Exception log record
  */
    
    static void duplicatecheck(List<Contact> lstNew){
        Set<String> setNewEmail = new set<String>();// Set of possible duplicate emails
        map<String,set<id>>  mapdupLeads= new map<String,set<id>>();//duplicate leads
        map<String,set<id>> mapdupContacts = new map<String,set<id>>();//duplicate contacts   
        
        
        if(lstNew!=null && lstNew.size()>0){
            
            //Create debug logs
            gam.Createlogs('ContactTriggerHandler- DuplicateCheck',lstNew,'lstNew');
            
            //Set of new emails to lookup for duplicates
            For(Contact con: lstNew){    
                setNewEmail.add(con.email);
            }
            
            try{
                
                //query for dulicate leads with same email
                // PRM - updated the condition to fetch only Lead record type leads (exclude Deal Registration leads)
                For( Lead dl : [select id,name, email from lead where isconverted=false 
                        and email in :setNewEmail and RecordType.DeveloperName='Lead']){
                    
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
                    
                    //group duplicate ContactIds by email             
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
                    for(Contact con: lstNew){
                      
                        string errormsg='';
                        
                        //Error msg when duplicates exist in both leads and contacts                        
                        if((mapdupLeads.keyset().contains(con.email))&& con.ConvertedFromLead__c==false &&
            (mapdupContacts.keyset().contains(con.email))) {                                      
                            errormsg = gam.DisplayErrorMessage('DuplicateLeads')+ mapdupLeads.get(con.email)+ '\n'+  GAM.DisplayErrorMessage('DuplicateContacts') + mapdupContacts.get(con.email) ;
                            con.adderror (errormsg , false);
                        }
                        
                        //Error msg when duplicates exist in both leads
                        if(mapdupLeads.keyset().contains(con.email) && con.ConvertedFromLead__c==false &&
            !(mapdupContacts.keyset().contains(con.email)))  {
              errormsg = gam.DisplayErrorMessage('DuplicateLeads')+ mapdupLeads.get(con.email);
                            con.adderror (errormsg , false);
            }
                        
                        
                        //Error msg when duplicates exist in both contacts
                        if(!(mapdupLeads.keyset().contains(con.email))&&(mapdupContacts.keyset().contains(con.email))){
                            errormsg = gam.DisplayErrorMessage('DuplicateContacts')+ mapdupContacts.get(con.email);
                            con.adderror (errormsg , false);
                        }
                        
                    }
                    
                }
            } 
            Catch(Exception ex){
                gam.CreateExceptionRecords( 'ContactTriggerHandler', 'exception in duplicatecheck', ex.getMessage());
                
            }
        }
        //Insert debug Logs
        gam.Insertdebuglogs();
    }
    
  
  /**
    * @description - PRM: this method is invoked from after update event of Contact
    * this method will activate sharing or Deal Registrations if View_All_Deal_Registrations__c is checked
    * @param triggerNew - list of contacts
    * @param triggerNewMap - map of new contacts
    * @param triggerOldMap - map of old contacts
    * @throws exception - NA
    */
    public static void sharingDRAfterUpdate(List<Contact> triggerNew, map<id,Contact> triggerNewMap, map<id,Contact> triggerOldMap){
    
    //list uf users that have to be activated if View_All_Deal_Registrations__c is checked
    List<id> allowShareUserList = new List<id>();
    
    //list uf users that have to be deactivated if View_All_Deal_Registrations__c is unchecked
    List<id> disallowShareUserList = new List<id>();
    
    //map of Contact Id wise User Id
    Map<Id,Id> contactIdwiseUserIdMap = new Map<Id,Id>();
      
    List<Id> contactList = new List<Id>();
    
    //check if View_All_Deal_Registrations__c is changed
    for(Contact contact : triggerNew){
      if(triggerOldMap.get(contact.Id).View_All_Deal_Registrations__c != triggerNewMap.get(contact.Id).View_All_Deal_Registrations__c)
      {
        contactList.add(contact.Id);
      }
    }  
    
    for(User usr : [select Id,ContactId from User where ContactId <> null AND ContactID IN: contactList]){
        ContactIdwiseUserIdMap.put(usr.ContactId,usr.Id);
      
      }
      
    //check if View_All_Deal_Registrations__c is changed
    for(Contact contact : triggerNew){
      //If View_All_Deal_Registrations__c is checked, add to allowShareUserList
      if(triggerOldMap.get(contact.Id).View_All_Deal_Registrations__c != triggerNewMap.get(contact.Id).View_All_Deal_Registrations__c && contact.View_All_Deal_Registrations__c)
      {
        if(ContactIdwiseUserIdMap != null && ContactIdwiseUserIdMap.get(contact.id) != null){
            allowShareUserList.add(ContactIdwiseUserIdMap.get(contact.id));
        }
      }
      //else add to disallowShareUserList
      else if(triggerOldMap.get(contact.Id).View_All_Deal_Registrations__c != triggerNewMap.get(contact.Id).View_All_Deal_Registrations__c && !contact.View_All_Deal_Registrations__c)
      {
        if(ContactIdwiseUserIdMap != null && ContactIdwiseUserIdMap.get(contact.id) != null){
            disallowShareUserList.add(ContactIdwiseUserIdMap.get(contact.id));
        }
      }
    }
    
    if(allowShareUserList.size() > 0){
            ApexSharingUtility.enableDRsharingForActiveUsers(allowShareUserList);
        }
        
        if(disallowShareUserList.size() > 0){
            ApexSharingUtility.disableDRsharingForInactiveUsers(disallowShareUserList);
        }
    }
    
    /**
    * @description - PRM: This method checks for duplicate primary contacts while Inserting. 
    * If a primary contact already found for the same account then throws error and blocks user from Inserting the contact. 
    * @param newCons - list of new contacts
    */
    
  public static void contactPrimaryInsertionDupeChecker(List<contact> newCons)
  {
      Set<Id> accWithNewConsSet = new Set<Id>();
      Map<Id,Boolean> accWithPrimaryConMap = new Map<Id,Boolean>();
      
      //Prepares the set of Account Ids that contacts are linked to
      If(newCons.size()>0)
      {
          for(Contact c : newCons)
          {
              If(c.Is_Primary__c == True)
              {accWithNewConsSet.add(c.AccountId);}
          }
      }
      
      //Checks the above Account Id set and forms a map with Account Id and Value set to 'True' if there's any primary contact for that account.
      If(accWithNewConsSet.size()>0)
      {
          for(Account a : [select id,(select id, Is_Primary__c from contacts where Is_Primary__c = True) from Account WHERE Id IN: accWithNewConsSet])
          {
              accWithPrimaryConMap.put(a.id, a.contacts.size()>0 ? true : false);
          }
      }
      
      //Iterates over the new contacts and validates with above Account Map and throws Error
      If(!accWithPrimaryConMap.isEmpty())
      {         
          for(SObject s : Trigger.New)
          {
              Contact c = (Contact)s;              
              //Validation will happen only if a primary contact is getting created, else not
              If(c.Is_Primary__c == True && accWithPrimaryConMap.get(c.AccountId) == true)
              {c.addError(label.PRM_Contact_Primary_Error);}
          }
      }
  }
  
  /**
    * @description - PRM: This method checks for duplicate primary contacts while Updating. 
    * If a primary contact already found for the same account then throws error and blocks user from Updating the contact. 
    * @param oldCons - Map of old Contacts
    * @param newCons - Map of new contacts
    */
    
  public static void contactPrimaryUpdationDupeChecker(Map<Id,Contact> oldCons,Map<Id,Contact> newCons)
  {
      Set<Id> accWithNewConsSet = new Set<Id>();
      Map<Id,Boolean> accWithPrimaryConMap = new Map<Id,Boolean>();
      //Map<Id,Id> accWithPrimaryConIdMap = new Map<Id,Id>();
      
      //Prepares the set of Account Ids that contacts are linked to
      If(newCons.size()>0)
      {
          for(Contact c : [SELECT AccountId,Is_Primary__c from Contact where Id IN :newCons.KeySet()])
          {
              accWithNewConsSet.add(c.AccountId);
          }
      }
      
      //Checks the above Account Id set and forms a map with Account Id and Value set to 'True' if there's any primary contact for that account.
      If(accWithNewConsSet.size()>0)
      {
          for(Account a : [select id,(select id, Is_Primary__c from contacts where Is_Primary__c = True) from Account WHERE Id IN: accWithNewConsSet])
          {
              accWithPrimaryConMap.put(a.id, a.contacts.size()>0 ? true : false);
          }
      }
      
      //Iterates over the new contacts and validates with above Account Map and throws Error
      If(!accWithPrimaryConMap.isEmpty())
      {         
          for(SObject s : Trigger.New)
          {
              Contact c = (Contact)s;
              
              //Since it's an update, includes only when a non-primary contact made primary and excludes all other scenarios
              If(c.Is_Primary__c != oldCons.get(c.Id).Is_Primary__c && c.Is_Primary__c == True)
              {  
                  
                  If(accWithPrimaryConMap.get(c.AccountId) == true)
                    
                  {c.addError(label.PRM_Contact_Primary_Error);}
              }
          }
      }
  }
    
     //<T01>
    /**
    * @description - This method populates related Campaign Series of the MQL Program Name on the Contact
    * @param triggerNew - list of new contacts
    * @param oldMap - map of old contacts
    */
    public static void populateCampaignSeries(List<Contact> triggerNew, Map<Id, Contact> oldMap){
        Set<String> assocCampaigns=new Set<String>();
        Map<string, Campaign> campSeriesNames = new Map<string, Campaign>();
        List<Contact> contactList=new List<Contact>();
        
        for(Contact campContact:triggerNew){
        
            if(campContact.MQL_Program_Name__c != null && campContact.MQL_Program_Name__c != '' && (trigger.isinsert ||(trigger.isupdate && campContact.MQL_Program_Name__c != oldMap.get(campContact.Id).MQL_Program_Name__c))){
                assocCampaigns.add(campContact.MQL_Program_Name__c);
                contactList.add(campContact);
            }
        } 
        
        List<Campaign> campList = 
            [SELECT Id, Name, Campaign_Series__c,Salesloft_Cadence__c FROM Campaign WHERE Name IN :assocCampaigns];

        for(Campaign c:campList){
            
            campSeriesNames.put(c.Name,c);
        }
        
        for(Contact updateContact : contactList){
            
            if(campSeriesNames != null && campSeriesNames.containsKey(updateContact.MQL_Program_Name__c)){

                updateContact.Campaign_Series__c = campSeriesNames.get(updateContact.MQL_Program_Name__c).Campaign_Series__c;
                updateContact.Salesloft_Cadence__c = campSeriesNames.get(updateContact.MQL_Program_Name__c).Salesloft_Cadence__c;
            }
        } 
    }
   /*   
  public static void updateCaseTimezone(List<Contact> triggerNew, map<id,Contact> triggerNewMap, map<id,Contact> triggerOldMap){
    //System.debug('@Developer -->updateCaseTimezone:' );
    
    set<Id> setConId = new set<Id> (); 
    for(Contact con : triggerNew){
        if(con.TimeZone_Lookup__c != null && con.TimeZone_Lookup__c != triggerOldMap.get(con.Id).TimeZone_Lookup__c){  
            setConId.add(con.Id);
        }
    }
    //System.debug('@Developer --> setConId :' + setConId);
    
    String sCaseSOQL = 'Select Id,Case_Timezone__c,ContactId From Case Where IsClosed = false And ContactId In: setConId And (' + Label.CaseTimeZoneUpdateCriteria + ')';
    
    list<Case> lstCaseToUpdate = new list<Case>();
    
    for(Case cse : database.query(sCaseSOQL)){
        Contact con = triggerNewMap.get(cse.ContactId);
        if(cse.Case_Timezone__c != con.TimeZone_Lookup__c){
            cse.Case_Timezone__c = con.TimeZone_Lookup__c;
            lstCaseToUpdate.add(cse);
        }
    }
    //System.debug('@Developer --> lstCaseToUpdate.size() :' + lstCaseToUpdate.size());
    if(lstCaseToUpdate.size() > 0){
        update lstCaseToUpdate;
    }
  }
*/
  /**
    * @description - This method is used to empty disqualified reason if the status is changed. 
    * @param newList - list of contacts
    * @param oldMap - map of old contacts
    * @throws exception - NA
    */   
    public static void autoDQProcess(List<Contact> newList, Map<Id,Contact> oldMap){
        for(Contact con : newList){
            if(((oldMap == null) || (oldMap != null && oldMap.get(con.Id).Contact_Status__c != con.Contact_Status__c)) && con.Contact_Status__c != 'Disqualified' && con.Disqualified_Reason__c != null){
                con.Disqualified_Reason__c = '';
            }
            if(((oldMap == null) || (oldMap != null && oldMap.get(con.Id).SL_Person_Stage__c != con.SL_Person_Stage__c)) && 
                (con.SL_Person_Stage__c == 'Completed' && (con.Contact_Status__c == 'Working' || con.Contact_Status__c == 'New'))){
            
                    con.Auto_DQ__c = true;
                    con.Contact_Status__c = 'Disqualified';
                    con.Disqualified_Reason__c = 'Auto DQ from completed cadence';
            }
        }
    }

    /**
    * @description - This method is used to populate autodq timestamp field
    * @param newList - List of contacts
    * @param oldMap - map of old contacts
    * @throws exception - NA
    */   
    //<T02> start
    public static void populateAutoDQTimestamp(List<Contact> newList, Map<Id,Contact> oldMap){
        Set<String> statusStageSet = new Set<String>{'Working:New','Working:Working','Replied:New','Replied:Working','Bounced:New','Bounced:Working'};
        for(Contact con : newList){
            if(((oldMap == null) || (oldMap != null && (oldMap.get(con.Id).Contact_Status__c != con.Contact_Status__c || oldMap.get(con.Id).SL_Person_Stage__c != con.SL_Person_Stage__c )))){
                String key = con.SL_Person_Stage__c + ':' + con.Contact_Status__c;
                if(statusStageSet.contains(key)){
                    con.Auto_DQ_Timestamp__c = System.now();
                }
                else{
                    con.Auto_DQ_Timestamp__c = null;
                }
            }
        }
    }
    //<T02> end

     /**
    * @description - This method is used to calculate predective score
    * @param contactList - List of contacts
    * @param oldMap - map of old contacts 
    * @throws exception - NA
    */   
    //<SALESRT-14408> start
    public static void calculatePredectiveScore(List<Contact> contactList, Map<Id,Contact> oldMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
            for(Contact con : contactList){
                if((
                    (oldMap == null) || 
                        (oldMap != null && 
                            (
                                oldMap.get(con.Id).LS_Person_Predictive_Score__c != con.LS_Person_Predictive_Score__c || 
                                oldMap.get(con.Id).AccountId != con.AccountId 
                            )
                        )
                    ) && !con.pse__Is_Resource__c
                    ){
    
                    accountIdSet.add(con.AccountId);
    
                    if(oldMap != null && oldMap.get(con.Id).AccountId != null && con.AccountId != oldMap.get(con.Id).AccountId){
                        accountIdSet.add(oldMap.get(con.Id).AccountId);
                    }
                }
            }
        }
        if(Trigger.isDelete){
            for(Contact con : contactList){
                if(con.AccountId != null){
                    accountIdSet.add(con.AccountId);
                }
            }
        }

        if(!accountIdSet.isEmpty() && !System.isFuture() && !System.isBatch()){
            ApexUtilitySales.calculateAccountPredectiveBucket(accountIdSet);
        }
    }
    //<SALESRT-14408> end
}