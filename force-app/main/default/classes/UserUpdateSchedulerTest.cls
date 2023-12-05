/*
@created by       : balajip
@created on       : 03/31/2023
@Purpose          : Test class for the class UserUpdateScheduler
@JIRA             : I2RT-7839
    
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************

*/
@isTest(SeeAllData=false)
public class UserUpdateSchedulerTest {
    
    @isTest 
    public static void testAll(){
        UserUpdateScheduler userUpdateScheduler = new UserUpdateScheduler();
        String cronStr = '0 00 * * * ?';
        System.schedule('User FTO Update 12344', cronStr, userUpdateScheduler);
    }
}