/*
 * Name         :   SegmentationEngine
 * Author       :   Vignesh Divakaran
 * Created Date :   6/21/2022
 * Description  :   This class parses segmentation criteria and condition defined on the records.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      6/21/2022       I2RT-6153       Initial version.                            N/A
 */

public class SegmentationEngine {

    //Private variables
    private Set<String> setQueryFields = new Set<String>();
    private final String IS_ONE_OF_OPERATOR = 'is one of';
    private final Map<String, String> OPERATORS = new Map<String, String>{
        'equals' => '==',
        'not equals' => '!=',
        'less than' => '<',
        'less or equals' => '<=',
        'greater than' => '>',
        'greater or equals' => '>=',
        'AND' => '&&',
        'OR' => '||'
    };

    
    /*
     Method Name : getSegmentationRules
     Description : This method returns all parsed Segmentation Criteria & Conditions.
     Parameters  : None
     Return Type : SegmentationWrapper
     */
    public SegmentationWrapper getSegmentationRules(){

        SegmentationWrapper objSegmentationWrapper = new SegmentationWrapper();
        objSegmentationWrapper.lstSegmentationRules = new List<SegmentationRule>();

        for(Case_Segmentation_Criteria__c objCaseSegmentationCriteria : [SELECT Id,Order__c,Filter__c,Segment__c,
                                                                            (SELECT Id,Index__c,Filter_Field__c,Operator__c,Filter_Type__c,Filter_Value__c,Filter_Reference__c FROM Case_Segmentation_Conditions__r) 
                                                                            FROM Case_Segmentation_Criteria__c
                                                                            WHERE (Start_Date__c = null AND End_Date__c = null) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY) OR 
                                                                            (Start_Date__c = null AND End_Date__c >= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c = null) ORDER BY Order__c ASC]){
            objSegmentationWrapper.lstSegmentationRules.add(getSegmentationRule(objCaseSegmentationCriteria));
        }
        objSegmentationWrapper.lstQueryFields = new List<String>(setQueryFields);
        
