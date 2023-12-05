/*
 * Name         :   CSMUpdateChurnForecast
 * Author       :   Karthi G
 * Created Date :   31/03/2023
 * Description  :   Controller class for allowing CSM's to update opportunity fields from churn forecast lwc
 * Test Class   :   CSMChurnForecastControllerTest

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                   Tag
 **********************************************************************************************************
 Karthi G            31/03/2023        AR-3141         Initial version                NA
 */

 //Declared as without sharing to avoid error when CSM updating churn fields.
public without sharing class CSMUpdateChurnForecast {
    public static void saveChurn(List<Opportunity> optyList){
        update optyList;
    }
}