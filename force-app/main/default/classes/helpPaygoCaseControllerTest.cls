@isTest
public class helpPaygoCaseControllerTest {
    
    static testmethod void test_method1(){
        Account acc = new Account(Name='Test Acc',BillingCountry='USA');
        insert acc;
        
        Contact con = new Contact(AccountId= acc.Id,FirstName ='Test',LastName = 'Contact',email = 'testuser@informatica.com');
        insert con;
        
        Org__c org = new Org__c(Support_Lite_End_Date__c = System.today()+5,OfferCode__c='cdi-generic-free');
        insert org;
        
        Org_User__c orgUser = new Org_User__c(Org__c = org.Id,Contact__c = con.Id);
        insert orgUser;
        
        help_Infa_Custom_Label__mdt record = [SELECT PayGo_Subscription_Products__c 
                                              FROM help_Infa_Custom_Label__mdt WHERE developerName='Paygo']; //data loader
      
        test.startTest();
        helpPaygoCaseController.getmetadatarecords();
        try{
            helpPaygoCaseController.CheckPaygoSubscribedUser(record.PayGo_Subscription_Products__c,'testuser@informatica.com');
        }
        Catch(Exception ex){}        
        test.stopTest();
        
    }
    
    
    static testmethod void test_method2(){
       help_Infa_Custom_Label__mdt record = [SELECT PayGo_Subscription_Products__c, Endpoint__c,PaygoOrgOffercode__c,CalloutUserName__c,
                                                  EsupportCreateCaseURL__c,EsupportManageCaseURL__c,
                                                  CalloutPassword__c FROM help_Infa_Custom_Label__mdt WHERE developerName='helpIdea'];
        
        Support_Lite_Product__mdt testrec = new Support_Lite_Product__mdt();
        testrec.Is_Case_Creation_Allowed__c = false;
        
        
        test.startTest();
        try{
            helpPaygoCaseController.CheckPaygoSubscribedUser('testrec','testuser@informatica.com');
        }
        Catch(Exception ex){}        
        
        test.stopTest();
        
    }
    
    static testmethod void testmethod3(){
        test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new helpPaygoCAICalloutMock());
            helpPaygoCaseController.handleCaseAction(userinfo.getUserId()); 
        }
        Catch(Exception ex){}
        test.stopTest();
    }
    
    
    
    static testmethod void testmethod4(){
        Account acc = new Account(Name='Test Acc',BillingCountry='USA');
        insert acc;
        
        Contact con = new Contact(AccountId= acc.Id,FirstName ='Test',LastName = 'Contact',email = 'testuser@informatica.com');
        insert con;
        
        Org__c org = new Org__c(Support_Lite_End_Date__c = System.today()+5);
        insert org;
        
        Org_User__c orgUser = new Org_User__c(Org__c = org.Id,Contact__c = con.Id);
        orgUser.Email__c = userinfo.getUserEmail();
        insert orgUser;
        
        test.startTest();        
        try{
            Test.setMock(HttpCalloutMock.class, new helpPaygoCAICalloutMock());
            helpPaygoCaseController.handleCaseAction(userinfo.getUserId()); 
        }
        Catch(Exception ex){}
        test.stopTest();
    }

}