        return objSegmentationWrapper;
    }

    /*
     Method Name : getSegmentationRule
     Description : This method parses Segmentation Criteria & Condition and returns them 
     Parameters  : Object, called from getSegmentationRules, objCaseSegmentationCriteria.
     Return Type : SegmentationRule
     */
    public SegmentationRule getSegmentationRule(Case_Segmentation_Criteria__c objCaseSegmentationCriteria){
        
        SegmentationRule objSegmentationRule = new SegmentationRule();
        objSegmentationRule.objCaseSegmentationCriteria = objCaseSegmentationCriteria;
        objSegmentationRule.strFilterCondition = getParsedConditions(objCaseSegmentationCriteria);
        
        return objSegmentationRule;
    }

    /*
     Method Name : getParsedConditions
     Description : This method parses all Conditions for the Segmentation Criteria.
     Parameters  : Object, called from getSegmentationRule, objCaseSegmentationCriteria.
     Return Type : String
     */
    public String getParsedConditions(Case_Segmentation_Criteria__c objCaseSegmentationCriteria){
        
        String strFilterCondition = replaceOperators(objCaseSegmentationCriteria?.Filter__c);
        Boolean boolHasConditions = !objCaseSegmentationCriteria.Case_Segmentation_Conditions__r.isEmpty();
        Map<String, String> filterConditions = new Map<String, String>();

        for(Case_Segmentation_Condition__c objCaseSegmentationCondition : objCaseSegmentationCriteria.Case_Segmentation_Conditions__r){
            strFilterCondition = strFilterCondition.replace(String.valueOf(objCaseSegmentationCondition.Index__c), '#'+String.valueOf(objCaseSegmentationCondition.Index__c));
            filterConditions.put('#'+String.valueOf(objCaseSegmentationCondition.Index__c), getParsedCondition(objCaseSegmentationCondition));
        }

        for(String strConditionIndex : filterConditions.keySet()){
            strFilterCondition = strFilterCondition.replace(strConditionIndex, filterConditions.get(strConditionIndex));
        }

        return boolHasConditions ? strFilterCondition : '';
    }

    /*
     Method Name : getParsedCondition
     Description : This method parses the given condition.
     Parameters  : Object, called from getParsedConditions, objCaseSegmentationCriteria.
     Return Type : String
     */
    public String getParsedCondition(Case_Segmentation_Condition__c objCaseSegmentationCondition){

        String strCondition = '';
        String strFilterField = objCaseSegmentationCondition.Filter_Field__c;
        String strOperator = OPERATORS.containsKey(objCaseSegmentationCondition.Operator__c) ? OPERATORS.get(objCaseSegmentationCondition.Operator__c) : '';
        String strFilterValue = objCaseSegmentationCondition.Filter_Type__c == 'Value' ? objCaseSegmentationCondition.Filter_Value__c : objCaseSegmentationCondition.Filter_Reference__c;

        setQueryFields.add(strFilterField);

        if(String.isNotBlank(strOperator)){
            strCondition = strFilterField+ ' ' +strOperator+ ' \'' +strFilterValue+ '\'';
        }
        else if(objCaseSegmentationCondition.Operator__c == IS_ONE_OF_OPERATOR){
            if(objCaseSegmentationCondition.Filter_Type__c == 'Value'){
                List<String> lstConditions = new List<String>();
                for(String strValue : strFilterValue.split(',')){
                    lstConditions.add(strFilterField+ ' == \'' +strValue+ '\'');
                }
                strCondition = '(' +String.join(lstConditions, ' || ')+ ')';
            }
            else{
                strCondition = 'IS_ONE_OF(' +strFilterField+ ',' +strFilterValue+ ')';
                setQueryFields.add(objCaseSegmentationCondition.Filter_Reference__c);
            }
        }
        
        return strCondition;
    }

    /*
     Method Name : replaceOperators
     Description : This method replaces all the operators on the given string.
     Parameters  : String, called from getParsedConditions, strValue.
     Return Type : String
     */
    public String replaceOperators(String strValue){
        if(String.isNotBlank(strValue)){
            for(String strOperator : OPERATORS.keySet()){
                strValue = strValue.replace(strOperator, OPERATORS.get(strOperator));
            }
        }
        return strValue;
    }

    /*
     Method Name : replaceReferences
     Description : This method replaces all the operators on the given string.
     Parameters  : (String,Set,SObject) called from replaceReferences, (strFilterCondition,setReferences,sObj).
     Return Type : String
     */
    public String replaceReferences(String strFilterCondition, Set<String> setReferences, Case objCase){

        for(String strReference : setReferences){

            List<String> lstConditions = new List<String>();
            List<String> lstFilterFields = strReference.subString(strReference.indexOf('(')+1, strReference.indexOf(')')).split(',');
            String strFilterField = lstFilterFields[0];
            String strFilterReference = lstFilterFields[1];
            String strFilterReferenceValue = '';

            //Now, we check if the Filter Reference is traversing a field on the lookup
            if(strFilterReference.contains('.')){
                strFilterReferenceValue = (String) objCase.getSobject(strFilterReference.split('\\.')[0]).get(strFilterReference.split('\\.')[1]);
            }
            else{
                strFilterReferenceValue = (String) objCase.get(strFilterReference);
            }
            
            //Now, we check if the Filter Reference is null
            if(strFilterReferenceValue == null){
                strFilterCondition = strFilterCondition.replace(strReference, strFilterReference+ ' != null');
            }
            else{

                //Now, we split the values separated by semicolon(;) and create a condition for each value
                for(String strValue : strFilterReferenceValue.split(';')){
                    lstConditions.add(strFilterField+ ' == \'' +strValue+ '\'');
                }
                strFilterCondition = strFilterCondition.replace(strReference, '(' +String.join(lstConditions, ' || ')+ ')');
            }
        }
        return strFilterCondition;
    }

    /* Wrapper Objects */
    public class SegmentationRule{
        public Case_Segmentation_Criteria__c objCaseSegmentationCriteria {get; set;}
        public String strFilterCondition {get; set;}
    }

    public class SegmentationWrapper{
        public List<SegmentationRule> lstSegmentationRules {get; set;}
        public List<String> lstQueryFields {get; set;}
    }

}