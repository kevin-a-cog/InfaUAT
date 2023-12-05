/**
 * @description       : 
 * @author            : SF Developer
 * @group             : 
 * @last modified on  : 09-01-2021
 * @last modified by  : Tejasvi Royal
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-24-2021   SF Developer   Initial Version
**/
public with sharing class panoptaIncidentController {  

    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}

    /*
    Parameters: Case RecordID    
    Return: List of Incident records
    Functionality: To return a list of Incident records
    */
    @AuraEnabled
    public static List<Incident__c> getPanopataIncidents(Id caseId, String sortorder, String searchTerm){
    
        List<Incident__c> lstIncidents = new List<Incident__c>();
        Case c = [Select Id,Support_Account__r.Name,Forecast_Product__c,Environment__c from Case where Id =: caseId];

        if(String.isNotEmpty(c?.Support_Account__r?.Name) && String.isNotEmpty(c?.Forecast_Product__c) && String.isNotEmpty(c?.Environment__c)){
            String supportAccount = c.Support_Account__r.Name;
            String product = c.Forecast_Product__c;
            String environment = c.Environment__c;

            String soqltorun = 'SELECT Id, Metric_Tags__c, Name, Incident_Id__c, Server_ID__c, Incident_Start_Time__c, ' +
                                    'Instance_Name__c, Incident_Summary__c, Status__c, Server_Key__c, Account__r.Name ' +
                                    'FROM Incident__c WHERE Status__c != \'Closed\' AND';

            
            List<Panopta_Org__mdt> panoptalist = new List<Panopta_Org__mdt>();
            panoptalist = [Select Id, Instance_Name__c from Panopta_Org__mdt where Support_Account__c =: supportAccount AND Product__c =: product AND Environment__c =: environment];

            /*List<Panopta_Org__mdt> panoptaOrgs = Panopta_Org__mdt.getAll().values();
            Set<String> instanceNames = new Set<String>();
            
            for(Panopta_Org__mdt panoptaOrg : panoptaOrgs){
                if((panoptaOrg.Support_Account__c == supportAccount) && (panoptaOrg.Product__c == product) && (panoptaOrg.Environment__c == environment) && !instanceNames.contains(panoptaOrg.Instance_Name__c)){
                    instanceNames.add(panoptaOrg.Instance_Name__c);
                    System.debug('instanceName --> '+panoptaOrg.Instance_Name__c);
                }
            }

            System.debug('instanceName size --> '+instanceNames.size());*/

            if(panoptalist.size() >0){
                Integer queryLimit = 200;
                String defaultSortOrder = 'ORDER BY LastModifiedDate DESC';
                Integer count = 1;
                for(Panopta_Org__mdt pom :panoptalist){
                    if(panoptalist.size() == 1){
                        soqltorun += ' Instance_Name__c LIKE \'%'+pom.Instance_Name__c+'%\' ';
                    } else {
                        if(count ==1){
                            soqltorun += ' (Instance_Name__c LIKE \'%'+pom.Instance_Name__c+'%\' ' + ' OR ';
                        } else {
                            if(panoptalist.size() == count)
                                soqltorun += ' Instance_Name__c LIKE \'%'+pom.Instance_Name__c+'%\' )';
                            else    
                                soqltorun += ' Instance_Name__c LIKE \'%'+pom.Instance_Name__c+'%\' OR';
                        }
                        count += 1;
                        
                    }
                }
               /* String soqltorun = 'SELECT Id, Metric_Tags__c, Name, Incident_Id__c, Server_ID__c, Incident_Start_Time__c, ' +
                                    'Instance_Name__c, Incident_Summary__c, Status__c, Server_Key__c, Account__r.Name ' +
                                    'FROM Incident__c WHERE Instance_Name__c LIKE \'%'+instanceName+'%\' ';
                
                /*if(String.isNotEmpty(searchTerm)){
                    searchTerm = String.escapeSingleQuotes(searchTerm);
                    soqltorun = soqltorun + 'AND (Instance_Name__c LIKE \'%'+searchTerm+'%\' OR '+
                                'Incident_Id__c LIKE \'%'+searchTerm+'%\' OR '+
                                'Status__c LIKE \'%'+searchTerm+'%\') ';
                }*/
                if(String.isEmpty(sortorder)) {
                    soqltorun = soqltorun +''+ defaultSortOrder;
                }
                else{
                    soqltorun = soqltorun +'ORDER BY '+ String.escapeSingleQuotes(sortorder);
                }
                soqltorun = soqltorun +' LIMIT :queryLimit';
                System.debug('SOQL --> '+soqltorun);
                lstIncidents = Database.query(soqltorun);
            }
        }

        return lstIncidents;
    }

     /*
    Parameters: Case RecordID    
    Return: List of Incidents attached to the Case.
    Functionality: To return a list of Case Incident records
    */
    @AuraEnabled
    public static List<Case_Incident__c> getCaseIncidents(String caseId, String sortorder) {

        List<Case_Incident__c> caseIncidents =  new List<Case_Incident__c>();
        String defaultSortOrder = 'ORDER BY LastModifiedDate DESC';
        String soqltorun = 'SELECT Id, Case__c, Case__r.CaseNumber, Incident__r.Metric_Tags__c, Incident__r.Incident_Start_Time__c, ' +
                                    'Incident__r.Incident_Id__c, Incident__r.Account__r.Name, Case__r.Forecast_Product__c, Incident__c, ' +
                                    'Incident__r.Name, Name, Incident__r.Instance_Name__c, Incident__r.Incident_Summary__c, ' +
                                    'Incident__r.Status__c, Incident__r.Server_Key__c ' +
                                    'FROM Case_Incident__c '; 

        if(String.isNotBlank(caseId)) {
            soqltorun = soqltorun +''+ 'WHERE Case__c = :caseId ';
            if(String.isEmpty(sortorder)) {
                soqltorun = soqltorun +''+ defaultSortOrder;
            }
            else{
                soqltorun = soqltorun +'ORDER BY '+ String.escapeSingleQuotes(sortorder);
            }
            caseIncidents = Database.query(soqltorun);
        }
        return caseIncidents;
    }


    
    /*
    Parameters: Case RecordID & Incident RecordID  
    Return: SUCCESS (or) ERROR
    Functionality: Attach Incident to Case using object "Case Incident"
    */
    @AuraEnabled
    public static List<Case_Incident__c> attachIncidentToCase(Id caseId, Id incidentId, String userurl){
        List<Case_Incident__c> returnList = new List<Case_Incident__c>();        
        List<Case_Incident__c> caselist = new List<Case_Incident__c>(); 
        try{
            if(String.isNotBlank(caseId) && String.isNotBlank(incidentId)){
                caselist = [Select Id from Case_Incident__c where Incident__c =: incidentId AND Case__c =: caseId];
            }

            Incident__c incident = [Select Id, Incident_Id__c from Incident__c where Id = :incidentId];
            Case_Incident__c caseIncident = new Case_Incident__c(Case__c = caseId, Incident__c = incidentId);                       

            if(caselist != null && caselist.size() <= 0){                

                Case c1 = [Select Id,CaseNumber from Case where Id = :caseIncident.Case__c];
                String message = 'Case #' + c1.CaseNumber + ' is associated to Incident';   
                String responsevalue = ' ';
                if(!test.isRunningTest()){
                	responsevalue = GetInfoPanoptaAPI.postOutageLog(message, incident.Incident_Id__c,userurl);
            	}
                if(responsevalue == 'SUCCESS' || test.isRunningTest()){
                    caseIncident.Primary__c = true;
                    insert caseIncident;                       
                    returnList = [Select Id,Case__c,Incident__c,Incident__r.Name,Incident__r.Account__r.Name from Case_Incident__c where Id =: caseIncident.id];
                    system.debug('caselist size'+caselist.size());
                    system.debug(incident);      
                }
                else{
                    throw new CustomException(responsevalue);
                }
                
            } /*else {
                insert caseIncident;
            }*/
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }        

        return returnList;
    }


    /*
    Parameters: Case RecordID & Incident RecordID
    Return: SUCCESS (or) ERROR
    Functionality: Detach Incident from Case, linked through object "Case Incident"
    */
    @AuraEnabled
    public static string detachIncidentFromCase(Id caseId, Id incidentId){
        String returnMessage;
        List<Case_Incident__c> caseIncident = new List<Case_Incident__c>();
         
        if(String.isNotBlank(caseId) && String.isNotBlank(incidentId)){
            caseIncident = [Select Id from Case_Incident__c where Case__c =: caseId and Incident__c =: incidentId];
        }

        if(caseIncident != null && caseIncident.size() > 0){
            try{
                delete caseIncident;
                returnMessage = 'SUCCESS';

            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }

        return returnMessage;
    }
}