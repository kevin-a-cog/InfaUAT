/*
@created by       : Wasim Akram
@created on       : 02/16/2023
@Purpose          : Trigger Helper for Shadow Lead Request.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.      Tag
****************************************************************************************************************************

*/
public class psa_ShadowLeadRequestTriggerHelper {
    public globalApexManager GAM = new globalApexManager();
 /**
    * Method called from Before Update Trigger to populate fields on Update operation.
    * @param List<psa_Shadow_Lead_Request__c>,Map<Id,psa_Shadow_Lead_Request__c>,List<psa_Shadow_Lead_Request__c>,Map<Id,psa_Shadow_Lead_Request__c>
    * @return 
    * @throws exception - NA
    */
    public void validateFileAttached(List<psa_Shadow_Lead_Request__c> oldList,List<psa_Shadow_Lead_Request__c> newList, Map<Id,psa_Shadow_Lead_Request__c> oldMap, Map<Id,psa_Shadow_Lead_Request__c> newMap){
        
        Map<Id,Integer> mapFileCount = new Map<Id,Integer>();
        String errorMessage = 'Please attach the file(s) before checking the Certification Attached';
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        //Count the files attached to the Shadow Lead Request record and store it in a map
        for(AggregateResult ar : [SELECT LinkedEntityId,count(Id) fileCount FROM ContentDocumentLink 
                                             WHERE LinkedEntityId IN :newMap.keySet() GROUP BY LinkedEntityId]){
            mapFileCount.put((Id) ar.get('LinkedEntityId'), (Integer) ar.get('fileCount'));            
        }
        
        for(psa_Shadow_Lead_Request__c slr : newList){
            //If Files are attached to the Shadow Lead Request record
            if(slr.Certification_attached__c != oldMap.get(slr.Id).Certification_attached__c && slr.Certification_attached__c && mapFileCount.size() > 0 && mapFileCount.get(slr.Id) > 0){
                contactIdSet.add(slr.Resource_Name__c);               
            }
            //If no files are found in the Shadow Lead Request record, throw error
            else if(slr.Certification_attached__c != oldMap.get(slr.Id).Certification_attached__c && slr.Certification_attached__c){
                slr.addError(errorMessage);
            }
        }
        //Mark the Certified Shadow Lead in Contact to TRUE
        for(Id contactId : contactIdSet){
            Contact con = new Contact(Id = contactId, Certified_Shadow_Lead__c = TRUE, Bypass_DateTime__c = System.now());
            conList.add(con);
        }   
        try{
            if(conList.size() > 0){
                update conList;
            }
        }
        catch(Exception e){GAM.CreateExceptionRecords('psa_ShadowLeadRequestTriggerHelper-->validateFileAttached-->update of Contact failed', e.getMessage(), conList[0].Id);}        
    }
}