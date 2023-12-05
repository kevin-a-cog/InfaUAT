/*
* Name : FeedMetaTriggerHandler
* Author : Deeksha Shetty
* Created Date : March 23,2022
* Description : Controller for Feed Meta Trigger
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
23/02/2022 I2RT- Initial version. N/A
*/

public class FeedMetaTriggerHandler {
    
    public void OnAfterInsert(List<Feed_Meta__c> feedmetaList){
        Map<Id,String> idsobjMap = new Map<Id,String>();
        for(Feed_Meta__c fm : feedmetaList){
            Id refId = fm.Reference__c;
            String sObjName =refId.getSObjectType().getDescribe().getName();
            idsobjMap.put(refId,sObjName);            
        }
        System.debug('idsobjMap='+idsobjMap);
        
        Set<Id> feedmetaIdwithreftype = new set<Id>();
        if(idsobjMap.size()>0){
            for(Id sid :idsobjMap.keyset()){
                if(idsobjMap.get(sid) == 'Event' || idsobjMap.get(sid) == 'Idea'){
                    feedmetaIdwithreftype.add(sid);
                }            
            }            
        }
                
        List<Feed_Meta__c> feedMetaRec = [select Id,Reference_Type__c from Feed_Meta__c where Reference__c =: feedmetaIdwithreftype];
        if(feedMetaRec.size()>0){
            for(Feed_Meta__c fm :feedMetaRec){
                fm.Reference_Type__c = 'Ideas';
            }
            update feedMetaRec;            
        }        
    }

    
    
    
    
    
}