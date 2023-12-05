/*
Class:          LinkUtility_Controller 
@Author:        Anil Sahu  
@Created Date:  18 may 2021
@Description:   Controller class for Quicklinks Lightning web component
This controller holds method for fetching the URL for a logged-in users/customer 
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
public without sharing class LinkUtility_Controller {
    public WrapperQicklinks objWrapperQicklinks{get;set;}//store link info
    public static globalApexManager GAM = new globalApexManager(); 
    public LinkUtility_Controller(){
        
        objWrapperQicklinks=new WrapperQicklinks(); 
    }
    
    //fetch all configurable data for Quicklinks
    @AuraEnabled(cacheable=true)
    public static List<WrapperQicklinks> getQuicklinkInfo(){
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        List<WrapperQicklinks> lstwrpper=new List<WrapperQicklinks>();
        try{
            Boolean isSupportAcc=false;
            for(AccountcontactRelation VarACR:[select AccountID from AccountcontactRelation 
                                               where contactid = : currentUser.ContactId
                                               and IsActive=:true ]){
                                                   isSupportAcc=true;//set true id
                                               }
            System.debug(' ACR '+isSupportAcc);
            WrapperQicklinks objwrapQlink;
            string strqlink='eSupport';
            map<string,string> mapGrupName=new  map<string,string>();
            //fetch metadata config values
            List<Link_Utility__mdt> lstLinkUtilities = [Select Id,Group_Name__c,Icon__c,Sort_Order__c from Link_Utility__mdt order by Sort_Order__c ASC];
            for(Link_Utility__mdt vamdt:lstLinkUtilities){ 
                mapGrupName.put(vamdt.Group_Name__c,vamdt.Group_Name__c);//
            }
            //bind the list with all method names   
            list<string> lstQlinks= new list<string>{'QuickLinks'};//add link information
                for(Link__c varQlnk:[Select Id,Name,Link_URL__c,Target__c,Group_Name__c,Skills__c,
                                     Public_Groups__c,Applications__c from Link__c where Group_Name__c=: strqlink and 
                                     ((Start_date__c = null and End_date__c = null) or  (End_date__c > TODAY and Start_date__c < TODAY))]){
                                         objwrapQlink= new WrapperQicklinks();
                                         objwrapQlink.isBlnSUpportAcc=isSupportAcc;
                                         objwrapQlink.objlnk=varQlnk;
                                         if(mapGrupName.get(varQlnk.Group_Name__c)!=null)
                                             lstwrpper.add(objwrapQlink);//add value to list
                                     }
        }catch(Exception e){
            GAM.CreateExceptionRecords('LinkUtility_Controller-getQuicklinkInfo', e.GetMessage(), userinfo.getUserId());
        }
        System.debug(' lstwrapper '+lstwrpper);
        return lstwrpper;
    }
    public class WrapperQicklinks{
        @AuraEnabled
        public boolean isBlnSUpportAcc{get;set;}
        @AuraEnabled
        public link__c objlnk{get;set;}
    }
}