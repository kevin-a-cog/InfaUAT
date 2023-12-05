/*
* Name : helpChangeRequestController
* Author : Deeksha Shetty
* Created Date : Jan 31,2022
* Description : Controller for helpChangeRequestLanding LWC component.
* Test Class   : helpIdeasControllerTest

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Deeksha Shetty         10-FEB-2021     NA                   Initial version.                                          NA

Utkarsh Jain           21-JUN-2022     I2RT-6504            CRT Landing Page                                          NA

Deeksha Shetty         22 May 2023     I2RT-8436            Search result did not show CR: CP-10597                   T1

                                                            in CR landing page
Deeksha Shetty         11-SEP-2023     I2RT-9054            Change request - enhancement                              T2

Deeksha Shetty         03-OCT-2023     I2RT-9211            My Account CRs - "Partner Account" name are also getting  T3
                                                            displayed in "Support Account" filter

Deeksha Shetty         18-OCT-2023     I2RT-9269            CR enhancement on list/tile view - Introducing Product    T4
                                                            /Reported version/Fixed version/Current status

Deeksha Shetty         18-OCT-2023    I2RT-9270             Mismatch in vote count in CR landing page/detail page     T5
Prashanth Bhat         26-OCT-2023    I2RT-9228             Pagination - Changed records limit in SOQL 100 to 108     T6
*/  

