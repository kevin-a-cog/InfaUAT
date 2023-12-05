/*
* Name         :   helpPaygoCaseController
* Author       :   Deeksha Shetty
* Created Date :   26-AUG-2022
* Description  :   Controller for PayGo-Ability of the users who has subscribed/ on trial period of Simple DI product
and Limitations in creating case for simple DI subscribers

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Deeksha Shetty        26-AUG-2022     Utopia-ph-3         Initial version.                                            NA
*/

public without sharing class helpPaygoCaseController {
    
        /*
    Method      : getmetadatarecords
    Description : This method returns a MetadataWrapper.
    Parameters  : NA
    Return Type : MetadataWrapper
    */
    @AuraEnabled
    public static MetadataWrapper getmetadatarecords(){
        try{
            help_Infa_Custom_Label__mdt record = [SELECT PayGo_Subscription_Products__c, Endpoint__c,PaygoOrgOffercode__c,CalloutUserName__c,
                                                  EsupportCreateCaseURL__c,EsupportManageCaseURL__c,
                                                  CalloutPassword__c FROM help_Infa_Custom_Label__mdt WHERE developerName='Paygo'];
            
            MetadataWrapper mw = new MetadataWrapper();
            mw.CurrentUserEmail = userinfo.getUserEmail();
            mw.Metadata = record;                
            return mw;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
        /*
    Method      : CheckPaygoSubscribedUser
    Description : This method returns CaseButonDisplay wrapper indicating org exists for the trial/ subscribed users, 
    based on which Create/Manage Case Buttons are displayed.
    Parameters  : String, String
    Return Type : CaseButonDisplay
    */
    
    @AuraEnabled
    public static CaseButonDisplay CheckPaygoSubscribedUser(String communityName,String userMail){
        try{
            CaseButonDisplay caseButtons = new CaseButonDisplay();
            
            List<Org_User__c> orgSubscriptionUser = new List<Org_User__c>();
            List<Org__c> userOrg = new List<Org__c>();
            Support_Lite_Product__mdt  product = new Support_Lite_Product__mdt();            
            MetadataWrapper mw = getmetadatarecords();
            
            if(userMail!=null) orgSubscriptionUser = [Select Org__c from Org_User__c where Email__c =:userMail LIMIT 1];
            
            if(orgSubscriptionUser.size()>0) userOrg = [Select OfferCode__c from Org__c where Id=:orgSubscriptionUser[0].Org__c];
            
            if(communityName!=null) product = [SELECT Is_Case_Creation_Allowed__c,Active__c 
                                               FROM Support_Lite_Product__mdt 
                                               WHERE Product_Name_on_Community__c =:communityName LIMIT 1];
            
            if(userOrg.size()>0 && mw.Metadata.PaygoOrgOffercode__c.contains(userOrg[0].OfferCode__c) && product.Is_Case_Creation_Allowed__c && product.Active__c){        
                caseButtons.CreateCaseDisplay = 'showCreateCase';
                caseButtons.ManageCaseDisplay = 'showManageCase';
            }
            else{
                caseButtons.CreateCaseDisplay = 'NoUser';
                caseButtons.ManageCaseDisplay = 'NoUser';
            }
            return caseButtons;            
        }
        catch(Exception e){
            system.debug('Error in CheckPaygoSubscribedUser: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }        
    }
    
    
        /*
    Method      : handleCaseAction
    Description : This method returns a string containing success/ error message.
    Parameters  : String (user Id) 
    Return Type : String.
    */
    
    @AuraEnabled
    public static String handleCaseAction(String userId){
        try{
            MetadataWrapper mw = getmetadatarecords();
            HttpResponse dataResponse;
            String responseString;
            string externalIdentityPid = [Select Id from profile where Name='External Identity Community'].Id;
            String orgUserId = [Select Id from Org_User__c where Email__c=:userinfo.getUserEmail() LIMIT 1].Id ;                        
            Boolean isSupportLiteUser = [Select isSupportLite__c from user where Id=:userinfo.getUserId()].isSupportLite__c;
            System.debug('isSupportLiteUser='+isSupportLiteUser);
            if(isSupportLiteUser){
                responseString = 'isCustomer';
            }
            else{
                EndpointRequestWrapper tempWrap = new EndpointRequestWrapper();            
                tempWrap.orgUser = orgUserId;
                tempWrap.UpgCmtyPlus = (userinfo.getProfileId() == externalIdentityPid) ? 'YES' : 'NO';          
                tempWrap.UserId = userinfo.getUserId();
                String reqBody = JSON.serialize(tempWrap);
                System.debug('reqBody='+reqBody);
                
                Blob headerValue = Blob.valueOf(mw.metadata.CalloutUserName__c + ':' + mw.metadata.CalloutPassword__c);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                
                dataResponse = helpUtilityClass.makeHttpCallout('POST','application/json',mw.metadata.Endpoint__c,
                                                                reqBody,authorizationHeader,'','','','');
                responseString = dataResponse.getStatusCode()==200 ? 'Success' : dataResponse.getBody();                 
                System.debug('responseString='+responseString);                
            }
            
            return responseString;                        
        }
        catch(Exception e){
            system.debug('Error in Create Case: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }        
    }
    
    
    
    public class CaseButonDisplay{
        @AuraEnabled public String CreateCaseDisplay;
        @AuraEnabled public String ManageCaseDisplay;
    }
    
    
    
    public class MetadataWrapper{
        @AuraEnabled public String CurrentUserEmail;
        @AuraEnabled public help_Infa_Custom_Label__mdt Metadata;
    }
    
    public class EndpointRequestWrapper{
        public String orgUser  {get;set;}
        public String UpgCmtyPlus{get;set;}
        public String UserId {get;set;}
    }
    
    
    
    
    
}