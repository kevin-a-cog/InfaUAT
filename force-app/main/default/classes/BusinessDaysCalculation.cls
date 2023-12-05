/************************************************************************************************************************************************************
   Created/ModifiedBy         Date              JIRA No.                       Requested By               Description                     Tag
 ***********************************************************************************************************************************************************
    Hardev Parmar             5-AUG-2018                                        This utility class to calculate various business day calculation such as getting next business days, 
                                                                                business hours, validating date is business day or not, total business days between two dates,                       
                                                                                business hours excluding weekends and holidays                                                             
 ************************************************************************************************************************************************************************************************
 */
 
public class BusinessDaysCalculation {

    private List<Boolean> businessDay = new Boolean[7];
    private List<Time> startHours = new Time [7];
    private List<Time> endHours = new Time [7];
    private Date knownSunday = date.newInstance(2013, 1, 6);
    private String businessHourId;
    private Boolean considerHolidays = false;
   
    // Constructor creates businessDay array
    public BusinessDaysCalculation(String businessHourName, Boolean considerHolidays,BusinessHours businessh) {     
        BusinessHours bh;         
        this.considerHolidays = considerHolidays;
        if(businessh == null){
          if(businessHourName == null) {
             bh = [SELECT SundayStartTime, MondayStartTime, TuesdayStartTime,WednesdayStartTime, ThursdayStartTime, FridayStartTime,SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                                FROM BusinessHours
                                    WHERE IsDefault = true ];
          }else {
             bh = [SELECT SundayStartTime, MondayStartTime, TuesdayStartTime,WednesdayStartTime, ThursdayStartTime, FridayStartTime,SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                                FROM BusinessHours
                                    WHERE Name =: businessHourName ];
           }
        }else{
            bh = businessh;
        }
         
         businessHourId = bh.Id;  
         system.debug('---businessHourId---'+businessHourId );
                
         businessDay[0] = (bh.SundayStartTime != null);
         businessDay[1] = (bh.MondayStartTime != null);
         businessDay[2] = (bh.TuesdayStartTime != null);
         businessDay[3] = (bh.WednesdayStartTime != null);
         businessDay[4] = (bh.ThursdayStartTime != null);
         businessDay[5] = (bh.FridayStartTime != null);
         businessDay[6] = (bh.SaturdayStartTime != null);
         
         startHours[0] = bh.SundayStartTime;
         startHours[1] = bh.MondayStartTime;
         startHours[2] = bh.TuesdayStartTime;
         startHours[3] = bh.WednesdayStartTime;
         startHours[4] = bh.ThursdayStartTime;
         startHours[5] = bh.FridayStartTime;
         startHours[6] = bh.SaturdayStartTime;
         
         endHours[0] = bh.SundayEndTime;
         endHours[1] = bh.MondayEndTime;
         endHours[2] = bh.TuesdayEndTime;
         endHours[3] = bh.WednesdayEndTime;
         endHours[4] = bh.ThursdayEndTime;
         endHours[5] = bh.FridayEndTime;
         endHours[6] = bh.SaturdayEndTime;
   }
   
   
   // Check if today is a business day - Date
   public Boolean isBusinessDay(Date inputDate) {
         // index i is index into the businessDay array based on inputDate
         Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
         Boolean isBusinessDay = businessDay[i];
         
         if(considerHolidays) {
             isBusinessDay = (isBusinessDay && BusinessHours.isWithin(businessHourId , datetime.newInstance(inputDate.year(), inputDate.month(),inputDate.day())));
         }
         
         return (isBusinessDay);
   }
   
   
   // Check if today is a business day - DateTime
   public Boolean isBusinessDay(DateTime inputDateTime) {
         
         Date businessDate = inputDateTime.date();
         Time businessTime = inputDateTime.Time();
         
         // index i is index into the businessDay array based on inputDate
         Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(businessDate)),7);
         Boolean isBusinessDay = isBusinessDay(businessDate);
         Boolean isBusinessHour = false;
         
         if(isBusinessDay){
             isBusinessHour = ( businessTime > getStartTime(businessDate) && businessTime < getEndTime(businessDate) );
         }
         
         return (isBusinessHour);
   }
   
    
   // Get the start time
   public Time getStartTime(Date inputDate) {
        Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
        return (startHours[i]);
   }
   
   
   // Get the End time
   public Time getEndTime(Date inputDate) {
        Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
        return (endHours[i]);
   }
   
   
   // Gets next business day, skipping non business days
   public Date nextBusinessDay(Date inputDate) {
     Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
     Date returnDate = inputDate;
     
     do {
         returnDate = returnDate.addDays(1);
         i++;
     } while (!businessDay[Math.mod(i, 7)]);
       
     if(considerHolidays) {
         if(!BusinessHours.isWithin(businessHourId , datetime.newInstance(returnDate.year(), returnDate.month(),returnDate.day() ))) {
             returnDate = nextBusinessDay(returnDate);
         }
     }
     
     return returnDate;
   }
   
   
   // returns back date in numberOfDays business days
   public Date addBusinessDays (Date startDate, integer numberOfDays) {
        Date returnDate = startDate;
        Integer holidayCount = 0;
        for (integer x = 0; x < numberOfDays; x++) {
            returnDate = nextBusinessDay(returnDate);
            system.debug('------considerHolidays----'+considerHolidays);
            if(considerHolidays){
                if(!BusinessHours.isWithin(businessHourId , datetime.newInstance( returnDate.year(), returnDate.month(), returnDate.day() ))){
                    holidayCount++;
                }
            }
        }
        system.debug('------holidayCount----'+holidayCount);
        if(holidayCount > 0) {
            returnDate.addDays(holidayCount);  
        }
        return returnDate;
   }
   
   
   //get the total business days between two dates
   public Integer getTotalBusinessDays(Date inputDateStart, Date inputDateEnd) {
       Integer totalDays = 0;
       Date returnDate = inputDateStart;
       
       do {
           returnDate = returnDate.addDays(1);
           if(isBusinessDay(returnDate)) {
               totalDays++;
               
               if(considerHolidays){
                   if(!BusinessHours.isWithin(businessHourId , datetime.newInstance( returnDate.year(), returnDate.month(), returnDate.day()))) {
                       totalDays--;
                   }
               }
           }  
       } while (returnDate != inputDateEnd);
       
       return totalDays;
   }
   
   
 }