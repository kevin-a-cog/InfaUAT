@isTest
public class PRM_OpportunityTriggerHandlerTest {
    
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();   
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id CompetitiorRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
    static Id ProspectRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeCSIId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    private final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private final static string OPP_RENEWAL_RT = Label.Renewal_Opportunity; // Renewal Opportunity record type name on Opportunity 
    
    @testSetup
    static void setUpPRMData(){
        
        UtilityTest.insertSetupObjectTestData();
        List<User> userList = UtilityTest.createUsersforPRM();
        List<Account> accList = UtilityTest.createAccountforPRM();
        List<User> prtnrUserList = UtilityTest.createPartnerUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        
        system.runAs(adminUser)
        {   
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            settings.SetupOwnerId = prtnrUserList[0].Id;
            upsert settings User_Exemptions__c.Id;
            
            User_Exemptions__c settings1 = User_Exemptions__c.getOrgDefaults();
            settings1.Ignore_Validation_Rules__c = true;
            settings1.SetupOwnerId = prtnrUserList[2].Id;
            upsert settings1 User_Exemptions__c.Id;
            /*------------------------------------------------Test Channel Program Creation Start---------------------------------------------------------*/
            //create ChannelProgram
            UtilityTestData.mChannelProgramData.put('Name','AIR and CSI');
            sObject channelProgramObj = new ChannelProgram();
            channelProgramObj = UtilityTest.putFieldRecord(channelProgramObj, UtilityTestData.mChannelProgramData);
            
            List<ChannelProgram> channelProgList = (List<ChannelProgram>) UtilityTest.makeInsert(new List<sObject>{channelProgramObj});
            
            //Creating Product2 records            
            UtilityTestData.mProductData.put('Name', 'DaaS Subscription');
            UtilityTestData.mProductData.put('Family', 'DaaS Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X1');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID1');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj = new Product2();      
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name', 'Cloud Subscription');
            UtilityTestData.mProductData.put('Family', 'Cloud Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X2');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID2');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj1 = new Product2();             
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name', 'On-Premise Perpetual');
            UtilityTestData.mProductData.put('Family', 'On-Premise Perpetual');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X3');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID3');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj2 = new Product2();      
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Name', 'On-Premise Subscription');
            UtilityTestData.mProductData.put('Family', 'On-Premise Subscription');
            UtilityTestData.mProductData.put('ProductCode', 'Pro-X4');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID4');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj3 = new Product2();
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProductData);           
            
