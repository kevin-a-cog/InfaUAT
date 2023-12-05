/*
Class:          GetInfoPanoptaAPITest
@Author:        Venky K
@Created Date:  30-Sep-2021
@Description:   Test class for GetInfoPanoptaAPI, PanoptaUserResponseWrapper class. 

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest   
public class GetInfoPanoptaAPITest {
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;
        
        
        //Create a Account record
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create a Incident record
        
        sobj = new  Incident__c(Account__c=lAccount[0].Id,Duration_of_the_Incident__c='10',Instance_Name__c='Test',Status__c='Active');
        insert sobj;
    }
    
    public static testmethod void testcheckuser(){
        
        String userid = String.valueof(UserInfo.getUserId());        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        String returnresponse = GetInfoPanoptaAPI.checkuser(userid);      
        Test.stopTest();
    }
    
    public static testmethod void setIncidentSummary(){
        
        String userid = String.valueof(UserInfo.getUserId());        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        GetInfoPanoptaAPI.setIncidentSummary('test','test',userid);      
        Test.stopTest();
    }
    
    public static testmethod void acknowledgeIncident(){
        
        String userid = String.valueof(UserInfo.getUserId());        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        GetInfoPanoptaAPI.acknowledgeIncident(userid,'test','test');      
        Test.stopTest();
    }
    
    public static testmethod void setIncidentLead(){
        
        String userid = String.valueof(UserInfo.getUserId());        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        GetInfoPanoptaAPI.setIncidentLead(userid,'test','test');      
        Test.stopTest();
    }
    
    public static testmethod void postOutageLog(){
        
        String userid = String.valueof(UserInfo.getUserId());        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        GetInfoPanoptaAPI.postOutageLog(userid,'test','test');      
        Test.stopTest();
    }   
    
    public static testmethod void testPanoptaUserResponseWrapper(){
        String jsonoutput = '{"meta": {"limit": 50, "next": null, "offset": 0, "previous": null, "total_count": 1}, "user_list":[{"allow_non_sso_login": true, "avatar_url":"https://secure.gravatar.com/avatar/183a73234ca2e160c4577bba84f66cae.jpg?d=mm", "contact_info": [{"detail":"appintegration@informatica.com", "extra_data": null, "info": "appintegration@informatica.com", "label": "SFDCUser","name": "SFDCIntegrationUser", "type": "https://api2.panopta.com/v2/contact_type/61", "url":"https://api2.panopta.com/v2/contact/346576/contact_info/395098"}], "created": "Wed, 12 May 2021 14:29:52 -0000","default_dashboard": null, "display_name": "SFDCIntegrationUser", "is_external_user": false, "roles":["https://api2.panopta.com/v2/role/389"], "server_group_access": "selected", "server_groups": [], "tags": [],"timezone": "https://api2.panopta.com/v2/timezone/America/Los_Angeles", "url":"https://api2.panopta.com/v2/user/202374", "username": "appintegration@informatica.com"}]}';
        PanoptaUserResponseWrapper returnresp =  PanoptaUserResponseWrapper.parse(jsonoutput);
    }

}