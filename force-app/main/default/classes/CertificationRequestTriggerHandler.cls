/*
 * Name         :   CertificationRequestTriggerHandler
 * Author       :   Vignesh Divakaran
 * Created Date :   5/27/2022
 * Description  :   This is an handler class.

 Change History
 *********************************************************************************************************************
 Modified By            Date            Jira No.        Description                                             Tag
 *********************************************************************************************************************
 Vignesh Divakaran      5/27/2022       I2RT-6149       Initial version.                                        N/A
 Vignesh Divakaran      7/21/2023       I2RT-8640       Commented the code to rollup certification request      T01
                                                        onto support account.
 */

public class CertificationRequestTriggerHandler extends TriggerHandler{

    private CertificationRequestTriggerHelper helper = new CertificationRequestTriggerHelper();

    public override void afterInsert() {          
        if(globalApexManager.avoidRecursion('CertificationRequestTrigger',  'after', 'insert') ) {
            return;
        }
        helper.notify((List<Certification_Request__c>) newList, null);
    }

    public override void afterUpdate() {          
        if(globalApexManager.avoidRecursion('CertificationRequestTrigger',  'after', 'update') ) {
            return;
        }
        // helper.rollupCertificationRequestToSupportAccount((List<Certification_Request__c>) newList,(Map<Id, Certification_Request__c>) oldMap); //<T01>
        helper.notify((List<Certification_Request__c>) newList, (Map<Id, Certification_Request__c>) oldMap);
    }

    public override void beforeUpdate() {          
        if(globalApexManager.avoidRecursion('CertificationRequestTrigger',  'before', 'update') ) {
            return;
        }
        helper.populateFields((List<Certification_Request__c>) newList,(Map<Id, Certification_Request__c>) oldMap);
        helper.validateOwner((List<Certification_Request__c>) newList, (Map<Id, Certification_Request__c>) oldMap, (Boolean) IsBefore, (Boolean) IsInsert, (Boolean) IsUpdate);
    }

    public override void beforeInsert() {          
        if(globalApexManager.avoidRecursion('CertificationRequestTrigger',  'before', 'insert') ) {
            return;
        }
        helper.validateOwner((List<Certification_Request__c>) newList, null, (Boolean) IsBefore, (Boolean) IsInsert, (Boolean) IsUpdate);
    }
}