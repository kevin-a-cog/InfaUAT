/**
 * Name         : IPUE_TestUtils
 * Author       : Stephanie Viereckl | ATG, Cognizant | stephanie.viereckl@atginfo.com
 * Created Date : July 21, 2021
 * Description  : This is a utility class to create record data for the IPU Estimator process.
 *
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Stephanie Viereckl       07-21-2021      IPUE-9      Initial create
 * Evan Strohm              10-06-2021      IPUE-52     Added objects
 * Colton Kloppel           10-25-2021      IPUE-52     Added setupFormData
 */
@isTest
public with sharing class IPUE_TestUtils {

    public static void setupAllData(){

         Test.StartTest();

        Account testAccount = createAccount(true);
        Opportunity testOpp = createOpportunity(true, testAccount);
        Contact testContact = createContact(true, testAccount);
        SBQQ__Quote__c testQuote = createQuote(true, testAccount, testOpp, testContact);
        blng__LegalEntity__c testLegalEntity = createLegalEntity(true);
        Order testOrder = createOrder(true, testAccount, testOpp, testLegalEntity);
        Test.StopTest();

        System.debug('SOQL limit after SetupAllData(): ' + Limits.getQueries() + '/' + Limits.getLimitQueries());

    }

    public static void setupFormData(){

        Form__c form = createForm(true, 'TestUtils Form');
        Page__c page = createPage(true, 'TestUtils Page 1', form.Id);
        SDoc_Template__c sDocTemplate = createSDocTemplate(true, form.Id, page.Id);

        Page_Frame__c frame = createPageFrame(true, 'TestUtils P1,F1', page.Id);
        Page_Section__c section = createPageSection(true,'TestUtils P1,F1,S1', page.Id, frame.Id);

        ConsumptionSchedule refSchedule = createConsumptionSchedule(false, 'formulaRef1', null);
        refSchedule.Active__c = true;
        refSchedule.Page_Section__c = section.Id;
        refSchedule.Sequence__c = 1;
        refSchedule.Consumption_Description__c = 'Test Question for Test Utils';

        insert refSchedule;

        refSchedule.isActive = true;

        update refSchedule;

        String formulaString = '($formulaRef1 * 2)';
        Calculation__c calc = createCalculation(true, 'TestUtils Calc',formulaString);

        ConsumptionSchedule calcedSchedule = createConsumptionSchedule(false, 'calced Schedule',null);
        calcedSchedule.Data_Type__c = 'Calculated';
        calcedSchedule.IPU_Calculation__c = calc.Id;
        calcedSchedule.Active__c = true;
        calcedSchedule.Page_Section__c = section.Id;
        calcedSchedule.Sequence__c = 2;
        calcedSchedule.Consumption_Description__c = 'Test Formula for Test Utils';
        calcedSchedule.Rollup_Into_Estimation_Summary_Lines__c = true;

        insert calcedSchedule;

        calcedSchedule.isActive = true;

        update calcedSchedule;

        Product2 testProd = createProduct(true);
        ProductConsumptionSchedule rollupProdConsumptionSchedule = createProductConsumptionSchedule(false, calcedSchedule.Id, testProd.Id);

        insert rollupProdConsumptionSchedule;
    }

    public static String setupEstimationSchedulePayload(Estimation_Summary__c estimationSummary){

        // For an existing Estimation Summary, create all the Estimation Outputs for each Consumption Schedule
        IPUE_EstimationModelHelper.createEstimationModel(estimationSummary);

        // Query out the Page Section details
        Page_Section__c pageSection = [
            SELECT Id, Parent_Page_Frame__c, Name, Sequence__c, Progress__c, Display_Page_Section_Total_Inline__c,
            Display_Estimation_Summary_Total__c, Display_Label__c, Title_Visibility__c
            FROM Page_Section__c
            WHERE Parent_Page_Frame__r.Page__r.Parent_Form__c = :estimationSummary.Form__c
            LIMIT 1
        ];

        // Query out the ConsumptionSchedule and Estimation Output records
        Map<Id, ConsumptionSchedule> scheduleMap = new Map<Id, ConsumptionSchedule>([
            SELECT Id, Name, Page_Section__c, Sequence__c, Consumption_Description__c,
            Picklist_Values__c, Data_Type__c, Required__c, Default__c,
                (
                    SELECT Name, Estimation_Schedule__c, Estimation_Summary__c, User_Value__c, Original_Data_Type__c, Notes__c,
                    Table_Cell__c, Row_Number__c, Column_Number__c, Estimation_Schedule__r.Data_Type__c, 
                    Estimation_Schedule__r.Default__c, Estimation_Schedule__r.Consumption_Description__c,
                    Parent_Estimation_Schedule__c, Parent_Estimation_Schedule__r.Sequence__c, Parent_Estimation_Schedule__r.Data_Type__c
                    FROM Estimation_Outputs__r
                    WHERE Estimation_Summary__c = :estimationSummary.Id
                ),
                (
                    SELECT Id
                    FROM Table_Cell_Members__r
                )
            FROM ConsumptionSchedule
            WHERE Page_Section__c = :pageSection.Id
            AND Active__c = true
            AND RecordType.DeveloperName = 'Estimation_Schedule'
            ORDER BY Sequence__c ASC
        ]);


        IPUE_FormControllerModels.DataWrapper wrapper = IPUE_FormController.fetchFormData(estimationSummary.Id);
        return JSON.serialize(wrapper.form.pages[0].frames[0].pageSections[0]);


        // List<IPUE_FormControllerModels.SectionItem> estimationScheduleModels = new List<IPUE_FormControllerModels.SectionItem>();

        // // For each Consumption Schedule, recreate the data model that is used in the ipueEstimatorHost LWC
        // for (ConsumptionSchedule schedule : scheduleMap.values()) {

        //     // Only proceed for Consumption Schedules that are not in a table - these will be added next
        //     if (schedule.Table_Cell_Members__r.isEmpty()) {
        //         Estimation_Output__c estimationOutput = schedule.Estimation_Outputs__r[0];

        //         IPUE_FormControllerModels.EstimationSchedule estimationModel = new IPUE_FormControllerModels.EstimationSchedule(schedule, false);
        //         estimationModel.Id = schedule.Id;
        //         estimationModel.description = schedule.Consumption_Description__c;
        //         estimationModel.isCalculated = schedule.Data_Type__c == 'Calculated' ? true : false;
        //         estimationModel.parentId = schedule.Page_Section__c;
        //         estimationModel.sequence = Integer.valueOf(schedule.Sequence__c);
        //         estimationModel.type = schedule.Data_Type__c;
        //         //necessary for calculations portion of testing to resolve. Dependend on Consumption Schedule named 'formulaRef1'.
        //         estimationOutput.User_Value__c = schedule.Name == 'formulaRef1' ? '1' : null;
        //         estimationModel.output =  new IPUE_FormControllerModels.EstimationOutput(schedule, false);
    
        //         IPUE_FormControllerModels.SectionItem sectionItem = new IPUE_FormControllerModels.SectionItem(estimationModel);
        //         estimationScheduleModels.add(sectionItem);
        //     }


        // }

        // IPUE_FormControllerModels.PageSection pageSectionWrapper = new IPUE_FormControllerModels.PageSection(pageSection);
        // pageSectionWrapper.sectionItems = estimationScheduleModels;

        // IPUE_FormControllerModels.DataWrapper wrapper = IPUE_FormControllerHelper.buildTableFromConsumptionSchedules(scheduleMap, new IPUE_FormControllerModels.DataWrapper(), false);
        // wrapper = IPUE_FormControllerHelper.sortTableRowsAndCells(wrapper);

        // for (IPUE_FormControllerModels.Table table : wrapper.tableByParentEstimationSchedule.values()) {
        //     IPUE_FormControllerModels.SectionItem sectionItem = new IPUE_FormControllerModels.SectionItem(table);
        //     System.debug('SectionItem : ' + sectionItem);
        //     pageSectionWrapper.sectionItems.add(sectionItem);
        // }

        // for (IPUE_FormControllerModels.SectionItem item : pageSectionWrapper.sectionItems) {
        //     System.debug('item: ' + item);
        // }

        //return JSON.serialize(pageSectionWrapper);

    }

    public static Account createAccount(Boolean doInsert){

        sObject sObjAccount = new Account();
        List<Account> accList = new List<Account>();

        sObjAccount = UtilityTest.putFieldRecord(sObjAccount, UtilityTestData.mAccountData);

        if (doInsert) {
            accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjAccount});
            return accList[0];
        } else {
            return (Account)sObjAccount;
        }

    }

    public static Opportunity createOpportunity(Boolean doInsert, Account testAccount){

        sObject sObjOpportunity = new Opportunity();
        List<Opportunity> oppList = new List<Opportunity>();

        sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity, UtilityTestData.mOpportunityData);
        sObjOpportunity.put('AccountId', testAccount.Id);

        if (doInsert) {
            oppList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity});
            return oppList[0];
        } else {
            return (Opportunity)sObjOpportunity;
        }

    }

    public static Contact createContact(Boolean doInsert, Account testAccount){

        sObject sObjContact = new Contact();
        List<Contact> contactList = new List<Contact>();

        sObjContact = UtilityTest.putFieldRecord(sObjContact, UtilityTestData.mContactData); 
        sObjContact.put('AccountId', testAccount.Id);

        if (doInsert) {
            contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObjContact});
            return contactList[0];
        } else {
            return (Contact)sObjContact;
        }

    }

    public static SBQQ__Quote__c createQuote(Boolean doInsert, Account testAccount, Opportunity testOpp, Contact testContact){

        sObject sObjQuote = new SBQQ__Quote__c();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();

        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', testAccount.Id + '');
        UtilityTestData.mSBQuoteData.put('SoldToAccount__c', testAccount.Id + '');
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', testAccount.Id + '');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c', testAccount.Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserAccount__c', testAccount.Id + '');
        UtilityTestData.mSBQuoteData.put('SoldToContact__c', testContact.Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserContact__c', testContact.Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', testOpp.Id + '');
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');

        sObjQuote = UtilityTest.putFieldRecord(sObjQuote, UtilityTestData.mSBQuoteData);

        if (doInsert) {
            quoteList = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObjQuote});
            return quoteList[0];
        } else {
            return (SBQQ__Quote__c)sObjQuote;
        }

    }

    public static blng__LegalEntity__c createLegalEntity(Boolean doInsert){

        sObject sObjLegalEntity = new blng__LegalEntity__c();
        List<blng__LegalEntity__c> legalEntityList = new List<blng__LegalEntity__c>();

        sObjLegalEntity = UtilityTest.putFieldRecord(sObjLegalEntity, UtilityTestData.mLegalEntityData);

        if (doInsert) {
            legalEntityList = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObjLegalEntity});
            return legalEntityList[0];
        } else {
            return (blng__LegalEntity__c)sObjLegalEntity;
        }

    }

    public static Order createOrder(Boolean doInsert, Account testAccount, Opportunity testOpp, blng__LegalEntity__c testLegalEntity){

        sObject sObjOrder = new Order();
        List<Order> orderList = new List<Order>();

        sObjOrder = UtilityTest.putFieldRecord(sObjOrder, UtilityTestData.mOrderData);
        sObjOrder.put('AccountId', testAccount.Id);
        sObjOrder.put('OpportunityId', testOpp.Id);
        sObjOrder.put('Legal_Entity__c', testLegalEntity.Id);
        sObjOrder.put('EffectiveDate', Date.today());

        if (doInsert) {
            orderList = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObjOrder});
            return orderList[0];
        } else {
            return (Order)sObjOrder;
        }

    }

    public static Estimation_Summary__c createEstimationSummary(Boolean doInsert, Id opportunityId){
        Estimation_Summary__c sObjEstimationSummary = new Estimation_Summary__c();
        sObjEstimationSummary.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Form Based').getRecordTypeId();

        if(opportunityId != null){
            sObjEstimationSummary.Opportunity__c = opportunityId;
        }

        sObjEstimationSummary.Total_Required_IPUs__c = 1500;
        sObjEstimationSummary.Additional_Non_Production_IPUs__c = 500;
        sObjEstimationSummary.Final_IPU_Estimate__c = 2000; 
        sObjEstimationSummary.Total_Production_IPUs__c = 1750;
        sObjEstimationSummary.Room_For_Growth__c = 250;


        if (doInsert) {
            insert sObjEstimationSummary;
            return sObjEstimationSummary;
        } else {
            return (Estimation_Summary__c)sObjEstimationSummary; 
        }
    }

    public static Estimation_Summary_Line__c  createEstimationSummaryLine(Boolean doInsert, Id parentSummaryId, String serviceId){
        Estimation_Summary_Line__c objSummaryLine = new Estimation_Summary_Line__c();

        if(parentSummaryId != null){
            objSummaryLine.Estimation_Summary__c = parentSummaryId;
        }
        if(serviceId != null){
            objSummaryLine.Service_Id__c = serviceId;
        } else{
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueString = dateString + randomInt;
            objSummaryLine.Service_Id__c = uniqueString;
        }
        objSummaryLine.Unit_Of_Measure__c = 'Compute Hrs';
        objSummaryLine.Estimated_Quantity__c = 124;
        objSummaryLine.Required_IPUs__c = 1235;

        if(doInsert){
            insert objSummaryLine;
            return objSummaryLine;
        } else {
            return objSummaryLine;
        }


    }

    public static Product2 createProduct(Boolean doInsert){

        sObject sObjProduct = new Product2();
        List<Product2> prodList = new List<Product2>();

        sObjProduct = UtilityTest.putFieldRecord(sObjProduct, UtilityTestData.mProductData);

        if (doInsert) {
            prodList = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObjProduct});
            return prodList[0];
        } else {
            return (Product2)sObjProduct;
        }

    }

    public static ProductConsumptionSchedule createProductConsumptionSchedule(Boolean doInsert, Id consumptionSchedId, Id productId){

        sObject productSchedule = new ProductConsumptionSchedule(
            ConsumptionScheduleId = consumptionSchedId,
            ProductId = productId
        );

        if (doInsert) {
            return (ProductConsumptionSchedule) UtilityTest.makeInsert(new List<sObject>{productSchedule})[0];
        } else {
            return  (ProductConsumptionSchedule) productSchedule;
        }

    }

    public static List<Estimator_Collaborator__c> createEstimatorCollaborator(Boolean isInsert,List<Contact> lContact,Estimation_Summary__c estimationSummary){
        List<Estimator_Collaborator__c> lstEstimatorCollaborator = new List<Estimator_Collaborator__c>();
        for(Contact contactRec:lContact){
            Estimator_Collaborator__c collab = new Estimator_Collaborator__c();
            collab.Contact__c = contactRec.Id;
            collab.Estimation_Summary__c = estimationSummary.Id;
            lstEstimatorCollaborator.add(collab);
        }
        if(isInsert){
            insert lstEstimatorCollaborator;
            return lstEstimatorCollaborator;
        }else{
            return lstEstimatorCollaborator;
        }
    }
    ////////////////////////////////////////
    // Form-related objects
    ////////////////////////////////////////

    public static Form__c createForm(Boolean doInsert, String name){
        SObject form = new Form__c(
            Name = name,
            Active__c = true,
            Usage__c = 'Internal'
        );

        if (doInsert) {
            return (Form__c) UtilityTest.makeInsert(new List<sObject> {form})[0];
        } else {
            return (Form__c) form;
        }
    }

    public static Page__c createPage(Boolean doInsert, String name, Id formId){

        SObject page = new Page__c(
            Name = name,
            Page_Number__c = 1,
            Parent_Form__c = formId,
            Page_Description__c = 'testUtil Page Description'
        );

        if (doInsert) {
            return (Page__c) UtilityTest.makeInsert(new List<sObject> {page})[0];
        } else {
            return (Page__c) page;
        }
    }

    public static SDoc_Template__c createSDocTemplate(Boolean doInsert, Id formId, Id pageId){

        SObject template = new SDoc_Template__c(
            Sequence__c = 1, 
            Default__c = true, 
            Button_Label__c = 'Test Label',
            Form__c = formId,
            Page__c = pageId
        );

        if (doInsert) {
            return (SDoc_Template__c) UtilityTest.makeInsert(new List<sObject> {template})[0];
        } else {
            return (SDoc_Template__c) template;
        }
    }

    public static Page_Frame__c createPageFrame(Boolean doInsert, String name, Id pageId){

        SObject frame = new Page_Frame__c(
            Name = name,
            Row_Sequence__c = 1,
            Column_Percentage__c = 100,
            Column_Sequence__c = 1,
            Page__c = pageId
        );



        if (doInsert) {
            return (Page_Frame__c) UtilityTest.makeInsert(new List<sObject> {frame})[0];
        } else {
            return (Page_Frame__c) frame;
        }
    }

    public static Page_Section__c createPageSection(Boolean doInsert, String name, Id parentPage, Id parentFrame){

        SObject section = new Page_Section__c(
            Name = name,
            Integration_Section__c = false,
            Sequence__c = 1,
            Title_Visibility__c = 'Hide',
            Parent_Page__c = parentPage,
            Parent_Page_Frame__c = parentFrame
        );

        if (doInsert) {
            return (Page_Section__c) UtilityTest.makeInsert(new List<sObject> {section})[0];
        } else {
            return (Page_Section__c) section;
        }
    }

    public static ConsumptionSchedule createTable(Boolean doInsert, Id pageSectionId, String tableType) {

        ConsumptionSchedule table = createConsumptionSchedule(false, tableType, null);
        table.Active__c = true;
        table.Page_Section__c = pageSectionId;
        table.Sequence__c = 1;
        table.Data_Type__c = tableType;

        if (doInsert) {
            insert table;
        } 

        return table;

    }

    public static void createSchedulesAndTableCells(Id parentTableId, Id pageSectionId, Integer numRows, Integer numColumns, String namePrefix){

        List<Table_Cell__c> tableCellsToInsert = new List<Table_Cell__c>();

        Integer totalCells = numRows * numColumns;
        Decimal columnNumber = 1;
        
        for (Integer i = 0; i < totalCells; i++) {

            ConsumptionSchedule schedule = createConsumptionSchedule(false, namePrefix + String.valueOf(i), null);
            schedule.Active__c = true;
            schedule.Page_Section__c = pageSectionId;

            // Create 3 different types of rows
            if (i < 3) {
                schedule.Data_Type__c = IPUE_CONSTANTS.STATIC_TEXT;
            } else if (i < 5) {
                schedule.Data_Type__c = IPUE_CONSTANTS.NUM;
            } else if (i < 6) {
                schedule.Data_Type__c = IPUE_CONSTANTS.CALCULATED;
            }else {
                schedule.Data_Type__c = IPUE_CONSTANTS.TEXT;
            }

            System.debug('+++ schedule name ' + schedule.Name);

            // Can't insert CS in bulk when also setting Matching Attribute
            insert schedule;
            
            Table_Cell__c cell = new Table_Cell__c();
            cell.Child_Estimation_Schedule__c = schedule.Id;
            cell.Parent_Estimation_Schedule__c = parentTableId;

            if (i < 3) {
                cell.Row_Number__c = 0;
            } else if (i < 6) { 
                cell.Row_Number__c = 1;
            } else {
                cell.Row_Number__c = 2;
            }    

            // Restart column count when greater than total number of columns
            if (columnNumber > numColumns) {
                columnNumber = 1;
            }

            cell.Column_Number__c = columnNumber;
            columnNumber++;       

            tableCellsToInsert.add(cell);

        }

        insert tableCellsToInsert;

    }

    ////////////////////////////////////////
    // Calculation-related objects
    ////////////////////////////////////////

    public static Map<String, Schema.RecordTypeInfo> scheduleTypesByName = ConsumptionSchedule.getSObjectType().getDescribe().getRecordTypeInfosByName();

    public static ConsumptionSchedule createConsumptionSchedule(Boolean doInsert, String name, String recordTypeName) {
        if (String.isBlank(recordTypeName)) {
            recordTypeName = 'Estimation Schedule';
        }
        SObject cs = new ConsumptionSchedule(
            Name = name,
            BillingTerm = 1,
            BillingTermUnit = 'Month',
            Type = 'Range',
            RatingMethod = 'Tier',
            RecordTypeId = scheduleTypesByName.get(recordTypeName).getRecordTypeId(),
            Active__c = true
        );

        if (doInsert) {
            return (ConsumptionSchedule) UtilityTest.makeInsert(new List<sObject> {cs})[0];
        } else {
            return (ConsumptionSchedule) cs;
        }
    }


    public static ConsumptionRate createConsumptionRate(Boolean doInsert, Id scheduleId, Decimal lower, Decimal upper, Decimal outcome, Integer processingOrder) {
        SObject rate = new ConsumptionRate(
            ConsumptionScheduleId = scheduleId,
            LowerBound = Integer.valueOf(lower),
            UpperBound = Integer.valueOf(upper),
            IPU_Lower_Bound__c = lower,
            IPU_Upper_Bound__c = upper,
            Outcome__c = outcome,
            ProcessingOrder = processingOrder,
            PricingMethod = 'PerUnit',
            Price = 0
        );

        if (doInsert) {
            return (ConsumptionRate) UtilityTest.makeInsert(new List<sObject> { rate })[0];
        } else {
            return (ConsumptionRate) rate;
        }
    }

    public static Estimation_Output__c createEstimationOutput(Boolean doInsert, String name, Id scheduleId, Decimal value) {
        SObject output = new Estimation_Output__c(
            Name = name,
            Estimation_Schedule__c = scheduleId,
            User_Value__c = String.valueOf(value)
        );

        if (doInsert) {
            return (Estimation_Output__c) UtilityTest.makeInsert(new List<sObject> { output })[0];
        } else {
            return (Estimation_Output__c) output;
        }
    }

    public static Calculation__c createCalculation(Boolean doInsert, String name, String formula) {
        SObject calc = new Calculation__c(
            Name = name,
            Formula__c = formula
        );

        if (doInsert) {
            return (Calculation__c) UtilityTest.makeInsert(new List<sObject> { calc })[0];
        } else {
            return (Calculation__c) calc;
        }
    }

    ////////////////////////////////////////
    // Integration-related objects
    ////////////////////////////////////////

    public static API_Information__c createApiInformation(Boolean doInsert, String name, String url, String type, String key, String namedCredential, Decimal minutesToCheck) {
        SObject mapping = new API_Information__c(
            Name = name,
            API_URL__c = url,
            Security_Header_Type__c = type,
            Security_Key__c = key,
            Named_Credential__c = namedCredential,
            Minutes_to_Expire__c = minutesToCheck
        );

        if (doInsert) {
            return (API_Information__c) UtilityTest.makeInsert(new List<SObject> { mapping })[0];
        } else {
            return (API_Information__c) mapping;
        }
    }

    public static API_Field_Mapping__c createFieldMapping(Boolean doInsert, String name, String fieldName, Id headerId, String defaultValue) {
        SObject mapping = new API_Field_Mapping__c(
            Name = name,
            API_Field_Name__c = fieldName,
            API_Header__c = headerId,
            Value__c = defaultValue
        );

        if (doInsert) {
            return (API_Field_Mapping__c) UtilityTest.makeInsert(new List<SObject> { mapping })[0];
        } else {
            return (API_Field_Mapping__c) mapping;
        }
    }

    public static Lightning_Service_Template__c createServiceTemplate(Boolean doInsert, String name, String content, Id pageSectionId) {
        SObject template = new Lightning_Service_Template__c(
            Name = name,
            Content__c = content,
            Page_Section__c = pageSectionId,
            Sequence__c = 1
        );

        if (doInsert) {
            return (Lightning_Service_Template__c) UtilityTest.makeInsert(new List<SObject> { template })[0];
        } else {
            return (Lightning_Service_Template__c) template;
        }
    }

    public static Lightning_Service_Member__c createServiceMember(Boolean doInsert, Id mappingId, Id templateId) {
        SObject template = new Lightning_Service_Member__c(
            API_Field_Mapping__c = mappingId,
            Lightning_Service_Template__c = templateId
        );

        if (doInsert) {
            return (Lightning_Service_Member__c) UtilityTest.makeInsert(new List<SObject> { template })[0];
        } else {
            return (Lightning_Service_Member__c) template;
        }
    }
    
    public static Opportunity_IPU_Services__c createOppIPUServices(Id oppId, Id prodId, Boolean doInsert) {
        SObject template = new Opportunity_IPU_Services__c(
            Forecast_Product__c = 'Cloud Data Governance and Catalog',
            Product_Family__c  = 'DQ',
            Opportunity__c = oppId,
            Product__c = prodId,
            Required_IPUs__c  = 10,
            Service_Name__c  = 'test'
            
        );

        if (doInsert) {
            return (Opportunity_IPU_Services__c) UtilityTest.makeInsert(new List<SObject> { template })[0];
        } else {
            return (Opportunity_IPU_Services__c) template;
        }
    }


}