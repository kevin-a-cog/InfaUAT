/*
* Name			:	CSMPlanContactTriggerHelper
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Helper Class for Plan Contact Trigger

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMPlanContactTriggerHelper {
    public static globalApexManager GAM = new globalApexManager();
    private CSMDuplicatePlanContactValidation validationHelper = new CSMDuplicatePlanContactValidation();
    public static String STRING_ACCOUNT_RECORD_TYPE_NAME = 'Partner Account';
    public static String strPartnerAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(STRING_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();

    public static String STRING_PLAN_PARTNER_RECORD_TYPE_NAME = 'Plan_Partner';
    public static String strPlanPartnerRecordTypeId = Schema.SObjectType.Partner_Relationship__c.getRecordTypeInfosByDeveloperName().get(STRING_PLAN_PARTNER_RECORD_TYPE_NAME).getRecordTypeId();
      /*
    Method Name : processBeforeInsert
    Description : This method will trigger for beforeinsert
    Parameters	: List of new Plan Contact instance and old map                
    Return Type : n/a
    */  
    public void processBeforeInsert(List<Plan_Contact__c> newList){
        //valdiate records and trigger if the duplciate record found
        populateDetails(newList);
    }
    /*
    Method Name : processBeforeUpdate
    Description : This method will trigger for before update and refine the records
    Parameters	: List of new Plan Contact instance and old map                
    Return Type : n/a
    */  
    public void processBeforeUpdate(List<Plan_Contact__c> newList,Map<Id,Plan_Contact__c> oldMap){
        List<Plan_Contact__c> refinedPlanContactList = new List<Plan_Contact__c>();
        for(Plan_Contact__c pCont : newList ){
            if(oldMap.containsKey(pCont.Id) && oldMap.get(pCont.Id).Contact__c != pCont.Contact__c){
                refinedPlanContactList.add(pCont);
            }
        }
        if(refinedPlanContactList.size()>0){
            populateDetails(newList);
        }
    }
     /*
    Method Name : processafterUpdate
    Description : This method will trigger for after update and refine the records
    Parameters	: List of new Plan Contact instance and old map                
    Return Type : n/a
    */  
    public void processafterUpdate(List<Plan_Contact__c> newList,Map<Id,Plan_Contact__c> oldMap){
        List<Plan_Contact__c> refinedPlanContactList = new List<Plan_Contact__c>();
        Set<Id> setPlanContactId = new Set<Id>();
        Map<Id,Id> mapPlanContact = new Map<Id,Id>();
        for(Plan_Contact__c pCont : newList ){
            if(oldMap.containsKey(pCont.Id) && oldMap.get(pCont.Id).Is_Success_Community_User__c != pCont.Is_Success_Community_User__c && pCont.Contact__c!=null){
                refinedPlanContactList.add(pCont);
                setPlanContactId.add(pCont.Id);
            }
        }
        if(refinedPlanContactList.size()>0){
            createAccountRelation(setPlanContactId);
            System.enqueueJob(new CSMAltifyQueueable(refinedPlanContactList));
            mapPlanContactWithPartners(refinedPlanContactList);
        }
    }

      /*
    Method Name : processAfterInsert
    Description : This method will trigger for after insert
    Parameters	: List of new Plan Contact instance and old map                
    Return Type : n/a
    */  
    public void processAfterInsert(List<Plan_Contact__c> newList){
        Set<Id> setPlanContactId = new Set<Id>();
        for(Plan_Contact__c pCont : newList ){
            if(pCont.Contact__c!=null && pCont.Is_Success_Community_User__c){
                setPlanContactId.add(pCont.Id);
            }
        }
        if(setPlanContactId.size()>0){
            createAccountRelation(setPlanContactId);
        }
        System.enqueueJob(new CSMAltifyQueueable(newList));
        mapPlanContactWithPartners(newList);
    }

        /*
    Method Name : populateDetails
    Description : This method will trigger for before update and prepopulate fields on plan contact records
    Parameters	: List of new Plan Contact records               
    Return Type : n/a
    */ 
    public void populateDetails(List<Plan_Contact__c> newList){
        Set<Id> refinedContactSet = new Set<Id>();      
        for(Plan_Contact__c pTeam : newList ){
            //Filter the Contact id's
            if(pTeam.Contact__c!=null){
                refinedContactSet.add(pTeam.Contact__c);
            }
        }
        if(!refinedContactSet.isEmpty()){
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,Name,Email FROM Contact WHERE Id IN:refinedContactSet]);
            for(Plan_Contact__c cont : newList ){
                //Check if the Contact record queried and map contains Contact id
                if(contactMap.containsKey(cont.Contact__c)){
                    //Assign the Contact params
                    Contact obtainedContact=contactMap.get(cont.Contact__c);
                    cont.Contact_email__c=obtainedContact.Email;
                }
            }             
            //valdiate records and trigger if the duplciate record found
            validationHelper.validate(newList);
        }        
    }
          /*
    Method Name : mapPlanContactWithPartners
    Description : This method will trigger for After update and Plan Contact is Created, 
                  if the related Account of the Contact is of Type = Partner.
                  Then the Partner Account should be automatically added to Plan Partners (Assigned Tab).
    Parameters	: List of new Plan Contact records               
    Return Type : n/a
    */ 
    public void mapPlanContactWithPartners(List<Plan_Contact__c> refinedList){
        Set<Id> refinedAccountSet = new Set<Id>();  
        Set<Id> planIdSet = new Set<Id>(); 
        List<Partner_Relationship__c> upsertPartnerRelationShipList = new List<Partner_Relationship__c>();
        Map<Id,Plan_Contact__c> planContactMap = new Map<Id,Plan_Contact__c>();
        //query plan contact and refine the accoutid and plan contact
        for(Plan_Contact__c pc : [SELECT Plan__c, Contact__c, Contact__r.AccountId FROM Plan_Contact__c WHERE Id IN:refinedList]){
            if(pc.Contact__c!=null && pc.Contact__r.AccountId != null){
                refinedAccountSet.add(pc.Contact__r.AccountId);
            }
            if(pc.Plan__c!=null){
                planIdSet.add(pc.Plan__c);                
                planContactMap.put(pc.Contact__r.AccountId,pc);
            }
        }
        if(refinedAccountSet.size()>0){
            Map<Id,Partner_Relationship__c> partnerMap = new Map<Id,Partner_Relationship__c>();
            //Query exisitng parter relation ship records with the plan contact account and associate with plan 
            for(Partner_Relationship__c pr:[SELECT Id, CreatedDate, Partner_Account__c, Opportunity__c,
                                            Partner_Account__r.Name,Opportunity__r.Name, Plan__c FROM Partner_Relationship__c
                                            WHERE Partner_Account__c IN : refinedAccountSet AND Partner_Account__r.RecordTypeId = :strPartnerAccountRecordType AND RecordTypeId = : strPlanPartnerRecordTypeId]){
                if(planContactMap.containsKey(pr.Partner_Account__c) && planContactMap.get(pr.Partner_Account__c)!=null && pr.Plan__c==null) {
                    pr.Plan__c=planContactMap.get(pr.Partner_Account__c).Plan__c;
                    upsertPartnerRelationShipList.add(pr);
                }
                partnerMap.put(pr.Partner_Account__c,pr);
            }           
            //Then update the records
            if(upsertPartnerRelationShipList.size()>0){
                update upsertPartnerRelationShipList;
            }
        }
    }
   /*
    Method Name : createAccountRelation
    Description : This method will trigger for After update and After insert event of plan contact trigger, 
                  this will Create Account Contact relation once the plan contact added 
    Parameters	: set of new Plan Contact Id               
    Return Type : n/a
    */ 
    public void createAccountRelation(Set<Id> setPlanContactId){
        List<Plan_Contact__c> lstPlanContacts = new List<Plan_Contact__c>();
        List<AccountContactRelation> lstAccountContactRelation = new List<AccountContactRelation>();
        Set<Id> setPlanAccountId = new Set<Id>();
        Set<Id> setContacId = new Set<Id>();
        Map<String,AccountContactRelation> mapAccountContact = new Map<String,AccountContactRelation>();
        
        for(Plan_Contact__c pcObj:[Select Plan__c,Contact__c, Plan__r.Account__c,Contact__r.Email,Id from Plan_Contact__c where Id IN: setPlanContactId] ){
            lstPlanContacts.add(pcObj);
            setPlanAccountId.add(pcObj.Plan__r.Account__c);
            if(pcObj.Contact__c!=null){
                setContacId.add(pcObj.Contact__c); 
            }
        }
        //Query existing Account contact relation ship records
        if(setPlanAccountId.size()>0 && setContacId.size()>0){
            for(AccountContactRelation objACR:[SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId=:setPlanAccountId AND ContactId=: setContacId]){
                mapAccountContact.put(objACR.AccountId+'-'+objACR.ContactId,objACR);
            }
        }
        for(Plan_Contact__c pcObj:lstPlanContacts){
            String strAccountContact = pcObj.Plan__r.Account__c+'-'+pcObj.Contact__c;
            if(!(mapAccountContact.get(strAccountContact)!=null)){
                lstAccountContactRelation.add(new AccountContactRelation(AccountId=pcObj.Plan__r.Account__c,ContactId=pcObj.Contact__c));
            }
        }
        //Inser Account contact relation records
        if(lstAccountContactRelation.size()>0){
            try{
                Database.insert(lstAccountContactRelation, false);                
            } catch(Exception e){
                GAM.CreateLogs('CSMPlanContactTriggerHelper.createAccountRelation() -> ' + e.getCause(), lstAccountContactRelation, 'lstAccountContactRelation');
            }
        }
    }
    

    /*
      public void deleteAltifyContact(List<Plan_Contact__c> sobjectRecords) {
        Set<String> allPlanConRec=new Set<String>();
        if(!sobjectRecords.isEmpty()){
            for(Plan_Contact__c getAllPlanRec: sobjectRecords ){
                allPlanConRec.add(getAllPlanRec.Id);
            }
            List<ALTF__Contact_Map_Details__c> getAllAltifyMap=[Select Id from ALTF__Contact_Map_Details__c where Name IN:allPlanConRec ];
            if(!getAllAltifyMap.isEmpty()){
                delete getAllAltifyMap;
            }
            System.debug('delete*'+allPlanConRec);
        }
         
     }
    */

      public void processBeforeDelete (List<Plan_Contact__c> newList)
    { 
        //do not run if the current user is sys admin, integration user, superuser
            List<Id> allIds=new List<Id>();
            Map<Id,Boolean> idvsbool=new Map<Id,boolean>();
            System.debug('In Plan contact');
            for( Plan_Contact__c ac:newList){
                //restricts non-admins/non-superusers/CSOs from delting account
                allIds.add(ac.Plan__c);
                System.debug('In Plan contact');
               
            }
            if(!allIds.isEmpty()){
                List<Plan__c> allPlans=[Select Id,CSM_isAutoPilot__c from Plan__c where Id IN:allIds];

                for(Plan__c pc:allPlans){
                    if(pc.CSM_isAutoPilot__c==true){
                        System.debug('In Plan contact');
                        idvsbool.put(pc.Id,pc.CSM_isAutoPilot__c);
                    }
                }
            }
            if(!idvsbool.isEmpty()){
                for( Plan_Contact__c ac:newList){
                    System.debug('In Plan contact');
                    //restricts non-admins/non-superusers/CSOs from delting account
                    Boolean val=idvsbool.get(ac.Plan__c);
                    if(val==true){
                        ac.addError('Cannot Delete In Auto Pilot Mode');
                    }
                }
            }
        
    }
    
     /*
    Method Name : updatePlanrecord
    Description : This method will trigger for After update and when the surevey is sent to plan contact.
				  The related plan record is updated.
    Parameters	: set of new Plan Contact Id               
    Return Type : n/a
    */ 
    public  void updatePlanrecord(List<Plan_Contact__c> newList)
    {
        List<Id> allIds=new List<Id>();
        Map<Id,Plan__c> updateplan=new Map<Id,Plan__c> ();
          for(Plan_Contact__c pCont : newList )
            {
                
                List<Plan__c> lstplan = new List<Plan__c>([Select id,Onboarding_Survey_Sent__c,Business_Outcome_Survey_Sent__c from Plan__c where Id =:pCont.Plan__c]);                               
                    System.debug(' plan Size'+lstplan.size());
                    if(lstplan.size()>0) 
                    {                                  
                        for(Plan__c plan:lstplan)
                        {
                            System.debug(' plan.Onboarding_Survey_Sent__c'+ plan.Onboarding_Survey_Sent__c);
                            
                            if (pCont.Onboarding_Survey_Sent__c && !plan.Onboarding_Survey_Sent__c)
                            {
                                plan.Onboarding_Survey_Sent__c = true;
                                updateplan.put(plan.id,plan);
                                System.debug(' plan.Onboarding_Survey_Sent__c'+ plan.Onboarding_Survey_Sent__c);
                                System.debug(' plan.ID'+ plan.ID);
                                
                            }
                            if (pCont.Business_Outcome_Survey_Sent__c && !plan.Business_Outcome_Survey_Sent__c)
                            {
                                plan.Business_Outcome_Survey_Sent__c = true;
                                updateplan.put(plan.id, plan);
                                System.debug(' plan.Business_Outcome_Survey_Sent__c'+ plan.Business_Outcome_Survey_Sent__c);
                                System.debug(' plan.ID'+ plan.ID);
                            }
                        }
                    }     
            } 
            if(updateplan.size()>0 && updateplan != null)
            {
                try{
                    Database.update(updateplan.values(), true);
                }
                catch(Exception e)
                {
                    GAM.CreateLogs('CSMPlanContactTriggerHelper.updatePlanrecord() -> ' + e.getCause(), updateplan.values(), 'updateplan');
                } 
                
            }                    
        
    } 

  
    /*
    Method Name : updateEngagmentrecord
    Description : This method will trigger for After update and when the CST surevey is sent to plan contact.
				  The related CST engagement record is update.
    Parameters	: set of new Plan Contact Id               
    Return Type : n/a
    */    
    public void updateEngagmentrecord(List<Plan_Contact__c> newList)
    {
        Map<Id,Engagement__c> updateeng = new Map<Id,Engagement__c> ();
            for(Plan_Contact__c pCont : newList )           
            {
                System.debug('eng log');
                List<Engagement__c> lsteng=new List<Engagement__c>([select id,CST_Survey_Sent__c,MFA_Survey_Sent__c,RecType__c from Engagement__c where Plan__r.Id=:pCont.Plan__c and  RecordType.DeveloperName = 'CST' And Status__c='Completed' order by createdDate DESC limit 1]);
                if(lsteng.size()>0)
                {
                    System.debug('eng log1');
                    for(Engagement__c eng:lsteng)
                    {
                        if(eng.RecType__c=='CSA' && pCont.CST_Survey_Sent__c && !eng.CST_Survey_Sent__c)
                        {
                            eng.CST_Survey_Sent__c = true;
                            updateeng.put(eng.id, eng);

                        }else if(eng.RecType__c=='MFA' && pCont.MFA_Survey_Sent__c && !eng.MFA_Survey_Sent__c)
                        {
                            eng.MFA_Survey_Sent__c = true;
                            updateeng.put(eng.id, eng);
                        }
                                            
                    }
                }
            }
            if(updateeng.size()>0 && updateeng !=null)
            {
                
                try{
                    Database.update(updateeng.values(), true);
                }
                catch(Exception e)
                {
                    GAM.CreateLogs('CSMPlanContactTriggerHelper.updateEngagmentrecord() -> ' + e.getCause(), updateeng.values(), 'updateeng');
                } 
            } 
    } 
  
}