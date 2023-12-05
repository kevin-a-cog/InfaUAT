/***************************************************************************************************************************************************************
 *  @Class Name: psa_pm_ProjectLocationTriggerHelper
 *  @Author: 
 *  @Date: 
 *  @Description: PSA-2391 : Trigger helper Class for Project Location
 ****************************************************************************************************************************************************************
 ChangeHistory
    
ModifiedBy              Date                       Requested By            Description                       Tag   
Wasim Akram             25-Oct-2022                                        PSA-2602 Project Location Update  <T1>
 ***************************************************************************************************************************************************************/

public class psa_pm_ProjectLocationTriggerHelper {
    
    public void runValidationsOnInsertUpdate(List<pse__Project_Location__c> newList, Map<Id,pse__Project_Location__c> newMap){
        List<Id> ListofProjectIds = new List<Id>();
        Set<pse__Proj__c> SetofProjectsToUpdate = new Set<pse__Proj__c>();
        List<pse__Proj__c> ListofProjectsToUpdate = new List<pse__Proj__c>();
        Map<Id,List<pse__Project_Location__c>> MapofProjectsToLocations = new Map<Id,List<pse__Project_Location__c>>(); 
        List<pse__Project_Location__c> PWLsToUpdate = new List<pse__Project_Location__c>();
        List<Id> ErrorLoop = new List<Id>();
        Boolean UpdateBoolean;
        
        for(pse__Project_Location__c pwl : newMap.values()){
            ListofProjectIds.add(pwl.pse__Project__c);
        }
        
        if(ListofProjectIds.size() > 0){
            System.debug('Inside the main loop.');
            Map<Id,pse__Proj__c> MapofProjToUpdate = new Map<Id,pse__Proj__c>([SELECT Id, psa_pm_Primary_Project_Location__c, (SELECT Id, psa_pm_Primary__c FROM pse__Project_Locations__r) FROM pse__Proj__c WHERE Id IN :ListofProjectIds]);
            for(pse__Proj__c proj : MapofProjToUpdate.values()){
                MapofProjectsToLocations.put(proj.Id,proj.pse__Project_Locations__r);
            }
            
            for(pse__Proj__c proj : MapofProjToUpdate.values()){
                Integer newPrimaryCount = 0;
                Integer primaryCount = 0;
                UpdateBoolean = false;
                for(pse__Project_Location__c pwl : MapofProjectsToLocations.get(proj.Id)){
                    if(trigger.newMap.containsKey(pwl.Id)){
                        if(pwl.psa_pm_Primary__c== true){
                            newPrimaryCount += 1; //newPrimaryCount to check if there needs to be an update of 'Primary = false' on a PWL
                            primaryCount += 1; //to check if there is a change in the Primary and if the Project should be updated.
                            proj.psa_pm_Primary_Project_Location__c = pwl.Id;
                        }
                    }
                    else if(pwl.psa_pm_Primary__c == true){
                        primaryCount += 1;
                        pwl.psa_pm_Primary__c = false;
                        PWLsToUpdate.add(pwl);
                    }
                }
                System.debug('newPrimaryCount: ' + newPrimaryCount);
                if(newPrimaryCount > 0){
                    UpdateBoolean = true;
                }
                if(primaryCount == 0){
                    if(!ErrorLoop.contains(proj.Id)){
                        ErrorLoop.add(proj.Id);
                        System.debug('Here in Primary Count = 0; ErrorLoop: ' + ErrorLoop);
                    }
                }
                System.debug('primaryCount: ' + primaryCount);
                if(primaryCount >= 1){    
                    System.debug('First addition to Update Set.');           
                    SetofProjectsToUpdate.add(proj);
                }
            }
            
            for(pse__Project_Location__c pwl : newList){
                System.debug('ErrorLoop: ' + ErrorLoop);
                if(ErrorLoop.contains(pwl.pse__Project__c)){
                    System.debug('Inside actual error branch.');
                    pwl.addError('There are no Primary Work Location(s). Please make sure there is exactly one Primary Work Location on a project.');
                }
            }
            
            ListofProjectsToUpdate.addAll(SetofProjectsToUpdate);
            try{
                Database.SaveResult[] sr = Database.update(ListofProjectsToUpdate,false);
                if(UpdateBoolean == true){
                    Database.SaveResult[] sr1 = Database.update(PWLsToUpdate,false);
                }
            }
            catch(Exception e){
                System.debug('Exception on ProjectWorkLocationTriggerHandler.handleAfterInsertAfterUpdate: ' + e.getMessage());
            }  
        }
    }
    
