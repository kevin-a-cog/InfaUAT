/*
    @Author:        ?
    @Created Date:  4/17/2022
    @Description:   Constants for the IPU Estimator

    Change History
    ********************************************************************************************************************************************
    ModifiedBy          Date          JIRA No.      Description                                                 Tag

    Kevin Antonioli     22 OCT 2023   PNP-515       Add constants for Subtotal sections                         <T01>                        
    ********************************************************************************************************************************************
*/
public with sharing class IPUE_CONSTANTS {
    public static final String ESTIMATION_SCHEDULE_DEV_NAME = 'Estimation_Schedule';

    /**** Estimation Schedule Data Types ****/
    public static final String TABLE_FIXED = 'Table - Fixed';
    public static final String TABLE_ELASTIC = 'Table - Elastic';
    public static final String STATIC_TEXT = 'Static Text';
    public static final String CALCULATED = 'Calculated';
    public static final String TEXT = 'Text';
    public static final String NUM = 'Number';
    public static final String PICKLIST = 'Picklist';

    /****** Keys Used in CalculationUtils ********/
    public static final String DEFAULT_KEY = 'Default';
    public static final String ROW_KEY = '_ROW_';
    public static final String COLUMN_KEY = '_COLUMN_';

    // <T01>:
    public static final String CURRENT_PAGE_IPU_SUBTOTAL_STR = 'current page ipu subtotal';
    public static final String NEXT_PAGE_IPU_SUBTOTAL_STR = 'next page ipu subtotal';
    public static final String ADDITIONAL_IPUS_NEEDED_STR = 'additional ipus needed';
    public static final String CURRENT_IPU_ENTITLEMENT_STR = 'enter current ipu entitlement';
    public static final String SECTION_TOTAL_IPUS_STR = 'total (ipus)';

    //Added empty constructor to get code coverage
    public IPUE_CONSTANTS() {
    }
}
