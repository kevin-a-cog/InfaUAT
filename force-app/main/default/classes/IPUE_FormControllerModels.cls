/*
    @Author:        Advanced Technology Group
    @Created Date:  February 2022
    @Description:   This is a helper class to hold all inner classes used in the IPUE_FormController and IPUE_FormControllerHelper classes
                    to better organize logic. This class is covered by IPUE_FormControllerTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.      Description                                                 Tag

    Stephanie Viereckl  Feb 2022      IPUE-153/193  Refactor into own class for better organization of models
    Chandana Gowda      10-Mar-2022   IPUE-156      Changed to without sharing and added new attribute hasReadOnlyAccess <T1>
    Saurabh Khandelwal  10-Mar-2022   IPUE-160      Added new variables in Data wrapper and added feeds related logic.   <T2>     
    KAPIL TILWANI       22 JUNE 2023  SALESRT-15017 Added Condition to display static text and Number validation.        
    
    ********************************************************************************************************************************************
*/
public without sharing class IPUE_FormControllerModels {

    public class DataWrapper {
        @AuraEnabled public AccountDataModel accountModel;
        @AuraEnabled public OppDataModel oppModel;
        @AuraEnabled public Boolean hasReadOnlyAccess = false; //<T1> - Set to true if the current user has read only access
        @AuraEnabled public Form form;
        @AuraEnabled public Integer integrationCount = 0;
        @AuraEnabled public Decimal totalEstimation;
        @AuraEnabled public Map<Id, Estimation_Output__c> outputMap;
        @AuraEnabled public Map<Id, Integer> pageSectionTotalMap;
        @AuraEnabled public List<Id> pageSectionIds = new List<Id>();
        //attributes for chatter fuctionality to store custom class for icon.
        @AuraEnabled public String chatterIconClass;
        @AuraEnabled public Boolean isUserInternal;
        
        public Set<Id> tableCellSchedules = new Set<Id>();
        public Map<Id, Table> tableByParentEstimationSchedule = new Map<Id, Table>();
        
    }

    public without sharing class AccountDataModel {

        @AuraEnabled public String name;
        @AuraEnabled public String accountNumber;
        @AuraEnabled public String address;

        public AccountDataModel(Id recordId) {

            Account account = [
                SELECT Id, Name, New_Org_Account_Number__c, BillingAddress
                FROM Account
                WHERE Id = :recordId
                LIMIT 1
            ];

            this.name = account.Name;
            this.accountNumber = account.New_Org_Account_Number__c;
            if (this.accountNumber == null) {
                this.accountNumber = '';
            }

            if (account.BillingAddress != null) {
                this.address = account.BillingAddress.getStreet() + ', ' + account.BillingAddress.getCity() + ', ' + account.BillingAddress.getState() + ', ' + account.BillingAddress.getPostalCode();
            }

        }

    }

    public without sharing class OppDataModel {

        @AuraEnabled public Boolean isClosed;

        public OppDataModel(Id recordId) {

            String stageName;

            if (recordId != null) {
                Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :recordId LIMIT 1];
                stageName = opp.StageName;
            }

            this.isClosed = stageName == 'Closed Won' || stageName == 'Closed Lost' ? true : false;

        }

    }

    public class Form {

        @AuraEnabled public Id Id;
        @AuraEnabled public Id estimationSummaryId;
        @AuraEnabled public List<PageWrapper> pages = new List<PageWrapper>();

        public Form (Form__c form) {
            this.Id = form.Id;
        }

    }

    public class PageWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public Decimal pageNumber;
        @AuraEnabled public String name;
        @AuraEnabled public List<Frame> frames = new List<Frame>();
        @AuraEnabled public List<SDocButton> sDocButtons = new List<SDocButton>();

        public PageWrapper(Page__c page){
            this.Id = page.Id;
            this.parentId = page.Parent_Form__c;
            this.pageNumber = page.Page_Number__c;
            this.name = page.Page_Name__c;
        }
    }

    public class Frame {

        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean isInputDriven;
        @AuraEnabled public Boolean isDisplayOnly;
        @AuraEnabled public Decimal columnSequence;
        @AuraEnabled public Decimal rowSequence;
        @AuraEnabled public Integer size;
        @AuraEnabled public String columnSize;
        @AuraEnabled public List<PageSection> pageSections = new List<PageSection>();

        public Frame(Page_Frame__c pageFrame) {
            this.Id = pageFrame.Id;
            this.parentId = pageFrame.Page__c;
            this.name = pageFrame.Name;
            this.isInputDriven = pageFrame.Frame_Type__c == 'Input-Driven' ? true : false;
            this.isDisplayOnly = pageFrame.Frame_Type__c == 'Display Only' ? true : false;
            this.columnSequence = pageFrame.Column_Sequence__c;
            this.rowSequence = pageFrame.Row_Sequence__c;
            this.size = getSize(pageFrame.Column_Percentage__c);
            this.columnSize = 'slds-col slds-size_' + this.size + '-of-12';
        }

        private Integer getSize(Decimal percentage){

            if (percentage > 0) {
                return Math.round((percentage/100) * 12);
            } else {
                return 0;
            }

        }

    }

    public class PageSection {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal numerator = 0;
        @AuraEnabled public Decimal denominator = 0;
        @AuraEnabled public Decimal progress = 0;
        @AuraEnabled public Boolean inputMissing = true;
        @AuraEnabled public Boolean showSection = false;
        @AuraEnabled public Boolean showTitle = false;
        @AuraEnabled public Boolean disableCheckbox = false;
        @AuraEnabled public Boolean showProgress = false;
        @AuraEnabled public Boolean showSectionTotal = false;
        @AuraEnabled public Integer sectionTotal = 0;
        @AuraEnabled public Boolean showTotalIpuSection = false;
        @AuraEnabled public String totalLabel = 'Total IPU'; // Default Value
        @AuraEnabled public Boolean hasSchedules = false;
        @AuraEnabled public List<SectionItem> sectionItems = new List<SectionItem>();

        public PageSection(Page_Section__c pageSection){
            this.Id = pageSection.Id;
            this.parentId = pageSection.Parent_Page_Frame__c;
            this.sequence = pageSection.Sequence__c;
            this.name = pageSection.Page_Sections_Name__c;
            this.showProgress = pageSection.Progress__c;
            this.showSectionTotal = pageSection.Display_Page_Section_Total_Inline__c;
            this.showTotalIpuSection = pageSection.Display_Estimation_Summary_Total__c;
            this.totalLabel = pageSection.Display_Label_Rich_Text__c != null ? pageSection.Display_Label_Rich_Text__c : this.totalLabel;

            if (pageSection.Title_Visibility__c == 'Visible') {
                this.showTitle = true;
            } else {
                this.showTitle = false;
                this.disableCheckbox = true;
                this.showSection = true;
            }

        }

    }

    public class SectionItemComparable implements Comparable {

        public SectionItem sectionItem;

        public SectionItemComparable(SectionItem sectionItem) {
            this.sectionItem = sectionItem;
        }
    
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            SectionItemComparable compareItem = (SectionItemComparable)compareTo;
    
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (sectionItem.sequence > compareItem.sectionItem.sequence) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (sectionItem.sequence < compareItem.sectionItem.sequence) {
                // Set return value to a negative value.
                returnValue = -1;
            }
    
            return returnValue;       
        }

    }

    public class SectionItem {
        @AuraEnabled public Boolean isTemplate = false;
        @AuraEnabled public Boolean isSchedule = false;
        @AuraEnabled public Boolean isTable = false;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public LightningServiceTemplate template;
        @AuraEnabled public EstimationSchedule schedule;
        @AuraEnabled public Table table;
        @AuraEnabled public Id Id;

        public SectionItem(LightningServiceTemplate template) {
            this.template = template;
            this.isTemplate = true;
            this.sequence = template.sequence;
            this.Id = template.templateId;
        }

        public SectionItem(EstimationSchedule schedule) {
            this.schedule = schedule;
            this.isSchedule = true;
            this.sequence = schedule.sequence;
            this.Id = schedule.Id;
        }

        public SectionItem(Table table) {
            this.table = table;
            this.isTable = true;
            this.sequence = table.sequence;
            this.Id = table.parentEstimationId;
        }

    }

    public class LightningServiceTemplate {
        @AuraEnabled public String name;
        @AuraEnabled public Id templateId;
        @AuraEnabled public Id pageSectionId;
        @AuraEnabled public String content;
        @AuraEnabled public Boolean contentFound;
        @AuraEnabled public Boolean hasIntegrations = false;
        @AuraEnabled public Decimal sequence;

        public LightningServiceTemplate(String name, Id templateId, Id pageSectionId, string jsonResponse, String content) {
            this.name = name;
            this.templateId = templateId;
            this.pageSectionId = pageSectionId;
            this.content = content;
        }

        public LightningServiceTemplate(String name, Id templateId, Id pageSectionId, string jsonResponse, String content, Decimal sequence) {
            this.name = name;
            this.templateId = templateId;
            this.pageSectionId = pageSectionId;
            this.content = content;
            this.sequence = sequence;
        }

    }

    // Represents the ConsumptionSchedule object
    public class EstimationSchedule {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public EstimationOutput output;
        @AuraEnabled public Boolean isInput = false;
        @AuraEnabled public Boolean isPicklist = false;
        @AuraEnabled public Boolean isRequired = false;
        @AuraEnabled public Boolean showSchedule = false;
        @AuraEnabled public Boolean isCalculated = false;
        @AuraEnabled public Boolean isTypeNumber = false;
        @AuraEnabled public Boolean showStaticIcon = true;
        @AuraEnabled public String defaultValue;
        @AuraEnabled public List<Combobox> picklistValues = new List<Combobox>();

        public EstimationSchedule(ConsumptionSchedule schedule, Boolean isClosed){
            this.Id = schedule.Id;
            this.parentId = schedule.Page_Section__c;
            this.sequence = schedule.Sequence__c;
            this.showSchedule = this.sequence > 0 ? true : false;
            this.description = schedule.Consumption_Description__c;

            if (!schedule.Estimation_Outputs__r.isEmpty()) {
                this.output = new EstimationOutput(schedule, isClosed);
            }

            this.type = schedule.Data_Type__c;
            this.isTypeNumber = (schedule.Data_Type__c == IPUE_CONSTANTS.NUM ||
                                schedule.Data_Type__c == IPUE_CONSTANTS.CALCULATED) ? true : false;
            this.isRequired = schedule.Required__c;

            if (this.type == IPUE_CONSTANTS.PICKLIST && schedule.Picklist_Values__c != null) {

                this.isPicklist = true;

                for (String option : schedule.Picklist_Values__c.split(',')) {
                    this.picklistValues.add(new Combobox(option));
                }

            } else if (this.type == IPUE_CONSTANTS.CALCULATED) {
                this.isCalculated = true;
            } else if(this.type == IPUE_CONSTANTS.STATIC_TEXT){
                this.isInput = false;
                this.showStaticIcon = false;
            }else{
                this.isInput = true;
            }

        }
    }

    public class EstimationOutput {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id scheduleId;
        @AuraEnabled public String value;
        //storing custom class name for chatter icon.
        @AuraEnabled public String chatterIconClass;
        @AuraEnabled public String picklistValue;
        @AuraEnabled public String notes;
        @AuraEnabled public Boolean hasNotes = false;

        public EstimationOutput(ConsumptionSchedule schedule, Boolean isClosed){

            Estimation_Output__c output = schedule.Estimation_Outputs__r[0];
            this.Id = output.Id;
            this.scheduleId = schedule.Id;
            this.notes = output.Notes__c;
            this.hasNotes = output.Notes__c != null ? true : false;
            //checking for user is internal & inernal feed user on output is checked && 
            // if user is external & external feed user on output is checked
            if(UserInfo.getUserType()=='Standard' && output.Feed_Internal_User__c){
                this.chatterIconClass='svgClass';
            }else{
                //for external user feed external check.
                if(output.Feed_External_User__c){
                    this.chatterIconClass='svgClass';
                }
            } 
            if (!isClosed && schedule.Data_Type__c != output.Original_Data_Type__c) {
                this.value = schedule.Default__c;
            } else {
                this.value = output.User_Value__c;
            }

            if (schedule.Data_Type__c == IPUE_CONSTANTS.PICKLIST && this.value != null) {
                this.picklistValue =  this.value.deleteWhitespace().toLowerCase();
            }

        }

        public EstimationOutput(ConsumptionSchedule schedule, Boolean isClosed, Estimation_Output__c output){

            this.Id = output.Id;
            this.scheduleId = schedule.Id;
            this.notes = output.Notes__c;
            this.hasNotes = output.Notes__c != null ? true : false;
            //checking for user is internal & inernal feed user on output is checked && 
            // if user is external & external feed user on output is checked
            if(UserInfo.getUserType()=='Standard' && output.Feed_Internal_User__c){
                this.chatterIconClass='svgClass';
            }else{
                //for external user feed external check.
                if(output.Feed_External_User__c){
                    this.chatterIconClass='svgClass';
                }
            } 
            if (!isClosed && schedule.Data_Type__c != output.Original_Data_Type__c) {
                this.value = schedule.Default__c;
            } else {
                this.value = output.User_Value__c;
            }

            if (schedule.Data_Type__c == IPUE_CONSTANTS.PICKLIST && this.value != null) {
                this.picklistValue =  this.value.deleteWhitespace().toLowerCase();
            }

        }

    }

    public class Table {
        @AuraEnabled public List<TableRow> rows = new List<TableRow>();
        @AuraEnabled public TableRow header = new TableRow();
        @AuraEnabled public Map<Integer, TableRow> rowsByRowNumber = new Map<Integer, TableRow>();
        @AuraEnabled public Id parentEstimationId;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public Integer highestColumnNumber;
        @AuraEnabled public Integer highestRowNumber;
        @AuraEnabled public Boolean isElastic;
        @AuraEnabled public Boolean isFixed;
    }

    public class TableRow {
        @AuraEnabled public List<TableCell> cells = new List<TableCell>();
        @AuraEnabled public Map<Integer, TableCell> cellsByColumnNumber = new Map<Integer, TableCell>();
        @AuraEnabled public Integer rowNumber;
    }

    public class TableCell {
        @AuraEnabled public Integer rowNumber;
        @AuraEnabled public Integer columnNumber;
        @AuraEnabled public String defaultValue;
        @AuraEnabled public String description;
        @AuraEnabled public String dataType;
        @AuraEnabled public Boolean isPicklist = false;
        @AuraEnabled public Boolean isCalculated = false;
        @AuraEnabled public Boolean isNumber = false;
        @AuraEnabled public EstimationOutput output;
        @AuraEnabled public List<Combobox> picklistValues = new List<Combobox>();

        public TableCell(){}

        public TableCell(ConsumptionSchedule schedule, Boolean isClosed, Estimation_Output__c output){
            this.rowNumber = Integer.valueOf(output.Row_Number__c);
            this.columnNumber = Integer.valueOf(output.Column_Number__c);
            this.description = removeHTML(schedule.Consumption_Description__c);
            this.dataType = schedule.Data_Type__c;
            this.output = new EstimationOutput(schedule, isClosed, output);

            if(this.dataType == IPUE_CONSTANTS.CALCULATED || this.dataType == IPUE_CONSTANTS.NUM){
                this.isNumber = true;
            }else if (this.dataType == IPUE_CONSTANTS.PICKLIST && schedule.Picklist_Values__c != null) {

                this.isPicklist = true;

                for (String option : schedule.Picklist_Values__c.split(',')) {
                    this.picklistValues.add(new Combobox(option));
                }

            } else if (this.dataType == IPUE_CONSTANTS.CALCULATED) {
                this.isCalculated = true;
            }

        }
    }

    public class SDocButton {
        @AuraEnabled public Boolean isDefault;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public String label;
        @AuraEnabled public Id templateId;

        public SDocButton(SDoc_Template__c sDocTemplate){
            this.isDefault = sDocTemplate.Default__c;
            this.sequence = sDocTemplate.Sequence__c;
            this.label = sDocTemplate.Button_Label__c;
            this.templateId = sDocTemplate.Template_Id__c;
        }
    }

    public class Combobox {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public Combobox(String option){
            this.label = option;
            this.value = option.deleteWhitespace().toLowerCase();
        }
    }

    /************************* Helper Methods *************************/

    private static String removeHTML(String stringValue){

        if (stringValue != null) {
            return stringValue.replaceAll('<[^>]+>','');
        } else {
            return '';
        }

    }

}