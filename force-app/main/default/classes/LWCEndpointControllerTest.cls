/*
Class:              EinsteinPayGoMainMenu
@Author:            Coveo/Madhu Shanthappa
@Created Date:      11-Sep-2023
@Description:       Test class to cover the feture of LWCEndpointController      
Change History:
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************
*/
@isTest
public class LWCEndpointControllerTest {
    @IsTest
    static void testEndpoint(){
        String testEndpoint = LWCEndpointController.getEndpoint('foo');
        System.assertNotEquals(testEndpoint, null);
    }
}