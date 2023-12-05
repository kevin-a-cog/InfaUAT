/*
    @created by       : Shashikanth
    @created on       : 07/27/2022
    @Purpose          : Helper class for Segmentation calculation
    @Testclass        : CaseTriggerHelperTest
    @JIRA             : I2RT-8524: GCS Segmentation 2023 - To add a new preferred segment (Case level)
    
Change History
****************************************************************************************************
ModifiedBy      Date           Jira No.    Tag     Description
****************************************************************************************************
Shashikanth     24-Aug-2023    I2RT-9001   T01     Preferred weightage for non Rule 1,rule 2
*/
public class CaseSegmentHelper
{

    //#region Variables

    private static GlobalApexManager gaManager = new GlobalApexManager();
    final Id RECORDTYPE_ID_TECHNICAL = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    final Map<string, List<string>> SEGMENTS_PRECEDENCE_DETAILS = new Map<string, List<string>>
    {
        'Hypercare' => new List<string>{'CertificationRequest'},                            //1
        'Strategic' => new List<string>{'Criteria'},                                        //2
        'Preferred' => new List<string>{'CriteriaCaseIndex','CertificationRequest'},        //3
        'Base'      => new List<string>{'Criteria'}                                         //4
    };

    ScriptEngine scriptEngineInstance = null;
    SegmentationEngine segmentEngine = new SegmentationEngine();
    SegmentationEngine.SegmentationWrapper objSegmentationWrapper = null;
    Map<Id, Case> queriedCases = new Map<Id, Case>();
    Map<String, List<Certification_Request__c>> supportAccountCRMap = new  Map<String, List<Certification_Request__c>>();
    Map<String, SupportAccountProductDetails> supportAccountDetailsMap = new Map<String, SupportAccountProductDetails>();

    List<Case_Segment_Period_Configuration__mdt> caseSegmentPeriodConfigList = null;
    List<Id> caseIds = new List<Id>();
    List<Case> caseList = null;
    List<Id> recalculateCaseIds = new List<Id>();
    List<string> productList = new List<string>();
    List<Id> supportAccountIdList = new List<Id>();

    //#endregion

    //#region Constructor

    public CaseSegmentHelper(List<Case> cases)
    {
        try
        {
            caseList = cases;

            scriptEngineInstance = ScriptEngine.getInstance();
            objSegmentationWrapper = segmentEngine.getSegmentationRules();

            prepareSupportAccountNProductIdList();

            getRuleRequiredCaseData(caseIds);
            getCertificationRequests();
            getSupportAccountProductDetails();
            getCaseSegmentPeriodConfigDetails();
        }
        catch(Exception ex)
        {
            gaManager.CreateExceptionRecords('CaseSegmentHelper Constructor Exception', 'Error in Constructor: '+ ex.getMessage(), 'CaseSegmentHelper');
        }
    }

    //#endregion

    //#region Public Methods
    
    /*
    @description    : Calculates the segment based on the case provided as input
    @date           : 07/27/2022
    @param          : caseDetails
    @return         : Case
    */
    public Case getCaseSegmentDetails(Case caseDetails)
    {
        Case caseUpdate = null;
        try
        {
            caseUpdate = new Case(Id = caseDetails.Id, 
                                        Forecast_Product__c = caseDetails.Forecast_Product__c, 
                                        Support_Account__c = caseDetails.Support_Account__c,
                                        Segment_Period_Flag__c = '');
            
            Set<String> segmentList = SEGMENTS_PRECEDENCE_DETAILS.keySet();

            for(String segment : segmentList)
            {
                Boolean isSegmentQualified = false;

                for(String segmentCheckType: SEGMENTS_PRECEDENCE_DETAILS.get(segment))
                {
                    if(segmentCheckType == 'CertificationRequest')
                    {
                        isSegmentQualified = checkCertificationRequest(caseUpdate, segment);
                    }
                    else if(segmentCheckType == 'Criteria')
                    {
                        isSegmentQualified = validateSegmentationCriteria(caseUpdate, segment);
                    }
                    else if(segmentCheckType == 'CriteriaCaseIndex')
                    {
                        isSegmentQualified = validateSegmentCriteriaCaseIndex(caseUpdate, segment);
                    }

                    if(isSegmentQualified)
                    {
                        caseUpdate.Segment__c = segment;
                        break;
                    }
                }

                if(isSegmentQualified)
                {
                    break;
                }
            }
        }
        catch(Exception ex)
        {
            gaManager.CreateExceptionRecords('CaseSegmentHelper.getCaseSegmentDetails', 'Error in getCaseSegmentDetails: '+ ex.getMessage(), caseDetails.Id);
        }
        return caseUpdate;
    }

