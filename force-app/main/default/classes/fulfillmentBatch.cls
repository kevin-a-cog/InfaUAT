/*
 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 N/A                    N/A             N/A             Initial version.                            N/A
 Vignesh Divakaran      2/2/2023        F2A-500         Flex IPU Org Entitlement creation           T01
*/

global class fulfillmentBatch implements Database.Batchable<sObject>{

   List<Sobject> orders ;
   global fulfillmentBatch(List<Sobject> orders){
     this.orders = orders;
   }

   global Iterable<Sobject> start(Database.BatchableContext BC){
      return orders;
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     for(sobject s : scope){
        Id id = (Id)s.get('Id');
        OrgEntitlementService.createOrgEntitlements(id); //<T01>
        ManageFulfillmentCtrl.createFulfillments(id);
        OrgEntitlementService.updateFLOnOrgEntitlementLine(id); //<T01>        
     }
    }

   global void finish(Database.BatchableContext BC){
   } 
}