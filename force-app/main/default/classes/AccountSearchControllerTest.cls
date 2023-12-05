/*
Class:          AccountSearchController
@Author:        Jiju N
@Created Date:  14 Dec 2021
@Description:   Test class for AccountSearchController, AccountSearchResultWrapper class. 

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class AccountSearchControllerTest {
    public static testmethod void testSearchAccounts(){
        Integer countOfResult = 5;
        Boolean leadConversion = true;
        Map<String, String> searchParamsMap = new Map<String, String>();
        searchParamsMap.put('name','Test Account');
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new AccountSearchControllerMock());
        List<AccountSearchResultWrapper> returnResponse = AccountSearchController.searchAccounts(searchParamsMap,countOfResult,leadConversion);
        system.debug('returnResponse------------------------'+returnResponse);
        system.assertEquals('Test Account', returnResponse[0].accountName, 'accountName does not match response');
        system.assertEquals('Test Street', returnResponse[0].address, 'address does not match response');
        system.assertEquals('A00000000', returnResponse[0].accountNumber, 'accountNumber does not match response');
        system.assertEquals('Test City', returnResponse[0].city, 'city does not match response');
        system.assertEquals('Test State', returnResponse[0].state, 'state does not match response');
        system.assertEquals('USA', returnResponse[0].country, 'country does not match response');
        system.assertEquals('abcdef', returnResponse[0].site_gduns, 'site_gduns does not match response');
        system.assertEquals('000-0000', returnResponse[0].postalCode, 'postalCode does not match response');
        Test.stopTest();
    }
}