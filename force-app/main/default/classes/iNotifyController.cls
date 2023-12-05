public with sharing class iNotifyController {
    
    @AuraEnabled
    public static List<Alerts_Announcements__c> getskillalerts(String appName, Integer alertOffSetNum,List<Alerts_Announcements__c> alertspassed){
        List<String> pslist = new List<String>();
        List<Alerts_Announcements__c> alerts = new List<Alerts_Announcements__c>();
        String soqltorun = ' ';
        for(ProfileSkillUser ps : [select id, name, profileskill.name,UserId,user.name from ProfileSkillUser where UserId = :UserInfo.getUserId() ]){
            pslist.add(ps.ProfileSkill.Name);            
        }
                
        
        if(pslist.size() > 0){
            soqltorun = 'Select Id,Name,Description__c,RecordType.DeveloperName from Alerts_Announcements__c where    (Application__c INCLUDES (:appName) or Application__c = null) and (Skills__c = null or Skills__c includes (';         
        
            for(String ps: pslist){
                soqltorun = soqltorun +'\'' + ps + '\'' + ','; 
            }
            soqltorun = soqltorun.removeEnd(',') +')' +') ';
        }
        else {
            soqltorun = 'Select Id,Name,Description__c,RecordType.DeveloperName from Alerts_Announcements__c where    (Application__c INCLUDES (:appName) or Application__c = null) and Skills__c = null ';
        }       
        
        date todaydate = Date.Today();
        System.debug('totot'+todaydate);
            if(alertspassed != null && alertspassed.size() > 0){
            soqltorun = soqltorun + ' and Start_Date__c<=TODAY and End_Date__c >= TODAY and Id IN :alertspassed  order by CreatedDate DESC';
        } else{
            soqltorun = soqltorun +  ' and  Start_Date__c<=TODAY and End_Date__c >= TODAY order by CreatedDate DESC LIMIT 30 OFFSET :alertOffSetNum';
        }
       
        system.debug('Soql run'+soqltorun);
        alerts = (List<Alerts_Announcements__c>)Database.query(soqltorun);
        system.debug('Returned alerts'+alerts);    
        return alerts;
    }
    
    @AuraEnabled
    public static List<Alerts_Announcements__c> getAlerts(String appName, Integer alertOffSetNum){
      return   getskillalerts(appName, alertOffSetNum,null);
        
    }

    @AuraEnabled
    public static List<Alerts_Announcements__c> checkAlerts(String appName, List<Alerts_Announcements__c> alerts){
        return   getskillalerts(appName, 0,alerts);
        
       
    }

    @AuraEnabled
    public static List<Inspire_Message__c> getInspireMessages(String appName, Integer inspireOffSetNum){

        List<Inspire_Message__c> inspireMessages = [Select Id,Name,Description__c,Has_Been_Viewed__c from Inspire_Message__c where OwnerId =: UserInfo.getUserId() and Activity_Date__c = TODAY order by Activity_Date__c DESC LIMIT 30 OFFSET :inspireOffSetNum];
        
        return inspireMessages;
    }

    @AuraEnabled
    public static string updateUnreadMessages(List<Inspire_Message__c> inspireMessages){
    List<Inspire_Message__c> toUpdate = new List<Inspire_Message__c>();
    String returnMessage;
       for(Inspire_Message__c im : inspireMessages){
        Inspire_Message__c i = new Inspire_Message__c(Id=im.Id);
        i.Has_Been_Viewed__c = 'Yes';
        toUpdate.add(i);
       }

       if(toUpdate.size() != null && toUpdate.size() > 0){
            try{
                update toUpdate;
                returnMessage = 'SUCCESS';
            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
       }
       
        
        return returnMessage;
    }

    @AuraEnabled
    public static string checkUnSubscribe(String testM){
        Alerts_Announcements__c a = new Alerts_Announcements__c();
        a.Name = 'Push Topic Unsubscribed';
        insert a;
        return 'Success';
    }



    
}