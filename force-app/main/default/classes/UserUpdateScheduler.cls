/*
@created by       : balajip
@created on       : 03/31/2023
@Purpose          : Schedulable class that is used to invoke the method UserService.FTO every 30 mins
@Testclass        : 
@JIRA             : I2RT-7839
    
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************

*/
global class UserUpdateScheduler implements Schedulable{

    /*
    Cron Job:
    UserUpdateScheduler userUpdateScheduler = new UserUpdateScheduler();
    String cronStr = '0 00 * * * ?';
    System.schedule('User FTO Update 1', cronStr, userUpdateScheduler);

    String cronStr = '0 30 * * * ?';
    System.schedule('User FTO Update 2', cronStr, userUpdateScheduler);
    */

    // to be called every half an hour so that the FTO flag is turned at the start of day for every timezone.
    global void execute(SchedulableContext sc){
        UserService.updateFTO();
    }
}