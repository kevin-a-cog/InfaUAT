/**
 * @description       : 
 * @author            : SF Developer
 * @group             : 
 * @last modified on  : 01-29-2021
 * @last modified by  : SF Developer
 * Modifications Log 
 * Ver   Date         Author         Modification               JIRA
 * 1.0   01-24-2021   SF Developer   Initial Version            NA
 * 2.0   08-25-2022   Vignesh D      Removed unused methods     I2RT-6954
**/
public with sharing class reproEnvironmentController {
       
    /*
    Parameters: Case RecordID    
    Return: List of Repro Environment records
    Functionality: To return a list of Repro Environment records
    */
    @AuraEnabled
    public static List<Repro_Environment__c> getReproEnvironments(Integer lmt, String caseId){
        List<Repro_Environment__c> reproEnvironments = new List<Repro_Environment__c>();
        List<Repro_Environment__c> reproEnvironmentsAcc = new List<Repro_Environment__c>();
        Set<Repro_Environment__c> reproEnvironmentsFinal = new Set<Repro_Environment__c>();
        Map<Id, Repro_Environment__c> objMap1 = new Map<Id, Repro_Environment__c>();
        List<Repro_Environment__c> reproEnvironmentsOrigin = new List<Repro_Environment__c>();

        Case c = [Select Id,Forecast_Product__c,Support_account__c from Case where Id = :caseId];
        if(lmt > 0){
            reproEnvironments = [Select Id,Name,Name__c,iServerMetaDataKey__c,ContainerId__c,RecordType.DeveloperName,Region__c,Case__r.OwnerId,Case__c,Case__r.Owner.Name,case__r.Support_account__r.name,Account__r.Name,OwnerId,Owner.Name from Repro_Environment__c where Product__c = :c.Forecast_Product__c limit :lmt];
           reproEnvironmentsAcc = [Select Id,Name,Name__c,iServerMetaDataKey__c,ContainerId__c,RecordType.DeveloperName,Region__c,Case__r.OwnerId,Case__c,Case__r.Owner.Name,case__r.Support_account__r.name,Account__r.Name,OwnerId,Owner.Name from Repro_Environment__c where case__r.Support_account__c = :c.Support_account__c 
                                        and Product__c = :c.Forecast_Product__c limit :lmt];
                                        System.debug('sasa2'+reproEnvironmentsAcc);
                                        if(!reproEnvironmentsAcc.isEmpty()){
                                            reproEnvironmentsFinal.addall(reproEnvironmentsAcc);
                                            reproEnvironmentsFinal.addall(reproEnvironments);
                                            List<Repro_Environment__c> lstRepro=new List<Repro_Environment__c>(reproEnvironmentsFinal);
                                           // lstRepro.sort();
                                            return lstRepro;
                                        }
          
        }
        reproEnvironments.sort();
        return reproEnvironments;
    }

    
     /*
    Parameters: Case RecordID    
    Return: List of Repro Environments attached to the Case.
    Functionality: To return a list of Case Repro Environment records
    */
    @AuraEnabled
    public static List<Case_Repro_Environment__c> getCaseReproEnvironments(String caseId){
        List<Case_Repro_Environment__c> caseReproEnvironments =  new List<Case_Repro_Environment__c>();
        
        if(String.isNotBlank(caseId)){
            caseReproEnvironments = [Select Id,Repro_Environment__r.Region__c,Case__c,Case__r.Owner.Name,Case__r.Support_Account__r.Name,Case__r.Forecast_Product__c,Repro_Environment__c,Repro_Environment__r.Name__c,Repro_Environment__r.RecordType.DeveloperName,Approval_Status__c,OwnerId,Repro_Environment__r.OwnerId,Repro_Environment__r.Owner.Name from Case_Repro_Environment__c where Case__c =: caseId order by CreatedDate ASC];
        }

        return caseReproEnvironments;
    }


    
    /*
    Parameters: Case RecordID & Repro Environment RecordID  
    Return: SUCCESS (or) ERROR
    Functionality: Attach Repro Environment to Case using object "Case Repro Environment"
    */
    @AuraEnabled
    public static List<Case_Repro_Environment__c> attachReproEnvironmentToCase(String caseId, String reproEnvironmentId, String caseOwnerId){
        //String returnMessage;
        List<Case_Repro_Environment__c> caseReproEnvironment = new List<Case_Repro_Environment__c>();
        List<Case_Repro_Environment__c> returnList = new List<Case_Repro_Environment__c>();
         
        if(String.isNotBlank(caseId) && String.isNotBlank(reproEnvironmentId)){
            caseReproEnvironment = [Select Id from Case_Repro_Environment__c where Case__c =: caseId and Repro_Environment__c =: reproEnvironmentId];
        }
        Repro_Environment__c re = [Select Id,Case__r.OwnerId,OwnerId from Repro_Environment__c where Id = :reproEnvironmentId];

        if(caseReproEnvironment != null && caseReproEnvironment.size() <= 0){
            Case_Repro_Environment__c cre = new Case_Repro_Environment__c(Case__c = caseId, Repro_Environment__c = reproEnvironmentId);
            cre.Approver__c = re.OwnerId;
            cre.Name = 'Case Repro Environment';
            if((caseOwnerId == re.OwnerId) || (UserInfo.getUserId() == re.OwnerId)){
                cre.Approval_Status__c = 'Approved';
            }
            try{
                insert cre;
                if((caseOwnerId != re.OwnerId) && (UserInfo.getUserId() != re.OwnerId)){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(cre.id);
                    Approval.ProcessResult result = Approval.process(req1);
                    System.assert(result.isSuccess());
                }
                returnList = [Select Id,Case__c,Repro_Environment__c,Repro_Environment__r.Name,Repro_Environment__r.Account__r.Name,Approval_Status__c from Case_Repro_Environment__c where Id =: cre.id];

            }
            catch(Exception e){
                //returnMessage = 'Error: '+e.getMessage();
                throw new AuraHandledException(e.getMessage());
            }
        }

        return returnList;
    }


    /*
    Parameters: Case RecordID & Repro Environment RecordID
    Return: SUCCESS (or) ERROR
    Functionality: Detach Repro Environment from Case, linked through object "Case Repro Environment"
    */
    @AuraEnabled
    public static string detachReproEnvironmentFromCase(String caseId, String reproEnvironmentId){
        String returnMessage;
        List<Case_Repro_Environment__c> caseReproEnvironment = new List<Case_Repro_Environment__c>();
         
        if(String.isNotBlank(caseId) && String.isNotBlank(reproEnvironmentId)){
            caseReproEnvironment = [Select Id from Case_Repro_Environment__c where Case__c =: caseId and Repro_Environment__c =: reproEnvironmentId];
        }

        if(caseReproEnvironment != null && caseReproEnvironment.size() > 0){
            try{
                delete caseReproEnvironment;
                returnMessage = 'SUCCESS';

            }
            catch(Exception e){
                //returnMessage = 'Error: '+e.getMessage();
                throw new AuraHandledException(e.getMessage());
            }
        }

        return returnMessage;
    }

    /*
    Parameters: caseId, searchTerm, filters
    Return: List
    Functionality: Global Search on Repro Environments
    */
    @AuraEnabled
    public static List<Repro_Environment__c> searchReproEnvironments(String caseId, String searchTerm, String filters){

        //Escape string arguments
        caseId = (caseId != null) ? String.escapeSingleQuotes(caseId) : caseId;
        searchTerm = String.isNotEmpty(searchTerm) ? String.escapeSingleQuotes(searchTerm) : searchTerm;

        Set<Id> reproEnvironmentIds = new Set<Id>();
        List<Repro_Environment__c> lstReproEnvironments = new List<Repro_Environment__c>();

        if(String.isNotEmpty(searchTerm)){
            if(String.isEmpty(filters)){
                searchTerm+= '*';
                String queryStr = 'FIND :searchTerm IN ALL FIELDS RETURNING Repro_Environment__c(Id) LIMIT 50';
            
                List<Search.SearchResult> reproEnvironmentList = Search.find(queryStr).get('Repro_Environment__c');
                for(Search.SearchResult sr : reproEnvironmentList){
                    Repro_Environment__c re = (Repro_Environment__c) sr.getSObject();
                    reproEnvironmentIds.add(re.Id);
                }

                if(!reproEnvironmentIds.isEmpty()){
                    lstReproEnvironments = [Select Id,Name,Name__c,iServerMetaDataKey__c,ContainerId__c,RecordType.DeveloperName,Region__c,Case__r.OwnerId,
                                            Case__c,Case__r.Owner.Name,case__r.Support_account__r.name,Account__r.Name,OwnerId,Owner.Name from Repro_Environment__c 
                                            Where Id IN :reproEnvironmentIds];
                }
            }
            else{
                String filterConditions = '';
                Map<String, String> searchFiltersMap = getSearchFilters();
                String soqlQueryStr = 'Select Id,Name,Name__c,iServerMetaDataKey__c,ContainerId__c,RecordType.DeveloperName,Region__c,Case__r.OwnerId,'+
                                      'Case__c,Case__r.Owner.Name,case__r.Support_account__r.name,Account__r.Name,OwnerId,Owner.Name from Repro_Environment__c ';

                if(filters.contains(',')){
                    for(String filter : filters.split(',')){
                        if(searchFiltersMap.containsKey(filter)){
                            filterConditions = String.isEmpty(filterConditions) ? 'Where '+ filter +' LIKE \'%'+ searchTerm +'%\' ' : filterConditions +'OR '+ filter +' LIKE \'%'+ searchTerm +'%\' ';
                        }
                    }
                }
                else{
                    filterConditions = searchFiltersMap.containsKey(filters) ? 'Where '+ filters +' LIKE \'%'+ searchTerm +'%\' ' : filterConditions;
                }
                
                soqlQueryStr = soqlQueryStr + filterConditions + 'LIMIT 50';
                System.debug('soqlQueryStr -> '+soqlQueryStr);
                lstReproEnvironments = Database.query(soqlQueryStr);
            }
        }
        else{
            lstReproEnvironments = getReproEnvironments(50, caseId);
        }
        
        return lstReproEnvironments;
    }

    /*
    Parameters: None
    Return: List
    Functionality: Search Filter label and values
    */
    @AuraEnabled
    public static Map<String,String> getSearchFilters(){
        return new  Map<String,String>{
            'Product__c'=>'Product',
            'Version__c'=>'Version',
            'Region__c'=>'Region'   
        };
    }

}