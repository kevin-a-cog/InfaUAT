/*
@created by       : MAHESH GANTI
@created on       : 10/12/2020
@Purpose          : Contact Trigger Helper
@Testclass        : 
@JIRA             : 


Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
Vivek W         22-Oct-2020     Project Rhapsody    Creation of Permission Control on new Region add      PSA-73         T01
*/
public class ContactTriggerHelper {
    
    /**
    * this method is invoked from After insert event of Contacts
    *
    * @param lstNew - list of new contacts, Map<Id,Contact>
    * @return return-void
    * @throws exception - NA
    */
    public static void handlePSEAfterContactInsertActions(List<Contact> newContList, Map<Id, Contact> newConMap){
        
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        for(Contact conRec : newContList){
            if(conRec.pse__Region__c <> null && (conRec.pse__Resource_Role__c <> null || conRec.pse__Resource_Role__c <>'') && (conRec.pse__Is_Resource__c == true)){               
                conMap.put(conRec.Id,conRec);
            }
        }
        system.debug('**CTH-conMap**________'+conMap);
        system.debug('**CTH-conMap**________'+conMap.size());
        if(conMap.size()>0){
            psa_us_PermissionControlHandler.createPermControlRecs(conMap,null,'Contact');
        }
    }

    /**
    * this method is invoked from After Update event of Contacts
    *
    * @param lstNew - list of new contacts,New Map<Id,Contact> and Old Map<Id,Contact>
    * @return return-void
    * @throws exception - NA
    */
    
    public static void handlePSEAfterContactUpdateActions(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        
        Map<Id,Contact> conMapToProcess = new Map<Id,Contact>();
        Map<Id,Contact> conMapToRecreate = new Map<Id,Contact>();
        Set<Id> contactIdSet = new Set<Id>();
        
        for(Contact oldConRec : oldMap.values()){
            system.debug('**CTH-oldConRec**________'+oldConRec);
            for(Contact newConRec : newMap.values()){
                system.debug('**CTH-newConRec**________'+newConRec);
                if((oldConRec.Id == newConRec.Id) && (oldConRec.pse__Region__c <> newConRec.pse__Region__c) && (newConRec.pse__Region__c <> null) && (newConRec.pse__Is_Resource__c == true)){
                    //<T01> start
                    if(oldConRec.pse__Region__c == null){
                        conMapToRecreate.put(newConRec.Id,newConRec);
                    }
                    else {
                        conMapToProcess.put(newConRec.Id,newConRec);
                    }
                    //<T01> end
                }
                if((oldConRec.Id == newConRec.Id) && ((oldConRec.pse__Region__c <> newConRec.pse__Region__c) && (newConRec.pse__Region__c == null)) && (newConRec.pse__Is_Resource__c == true)){
                    contactIdSet.add(newConRec.Id);
                }
                          
                if((oldConRec.Id == newConRec.Id) && ((oldConRec.pse__Resource_Role__c <> newConRec.pse__Resource_Role__c) &&  (newConRec.pse__Region__c <> null) && (newConRec.pse__Resource_Role__c <> null || newConRec.pse__Resource_Role__c <> '')) && (newConRec.pse__Is_Resource__c == true)){
                    contactIdSet.add(newConRec.Id);
                    conMapToRecreate.put(newConRec.Id,newConRec);
                }
                if((oldConRec.Id == newConRec.Id) && ((oldConRec.pse__Is_Resource_Active__c <> newConRec.pse__Is_Resource_Active__c) && (newConRec.pse__Is_Resource_Active__c == false)) && (newConRec.pse__Is_Resource__c == true)){
                    contactIdSet.add(newConRec.Id);
                }
            }
        }
        system.debug('**CTH-contactIdSet**________'+contactIdSet);
        system.debug('**CTH-conMapToRecreate**________'+conMapToRecreate);
        system.debug('**CTH-conMapToProcess**________'+conMapToProcess);

        if(conMapToProcess.size()>0){
            psa_us_PermissionControlHandler.updatePermControlRecs(conMapToProcess,null,null,'Contact');
        }
        if(contactIdSet.size()>0){
            psa_us_PermissionControlHandler.deletePermControlRecs(contactIdSet,'Contact');
        }
        if(conMapToRecreate.size()>0){
            psa_us_PermissionControlHandler.createPermControlRecs(conMapToRecreate,null,'Contact');
        }
    }

}