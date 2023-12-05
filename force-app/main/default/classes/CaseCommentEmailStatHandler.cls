/*
@created by       : Sandeep Duggi
@created on       : 12/21/2021
@Purpose          : handles Trigger contexts on CaseCommentEmailStatTrigger
@Testclass        : 
@JIRA             : I2RT-5131



Change History
****************************************************************************************************
ModifiedBy      Date        Requested By        Description               Jira No.       Tag

****************************************************************************************************

*/public class CaseCommentEmailStatHandler {
   @future(callout=true) 
   public static void ApiCallToDeleteBounces(String[] Emails){
       
        system.debug('emails'+Json.serializePretty(Emails));
        string strRequestBody = String.escapeSingleQuotes(JSON.serialize(Emails));
		string endPoint = 'https://api.sendgrid.com/v3/suppression/bounces';
        system.debug('strRequestBody'+strRequestBody);
          
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('DELETE');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/json');
        String authorizationHeader = Label.SendgridAPIKey;
        system.debug('authorizationHeader'+authorizationHeader) ;      
        request.setHeader('Authorization', authorizationHeader);
        if(String.isNotBlank(strRequestBody)){
           request.setBody('{\"delete_all\": true}');
        }
        
        System.debug('request==='+request);
        //System.debug('strRequestBody===' + strRequestBody);
       if(!Test.isRunningTest()){
        HttpResponse httpResponse = new Http().send(request); 
        System.debug('httpResponse Status===' + httpResponse.getStatus());
        System.debug('httpResponse Status Code===' + httpResponse.getStatusCode());
        System.debug('httpResponse  Body===' + httpResponse.getBody());
       }
       
        
    } 
    
    
}