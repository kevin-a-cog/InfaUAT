///addressICRTControllerExtensionTest
@isTest
public class addressICRTControllerExtensionTest {
    
    @isTest
    static void testMethod1(){
        PageReference pageRef = new pageReference('/apex/updateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'SBQQ__Quote__c');
        pageRef.getParameters().put('addresstype','billing');
        Test.setCurrentPage(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension(); 
        System.assertEquals('BillToAddressCleanse', testPage.GuideName);
    }
    
    @isTest
    static void testMethod2(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'SBQQ__Quote__c');
        pageRef.getParameters().put('addresstype','shipping');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('ShipToAddressCleanse', testPage.GuideName);
    }
    
    @isTest
    static void testMethod3(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'SBQQ__Quote__c');
        pageRef.getParameters().put('addresstype','enduser');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('EndToAddressCleanse', testPage.GuideName);
    }
    
    @isTest
    static void testMethod4(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'SBQQ__Quote__c');
        pageRef.getParameters().put('addresstype','soldto');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('SoldToAddressCleanse', testPage.GuideName);
    }
    
    @isTest
    static void testMethod5(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'SBQQ__Quote__c');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('', testPage.GuideName);
    }
    
    @isTest
    static void testMethodOrder1(){
        PageReference pageRef = new pageReference('/apex/updateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'Order');
        pageRef.getParameters().put('addresstype','billing');
        Test.setCurrentPage(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension(); 
        System.assertEquals('BillToAddressCleanseOrder', testPage.GuideName);
    }
    
    @isTest
    static void testMethodOrder2(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'Order');
        pageRef.getParameters().put('addresstype','shipping');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('ShipToAddressCleanseOrder', testPage.GuideName);
    }
    
    @isTest
    static void testMethodOrder3(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'Order');
        pageRef.getParameters().put('addresstype','enduser');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('EndToAddressCleanseOrder', testPage.GuideName);
    }
    
    @isTest
    static void testMethodOrder4(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'Order');
        pageRef.getParameters().put('addresstype','soldto');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('SoldToAddressCleanseOrder', testPage.GuideName);
    }
    
    @isTest
    static void testMethodOrder5(){
        PageReference pageRef = new pageReference('/apex/UpdateAddressIcrt');
        pageRef.getParameters().put('objectid', 'a1qDR000000v1R1YAI');
        pageRef.getParameters().put('objectname', 'Order');
        test.setCurrentPageReference(pageRef);
        addressICRTControllerExtension testPage = new addressICRTControllerExtension();  
        System.assertEquals('', testPage.GuideName);
    }
}