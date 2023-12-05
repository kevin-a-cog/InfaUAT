@isTest
public class addressDependentPicklistControllerTest {
    private static List<Schema.SObjectType> mySObjects = new Schema.SObjectType[] {
                                                            Account.SObjectType,
                                                            Opportunity.SObjectType,
                                                            pse__Region__c.SObjectType,
                                                            Contact.SObjectType,
                                                            pse__Proj__c.SObjectType,
                                                            pse__Project_Location__c.SObjectType,
                                                            AddressMatrix__c.SObjectType
                                                        };
    @testSetup
    private static void createTestData(){
        UnitOfWork uow = new UnitOfWork(mySObjects);
        User userObj = [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
        System.runAs(userObj){
            //Create Account
            Account acc = new Account(Name = 'Test Account', RecordTypeId = AccRecType.Id, BillingCountry = 'India');
            uow.registerNew(acc);
            
            //Create Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opp', CloseDate = System.today().addDays(30), Type = 'Direct', StageName = 'Validate', CurrencyIsoCode = 'USD',
                                              psa_om_Start_Date__c = System.today(), psa_om_End_Date__c = System.today().addDays(10),
                                              psa_om_IPS_Package__c = 'JumpStart: Enterprise Data Preparation',
                                              PSA_OM_Project_Type__c = 'JumpStart');
            uow.registerNew(opp, Opportunity.AccountId, acc);

            //Create Region 
            pse__Region__c region = new pse__Region__c(Name = 'Test Region-1');
            uow.registerNew(region); 

            //Create Contact
            Contact con = new Contact(LastName = 'Test Contact' ,pse__Resource_Role__c = 'Regional Manager', pse__Is_Resource__c = true,RecordTypeId = rt.Id,
                    Is_Primary__c = false, pse__Is_Resource_Active__c = true, pse__Default_Cost_Rate__c = 10,psa_Employee_Type__c = 'Informatica-Non PS',
                    pse__Salesforce_User__c = userObj.Id);
            uow.registerRelationship(con, Contact.pse__Region__c, region);
            uow.registerNew(con, Contact.AccountId, acc);
            
            //Create Project
            pse__Proj__c proj = new pse__Proj__c(pse__Project_Type__c = 'Customer Project',psa_pm_Project_Sub_Type__c = 'JumpStart',
                pse__Is_Active__c = true, psa_pm_Require_Product_On_Timecards__c = false, pse__Start_Date__c = System.today().addDays(-6), 
                pse__End_Date__c = System.today().addDays(10), pse__Allow_Self_Staffing__c = true, psa_pm_Expense_Approval_Method__c = 'Auto-Approve');
            uow.registerRelationship(proj, pse__Proj__c.pse__Project_Manager__c, con);
            uow.registerRelationship(proj, pse__Proj__c.pse__Opportunity__c, opp);
            uow.registerNew(proj, pse__Proj__c.pse__Account__c, acc); 

            //Create Project Location
            pse__Project_Location__c projLoc = new pse__Project_Location__c(psa_pm_Primary__c = true, PSA_Work_Country__c = 'India', 
                                                PSA_PM_Work_State__c = 'Karnataka', psa_PM_Work_City__c = 'Bangalore');
            uow.registerNew(projLoc, pse__Project_Location__c.pse__Project__c, proj);
            
            //Create Address Matrix
            AddressMatrix__c address = new AddressMatrix__c(Is_Active__c=true,Country__c='India',State__c='Karnataka',City__c='Bengaluru');
        	uow.registerNew(address);
            
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }
    }    
    
    @isTest
    private static void testLWCmethods(){
        List<pse__Project_Location__c> lProjectLoc = [SELECT Id FROM pse__Project_Location__c LIMIT 1];
        
        addressDependentPicklistController.getDefaultValues(lProjectLoc[0].Id);
        addressDependentPicklistController.updateAddress(lProjectLoc[0].Id,'India','Maharastra','Mumbai');
        addressDependentPicklistController.getCountryListWithoutUS();
    }    
}