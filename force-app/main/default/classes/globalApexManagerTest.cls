/*
Class:  globalApexManagerTest
        @Author:        Anil Solanki
        @Created Date:  27 April 2018
        @Description:   Test Class for globalApexManager Class.
*/
@isTest
private class globalApexManagerTest{

    private Final Static String vEmployee = Label.Profile_Employee;
        

    @testSetup
    static void setupData(){

       List<User> UserList= new List<user>();
       User user1 = [select Id, Name from User where Profile.Name =: vEmployee AND isActive=true limit 1];
       user1.ManagerEmployeeNumber__c ='1111';
       UserList.add(user1);
       update UserList;
       
       globalApexManager.checkDebugLogSwitch();
       globalApexManager.checkRunFuture();
       globalApexManager GAM = new globalApexManager();
       
       Global_Config__c settings = new Global_Config__c(Enable_Debug_Logs__c = true);
       insert settings;

       GAM.CreateLogs('test',UserList,'test'); 
       GAM.CreateLogs('test','testUpdate');
       GAM.DisplayErrorMessage('Failed');
       GAM.CreateLogs('testClass',UserList[0].Id,UserList[0].ManagerEmployeeNumber__c,'1111');
       GAM.CreateLogs('test',UserList[0],'debug');
       GAM.InsertDebugLogs();
       GAM.CreateExceptionRecords('testRecords','Failed',UserList[0].Id);
       system.assertEquals(UserList[0].ManagerEmployeeNumber__c,'1111');
    }
    
    static testmethod void avoidRecursion(){
        //Create test data here
        Exception failureDuringExecution = null;
        Test.startTest();
            try { 
                globalApexManager.avoidRecursion('UpdateCase');
                globalApexManager.avoidRecursion('ProcessCase');
                globalApexManager.allowRun('UpdateCase');
          
            } catch(Exception failure) { 
                 }
        Test.stopTest();
        
        System.assertEquals(TRUE, globalApexManager.avoidRecursion('ProcessCase'), 'Error Adding class name to avoid recursion');
        System.assertEquals(FALSE, globalApexManager.avoidRecursion('UpdateCase'), 'Error removing class name from avoid recursion');
    }
}