            UtilityTestData.mProductData.put('Name', 'Intelligent Cloud Data Management for FedRAMP - 120 Informatica Processing Units per consecutive month');
            UtilityTestData.mProductData.put('Product_Family__c', 'IPU');
            UtilityTestData.mProductData.put('ProductCode', 'BACKPOCKET');
            UtilityTestData.mProductData.put('IsActive', 'True');
            UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID5');
            UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
            sObject sObj4 = new Product2();
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mProductData);  
            
            
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3, sObj4});
            System.assertEquals(lProduct.size(), 5);          
            
            /*------------------------------------------------Test Channel Program Creation End---------------------------------------------------------*/
            
            Test.startTest();
            /*------------------------------------------------Test Channel Program Level Creation Start---------------------------------------------------------*/
            //create ChannelProgramLevel
            Id ChannelProgramLevelRecTypeAIRId = Schema.SObjectType.ChannelProgramLevel.getRecordTypeInfosByName().get('AIR').getRecordTypeId();
            Id ChannelProgramLevelRecTypeCSIId = Schema.SObjectType.ChannelProgramLevel.getRecordTypeInfosByName().get('CSI').getRecordTypeId();
            
            UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeAIRId);
            UtilityTestData.mChannelProgramLevelData.put('Name','AIR');
            UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[0].id + '');     
            sObject channelProgramLevelObj = new ChannelProgramLevel();
            channelProgramLevelObj = UtilityTest.putFieldRecord(channelProgramLevelObj, UtilityTestData.mChannelProgramLevelData);
            
            UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeCSIId);
            UtilityTestData.mChannelProgramLevelData.put('Name','CSI');     
            sObject channelProgramLevelObj1 = new ChannelProgramLevel();
            channelProgramLevelObj1 = UtilityTest.putFieldRecord(channelProgramLevelObj1, UtilityTestData.mChannelProgramLevelData);
            
            List<ChannelProgramLevel> channelProgLevelList = (List<ChannelProgramLevel>) UtilityTest.makeInsert(new List<sObject>{channelProgramLevelObj,channelProgramLevelObj1});
            
            /*------------------------------------------------Test Channel Program Level Creation End---------------------------------------------------------*/
            
            
            /*------------------------------------------------Test Partner Program Creation Start---------------------------------------------------------*/
            //create partner program
            UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
            UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
            UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
            UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
            UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
            UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
            UtilityTestData.mPartnerProgramData.put('Program_Type__c','1 Tier AIR');
            UtilityTestData.mPartnerProgramData.put('Program_Level__c','N/A');
            
            //Create partnerProgObj for accList[1].id
            sObject partnerProgObj = new Partner_Program__c();
            partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
            
            //Create partnerProgObj1 for accList[2].id
            UtilityTestData.mPartnerProgramData.put('Partner__c',accList[2].id + '');
            sObject partnerProgObj1 = new Partner_Program__c();
            partnerProgObj1 = UtilityTest.putFieldRecord(partnerProgObj1, UtilityTestData.mPartnerProgramData);
            
            //Create partnerProgObj2 for accList[3].id
            UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeCSIId);
            UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[1].id+'');
            UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
            UtilityTestData.mPartnerProgramData.put('Program_Level__c','Foundation');
            UtilityTestData.mPartnerProgramData.put('Partner__c',accList[3].id + '');
            sObject partnerProgObj2 = new Partner_Program__c();
            partnerProgObj2 = UtilityTest.putFieldRecord(partnerProgObj2, UtilityTestData.mPartnerProgramData);
            
            List<Partner_Program__c> partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj,partnerProgObj1,partnerProgObj2});
            
            /*------------------------------------------------Test Partner Program Creation End---------------------------------------------------------*/
            
            /*------------------------------------------------Test Partner Distributor Creation Start---------------------------------------------------------*/
            //create partner distributor
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','United States');
            sObject partnerdisti = new Partner_Distributor__c();
            partnerdisti = UtilityTest.putFieldRecord(partnerdisti, UtilityTestData.mPartnerDistributorData);
            
            //create partner distributor for software reseller and SI
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[3].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            sObject partnerdisti1 = new Partner_Distributor__c();
            partnerdisti1 = UtilityTest.putFieldRecord(partnerdisti1, UtilityTestData.mPartnerDistributorData);
            
            
            List<Partner_Distributor__c> partnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{partnerdisti,partnerdisti1});
            
            /*------------------------------------------------Test Partner Distributor Creation End---------------------------------------------------------*/
            /*------------------------------------------------Test AccountTeamMember Creation Start---------------------------------------------------------*/
            //Add PSM to Account Team member1
            UtilityTestData.mAccountTeamMember.put('AccountId',accList[1].id + '');
            UtilityTestData.mAccountTeamMember.put('UserId',psmUser.id + '');
            UtilityTestData.mAccountTeamMember.put('TeamMemberRole','PSM');
            
            sObject AccTeamMember1 = new AccountTeamMember();
            AccTeamMember1 = UtilityTest.putFieldRecord(AccTeamMember1, UtilityTestData.mAccountTeamMember);
            
            //Add PSM to Account Team member2
            UtilityTestData.mAccountTeamMember.put('AccountId',accList[2].id + '');
            
            sObject AccTeamMember2 = new AccountTeamMember();
            AccTeamMember2 = UtilityTest.putFieldRecord(AccTeamMember2, UtilityTestData.mAccountTeamMember);
            
            //Add PSM to Account Team member3
            UtilityTestData.mAccountTeamMember.put('AccountId',accList[3].id + '');
            
            sObject AccTeamMember3 = new AccountTeamMember();
            AccTeamMember3 = UtilityTest.putFieldRecord(AccTeamMember3, UtilityTestData.mAccountTeamMember);
            
            //Add all accounts team member to acclist
            List<AccountTeamMember> accTeamMemList = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{AccTeamMember1,AccTeamMember2,AccTeamMember3});
            /*------------------------------------------------Test AccountTeamMember Creation End---------------------------------------------------------*/
            
            /*------------------------------------------------Test Lead creation Start---------------------------------------------------------*/
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','');
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id+'');
            UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
            
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','United States');
            UtilityTestData.mLeadData.put('FirstName','test resell');
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('FirstName','test1 referral');
            UtilityTestData.mLeadData.put('LastName ','test1');
            UtilityTestData.mLeadData.put('Email','test1@testr1.q');
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert1');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[3].id+'');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','Yes');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            //create lead1
            sObject lead1 = new Lead();
            lead1 = UtilityTest.putFieldRecord(lead1, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('FirstName','test2 resell');
            UtilityTestData.mLeadData.put('LastName ','test2');
            UtilityTestData.mLeadData.put('Email','test2@testr2.q');
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert2');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id+'');
            //UtilityTestData.mLeadData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            //create lead2
            sObject lead2 = new Lead();
            lead2 = UtilityTest.putFieldRecord(lead2, UtilityTestData.mLeadData);
            
            UtilityTestData.mLeadData.put('FirstName','test3 referral');
            UtilityTestData.mLeadData.put('LastName ','test3');
            UtilityTestData.mLeadData.put('Email','test3@testr3.q');
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert3');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[3].id+'');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','No');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            //create lead3
            sObject lead3 = new Lead();
            lead3 = UtilityTest.putFieldRecord(lead3, UtilityTestData.mLeadData);

            UtilityTestData.mLeadData.put('FirstName','test4 referral');
            UtilityTestData.mLeadData.put('LastName ','test4');
            UtilityTestData.mLeadData.put('Email','test4@testr4.q');
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert4');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Ecosystem');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[3].id+'');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','No');
            UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
            //create lead3
            sObject lead4 = new Lead();
            lead4 = UtilityTest.putFieldRecord(lead4, UtilityTestData.mLeadData);            
            
            List<lead> resellleadList = new list<lead>();
            List<lead> referralleadList = new list<lead>();
            system.runAs(prtnrUserList[0])
            {
                resellleadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead,lead2});
            }
            system.runAs(prtnrUserList[2])
            {
                referralleadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead1,lead3,lead4});
            }
            /*------------------------------------------------Test Lead creation End---------------------------------------------------------*/
            
            
            /*------------------------------------------------Test Lead Product Start---------------------------------------------------------*/
            UtilityTestData.mProductData.put('Lead__c',resellleadList[0].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[0].id+'');
            
            sObject leadProd1o1 = new Deal_Registration_Products__c();
            leadProd1o1 = UtilityTest.putFieldRecord(leadProd1o1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Lead__c',resellleadList[0].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[1].id+'');
            
            sObject leadProd1o2 = new Deal_Registration_Products__c();
            leadProd1o2 = UtilityTest.putFieldRecord(leadProd1o2, UtilityTestData.mProductData);
            /*-----------------------------------------------------------------------------------------*/
            UtilityTestData.mProductData.put('Lead__c',referralleadList[0].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[0].id+'');
            
            sObject leadProd2o1 = new Deal_Registration_Products__c();
            leadProd2o1 = UtilityTest.putFieldRecord(leadProd2o1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Lead__c',referralleadList[0].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[1].id+'');
            
            sObject leadProd2o2 = new Deal_Registration_Products__c();
            leadProd2o2 = UtilityTest.putFieldRecord(leadProd2o2, UtilityTestData.mProductData);
            /*-----------------------------------------------------------------------------------------*/
            UtilityTestData.mProductData.put('Lead__c',resellleadList[1].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[0].id+'');
            
            sObject leadProd3o1 = new Deal_Registration_Products__c();
            leadProd3o1 = UtilityTest.putFieldRecord(leadProd3o1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Lead__c',resellleadList[1].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[1].id+'');
            
            sObject leadProd3o2 = new Deal_Registration_Products__c();
            leadProd3o2 = UtilityTest.putFieldRecord(leadProd3o2, UtilityTestData.mProductData);
            /*-----------------------------------------------------------------------------------------*/
            UtilityTestData.mProductData.put('Lead__c',referralleadList[1].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[0].id+'');
            
            sObject leadProd4o1 = new Deal_Registration_Products__c();
            leadProd4o1 = UtilityTest.putFieldRecord(leadProd4o1, UtilityTestData.mProductData);
            
            UtilityTestData.mProductData.put('Lead__c',referralleadList[1].id+'');
            UtilityTestData.mProductData.put('Product__c',lProduct[1].id+'');
            
            sObject leadProd4o2 = new Deal_Registration_Products__c();
            leadProd4o2 = UtilityTest.putFieldRecord(leadProd4o2, UtilityTestData.mProductData);
            /*-----------------------------------------------------------------------------------------*/
            List<Deal_Registration_Products__c> leadProdList = (List<Deal_Registration_Products__c>) UtilityTest.makeInsert(new List<sObject>{leadProd1o1,leadProd1o2,leadProd3o1,leadProd3o2});
            /*------------------------------------------------Test Lead Product Start---------------------------------------------------------*/
            
            /*------------------------------------------------Test Lead Updation Start---------------------------------------------------------*/
            //UtilityTestData.mLeadData.put('PSM__c',psmUserList[0].id+'');

            resellleadList[0].Status = 'Approved';
            resellleadList[0].Account__c = accList[0].id;
            resellleadList[0].Field_Sales_Rep__c = sogUser.id;
            
            resellleadList[1].Status = 'Approved';
            resellleadList[1].Account__c = accList[0].id;
            resellleadList[1].Field_Sales_Rep__c = sogUser.id;
            
            referralleadList[1].Status = 'Approved';
            referralleadList[1].Account__c = accList[0].id;
            referralleadList[1].Field_Sales_Rep__c = sogUser.id;
            
            referralleadList[0].Status = 'Approved';
            referralleadList[0].Account__c = accList[0].id;
            referralleadList[0].Field_Sales_Rep__c = sogUser.id;
            
            list<lead> leadToUpdate = new list<lead>();
            leadToUpdate.addAll(resellleadList);
            leadToUpdate.addAll(referralleadList);
            
            //List<lead> upleadList = (List<lead>) UtilityTest.makeUpdate(leadToUpdate);
            
            /*------------------------------------------------Test Lead Updation End---------------------------------------------------------*/
        }
         Test.stopTest();    
    }
    
    @isTest
    public static void PRMLeadConversion1(){

        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name from Lead];
        
        //rus as admin user and emulate convert to new opportunity
        System.runAs(adminUser) {
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[0].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c',leadList[0].Primary_Role_in_Sale__c);
            UtilityTestData.mOpportunityData.put('Owner',adminUser.id+'');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[1].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c',leadList[1].Primary_Role_in_Sale__c);
            sObject Oppty1 = new Opportunity();
            Oppty1 = UtilityTest.putFieldRecord(Oppty1, UtilityTestData.mOpportunityData);
            
            
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            system.assertEquals(opptyList.size(),1);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void PRMLeadConversion2(){
        
        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name from Lead ];
        
        //rus as admin user and emulate convert to new opportunity
        System.runAs(adminUser) {
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[4].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c',leadList[4].Primary_Role_in_Sale__c);
            UtilityTestData.mOpportunityData.put('Owner',adminUser.id+'');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);            
            
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            system.assertEquals(opptyList.size(),1);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void PRMLeadConversion3(){

        Test.startTest();
        
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name,Partner_Account__c from Lead];
        
        //rus as admin user and emulate convert to new opportunity
        System.runAs(adminUser) 
        {
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c','');
            UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
            UtilityTestData.mOpportunityData.put('Owner',adminUser+'');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Type','Indirect');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);
            
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            system.assertEquals(opptyList.size(),1);            
            
            //update owner
            opptyList[0].Dev_Lead_Identifier__c = leadList[1].id+':Deal_Registration';
            opptyList[0].sub_type__c = leadList[1].Primary_Role_in_Sale__c;
            opptyList[0].OwnerId = sogUser.id;
            opptyList[0].StageName = 'Validate';            
            
            List<Opportunity> upOpptyList = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{opptyList[0]});
            system.assertEquals(upOpptyList[0].OwnerId,sogUser.id);
            Test.stopTest();            
        }
    }
    
    @isTest
    public static void PRMLeadConversion4(){

        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        System.runAs(adminUser) 
        {
            List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name,Partner_Account__c,CreatedById,Deal_Registration_Type__c from Lead];
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[1].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
            UtilityTestData.mOpportunityData.put('Owner',sogUser.id+'');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Type','Indirect');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);
            
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Opportunity> upOpptyList = new List<Opportunity>();
            
            
            
            opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            system.assertEquals(opptyList[0].sub_type__c,'Partner Sourced/Partner Driven');
            opptyList[0].Dev_Lead_Identifier__c = '';
            opptyList[0].sub_type__c = leadList[0].Primary_Role_in_Sale__c;
            opptyList[0].StageName = 'Validate';
            try{
                upOpptyList = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{opptyList[0]});
                system.assertEquals(opptyList[0].sub_type__c,leadList[0].Primary_Role_in_Sale__c);
            }
            catch(Exception e){}
            
            Test.stopTest();
        }
    }
    @isTest
    public static void PRMLeadConversion5(){     
        
        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name,Partner_Account__c,CreatedById,Deal_Registration_Type__c,CreatedBy.Username from Lead];
        UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[2].id+':Deal_Registration');
        UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
        UtilityTestData.mOpportunityData.put('Owner',sogUser+'');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('Type','Indirect');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        
        sObject Oppty = new Opportunity();
        Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);
        
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Opportunity> upOpptyList = new List<Opportunity>();
        
        System.runAs(adminUser) {
            
            opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            system.assertEquals(opptyList.size(),1);
            
            opptyList[0].Dev_Lead_Identifier__c = leadList[3].id+':Deal_Registration';
            opptyList[0].sub_type__c = leadList[0].Primary_Role_in_Sale__c;
            opptyList[0].StageName = 'Validate';
            try{
                upOpptyList = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{opptyList[0]});
                system.assertEquals(opptyList[0].sub_type__c,leadList[0].Primary_Role_in_Sale__c);
            }
            catch(Exception e){}
        }
        Test.stopTest();
    }
    
    //Method to cover createdUserSalesTeamAddition()
    @isTest
    public static void createTeamMemberOnOwnerChange() {
        Test.startTest();
        List<User> userObjList = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true ORDER BY Name desc];
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name from Lead];
        
        UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c','');
        UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
        UtilityTestData.mOpportunityData.put('OwnerId',userObjList[0].Id +'');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('Type','Indirect');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        sObject Oppty = new Opportunity();
        Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);        
        List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
        
        System.runAs(userObjList[0]) {
            //Update the Owner on the Opportunity to another User
            sObject sObj = new Opportunity(Id = lOpportunityRecord[0].Id, OwnerId = userObjList[1].Id
                                           ,Dev_Lead_Identifier__c = leadList[0].id+':Deal_Registration'
                                          );
            List<Opportunity> lOpportunityRecordUpdate1 = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lOpportunityRecordUpdate1.size(),1);
        }
        Test.stopTest();
    }
}