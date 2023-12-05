/*
 Class:  TempEmailServiceClass
        @Author:        Ambica Pyati
        @Created Date:  11/21/2018
        @Description:   dummy Email service class used to generate email address.
*/

global class TempEmailServiceClass implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
 
    // Create an InboundEmailResult object for returning the result of the Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
  
   // Do nothing
     
   // Return the result for the Apex Email Service
   return result;
  }
}