/*
@created by       : Anil Sahu
@created on       : 1oct 2021
@Purpose          : Test class for CaseControllerHelper.
@JIRA             : 
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
Vignesh D      08/17/2022  I2RT-6954   T01     Commented unused code as part of apex cleanup
*/
@isTest
public class caseControllerHelperTest {
 public static   Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
    
   
     static testMethod void testFetchOrgNames() {
         Test.startTest();
         caseControllerHelper.ResponseDate(200,'Atlantic/Azores');         
         Test.stopTest();
     }
}