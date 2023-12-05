// Controller used by any visualforce page for forcing a sync without changing mapped fields
public with sharing class TickleController {
   private final Id objectId;
   
   public TickleController(ApexPages.StandardController stdController) {
       objectId = stdController.getRecord().Id;
   }
   
   public PageReference sync() {
       Map<String, Set<Id>> objectIdsByObjectType = new Map<String, Set<Id>>();
       objectIdsByObjectType.put(String.valueOf(objectId.getSObjectType()), new Set<Id>{objectId});
       APXT_Redlining.PlatformDataService.tickleData(objectIdsByObjectType);
       system.debug(objectIdsByObjectType);
       PageReference pageRef = new PageReference('/' + objectId);
       pageRef.setRedirect(true);
       return pageRef;
   }
}