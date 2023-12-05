/*
@created by       : MAHESH GANTI
@created on       : 10/30/2020
@Purpose          : Apex Class for all psa Generic Methods
@Testclass        : 
@JIRA             : 
*/
public class psa_UtilsController {

    public static String getFormattedDate(){
        String reqFormat = '';
        Date todayDate = System.today();
        Integer current_month = todayDate.month();
        
        if(current_month == 1 || current_month == 2 || current_month == 3){
            reqFormat='Q1 ';
        }
        if(current_month == 4 || current_month == 5 || current_month == 6){
            reqFormat='Q2 ';
        }
        if(current_month == 7 || current_month == 8 || current_month == 9){
            reqFormat='Q3 ';
        }
        if(current_month == 10 || current_month == 11 || current_month == 12){
            reqFormat='Q4 ';
        }
        reqFormat += todayDate.year();

        return reqFormat;
    }

    public static Map<Id,Contact> getContactMapFromContactIds(Set<Id> conIds){
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id,Name,pse__Salesforce_User__c,pse__Salesforce_User__r.ManagerId
                                                        FROM Contact
                                                        WHERE Id IN :conIds]);
        
        return conMap;
    }

    public static Map<Id,pse__Proj__c> getProjectMapFromProjIds(Set<Id> proIds){
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([SELECT Id,Name,psa_pm_Portfolio_Manager__c,psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c,
                                                                        psa_pm_Portfolio_Manager__r.pse__Salesforce_User__r.ManagerId,pse__Project_Manager__c,
                                                                        pse__Project_Manager__r.pse__Salesforce_User__c,pse__Project_Manager__r.pse__Salesforce_User__r.ManagerId
                                                                FROM pse__Proj__c
                                                                WHERE Id IN :proIds]);
        
        return projMap;
    }

    public static User getUserRec(Id userId){
        return [SELECT Id,Name,ManagerId FROM User WHERE Id = :userId];     
    }
    
}