/*
Class:          ALTF_ContactMapDetailsTriggerHandler 
@Author:        Uday Gangula
@Created Date:  20-NOV-2021
@Description:   Apex Class on Altify Contact Influence Object.
*/
/*
Change History
************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                      Tag
************************************************************************************************************************************************************************
Uday Kumar         20-NOV-2021     SALESRT-13318            To stamp the 4 attributes present on Contact Map Details record to Contact record on conditions.      T<01>

*/


public class ALTF_ContactMapDetailsTriggerHandler{

    static Set<Id> ContactIds = new Set<Id>();
    public static globalApexManager GAM = new globalApexManager(); 
    static List<Contact> ContactsToUpdate = new list<Contact>();
    static Set<Id> ConIds = new Set<Id>();
     
    public static void ContactMapDetailsHandling(Map<Id,ALTF__Contact_Map_Details__c> newCmdsMap,Map<Id,ALTF__Contact_Map_Details__c > oldCmdsMap){
        ConIds= ContactIdsCalc(newCmdsMap,oldCmdsMap);
        ContactMapDetails(ConIds);  
    }
    public static Set<Id> ContactIdsCalc(Map<Id,ALTF__Contact_Map_Details__c> newCmdsMap,Map<Id,ALTF__Contact_Map_Details__c > oldCmdsMap){
        if(Trigger.Isupdate){
            for(ALTF__Contact_Map_Details__c cmdNew:newCmdsMap.values()){
                if(cmdNew.ALTF__Account__c!=null && cmdNew.ALTF__Contact__c!=null &&  (cmdNew.ALTF__Coverage__c !=oldCmdsMap.get(cmdNew.Id).ALTF__Coverage__c || cmdNew.ALTF__Decision_Orientation__c!=oldCmdsMap.get(cmdNew.Id).ALTF__Decision_Orientation__c || cmdNew.ALTF__Political__c !=oldCmdsMap.get(cmdNew.Id).ALTF__Political__c || cmdNew.ALTF__Status__c !=oldCmdsMap.get(cmdNew.Id).ALTF__Status__c))
                ContactIds.add(cmdNew.ALTF__Contact__c);
            }
        }
        if(Trigger.IsDelete)
        for(ALTF__Contact_Map_Details__c cmdOld:oldCmdsMap.values()){
            if(cmdOld.ALTF__Account__c!=null && cmdOld.ALTF__Contact__c!=null)
            ContactIds.add(cmdOld.ALTF__Contact__c);
        }   
        return ContactIds;
    }
     
    @future
    Public static void ContactMapDetails(Set<Id> ContIds){
        for(Contact Con:[Select Id,Altify_Coverage__c,Altify_Decision_Orientation__c,Altify_Political_Status__c,Altify_Support__c,AccountId, (Select Id,ALTF__Coverage__c,ALTF__Decision_Orientation__c,ALTF__Political__c,ALTF__Status__c,ALTF__Account__c from ALTF__Altify_Contact_Details__r) from Contact where Id IN :ContIds]){
            Boolean iscmdExist = false;
            
            for(ALTF__Contact_Map_Details__c cms:con.ALTF__Altify_Contact_Details__r){
                if(con.AccountId == cms.ALTF__Account__c){
                    iscmdExist = true;
                    Contact Cont = new Contact();
                    Cont.Id=Con.Id;
                    if(cms.ALTF__Coverage__c != null || cms.ALTF__Coverage__c != '')
                    Cont.Altify_Coverage__c=cms.ALTF__Coverage__c;
                    if(cms.ALTF__Decision_Orientation__c !=null || cms.ALTF__Decision_Orientation__c !='')
                    Cont.Altify_Decision_Orientation__c=cms.ALTF__Decision_Orientation__c;
                    if(cms.ALTF__Political__c!=null || cms.ALTF__Political__c!='')
                    Cont.Altify_Political_Status__c=cms.ALTF__Political__c;
                    if(cms.ALTF__Status__c!=null || cms.ALTF__Status__c!='')
                    Cont.Altify_Support__c=cms.ALTF__Status__c;
                  
                    ContactsToUpdate.add(Cont);
                    break;
                }
            }
            
           if(iscmdExist == false || Con.ALTF__Altify_Contact_Details__r.isempty()){
                Contact Cont = new Contact();
                Cont.Id=Con.Id;
                Cont.Altify_Coverage__c='';
                Cont.Altify_Decision_Orientation__c='';
                Cont.Altify_Political_Status__c='';
                Cont.Altify_Support__c='';
                ContactsToUpdate.add(Cont);
            }
        }
       
        Try{
            if(!ContactsToUpdate.isempty())
            Update ContactsToUpdate;
        }
        catch(exception e){
            GAM.CreateExceptionRecords('ALTF_ContactMapDetailsTriggerHandler', 'Exception in ContactMapDetails method',e.getMessage());
        }   
    }  
}