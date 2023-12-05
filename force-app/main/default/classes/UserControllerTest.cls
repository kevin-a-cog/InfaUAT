/*
@created by       : balajip
@created on       : 01/27/2020
@Purpose          : Test class for UserController.
@JIRA             : I2RT-5093

Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************

*/
@isTest
public class UserControllerTest {
        
    @isTest
    static void testMethodAll(){
        Test.startTest();
        UserController.allowGCSTeamUpdate();
        UserController.updateUser(UserInfo.getUserId(), 'IPS','APAC','Asia/Kolkata','09:00','18:00');
        Test.stopTest();
    }
}