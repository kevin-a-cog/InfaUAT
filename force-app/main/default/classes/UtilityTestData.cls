/*
***********************************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
***********************************************************************************************************************
balajip         01-09-2022  I2RT-6867   T01     removed reference to SkillService class to avoid SOQL execution in the static block
*/
public with sharing class UtilityTestData
{
     
    // Populate all the required fields here
    // also there would be some Lookup or Master Detail fields those shold be filled from main class only.
    public static Map<String, String> mLeadData = new Map<String, String>{'FirstName' => 'Test Lead','LastName' => 'LastName', 'Company' => 'Test Company', 
                                                                            'Email' => 'testemailforlead@infa.com', 'Status' => 'New','Phone' => '9999999999', 'Country' => 'India'};
    
    public static Map<String, String> mAccountData = new Map<String, String>{'Name' => 'Test Account','BillingCountry' => 'India','BillingStreet' => '298 S. Ringo Street', 
                                                                             'BillingState' => 'AR', 'BillingPostalCode' => '72201'};
    public static Map<String, String> mContactData = new Map<String, String>{'FirstName' => 'Test', 'LastName' => 'Contact', 'MailingStreet' => '298 S. Ringo Street', 'MailingCity' => 'Little Rock', 
                                                                             'MailingState' => 'AR', 'MailingCountry' => 'USA' ,'MailingPostalCode' => '72201', 'Community_Access__c' => 'Active'};    
    
    public static Map<String, String> mOpportunityData = new Map<String, String>{'Name' => 'Test Opportunity', 'StageName' => 'Qualified', 'CloseDate' => system.today() + '', 
                                                                                 'Sales_Play__c' => 'Data Quality'};
    public static Map<String,String> mLegalEntity = new Map<String,String>{'Name' => 'Informatica LLC test', 'Legal_Entity_Code__c' =>'USA'};
    public static Map<String, String> mSBQuoteData = new Map<String, String>{'SBQQ__Type__c' => 'Renewal', 'CurrencyIsoCode' => 'USD', 'SBQQ__StartDate__c' => System.today() + '', 
                                                                             'SBQQ__SubscriptionTerm__c' => '12', 'SBQQ__BillingName__c' => 'Quote Billing Name', 'SBQQ__PaymentTerms__c' => 'Net 30', 
                                                                             'SBQQ__ShippingName__c' => 'Quote Shipping Name', 'Shipping_Email__c' => 'testmail@test.com', 'SBQQ__Primary__c' => 'true', 
                                                                             'SBQQ__Status__c' => 'Approved', 'BillingAddress_PSFTID__c' => 'Billing Address', 'EditLinesFieldSetName__c' => 'Standard'};
     
    public static Map<String, String> mPricebook2Data = new Map<String, String>{'Name' => 'Price Book', 'IsActive' => 'true'};
        
    
    public static Map<String, String> mLegalEntityData = new Map<String, String>{'Name' => 'Delete', 'blng__Active__c' => 'true', 'Legal_Entity_Code__c' => 'z'};
    
    public static Map<String, String> mProductData = new Map<String, String>{'Name'=>'TestProduct2','Product_Category__c'=>'Parent','Orderable__c'=>'True','Offering_Type__c' => 'Cloud Hosted Subscription','SBQQ__ChargeType__c' => 'Recurring','SBQQ__BillingFrequency__c' => 'Monthly','SBQQ__BillingType__c' => 'Advance'};
    public static Map<String, String> mOpportunityProdData = new Map<String, String>{'UnitPrice' => '1000', 'Quantity' => '10'};
    public static Map<String, String> mCompetitorData = new Map<String, String>{'CurrencyIsoCode' => 'USD'};    
    public static Map<String, String> mLeadProductData = new Map<String, String>{'Name' => 'Test Product', 'CurrencyIsoCode' => 'USD'};
    
    
    public static Map<String, String> mTerritoryData = new Map<String, String>{ 'Name' => 'US', 'DeveloperName' => 'TestTerritory'};    
    public static Map<String, String> mUserTerritory2AssociationData = new Map<String, String>();
    public static Map<String, String> mUserData = new Map<String, String>{'Alias' => 'usrTemp', 'Email' => 'usr_temp@testorg.com', 
                                                                            'EmailEncodingKey' => 'UTF-8', 'LastName' => 'Testing', 'LanguageLocaleKey' => 'en_US', 
                                                                            'LocaleSidKey' => 'en_US', 'TimeZoneSidKey' => 'America/Los_Angeles', 
                                                                            'Username' => 'usr_temp@testorg.com', 'CommunityNickname' => 'usr123'};
    public static Map<String,String> mblngBillingRuleData = new Map<String,String>{'Name' =>'TestBillingRule','blng__Active__c' =>'True','blng__GenerateInvoices__c'=>'Yes',
                                                                                'blng__InitialBillingTrigger__c'=>'Order Product Activation Date'};

    public static Map<String,String> mblngRevRecRuleData = new Map<String,String>{'Name'=>'TestRevRecRule','blng__CreateRevenueSchedule__c'=>'Yes','blng__Active__c'=>'True'};

    public static Map<String,String> mblngTaxRuleData = new Map<String,String>{'Name'=>'TestTaxRule','blng__TaxableYesNo__c'=>'No','blng__Active__c'=>'True'};  
    
    public static Map<String,String> mProduct2Data = new Map<String,String>{'Name'=>'TestProduct2','Product_Category__c'=>'Parent','Orderable__c'=>'True','Offering_Type__c' => 'Cloud Hosted Subscription','SBQQ__ChargeType__c' => 'Recurring','SBQQ__BillingFrequency__c' => 'Monthly','SBQQ__BillingType__c' => 'Advance'};  

    public static Map<String,String> mPriceBookEntryData = new Map<String,String>{'IsActive'=>'True','CurrencyIsoCode'=> 'USD','UnitPrice'=>'500.00'};  

    public static Map<String,String> mQuoteLineData = new Map<String,String>{'SBQQ__Quantity__c'=>'1','SBQQ__ChargeType__c' => 'Recurring','SBQQ__BillingFrequency__c' => 'Monthly','SBQQ__BillingType__c' => 'Advance'}; 

    public static Map<String,String> mOrderData = new Map<String,String>{'Name'=>'Test Order','Status'=> 'Draft','SoldStreet__c'=>'Test Street','SoldCity__c'=> 'Test City',
                                                                           'SoldStateProvince__c'=> 'Test State', 'SoldPostalCode__c' => '12345', 'SoldCountry__c'=> 'Test Country',
                                                                            'EndUserStreet__c'=> 'End Street', 'EndUserCity__c'=> 'End City', 'EndUserStateProvince__c'=> 'End State',
                                                                              'EndUserPostalCode__c'=> '12345','EndUserCountry__c'=>'End Country','Shipping_Preference__c'=> 'Email',
                                                                              'CurrencyIsoCode' =>'USD','SBQQ__PaymentTerm__c'=> 'Net 30','Marked_for_Review_Count__c' => '1',
                                                                               'Provisioning_Incomplete_Count__c' => '1', 'BillingName_PSFTID__c'=> 'test','EndUserAddress_PSFTID__c'=>'test',
                                                                               'ShippingName_PSFTID__c'=>'test','SoldAddress_PSFTID__c'=> 'test','BillingStreet'=>'test', 'BillingCity'=>'test',
                                                                                'BillingState'=>'test','BillingPostalCode'=>'test','BillingCountry'=>'test','BillingAddress_PSFTID__c'=>'tet',
                                                                                 'BillingName__c'=>'test','ShippingStreet'=>'test','ShippingCity'=>'test','ShippingState'=>'test','ShippingPostalCode'=>'test',
                                                                                 'ShippingCountry'=>'test','ShippingAddress_PSFTID__c'=>'test','ShippingName__c'=>'test','SoldAddress_PSFTID__c'=>'test' };

    public static Map<String,String> mOrderItemData = new Map<String,String>{'Quantity'=> '50.00', 'UnitPrice'=> '20000', 'Statement_of_Position_SOP_Amount__c'=> '50',
                                                                               'SBQQ__Status__c'=> 'Draft', 'SBQQ__Activated__c'=> 'True', 'SBQQ__ChargeType__c'=> 'Recurring',
                                                                                'Product_Category__c'=>'Feature', 'SBQQ__BillingFrequency__c'=> 'Annual', 'SBQQ__BillingType__c'=> 'Arrears',
                                                                                 'Override_Billing_Alignment__c'=> 'False', 'SBQQ__OrderedQuantity__c'=> '10','Purchase_Order_PO_Number__c'=>'10',
                                                                                  'Renewal_Statement_of_Position_SOP_ACV__c'=>'10'  };                         

    public static Map<String,String> mAssetData = new Map<String,String>{'CurrencyIsoCode' => 'USD', 'Name' => 'Test Asset'}; 


    public static Map<String,String> mTaxConfigData = new Map<String,String>{'Name'=>'Standard'};

    public static Map<String,String> mBillConfigData = new Map<String,String>();

    public static Map<String,String> mBillPrefixData = new Map<String,String>();
     public static Map<String,String> mBookingData   = new Map<String,String>();
    
    public static Map<String,String> mBookinglineData   = new Map<String,String>{'Name' => 'Test BookingLine'};

    public static Map<String,String> mSBQQSubscriptionData   = new Map<String,String>{'Name'=>'Test Subscriptions'};
    
    public static Map<String,String> mContractData = new Map<String,String>{'Name' => 'Test Contract', 'ContractTerm' => '10'};
    
    public static Map<String,String> mPartnerDistributorData = new Map<String,String>{'Country__c' => 'Australia'};
        
    
        
    public static Map<String,String> mPartnerProgramData = new Map<String,String>{'Name' => 'Test Partner Program','Program_Status__c' => 'Active','Country__c' => 'United States',
        'Program_Level__c'=>'N/A','Program_Type__c'=>'1 Tier AIR','Co_Sell_License_Revenue_Actual__c'=>'10',
        'No_of_projects_registered__c'=>'5','Total_Revenue_Target__c'=>'50','Sale_Accreditation_Compliance__c'=>'Big Data',
        'Resellers_Recruited_Annual_Target__c'=>'5','Resellers_Recruited_Annual_Actual__c'=>'5','Renewal_Status__c'=>'In Progress',
        'Qp_Resell_Revenue__c'=>'5','Q4_Resell_Revenue__c'=>'4','Q3_Resell_Revenue__c'=>'3','Q2_Resell_Revenue__c'=>'2',
        'Q1_Resell_Revenue__c'=>'1','Program_Name__c'=>'Test Partner Program','Pre_Sale_Certification_Compliance__c'=>'Big Data',
        'Co_Sell_Subscription_Revenue_Actual__c'=>'10','Program_Level__c'=>'N/A','Program_Type__c'=>'1 Tier AIR'};
               
    public static Map<String,String> mChannelProgramLevelData = new Map<String,String>{'Name' => 'Test Channel Program Level'};
        
    public static Map<String,String> mChannelProgramData = new Map<String,String>{'Name' => 'Test Channel Program'};
        
    public static Map<String,String> mProjectRegistrationData = new Map<String,String>{'Project_Name__c' => 'Test Project Reg','Status__c'=>'In Progress',
                                      'Project_Type__c'=>'Related to an in-progress opportunity','Customer_Account_Name__c'=>'Test Cust Account',
                                      'Customer_Account_Country__c'=>'United States','Customer_Account_City__c'=>'Test City','Customer_Contact_Name__c'=>'Test Cust Contact',
                                      'Customer_Contact_Email__c'=>'abc@abc.com','Customer_Account_State_Province__c'=>'Alaska'};
        
    public static Map<String,String> mChannelProgramMemberData = new Map<String,String>{'Program_Name__c' => 'Test Channel Member Program'};
        
    public static Map<String,String> mPartnerRelationshipData = new Map<String,String>{'Partner_Role__c' => 'OEM'};
        
    public static Map<String,String> mEvaluationData = new Map<String,String>{'Status__c' => 'Survey Sent','Knowledge_Transfer_and_Coaching_Skills__c'=>'5',
            'Expectations_Met_by_INFA_Partner__c'=>'5','Partner_s_Accuracy_and_Meeting_Dedlines__c'=>'5',
            'Partner_s_Analysis_and_Understanding__c'=>'5','Partner_s_Communication_and_Teamwork__c'=>'5',
            'Partner_s_Overall_Management__c'=>'5','Partner_s_Technical_Competence__c'=>'5'};
            
    public static Map<String,String> mAccountTeamMember = new Map<String,String>{};
                
    public static Map<String,String> mOpportunityTeamMember = new Map<String,String>{};
                    
    public static Map<String,String> mProductRequestData = new Map<String,String>{'Comments__c' => 'test'}; 
                        
    public static Map<String,String> mEngagementData = new Map<String,String>{'Name'=>'Test Engagement'};
                            
    public static Map<String,String> mCustomMetaData = new Map<String,String>{'MasterLabel'=>'Test Data','DeveloperName'=>'Test Name','NamespacePrefix'=>'Test Prefix'};
    
    public static Map<String,String> mDiscountApprovalSSDirector = new Map<String,String>();
    public static Map<String,String> mDiscountApprovalMatrix = new Map<String,String>{'Name'=>'DiscApprovalMatrix','DrivenBy__c'=>'Inside Sales','OpportunitySize__c'=>'Lic-XXL','OpportunityTier__c'=>'1','ApproverSeq__c'=>'1','TopApprover__c'=>'true'};
    public static Map<String,String> mDiscountApproval = new Map<String,String>{'Discount__c'=>'20','DrivenBy__c'=>'Inside Sales','OpportunityLicense__c'=>'Sub-M' };
    public static Map<String,String> mTaskData = new Map<String,String>{'Subject'=> 'Test Subject','Type'=>'Email'};
    public static Map<String,String> mEventData = new Map<String,String>{'Subject'=>'Test Event Subject','DurationInMinutes'=>'60','ActivityDateTime'=>system.now() + ''};
    public static Map<String,String> mMultiCurrencyMasterData = new Map<String,String>{'Name'=> 'Test Name','Active__c'=>'TRUE'};
    public static Map<String,String> mCurrencyExchangeRateData = new Map<String,String>{'Conversation_Rate__c'=>'50','Currency_Code__c'=> 'INR'};
    public static Map<String,String> mOpportunityContactRoleData = new Map<String,String>{};
    public static Map<String,String> mOpportunityTeamMemberData = new Map<String,String>{'TeamMemberRole'=>'Account Manager','OpportunityAccessLevel'=> 'Edit'};
    public static Map<String,String> mOrgData = new Map<String,String>{'Name'=>'Test Org','OrgID__c' => '123456789'};
    public static Map<String,String> mOrgServiceData = new Map<String,String>{'Name'=>'Test Org Service','License_Type__c' => 'Trial'};
    public static Map<String,String> mOrgUserData = new Map<String,String>{'Name'=>'Test Org User', 'Email__c' => 'testOrgEmail@test.com'};
    public static Map<String,String> mAccountProduct = new Map<String,String>{'Related_Asset_Identifier__c'=> '11111','Forecast_Product__c'=> 'Data Archive'};
    public static Map<String,String> mAccountLOB = new Map<String,String>{'Name'=> 'Test LOB'};
    public static Map<String,String> mPlan = new Map<String,String>{'Current_State_of_plan__c'=> 'Onboarding'};
    public static Map<String,String> mLOBContact = new Map<String,String>{'Role__c'=> 'Director'};
    public static Map<String,String> mRiskIssue = new Map<String,String>{'Name'=> 'Test Risk'};
    public static Map<String,String> mRelatedOpportunityPlan = new Map<String,String>{'Is_First_Year_Renewal__c'=> 'TRUE'};

    public static Map<String,String> mLegalAgreement = new Map<String,String>{'Name' => 'Test Legal Agreement', 'Agreement_Type__c' => 'Master','Legal_Entity__c' => 'Informatica LLC',
  'Contract_Term_Type__c' => 'Perpetual', 'Contract_Type__c' => 'US - ILSA','Contract_Purpose__c' => 'Test','Start_Date__c' => String.valueOf(Date.today())};
    public static Map<String,String> mE2aBusinessUnit = new Map<String,String>{'Name'=> 'Digital Touch'}; 
    public static Map<String,String> mRelatedAccountProduct = new Map<String,String>{};
    public static Map<String,String> mRelatedRiskProduct = new Map<String,String>{};
    public static Map<String,String> mRelatedOpportunityProduct = new Map<String,String>{};
    public static Map<String,String> mPricebookUpliftData = new Map<String,String>{'Round_up_To__c' => '10','Percentage__c' => '5'};   
    public static Map<String,String> mInstallBase = new Map<String,String>{'Name'=> 'Test InstallBase'};
    public static Map<String,String> mInstallBaseMapping = new Map<String,String>{'Name'=> 'Test InstallBase Mapping'};
    public static Map<String,String> mVersion = new Map<String,String>{'Name'=> 'Test Version'};
    public static Map<String,String> mDownloadLink = new Map<String,String>{'Name'=> 'Test Download Link'};
    public static Map<String,String> mFulfillment = new Map<String,String>{'Name'=> 'Test Fulfillment'};
    public static Map<String,String> mFulfillmentLine = new Map<String,String>{'Name'=> 'Test Fulfillment Line'};
    public static Map<String,String> mRelatedFulfillmentLine = new Map<String,String>{'Name'=> 'Test Related Fulfillment Line'};
    public static Map<String,String> mFulfillmentVersion = new Map<String,String>{'Name'=> 'Test Fulfillment Version'};
    
    public static Map<String,String> mOldOrgOrderData = new Map<String,String>{'Name' => 'Test Old Org Order1','Old_Org_Order_Id__c' => '12345'}; 
    public static Map<String,String> mOldOrgOrderDetailData = new Map<String,String>{'Name' => 'Test Old Org Order1','Extended_Price__c' => '12345', 'Order_Name__c' => 'Test' ,'Quantity__c' => '2', 'SKU_Name__c' => 'Test Sku'}; 
    public static Map<String,String> mObjectTerritory2AssociationData = new Map<String,String>{};
    public static Map<String,String> mBillPlanDataAmt = new Map<String,String>{'Bill_Amount__c' => '1','Partial_Order__c' => 'FALSE'};
    public static Map<String,String> mBillPlanDataPer = new Map<String,String>{'Bill_Percentage__c' => '100','Partial_Order__c' => 'FALSE'};
    public static Map<String,String> mCampaignData = new Map<String,String>{'Name' => 'TestCampaign'};
    public static Map<String,String> mNextActionRecommendation =new Map<String,String> {'Name'=>'Test Rec'};
    public static Map<String,String> mpaymentTerm = new Map<String,String> {'Start_Date__c' => String.valueOf(Date.today()),'End_Date__c' => String.valueOf(Date.today().addDays(10)),'Payment_Term__c' => '10'};
    public static Map<String,String> mCurrencyConvRate = new Map<String,String> {'CurrencyIsoCode' => 'USD','Conversion_Rate__c' => '1','Round_Up_To__c' => '10'};
    public static Map<String,String> mSubscriptionLine = new Map<String,String>{};
    public static Map<String,String> mRevSchedule = new Map<String,String>{'blng__TotalRevenueAmount__c' => '100'};
    public static Map<String,String> mGLRule = new Map<String,String>{'Name' => 'GLRule','blng__Active__c' => 'TRUE'};
    public static Map<String,String> mFinanceBook = new Map<String,String>{'Name' => 'FinanceBook','blng__Active__c' => 'TRUE','blng__PeriodType__c' => 'Revenue'};
    public static Map<String,String> mRevenueDistributionMethod = new Map<String,String>{'Name' => 'RevenueDistributionMethod','blng__Active__c' => 'TRUE','blng__DistributionMethod__c' => 'Monthly','blng__MonthlyRecognitionProration__c' => 'Number of Days','blng__RevenueScheduleTermEndDate__c' => 'Order Product End Date',
    'blng__RevenueScheduleTermStartDate__c' => 'Order Product Start Date','blng__RevenueTransactionCreationProcess__c' => 'Automatic','blng__Type__c' => 'Order'};
    public static Map<String,String> mRevRecTreat = new Map<String,String>{'Name' => 'RevRevTreat','blng__Type__c' => 'Percentage','blng__Percentage__c' => '100','blng__RevenueScheduleCreationAction__c' => 'Order Activation','blng__Active__c' => 'TRUE','blng__ProcessingOrder__c' => '1'};
    public static Map<String,String> mRevAgree = new Map<String,String>{'Stage__c' => 'Draft'};
    public static Map<String,String> mROC = new Map<String,String>{'Original_Order__c' => 'TRUE'};
    public static Map<String,String> mProductOption = new Map<String,String>{'SBQQ__Number__c' => '10','Is_Child__c' => 'TRUE','Percentage_Allocation__c' => '100'};
    public static Map<String,String> mProductFeature = new Map<String,String>{'SBQQ__Number__c' => '10','Name' => 'Test Feature','SBQQ__MinOptionCount__c' => '0'};
    public static Map<String,String> mProductRule = new Map<String,String>{'SBQQ__ErrorMessage__c' => 'HELLO','SBQQ__ConditionsMet__c' => 'All','Name' => 'Test Product Rule','SBQQ__Scope__c' => 'Quote','SBQQ__Type__c' => 'Alert','SBQQ__EvaluationEvent__c' => 'Always'};
    public static Map<String,String> mPriceRule = new Map<String,String>{'SBQQ__TargetObject__c' => 'Calculator','Name' => 'Test PriceRule','SBQQ__ConditionsMet__c' => 'All','CurrencyIsoCode' => 'USD','SBQQ__EvaluationEvent__c' => 'On Initialization;Before Calculate;After Calculate'};
    public static Map<String,String> mDisSch = new Map<String,String>{'SBQQ__Type__c' => 'Range','Name' => 'Test Dis Sch','SBQQ__DiscountUnit__c' => 'Percent','SBQQ__QuoteLineQuantityField__c' => 'Quantity'};
    public static Map<String,String> mConfigAtt = new Map<String,String>{'SBQQ__TargetField__c' => 'Cancel_Reason__c','Name' => 'Test Config Att','SBQQ__ColumnOrder__c' => '1','SBQQ__Position__c' => 'Top','SBQQ__ApplyToProductOptions__c' => 'true','SBQQ__DisplayOrder__c' => '10'};
    public static Map<String,String> mERPCompany = new Map<String,String>{'CurrencyIsoCode' => 'USD'};
    public static Map<String,String> mERPSite = new Map<String,String>{'Country__c' => 'USA'};    
    public static Map<String,String> mFinancePeriod = new Map<String,String>{'Name' => 'Finance Period Booking'};
    public static Map<String,String> mContactMapDetailsData = new Map<String, String>{'ALTF__Coverage__c' => 'In-Depth','ALTF__Decision_Orientation__c' => 'Financial', 'ALTF__Political__c' => 'Inner Circle', 'ALTF__Status__c' => 'Mentor'}; //Altify Contact Map Details Object Test Data    
   
    /**psa**/    
    public static Map<String,String> mRegion =new Map<String,String> {'Name'=>'Test Region','psa_pm_Territory_ID_Mapping__c'=>'1234'};   
    public static Map<String,String> mAssignmentData =new Map<String,String> {'Name'=>'Test Assignment','pse__Cost_Rate_Amount__c'=>'100.00','pse__Start_Date__c'=> String.valueOf(Date.today()),'pse__End_Date__c' => String.valueOf(Date.today().addDays(10))};   
    public static Map<String,String> mProjectData =new Map<String,String> {'Name'=>'Test Project'};  
    public static Map<String,String> mScheduleData =new Map<String,String> {'Name'=>'Test Schedule'};   
    public static Map<String,String> mPermissionControl =new Map<String,String> {'pse__Staffing__c' => 'true'};  
    public static Map<String,String> mSurvey =new Map<String,String> {'psa_pm_Survey_Language__c' => 'English'};
    public static Map<String,String> mSurveyLineItem =new Map<String,String> {'Adoptiion_Overall_Abilities_Score__c' => '10'};
    public static Map<String,String> mTimePeriod =new Map<String,String> {'pse__Type__c' => 'Year'};
    public static Map<String,String> mExpenseReport =new Map<String,String> {'Name' => 'Test Expense Report'};
    public static Map<String,String> mExpense =new Map<String,String> {};
    public static Map<String,String> mEvent =new Map<String,String> {};
    public static Map<String,String> mMilestone =new Map<String,String> {};
    public static Map<String,String> mResourceRequest =new Map<String,String> {'pse__SOW_Hours__c'=>'8.00'};
    public static Map<String,String> mCodeMapping =new Map<String,String> {'Name'=>'Test','psa_pm_City_Name__c'=>'Test City','psa_pm_County_State__c'=>'Test State','psa_pm_MSA_Code__c'=>'12345','psa_pm_MSA_Name__c'=>'Test Name','psa_pm_State_Code__c'=>'Test code','psa_pm_ZIP_Code__c'=>'123345'};
    public static Map<String,String> mBudget =new Map<String,String> {'Name'=>'Test Budget'};
    public static Map<String,String> mLocation =new Map<String,String> {'Name'=>'Test Location'};
    public static Map<String,String> mSkill =new Map<String,String> {'Name' => 'Product 360'};
    public static Map<String,String> mSkillRating =new Map<String,String> {'Name' => 'Test Rating Id', 'pse__Aspiration__c' => 'true', 'pse__Certified__c' => 'true', 'pse__Rating__c' => '1 - Limited Exposure'};
  /**psa**/    
    
    /** I2RT **/
    public static String currentUserId=UserInfo.getUserId();
    public static Map<String,String> mCase = new Map<String,String>{'Subject' => 'Test Subject','origin' => 'Web'};
    public static Map<String,String> mCaseContact = new Map<String,String>{'Name' => 'Test Case Contact','Email__c' => 'test98765123@test.com'};
    public static Map<String,String> mAccContact = new Map<String,String>{'Roles' => 'Read/Write'};
    
    public static Map<String,String> mTechnicalProductLine = new Map<String,String>{'Name' => 'Test'};  
    public static Map<String,String> mTechnicalProdLines = new Map<String,String>{'Name' => 'Active VOS', 'Status__c' => 'Active','Version__c' => '1','Problem_Type__c' =>'Installation', 'Component_SubComponent__c' => 'ActiveVOS Console:Error~Permission;Installation'};  
    public static Map<String,String> mEntitledProduct = new Map<String,String>{'Name' => 'Test'};  

    public static Map<String,String> mProfileSkillEscalation = new Map<String,String>{'Name' => 'Escalation Manager', 'Queue_Name__c' => 'Escalation_Managers'}; //T01
    public static Map<String,String> mProfileSkillProductSME = new Map<String,String>{'Name' => 'PowerCenter - SME', 'Type__c' => 'Product Engineer/Specialist', 'Product_Name__c' => 'PowerCenter', 'Queue_Name__c' => 'PowerCenter', 'Chatter_Group_Name__c' => 'PowerCenter-PS', 'Public_Group_Name_c' => 'PowerCenter'}; //T01
    public static Map<String,String> mProfileSkillProductPS = new Map<String,String>{'Name' => 'PowerCenter - PS', 'Type__c' => 'Product Specialist', 'Product_Name__c' => 'PowerCenter', 'Queue_Name__c' => 'PowerCenter', 'Chatter_Group_Name__c' => 'PowerCenter-PS', 'Public_Group_Name_c' => 'PowerCenter'}; //T01
    public static Map<String, String> mServiceResouce = new Map<String, String>{'IsActive' => 'true'};

    public static Map<String,String> mTimeZone =new Map<String,String> {'Name'=>'Test TimeZone','TimeZoneSidKey__c'=>'GMT'};    

    public static Map<String,String> mCasePowerCenter = new Map<String,String>{'Subject' => 'Test Subject', 'origin' => 'Web', 'Forecast_Product__c' => 'PowerCenter'};
    public static Map<String,String> mServiceAppointment = new Map<String,String>{'Status__c' => 'Available','Appointment_Date__c' => string.valueOf(system.today()+2), 'start_time__c' => '10:30', 'End_time__c' => '10:45'};
    public static Map<String,String> mEntitlement =new Map<String,String> {'Name'=>'Test mEntitlement'};

    public static Map<String,String> mServiceBOM = new Map<String,String>{'Forecast_Product__c'=>'Axon Data Governance','Delivery_Method__c'=>'On premise'};
    public static Map<String,String> mAccContactRelation = new Map<String,String>{'isActive'=>'true'};

    //public static Map<String,String> mCase = new Map<String,String>{'Subject' => 'Test Subject','origin' => 'Web'};
    public static Map<String,String> mCaseComment =new Map<String,String> {'Comment__c'=>'Test CommentBody','Status__c'=>'Draft'};    
    //public static Map<String,String> mCaseContact = new Map<String,String>{'Email__c' => 'test98765123@test.com'};
    public static Map<String,String> mCaseTeam = new Map<String, String>{'Name'=>'Test','Role__c'=>'Owner'};
    public static Map<String,String> mCaseMilestone = new Map<String, String>{'Name'=>'CM-1','Milestone_Name__c'=>'Initial Response','Start_Date__c'=>String.valueOf(System.today())};
    public static Map<String,String> mCaseIncident = new Map<String, String>{'Name'=>'A-1'};
    public static Map<String,String> mCaseKB = new Map<String, String>{'Name'=>'Test','ArticleNumber__c'=>'000000001'};
    public static Map<String,String> mCaseReproEnvironment = new Map<String, String>{'Name'=>'Case Repro Environment','Primary__c'=>'false','Approval_Status__c'=>'Requested'};
    public static Map<String,String> mCaseWeightage = new Map<String, String>{'Name'=>'100%','ACC__c'=>'0.0','Full_Case_Weightage__c'=>'110.0','Final_Case_Weightage__c'=>'100.0'};
    public static Map<String,String> mCaseCommentEmailStat = new Map<String, String>{'Name'=>'CCE-1','Delivery__c'=>'Delivered','Email_Clicked__c'=>'false','Email_Opened__c'=>'false','Is_Email_Clicked__c'=>'No','Is_Email_Opened__c'=>'No'};
    public static Map<String,String> mCaseCommentFeedback = new Map<String, String>{'Name'=>'CCF-1','disLike__c'=>'false','Like'=>'true','Feedback__c'=>'test feedback'};

    public static Map<String,String> mCollaborate = new Map<String, String>{'Name'=>'Get Help-Active VOS-00002274','Skill__c'=>'Active VOS - Engineer/Specialist','Product__c'=>'Active VOS','Type__c'=>'Get Help','Question__c'=>'dfsdfsdfsdf','Title__c'=>'sdfsdfsd'};

    public static Map<String,String> mEngagementEscalation = new Map<String,String>{'Name'=>'Escalation One', 'Title__c' => 'Escalation One'};
    public static Map<String,String> mCaseEscalation = new Map<String,String>{'Name'=>'CESC-1'};
    public static Map<String,String> mEngagementTeam = new Map<String,String>{'Name'=>'GTN-1','Role__c'=>'GCS Case Collaborator'};
    public static Map<String,String> mEngagementContact = new Map<String,String>{'Name'=>'CN-1'};

    public static Map<String,String> mShiftPlan = new Map<String,String>{'Name '=>'Holiday Support (India)','Type__c'=>'Holiday Support (India)','Start_Date__c'=>String.valueOf(System.today()),'End_Date__c'=>String.valueOf(System.today()+1)};   
    public static Map<String,String> mShiftRequest = new Map<String,String>{'Name'=>'Req-1','Allocation_Type__c'=>'Holiday Support (India)','Resource_Count__c'=>'2'};    
    public static Map<String,String> mShiftAllocation = new Map<String,String>{'Location__c'=>'WFH','Contact_Number__c'=>'3434332325','Status__c'=>'Pending','Start_Date__c'=>String.valueOf(System.today()),'End_Date__c'=>String.valueOf(System.today()+1)};    
    public static Map<String,String> mShiftDate = new Map<String,String>{'Start_Date__c'=>String.valueOf(System.today()),'End_Date__c'=>String.valueOf(System.today()+1)}; 

    public static Map<String,String> mNotificationCriteria = new Map<String,String>{'Object__c'=>'Case','Condition__c'=>'Priority == \'P1\'','Active__c'=>'true'};  
    public static Map<String,String> mNotificationCriteriaDetail = new Map<String,String>{'Field_Name__c'=>'Priority','Field_API_Name__c'=>'Priority','Operator__c'=>'equals','Value__c'=>'P1'};   
    public static Map<String,String> mNotificationUser = new Map<String,String>{'Name'=>'NU-1','User_Phone__c'=>'2312435467','User_Email__c'=>'abc@abc.com','Active__c'=>'true'};   

    public static Map<String,String> mAppointmentRequest = new Map<String,String>{'Name'=>'Service Appointment-1','Status__c'=>'Available','Activity_Type__c'=>'Restart the services','Appointment_Date__c'=>String.valueOf(System.today())};
    public static Map<String,String> mAttendee = new Map<String,String>{'Name'=>'A-1'};
    public static Map<String,String> mTimeSlot = new Map<String,String>{'Name'=>'TS-1','Start_Time__c'=>String.valueOf(System.today()),'Duration__c'=>'60.0','Originally_Available__c'=>'false'};
    public static Map<String,String> mAlertannouncements = new Map<String,String>{'Name'=>'Test AlertAnnouncement'};
    public static Map<String,String> mInspiredMessages = new Map<String,String>{'Name'=>'Test IMessages','pse__Type__c' => 'Technical','pse__Certification_Source__c' => 'Google'};
    public static Map<String, String> mLinkData = new Map<String, String>{};
    /** I2RT **/    
        
    /** Cosmos **/
    /**Existing TestData **/
    //public static Map<String,String> mPlan = new Map<String,String>{'Current_State_of_plan__c'=> 'Onboarding','Sub_Stage__c'=>'Pre-Closure'};
    //public static Map<String,String> mRiskIssue = new Map<String,String>{'Name'=> 'Test Risk'};
    //public static Map<String,String> mRelatedOpportunityPlan = new Map<String,String>{'Is_First_Year_Renewal__c'=> 'TRUE'};//INTERLOCKS
    //public static Map<String,String> mRelatedAccountProduct = new Map<String,String>{}; // PLAN PRODUCTS
    //public static Map<String,String> mRelatedRiskProduct = new Map<String,String>{};
    //public static Map<String,String> mRelatedOpportunityProduct = new Map<String,String>{}; //INTERLOCK PRODUCTS
        
     /**New TestData **/   
    public static Map<String,String> mObjective = new Map<String,String>{'Business_Goal__c' => 'Test Business Goal', 'Technical_Goal__c' => 'Test Technical Goal','Comments__c' => 'Test Comments'};
    public static Map<String,String> mObjectiveProduct = new Map<String,String>{};
    public static Map<String,String> mPlanMilestone = new Map<String,String>{'Name'=>'Test Milestone','Status__c' => 'In Progress','Description__c' =>'Test Description','Milestone_Type__c' => 'Technical Milestone'};
    public static Map<String,String> mMilestoneProduct = new Map<String,String>{};
    public static Map<String,String> mPlanContract = new Map<String,String>{};
    public static Map<String,String> mPartnerRelationship = new Map<String,String>{};
    public static Map<String,String> mPlanTeam = new Map<String,String>{'Role__c'=>'CST'};
    public static Map<String,String> mPlanContact = new Map<String,String>{'Contact_email__c'=>'test@test.com','Title__c'=>'Vice President'};  
    public static Map<String,String> mSurveyResponse = new Map<String,String>{'Name' => 'GetFeedback Survey Response: New Business Outcome Survey - CSP'}; 
    public static Map<String,String> mPartnerAccountData = new Map<String,String>{ };    
    /** Cosmos **/
    
    public static Map<String,String> mForm = new Map<String,String>{'Name'=>'Test Form', 'Active__c' =>'true', 'CurrencyIsoCode' => 'USD', 'Driven_From_Object__c' => 'Opportunity', 'Form_Type__c' => 'Estimation'};
    public static Map<String,String> mEstimationSummary = new Map<String,String>{'Name'=>'Test Estimation Summary', 'Status__c' =>'Draft'};    
        
    //Consumption Schedules - Added to handle revSchTesting
    public static Map<String,String> mProduct2DataConSch = new Map<String,String>{'Name'=>'TestProduct2 per Hit','Product_Category__c'=>'Parent','Orderable__c'=>'True','Offering_Type__c' => 'DaaS Hosted Subscription','SBQQ__ChargeType__c' => 'Recurring','SBQQ__BillingFrequency__c' => 'Annual','SBQQ__BillingType__c' => 'Advance', 'Amoritization_Schedule__c'=> 'DaaS'};  
    public static Map<String,String> mProduct2DataCSOverage = new Map<String,String>{'Name'=>'TestProduct2 per Hit Overage','Product_Category__c'=>'Add-ons','Orderable__c'=>'True','Offering_Type__c' => 'DaaS Hosted Subscription','SBQQ__ChargeType__c' => 'Recurring','SBQQ__BillingFrequency__c' => 'Annual','SBQQ__BillingType__c' => 'Arrears'};  
    
    //added altify account object test data for SALESRT#13807
    public static Map<String,String> mAltifyAccountObjectve = new Map<String,String>{'Name' => 'Test Account objective'};
        
}