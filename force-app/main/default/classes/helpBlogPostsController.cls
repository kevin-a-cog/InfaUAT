/*
* Name : helpBlogPostsController
* Author : Deeksha Shetty
* Created Date : Jan 11,2022
* Description : Controller for Blogs component in product detail page.
Change History
**********************************************************************************************************
Modified By                 Date         Jira No.             Description                                   Tag
Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components            T1
                                                            in the Product community
**********************************************************************************************************

*/

public class helpBlogPostsController {
    
    @AuraEnabled
    Public static List<RequiredValuesWrapper> displayBlogs(String topicId,String token){
        try{
            System.debug('topicId in Blogs='+topicId);
            System.debug('token in Blogs='+token);
            String topicname = [Select Name from Topic Where Id=:topicId].Name;            
            String topic = topicname.replace(' ', '%20');
            topic = topic.replace('&', '%26');
            string authorizationHeader = 'Bearer '+token; //T1
            
            help_Infa_Custom_Label__mdt   endptDetail = [SELECT Endpoint__c ,Learn_More__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='BlogVideoDetail'];
             

            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json',endptDetail.Endpoint__c+'@athenaproduct="'+topic+'"',
                                                                     '',authorizationHeader,'','','',token);            
            
            String responseString = dataResponse.getBody();
            System.debug('responseString1='+responseString);
            responseString = responseString.replace('"date" :', '"udate" :');
            responseString = responseString.substringAfter('results"'+' '+':');        
            responseString = responseString.substring(0,responseString.lastIndexOf('}'));        
            System.debug('responseString2='+responseString);
            List<videodisplayWrapper> resultList = (List<videodisplayWrapper>)JSON.deserialize(responseString, List<videodisplayWrapper>.class);
            System.debug('resultList='+resultList.size());
            List<rawWrapper> rawList = new List<rawWrapper>();
            if(!resultList.isEmpty()){               
                for(videodisplayWrapper vwrap : resultList){
                    rawList.add(vwrap.raw);
                }
            }            
            System.debug('rawList='+rawList.size());
            Map<Date,List<RequiredValuesWrapper>>  dateValueMap = new Map<Date,List<RequiredValuesWrapper>>();
            for(rawWrapper rwrap : rawList){
                RequiredValuesWrapper req = new RequiredValuesWrapper();
                req.title = rwrap.systitle;
                req.printableUri = rwrap.sysprintableuri;
                                 
                req.rowId = rwrap.rowid;
                req.url = rwrap.clickableuri;
                string date1 = rwrap.udate;            
                Long longDate  = Long.valueOf(date1);
                DateTime dt = DateTime.newInstance(longDate);
                Date videoUploadDate = date.newinstance(dt.year(), dt.month(), dt.day());
                req.uploadDate = videoUploadDate;
                
                if (dateValueMap.containsKey(videoUploadDate)){
                    dateValueMap.get(videoUploadDate).add(req);                                                         
                } else{
                    dateValueMap.put(videoUploadDate, new List<RequiredValuesWrapper>{req});                   
                }
            }
            
            System.debug('dateValueMap='+dateValueMap);
            List<Date> datelist = new List<Date>();
            if(!dateValueMap.isEmpty()){
                for(Date d : dateValueMap.keyset()){
                    datelist.add(d);           
                }
            }
            
            List<Date> recentDates = new List<Date>(); 
            if(!datelist.isEmpty()){
                datelist.sort();
                System.debug('datelist='+datelist);                           
                for(Integer i = datelist.size()-1; i>=0;i--){
                    recentDates.add(datelist.get(i));                    
                }
            }
            System.debug('recentDates='+recentDates);
            List<RequiredValuesWrapper> requiredValuesWrapperList = new List<RequiredValuesWrapper>();            
            if(!recentDates.isEmpty()){
                for(Date dt : recentDates){
                    if(dateValueMap.containsKey(dt) && requiredValuesWrapperList.size()< 5){
                        for(RequiredValuesWrapper req : dateValueMap.get(dt)){
                            if(requiredValuesWrapperList.size() != 5){
                                requiredValuesWrapperList.add(req);
                            }
                            else{
                                break;
                            }                                                       
                        }                        
                    }
                    else{
                        break;
                    }
                }
            }
            System.debug('requiredValuesWrapperList='+requiredValuesWrapperList);
            requiredValuesWrapperList[0].LearnMoreUrl = endptDetail.Learn_More__c +topic+']&f:@incontenttype=[Blog]';
            return requiredValuesWrapperList;   
        }
        Catch(Exception e){
            system.debug('Error in Blog Posts : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
        
    }
    
    public class RequiredValuesWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String uri;
        @AuraEnabled public String printableUri;        
        @AuraEnabled public String rowId;
        @AuraEnabled public String url;
        @AuraEnabled public Date uploadDate;
        @AuraEnabled public String LearnMoreUrl;
    }
    
    
    public class videodisplayWrapper {        
        @AuraEnabled public rawWrapper raw;        
    }
    
    public class rawWrapper{
        @AuraEnabled public String systitle;
        @AuraEnabled public String rowid;        
        @AuraEnabled public String clickableuri;
        @AuraEnabled public String sysprintableuri;
        @AuraEnabled public String udate;                
    }
    
    
}