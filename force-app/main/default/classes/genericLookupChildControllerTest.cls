/*
Class:  genericLookupChildControllerTest
@Author:        Chandana Gowda
@Created Date:  02 Jun 2019
@Description:   Test Class for genericLookupChildController Class.

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
Chandana Gowda        30-Oct-2019       AR-1016       Handle the change of return type in the function
getFields                                               T1
ambica                  11/17/20                       Removed ortoo referenes                        <T02>
*************************************************************************************************************************************
*/
@isTest
public class genericLookupChildControllerTest {
    
    @testSetup
    static void setupObjectTestData() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Opportunity
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
        sObject Opty = new Opportunity();
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});
        
        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});
        
        //Account Product
        UtilityTestData.mAccountProduct.put('Account__c',lAccount[0].Id);
        sObject AccProd = new Account_Product__c();
        AccProd = UtilityTest.putFieldRecord(AccProd, UtilityTestData.mAccountProduct);
        List<Account_Product__c> lAccProd = (List<Account_Product__c>) UtilityTest.makeInsert(new List<sObject>{AccProd});         
        
        /*<T02>
        //e2a Business Unit
        sObject e2aBusinessUnit = new ortoo_e2a__Business_Unit__c();
        e2aBusinessUnit = UtilityTest.putFieldRecord(e2aBusinessUnit, UtilityTestData.me2aBusinessUnit);
        List<ortoo_e2a__Business_Unit__c> le2aBusinessUnit = (List<ortoo_e2a__Business_Unit__c>) UtilityTest.makeInsert(new List<sObject>{e2aBusinessUnit}); 
       </T02> */
        
        //Plan
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Outcome Based Success Plan').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        //Related Account Products
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account_Product__c',lAccProd[0].Id);
        sObject relAccProd = new Related_Account_Plan__c();
        relAccProd = UtilityTest.putFieldRecord(relAccProd, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lRelAccProd = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relAccProd}); 
        
        //Related opportunity Plan(Interlock)
        UtilityTestData.mRelatedOpportunityPlan.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('Opportunity__c',lOpty[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObject relOptyPlan = new Related_Opportunity_Plan__c();
        relOptyPlan = UtilityTest.putFieldRecord(relOptyPlan, UtilityTestData.mRelatedOpportunityPlan);        
        List<Related_Opportunity_Plan__c> lRelOptyPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relOptyPlan});
        
        //Related Opportunity Product(Interlock Product)
        UtilityTestData.mRelatedOpportunityProduct.put('Related_Opportunity_Plan__c',lRelOptyPlan[0].Id);
        UtilityTestData.mRelatedOpportunityProduct.put('Account_Product__c',lAccProd[0].Id);
        sObject relOptyProd = new Engagement_Product__c();
        relOptyProd = UtilityTest.putFieldRecord(relOptyProd, UtilityTestData.mRelatedOpportunityProduct);
        List<Engagement_Product__c> lRelOptyProd = (List<Engagement_Product__c>) UtilityTest.makeInsert(new List<sObject>{relOptyProd});
        }
        
    } 
    
    /* static testMethod void testhasCSMPermission() {
User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
System.RunAs(u1) {
test.StartTest();
Boolean Res = genericLookupChildController.hasCSMPermission();
system.assertEquals(Res,TRUE);
test.stopTest();
}
}*/
    
    static testMethod void testgetRelationshipNames() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            String relName = genericLookupChildController.getRelationshipNames('Related_Opportunity_Plan__c','Plan__c');
            system.assertEquals(relName,'Plan__r');
            test.stopTest();
        }
    }
    static testMethod void testSaveRelatedOptyproduct() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            Generic_Lookup__mdt mdtRec = genericLookupChildController.getParams('Add Product');
            String searchKeyWord='';
            List<Sobject> pillsList=[Select id,Forecast_Product__c,Name,Status__c  from Related_Account_Plan__c];//null;
            String Child2Object='Related_Opportunity_Plan__c';
            String Child2ParentRelationship='Plan__r';
            String Child1JunctionSourceObjField=mdtRec.Child1JunctionSourceObjField__c;
            String JunctionObject=mdtRec.JunctionObject__c;
            String Child1Object=mdtRec.Child1Object__c;
            String Child1ParentField=mdtRec.Child1ParentField__c;
            String searchFieldName=mdtRec.searchFieldName__c;
            String JunctionField2=mdtRec.JunctionField2__c;
            String JunctionField1=mdtRec.JunctionField1__c;
            String Child2ParentField=mdtRec.Child2ParentField__c;
            String JunctionField1SourceObj=mdtRec.JunctionField1SourceObj__c;
            String fieldSetName=mdtRec.fieldSetName__c;
            String filterCriteria='End_Date__c >= today'; //mdtRec.Filter_Criteria__c;
            String queryString='Forecast_Product__c,'+'Name,'+'Status__c ';
            Id parentId=[Select Id from Related_Opportunity_Plan__c LIMIT 1].Id;              
            
            List<String> permissionSetLst = new List<String>();
            genericLookupChildController.hasCSMPermission(permissionSetLst);
            //-------------------------------------------------------------------------<T1>
            Map<String,List<String>> fsml = new Map<String,List<String>>();
            fsml = genericLookupChildController.getFields(Child1Object,fieldSetName,JunctionField1SourceObj);
            //-------------------------------------------------------------------------</T1>
            List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,  queryString, parentId,  Child2Object, Child2ParentRelationship, Child1JunctionSourceObjField, JunctionObject, Child1Object, Child1ParentField, searchFieldName, JunctionField2, JunctionField1, Child2ParentField, JunctionField1SourceObj, filterCriteria);
            
            //List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,queryString,parentId,Child2Object,Child2ParentRelationship,Child1JunctionSourceObjField,JunctionObject,Child1Object,Child1ParentField,searchFieldName,JunctionField2,JunctionField1,Child2ParentField,JunctionField1SourceObj,filterCriteria);
            genericLookupChildController.saveSelectedLOBContacts(objList,parentId,Child2Object,JunctionField2,JunctionField1,JunctionObject);
            test.stopTest();
        }
    }
    
    
    
    
       static testMethod void testSaveRelatedOptyproduct1() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            Generic_Lookup__mdt mdtRec = genericLookupChildController.getParams('Add Product');
            String searchKeyWord='';
            List<Sobject> pillsList=null;
            String Child2Object='Related_Opportunity_Plan__c';
            String Child2ParentRelationship='Plan__r';
            String Child1JunctionSourceObjField=mdtRec.Child1JunctionSourceObjField__c;
            String JunctionObject=mdtRec.JunctionObject__c;
            String Child1Object=mdtRec.Child1Object__c;
            String Child1ParentField=mdtRec.Child1ParentField__c;
            String searchFieldName=mdtRec.searchFieldName__c;
            String JunctionField2=mdtRec.JunctionField2__c;
            String JunctionField1=mdtRec.JunctionField1__c;
            String Child2ParentField=mdtRec.Child2ParentField__c;
            String JunctionField1SourceObj=mdtRec.JunctionField1SourceObj__c;
            String fieldSetName=mdtRec.fieldSetName__c;
            String filterCriteria=mdtRec.Filter_Criteria__c;
            String queryString='Forecast_Product__c,'+'Name,'+'Status__c ';
            Id parentId=[Select Id from Related_Opportunity_Plan__c LIMIT 1].Id;              
            string CSMCUSTOMPERMISSION ='CSMUser'; 
             List<String> permissionSetLst = new List<String>();
             permissionSetLst.add(CSMCUSTOMPERMISSION);   
             genericLookupChildController.hasCSMPermission(permissionSetLst);
            //-------------------------------------------------------------------------<T1>
            Map<String,List<String>> fsml = new Map<String,List<String>>();
            //fsml = genericLookupChildController.getFields(Child1Object,fieldSetName,JunctionField1SourceObj);
            //-------------------------------------------------------------------------</T1>
            List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,  queryString, parentId,  Child2Object, Child2ParentRelationship, Child1JunctionSourceObjField, JunctionObject, Child1Object, Child1ParentField, searchFieldName, JunctionField2, JunctionField1, Child2ParentField, JunctionField1SourceObj, filterCriteria);
            
            //List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,queryString,parentId,Child2Object,Child2ParentRelationship,Child1JunctionSourceObjField,JunctionObject,Child1Object,Child1ParentField,searchFieldName,JunctionField2,JunctionField1,Child2ParentField,JunctionField1SourceObj,filterCriteria);
           // genericLookupChildController.hasCSMPermission(objList);
            test.stopTest();
        }
    }
    
    static testMethod void testSaveRelatedOptyproduct3() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            Generic_Lookup__mdt mdtRec = genericLookupChildController.getParams('Add Product');
            String searchKeyWord='';
            List<Sobject> pillsList=null;
            String Child2Object='Related_Opportunity_Plan__c';
            String Child2ParentRelationship='Plan__r';
            String Child1JunctionSourceObjField=mdtRec.Child1JunctionSourceObjField__c;
            String JunctionObject=mdtRec.JunctionObject__c;
            String Child1Object=mdtRec.Child1Object__c;
            String Child1ParentField=mdtRec.Child1ParentField__c;
            String searchFieldName=mdtRec.searchFieldName__c;
            String JunctionField2=mdtRec.JunctionField2__c;
            String JunctionField1=mdtRec.JunctionField1__c;
            String Child2ParentField=mdtRec.Child2ParentField__c;
            String JunctionField1SourceObj=mdtRec.JunctionField1SourceObj__c;
            String fieldSetName=mdtRec.fieldSetName__c;
            String filterCriteria=mdtRec.Filter_Criteria__c;
            String queryString='Forecast_Product__c,'+'Name';
            Id parentId=[Select Id from Related_Opportunity_Plan__c LIMIT 1].Id;              
            string CSMCUSTOMPERMISSION ='CSMUser'; 
             List<String> permissionSetLst = new List<String>();
             permissionSetLst.add(CSMCUSTOMPERMISSION);   
             genericLookupChildController.hasCSMPermission(permissionSetLst);
             //-------------------------------------------------------------------------<T1>
           // Map<String,List<String>> fsml = new Map<String,List<String>>();
            //fsml = genericLookupChildController.getFields(Child1Object,fieldSetName,JunctionField1SourceObj);
            //-------------------------------------------------------------------------</T1>
            List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,  queryString, parentId,  Child2Object, Child2ParentRelationship, Child1JunctionSourceObjField, JunctionObject, Child1Object, Child1ParentField, searchFieldName, JunctionField2, JunctionField1, Child2ParentField, JunctionField1SourceObj, filterCriteria);
            
           // List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,queryString,parentId,Child2Object,Child2ParentRelationship,Child1JunctionSourceObjField,JunctionObject,Child1Object,Child1ParentField,searchFieldName,JunctionField2,JunctionField1,Child2ParentField,JunctionField1SourceObj,filterCriteria);
           // genericLookupChildController.hasCSMPermission(objList);
            test.stopTest();
        }
    } 
    
    
    
    
    
    static testMethod void testRelatedAccProd() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            Generic_Lookup__mdt mdtRec = genericLookupChildController.getParams('Add Account Product');
            String searchKeyWord='';
            List<Sobject> pillsList=null;
            String Child2Object='Plan__c';
            String Child2ParentRelationship='Account__r';
            String Child1JunctionSourceObjField=mdtRec.Child1JunctionSourceObjField__c;
            String JunctionObject=mdtRec.JunctionObject__c;
            String Child1Object=mdtRec.Child1Object__c;
            String Child1ParentField=mdtRec.Child1ParentField__c;
            String searchFieldName=mdtRec.searchFieldName__c;
            String JunctionField2=mdtRec.JunctionField2__c;
            String JunctionField1=mdtRec.JunctionField1__c;
            String Child2ParentField=mdtRec.Child2ParentField__c;
            String JunctionField1SourceObj=mdtRec.JunctionField1SourceObj__c;
            String fieldSetName=mdtRec.fieldSetName__c;
            String filterCriteria= mdtRec.Filter_Criteria__c;
            String queryString='Forecast_Product__c,'+'Name,'+'Status__c,'+'Related_Asset_Identifier__c ';
            Id parentId=[Select Id from Plan__c LIMIT 1].Id;    
            
           
            //-------------------------------------------------------------------------<T1>
            Map<String,List<String>> fsml = new Map<String,List<String>>();
            fsml = genericLookupChildController.getFields(Child1Object,fieldSetName,JunctionField1SourceObj);
            //-------------------------------------------------------------------------</T1>
            List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,queryString,parentId,Child2Object,Child2ParentRelationship,Child1JunctionSourceObjField,JunctionObject,Child1Object,Child1ParentField,searchFieldName,JunctionField2,JunctionField1,Child2ParentField,JunctionField1SourceObj,filterCriteria);
            genericLookupChildController.saveSelectedLOBContacts(objList,parentId,Child2Object,JunctionField2,JunctionField1,JunctionObject);
            test.stopTest();
        }
       } 
    
     static testMethod void testRelatedAccProd1() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            Generic_Lookup__mdt mdtRec = genericLookupChildController.getParams('Add Product');
            String searchKeyWord='';
           
            String Child2Object='Plan__c';
            String Child2ParentRelationship='Account__r';
            String Child1JunctionSourceObjField=mdtRec.Child1JunctionSourceObjField__c;
            String JunctionObject=mdtRec.JunctionObject__c;
            String Child1Object=mdtRec.Child1Object__c;
            String Child1ParentField=mdtRec.Child1ParentField__c;
            String searchFieldName=mdtRec.searchFieldName__c;
            String JunctionField2=mdtRec.JunctionField2__c;
            String JunctionField1=mdtRec.JunctionField1__c;
            String Child2ParentField=mdtRec.Child2ParentField__c;
            String JunctionField1SourceObj='Related_Account_Plan__c';//mdtRec.JunctionField1SourceObj__c;
            String fieldSetName=mdtRec.fieldSetName__c;
            String filterCriteria= mdtRec.Filter_Criteria__c;
            String queryString='Forecast_Product__c,'+'Name,'+'Status__c,'+'Related_Asset_Identifier__c ';
            Id parentId=[Select Id from Plan__c LIMIT 1].Id;   
            
            Account objAccount = new Account();
            objAccount.Name = 'Test';
            objAccount.BillingCountry = 'US';
            insert objAccount;
            Plan__c objPlan = new Plan__c();
            
            Contact cont = new Contact();
            cont.FirstName='Test';
            cont.LastName='Test';
            cont.Accountid= objAccount.id;
            insert cont;
            
            objPlan.Name = 'TestNew';
            objPlan.Is_Template__c = false;
            objPlan.Account__c = objAccount.Id;
            insert objPlan;
            
            List<Sobject> lobContactRecords= new  List<Sobject>();
            lobContactRecords.add(cont);
            List<Sobject> pillsList= new List<Sobject>();
            pillsList.add(cont);
            //-------------------------------------------------------------------------<T1>
            Map<String,List<String>> fsml = new Map<String,List<String>>();
            fsml = genericLookupChildController.getFields(Child1Object,fieldSetName,JunctionField1SourceObj);
            //-------------------------------------------------------------------------</T1>
            //List<sObject> objList= genericLookupChildController.contactSearchBar(searchKeyWord,pillsList,queryString,parentId,Child2Object,Child2ParentRelationship,Child1JunctionSourceObjField,JunctionObject,Child1Object,Child1ParentField,searchFieldName,JunctionField2,JunctionField1,Child2ParentField,JunctionField1SourceObj,filterCriteria);
             genericLookupChildController.saveSelectedLOBContacts(lobContactRecords,parentId,Child2Object,JunctionField2,JunctionField1,JunctionObject);
             genericLookupChildController.updateSelected(lobContactRecords,pillsList,'custom');
            test.stopTest();
        }
       }
    static testMethod void testSaveRelatedOptyproduct6() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
             Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Related_Opportunity_Plan__c');
             Schema.FieldSet fs;
             Schema.DescribeSObjectResult describe = targetType.getDescribe();
             Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
             fs = fsMap.get('PlanInterlock');
             List<Schema.FieldSetMember> fieldSet = fs.getFields();
             List<genericLookupChildController.FieldSetMember> fset = new List<genericLookupChildController.FieldSetMember>();
            for(Schema.FieldSetMember fsMember:fieldSet){
             fset.add(new genericLookupChildController.FieldSetMember(fsMember));
            }
            test.stopTest();
        }
    } 
}