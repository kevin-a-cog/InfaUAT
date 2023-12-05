/*
Trigger:        IPUTypePicklistController
@Author:        Nishant Bansal
@Created Date:  06/12/2023
@Description:   Controller for iPUTypePicklist lwc component SALESRT-15257
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.                      Description                                                 Tag

********************************************************************************************************************************************
*/ 
public class IPUTypePicklistController {
    
    /**
     * @description : fetch picklist values from custom object in lwc
     * 
     * @param : estimatorId - Estimator Id
     * 
     * @return : List of ipuPicklistWrapper
     */
    @AuraEnabled
    public static List <ipuPicklistWrapper> findIPUPicklistValues(String estimatorId) {

        list<String> availableIPUTypes = new list<String>();
        list<ipuPicklistWrapper> ipUPicklistList = new list <ipuPicklistWrapper>();

        Estimation_Summary__c estSummary = [SELECT Id, IPU_Type__c, Form__c, Form__r.Available_IPU_Types__c FROM Estimation_Summary__c WHERE Id =: estimatorId];

        if(estSummary != null && estSummary.Form__c != null && estSummary.Form__r.Available_IPU_Types__c != null) {
            availableIPUTypes = estSummary.Form__r.Available_IPU_Types__c.split(';');
        
            for (String picklist: availableIPUTypes) {
                ipUPicklistList.add(new ipuPicklistWrapper(picklist,picklist, estSummary.IPU_Type__c));
            }
        }
        return ipUPicklistList;
    }

    /**
     * @description : update IPU Type picklist value
     * 
     * @param : estimatorId - Estimator Id
     * @param : selectedValue - selected value in string
     * 
     * @return : void
     */
    @AuraEnabled
    public static void updateIPUType(String estimatorId, String selectedValue) {
        
        Estimation_Summary__c estSummary = new Estimation_Summary__c(Id=estimatorId, 
                                                                IPU_Type__c = selectedValue);
        
        
        update estSummary;
    }

    // wrapper class 
    public class ipuPicklistWrapper {
        @auraEnabled public string label {get;set;}
        @auraEnabled public string value {get;set;}
        @auraEnabled public string selectedValue {get;set;}

        public ipuPicklistWrapper(String label, String value, String selectedValue) {
            this.label = label;
            this.value = value;
            this.selectedValue = selectedValue;
        }
    }
}