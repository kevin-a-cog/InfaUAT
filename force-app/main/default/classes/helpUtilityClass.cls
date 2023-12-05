/*
* Description: This class includes all resuable methods used for IN Transformation.
*/

public without sharing class helpUtilityClass {
    
    /* This is a Common Class used for making HTTP Callout */
    public static HttpResponse makeHttpCallout(String method, String contentType,String endPoint,
                                               String requestBody, String authorisation,String charSet,
                                               String xAPIUserName, String xAPISeret, String xAPIToken){
                                                   HttpRequest req = new HttpRequest();
                                                   req.setMethod(method);
                                                   req.setHeader('Content-Type', contentType);
                                                   req.setEndpoint(endPoint);
                                                   req.setTimeout(120000);
                                                   if(String.isNotBlank(requestBody)){
                                                       req.setBody(requestBody);    
                                                   }
                                                   if(String.isNotBlank(authorisation)){
                                                       req.setHeader('Authorization', authorisation);
                                                   }
                                                   if(String.isNotBlank(charSet)){
                                                       req.setHeader('Accept-Charset', charSet);
                                                   }
                                                   if(String.isNotBlank(xAPIUserName)){
                                                       req.setHeader('X-Api-User', xAPIUserName);
                                                   }
                                                   if(String.isNotBlank(xAPISeret)){
                                                       req.setHeader('X-Api-Secret', xAPISeret);
                                                   }
                                                   if(String.isNotBlank(xAPIToken)){
                                                       req.setHeader('X-Api-Token', xAPIToken);
                                                   }
                                                   system.debug('req.getHeader : ' + req.getHeader('X-Api-Secret'));
                                                   system.debug('req.getBody : ' + req.getBody());
                                                   system.debug('req.toString : ' + req.toString());
                                                   Http http = new Http();
                                                   HTTPResponse res = http.send(req);
                                                   system.debug('res.toString : ' + res.getBody());
                                                   return res;
                                               }
}