/*
* Name : helpCoveoVideoDisplayController
* Author : Deeksha Shetty
* Created Date : Jan 3,2022
* Description : Controller for helpCoveoVideoDisplay LWC component. Displays videos in Support TV.
Change History
**********************************************************************************************************
Modified By                Date        Jira No.                  Description                                                 Tag
Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components in the Product community     T1

**********************************************************************************************************

*/

public class helpCoveoVideoDisplayController {
    
    
    @AuraEnabled
    Public static List<RequiredValuesWrapper> displayVideos(String token,String topicId){
        try{
            HttpResponse dataResponse;
            String topic;
            help_Infa_Custom_Label__mdt   endptDetail = [SELECT Endpoint__c , Learn_More__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='CoveoVideoDetail'];
            string authorizationHeader = 'Bearer '+token; //T1
            if(topicId=='home'){
                dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json',endptDetail.Endpoint__c,
                                                                '',authorizationHeader,'','','',token);
                
            }
            else{
                String topicname = [Select Name from Topic Where Id=:topicId].Name;            
                topic = topicname.replace(' ', '%20');
                topic = topic.replace('&', '%26');
                System.debug('topicname='+topic);
                dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json',endptDetail.Endpoint__c+'@athenaproduct="'+topic+'"',
                                                                '',authorizationHeader,'','','',token);
            }
            
            
            
            
            
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
                req.clickUri = rwrap.clickableuri;   //https://www.youtube.com/watch?v=rB6XP6OwDR
                req.htmlImage = rwrap.ytthumbnailurl;
                req.rowId = rwrap.rowid;
                req.videoDescription = rwrap.ytdescription;
                req.embeddedHtml = rwrap.clickableuri.replace('watch?v=','embed/');
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
                    if(dateValueMap.containsKey(dt) && requiredValuesWrapperList.size()< 6){
                        for(RequiredValuesWrapper req : dateValueMap.get(dt)){
                            if(requiredValuesWrapperList.size() != 6){
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
            requiredValuesWrapperList[0].LearnMoreUrl = endptDetail.Learn_More__c + topic+']';
            return requiredValuesWrapperList;            
        }
        catch (Exception e) {
            system.debug('Error in CoveoVideoDisplay : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }
    }
    
    
    
    
    
    public class RequiredValuesWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String uri;
        @AuraEnabled public String printableUri;
        @AuraEnabled public String clickUri;
        @AuraEnabled public String htmlImage;
        @AuraEnabled public String rowId;
        @AuraEnabled public String embeddedHtml;
        @AuraEnabled public Date uploadDate;
        @AuraEnabled public String cardTitle;
        @AuraEnabled public String videoDescription;
        @AuraEnabled public String LearnMoreUrl;
        
    }
    
    
    public class videodisplayWrapper {        
        @AuraEnabled public rawWrapper raw;        
    }
    
    public class rawWrapper{
        @AuraEnabled public String systitle;
        @AuraEnabled public String ytthumbnailurl;
        @AuraEnabled public String rowid;        
        @AuraEnabled public String clickableuri;
        @AuraEnabled public String sysprintableuri;
        @AuraEnabled public String udate;
        @AuraEnabled public String ytdescription;
        
    }    
}