    public void runValidationsOnDelete(List<pse__Project_Location__c> oldList, Map<Id, pse__Project_Location__c> oldMap){
        
        List<Id> ListofProjectIds = new List<Id>();
        Map<Id,List<pse__Project_Location__c>> MapofProjectsToLocations = new Map<Id,List<pse__Project_Location__c>>();
        List<Id> ErrorLoop = new List<Id>();
        
        for(pse__Project_Location__c pwl : oldMap.values()){
            ListofProjectIds.add(pwl.pse__Project__c);
        }
        
        if(ListofProjectIds.size() > 0){
            System.debug('Inside the main loop.');
            Map<Id,pse__Proj__c> MapofProjToUpdate = new Map<Id,pse__Proj__c>([SELECT Id, psa_pm_Primary_Project_Location__c, (SELECT Id,psa_pm_Primary__c FROM pse__Project_Locations__r) FROM pse__Proj__c WHERE Id IN :ListofProjectIds]);
            for(pse__Proj__c proj : MapofProjToUpdate.values()){
                MapofProjectsToLocations.put(proj.Id,proj.pse__Project_Locations__r);
            }
            
            for(pse__Proj__c proj : MapofProjToUpdate.values()){
                Integer primaryCount = 0;
                for(pse__Project_Location__c pwl : MapofProjectsToLocations.get(proj.Id)){
                    if(pwl.psa_pm_Primary__c == true){
                        primaryCount += 1;
                    }
                }
                System.debug('primaryCount: ' + primaryCount);
                if(primaryCount == 0){
                    if(!ErrorLoop.contains(proj.Id)){
                        ErrorLoop.add(proj.Id);
                        System.debug('Here in Primary Count = 0; ErrorLoop: ' + ErrorLoop);
                    }
                }
            }
            
            for(pse__Project_Location__c pwl : oldList){
                System.debug('ErrorLoop: ' + ErrorLoop);
                if(ErrorLoop.contains(pwl.pse__Project__c)){
                    System.debug('Inside actual error branch.');
                    pwl.addError('There are no Primary Work Location(s). Please make sure there is exactly one Primary Work Location on a project.');
                }
            }
        }
    }
    public void populateMSAFieldValuesOnInsert(List<pse__Project_Location__c> newList){
        
        Set<Id> msaCodeMapIds = new Set<Id>();
        for(pse__Project_Location__c projLoc : newList){
            if(!String.isBlank(projLoc.psa_pm_MSA_Code_Mapping__c)){
                msaCodeMapIds.add(projLoc.psa_pm_MSA_Code_Mapping__c);
            }
        }
        if(!msaCodeMapIds.isEmpty()){
            mappingMSAFields(newList,msaCodeMapIds);
        }
    }
    
    public void populateMSAFieldValuesOnUpdate(Map<Id,pse__Project_Location__c> newMap,Map<Id,pse__Project_Location__c> oldMap){
        
        Set<Id> msaCodeMapIds = new Set<Id>();
        for(pse__Project_Location__c projLoc : newMap.values()){
           pse__Project_Location__c oldProjLocRec =  oldMap.get(projLoc.Id);
            if(!String.isBlank(projLoc.psa_pm_MSA_Code_Mapping__c) && oldProjLocRec.psa_pm_MSA_Code_Mapping__c!=projLoc.psa_pm_MSA_Code_Mapping__c){
                msaCodeMapIds.add(projLoc.psa_pm_MSA_Code_Mapping__c);
            }
        }
        if(!msaCodeMapIds.isEmpty()){
            mappingMSAFields(newMap.values(),msaCodeMapIds);
        }
    }
    
