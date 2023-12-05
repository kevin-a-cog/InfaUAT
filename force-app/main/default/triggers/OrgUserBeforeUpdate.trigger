/*
        Trigger:        OrgUserBeforeUpdate 
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler logic on before update of Org uSer
*/

trigger OrgUserBeforeUpdate on Org_User__c (Before update) {

    if(globalApexManager.avoidRecursion('OrgUserBeforeUpdate ')) {
                    return;
        }
    
    OrgTriggerHandler.OrgUserBeforeUpdate(Trigger.oldmap, Trigger.new);


}