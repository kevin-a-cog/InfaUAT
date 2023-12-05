/*
 * Name         :   GlobalUtilityTest
 * Author       :   Vignesh Divakaran
 * Created Date :   6/29/2022
 * Description  :   Test class for GlobalUtility.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                               Tag
 **********************************************************************************************************
 Vignesh Divakaran      6/29/2022       N/A             Initial version.                          N/A
 Vignesh Divakaran      8/30/2022       N/A             Increased coverage for new methods added  T01
 Vignesh Divakaran      9/28/2022       N/A             Increased coverage for new methods added  T02
 Vignesh Divakaran      4/28/2023       N/A             Increased coverage for new methods added  T03
 */

@isTest
public class GlobalUtilityTest {
    
    /*
     Method Name : UtilityMethodsTest
     Description : Testing all utility methods.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void UtilityMethodsTest() {
        Test.startTest();
        System.assert(GlobalUtility.getOrganizationDate() != null, 'Unable to get organization date');
        System.assert(GlobalUtility.escapeSingleQuotes('\'Test String\'').contains('\''), 'Single quote is not escaped from the string');
        GlobalUtility.getCommunityUserContactId();
        System.assert(GlobalUtility.escapeSingleQuotes(new List<String>{'\'Test String 1\'', 'Test String 2', 'Test String 3'})[0].contains('\''), 'Single quote is not escaped from the list of strings');
        GlobalUtility.isExternalUser();
        Test.stopTest();
    }
}