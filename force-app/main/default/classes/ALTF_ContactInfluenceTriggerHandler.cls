/*
Class:          ALTF_ContactInfluenceTriggerHandler 
@Author:        Uday Gangula
@Created Date:  20-NOV-2021
@Description:   Apex Class on Altify Contact Influence Object.
*/
/*
Change History
*************************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                                Tag
*************************************************************************************************************************************************************************************
Uday Kumar         20-NOV-2021     SALESRT-13318            To put all the Conflict, Influenced and Influenced By contacts in format of string on the contact record        T<01>

*/


public class ALTF_ContactInfluenceTriggerHandler{
    public static globalApexManager GAM = new globalApexManager();
    static Set<Id> InfluencingConIds = new set<Id>();
    static Set<Id> InfluencedConIds = new Set<Id>();
    static Map<Id,Set<Id>> InfluencingIdInfluencersMap = new Map<Id,Set<Id>>();
    static Map<Id,set<Id>> InfluencingIdConflictsMap = new Map<Id,set<Id>>();
    static Map<Id,Set<Id>> InfluecedIdInfluencedByMap = new Map<Id,Set<Id>>();
    static Map<Id,Set<Id>> InfluencedIdConflictsMap = new Map<Id,Set<Id>>();
    static Map<Id,Contact> allContactsMap = new Map<Id,Contact>();
    Static Set<Id> ConIds = new Set<Id>();
    static List<Contact> contactsToUpdate = new List<Contact>();
    