    //#endregion
    
    //#region Data Prep

    /*
    @description : prepares Case, SupportAccount & ProductId List
    @date        : 07/27/2022
    @param       : 
    @return      : void
    */
    private void prepareSupportAccountNProductIdList()
    {
        for(Case caseItem : caseList)
        {
            caseIds.add(caseItem.Id);

            if(String.isNotBlank(caseItem.Forecast_Product__c) && !productList.contains(caseItem.Forecast_Product__c))
            {
                productList.add(caseItem.Forecast_Product__c);
            }
            if(String.isNotBlank(caseItem.Support_Account__c) && !supportAccountIdList.contains(caseItem.Support_Account__c))
            {
                supportAccountIdList.add(caseItem.Support_Account__c);
            }
        }
    }

    /*
    @description : gets all active Certification Requests for all the support accounts 
                   and products
    @date        : 07/27/2022
    @param       : 
    @return      : void
    */
    private void getCertificationRequests()
    {
        Date currentDate = GlobalUtility.getOrganizationDate();
        String productListValues = '\'' + String.join(productList, '\',\'') + '\'';
        
        String query = 'SELECT Support_Account__c, Product__c, Request_Type__c';
        query += ' FROM Certification_Request__c';
        query += ' WHERE ((Request_Type__c = \'Hypercare\')';
        query += '          OR (Request_Type__c != \'Hypercare\' AND Product__c  INCLUDES  (' + productListValues + ')))';
        query += ' AND Support_Account__c IN :supportAccountIdList';
        query += ' AND Status__c  = \'Approved\'';
        query += ' AND (Start_Date__c <= :currentDate AND End_Date__c >= :currentDate)';
        query += ' ORDER BY CreatedDate DESC';
        
        for(Certification_Request__c crItem : Database.query(query))
        {
            String saCRkey = crItem.Support_Account__c + '-' + crItem.Request_Type__c;
            List<Certification_Request__c> crItems = null;

            if(crItem.Request_Type__c != 'Hypercare' && supportAccountCRMap.containsKey(saCRkey))
            {
                crItems = supportAccountCRMap.get(saCRkey);
            }
            else if(!supportAccountCRMap.containsKey(saCRkey))
            {
                crItems = new List<Certification_Request__c>();
                supportAccountCRMap.put(saCRkey, crItems);
            }

            if(crItems != null)
            {
                crItems.add(crItem);
            }
        }
    }

    /*
    @description : gets all the case field values needed for Segment Criteria rules execution
    @date        : 07/27/2022
    @param       : caseIdList
    @return      : void
    */
    private void getRuleRequiredCaseData(List<Id> caseIdList)
    {
        String strQuery = 'SELECT ';
        if(objSegmentationWrapper.lstQueryFields.isEmpty())
        {
            strQuery+= 'Id';
        }
        else
        {
            strQuery+= '' +String.join(objSegmentationWrapper.lstQueryFields, ',')+',Id';
        }
        strQuery+= ' FROM Case WHERE Id IN :caseIdList';
        Map<Id, Case> caseDetailsList = new Map<Id, Case>((List<Case>) Database.query(strQuery));

        queriedCases.putAll(caseDetailsList);
    }