    public void mappingMSAFields(List<pse__Project_Location__c> newList,Set<Id> msaCodeMapIds){
        
        Map<Id,PSA_MSA_Code_Mapping__c> msaCodeMap = new Map<Id,PSA_MSA_Code_Mapping__c>([Select Id,psa_pm_Work_Street__c, psa_pm_City_Name__c, psa_pm_County_Name__c, 
                                                                                              psa_pm_State_Code__c, psa_pm_Work_Country__c, psa_pm_ZIP_Code__c 
                                                                                              from PSA_MSA_Code_Mapping__c where Id IN :msaCodeMapIds]);
            
            
            String hyphen1, hyphen2;
            if(!msaCodeMap.isEmpty() && msaCodeMap !=null){
                for(pse__Project_Location__c projLoc : newList){
                    if(msaCodeMap.containsKey(projLoc.psa_pm_MSA_Code_Mapping__c)){
                        
                        PSA_MSA_Code_Mapping__c msaCodeRec =  msaCodeMap.get(projLoc.psa_pm_MSA_Code_Mapping__c);
                        //<T1>
                        /*
                        projLoc.PSA_Work_Street__c = !String.isBlank(projLoc.PSA_Work_Street__c)?projLoc.PSA_Work_Street__c:msaCodeRec.psa_pm_Work_Street__c;
                        projLoc.psa_PM_Work_City__c = !String.isBlank(projLoc.psa_PM_Work_City__c)?projLoc.psa_PM_Work_City__c:msaCodeRec.psa_pm_City_Name__c;
                        projLoc.PSA_PM_Work_State__c = !String.isBlank(projLoc.PSA_PM_Work_State__c)?projLoc.PSA_PM_Work_State__c:msaCodeRec.psa_pm_State_Code__c;
                        projLoc.PSA_PM_Work_County__c = !String.isBlank(projLoc.PSA_PM_Work_County__c)?projLoc.PSA_PM_Work_County__c:msaCodeRec.psa_pm_County_Name__c;
                        projLoc.PSA_Work_Country__c = !String.isBlank(projLoc.PSA_Work_Country__c)?projLoc.PSA_Work_Country__c:msaCodeRec.psa_pm_Work_Country__c;
                        projLoc.PSA_Work_Zip_Postal_Code__c = !String.isBlank(projLoc.PSA_Work_Zip_Postal_Code__c)?projLoc.PSA_Work_Zip_Postal_Code__c:msaCodeRec.psa_pm_ZIP_Code__c;
                        */
                        projLoc.Home_Location__c = false;
                        projLoc.PSA_Work_Street__c = msaCodeRec.psa_pm_Work_Street__c;
                        projLoc.psa_PM_Work_City__c = !String.isBlank(msaCodeRec.psa_pm_City_Name__c) ? msaCodeRec.psa_pm_City_Name__c : '';
                        projLoc.PSA_PM_Work_State__c = !String.isBlank(msaCodeRec.psa_pm_State_Code__c) ? msaCodeRec.psa_pm_State_Code__c : '';
                        projLoc.PSA_PM_Work_County__c = !String.isBlank(msaCodeRec.psa_pm_County_Name__c) ? msaCodeRec.psa_pm_County_Name__c : '';
                        projLoc.PSA_Work_Country__c = !String.isBlank(msaCodeRec.psa_pm_Work_Country__c) ? msaCodeRec.psa_pm_Work_Country__c : '';
                        projLoc.PSA_Work_Zip_Postal_Code__c = msaCodeRec.psa_pm_ZIP_Code__c;
                        hyphen1 = (!String.isBlank(msaCodeRec.psa_pm_State_Code__c) || !String.isBlank(msaCodeRec.psa_pm_County_Name__c)) && !String.isBlank(msaCodeRec.psa_pm_City_Name__c) ? ' - ':'';
                        hyphen2 = !String.isBlank(msaCodeRec.psa_pm_State_Code__c) && !String.isBlank(msaCodeRec.psa_pm_County_Name__c) ? ' - ':'';
                        
                        projLoc.Name = projLoc.psa_PM_Work_City__c + hyphen1 + projLoc.PSA_PM_Work_State__c + hyphen2 + projLoc.PSA_PM_Work_County__c;
                        //</T1>
                    }
                }
                
            }
        }
    
}