    public static void AltifyContactInfluenceUpdates(Map<Id,ALTF__Contact_Influence__c> newAciMap,Map<Id,ALTF__Contact_Influence__c> oldAciMap){
        if(Trigger.IsInsert || Trigger.IsUpdate){
            for(ALTF__Contact_Influence__c acNew:newAciMap.values()){
                if(acNew.ALTF__Influencing_Contact__c!=null){
                    InfluencingConIds.add(acNew.ALTF__Influencing_Contact__c);
                    ConIds.add(acNew.ALTF__Influencing_Contact__c);
                }
                if(acNew.ALTF__Influenced_Contact__c!=null){
                    InfluencedConIds.add(acNew.ALTF__Influenced_Contact__c);
                    ConIds.add(acNew.ALTF__Influenced_Contact__c);
                }
            }
        }
        if(Trigger.Isupdate || Trigger.Isdelete){
            for(ALTF__Contact_Influence__c acOld:oldAciMap.values()){
                if(acOld.ALTF__Influencing_Contact__c!=null){
                    InfluencingConIds.add(acOld.ALTF__Influencing_Contact__c);
                    ConIds.add(acOld.ALTF__Influencing_Contact__c);
                }
                if(acOld.ALTF__Influenced_Contact__c!=null){
                    InfluencedConIds.add(acOld.ALTF__Influenced_Contact__c);
                    ConIds.add(acOld.ALTF__Influenced_Contact__c);
                }  
            }
        }
        for(ALTF__Contact_Influence__c aciNew:[Select ALTF__Influencing_Contact__c,Id,ALTF__Influenced_Contact__c,ALTF__Type__c from ALTF__Contact_Influence__c where ALTF__Influencing_Contact__c IN :ConIds OR ALTF__Influenced_Contact__c IN :ConIds]){
        Set<Id> existingInfluencedContactSet = new Set<Id>();
        Set<Id> existingConflictContactSet = new Set<Id>();
        Set<Id> existingInfluencedBYContactSet = new Set<Id>();
            if(aciNew.ALTF__Influencing_Contact__c!=null && aciNew.ALTF__Influenced_Contact__c!=null){
                if(aciNew.ALTF__Type__c=='Influence'){
                    if(InfluencingIdInfluencersMap.keyset().contains(aciNew.ALTF__Influencing_Contact__c)){
                        existingInfluencedContactSet.addall(InfluencingIdInfluencersMap.get(aciNew.ALTF__Influencing_Contact__c));  
                    }
                    existingInfluencedContactSet.add(aciNew.ALTF__Influenced_Contact__c);
                    if(InfluecedIdInfluencedByMap.Keyset().contains(aciNew.ALTF__Influenced_Contact__c)){
                        existingInfluencedBYContactSet.addall(InfluecedIdInfluencedByMap.get(aciNew.ALTF__Influenced_Contact__c));
                    }
                    existingInfluencedBYContactSet.add(aciNew.ALTF__Influencing_Contact__c);
                }
                if(aciNew.ALTF__Type__c=='Conflict'){
                    if(InfluencingIdConflictsMap.keyset().contains(aciNew.ALTF__Influencing_Contact__c)){
                        existingConflictContactSet.addall(InfluencingIdConflictsMap.get(aciNew.ALTF__Influencing_Contact__c));
                    }
                    existingConflictContactSet.add(aciNew.ALTF__Influenced_Contact__c);
                }
            }
            if(!existingInfluencedContactSet.isEmpty())
                InfluencingIdInfluencersMap.put(aciNew.ALTF__Influencing_Contact__c,existingInfluencedContactSet);
            if(!existingInfluencedBYContactSet.isEmpty())
                InfluecedIdInfluencedByMap.put(aciNew.ALTF__Influenced_Contact__c,existingInfluencedBYContactSet);
            if(!existingConflictContactSet.isEmpty())
                InfluencingIdConflictsMap.put(aciNew.ALTF__Influencing_Contact__c,existingConflictContactSet);
        }
        for(Id ConflictId:InfluencingIdConflictsMap.keyset()){
            for(Id ChildConflictId:InfluencingIdConflictsMap.get(ConflictId)){
            Set<Id> existingChildConflictIds = new Set<Id>();
                if(InfluencingIdConflictsMap.keyset().contains(ChildConflictId)){
                    existingChildConflictIds.addAll(InfluencingIdConflictsMap.get(ChildConflictId));
                }
            existingChildConflictIds.add(ConflictId);
            InfluencingIdConflictsMap.put(ChildConflictId,existingChildConflictIds);
            }
        }
            ConIds.addAll(InfluencingIdInfluencersMap.keyset());
            ConIds.addAll(InfluecedIdInfluencedByMap.Keyset());
            ConIds.addAll(InfluencingIdConflictsMap.keyset());
            ConIds.addAll(InfluencedIdConflictsMap.keyset()); 
        for(Contact con:[Select Id,name,AccountId from Contact where Id In :ConIds])
        allContactsMap.put(con.Id,con);
            
        for(Id conId:ConIds){
        String InfluencedContactNames = '';
        String ConflictContactNames = '';
        String InfluencedByContactNames = '';  
            if(InfluencingIdInfluencersMap.keyset().contains(conId)){
                for(Id InfluencedConId:InfluencingIdInfluencersMap.get(conId)){
                    if(allContactsMap.get(conId).AccountId == allContactsMap.get(InfluencedConId).AccountId)
                    InfluencedContactNames= allContactsMap.get(InfluencedConId).Name + '; ' +  InfluencedContactNames;
                }
            }
            if(InfluecedIdInfluencedByMap.keyset().contains(conId)){
                for(Id InfluencedByConId:InfluecedIdInfluencedByMap.get(conId)){
                    if(allContactsMap.get(conId).AccountId == allContactsMap.get(InfluencedByConId).AccountId)
                    InfluencedByContactNames= allContactsMap.get(InfluencedByConId).Name + '; ' +  InfluencedByContactNames;
                }
            }
            if(InfluencingIdConflictsMap.keyset().contains(conId)){
                for(Id ConflictConId:InfluencingIdConflictsMap.get(conId)){
                    if(allContactsMap.get(conId).AccountId == allContactsMap.get(ConflictConId).AccountId)
                    ConflictContactNames= allContactsMap.get(ConflictConId).Name + '; ' +  ConflictContactNames;
                }
            }
            Contact contt = new Contact();
            contt.Altify_Influencing_Contacts__c=InfluencedContactNames;
            contt.Altify_Influenced_by_Contacts__c=InfluencedByContactNames;
            contt.Altify_Conflict_Contacts__c=ConflictContactNames;
            contt.Id=conId;
            if(InfluencedContactNames=='')
                contt.Altify_Influencer__c=false;
                else
                contt.Altify_Influencer__c=true;
            if(InfluencedByContactNames=='')
                contt.Altify_Influenced__c=false;
                else
                contt.Altify_Influenced__c=true;
            if(ConflictContactNames=='')
                contt.Altify_Conflict__c=false;
                else
                contt.Altify_Conflict__c=true;
            contactsToUpdate.add(contt);
                
            }
            if(!contactsToUpdate.isEmpty())
        Try{
            update contactsToUpdate;
        }catch(exception e){
        GAM.CreateExceptionRecords('ALTF_ContactInfluenceTriggerHandler', 'Exception in AltifyContactInfluenceUpdates method',e.getMessage());    
        }     
    }
}