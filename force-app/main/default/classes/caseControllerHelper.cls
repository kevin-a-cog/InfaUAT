/*
*@created by       : Anil Sahu
@created on       : 8July21
@Purpose          : helper  class for Case caseController 

Change History
*********************************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
*********************************************************************************************************************
balajip     12/30/2021  I2RT-5221   T01     fixed the year format in the Response Time string.
Vignesh D   02/14/2022              T02     Incorrect datetime format, TimeZoneSIDKey to be passed.
Vignesh D   08/17/2022  I2RT-6954   T03     Removed unused code as part of apex cleanup
*/
public class caseControllerHelper {
    
    public static string ResponseDate(Integer Minutes,string strTimeZoneName){
        datetime newDt;  
       //double hours = Mintutes/60;
       string strTimeZone;
        map<string,string> mapZone=new map<string,string>();
        /*if(strTimeZoneName!=null){ //Vignesh D: commented
            strTimeZone=strTimeZoneName.substringBetween('(', ')');
        }*/
       /* if(strTimeZoneName.containsIgnoreCase('pacific')){
            strTomeZone='PST';
        }else if(strTimeZoneName.containsIgnoreCase('india')){
            strTomeZone='IST';
        }else if(strTimeZoneName.containsIgnoreCase('central')){
            strTomeZone='CST';
        }else if(strTimeZoneName.containsIgnoreCase('eastern')){
            strTomeZone='EST';
        }*/
        
        id bsId;
        DateTime dt = datetime.now(); 
        // BusinessHours stdBusinessHours = [select id,name from businesshours where name =: strTimeZoneName];
        for(businesshours vr:[select id,name, SundayStartTime, MondayStartTime, TuesdayStartTime,
         WednesdayStartTime, ThursdayStartTime, FridayStartTime,
         SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,
         WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime,TimeZoneSidKey from businesshours 
         WHERE TimeZoneSidKey =: strTimeZoneName AND (NOT Name LIKE '24x%') LIMIT 1]){//Vignesh D
            string strname=vr.name; 
             //if(!strname.containsIgnoreCase('24x')){ //Vignesh D: commented
            //string strtimeZnname=strname.substringAfter(':'); //Vignesh D: commented
           //  System.debug(strTimeZoneName.trim()+' param dt== new '+strtimeZnname.trim());
           //if(strtimeZnname.trim()==strTimeZoneName.trim()){ //Vignesh D: commented
            if(strTimeZoneName == vr.TimeZoneSidKey){ //Vignesh D
                bsId=vr.id;
            }
         //}
        } 
         string strdt;
        if ((Minutes != NULL) && (bsId != NULL)) {  
            Datetime currentTime = System.now(); 
         Datetime   targetDT =BusinessHours.add( bsId,currentTime, Minutes * 60 * 1000L);//minutes
         // strdt=targetDT.format('M/d/yyyy hh:mm a',strTimeZoneName); //Vignesh D: updated datetime format
          System.debug(' datev '+strdt);
           
          //T01 - changed 'YYYY' to 'yyyy'
          //strdt=targetDT.format('MMMMM')+' '+targetDT.day()+' , '+targetDT.format('yyyy',strTimeZoneName)+' '+targetDT.format('hh:mm a',strTimeZoneName);
          strdt = targetDT.format('MMMMM dd, yyyy hh:mm a',strTimeZoneName); //<T02>
          // +' '+bsId+strTomeZone;//+' '+targetDT.format('h:mm a');  
         // working Datetime   targetDT =BusinessHours.add( [SELECT Id FROM BusinessHours WHERE IsDefault = true].id,currentTime, Minutes* 60 * 60 * 1000L);
            //strdt=targetDT.format('h:mm a')+targetDT.format('yyyy-MM-dd HH:mm:ss',strTomeZone)+''+strTomeZone+'-mydate-'+targetDT+' mydate +bsId'+bsId ;
            // targetDT =BusinessHoursServices.getSLATimeByBusinessHour(bsId,currentTime,Minutes);// BusinessHours.add(bsid,dt, Minutes * 60 * 1000L);
           // System.debug(strTomeZone+'---'+targetDT.format('yyyy-MM-dd HH:mm:ss','EST')+ 'inside both  data  =='+targetDT.format('yyyy-MM-dd HH:mm:ss','IST'));
        }
         //datetime.valueOf(targetDT.format('yyyy-MM-dd HH:mm:ss',strTomeZone)); 
       System.debug('date=== '+strdt);
        return strdt;
        
    }    
}