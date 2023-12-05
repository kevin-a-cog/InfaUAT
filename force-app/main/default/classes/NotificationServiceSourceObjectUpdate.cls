/*
        Class:          NotificationServiceSourceObjectUpdate
        @Author:        Nishant Bansal
        @Created Date:  March 03 20213
        @Description:   To update the Source Object
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy           Date          JIRA No.                Description                                                 Tag
	Nishant Bansal		04/25/2023     SALESRT-13388		Updating the boolean to false
    ********************************************************************************************************************************************
*/
public class NotificationServiceSourceObjectUpdate {

    //<SALESRT-14945> Starts here
    /**
     * @description : Added the method to update the Sobject
     * 
     * @param : objectAPIName - Object Name
     * @param : record - Sobject
     * 
     * @return : void
     */
    public static void updateOppTriggerToFalse(String objectAPIName, Sobject record) {
        
        if(objectAPIName == 'Opportunity' && Boolean.valueOf(record.get('Trigger_IPU_Notification__c'))) {   
            Opportunity opp = new Opportunity(Id = String.valueOf(record.get('Id')), Trigger_IPU_Notification__c = false);
            update opp;
        }
        
    }
    
    //<SALESRT-13388> Starts here
    /**
     * @description : Added the method to update the Sobject
     * 
     * @param : objectAPIName - Object Name
     * @param : record - Sobject
     * 
     * @return : void
     */
    public static void updateContractTriggerToFalse(String objectAPIName, Sobject record) {
        
        if(objectAPIName == 'Contract' && Boolean.valueOf(record.get('Amendment_Contracted_Notification__c'))) {   
            Contract contract = new Contract(Id = String.valueOf(record.get('Id')), Amendment_Contracted_Notification__c = false);
            update contract;
        }
        
    }
    
}