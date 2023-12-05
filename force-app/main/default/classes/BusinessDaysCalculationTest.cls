/*
Class:          BusinessDaysCalculationTest
@Author:        Aishwarya Badri
@Created Date:  15-Mar-2021
@Description:   Test class to BusinessDaysCalculation

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class BusinessDaysCalculationTest {
    
    static testMethod void testCalculateBusinessHrs(){
        System.debug('testManageCaseContacts--entry');
        Test.startTest();
        List<BusinessHours> bhList= new List<BusinessHours>([SELECT name,SundayStartTime, MondayStartTime, TuesdayStartTime,WednesdayStartTime, ThursdayStartTime, FridayStartTime,SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                                                             FROM BusinessHours limit 1]);
        
        String bhName='08x05: (GMT+00:00) Azores Summer Time (Atlantic/Azores)';
        BusinessDaysCalculation bhour=new BusinessDaysCalculation(bhName,false,bhList[0]);
        
        Date myDate = Date.newInstance(2021, 10, 17);
        Date startDate = mydate.addDays(2);
        Date endDate = mydate.addDays(4);
        
        bhour.isBusinessDay(startDate);
        bhour.isBusinessDay(DateTime.now());
        bhour.getStartTime(startDate);
        bhour.getEndTime(endDate);
        bhour.nextBusinessDay(startDate);
        
        bhour.addBusinessDays(startDate,10);
        bhour.getTotalBusinessDays(startDate,endDate);
        Test.stopTest();
    }
    
    
}