    /*
    @description : gets Support account and Product specific details like Technical Cases count 
                    and Case CreatedDates which will be used in Segment Case Index calculation
    @date        : 07/27/2022
    @param       : 
    @return      : void
    */
    private void getSupportAccountProductDetails()
    {
        for(Case caseItem: [SELECT Id, RecordTypeId, Support_Account__c, Forecast_Product__c,
                            Segment__c,Segment_Period_Flag__c, CreatedDate                         //<T01>
                            FROM Case
                            WHERE RecordTypeId = :RECORDTYPE_ID_TECHNICAL
                            AND Support_Account__c IN :supportAccountIdList
                            AND Forecast_Product__c IN :productList
                            ORDER BY Support_Account__c, Forecast_Product__c, CreatedDate])
        {
            String saProductKey = caseItem.Support_Account__c + '-' + caseItem.Forecast_Product__c;

            SupportAccountProductDetails supportAccountDetails = null;

            if(supportAccountDetailsMap.containsKey(saProductKey))
            {
                supportAccountDetails = supportAccountDetailsMap.get(saProductKey);
            }
            else
            {
                supportAccountDetails = new SupportAccountProductDetails();
                supportAccountDetailsMap.put(saProductKey,supportAccountDetails);
            }
            
            supportAccountDetails.technicalCasesCount = supportAccountDetails.technicalCasesCount + 1;
            supportAccountDetails.technicalCasesCreatedDates.add(caseItem.CreatedDate);
       }
    }

    private void getCaseSegmentPeriodConfigDetails()
    {
        caseSegmentPeriodConfigList = [SELECT  Product__c, Period__c, Period_Flag__c, Case_Index__c, Segment__c, Is_PC2_Customer__c 
                                        FROM Case_Segment_Period_Configuration__mdt];
    }


    //#endregion

    //#region Business Logic

    /*
    @description : Validates a case against the Segment Criteria Rules and Case Index
    @date        : 07/27/2022
    @param       : caseDetails
    @param       : segment
    @return      : Boolean
    */
    private Boolean validateSegmentCriteriaCaseIndex(Case caseDetails, String segment)
    {
        Boolean isValid = validateSegmentationCriteria(caseDetails, segment);
        if(isValid)
        {
            Boolean isCasePeriodIndexValid = checkCasePeriodIndex(caseDetails, segment);
            isValid = isCasePeriodIndexValid;
        }

        if(isValid)
        {
            caseDetails.Segment__c = segment;
        }
        return isValid;
    }

    /*
    @description : Validates a case against Case Index configured
    @date        : 07/27/2022
    @param       : caseDetails
    @param       : segment
    @return      : Boolean
    */
    private Boolean checkCasePeriodIndex(Case caseDetails, String segment)
    {
        Boolean isValidCasePeriod = false;
        SupportAccountProductDetails saProductDetails = getSupportAccountProductDetails(caseDetails);
        
        if(saProductDetails != null)
        {
            Case_Segment_Period_Configuration__mdt caseSegmentPeriodConfig = getCaseSegmentPeriodConfig(caseDetails.Forecast_Product__c, segment);   //<T01>
            
            if(caseSegmentPeriodConfig != null
                && saProductDetails.technicalCasesCount >= caseSegmentPeriodConfig.Case_Index__c)
            {
                Integer caseIndex = Integer.valueOf(caseSegmentPeriodConfig.Case_Index__c);
                DateTime segmentPeriodValidUpto = null;
                DateTime caseIndexDate = saProductDetails.technicalCasesCreatedDates[caseIndex-1];
                
                if(caseIndexDate != null)
                {
                    segmentPeriodValidUpto = caseIndexDate.AddDays(Integer.valueOf(caseSegmentPeriodConfig.Period__c));
                }
                
                if(segmentPeriodValidUpto != null && segmentPeriodValidUpto >= DateTime.Now())
                {
                    caseDetails.Segment_Period_Flag__c = caseSegmentPeriodConfig.Period_Flag__c;
                    isValidCasePeriod = true;
                }
            }
        }
        return isValidCasePeriod;
    }

    /*
    @description : Gets the 'SupportAccountProductDetails' for a given caseSupport Account and Product combination
    @date        : 07/27/2022
    @param       : caseDetails
    @return      : SupportAccountProductDetails
    */
    private SupportAccountProductDetails getSupportAccountProductDetails(Case caseDetails)
    {
        String saProductKey = caseDetails.Support_Account__c + '-' + caseDetails.Forecast_Product__c;
        SupportAccountProductDetails saProductDetails = supportAccountDetailsMap.get(saProductKey);
        return saProductDetails;
    }

