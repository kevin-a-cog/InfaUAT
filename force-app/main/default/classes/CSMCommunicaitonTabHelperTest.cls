/* Author		:	Deva M
* Created Date	: 	04/03/2022
* Description	:	Test class for CSMCommunicaitonTabHelperTest

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				04/03/2022		N/A				Initial version.			N/A
*/
@isTest(seeAllData = false)
public with sharing class CSMCommunicaitonTabHelperTest {
     /*
	 Method Name : fetchTabsTest
	 Description : test MEtdhod to test tabs 
	 Parameters	 : none.
	 Return Type : none 
	 */
    @isTest
    public static void fetchTabsTest() {
        CSMCommunicaitonTabHelper obj = new CSMCommunicaitonTabHelper();
        obj=CSMCommunicaitonTabHelper.fetchTabs();
        System.assert(obj.parentTabList!=null && obj.parentTabList.size()>0);
    }
}