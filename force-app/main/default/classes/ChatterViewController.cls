public class ChatterViewController {
    
    @Auraenabled
    public static Map<String,Object> checkObjectSupportsFeed(Id recordId, Boolean isFeedMetaNeeded){
        Map<String,Object>resultMap = new Map<String,Object>();
        resultMap.put('isExternalUser',Userinfo.getUserType()!='Standard' ? true: false);
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String[] types = new String[]{sObjName};

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
        //checking for feed enabled for the obj.
        if(results[0].isFeedEnabled() && !isFeedMetaNeeded){
            //record supports feed tracking
            resultMap.put('isFeedEnabled',true);
        }else{
            System.debug('ELSE BLOCK');
            //checking whether feed meta object record exist for selected recordId.
             List<Feed_Meta__c> feedMetaList = [select Id, Name, Reference__c from Feed_Meta__c where Reference__c =: recordId];
            if(feedMetaList.size()>0)
            {
                resultMap.put('isFeedEnabled',false);
                resultMap.put('feedMetaId',feedMetaList[0].Id);
            }
            else
            {
                Feed_Meta__c feed = new Feed_Meta__c();
                feed.Reference__c = recordId;
                insert feed;
                resultMap.put('isFeedEnabled',false);
                resultMap.put('feedMetaId',feed.Id);                
            }
            System.debug('resultMap else='+ resultMap);
             
        }
        System.debug('Resultmap='+resultMap);
        return resultMap;
    }

	@Auraenabled
    public static Boolean checkForExternalUser(){
        return UserInfo.getUserType()=='Standard' ? true : false;
    }
}