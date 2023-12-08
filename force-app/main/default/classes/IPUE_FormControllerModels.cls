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
    Kevin Antonioli     22 OCT 2023   PNP-512       Add properties to existing data models to enhance performance/UX     <T3>
    Kevin Antonioli     16 NOV 2023   PNP-515       Add properties to existing data models to enhance performance/UX     <T4>

    ********************************************************************************************************************************************
*/
public without sharing class IPUE_FormControllerModels {
    public IPUE_FormControllerModels() {
    }
    // prettier-ignore
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
        @AuraEnabled public List<Id> initialSelectedSectionIds = new List<Id>(); // <T4>
        //attributes for chatter fuctionality to store custom class for icon.
        @AuraEnabled public String chatterIconClass;
        @AuraEnabled public Boolean isUserInternal;
        @AuraEnabled public List<Id> crossDependentSectionIds = new List<Id>(); // <T4>


        public Set<Id> tableCellSchedules = new Set<Id>();
        public Map<Id, Table> tableByParentEstimationSchedule = new Map<Id, Table>();
    }
    // prettier-ignore
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
                this.address =
                    account.BillingAddress.getStreet() +
                    ', ' +
                    account.BillingAddress.getCity() +
                    ', ' +
                    account.BillingAddress.getState() +
                    ', ' +
                    account.BillingAddress.getPostalCode();
            }
        }
    }
    // prettier-ignore
    public without sharing class OppDataModel {
        @AuraEnabled
        public Boolean isClosed;

        public OppDataModel(Id recordId) {
            String stageName;

            if (recordId != null) {
                Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :recordId LIMIT 1];
                stageName = opp.StageName;
            }

            this.isClosed = stageName == 'Closed Won' || stageName == 'Closed Lost' ? true : false;
        }
    }
    // prettier-ignore
    public class Form {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id estimationSummaryId;
        @AuraEnabled public List<PageWrapper> pages = new List<PageWrapper>();

        public Form(Form__c form) {
            this.Id = form.Id;
        }
    }
    // prettier-ignore
    public class PageWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public Decimal pageNumber;
        @AuraEnabled public String name;
        @AuraEnabled public List<Frame> frames = new List<Frame>();
        @AuraEnabled public List<SDocButton> sDocButtons = new List<SDocButton>();

        public PageWrapper(Page__c page) {
            this.Id = page.Id;
            this.parentId = page.Parent_Form__c;
            this.pageNumber = page.Page_Number__c;
            this.name = page.Page_Name__c;
        }
    }
    // prettier-ignore
    public class Frame {
        @AuraEnabled public Estimation_Summary__c estimationSummaryRecord; // <T3>
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

        // added estimationSummaryRecord param for <T3>
        public Frame(Page_Frame__c pageFrame, Estimation_Summary__c estimationSummaryRecord) {
            this.estimationSummaryRecord = estimationSummaryRecord;
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

        private Integer getSize(Decimal percentage) {
            if (percentage > 0) {
                return Math.round((percentage / 100) * 12);
            } else {
                return 0;
            }
        }
    }
    // prettier-ignore
    public class PageSection {
        @AuraEnabled public Page_Section__c pageSectionRecord; // <T3>
        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public Decimal pageNumber; // <T3>
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
        @AuraEnabled public Integer sectionTotalFromLine = 0;
        @AuraEnabled public Boolean showTotalIpuSection = false;
        @AuraEnabled public String  totalLabel = 'Total IPU'; // Default Value
        @AuraEnabled public Boolean expansionByDefault = false; // <T3>
        @AuraEnabled public Boolean selectedByUser = false; // <T3>
        @AuraEnabled public Boolean preChecked = false; // <T3>
        @AuraEnabled public Boolean newlyCheckedOnceBefore = false; // <T3>
        @AuraEnabled public Boolean hasSchedules = false;
        @AuraEnabled public Boolean noEstSummaryLines = false; // <T3>
        @AuraEnabled public Boolean greyOutProgressRingOnPageLoad = false; // <T3>
        @AuraEnabled public Boolean tableProgressRingsAssembled = false; // <T3>
        @AuraEnabled public Boolean tableLockedFlag = true; // <T3>
        @AuraEnabled public Boolean hasTables = false; // <T3>
        @AuraEnabled public Id estimationSummaryFormId; // <T3>
        @AuraEnabled public Boolean isCrossDependent = false; // <T4>
        @AuraEnabled public List<SectionItem> sectionItems = new List<SectionItem>();

        public PageSection(Page_Section__c pageSectionRecord) {
            this.pageSectionRecord = pageSectionRecord;
            this.Id = pageSectionRecord.Id;
            this.parentId = pageSectionRecord.Parent_Page_Frame__c;
            this.pageNumber = pageSectionRecord.Parent_Page_Frame__r.Page__r.Page_Number__c;
            this.sequence = pageSectionRecord.Sequence__c;
            this.name = pageSectionRecord.Page_Sections_Name__c;
            this.showProgress = pageSectionRecord.Progress__c;
            this.showSectionTotal = pageSectionRecord.Display_Page_Section_Total_Inline__c;
            this.showTotalIpuSection = pageSectionRecord.Display_Estimation_Summary_Total__c;
            this.totalLabel = pageSectionRecord.Display_Label_Rich_Text__c != null ? pageSectionRecord.Display_Label_Rich_Text__c : this.totalLabel;
            this.expansionByDefault = pageSectionRecord.Expansion_By_Default__c; // <T3>

            if (pageSectionRecord.Title_Visibility__c == 'Visible') {
                this.showTitle = true;
            } else {    
                this.showTitle = false;
                this.disableCheckbox = true;
                this.showSection = true;
            }

            // <T3>:
            if(pageSectionRecord.Expansion_By_Default__c){
                this.expansionByDefault = true;
                this.disableCheckbox = true;
                this.showSection = true;
                this.preChecked = true;
            } else if(!pageSectionRecord.Estimation_Summary_Lines__r.isEmpty()) {
                if(pageSectionRecord.Estimation_Summary_Lines__r[0].Selected_By_User__c) {
                    if(pageSectionRecord.Estimation_Summary_Lines__r[0].Required_IPUs__c != null) {
                        this.sectionTotalFromLine = Integer.valueOf(pageSectionRecord.Estimation_Summary_Lines__r[0].Required_IPUs__c);
                    }
                    this.showSection = true;
                    this.preChecked = true;
                } else {
                    this.greyOutProgressRingOnPageLoad = true;
                }
            } else if(pageSectionRecord.Estimation_Summary_Lines__r.isEmpty()) {
                this.noEstSummaryLines = true; 
            }

            // <T4>: 
            this.isCrossDependent = pageSectionRecord.Cross_Dependent_On_Other_Sections__c;
        }
    }
    // prettier-ignore
    public class SectionItemComparable implements Comparable {
        public SectionItem sectionItem;

        public SectionItemComparable(SectionItem sectionItem) {
            this.sectionItem = sectionItem;
        }

        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            SectionItemComparable compareItem = (SectionItemComparable) compareTo;

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
    // prettier-ignore
    public class SectionItem {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id parentId; // <T03>
        @AuraEnabled public Boolean isTemplate = false;
        @AuraEnabled public Boolean isSchedule = false;
        @AuraEnabled public Boolean isTable = false;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public LightningServiceTemplate template;
        @AuraEnabled public EstimationSchedule schedule;
        @AuraEnabled public Table table;

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

        public SectionItem(Table table, PageSection pageSection) {
            this.Id = table.parentEstimationId;
            this.parentId = pageSection.Id; // <T03>
            this.table = table;
            this.isTable = true;
            this.sequence = table.sequence;
            table.parentPageSectionId = pageSection.Id; // <T03>     
        }
    }
    // prettier-ignore
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

        public LightningServiceTemplate(
            String name,
            Id templateId,
            Id pageSectionId,
            string jsonResponse,
            String content,
            Decimal sequence
        ) {
            this.name = name;
            this.templateId = templateId;
            this.pageSectionId = pageSectionId;
            this.content = content;
            this.sequence = sequence;
        }
    }
    // Represents the ConsumptionSchedule object
    // prettier-ignore
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

        public EstimationSchedule(ConsumptionSchedule schedule, Boolean isClosed) {
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
                schedule.Data_Type__c == IPUE_CONSTANTS.CALCULATED)
                ? true
                : false;
            this.isRequired = schedule.Required__c;

            if (this.type == IPUE_CONSTANTS.PICKLIST && schedule.Picklist_Values__c != null) {
                this.isPicklist = true;

                for (String option : schedule.Picklist_Values__c.split(',')) {
                    this.picklistValues.add(new Combobox(option));
                }
            } else if (this.type == IPUE_CONSTANTS.CALCULATED) {
                this.isCalculated = true;
            } else if (this.type == IPUE_CONSTANTS.STATIC_TEXT) {
                this.isInput = false;
                this.showStaticIcon = false;
            } else {
                this.isInput = true;
            }
        }       
    }
    // prettier-ignore
    public class EstimationOutput {
        @AuraEnabled public Id Id;
        @AuraEnabled public Id scheduleId;
        @AuraEnabled public String value;
        //storing custom class name for chatter icon.
        @AuraEnabled public String chatterIconClass;
        @AuraEnabled public String picklistValue;
        @AuraEnabled public String notes;
        @AuraEnabled public Boolean hasNotes = false;

        public EstimationOutput(ConsumptionSchedule schedule, Boolean isClosed) {
            Estimation_Output__c output = schedule.Estimation_Outputs__r[0];
            this.Id = output.Id;
            this.scheduleId = schedule.Id;
            this.notes = output.Notes__c;
            this.hasNotes = output.Notes__c != null ? true : false;
            //checking for user is internal & inernal feed user on output is checked &&
            // if user is external & external feed user on output is checked
            if (UserInfo.getUserType() == 'Standard' && output.Feed_Internal_User__c) {
                this.chatterIconClass = 'svgClass';
            } else {
                //for external user feed external check.
                if (output.Feed_External_User__c) {
                    this.chatterIconClass = 'svgClass';
                }
            }
            if (!isClosed && schedule.Data_Type__c != output.Original_Data_Type__c) {
                this.value = schedule.Default__c;
            } else {
                this.value = output.User_Value__c;
            }

            if (schedule.Data_Type__c == IPUE_CONSTANTS.PICKLIST && this.value != null) {
                this.picklistValue = this.value.deleteWhitespace().toLowerCase();
            }
        }

        public EstimationOutput(ConsumptionSchedule schedule, Boolean isClosed, Estimation_Output__c output) {
            this.Id = output.Id;
            this.scheduleId = schedule.Id;
            this.notes = output.Notes__c;
            this.hasNotes = output.Notes__c != null ? true : false;
            //checking for user is internal & inernal feed user on output is checked &&
            // if user is external & external feed user on output is checked
            if (UserInfo.getUserType() == 'Standard' && output.Feed_Internal_User__c) {
                this.chatterIconClass = 'svgClass';
            } else {
                //for external user feed external check.
                if (output.Feed_External_User__c) {
                    this.chatterIconClass = 'svgClass';
                }
            }
            if (!isClosed && schedule.Data_Type__c != output.Original_Data_Type__c) {
                this.value = schedule.Default__c;
            } else {
                this.value = output.User_Value__c;
            }

            if (schedule.Data_Type__c == IPUE_CONSTANTS.PICKLIST && this.value != null) {
                this.picklistValue = this.value.deleteWhitespace().toLowerCase();
            }
        }
    }
    // prettier-ignore
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
        @AuraEnabled public Id parentPageSectionId; // <T3>
        @AuraEnabled public Boolean isLocked = true; // <T03>

    }
    // prettier-ignore
    public class TableRow {
        @AuraEnabled public List<TableCell> cells = new List<TableCell>();
        @AuraEnabled public Map<Integer, TableCell> cellsByColumnNumber = new Map<Integer, TableCell>();
        @AuraEnabled public Integer rowNumber;
    }
    // prettier-ignore
    public class TableCell {
        @AuraEnabled public Integer rowNumber;
        @AuraEnabled public Integer columnNumber;
        @AuraEnabled public String defaultValue;
        @AuraEnabled public String description;
        @AuraEnabled public String dataType;
        @AuraEnabled public Boolean isPicklist = false;
        @AuraEnabled public Boolean isCalculated = false;
        @AuraEnabled public Boolean isNumber = false;
        @AuraEnabled public Boolean isPerpetualReadOnlyInput = false; // <T3> TODO: remove, use isCalculated instead
        @AuraEnabled public Boolean isChecked = true; // <T3>
        @AuraEnabled public EstimationOutput output;
        @AuraEnabled public List<Combobox> picklistValues = new List<Combobox>();

        public TableCell() {
        }

        public TableCell(ConsumptionSchedule schedule, Boolean isClosed, Estimation_Output__c outputRecord) {
            this.rowNumber = Integer.valueOf(outputRecord.Row_Number__c);
            this.columnNumber = Integer.valueOf(outputRecord.Column_Number__c);
            this.description = removeHTML(schedule.Consumption_Description__c);
            this.dataType = schedule.Data_Type__c;
            this.output = new EstimationOutput(schedule, isClosed, outputRecord);

            if (this.dataType == IPUE_CONSTANTS.CALCULATED || this.dataType == IPUE_CONSTANTS.NUM) {
                this.isNumber = true;
            } else if (this.dataType == IPUE_CONSTANTS.PICKLIST && schedule.Picklist_Values__c != null) {
                this.isPicklist = true;

                for (String option : schedule.Picklist_Values__c.split(',')) {
                    this.picklistValues.add(new Combobox(option));
                }
            } else if (this.dataType == IPUE_CONSTANTS.CALCULATED) {
                this.isCalculated = true;
            }

            // <T3> TODO: remove, use isCalculated instead
            if(this.dataType == IPUE_CONSTANTS.CALCULATED) {
                this.isPerpetualReadOnlyInput = true;
            }
        }
    }
    // prettier-ignore
    public class SDocButton {
        @AuraEnabled public Boolean isDefault;
        @AuraEnabled public Decimal sequence;
        @AuraEnabled public String label;
        @AuraEnabled public Id templateId;

        public SDocButton(SDoc_Template__c sDocTemplate) {
            this.isDefault = sDocTemplate.Default__c;
            this.sequence = sDocTemplate.Sequence__c;
            this.label = sDocTemplate.Button_Label__c;
            this.templateId = sDocTemplate.Template_Id__c;
        }
    }
    // prettier-ignore
    public class Combobox {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public Combobox(String option) {
            this.label = option;
            this.value = option.deleteWhitespace().toLowerCase();
        }
    }
    /************************* Helper Methods *************************/

    private static String removeHTML(String stringValue) {
        if (stringValue != null) {
            return stringValue.replaceAll('<[^>]+>', '');
        } else {
            return '';
        }
    }
}
