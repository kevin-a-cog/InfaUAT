/****************************************************************************************************************
Class:          A2RTestFuel
@Author:        vsabbell
@Created Date:  8/22/2018.
@Description:   Creates Test Data to Test Customer Success App. Creates Accounts , Account Team members, Account Lobs, Assets, Permission set assingnments and users to test the CSP.

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                             Tag
Ambica              8/10        mpatil              Remove risk reason reference            <T01>
Ambica              11/17/20    mpatil			    Remove ortoo references                <T02>
********************************************************************************************************************/
@IsTest
public with sharing class A2RTestFuel {

    public static Map<String,User> getUserMapByRole( Boolean testcase) {
        Map<String,User> userMapByRole;
        if(testcase){
        userMapByRole = new Map<String,User>{
                'CSM' => createUser('CSM', 'CSM LastName', 'CSM1', 'csm1@infa.com', 'csm1@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true),
                'SMG' => createUser('SMG', 'AnthonyBrugnoli', 'SMG1', 'SMG1@infa.com', 'SMG1@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true),
                'CSO' =>  createUser('CSO', 'RandyBrown', 'CSO1', 'CSO1@infa.com', 'CSO1@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true),
                'Admin' =>createAdminUser('System', 'Admin', 'Admin1', 'sysAdmin1@infa.com', 'sysadmi1n@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true)
                };
        }
        else 
        {
         userMapByRole = new Map<String,User>{
                'CSM' => createUser('CSM', 'CSM LastName', 'CSM1', 'csm2@infa.com', 'csm2@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true),
                'SMG' => createUser('SMG', 'AnthonyBrugnoli', 'SMG1', 'SMG2@infa.com', 'SMG2@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true),
                'CSO' =>  createUser('CSO', 'RandyBrown', 'CSO1', 'CSO2@infa.com', 'CSO2@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true),
                'Admin' =>createAdminUser('System', 'Admin', 'Admin1', 'sysAdmin2@infa.com', 'sysadmin2@infa.com', 'GMT', 'en_US', 'UTF-8', 'en_US', true)
                };
        }
        
        return userMapByRole;
    }
    public static user createUser(String LastName, String FirstName, String Alias, String Email, String Username, String TimeZoneSidKey, String LanguageLocaleKey, String EmailEncodingKey, String LocaleSidKey, Boolean isInsert){

        Profile salesProfile = [SELECT Id, Name FROM Profile WHERE Name='Employee'];
        user u = new user(LastName = LastName, FirstName = FirstName, Alias = Alias, Email = Email, Username = Username, TimeZoneSidKey = TimeZoneSidKey, LanguageLocaleKey = LanguageLocaleKey, EmailEncodingKey = EmailEncodingKey, LocaleSidKey = LocaleSidKey, ProfileId = salesProfile.id);
        if(isInsert)
            insert u;
        return u;
    }
    //  Static method to create test data for Admin user on User
    public static user createAdminUser(String LastName, String FirstName, String Alias, String Email, String Username, String TimeZoneSidKey, String LanguageLocaleKey, String EmailEncodingKey, String LocaleSidKey, Boolean isInsert){

        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];
        user u = new user(LastName = LastName, FirstName = FirstName, Alias = Alias, Email = Email, Username = Username, TimeZoneSidKey = TimeZoneSidKey, LanguageLocaleKey = LanguageLocaleKey, EmailEncodingKey = EmailEncodingKey, LocaleSidKey = LocaleSidKey, ProfileId = adminProfile.id);
        if(isInsert)
            insert u;
        return u;
    }

    public Static Map<String,PermissionSet> AssignpermissionSets(Map<String,User> userMapByRole){
        Map<String,PermissionSet> AssignpermissionSets;
        AssignpermissionSets = new Map<String,PermissionSet>();
        Set<String> CSMPermissionSets = new Set<String>{'ReferenceView_User',
                //'ReferenceView_User_Supplemental',
                //'X00e41000000FrnJAAS',
                'APEX_Permissions',
                //'Customer_Success_Super_User_CSO',
                'Customer_Success_User_CSM'};
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [select Id,name from PermissionSet where Name In :CSMPermissionSets]){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = ps.Id;
            psa.AssigneeId = userMapByRole.get('CSM').Id;
            permissionSetAssignmentList.add(psa);
            AssignpermissionSets.put(ps.name,ps);
        }
        Set<String> SMGPermissionSets = new Set<String>{
                //'ReferenceView_User',
                //'ReferenceView_User_Supplemental',
                //'X00e41000000FrnJAAS',
                'APEX_Permissions',
                //'AdvancedApprovalsUser',
                'SteelBrickCPQUser',
                //'AdvancedApprovalsUserCloned',
                //'Salesforce_Billing_User',
                'SteelBrickCPQUserCloned'
                //'SalesforceBillingUserCloned'
        };
        for(PermissionSet ps: [select Id,name from PermissionSet where Name In :SMGPermissionSets]){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = ps.Id;
            psa.AssigneeId = userMapByRole.get('SMG').Id;
            permissionSetAssignmentList.add(psa);
            AssignpermissionSets.put(ps.name,ps);
        }

        for(PermissionSet ps: [select Id,name from PermissionSet ]){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = ps.Id;
            psa.AssigneeId = userMapByRole.get('Admin').Id;
            permissionSetAssignmentList.add(psa);
            AssignpermissionSets.put(ps.name,ps);
        }




        List<Database.SaveResult> srlist = Database.insert(permissionSetAssignmentList,false);
        for(Database.SaveResult sr: srlist){
            if(!sr.isSuccess()){
                System.debug(LoggingLevel.ERROR, Json.serialize(sr));
            }
        }

        return AssignpermissionSets;

    }

    Public static List<AccountTeamMember> AssignaccountTeamList(Map<String,User> userMapByRole,Id AccountId) {
        List<AccountTeamMember> AssignaccountTeamList;
        AssignaccountTeamList = new List<AccountTeamMember>{
                new AccountTeamMember(AccountId=AccountId,
                        TeamMemberRole='CSM',
                        OpportunityAccessLevel='Read',
                        CaseAccessLevel=null,
                        ContactAccessLevel=null,
                        AccountAccessLevel='Read',
                        UserId =userMapByRole.get('CSM').Id )
        };
        Insert  AssignaccountTeamList;

        return AssignaccountTeamList;

    }

    public List<product2> productList {
        get {
             if(productList==null){
                 productList = new List<product2>();
                 Product2 oProduct = new Product2();
                 oProduct.Name = 'Test';
                 oProduct.Pricing_Business_Model__c = 'Subscription';
                 oProduct.Forecast_Product__c = 'Data Quality';
                 oProduct.Delivery_Method__c  = 'Hosted Multi Tenant'; 
                oProduct.SBQQ__ChargeType__c='Recurring';
                oProduct.SBQQ__BillingFrequency__c='Monthly';
                oProduct.SBQQ__BillingType__c='Advance';                 
                 oProduct.Offering_Type__c  = 'Cloud Hosted Subscription';
                 productList.add(oProduct);

                 Insert productList;

                 Id pricebookId = Test.getStandardPricebookId();

                 Pricebook2 pb = new Pricebook2();
                 pb.Id = pricebookId;
                 pb.IsActive = true;

                 update pb;

                 // List<pricebookEntry> pricebookEntr
                 // create PriceBookEntry2 for standard pricebook
                 pricebookEntry pbe = new pricebookEntry();
                 pbe.IsActive = true;
                 pbe.Pricebook2Id = pb.Id;
                 pbe.Product2Id = oProduct.Id;
                 pbe.CurrencyIsoCode = 'USD';
                 pbe.UnitPrice = 500.00;

                 insert pbe;
             }
             return productList;
        }
        private set;
    }

    public User_Exemptions__c settings{
        get {
            if(settings==null){
                User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
                settings.Ignore_Validation_Rules__c = true;
                upsert settings User_Exemptions__c.Id;
            }
            return settings;
        }
        set;
    }

    public List<Account> AccountList{
        get{
            if(AccountList==null){
                AccountList = new List<Account>();
                Account acc = new Account();
                acc.Name = 'ACME';
                acc.BillingCountry = 'India';
                acc.Payment_Terms__c = 'Net 30';
                accountList.add(acc);

                Insert accountList;
            }
            return AccountList;
        }
         set;
    }

    public List<Opportunity> OpportunityList {
        get{
            if(OpportunityList==null){

                 Id OpportunityRecordTypeId;
                Map<Id,RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
                for(Id recordTypeId :recordTypeInfos.keyset()){
                    if(recordTypeInfos.get(recordTypeId).getDeveloperName().equalsIgnoreCase('Renewal_Opportunity')){
                        OpportunityRecordTypeId = recordTypeId;
                    }
                }

                OpportunityList = new  List<Opportunity>{
                        new Opportunity(
                                Name = AccountList[0].Name+' Renewal Year 1',
                                CloseDate = Date.today().addDays(20),
                                //Type = 'Direct',
                                StageName = 'Qualified',
                                CurrencyIsoCode = 'USD',
                                AccountId = AccountList[0].Id,
                                RecordTypeId = OpportunityRecordTypeId

                        )
                };
                Insert OpportunityList;
            }
            return OpportunityList;
        }
        set;}

    public  List<Account_LOB__c>  accountLOBList{
        get{
            if(accountLOBList==null){
                accountLOBList = new List<Account_LOB__c>();
                Account_LOB__c lob1 = new Account_LOB__c();
                lob1.Account__c = AccountList[0].Id;
                accountLOBList.add(lob1);
                Insert accountLOBList;
            }
            return accountLOBList;
        }
        set;}

    public List<Account_Product__c> accountProductList{
        get{
            if(accountProductList==null){
                accountProductList = new List<Account_Product__c>();
                Account_Product__c ap1 = new Account_Product__c();
                ap1.Account__c = AccountList[0].Id;
                ap1.Line_of_Business__c = accountLOBList[0].Id;
                ap1.Forecast_Product__c = 'Data Quality';
                accountProductList.add(ap1);

                Account_Product__c ap2 = new Account_Product__c();
                ap2.Account__c = AccountList[0].Id;
                ap2.Line_of_Business__c = accountLOBList[0].Id;
                ap2.Forecast_Product__c = 'Cloud Application Integration';
                accountProductList.add(ap2);

                Account_Product__c ap3 = new Account_Product__c();
                ap3.Account__c = AccountList[0].Id;
                ap3.Line_of_Business__c = accountLOBList[0].Id;
                ap3.Forecast_Product__c = 'Cloud Application Integration';
                accountProductList.add(ap3);

                Account_Product__c ap4 = new Account_Product__c();
                ap4.Account__c = AccountList[0].Id;
                ap4.Line_of_Business__c = accountLOBList[0].Id;
                ap4.Forecast_Product__c = 'Identity Resolution';
                accountProductList.add(ap4);

                Insert accountProductList;
            }
            return accountProductList;
        }
        set;
    }

    public List<Asset> assetList{
        get{
            if(assetList==null){
                system.assert(AccountList!=null && AccountList[0]!=null, 'Account Does not exist.');
                assetList = new List<Asset>();
                // create asset1
                System.debug(LoggingLevel.ERROR,''+AccountList[0]);
                Asset oAsset1 = new Asset();
                oAsset1.Name = 'testAsset1';
                oAsset1.AccountId = AccountList[0].Id;
                oAsset1.Product2 = productList[0];
                oAsset1.Asset_Identifier__c = null;
                //oAsset1.Pricin
                //PROD_PRICING_MODEL_SUBSCRIPTION
                assetList.add(oAsset1);

                // create asset2
                Asset oAsset2 = new Asset();
                oAsset2.Name = 'testAsset2';
                oAsset2.AccountId =  AccountList[0].Id;
                oAsset2.Product2 = productList[0];
                oAsset2.Asset_Identifier__c = null;
                assetList.add(oAsset2);

                // create asset3
                Asset oAsset3 = new Asset();
                oAsset3.Name = 'testAsset3';
                oAsset3.AccountId =  AccountList[0].Id;
                oAsset3.Product2 = productList[0];
                oAsset3.Asset_Identifier__c = null;
                assetList.add(oAsset3);

                // create asset4
                Asset oAsset4 = new Asset();
                oAsset4.Name = 'testAsset4';
                oAsset4.AccountId =  AccountList[0].Id;
                oAsset4.Product2 = productList[0];
                oAsset4.Asset_Identifier__c = null;
                assetList.add(oAsset4);

                insert assetList;
            }
            return assetList;
        }
        private set;
    }

    public List<Plan__c> PlanList{
        get{
            if(PlanList == null){
                Id PlanRecordTypeId;
                Map<Id,RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Plan__c.getRecordTypeInfosById();
                for(Id recordTypeId :recordTypeInfos.keyset()){
                    if(recordTypeInfos.get(recordTypeId).getDeveloperName().equalsIgnoreCase('New_Product_Implementation')){
                        PlanRecordTypeId = recordTypeId;
                    }
                }

                PlanList = new List<Plan__c>();

                Plan__c plan = new Plan__c();
                plan.Account__c =AccountList[0].Id;
                plan.Business_Case__c='Test';
                plan.Projected_Go_Live_Date__c = Date.today().addDays(120);
                plan.Closing_Notes__c= 'Test';
                plan.name = 'Account Year 1 Plan' ;
                plan.RecordTypeId = PlanRecordTypeId;
                plan.Line_of_Business__c = accountLOBList[0].Id;
                plan.Current_State_of_plan__c = 'Onboarding';
                //plan.Status__c = 'Complete';
                plan.Actual_Go_Live_Date__c = Date.Today().addDays(120);
                plan.Due_Date__c =Date.Today().addDays(60);
                PlanList.add(plan);

                Insert PlanList;

            }

            return PlanList;
        }
        private set;
    }

    public List<Related_Account_Plan__c> PlanProductList{
        get{
            if(PlanProductList==null){
                PlanProductList = new List<Related_Account_Plan__c>{
                        new Related_Account_Plan__c(Account_Plan__c = PlanList[0].Id,
                                                    Account_Product__c =accountProductList[0].Id
                                                    //Product_At_Risk__c=true
                                                    ),
                        new Related_Account_Plan__c(Account_Plan__c = PlanList[0].Id,
                                                    Account_Product__c =accountProductList[1].Id
                                //Product_At_Risk__c=true
                        ),
                        new Related_Account_Plan__c(Account_Plan__c = PlanList[0].Id,
                                                    Account_Product__c =accountProductList[2].Id
                                //Product_At_Risk__c=true
                        )
                };
                Insert PlanProductList;
            }
            return     PlanProductList;
        }
        private set;}

    public List<Risk_Issue__c> riskIssueList{
        get{
            if(riskIssueList==null){
                riskIssueList=new List<Risk_Issue__c>{
                        new Risk_Issue__c( Name = 'Account Risk for Year1 Renewal',
                                           Status__c = 'Open',
                                           Churn_Likelihood__c = 'Likely'
                                          // Risk_Reason__c = 'Acquisition' <T01>
                                          )
                        //new Risk_Issue__c()
                };
                Insert riskIssueList;
         }
            return riskIssueList;
        }
        set;
    }

    public List<Related_Opportunity_Plan__c> relatedOpportunityPlanList{
        get{
            if(relatedOpportunityPlanList==null){
                Schema.DescribeSObjectResult d = Schema.SObjectType.Related_Opportunity_Plan__c;
                Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
                List<String> recordTypeNames = new List<String>{'Renewal(SMG)'};
                
                system.assert(rtMapByName.containsKey(recordTypeNames[0]),'record type does not exist. '+ JSON.serialize(rtMapByName));
                //system.assert(rtMapByName.containsKey(recordTypeNames[1]),'record type does not exist. '+ JSON.serialize(rtMapByName));
                //system.assert(rtMapByName.containsKey(recordTypeNames[2]),'record type does not exist. '+ JSON.serialize(rtMapByName));
                system.debug(LoggingLevel.ERROR,''+JSON.serialize(rtMapByName));
                relatedOpportunityPlanList=new List<Related_Opportunity_Plan__c>{
                        new Related_Opportunity_Plan__c(
                                Opportunity__c =OpportunityList[0].Id,
                                Plan__c = PlanList[0].Id,
                                Account__c = AccountList[0].Id,
                                RecordTypeId = rtMapByName.get(recordTypeNames[0]).getRecordTypeId(),
                                Level_of_Risk__c = 'Yellow',
                                Renewal_Likelihood__c = 'Moderate',
                                Is_First_Year_Renewal__c = false,
                                Ignore_ABV__c = true,
                                Last_Contact_Date__c = Date.today().addDays(20),
                                Highest_Role_Engaged_With__c = 'IT/Business Manager'
                        )
                            ,
                        new Related_Opportunity_Plan__c(
                                Opportunity__c =OpportunityList[0].Id,
                                Plan__c = PlanList[0].Id,
                                Account__c = AccountList[0].Id,
                                RecordTypeId = Label.ProfessionalServicesRecId,
                                Level_of_Risk__c = 'Yellow',
                                Renewal_Likelihood__c = 'Moderate',
                                Is_First_Year_Renewal__c = false,
                                Ignore_ABV__c = true,
                                Last_Contact_Date__c = Date.today().addDays(20),
                                Highest_Role_Engaged_With__c = 'IT/Business Manager'
                        )
                };
                Insert relatedOpportunityPlanList;
            }
            return relatedOpportunityPlanList;
        }
        set;
    }
    
    public List<Engagement_Product__c> EngagementProductList{
        get{
            
            if(EngagementProductList==null){
                EngagementProductList=new List<Engagement_Product__c>{
                        new Engagement_Product__c(
                                Related_Opportunity_Plan__c = relatedOpportunityPlanList[0].Id,
                                Account_Product__c = accountProductList[0].Id
                        ),
                        new Engagement_Product__c(
                                Related_Opportunity_Plan__c = relatedOpportunityPlanList[0].Id,
                                Account_Product__c = accountProductList[1].Id
                        ),
                        new Engagement_Product__c(
                                Related_Opportunity_Plan__c = relatedOpportunityPlanList[0].Id,
                                Account_Product__c = accountProductList[2].Id
                        )
                };
                Insert EngagementProductList;
            }
            return EngagementProductList;
        }
        set;
    }
    
    /*<T02>
    public List<ortoo_e2a__Business_Unit__c> BusinessUnitList{
        get{
            List<String> recordTypeNames = new List<String>{'SMG Handoff','Adoption Services Engagement','Renewal Rescue'};
            if(BusinessUnitList==null){
                BusinessUnitList = new List<ortoo_e2a__Business_Unit__c>{
                    new ortoo_e2a__Business_Unit__c(
                     Name = recordTypeNames[0]
                    ),
                    new ortoo_e2a__Business_Unit__c(
                    Name = recordTypeNames[1]
                    ),
                    new ortoo_e2a__Business_Unit__c(
                    Name = recordTypeNames[2]
                    )    
                };
            }
            Insert BusinessUnitList;
            return BusinessUnitList;
        }
        set;
    }</T02>
*/

    public A2RTestFuel(){
      
    }

}