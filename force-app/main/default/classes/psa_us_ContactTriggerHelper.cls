/*
@created by       : MAHESH GANTI
@created on       : 10/12/2020
@Purpose          : Contact Trigger Helper
@Testclass        : 
@JIRA             : 

Change History
******************************************************************************************************************************************************
ModifiedBy          Date            Requested By        Description                                                         Jira No.       Tag
******************************************************************************************************************************************************
Vivek W             22-Oct-2020     Project Rhapsody    Creation of Permission Control on new Region add                    PSA-73         T01
Vivek W             11-Mar-2022     Neha Kumari         Creation of Permission Control for Skills                           PSA-2277       T02
Rohit Niranjanamath 09-Sept-2023    Sept Build '23      Resource Manager field addition to RR and PSA Contact Page layouts  PSA-3079       T03
Wasim               16-Oct-2023     Nov Build '23       Tech Debt- PSA Contact restriction for duplicate record             PSA-3234       T04
*/
public without sharing class psa_us_ContactTriggerHelper {
    /**
     * @description - this method is invoked from After insert event of Contacts
     * @param newContList - list of new contacts
     * @param newConMap - map of new contacts
     * @throws exception - NA
     */
     public static void handlePSEAfterContactInsertActions(List<Contact> newContList, Map<Id, Contact> newConMap){
         
         Map<Id,Contact> conMap = new Map<Id,Contact>();
         for(Contact conRec : newContList){
             if(conRec.pse__Region__c <> null && (conRec.pse__Resource_Role__c <> null || conRec.pse__Resource_Role__c <>'') && 
                (conRec.pse__Is_Resource__c == true) && (conRec.pse__Salesforce_User__c <> null)){               
                 conMap.put(conRec.Id,conRec);
             }
             //<T02>
            if(conRec.ReportsTo <> null && conRec.pse__Is_Resource__c == true){               
                conMap.put(conRec.Id,conRec);
            }
            //</T02>

         }
         if(conMap.size()>0){
             psa_us_PermissionControlHandler.createPermControlRecs(conMap,null,'Contact');
         }
     }
     /**<T04>
     * @description - this method is invoked from Before insert event of Contacts - to avoid creating Duplicate PSA Contacts
     * @param newList - list of new contacts
     * @throws exception - NA
     */
     public static void avoidDuplicatePSContact(List<Contact> newList){
        Set<String> emailList = new Set<String>();
        Id psaAccountId = [SELECT Id FROM Account WHERE Name = 'Informatica LLC PSA' LIMIT 1]?.Id; 
        for(Contact con : newList){
            if(String.isNotBlank(con.Email) && con.AccountId != null && con.AccountId == psaAccountId){
                emailList.add(con.Email);
            }
        }
        if(emailList.size() > 0){
            //Check if the existing Contact has the same Email as the one they are creating under Informatica LLC Account
            AggregateResult[] agrList = [SELECT Email,Count(Id) noOfContacts FROM Contact WHERE Email IN :emailList AND AccountId = :PSAaccountId AND Email != null GROUP BY Email HAVING COUNT(Id) > 0 ];
            for(AggregateResult agr : agrList){
                if((Integer)agr.get('noOfContacts') > 0){
                    newList[0].addError('Contact already exists under the Account Informatica LLC PSA');
                }
            }
        }
     }
     //</T04>
     /**
     * @description - this method is invoked from After Update event of Contacts
     * @param newList - list of new contacts
     * @param newMap - map of new contacts
     * @param oldMap - map of old contacts
     * @throws exception - NA
     */
     
    public static void handlePSEAfterContactUpdateActions(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
         
        Map<Id,Contact> conMapToProcess = new Map<Id,Contact>();
        Map<Id,Contact> conMapToRecreate = new Map<Id,Contact>();
        Map<Id,Contact> conMapToUpdateMgr = new Map<Id,Contact>();//T02
        Set<Id> contactIdSet = new Set<Id>();
         
        for(Contact oldConRec : oldMap.values()){
            for(Contact newConRec : newMap.values()){
                if((oldConRec.Id == newConRec.Id) && (oldConRec.pse__Region__c <> newConRec.pse__Region__c) && (newConRec.pse__Region__c <> null) && 
                    (newConRec.pse__Is_Resource__c == true) && (newConRec.pse__Salesforce_User__c <> null)){
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
                //<T02>
                if((oldConRec.Id == newConRec.Id) && (oldConRec.ReportsToId <> newConRec.ReportsToId) && (newConRec.pse__Is_Resource__c == true)){
                    conMapToUpdateMgr.put(newConRec.Id,newConRec);
                }
                //</T02>
                if((oldConRec.Id == newConRec.Id) && ((oldConRec.pse__Is_Resource_Active__c <> newConRec.pse__Is_Resource_Active__c) && (newConRec.pse__Is_Resource_Active__c == false)) && (newConRec.pse__Is_Resource__c == true)){
                    contactIdSet.add(newConRec.Id);
                }
            }
        }
 
        if(conMapToProcess.size()>0){
            psa_us_PermissionControlHandler.updatePermControlRecs(conMapToProcess,null,null,'Contact');
        }
        if(contactIdSet.size()>0){
            psa_us_PermissionControlHandler.deletePermControlRecs(contactIdSet,'Contact');
        }
        if(conMapToRecreate.size()>0){
            psa_us_PermissionControlHandler.createPermControlRecs(conMapToRecreate,null,'Contact');
        }
        //<T02>
        if(conMapToUpdateMgr.size()>0){
            psa_us_PermissionControlHandler.updatePermControlRecsForSkill(conMapToUpdateMgr,oldMap);
        }
        //</T02>
    }
    //<T03> - Start
    /**
     * @description - this method is invoked from before insert/update event of Contacts
     * @param oldMapCon - map of old contacts
     * @param newConRec - list of new contacts 
     * @throws exception - NA
     */
    public static void updateOnRMOContactfieldOnContact(Map<Id, Contact> oldMapCon, List<Contact> newConRec) {
        Set<Id> regionIds = new Set<Id>();
        // Collect the unique pse__Region__c IDs from the newConRec
        for (Contact conRec : newConRec) {
            if (conRec.pse__Region__c != null && (oldMapCon == null || (oldMapCon != null && oldMapCon.get(conRec.Id).pse__Region__c != conRec.pse__Region__c))) {
                regionIds.add(conRec.pse__Region__c);
            }
        }
        // Query for pse__Region__c records in bulk and update Contact records with psa_RMO_Contact__c from corresponding pse__Region__c records
        if (!regionIds.isEmpty()) {
            Map<Id, pse__Region__c> regionMap = new Map<Id, pse__Region__c>([SELECT Id, psa_RMO_Contact__c FROM pse__Region__c WHERE Id IN :regionIds]);
        
            for (Contact conRec : newConRec) {
                //pse__Region__c regionRec = regionMap.get(conRec.pse__Region__c);
                    conRec.psa_RMO_Contact__c = regionMap.get(conRec.pse__Region__c)?.psa_RMO_Contact__c;
    
            }
        }
    }
    //<T03> - End
 
}