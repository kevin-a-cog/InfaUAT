/*
   @created by       : Anusha Palekar
   @created on       : 18/02/2022
   @Purpose          : API Calls to Coveo for IN Community
   @Testclass        :
   @JIRA             :
*/

global with sharing class helpCoveoArticlesController {

    public helpCoveoArticlesController() {
        //Nothing
    }

    /* Make API get call to Coveo to fetch details */
    @AuraEnabled(Cacheable=true)
    public static CoveoResultsResponse getDetails(String token) {

        CoveoResultsResponse coveoResponse = new CoveoResultsResponse();
        List<CoveoResultsWrapper> coveoResults = new List<CoveoResultsWrapper>(); 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        help_Infa_Custom_Label__mdt   endptDetail = [SELECT Endpoint__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='articles'];
        string authorizationHeader = 'Bearer ' +token;
        request.setEndpoint(endptDetail.Endpoint__c);
        request.setMethod('GET');
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        HttpResponse response;
        try{
                response = http.send(request);
            	System.debug('Response>>>>>>'+response.getBody());
                if(response.getStatusCode() == 200) {
                    coveoResponse.APIResponseStatus = '200';
                    coveoResponse.ErrorMessage = 'NO_ERROR';
                    Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    System.debug('Deserialized Response>>>>>>'+resultObj);
                    List<Object> lstResults = (List<Object>)resultObj.get('results');
                        for(Integer i = 0; i<lstResults.size(); i++) {

                            Object result = lstResults[i];
                            Map<String,Object> mapResult = (Map<String,Object>)result;
                            if( mapResult.get('raw') != null)
                            {
                                Object objRaw = mapResult.get('raw');
                                Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
                                CoveoResultsWrapper coveoData = new CoveoResultsWrapper();
                                coveoData.coveoTitle = mapRaw.get('title') != null ?  mapRaw.get('title').toString()  : '';
                                coveoData.coveoExcerpt = mapResult.get('excerpt') != null ?  mapResult.get('excerpt').toString()  : '';
                                coveoData.clickableuri = mapResult.get('printableUri') != null ?  mapResult.get('printableUri').toString()  : '';
                                coveoData.infapublicurl = mapRaw.get('infapublicurl') != null ?  mapRaw.get('infapublicurl').toString()  : '';
                                coveoData.infacontenttype = mapRaw.get('infacontenttype') != null ?  mapRaw.get('infacontenttype').toString()  : '';
                                coveoData.infadocumenttype = mapRaw.get('infadocumenttype') != null ?  mapRaw.get('infadocumenttype').toString()  : '';
                                coveoData.infaprimaryproduct = mapRaw.get('infaprimaryproduct') != null ?  mapRaw.get('infaprimaryproduct').toString()  : '';
                                coveoData.athenaproduct = (List<String>) JSON.deserialize(JSON.serialize(mapRaw.get('athenaproduct')), List<String>.class);
                                coveoData.athenaproductversion = (List<String>) JSON.deserialize(JSON.serialize(mapRaw.get('athenaproductversion')), List<String>.class);
                                //coveoData.lastModifiedDate = mapRaw.get('sfarticlecreateddate') != null ? DateTime.newInstance( Long.valueOf(mapRaw.get('sfarticlecreateddate').toString())) : null;
                                coveoResults.add(coveoData);
                                System.debug('Each Result>>>>>>'+coveoData);
                            }
                        }
                    coveoResponse.CoveoResultsWrapper = coveoResults;
                }
            }
        catch(Exception e) {
            coveoResponse.APIResponseStatus = 'ERROR';
            coveoResponse.ErrorMessage = e.getMessage();       
        }
        return coveoResponse;
    }

    public class CoveoResultsWrapper{
    //Coveo Data Properties
    @AuraEnabled public string coveoTitle { get; set; }
    @AuraEnabled public string coveoExcerpt { get; set; }
    @AuraEnabled public string clickableuri { get; set; }
    @AuraEnabled public string infapublicurl { get; set; }
    @AuraEnabled public string infacontenttype { get; set; }
    @AuraEnabled public string infadocumenttype { get; set; } 
    @AuraEnabled public string infaprimaryproduct { get; set; } 
    @AuraEnabled public DateTime lastModifiedDate { get; set; }  
    @AuraEnabled public List<string> athenaproduct{get ; set; }
    @AuraEnabled public List<string> athenaproductversion{get ; set; }
        
    }

    public class CoveoResultsResponse{
    //API status properties with Data
    @AuraEnabled public string apiResponseStatus { get; set; }
    @AuraEnabled public string searchDataAPIURL { get; set; }
    @AuraEnabled public List<CoveoResultsWrapper> coveoResultsWrapper;
    @AuraEnabled public string errorMessage { get; set; }
    }
}