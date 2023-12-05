/** 
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition. 
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
* 
*  @Author:        RamEsh M S
*  @Created Date:  09/01/2021
*  @Description:   Test class for closeFinancePeriodController with the updated test framework
* Change History
********************************************************************************************************
* ModifiedBy          Date        Requested By        Description                                                       Tag

******************************************************************
*/
@isTest
private class closeFinancePeriodControllerTest {
    
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    private Final static Id FPRecTypId = Schema.SObjectType.blng__FinancePeriod__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
    
    
    @testSetup
    static void setupObjectTestData() {
        
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            sObject sObj = new Account();
            sObject sObj1 = new Account();
            sObject sObj2 = new Account();
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            
            sObj1 = new Account();
            UtilityTestData.mAccountData.put('Name','Testing CloseFP');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            SObj = new blng__FinanceBook__c();
            UtilityTestData.mFinanceBook.put('Name','Booking');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mFinanceBook);
            List<blng__FinanceBook__c> lFinBook = (List<blng__FinanceBook__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Map<Integer,String> MonthName = new Map<Integer,String> {1=>'JAN',2=>'FEB',3=>'MAR',4=>'APR',5=>'MAY',6=>'JUN',7=>'JUL',8=>'AUG',9=>'SEP',10=>'OCT',11=>'NOV',12=>'DEC'};
                
                Date curMonStaDate = Date.Today().toStartOfMonth();
            Date currMonEndDate = curMonStaDate + Date.daysInMonth(curMonStaDate.year(), curMonStaDate.month()) - 1;
            Date preMonEndDate = curMonStaDate - 1;
            Date preMonStaDate = preMonEndDate.toStartOfMonth();
            Date NexMonStaDate = currMonEndDate + 1;
            Date NexMonEndDate = NexMonStaDate + Date.daysInMonth(NexMonStaDate.year(), NexMonStaDate.month()) - 1;
            
            
            SObj = new blng__FinancePeriod__c();
            UtilityTestData.mFinancePeriod.put('blng__PeriodStartDate__c',preMonStaDate+'');
            UtilityTestData.mFinancePeriod.put('blng__PeriodEndDate__c',preMonEndDate+'');
            UtilityTestData.mFinancePeriod.put('Active__c','FALSE');
            UtilityTestData.mFinancePeriod.put('blng__PeriodStatus__c','Closed');
            UtilityTestData.mFinancePeriod.put('blng__FinanceBook__c',lFinBook[0].Id);
            UtilityTestData.mFinancePeriod.put('RecordTypeId',FPRecTypId);
            UtilityTestData.mFinancePeriod.put('Name',MonthName.get(preMonStaDate.month()) + '-' + preMonStaDate.year() + ' : Booking');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mFinancePeriod);
            
            SObj1 = new blng__FinancePeriod__c();
            UtilityTestData.mFinancePeriod.put('blng__PeriodStartDate__c',curMonStaDate+'');
            UtilityTestData.mFinancePeriod.put('blng__PeriodEndDate__c',currMonEndDate+'');
            UtilityTestData.mFinancePeriod.put('Active__c','TRUE');
            UtilityTestData.mFinancePeriod.put('blng__PeriodStatus__c','Open');
            UtilityTestData.mFinancePeriod.put('blng__FinanceBook__c',lFinBook[0].Id);
            UtilityTestData.mFinancePeriod.put('RecordTypeId',FPRecTypId);
            UtilityTestData.mFinancePeriod.put('Name',MonthName.get(curMonStaDate.month()) + '-' + curMonStaDate.year() + ' : Booking');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mFinancePeriod);
            
            SObj2 = new blng__FinancePeriod__c();
            UtilityTestData.mFinancePeriod.put('blng__PeriodStartDate__c',NexMonStaDate+'');
            UtilityTestData.mFinancePeriod.put('blng__PeriodEndDate__c',NexMonEndDate+'');
            UtilityTestData.mFinancePeriod.put('Active__c','FALSE');
            UtilityTestData.mFinancePeriod.put('blng__PeriodStatus__c','Open');
            UtilityTestData.mFinancePeriod.put('blng__FinanceBook__c',lFinBook[0].Id);
            UtilityTestData.mFinancePeriod.put('RecordTypeId',FPRecTypId);
            UtilityTestData.mFinancePeriod.put('Name',MonthName.get(NexMonStaDate.month()) + '-' + NexMonStaDate.year() + ' : Booking');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mFinancePeriod);
            
            List<blng__FinancePeriod__c> lFinPeriod = (List<blng__FinancePeriod__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            Test.startTest();
            
            
            sObj = new Order();
            sObj1 = new Order();
            
            UtilityTestData.mOrderData.put('Name','Finance Period Testing 1');
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            UtilityTestData.mOrderData.put('Generate_Date__c',Date.Today() + ''); 
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
            
            UtilityTestData.mOrderData.put('Name','Finance Period Testing 2');
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            UtilityTestData.mOrderData.put('Generate_Date__c',Date.Today() + ''); 
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderData);
            
            UtilityTestData.mOrderData.put('Name','Finance Period Testing 3');
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            UtilityTestData.mOrderData.put('Generate_Date__c',Date.Today() + ''); 
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
            
            List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            List<Id> orderIDs = new List<Id> ();
            
            for(Order ord : lOrder)
            {
                orderIDs.add(ord.Id);   
            }
            
            SBQQ.TriggerControl.disable();
            OrderTriggerHandler.calculateFP(orderIDs,null);
            SBQQ.TriggerControl.enable();
            
            Test.stopTest();
        }
    }   
    
    
    @isTest
    Static void populateFP() {
        
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            Date curMonStaDate = Date.Today().toStartOfMonth();
            Date currMonEndDate = curMonStaDate + Date.daysInMonth(curMonStaDate.year(), curMonStaDate.month()) - 1;
            Date preMonEndDate = curMonStaDate - 1;
            Date preMonStaDate = preMonEndDate.toStartOfMonth();
            Date NexMonStaDate = currMonEndDate + 1;
            Date NexMonEndDate = NexMonStaDate + Date.daysInMonth(NexMonStaDate.year(), NexMonStaDate.month()) - 1;
            
            List<Order> lOrder = [Select Id, Status from Order where Account.Name = 'Testing CloseFP' Limit 3];
            
            
            
            Test.startTest();
            
            sObject sObjOrder = new Order(id = lOrder[0].Id);
            UtilityTestData.mOrderData.put('Generate_Date__c',NexMonStaDate + ''); 
            sObjOrder = UtilityTest.putFieldRecord(sObjOrder, UtilityTestData.mOrderData);
            
            SBQQ.TriggerControl.disable();
            List<Order> lOrderUpdated1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObjOrder});
            SBQQ.TriggerControl.enable();
            
            Test.stopTest();
            
            List<blng__FinancePeriod__c> FPList = [Select Id,Active__c,blng__PeriodStatus__c from blng__FinancePeriod__c where blng__FinanceBook__r.Name = 'Booking' AND RecordType.Name = 'Booking'];
            
            for(blng__FinancePeriod__c Fp : FPList)
            {
                if(FP.Active__c && FP.blng__PeriodStatus__c == 'Open')
                {
                    closeFinancePeriodController.closeAndMoveOrders(FP.Id,Date.Today());
                    break;
                }
            }
            
            
            
        }
    }
    
}