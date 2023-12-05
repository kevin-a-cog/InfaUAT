/*
* Name : helpArticles_Documents
* Author : Deeksha Shetty
* Created Date : Feb 9,2022
* Description : Controller for Articles and Docs component in product detail page.
Change History
**********************************************************************************************************
Modified By                 Date         Jira No.               Description                                Tag
Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components           T1
                                                            in the Product community
**********************************************************************************************************
*/

public without sharing class helpArticles_Documents {
    
    @AuraEnabled
    Public static List<RequiredValuesWrapper> displayArticles(String topicId, String token){
        try{
            String topicname = [Select Name from Topic Where Id=:topicId].Name;            
            String topic = topicname.replace(' ', '%20');
            topic = topic.replace('&', '%26');
            string authorizationHeader = 'Bearer '+token; //T1
            List<RequiredValuesWrapper> requiredValuesWrapperList = new List<RequiredValuesWrapper>();
            help_Infa_Custom_Label__mdt   endptDetail = [SELECT Endpoint__c ,Learn_More__c FROM help_Infa_Custom_Label__mdt  WHERE developerName ='ToparticlesEndptDetail'];
            
            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json',endptDetail.Endpoint__c+'"'+topic+'"@infadocumenttype="KB"',
                                                                         '',authorizationHeader,'','','',token);
            if(dataResponse.getStatusCode()!=200){                
                return requiredValuesWrapperList;
            }
            else{               
                String responseString = dataResponse.getBody();
                responseString = responseString.replace('"sfprimary_product__c" :', '"sfprimaryproduct" :');
                responseString = responseString.substringAfter('results"'+' '+':');        
                responseString = responseString.substring(0,responseString.lastIndexOf('}'));
                List<articledocdisplayWrapper> resultList = (List<articledocdisplayWrapper>)JSON.deserialize(responseString, List<articledocdisplayWrapper>.class);
                System.debug('resultList='+resultList);
                List<rawWrapper> rawList = new List<rawWrapper>();
                
                
                if(!resultList.isEmpty() || test.isRunningTest()){               
                    for(articledocdisplayWrapper vwrap : resultList){
                        rawList.add(vwrap.raw);
                    }
                }            
                
                if(rawList.size()>0){
                    for(rawWrapper rwrap : rawList){
                        RequiredValuesWrapper req = new RequiredValuesWrapper();
                        req.title = rwrap.systitle;
                        req.sfprimaryproduct = topicname;
                        req.url = rwrap.infapublicurl;               
                        requiredValuesWrapperList.add(req);
                        
                    }
                    
                }
                
                System.debug('requiredValuesWrapperList='+requiredValuesWrapperList);
                if(requiredValuesWrapperList.size()>0){
                    requiredValuesWrapperList[0].LearnMoreUrl = endptDetail.Learn_More__c +topic+']';				              
                }                
            }
            return requiredValuesWrapperList;              
        }
        Catch(Exception e){
            system.debug('Error in Articles  : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }        
    }
    
    
    @AuraEnabled
    Public static List<RequiredValuesWrapper> displayDocs(String topicId, String token){
        try{
            String topicname = [Select Name from Topic Where Id=:topicId].Name;
			List<RequiredValuesWrapper> requiredValuesWrapperList = new List<RequiredValuesWrapper>();            
            String topic = topicname.replace(' ', '%20');
            string authorizationHeader = 'Bearer ' +token; //T1
            help_Infa_Custom_Label__mdt   endptDetail = [SELECT Endpoint__c ,Learn_More__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='RecentDocEndptDetail'];
            
            HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json',endptDetail.Endpoint__c+'"'+topic+'"@infadocumenttype="DocPortal"',
                                                                         '',authorizationHeader,'','','',token);
            if(dataResponse.getStatusCode()!=200){
                return requiredValuesWrapperList;
            }
            else{                          
                String responseString = dataResponse.getBody();
                responseString = responseString.replace('"sfprimary_product__c" :', '"sfprimaryproduct" :');
                responseString = responseString.substringAfter('results"'+' '+':');        
                responseString = responseString.substring(0,responseString.lastIndexOf('}'));                        
                List<articledocdisplayWrapper> resultList = (List<articledocdisplayWrapper>)JSON.deserialize(responseString, List<articledocdisplayWrapper>.class);
                System.debug('resultList='+resultList);
                List<rawWrapper> rawList = new List<rawWrapper>();
                
                
                if(!resultList.isEmpty()){               
                    for(articledocdisplayWrapper vwrap : resultList){
                        rawList.add(vwrap.raw);
                    }
                }            
                System.debug('rawList='+rawList.size());
                if(rawList.size()>0){
                    for(rawWrapper rwrap : rawList){
                        RequiredValuesWrapper req = new RequiredValuesWrapper();
                        req.title = rwrap.systitle;
                        req.sfprimaryproduct = topicname;
                        req.athenaproduct = rwrap.athenaproduct;
                        req.url = rwrap.clickableuri;                
                        requiredValuesWrapperList.add(req);                
                    }                   
                }                                
                System.debug('requiredValuesWrapperList='+requiredValuesWrapperList);
                if(requiredValuesWrapperList.size()>0){
                    requiredValuesWrapperList[0].LearnMoreUrl = endptDetail.Learn_More__c +topic+']';				              
                }
                
            }
            return requiredValuesWrapperList;              
            
        }
        Catch(Exception e){
            system.debug('Error in Articles  : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }        
    }
    
    public class RequiredValuesWrapper{
        @AuraEnabled public String title;
        @AuraEnabled public String sfprimaryproduct;
        @AuraEnabled public List<String> athenaproduct;
        @AuraEnabled public String url;
        @AuraEnabled public String LearnMoreUrl;        
    }
    
    
    public class articledocdisplayWrapper {        
        @AuraEnabled public rawWrapper raw;        
    }
    
    public class rawWrapper{
        @AuraEnabled public String systitle;
        @AuraEnabled public String sfprimaryproduct;
        @AuraEnabled public  List<String> athenaproduct;
        @AuraEnabled public String clickableuri;
        @AuraEnabled public String infapublicurl;
    }

}