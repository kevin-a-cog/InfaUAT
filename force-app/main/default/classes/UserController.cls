/*
    @created by       : balajip
    @created on       : 01/20/2022
    @Purpose          : Controller class for User Lightning components
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
Amit Garg       28/02/2022  I2RT-5099   T01    save Region field with User
Shashikanth     06/20/2023  I2RT-8365   T02    User Profile - Add shift Time Start and End Time
*/
public without sharing class UserController {

    private static GlobalApexManager gaManager = new GlobalApexManager();
    
    @AuraEnabled
    public static Boolean allowGCSTeamUpdate(){
        Boolean canUpdateGCSTeam = false;
        Boolean isGCSManager =  FeatureManagement.checkPermission('GCS_Manager');
        Boolean isGCSAdmin =  FeatureManagement.checkPermission('GCS_Admin');
        canUpdateGCSTeam = (isGCSManager||isGCSAdmin);
        return canUpdateGCSTeam;
    }

    @AuraEnabled
    public static String updateUser(String userId, String gcsTeam, string region, string timeZone, string shiftStartTime, string shiftEndTime){//<T01>
        try {
            User usr = new User();
            usr.Id = userId;
            usr.Region__c = region;//<T01>
            usr.GCS_Team__c = gcsTeam;
            //<T02>
            usr.Shift_Start_Time__c = getTime(shiftStartTime);
            usr.Shift_End_Time__c = getTime(shiftEndTime);
            usr.TimeZoneSidKey = timeZone;
            //</T02>
            update usr;
        } catch (Exception e) {
            //<T02>
            gaManager.CreateExceptionRecords('UserController.updateUser', 'Error while updating user: '+ e.getMessage(), userId);
           return e.getMessage();
           //</T02>
        }
        return '';              //<T02>
    }

    //<T02>
    private static Time getTime(String timeString)
    {
        if(String.isNotBlank(timeString))
        {
            String[] strTimeSplit = timeString.split(':');

            if(strTimeSplit != null && strTimeSplit.Size() > 1)
            {
                Time timeValue = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                    ,Integer.valueOf(strTimeSplit[1]) //min
                                                    ,0                                //sec
                                                    ,0);
                return timeValue;
            }
        }
        return null;
    }
    //</T02>
}