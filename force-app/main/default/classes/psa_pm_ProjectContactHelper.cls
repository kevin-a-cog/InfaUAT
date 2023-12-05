public class psa_pm_ProjectContactHelper {
    
    public void checkPrimaryContactOnBeforeInsert(list<psa_pm_Project_Contact__c> triggerNew){
        System.debug('@Developer -->checkPrimaryContactOnBeforeInsert:' );
        set<String>setProjectId = new set<String>();
        for(psa_pm_Project_Contact__c proCon :triggerNew){
            if(proCon.psa_pm_Primary_Contact__c && !setProjectId.contains(procon.psa_pm_Project__c)){
                setProjectId.add(procon.psa_pm_Project__c); // master detail relationship no check for null is needed
            }
            else if(proCon.psa_pm_Primary_Contact__c && setProjectId.contains(procon.psa_pm_Project__c)){
                proCon.psa_pm_Primary_Contact__c = false; // in memory flag uncheck
            }
        }
        System.debug('@Developer --> setProjectId :' + setProjectId);
        list<psa_pm_Project_Contact__c> proConListToUpdate = new list<psa_pm_Project_Contact__c>();
        for(pse__Proj__c  proj : [Select Id,
                                  (Select Id,psa_pm_Project__c
                                   From Project_Contacts__r
                                   Where psa_pm_Primary_Contact__c = true
                                  )
                                  From pse__Proj__c  
                                  Where Id In :setProjectId])
        {
            for(psa_pm_Project_Contact__c proCon : proj.Project_Contacts__r){
                proCon.psa_pm_Primary_Contact__c = false;
                proConListToUpdate.add(proCon);    
            }
        }
        System.debug('@Developer --> proConListToUpdate :' + proConListToUpdate);
        
        if(proConListToUpdate.size() > 0){
            update proConListToUpdate;
        }
    }
    
    public void checkPrimaryContactOnBeforeUpdate(list<psa_pm_Project_Contact__c> triggerNew,Map<Id, psa_pm_Project_Contact__c> oldMap){
        System.debug('@Developer -->checkPrimaryContactOnBeforeUpdate:' );
        set<String>setProjectId = new set<String>();
        
        for(psa_pm_Project_Contact__c proCon :triggerNew){
            if(procon.psa_pm_Primary_Contact__c != oldMap.get(proCon.Id).psa_pm_Primary_Contact__c){
                if(proCon.psa_pm_Primary_Contact__c && !setProjectId.contains(procon.psa_pm_Project__c)){
                    setProjectId.add(procon.psa_pm_Project__c); // master detail relationship no check for null is needed
                }
                else if(proCon.psa_pm_Primary_Contact__c && setProjectId.contains(procon.psa_pm_Project__c)){
                    proCon.psa_pm_Primary_Contact__c = false; // in memory flag uncheck
                }
            }
        }
        System.debug('@Developer --> setProjectId :' + setProjectId);
        list<psa_pm_Project_Contact__c> proConListToUpdate = new list<psa_pm_Project_Contact__c>();
        for(pse__Proj__c  proj : [Select Id,
                                  (Select Id,psa_pm_Project__c
                                   From Project_Contacts__r
                                   Where psa_pm_Primary_Contact__c = true
                                   And Id Not IN : triggerNew
                                  )
                                  From pse__Proj__c  
                                  Where Id In :setProjectId])
        {
            for(psa_pm_Project_Contact__c proCon : proj.Project_Contacts__r){
                proCon.psa_pm_Primary_Contact__c = false;
                proConListToUpdate.add(proCon);    
            }
        }
        System.debug('@Developer --> proConListToUpdate :' + proConListToUpdate);
        
        if(proConListToUpdate.size() > 0){
            update proConListToUpdate;
        }
    }
}