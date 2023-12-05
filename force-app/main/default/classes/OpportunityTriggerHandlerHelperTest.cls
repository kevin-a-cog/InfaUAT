/*
Class:          OpportunityTriggerHandlerHelperTest
@Author:        Uday Kumar
@Created Date:  01-APR-2021
@Description:   Test class for OpportunityTriggerHandlerHelper Class.
*/
/*
Change History
************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                      Tag
************************************************************************************************************************************************************************
Uday Kumar         01-APR-2021     SALESRT-12900            To Create OCR's using Bill to, Sold to, End user, Ship to contacts from Primary Quote of Oppty.       T<01>
 

*/

@isTest
public class OpportunityTriggerHandlerHelperTest {

    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    @testSetup
    static void setupObjectTestData(){
        
        sObject sObj = new Account();
        sObject sObj1 = new Account();
       
        //Insert Account data
        UtilityTestData.mAccountData.put('BillingCity', 'test');
        UtilityTestData.mAccountData.put('BillingStreet', 'test');
        UtilityTestData.mAccountData.put('BillingState', 'test');
        UtilityTestData.mAccountData.put('BillingPostalCode', 'test');
        UtilityTestData.mAccountData.put('BillingCountry', 'Switzerland');
        UtilityTestData.mAccountData.put('New_Logo_SPIFF__c','G2K Eligible');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert Contact Data
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        // Insert new Opportunity
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Direct');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','CHF');
        UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');   
        UtilityTestData.mOpportunityData.put('Name', 'OpportunityTriggerHandlerHelperTest1');   
       
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
     
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'OpportunityTriggerHandlerHelperTest2');   
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        // Create OCR to cover the scenario where an opportunity has one OCR role with Billing Contact
        sObj = new OpportunityContactRole();
        sObj1 = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId',lOpportunity[1].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('IsPrimary','true');
        UtilityTestData.mOpportunityContactRoleData.put('Role','End User');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData );
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId',lOpportunity[0].Id);
        sObj1= UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData );
        List<OpportunityContactRole> lOCR= (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1}); 
        
        // Insert new Quote under opportunity 0
        UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('ShipToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('BillToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
        
        
        
        sObj = new SBQQ__Quote__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        
        // Insert new Quote under opportunity 1
        UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('ShipToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('BillToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[1].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
         
        sobj1= new SBQQ__Quote__c();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData); 
        
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sobj1}); 
        
        
        
        
    }
        
    //Update the existing Opportunity for firing the trigger for update operation on Opportunity with the state to Closed Won
    @isTest
    public static void UpdateOpportunity() {
    
        List<Opportunity> lOpportunity = [SELECT Id,StageName FROM Opportunity where Name Like '%OpportunityTriggerHandlerHelperTest%'LIMIT 2];
        List<SBQQ__Quote__c> lQuote = [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 2];
        User userObj = [select Id,Name from User where Name='Deployment Master' and isActive=true limit 1];
        List<Opportunity> OppsToUpdate = new list<Opportunity>();
        system.runAs(userobj){
            Test.StartTest(); 
            if(!lOpportunity.isempty()){
                Opportunity opp1 = new Opportunity(Id = lOpportunity[0].Id);
                opp1.StageName = 'Closed Won';
                opp1.Substage__c = 'Sales Won';
                if(lQuote[0].SBQQ__Opportunity2__c == lOpportunity[0].Id)
                    opp1.SBQQ__PrimaryQuote__c = lQuote[0].Id;
                else
                    opp1.SBQQ__PrimaryQuote__c = lQuote[1].Id;
                OppsToUpdate.add(opp1);
                
                Opportunity opp2 = new Opportunity(Id = lOpportunity[1].Id);
                opp2.StageName = 'Closed Won';
                opp2.Substage__c = 'Sales Won';
               if(lQuote[1].SBQQ__Opportunity2__c == lOpportunity[1].Id)
                    opp2.SBQQ__PrimaryQuote__c = lQuote[1].Id;
                else
                    opp2.SBQQ__PrimaryQuote__c = lQuote[0].Id;
                
                OppsToUpdate.add(opp2);
                try{
                    globalApexManager.allowRun('OpportunityBeforeUpdate');
                    globalApexManager.allowRun('OpportunityAfterUpdate');
                update OppsToUpdate;
                }catch(exception e){
                    System.debug('@@exception'+e.getMessage()+e.getLineNumber()+e.getStackTraceString());
               	 }
            }
            Test.StopTest();
            List<OpportunityContactRole> OCRs = (list<OpportunityContactRole>) UtilityTest.executeQuery('select Id,opportunityId,Role from OpportunityContactRole where opportunityId=\''+lOpportunity[0].Id+'\'');
          
            system.assertEquals(OCRs.size() > 1,true );
             
            List<OpportunityContactRole> OCRs2 = (list<OpportunityContactRole>) UtilityTest.executeQuery('select Id,opportunityId,Role from OpportunityContactRole where opportunityId=\''+lOpportunity[1].Id+'\'');
             
            system.assertEquals(OCRs2.size() > 1,true );
        }
    }  

    @isTest
    Public static void testPriceBookAssignmentInsert(){
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        Contact con = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        sObject sObj = new Opportunity();
        sObject sObj1 = new Opportunity();
        system.runAs(userobj){
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', con.AccountId);
            UtilityTestData.mOpportunityData.put('End_User__c', con.Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
            Test.startTest();
                List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            Test.stopTest();
        }
        List<Opportunity> OCRs2 = (list<Opportunity>) UtilityTest.executeQuery('select Id,CurrencyIsoCode,PriceBook2Id from Opportunity where  AccountId=\''+con.AccountId+'\'');
        system.assertEquals(OCRs2[0].PriceBook2Id, pam.Pricebook_Id__c);
    }
    
    @isTest
    Public static void testPriceBookAssignmentInsertDifferentCurrency(){
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        Contact con = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        sObject sObj = new Opportunity();
        sObject sObj1 = new Opportunity();
        system.runAs(userobj){
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', con.AccountId);
            UtilityTestData.mOpportunityData.put('End_User__c', con.Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'EUR');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
            Test.startTest();
                List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            Test.stopTest();
        }
        List<Opportunity> OCRs2 = (list<Opportunity>) UtilityTest.executeQuery('select Id,CurrencyIsoCode,PriceBook2Id from Opportunity where  AccountId=\''+con.AccountId+'\'');

        system.assertEquals(OCRs2[0].PriceBook2Id, pam.Pricebook_Id__c);
    }

    @isTest
    Public static void testPriceBookAssignmentUpdate(){
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        Contact con = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        sObject sObj = new Opportunity();
        sObject sObj1 = new Opportunity();
        system.runAs(userobj){
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', con.AccountId);
            UtilityTestData.mOpportunityData.put('End_User__c', con.Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);    
            Test.startTest();
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
                lOpportunity[0].CurrencyIsoCode = 'EUR';
            	lOpportunity[0].Pricebook2Id = pam.Pricebook_Id__c;
            	update lOpportunity;
            Test.stopTest();
        }
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Name,AccountId, Account.Name,owner.Name,Fulfillment_Information__c,StageName FROM Opportunity LIMIT 1]);
        Set<Id> oppSet = new Set<Id>();
        for(Opportunity opp:oppMap.values()){
            oppSet.add(opp.Id);
        }
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        Set<Id> accSet = new Set<Id>();
        accSet.add(acc[0].Id);
        AccountTeamMember accTeamMem = new AccountTeamMember();
        accTeamMem.put('TeamMemberRole','CSM');
        accTeamMem.put('AccountId',acc[0].Id);
        accTeamMem.put('UserId',userobj.Id);
        
        OpportunityTriggerHandlerHelper.createChatterPostForCloudAssurance(oppMap,oppSet,accSet);
        List<Opportunity> OCRs2 = (list<Opportunity>) UtilityTest.executeQuery('select Id,CurrencyIsoCode,PriceBook2Id from Opportunity where  AccountId=\''+con.AccountId+'\'');
        system.assertEquals(OCRs2[0].PriceBook2Id, pam.Pricebook_Id__c);
    }
    
    @isTest
    Public static void testPriceBookAssignmentUpdateDefault(){
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        Contact con = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        sObject sObj = new Opportunity();
        sObject sObj1 = new Opportunity();
        system.runAs(userobj){
            Account acc = new Account();
            acc.Id = con.AccountId;
            acc.BillingCountry = 'xyz';
            update acc;
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', con.AccountId);
            UtilityTestData.mOpportunityData.put('End_User__c', con.Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
          	
            Test.startTest();
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            lOpportunity[0].PriceBook2Id = Test.getStandardPricebookId();
            update lOpportunity;
            Test.stopTest();
        }
        List<Opportunity> OCRs2 = (list<Opportunity>) UtilityTest.executeQuery('select Id,CurrencyIsoCode,PriceBook2Id from Opportunity where  AccountId=\''+con.AccountId+'\'');
        system.assertEquals(OCRs2[0].PriceBook2Id, pam.Pricebook_Id__c);
    }
    
    @isTest
    Public static void testPriceBookAssignmentContracts(){
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        Contact con = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        
        
            
        sObject sObj = new Opportunity();
        sObject sObj1 = new Opportunity();
        system.runAs(userobj){
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', con.AccountId);
            UtilityTestData.mOpportunityData.put('End_User__c', con.Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);    
            Test.startTest();
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
                lOpportunity[0].CurrencyIsoCode = 'EUR';
            	lOpportunity[0].Pricebook2Id = pam.Pricebook_Id__c;
            	update lOpportunity;
            Test.stopTest();
        }
        List<Opportunity> OCRs2 = (list<Opportunity>) UtilityTest.executeQuery('select Id,CurrencyIsoCode,PriceBook2Id from Opportunity where  AccountId=\''+con.AccountId+'\'');
        system.assertEquals(OCRs2[0].PriceBook2Id, pam.Pricebook_Id__c);
    }
    
    /*
     Static testMethod void testPriceBookAssignmentUpdateDifferntCurrency(){
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, CurrencyIsoCode from Opportunity limit 2');   
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        List<Opportunity> OppsToUpdate = new list<Opportunity>();
        system.runAs(userobj){
            Test.StartTest(); 
            if(!lOpportunity.isempty()){
                lOpportunity[0].CurrencyIsoCode='EUR';
                lOpportunity[1].CurrencyIsoCode='EUR';
                OppsToUpdate.add(lOpportunity[0]);
                OppsToUpdate.add(lOpportunity[1]);
                Try{
                update OppsToUpdate;
                }catch(exception e){}
            }
            Test.StopTest();
            List<Opportunity> OCRs2 = (list<Opportunity>) UtilityTest.executeQuery('select Id,CurrencyIsoCode,Pricebook2Id from Opportunity where Id=\''+OppsToUpdate[0].Id+'\'');
            system.assertNotEquals(OCRs2[0].PriceBook2Id, pam.Pricebook_Id__c);
        }
    }*/

    @IsTest
    public static void testSpiff(){
        User userObj = [select Id,Name from User where Profile.name='System Administrator' and isActive=true limit 1];
        Contact con = [SELECT Id,AccountId FROM Contact LIMIT 1];
        Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Currency_ISO_Code__c = 'CHF' AND MasterLabel = 'Switzerland' LIMIT 1];
        
        
            
        sObject sObj = new Opportunity();
        sObject sObj1 = new Opportunity();
        system.runAs(userobj){
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', con.AccountId);
            UtilityTestData.mOpportunityData.put('End_User__c', con.Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');

            UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '25');     
        
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
        
            sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);    
            Test.startTest();
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            Test.stopTest();
        }
    }
}