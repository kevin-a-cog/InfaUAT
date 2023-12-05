/*
@created by       : Wasim Akram
@created on       : 02-Nov-2022
@Purpose          : Controller class for the LWC Component psaCreateProjectLocation

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public with sharing class psaCreateProjectLocationController {
    public static globalApexManager GAM = new globalApexManager();
     /**
    * Method invoked to create the Project Location record
    * @param projId,isPrimary,isHomeLocation,psaMsaCode,state,country,city
    * @return return- String
    * @throws exception - NA
    */
    @AuraEnabled
    public static string createProjLocation(Id projId,Boolean isPrimary,Boolean isHomeLocation,Id psaMsaCode,
                                            String state,String country,String city){
        try {
            String projName;            
            pse__Project_Location__c projLoc = new pse__Project_Location__c(pse__Project__c = projId,
                Home_Location__c = isHomeLocation, psa_pm_MSA_Code_Mapping__c = psaMsaCode, PSA_PM_Work_State__c = state,
                PSA_Work_Country__c = country, psa_PM_Work_City__c = city, psa_pm_Primary__c = isPrimary);
            insert projLoc;
            return projLoc.Id;
        } 
        catch (Exception e) {GAM.CreateExceptionRecords('psaCreateProjectLocationController.createProjLocation() -> ' + e.getCause(),e.getmessage(), projId); throw new AuraHandledException(e.getMessage());}
    }
}