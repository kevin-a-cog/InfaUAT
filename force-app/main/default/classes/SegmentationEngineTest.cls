/*
 * Name         :   SegmentationEngineTest
 * Author       :   Vignesh Divakaran
 * Created Date :   6/29/2022
 * Description  :   Test class for SegmentationEngine.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      6/29/2022       N/A             Initial version.            N/A
 */

@isTest
public class SegmentationEngineTest {
    
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {

        List<Case_Segmentation_Criteria__c> lstCaseSegmentationCriterias = new List<Case_Segmentation_Criteria__c>();
        List<Case_Segmentation_Condition__c> lstCaseSegmentationConditions = new List<Case_Segmentation_Condition__c>();

        //Create Segmentation Criterias
        Case_Segmentation_Criteria__c objCaseSegmentationCriteria = new Case_Segmentation_Criteria__c();
        objCaseSegmentationCriteria.Order__c = 1;
        objCaseSegmentationCriteria.Filter__c = '1 AND 2';
        objCaseSegmentationCriteria.Segment__c = 'Hypercare';
        objCaseSegmentationCriteria.Start_Date__c = null;
        objCaseSegmentationCriteria.End_Date__c = null;
        lstCaseSegmentationCriterias.add(objCaseSegmentationCriteria);

        objCaseSegmentationCriteria = new Case_Segmentation_Criteria__c();
        objCaseSegmentationCriteria.Order__c = 2;
        objCaseSegmentationCriteria.Filter__c = '((1 OR 2) AND (3 OR 4 OR 5)) OR 6';
        objCaseSegmentationCriteria.Segment__c = 'Strategic';
        objCaseSegmentationCriteria.Start_Date__c = null;
        objCaseSegmentationCriteria.End_Date__c = null;
        lstCaseSegmentationCriterias.add(objCaseSegmentationCriteria);

        objCaseSegmentationCriteria = new Case_Segmentation_Criteria__c();
        objCaseSegmentationCriteria.Order__c = 3;
        objCaseSegmentationCriteria.Filter__c = null;
        objCaseSegmentationCriteria.Segment__c = 'Base';
        objCaseSegmentationCriteria.Start_Date__c = null;
        objCaseSegmentationCriteria.End_Date__c = null;
        lstCaseSegmentationCriterias.add(objCaseSegmentationCriteria);

        insert lstCaseSegmentationCriterias;

        //Create Segmentation Conditions
        Case_Segmentation_Condition__c objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 1;
        objCaseSegmentationCondition.Filter_Field__c = 'Support_Account__r.GCS_Segment__c';
        objCaseSegmentationCondition.Operator__c = 'equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Hypercare';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[0].Id;
        objCaseSegmentationCondition.Index__c = 2;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Reference';
        objCaseSegmentationCondition.Filter_Reference__c = 'Support_Account__r.Product__c';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 1;
        objCaseSegmentationCondition.Filter_Field__c = 'Success_Offering__c';
        objCaseSegmentationCondition.Operator__c = 'equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Signature Select';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 2;
        objCaseSegmentationCondition.Filter_Field__c = 'Success_Offering__c';
        objCaseSegmentationCondition.Operator__c = 'equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Signature Success';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 3;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Active VOS,Axon Data Governance,Cloud Application Integration,Cloud Data Governance and Catalog';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 4;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Cloud MDM - Reference 360,Connectors,Customer 360,Customer 360 Insights,Customer 360 Insights(AllSight)';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 5;
        objCaseSegmentationCondition.Filter_Field__c = 'Forecast_Product__c';
        objCaseSegmentationCondition.Operator__c = 'is one of';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'Enterprise Data Catalog,Enterprise Data Preparation,Foundation 360,Identity Resolution,MDM Multidomain,PowerCenter,Procurement';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        objCaseSegmentationCondition = new Case_Segmentation_Condition__c();
        objCaseSegmentationCondition.Case_Segmentation_Criteria__c = lstCaseSegmentationCriterias[1].Id;
        objCaseSegmentationCondition.Index__c = 6;
        objCaseSegmentationCondition.Filter_Field__c = 'Preferred_Language__c';
        objCaseSegmentationCondition.Operator__c = 'not equals';
        objCaseSegmentationCondition.Filter_Type__c = 'Value';
        objCaseSegmentationCondition.Filter_Value__c = 'English';
        lstCaseSegmentationConditions.add(objCaseSegmentationCondition);

        insert lstCaseSegmentationConditions;

    }

    /*
     Method Name : getSegmentationRulesTest
     Description : This method tests parsing all Segmentation Criteria & Conditions
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void getSegmentationRulesTest() {
        SegmentationEngine segmentationEngine = new SegmentationEngine();
        Test.startTest();
        System.assertNotEquals(segmentationEngine.getSegmentationRules() == null, true, 'There are no Segmentation Rules.');
        Test.stopTest();
    }
}