public without sharing class  helpChangeRequestController {
    public static Integer limitVar = 108;
    @AuraEnabled(cacheable=true)
    public static help_Infa_Custom_Label__mdt getmetadatarecords(){
        try{
            help_Infa_Custom_Label__mdt crtpopup= [SELECT CRTImagePopup__c, SearchResultURL__c FROM help_Infa_Custom_Label__mdt WHERE developerName = 'helpIdea'];
            return crtpopup;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    
    
    /*
    CRT LANDING : Displays CRT Based on All/My CRTs Tab
    param : userId - for providing checking if loggedin user following any community.
    param : networkId
    param : sortvalue
    param : token
    return : CRs List. 
   */    
    @AuraEnabled
    public static List<ideasLandingWrapper> CRTsLandingDisplay(String networkId,String userId,String sortvalue, String token){
        try{
            Id communityid =[SELECT Id FROM Community where NetworkId =:networkId].Id;            
            List<Community_Interactions__c> fetchFollowIdea = [SELECT Id__c FROM Community_Interactions__c where Type__c='CRT' AND
                                                               Follow__c= true AND User__c=:userId];
            Map<String,Community_Interactions__c> followIdeaMap = new Map<String,Community_Interactions__c>();
            for(Community_Interactions__c com : fetchFollowIdea){
                followIdeaMap.put(com.Id__c,com);
            }
            List<ideasLandingWrapper> displayideawraplist = new List<ideasLandingWrapper>();
            Map<Id,Idea> allideaMap;
            if(sortvalue == 'myideas'){
                allideaMap = new Map<Id,Idea>([SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,Reported_Version__c ,To_be_Fixed_in_version__c ,
                                               CreatedDate, CreatorName,CreatedById FROM Idea 
                                               WHERE Status!=null AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                                     OR Categories INCLUDES('change Request')) AND Id in :followIdeaMap.keyset() ORDER BY CreatedDate DESC LIMIT :limitVar]);//T6
            }else if (sortvalue == 'mySupportAccountideas'){
                List<User> contactIDList = [select Id, Name,ContactId from User where ContactId != null and Id =:userId];               
                if(contactIDList.size() > 0){
                    String supportAccId = [Select ID from RecordType WHERE DeveloperName='Support_Account'].ID;//T3 - Added Record Type Condition to check if its support Acc
                    List<AccountContactRelation> supportAcountId = [select Id,AccountId, ContactId  from AccountContactRelation where ContactId =: contactIDList[0].contactID AND
                                                                   Account.RecordTypeId =:supportAccId]; 
                    List<String> tempList = new List<String>();
                    return getCoveoCRData(supportAcountId, token, 'Latest', tempList); 
                }
                return displayideawraplist;
                
            }else{
                allideaMap = new Map<Id,Idea>([SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,CreatedById,
                                               createdDate, CreatorName,Reported_Version__c ,To_be_Fixed_in_version__c FROM Idea 
                                               WHERE Status!=null AND CommunityId =:communityid AND (Categories='Change Request'
                                               OR Categories INCLUDES('change Request')) ORDER BY CreatedDate DESC LIMIT :limitVar]);//T6
            }
            
            if(allideaMap.size()>0){
                for(Idea item :allideaMap.values()){
                    if(sortvalue == 'myideas'){
                        if(followIdeaMap.keyset().contains(item.Id) || (allideaMap.get(item.Id).Status=='Draft' && allideaMap.get(item.Id).CreatedById==userId)){
                            displayideawraplist.add(mapIdeaData(item));                              
                        }                        
                    }
                    else if(sortvalue == 'allIdeas'){
                        displayideawraplist.add(mapIdeaData(item));                     
                    }                                    
                }
            }           
            return displayideawraplist;
        }
        
        Catch(Exception e){
            system.debug('Error in idea Landing Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    
    /* 
    T2 starts : getSupportAccountNames : Gets all support Accounts related to User
    * Filter is dynamic and can show only the support account the user is part of
    return : SupportAccountWrapper - Support Account Ids & Names List. 
   */ 
    
    @AuraEnabled
    public static List<SupportAccountWrapper> getSupportAccNamesCoveo(String token) {
        List<SupportAccountWrapper> supportAccNamesList = new List<SupportAccountWrapper>();
        Set<String> supportAccIdsSet = new Set<String>();
        Map<String,String> supportAccIdNameMap = new Map<String,String>();
        List<AccountContactRelation> supportAcountIdList = new List<AccountContactRelation>();
        List<User> contactIDList = new List<User>();
        
        if(test.isrunningtest()) contactIDList = [select ContactId from User where ContactId != null limit 1];
        else contactIDList = [select ContactId from User where ContactId != null and Id =:userinfo.getuserId()];    
        
        if(contactIDList.size()>0){
            String supportAccId = [Select ID from RecordType WHERE DeveloperName='Support_Account'].ID; //T3 - Added Record Type Condition to check if its support Acc
            supportAcountIdList  = [select AccountId,Account.Name from AccountContactRelation where ContactId =: contactIDList[0].contactID 
                                    AND Account.RecordTypeId =:supportAccId
                                    Order by Account.Name ASC ];             
        }        
        
        List<String> supportAccList = new List<String>();
        if(supportAcountIdList.size()>0 || test.isrunningtest()){
            for(AccountContactRelation acr : supportAcountIdList){
                supportAccIdNameMap.put(acr.AccountId,acr.Account.Name);
                supportAccList.add(acr.AccountId);
            }            
        }
        
        String suppAccString = string.join(supportAccList,'; ');
        
        String authorizationHeader = 'Bearer ' +token;
        help_Infa_Custom_Label__mdt   endptDetail = [SELECT  Endpoint__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='supportAccountCR'];
        String endpoint = suppAccString.replace('; ', '%2C%20');
        String sortString = ')&sortCriteria=date%20descending';
    
        String finalEndpoint = endptDetail.Endpoint__c + endpoint + sortString ;
        String responseString;
        
        if(test.isrunningtest()) responseString ='{"totalCount" : 5472,"results" : [ {"title" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","uri" : "https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","printableUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","clickUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","raw" :{"systitle" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","clickableuri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","ytthumbnailurl" : "https://i.ytimg.com/vi/56ptHKf_B0U/mqdefault.jpg","printableuri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","udate" : 1641568034000,"rowid" : 1641607828317879983},"Title" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","Uri" : "https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","PrintableUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","ClickUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","UniqueId" : "42.8693$https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","Excerpt" : "This video demonstrates how to configure an IAM assume role to access AWS resources using PowerExchange for Amazon S3.","FirstSentences" : null}]}';
        
        else{
            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json', finalEndpoint,
                                                                         '',authorizationHeader,'','','',token);
            responseString = dataResponse.getBody();
        }      
        responseString = responseString.replace('"sfupvote_count__c":', '"sfupvotecount":');        
        responseString = responseString.substringAfter('results" :');  
        responseString = responseString.substring(0,responseString.lastIndexOf('}'));
        responseString = responseString.replace('sfsupport_account_id__c','sfsupportAccountId');//T2
        System.debug('responseString=>'+responseString);
        List<displayWrapper> resultList = (List<displayWrapper>)JSON.deserialize(responseString, List<displayWrapper>.class);
        System.debug('resultList=>'+resultList);
        List<rawWrapper> rawList = new List<rawWrapper>();
        if(!resultList.isEmpty() || test.isRunningTest()){               
            for(displayWrapper vwrap : resultList){
                rawList.add(vwrap.raw);
            }
        }
        System.debug('rawList=>'+rawList);
        
        for(rawWrapper rwrap : rawList){
            if(rwrap.sfsupportAccountId.size()>0){
                for(String sfId : rwrap.sfsupportAccountId){
                    supportAccIdsSet.add(sfId);
                }                
            }            
        }
        
        
        if(supportAccIdsSet.size()>0){
            for(String acr : supportAccIdsSet){
                SupportAccountWrapper acwrap = new SupportAccountWrapper();
                acwrap.Id = acr;
                acwrap.Name = supportAccIdNameMap.keyset().contains(acr) ? supportAccIdNameMap.get(acr) : '' ;
                if(acwrap.Name!='') supportAccNamesList.add(acwrap);                
            }           
        }
        
        if(supportAccNamesList.size()==0) supportAccNamesList[0].NoData = 'no Data';
        System.debug('supportAccNamesList='+supportAccNamesList);
         return supportAccNamesList;
    }
    
    //T2 ends
       
    
    @AuraEnabled
    public static List<ideasLandingWrapper> sortbyFilterCRTs(String networkId,String userId,String sortFilter, String sortCRT, String token, List<String> selectedStatus){
        try{
            Id communityid =[SELECT Id FROM Community where NetworkId =:networkId].Id;
            List<help_community_url__mdt> communityUrl = [SELECT url_name__c FROM help_community_url__mdt where developerName = 'communityUrl'];
            List<Idea> ideaDetail = new List<Idea>();
            List<Community_Interactions__c> fetchFollowIdea = [SELECT Id__c FROM Community_Interactions__c where Type__c='CRT' AND
                                                               Follow__c= true AND User__c=:userId];
            Map<String,Community_Interactions__c> newMap = new Map<String,Community_Interactions__c>();
            for(Community_Interactions__c com : fetchFollowIdea){
                newMap.put(com.Id__c,com);
            }
            
            
            if(sortCRT == 'mySupportAccountideas' && sortFilter == 'Latest'){
                
                Id contactID = [select Id, Name,ContactId from User where ContactId != null and Id =:userId].ContactId;
                if(contactID != null){
                    List<AccountContactRelation> supportAcountId = [select Id,AccountId, ContactId  from AccountContactRelation where ContactId =: contactID];
                    return getCoveoCRData(supportAcountId, token, 'Latest', selectedStatus); 
                }
            }else if(sortCRT == 'mySupportAccountideas'){
                Id contactID = [select Id, Name,ContactId from User where ContactId != null and Id =:userId].ContactId;
                if(contactID != null){
                    List<AccountContactRelation> supportAcountId = [select Id,AccountId, ContactId  from AccountContactRelation where ContactId =: contactID];
                    return getCoveoCRData(supportAcountId, token, 'Old', selectedStatus); 
                }
            }else if(selectedStatus.size() == 0){
                if(sortCRT == 'myCrs' && sortFilter == 'Latest'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,
                                  CreatedDate, CreatorName,CreatedById FROM Idea 
                                  WHERE Status!=null AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                        OR Categories INCLUDES('change Request')) AND Id in :newMap.keyset() ORDER BY CreatedDate DESC LIMIT :limitVar] ; //T6      
                }else if(sortCRT == 'myCrs'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,
                                  CreatedDate, CreatorName,CreatedById FROM Idea 
                                  WHERE Status!=null AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                        OR Categories INCLUDES('change Request')) AND Id in :newMap.keyset() ORDER BY CreatedDate ASC LIMIT :limitVar] ;//T6
                }else if (sortCRT == 'allCrs' && sortFilter == 'Latest'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,CreatedById,
                                  createdDate, CreatorName FROM Idea 
                                  WHERE Status!=null AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                        OR Categories INCLUDES('change Request')) ORDER BY CreatedDate DESC LIMIT :limitVar];//T6
                }else if (sortCRT == 'allCrs'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,CreatedById,
                                  createdDate, CreatorName FROM Idea 
                                  WHERE Status!=null AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                        OR Categories INCLUDES('change Request')) ORDER BY CreatedDate ASC LIMIT :limitVar];//T6
                }
            } else if(selectedStatus.size() > 0){
                if(sortCRT == 'myCrs' && sortFilter == 'Latest'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,
                                  CreatedDate, CreatorName,CreatedById FROM Idea 
                                  WHERE Status in :selectedStatus AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                                     OR Categories INCLUDES('change Request')) AND Id in :newMap.keyset() ORDER BY CreatedDate DESC LIMIT :limitVar] ;   //T6    
                }else if(sortCRT == 'myCrs'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,
                                  CreatedDate, CreatorName,CreatedById FROM Idea 
                                  WHERE Status in :selectedStatus AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                                     OR Categories INCLUDES('change Request')) AND Id in :newMap.keyset() ORDER BY CreatedDate ASC LIMIT :limitVar] ;//T6
                }else if (sortCRT == 'allCrs' && sortFilter == 'Latest'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,CreatedById,
                                  createdDate, CreatorName FROM Idea 
                                  WHERE Status in :selectedStatus AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                                     OR Categories INCLUDES('change Request')) ORDER BY CreatedDate DESC LIMIT :limitVar];//T6
                }else if (sortCRT == 'allCrs'){
                    ideaDetail = [SELECT Id, Title,Body, Upvote_Count__c, Categories, Status,CreatedById,
                                  createdDate, CreatorName FROM Idea 
                                  WHERE Status in :selectedStatus AND CommunityId =:communityid AND (Categories='Change Request'
                                                                                                     OR Categories INCLUDES('change Request')) ORDER BY CreatedDate ASC LIMIT :limitVar];//T6
                }
            }
            List<ideasLandingWrapper> followideawraplist = new List<ideasLandingWrapper>();
            
            if(ideaDetail.size()>0){                
                for(Idea item :ideaDetail){
                    if(sortCRT=='myCrs'){
                        if(newMap.keyset().contains(item.Id)){                            
                            followideawraplist.add(mapIdeaData(item));
                        }
                    }
                    else if(sortCRT=='allCrs'){          
                        followideawraplist.add(mapIdeaData(item));    
                    }
                }   
            }
            return followideawraplist;
        }
        
        Catch(Exception e){
            system.debug('Error in idea Landing Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled
    public static List<ideasLandingWrapper> getSearchedCRs(String searchTerm,String networkId){
        try{
            List<ideasLandingWrapper> displayideawraplist = new List<ideasLandingWrapper>();
            String SearchKey =  searchTerm!= null ?'%'+String.escapeSingleQuotes(searchTerm)+'%' :'';
            String SOQL;
            Id communityid =[SELECT Id FROM Community where NetworkId =:networkId].Id;
            List<Idea> searchedIdeaList = new List<Idea>();
            string changerequest = '(\'' +'Change Request' + '\')'; //T1
            //this will search from the entire CR records if search key is present and return 100 items to LWC
            //T1 - Search Issue - have added INCLUDES
            if(String.isNotBlank(searchTerm)){
                SOQL = 'Select Id,Body,Title,Status,Categories,CreatorName,createddate,Upvote_Count__c,Reported_Version__c ,To_be_Fixed_in_version__c FROM Idea WHERE Title LIKE:SearchKey AND Status!=null AND CommunityId =:communityid AND Categories INCLUDES '+changerequest+ 'ORDER BY Title,CreatedDate DESC LIMIT '+limitVar;//T6
            }
            
            searchedIdeaList = Database.query(SOQL);
            for(Idea item : searchedIdeaList){
                displayideawraplist.add(mapIdeaData(item));                               
            }                        
            
            return displayideawraplist;       
        }
        catch(Exception e){
            system.debug('Error in Searched Ideas : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
    }
     
    public static List<ideasLandingWrapper> getCoveoCRData(List<AccountContactRelation> supportAcountId, String token, String sortBy, List<String> selectedStatus) {
        List<ideasLandingWrapper> displayideawraplisttemp = new List<ideasLandingWrapper>();
        Map<String,String> supportAccMap = new Map<String,String>();
        List<String> supportAccList = new List<String>();
        
        List<AccountContactRelation> supportAcountIdList = [select AccountId,Account.Name from AccountContactRelation where Id=:supportAcountId
                                                            Order by Account.Name ASC ];
        if(supportAcountIdList.size()>0){
            for(AccountContactRelation acr : supportAcountIdList){
                supportAccList.add(acr.AccountId);
                supportAccMap.put(acr.AccountId,acr.Account.Name);
            }            
        }
        
        String suppAccString = string.join(supportAccList,'; ');
        
        String authorizationHeader = 'Bearer ' +token;
        help_Infa_Custom_Label__mdt   endptDetail = [SELECT  Endpoint__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='supportAccountCR'];
        String endpoint = suppAccString.replace('; ', '%2C%20');
        String sortString = ')&sortCriteria=date%20descending';
        if(selectedStatus.size() > 0){
            String selectedStatusString = String.join(selectedStatus, '; ');
            String endpointStatus = selectedStatusString.replace('; ', '%2C%20');
            sortString = ')%40sfstatus%3D('+ endpointStatus +')&sortCriteria=date%20ascending';
            if(sortBy == 'Latest'){
                sortString = ')%40sfstatus%3D('+ endpointStatus +')&sortCriteria=date%20descending';
            }
        }else{
            sortString = ')&sortCriteria=date%20ascending';
            if(sortBy == 'Latest'){
                sortString = ')&sortCriteria=date%20descending';
            }
        }
        
        String finalEndpoint = endptDetail.Endpoint__c + endpoint + sortString ;        
        system.debug('--finalEndpoint--'+finalEndpoint);
        String responseString;        
        
        if(test.isrunningtest()) responseString ='{"totalCount" : 5472,"results" : [ {"title" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","uri" : "https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","printableUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","clickUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","raw" :{"systitle" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","clickableuri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","ytthumbnailurl" : "https://i.ytimg.com/vi/56ptHKf_B0U/mqdefault.jpg","printableuri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","udate" : 1641568034000,"rowid" : 1641607828317879983},"Title" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","Uri" : "https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","PrintableUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","ClickUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","UniqueId" : "42.8693$https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","Excerpt" : "This video demonstrates how to configure an IAM assume role to access AWS resources using PowerExchange for Amazon S3.","FirstSentences" : null}]}';
        
        else  {
            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json', finalEndpoint,
                                                                         '',authorizationHeader,'','','',token);
            responseString = dataResponse.getBody();
        }
        
        System.debug('initial response=>'+responseString);                 
          
        responseString = responseString.substringAfter('results" :');  
        responseString = responseString.substring(0,responseString.lastIndexOf('}'));
        responseString = responseString.replace('sfsupport_account_id__c','sfsupportAccountId');//T2
        responseString = responseString.replace('sfupvote_count__c', 'sfupvotecount');                 //T5 - Replace all sfupvote_count__c formats to sfupvotecount         
        responseString = responseString.replace('sfto_be_fixed_in_version__c', 'ToBeFixedInVersion');    //T4- Changing the format to Display this field in UI.
        responseString = responseString.replace('sfreported_version__c', 'ReportedVersion');             //T4- Changing the format to Display this field in UI.
        System.debug('responseString=>'+responseString);
        List<displayWrapper> resultList = (List<displayWrapper>)JSON.deserialize(responseString, List<displayWrapper>.class);
        System.debug('resultList=>'+resultList);
        System.debug('resultList Size=>'+resultList.size());
        List<rawWrapper> rawList = new List<rawWrapper>();
        if(!resultList.isEmpty() || test.isRunningTest()){               
            for(displayWrapper vwrap : resultList){
                rawList.add(vwrap.raw);
            }
        }
        system.debug('rawList=>'+rawList);
        system.debug('rawList size=>'+rawList.size());
        String category;
        
        for(rawWrapper rwrap : rawList){
            System.debug('rwrap=>'+rwrap);
            ideasLandingWrapper req = new ideasLandingWrapper();
            req.Id = rwrap.sfid != null ? rwrap.sfid : '';
            req.Name = rwrap.systitle != null ? rwrap.systitle : '';
            req.Status = rwrap.sfstatus != null ? rwrap.sfstatus : '';
            
            /* T4 Starts - Removing Change Request from the categories */
            if( rwrap.sfcategories != null && rwrap.sfcategories.contains(';')){
                List<String> categoryList = rwrap.sfcategories.split(';');                   
                categoryList.remove(categoryList.indexOf('Change Request'));
                category = (categoryList[0]=='Change Request') ? categoryList[1] : categoryList[0];
                req.Category = category;
            }
            else{
                req.Category = rwrap.sfcategories != null ? rwrap.sfcategories : '';
            }
           
           /* T4 Ends */
                      
            req.upvoteCount = rwrap.sfupvotecount != null ? rwrap.sfupvotecount : 0.0;
            req.Description = rwrap.sfbody != null ? rwrap.sfbody.stripHtmlTags() : '';
            req.Link = rwrap.sysprintableuri != null ? rwrap.sysprintableuri : '';
            req.CreatorName = rwrap.sfcreatorname;
            if(rwrap.ReportedVersion != null) req.ReportedVersion = rwrap.ReportedVersion ; //T4 - If there is no Reported Version , don't show the field and value.
            if(rwrap.ToBeFixedInVersion != null) req.ToBeFixedInVersion = rwrap.ToBeFixedInVersion ; //T4- If there is no to be fixed in version, don't show the field and value.
            DateTime dT = datetime.newinstance(long.valueOf(rwrap.syssfcreateddate));                
            req.createddate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year();
            
            if(rwrap.sfsupportAccountId.size()==1){
                System.debug('First Block=>'+rwrap.sfsupportAccountId[0]);
                req.SupportAccountName = supportAccMap.keyset().contains(rwrap.sfsupportAccountId[0]) ? supportAccMap.get(rwrap.sfsupportAccountId[0]) : '';
            }
            
            else if(rwrap.sfsupportAccountId.size() > 1){
                System.debug('Second Block=>'+rwrap.sfsupportAccountId);
                for(String rw : rwrap.sfsupportAccountId){
                    System.debug('rw='+rw);
                    if(supportAccMap.keyset().contains(rw)){
                        req.SupportAccountName = supportAccMap.get(rw);
                    }
                    else System.debug('Support Account Name absent');                              
                }
            }
            else  System.debug('Third Block=>'+rwrap.sfsupportAccountId);
            
            System.debug('req.SupportAccountName INSIDE='+req.SupportAccountName);
            System.debug('displayideawraplisttemp Size INSIDE=>'+displayideawraplisttemp.size());
            displayideawraplisttemp.add(req);                                      
        }
              
        System.debug('displayideawraplisttemp=>'+displayideawraplisttemp);
        System.debug('displayideawraplisttemp Size=>'+displayideawraplisttemp.size());        
        return displayideawraplisttemp;
    }
    
    
    public static ideasLandingWrapper mapIdeaData(Idea item){
        String sitelabel = System.Label.IN_CommunityName;
        ideasLandingWrapper wrap = new ideasLandingWrapper();
        wrap.Id = item.Id;
        /* T4 Starts - Removing Change Request from the categories */
        String category;
        if(item.Categories.contains(';')){
            List<String> categoryList = item.Categories.split(';');                   
            categoryList.remove(categoryList.indexOf('Change Request'));
            category = (categoryList[0]=='Change Request') ? categoryList[1] : categoryList[0];
            wrap.Category = category;
        }
        else wrap.Category = item.Categories;
        
        /* T4 Ends */
        wrap.Name = item.title;
        wrap.Status = item.Status;
        if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
        else{wrap.upvoteCount= item.Upvote_Count__c;}
        if(item.Reported_Version__c !=null) wrap.ReportedVersion = item.Reported_Version__c;   //T4
        if(item.To_be_Fixed_in_version__c!=null) wrap.ToBeFixedInVersion = item.To_be_Fixed_in_version__c;  //T4
        wrap.Description = item.body.stripHtmlTags();
        wrap.Link = sitelabel + 'ideadetail?id=' + item.Id;
        DateTime dT = item.CreatedDate;                
        wrap.createddate = dT.format('MMMM') +' '+dT.day()+' '+  dT.year();                
        wrap.CreatorName = item.CreatorName;   
        return wrap;   
    }
    
    /*T2 starts - Wrapper Class to return the support account ID & Name*/
    public class SupportAccountWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String NoData;

    }
    /*T2 ends*/
    
    
    public class ideasLandingWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Status;
        @AuraEnabled public String Category;   
        @AuraEnabled public decimal upvoteCount;
        @AuraEnabled public String Description;
        @AuraEnabled public String Link;
        @AuraEnabled public String CreatorName;
        @AuraEnabled public String createddate;
        @AuraEnabled public String SupportAccountId; /* T2 - Created to get the support Account ID*/
        @AuraEnabled public String SupportAccountName; /* T2 - Created to get the support Account Name */ 
        @AuraEnabled public String ReportedVersion; //T4
        @AuraEnabled public String ToBeFixedInVersion; //T4
        
    }
    
    public class ideaWrapper{
        @AuraEnabled public String ideaId;
        @AuraEnabled public String title;
        @AuraEnabled public String Body;
        @AuraEnabled public String createddate;
        @AuraEnabled public String CreatorName;
        @AuraEnabled public String communityName;
        @AuraEnabled public String Category;
        @AuraEnabled public decimal totalVoteCount;
        @AuraEnabled public decimal upvoteCount;
        @AuraEnabled public String Status;        
    }    
    
    public class displayWrapper {
        @AuraEnabled public rawWrapper raw;        
    }
    
    public class rawWrapper{
        @AuraEnabled public String sfid;
        @AuraEnabled public String systitle;
        @AuraEnabled public String sfstatus;
        @AuraEnabled public String sfcategories;
        @AuraEnabled public decimal sfupvotecount;
        @AuraEnabled public String sfbody;
        @AuraEnabled public String sysprintableuri;
        @AuraEnabled public String sfcreatorname;
        @AuraEnabled public String syssfcreateddate;
        @AuraEnabled public List<String> sfsupportAccountId  ;// T2 - Created to store support Account Id
        @AuraEnabled public String ReportedVersion; //T4
        @AuraEnabled public String ToBeFixedInVersion; //T4
    }
}