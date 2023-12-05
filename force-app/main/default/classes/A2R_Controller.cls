/****************************************************************************************************************
Class:          A2R_Controller
@Author:        vsabbell
@Created Date:  8/10/2018.
@Description:   Makes a chatter post for SMGHandoff and Updates Notification COunt. Also used as a wrapper to be used for Notify SMG Lightning Component.

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                             Tag
vsabbella            10/09/2018 :                   Change History: Add invokable method to invoke chatter post using process builder. AR 556<T01>
                                                                            
vsabbella            11/29                         Make Chatter post only once after sending email.Pb invokes this class

Venky K             05/04                          AR-1034 To invoke chatter post for incoming email with specific subject <T02>

Ambica              11/17                          Remove Ortoo references <T03>
                                                                                 
                                                                                                                                                                              
*******************************************************************************************************************/

public with sharing class A2R_Controller {

    class customException extends  exception{}
    /*
    * 1 . Controller Method invoked from lightning compoenent
    * 2.  Uses connect API to make a chatter post
    *
    * */

    @AuraEnabled
    public static String invokeNotification(String recordId){
        //A2R_Controller.A2RResponse
        String responseJSON ;
        try{
            CustomPermissionsReader csm = new CustomPermissionsReader();
            if(!csm.hasPermission('CSMUser')){
                Throw New customException('Insufficient Privileges to Notify_SMGs');
            }
            System.debug(LoggingLevel.ERROR,'before  NotifyUsers');
            Boolean postedToChatter = A2RUtils.NotifyUsers(new List<Id>{Id.valueOf(recordId)});
            System.debug(LoggingLevel.ERROR,'After sending: result:'+postedToChatter);
            if(postedToChatter){
                updateCountOfSMGNotification(recordId);
                A2R_Controller.A2RResponse Response = new A2R_Controller.A2RResponse(true);
                Response.addMessage('Posted to Chatter Feed');
                responseJSON = JSON.serialize(Response);
            }else {
                Throw new customException('Error Occurred: Post to chatter was unsuccessful.');
            }
        }
        catch(Exception Ex){
            A2R_Controller.A2RResponse Response = new A2R_Controller.A2RResponse(false);
            Response.addMessage('Error Occurred.'+Ex.getMessage());
            responseJSON = JSON.serialize(Response);
        }
        return responseJSON;
    }

    public static void updateCountOfSMGNotification (String recordId) {
        globalApexManager GAM = new globalApexManager();
        try{
            Related_Opportunity_Plan__c recRelatedPlanOpp = [Select Id,
                    Count_Of_SMG_Notification__c
            FROM Related_Opportunity_Plan__c
            WHERE Id = :Id.valueOf(recordId)];
            recRelatedPlanOpp.Count_Of_SMG_Notification__c =  recRelatedPlanOpp.Count_Of_SMG_Notification__c==null?1:recRelatedPlanOpp.Count_Of_SMG_Notification__c+1;
           update recRelatedPlanOpp;
        }catch(Exception ex){
            GAM.CreateExceptionRecords('A2R_Controller', 'Exception in updateCountOfSMGNotification',ex.getMessage());
        }
        GAM.InsertDebugLogs();
    }

    // <T01>
    @InvocableMethod(label='Chatter Post for SMG Handoff'
                     description='Chatter Post for SMG Handoff')
    public static void invokableSMGHandoffPost(List<ID> ids) {
        globalApexManager GAM = new globalApexManager();
        try{
            
            String Objectname = ids[0].getSobjectType().getDescribe().getname(); 
            /*<T03>
            if(Objectname =='ortoo_e2a__EmailMessage__c' ){
                ortoo_e2a__EmailMessage__c emailMsg = [select id,name,Related_Opportunity_Plan__c,ortoo_e2a__Incoming__c,ortoo_e2a__From_Address__c,ortoo_e2a__Subject__c
                 from ortoo_e2a__EmailMessage__c  
         where Id = :ids[0]];

                if(!emailMsg.ortoo_e2a__Incoming__c &&
                    !String.isBlank(emailMsg.ortoo_e2a__Subject__c)
                    && !(emailMsg.ortoo_e2a__Subject__c.startsWith('RE:')
                    || emailMsg.ortoo_e2a__Subject__c.startsWith('FW:')
             )
              ){
                    String reponse = invokeNotification( emailMsg.Related_Opportunity_Plan__c);
                }
            
            } <T03>*/
            
            if(Objectname =='Related_Opportunity_Plan__c'){
                String reponse = invokeNotification( ids[0]);

            }

        }
        catch(Exception Ex){
            System.debug(LoggingLevel.ERROR, Ex.getMessage());
            GAM.CreateExceptionRecords('A2R_Controller ', 'Exception in invokableSMGHandoffPost',ex.getMessage());
        }
        return;
    }
    
    
    Public class A2RResponse {
        boolean isSuccess;
        String[] Messages;
        String Response;
        public A2RResponse(boolean isSuccess){
            this.isSuccess = isSuccess;
            this.Messages = new String[]{};
        }
        void addMessage(String message){
            if(!String.isBlank(message))
                this.Messages.add(Message);
        }
     
    }
    
}