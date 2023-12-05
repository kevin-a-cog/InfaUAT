/*
@created by       : MAHESH GANTI
@created on       : 10/12/2020
@Purpose          : Permission Control Object Handler Class
@Testclass        : 
@JIRA             : 

******************************************************************************************************
Modified by        JIRA No        Date         Comment                                            Tag
******************************************************************************************************
Vivek W            PSA-1374       16-Feb-21    Updating the Permission Control Creation
                                               to lookup to parent region instead of the region
                                               on PSA Resource                                     T1

Vivek W            PSA-2277       04-Mar-22     Updating the Permission Control creation to 
                                               accommodate the permissions for Skills & Cert       T2

Vivek W            PSA-2337       11-Apr-22    Fixing the bug in PSA-2277                          T3
*/
public class psa_us_PermissionControlHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    /**
* this method is invoked to create Permission control records when a Contact or Assignment is created.
*
* @param Map<Id,Contact> & Map<Id,pse__Assignment__c>(Filtered recs) and String to specify object name
* @return return-void
* @throws exception - NA
*/
    public static void createPermControlRecs(Map<Id, Contact> contactMap,Map<Id, pse__Assignment__c> assignMap, String objectName){
        
        List<pse__Permission_Control__c> permContList = new List<pse__Permission_Control__c>();  
        Map<Id,Set<String>> recIdPermsMap = new Map <Id,Set<String>>();
        Set<String> resRoleSet = new Set<String>();
        Map<Id,String> recIdRoleMap = new Map<Id,String>();
        Map<Id,String> conIdUserRoleMap = new Map<Id,String>();
        Map<Id,pse__Region__c> regionIDMap = new Map<Id,pse__Region__c>();
        
        if(objectName == 'Contact'){
            for(pse__Region__c region : [SELECT Id,pse__Parent_Region__c,pse__Headquarters_Region__c FROM pse__Region__c]){
                regionIDMap.put(region.Id,region);
            }
            for(Contact conRec : contactMap.values()){
                if(conRec.pse__Resource_Role__c <> null || conRec.pse__Resource_Role__c <>''){
                    resRoleSet.add(conRec.pse__Resource_Role__c);
                    recIdRoleMap.put(conRec.Id,conRec.pse__Resource_Role__c);
                }             
            }
        }
        if(objectName == 'Assignment'){
            for(pse__Assignment__c assRec : assignMap.values()){
                resRoleSet.add(assRec.pse__Role__c);
                recIdRoleMap.put(assRec.Id,assRec.pse__Role__c);
            }
        }
        
        if(resRoleSet.size()>0){
            recIdPermsMap = getContPermMap(resRoleSet,recIdRoleMap,objectName);
        }
        if(objectName == 'Contact' && recIdRoleMap.size()>0){
            conIdUserRoleMap = getUserRoleForContactRole(recIdRoleMap);
        }
        
        if(recIdPermsMap.size()>0){
            for(Id recId : recIdPermsMap.keyset()){
                pse__Permission_Control__c permConRec = new pse__Permission_Control__c();               
                if(objectName == 'Contact' && contactMap.get(recId).pse__Region__c != null){
                    permConRec.pse__User__c = contactMap.get(recId).pse__Salesforce_User__c;
                    permConRec.psa_us_Contact__c = recId;
                    permConRec.pse__Cascading_Permission__c = true;
                    if(conIdUserRoleMap.size()>0 && conIdUserRoleMap.containsKey(recId)){
                        String userRole = conIdUserRoleMap.get(recId);
                        if(userRole == 'PSA_Operations' || userRole == 'PSA_Sales' || userRole == 'PSA_Resource_Manager' || userRole == 'PSA_Deal_Desk'){
                            //<T1>
                            // permConRec.pse__Cascading_Permission__c = true;
                            if(regionIDMap.get(contactMap.get(recId).pse__Region__c).pse__Headquarters_Region__c != null){
                                permConRec.pse__Region__c = regionIDMap.get(contactMap.get(recId).pse__Region__c).pse__Headquarters_Region__c;
                            }
                            else{
                                permConRec.pse__Region__c = contactMap.get(recId).pse__Region__c; 
                            }
                        }
                        else if(userRole == 'PSA_Project_Manager'){
                            //  permConRec.pse__Cascading_Permission__c = true;
                            if(regionIDMap.get(contactMap.get(recId).pse__Region__c).pse__Parent_Region__c != null){
                                permConRec.pse__Region__c = regionIDMap.get(contactMap.get(recId).pse__Region__c).pse__Parent_Region__c;
                            }
                            else{
                                permConRec.pse__Region__c = contactMap.get(recId).pse__Region__c; 
                            }
                        }
                        else if(userRole == 'PSA_User'){
                            permConRec.pse__Region__c = contactMap.get(recId).pse__Region__c;
                            
                        }
                        //</T1>
                    }
                }
                if(objectName == 'Assignment'){
                    permConRec.pse__User__c = assignMap.get(recId).pse__Resource__r.pse__Salesforce_User__c;
                    permConRec.pse__Project__c = assignMap.get(recId).pse__Project__c;
                    permConRec.psa_us_Schedule__c = assignMap.get(recId).pse__Schedule__c;
                    permConRec.psa_us_Assignment__c = recId;
                    permConRec.pse__Start_Date__c = assignMap.get(recId).pse__Start_Date__c;
                    permConRec.pse__End_Date__c = assignMap.get(recId).pse__End_Date__c;
                }
                Set<String> permSet = recIdPermsMap.get(recId);
                if(permSet.contains('Resource Request Entry')){
                    permConRec.pse__Resource_Request_Entry__c = true;
                }
                if(permSet.contains('Staffing')){
                    permConRec.pse__Staffing__c = true;
                }
                if(permSet.contains('Skills And Certifications Entry')){
                    permConRec.pse__Skills_And_Certifications_Entry__c = true;
                }
                if(permSet.contains('Skills And Certifications View')){
                    permConRec.pse__Skills_And_Certifications_View__c = true;
                }
                if(permSet.contains('Billing')){
                    permConRec.pse__Billing__c = true;
                }
                if(permSet.contains('Forecast Edit')){
                    permConRec.pse__Forecast_Edit__c = true;
                }
                if(permSet.contains('Forecast View')){
                    permConRec.pse__Forecast_View__c = true;
                }
                if(permSet.contains('Project Task Gantt View')){
                    permConRec.pse__View_Task_Manager__c = true;
                }
                if(permSet.contains('Project Task Gantt Edit')){
                    permConRec.pse__Edit_Task_Manager__c = true;
                }
                if(permSet.contains('Timecard Entry')){
                    permConRec.pse__Timecard_Entry__c = true;
                }
                if(permSet.contains('Timecard Ops Edit')){
                    permConRec.pse__Timecard_Ops_Edit__c = true;
                }
                if(permSet.contains('Expense Entry')){
                    permConRec.pse__Expense_Entry__c = true;
                }
                if(permSet.contains('Expense Ops Edit')){
                    permConRec.pse__Expense_Ops_Edit__c = true;
                }
                if(permSet.contains('Invoicing')){
                    permConRec.pse__Invoicing__c = true;
                }
                if(permSet.contains('Project Version Compare')){
                    permConRec.pse__Compare_Project_Version__c = true;
                }
                if(permSet.contains('Project Version Create')){
                    permConRec.pse__Create_Project_Version__c = true;
                }
                if(permSet.contains('Project Version Delete')){
                    permConRec.pse__Delete_Project_Version__c = true;
                }
                permConRec.pse_us_Is_Automated__c = true;
                permContList.add(permConRec);
            }
            if(objectName == 'Contact'){
                permContList.addAll(getSkillPermControl(contactMap));//T2
            }
        }
        if(permContList.size()>0){
            try{
                insert permContList;
            }         
            catch(Exception e){
                GAM.CreateLogs('CLASS: psa_us_PermissionControlHandler | METHOD: createPermControlRecs', permContList , 'permContList- recs Creation');
            }
        }      
    }

    //<T2>
    public static List<pse__Permission_Control__c> getSkillPermControl(Map<Id, Contact> contactMap){
        
        //querying necessary details from contacts
        List<Contact> contList = new List<Contact>([SELECT Id, ReportsTo.pse__Salesforce_User__c,pse__Resource_Role__c FROM Contact WHERE Id IN: contactMap.keySet()]);
        
        //creating a list of permission controls to be returned
        List<pse__Permission_Control__c> lstPermControl = new List<pse__Permission_Control__c>();

        //getting all the managers
        Map<Id, Contact> contactIdMap = new Map<Id, Contact>();
        for(Contact con : contList){
            if(con.pse__Resource_Role__c != 'PS Operations' && con.pse__Resource_Role__c != 'Resource Management'){
                if(con.ReportsToId != null){
                    contactIdMap.put(con.Id,con);
                }
            }
        }

        for(Contact con : contactIdMap.values()){
            pse__Permission_Control__c pc = new pse__Permission_Control__c();
            pc.pse__User__c = con.ReportsTo.pse__Salesforce_User__c;
            pc.pse__Resource__c = con.Id;
            pc.pse__Cascading_Permission__c = true;
            pc.pse__Skills_And_Certifications_Entry__c = true;
            pc.pse__Skills_And_Certifications_View__c = true;
            pc.psa_Automated_for_Skills__c = true;
            lstPermControl.add(pc);
        }

        //getting all the reporting employees (reports)
        Map<Id,List<Contact>> reportsIdMap = new Map<Id,List<Contact>>();
        for(Contact con : [SELECT Id,ReportsTo.pse__Salesforce_User__c FROM Contact WHERE ReportsToId IN: contactMap.keySet() AND pse__Resource_Role__c != 'PS Operations' AND pse__Resource_Role__c != 'Resource Management']){
            if(reportsIdMap.containsKey(con.ReportsTo.pse__Salesforce_User__c)){
                reportsIdMap.get(con.ReportsTo.pse__Salesforce_User__c).add(con);
            }
            else{
                reportsIdMap.put(con.ReportsTo.pse__Salesforce_User__c,new List<Contact>{con});
            }
        }

        //looping on all the reports and adding Permission Control Records for each report
        for(Id i : reportsIdMap.keySet()){
            for(Contact c : reportsIdMap.get(i)){
                pse__Permission_Control__c pc = new pse__Permission_Control__c();
                pc.pse__User__c = i;
                pc.pse__Resource__c = c.Id;
                pc.pse__Cascading_Permission__c = true;
                pc.pse__Skills_And_Certifications_Entry__c = true;
                pc.pse__Skills_And_Certifications_View__c = true;
                pc.psa_Automated_for_Skills__c = true;
                lstPermControl.add(pc);
            }
        }

        return lstPermControl;
    }

    public static void updatePermControlRecsForSkill(Map<Id,Contact> conMap, Map<Id, Contact> oldMap){
        
        List<Id> lstManagers = new List<Id>();
        List<Id> lstManagerUserIDs = new List<Id>();
        Map<Id,Id> mapContactToNewManagerId = new Map<Id,Id>();
        List<pse__Permission_Control__c> lstPCUpdate = new List<pse__Permission_Control__c>();

        //querying necessary details from contacts
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, ReportsTo.pse__Salesforce_User__c FROM Contact WHERE Id IN: conMap.keySet()]);

        for(Contact c : oldMap.values()){
            lstManagers.add(c.ReportsToId);//Old ReportsToId
            if(contactMap.get(c.Id) != null){
                if(contactMap.get(c.Id).ReportsToId != null){
                    mapContactToNewManagerId.put(c.Id,contactMap.get(c.Id).ReportsTo.pse__Salesforce_User__c);
                }
            }
        }

        for(Contact con : [SELECT Id, pse__Salesforce_User__c FROM Contact WHERE Id IN: lstManagers]){
            lstManagerUserIDs.add(con.pse__Salesforce_User__c); //User of the Old ReportsTo, to query the Permission Control
        }

        List<pse__Permission_Control__c> permContList = new List<pse__Permission_Control__c>([SELECT Id,pse__User__c,pse__Resource__c FROM pse__Permission_Control__c WHERE pse__User__c IN: lstManagerUserIDs /* <T3> */ AND pse__Resource__c IN: conMap.keySet() /* </T3> */ AND psa_Automated_for_Skills__c = true]);

        for(pse__Permission_Control__c pc : permContList){
            if(mapContactToNewManagerId.get(pc.pse__Resource__c) != null){    //<T3>
                pc.pse__User__c = mapContactToNewManagerId.get(pc.pse__Resource__c);
                lstPCUpdate.add(pc);
            }
        }

        if(lstPCUpdate.size() > 0){
            try{
                update lstPCUpdate;
            }
            catch(Exception e){
                System.debug('Error in updating the Permission Control : ' + e.getMessage());
            }
        }
    }
    //</T2>
    
    /**
* this method is invoked from After Contacts/Schedule/Assignment update to update Permission control.

* @param Map<Id,Contact> & Map<Id,pse__Assignment__c>,Map<Id,pse__schedule__c>(Filtered recs) and String to specify object name
* @return return-void
* @throws exception - NA
*/
    public static void updatePermControlRecs(Map<Id,Contact> contactMap,Map<Id,pse__Assignment__c> assignMap,Map<Id,pse__Schedule__c> scheduleMap,string objName){
        
        List<pse__Permission_Control__c> permContToUpdate = new List<pse__Permission_Control__c>();
        List<pse__Permission_Control__c> permContToProcess = new List<pse__Permission_Control__c>();
        //<T1>
        Map<Id,String> conIdUserRoleMap = new Map<Id,String>();
        Map<Id,String> recIdRoleMap = new Map<Id,String>();
        Map<Id,pse__Region__c> regionIDMap = new Map<Id,pse__Region__c>();
        
        if(objName == 'Contact'){
            for(pse__Region__c region : [SELECT Id,pse__Parent_Region__c,pse__Headquarters_Region__c FROM pse__Region__c]){
                regionIDMap.put(region.Id,region);
            }
            for(Contact conRec : contactMap.values()){
                if(conRec.pse__Resource_Role__c <> null || conRec.pse__Resource_Role__c <> ''){
                    recIdRoleMap.put(conRec.Id,conRec.pse__Resource_Role__c);
                }             
            }
        }
        
        if(objName == 'Contact' && recIdRoleMap.size()>0){
            conIdUserRoleMap = getUserRoleForContactRole(recIdRoleMap);
        }
        //</T1>
        
        if(objName == 'Contact'){
            permContToProcess = [SELECT Id,pse_us_Is_Automated__c,Name,pse__Region__c,psa_us_Contact__c,psa_us_Schedule__c
                                 FROM pse__Permission_Control__c WHERE psa_us_Contact__c IN : contactMap.keyset()];
        }
        /**
if(objName == 'Assignment'){
permContToProcess = [SELECT Id,pse_us_Is_Automated__c,Name,pse__Region__c,pse__Project__c,psa_us_Schedule__c,psa_us_Assignment__c
FROM pse__Permission_Control__c WHERE psa_us_Assignment__c IN : assignMap.keyset()];
}
*/
        
        if(objName == 'Schedule'){
            permContToProcess = [SELECT Id,pse_us_Is_Automated__c,Name,pse__Project__c,psa_us_Schedule__c,pse__Start_Date__c,pse__End_Date__c
                                 FROM pse__Permission_Control__c WHERE psa_us_Schedule__c IN : scheduleMap.keyset()];
        }
        
        if(permContToProcess.size()>0){
            for(pse__Permission_Control__c permConRec : permContToProcess){
                if(objName == 'Contact'){
                    for(Id conRecId : contactMap.keyset()){
                        if(permConRec.psa_us_Contact__c == conRecId){
                            //<T1> permConRec.pse__Region__c = contactMap.get(conRecId).pse__Region__c;
                            if(conIdUserRoleMap.size()>0 && conIdUserRoleMap.containsKey(conRecId)){
                                String userRole = conIdUserRoleMap.get(conRecId);
                                if(userRole == 'PSA_Operations' || userRole == 'PSA_Sales' || userRole == 'PSA_Resource_Manager' || userRole == 'PSA_Deal_Desk'){
                                    System.debug('In Category 1');
                                    permConRec.pse__Cascading_Permission__c = true;
                                    if(regionIDMap.get(contactMap.get(conRecId).pse__Region__c).pse__Headquarters_Region__c != null){
                                        System.debug('Can populate Parent Region');
                                        permConRec.pse__Region__c = regionIDMap.get(contactMap.get(conRecId).pse__Region__c).pse__Headquarters_Region__c;
                                    }
                                    else{
                                        permConRec.pse__Region__c = contactMap.get(conRecId).pse__Region__c; 
                                    }
                                }
                                else if(userRole == 'PSA_Project_Manager'){
                                    permConRec.pse__Cascading_Permission__c = true;
                                    if(regionIDMap.get(contactMap.get(conRecId).pse__Region__c).pse__Parent_Region__c != null){
                                        System.debug('Can populate Parent Region');
                                        permConRec.pse__Region__c = regionIDMap.get(contactMap.get(conRecId).pse__Region__c).pse__Parent_Region__c;
                                    }
                                    else{
                                        permConRec.pse__Region__c = contactMap.get(conRecId).pse__Region__c; 
                                    }
                                }
                                else if(userRole == 'PSA_User' || userRole == 'PSA_Subcontractor'){
                                    System.debug('In Category 3');
                                    permConRec.pse__Cascading_Permission__c = true;
                                    permConRec.pse__Region__c = contactMap.get(conRecId).pse__Region__c;
                                }
                                //</T1>
                            }
                            permContToUpdate.add(permConRec);
                        }                          
                    }                   
                }
                
                /**
if(objName == 'Assignment'){
for(Id assignRecId : assignMap.keyset()){
if(permConRec.psa_us_Assignment__c == assignRecId){
permConRec.pse__Project__c = assignMap.get(assignRecId).pse__Project__c;
permConRec.psa_us_Schedule__c = assignMap.get(assignRecId).pse__Schedule__c;
permContToUpdate.add(permConRec);
}                          
}
}
*/
                
                if(objName == 'Schedule'){
                    for(Id schRecId : scheduleMap.keyset()){
                        if(permConRec.psa_us_Schedule__c == schRecId){
                            permConRec.pse__Start_Date__c = scheduleMap.get(schRecId).pse__Start_Date__c;
                            permConRec.pse__End_Date__c = scheduleMap.get(schRecId).pse__End_Date__c;
                            permContToUpdate.add(permConRec);
                        }                          
                    }
                }
            }
        }
        
        if(permContToUpdate.size()>0){
            try{
                update permContToUpdate;
            }catch(Exception e){
                GAM.CreateLogs('CLASS: psa_us_PermissionControlHandler | METHOD: updatePermControlRecs', permContToUpdate , 'permContToUpdate- recs UPDATE');
            }
            
        }  
        
    }
    
    /**
* Method to Delete Permission control recs when a Contact is de-activated or Assignement is deleted.

* @param Set<Id> - source recIds(Contact or Assignement)
* @return return-void
* @throws exception - NA
*/
    public static void deletePermControlRecs(Set<Id> sourceRecIds,string objName){
        List<pse__Permission_Control__c> permContToDelete = new List<pse__Permission_Control__c>();
        
        if(objName == 'Contact'){
            permContToDelete = [Select Id,Name,psa_us_Contact__c FROM pse__Permission_Control__c WHERE psa_us_Contact__c IN :sourceRecIds AND pse_us_Is_Automated__c = true];
        }
        if(objName == 'Assignment'){
            permContToDelete = [Select Id,Name,psa_us_Assignment__c FROM pse__Permission_Control__c WHERE psa_us_Assignment__c IN :sourceRecIds AND pse_us_Is_Automated__c = true ];
        } 
        if(permContToDelete.size()>0){
            try{
                delete permContToDelete;
            }         
            catch(Exception e){
                GAM.CreateLogs('CLASS: psa_us_PermissionControlHandler | METHOD: deletePermControlRecs', permContToDelete , 'permContToDelete- recs DELete');
            }
        }
    }
    
    /**
* Method to fetch all permission sets associated for a particular role on Contact or Assignement.

* @param Set<String> - Roles from Contact or Assignment & Map<Id,Role> which has Record Id and the associated Salesforce role.
* @return return-void
* @throws exception - NA
*/
    public static Map<Id,Set<String>> getContPermMap(Set<String> resRoleSet,Map<Id,String> recIdRoleMap,String objName){
        
        Map<Id,Set<String>> conPermMap = new Map<Id,Set<String>>();
        Map<String,Set<String>> rolePermMap = new Map <String,Set<String>>();
        Map<String,String> userRoleMap = new Map<String,String>();
        Set<String> userRoleSet = new Set<String>();
        
        if(objName == 'Contact'){
            for(User_Role_Mapping__mdt urm : [SELECT Id, Label,DeveloperName, Active__c, User_Role_Grouping__c FROM User_Role_Mapping__mdt 
                                              WHERE Label IN :resRoleSet AND Active__c = true])
            {
                userRoleMap.put(urm.Label,urm.User_Role_Grouping__c);
                userRoleSet.add(urm.User_Role_Grouping__c);
            }
        }
        
        if(objName == 'Assignment'){
            for(psa_us_Project_Role_Mapping__mdt prm : [SELECT Id,Label,DeveloperName, Active__c,Project_Role_Grouping__c FROM psa_us_Project_Role_Mapping__mdt 
                                                        WHERE Label IN :resRoleSet AND Active__c = true])
            {
                userRoleMap.put(prm.Label,prm.Project_Role_Grouping__c);
                userRoleSet.add(prm.Project_Role_Grouping__c);
            }
        }
        if(userRoleSet.size()>0){
            for(Permission_Control_Mapping__mdt pcm : [SELECT Id, DeveloperName, Active__c, Permission_Controls__c,Permission_Controls_For_Project__c,
                                                       Permission_Control_Type__c FROM Permission_Control_Mapping__mdt 
                                                       WHERE DeveloperName IN :userRoleSet AND Active__c = true])
            {
                string allPermissions ;
                if(objName == 'Contact'){
                    allPermissions = pcm.Permission_Controls__c;
                }
                else{
                    allPermissions = pcm.Permission_Controls_For_Project__c;
                }
                List<String> permissionList = allPermissions.split(',');
                Set<String> permissionSet = new Set<String>(permissionList);
                rolePermMap.put(pcm.DeveloperName,permissionSet);               
            }
        }
        
        if(rolePermMap.size()>0){
            for(Id conId : recIdRoleMap.Keyset()){
                string conResRole = recIdRoleMap.get(conId);
                Set<String> permSet = rolePermMap.get(userRoleMap.get(conResRole));
                conPermMap.put(conId,permSet);
            }
        }
        return conPermMap;
    }
    
    public static Map<Id,String> getUserRoleForContactRole(Map<Id,String> conIdRoleMap){
        
        Map<Id,String> conIdUserRoleMap = new Map<Id,String>();
        Map<String,String> conRoleUserRoleMap = new Map<String,String>();
        for(User_Role_Mapping__mdt urm : [SELECT Id, Label,DeveloperName, Active__c, User_Role_Grouping__c FROM User_Role_Mapping__mdt 
                                          WHERE Label IN :conIdRoleMap.values() AND Active__c = true])
        {
            conRoleUserRoleMap.put(urm.Label,urm.User_Role_Grouping__c);
        }
        if(conRoleUserRoleMap.size()>0){
            for(Id conId : conIdRoleMap.keySet()){
                String conRole = conIdRoleMap.get(conId);
                if(conRoleUserRoleMap.containsKey(conRole)){
                    String userRole = conRoleUserRoleMap.get(conRole);
                    conIdUserRoleMap.put(conId,userRole);
                }
            }
        }
        return conIdUserRoleMap;
    }
}