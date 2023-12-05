/*
Class:  TempEmailServiceClassTest
        @Author:        Ambica Pyati
        @Created Date:  11/21/2018
        @Description:   Test Class for TempEmailServiceClass.
*/
@isTest
private class TempEmailServiceClassTest{

    static testMethod void myUnitTest() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env   = new Messaging.InboundEnvelope();
        // call the email service class
        TempEmailServiceClass tempesc = new TempEmailServiceClass();
        tempesc.handleInboundEmail(email, env);
    }
}