    /*
    @description : Gets the Case Index Configuration details for Product & Segment combination
    @date        : 07/27/2022
    @param       : product
    @param       : segment
    @return      : Case_Segment_Period_Configuration__mdt
    */
    private Case_Segment_Period_Configuration__mdt getCaseSegmentPeriodConfig(String product, String segment)          //<T01>
    {
        Case_Segment_Period_Configuration__mdt caseSegmentPeriodConfig = null;

        for(Case_Segment_Period_Configuration__mdt configItem : caseSegmentPeriodConfigList)
        {
            if(configItem.Product__c == product 
                && configItem.Segment__c == segment)             //<T01>
                {
                    caseSegmentPeriodConfig = configItem;
                    break;
                }
        }

        return caseSegmentPeriodConfig;
    }

    /*
    @description : Checks whether a valid Certfication request exists for a given case against the given segment
    @date        : 07/27/2022
    @param       : caseDetails
    @param       : segment
    @return      : Boolean
    */
    private Boolean checkCertificationRequest(Case caseDetails, String segment)
    {
        String saCRkey = caseDetails.Support_Account__c + '-' + segment;

        if(!(!supportAccountCRMap.isEmpty() && supportAccountCRMap.containsKey(saCRkey)))
        {
           return false;
        }

        for(Certification_Request__c certificationRequest : supportAccountCRMap.get(saCRkey))
        {
            if(checkMultipickList(certificationRequest.Product__c, caseDetails.Forecast_Product__c))
            {
                return true;
            }
        }
        
        return false;
    }

    /*
    @description : Checks a given value exists in the multiPickList value
    @date        : 07/27/2022
    @param       : selectedValues
    @param       : compareValue
    @return      : Boolean
    */
    private Boolean checkMultipickList(string selectedValues, string compareValue)
    {
        Boolean isExists = false;

        List<String> sourceList = String.isNotBlank(selectedValues) ? selectedValues.split(';') : null;

        isExists = (sourceList != null) ? sourceList.contains(compareValue) : false;

        return isExists;
    }

    /*
    @description : Validates Segmentation Criteria rules for a given Case against the given segment
    @date        : 07/27/2022
    @param       : caseDetails
    @param       : segment
    @return      : Boolean
    */
    private Boolean validateSegmentationCriteria(Case caseDetails, String segment)
    {
        String strPattern = 'IS_ONE_OF\\(.+?\\)';
        Pattern oPattern = Pattern.compile(strPattern);

        for(SegmentationEngine.SegmentationRule objSegmentationRule : objSegmentationWrapper.lstSegmentationRules){
            if(objSegmentationRule.objCaseSegmentationCriteria?.Segment__c != segment)
            {
                continue;
            }

            String strFilterCondition = objSegmentationRule.strFilterCondition;
            
            if(String.isNotBlank(strFilterCondition))
            {
               //Replace every IS_ONE_OF references with actual condition
                Set<String> setReferences = new Set<String>();
                Matcher oMatcher = oPattern.matcher(strFilterCondition);
                while(oMatcher.find()){
                    setReferences.add(oMatcher.group(0));
                }

                if(!setReferences.isEmpty()){
                    strFilterCondition = segmentEngine.replaceReferences(strFilterCondition, setReferences, queriedCases.get(caseDetails.Id));
                }

                Map<String, Object> mapFieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(queriedCases.get(caseDetails.Id))); 
                Object objResult = scriptEngineInstance.eval(strFilterCondition, mapFieldValues);
                Boolean boolFilterResult = (Boolean) objResult;

                if(boolFilterResult)
                {
                    return true;
                }
            }
            else
            {
                return true;
            }
        }

        return false;
    }

    //#endregion

    //#region Classes
   
     /*
    @description : Wrapper class used to store the Technical Cases Count and the Created Dates
    @date        : 07/27/2022
    */
    public class SupportAccountProductDetails
    {
        private Integer techCasesCount = 0;
        private List<Datetime> technicalCasesCreateDateList  = new List<Datetime>(); 

        public List<Datetime> technicalCasesCreatedDates
        { 
            get {return technicalCasesCreateDateList;} 
            set { technicalCasesCreateDateList = value; } 
        }

        public Integer technicalCasesCount 
        { 
            get {return techCasesCount;} 
            set { techCasesCount = value; } 
        }
    }

    //#endregion
}