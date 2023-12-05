/*
 * Name         :   OrgServiceTriggerHandler
 * Author       :   Vignesh Divakaran
 * Created Date :   8/29/2022
 * Description  :   This is an handler class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      8/29/2022       I2RT-7004       Initial version.                            N/A
 */

public class OrgServiceTriggerHandler extends TriggerHandler{
    
    private OrgServiceTriggerHelper helper = new OrgServiceTriggerHelper();

    public override void afterInsert() {          
        if(globalApexManager.avoidRecursion('OrgServiceTrigger',  'after', 'insert') ) {
            return;
        }
        helper.rollupExpirationDateToOrg((List<Org_Service__c>) newList);
    }

    public override void afterUpdate() {          
        if(globalApexManager.avoidRecursion('OrgServiceTrigger',  'after', 'update') ) {
            return;
        }
        helper.rollupExpirationDateToOrg((List<Org_Service__c>) newList);
    }

	public override void beforeUpdate() {          
        OrgServiceTriggerHelper.trackingHistory((List<Org_Service__c>) newList, (Map<Id, Org_Service__c>)oldMap);
    }
    String strValue = '';
}