/*
        Trigger:        OrgUserBeforeInsert 
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler logic on before insert of Org uSer
*/

trigger OrgUserBeforeInsert on Org_User__c (Before insert) {

    if(globalApexManager.avoidRecursion('OrgUserBeforeInsert')) {
                    return;
        }
    
    OrgTriggerHandler.OrgUserBeforeInsert(Trigger.new);


}