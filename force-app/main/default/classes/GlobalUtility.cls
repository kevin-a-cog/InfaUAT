/*
 * Name         :   GlobalUtility
 * Author       :   Vignesh Divakaran
 * Created Date :   6/22/2022
 * Description  :   This is an Utility Class.

 Change History
 *************************************************************************************************************
 Modified By            Date            Jira No.        Description                                     Tag
 *************************************************************************************************************
 Vignesh Divakaran      6/22/2022       I2RT-6149       Initial version.                                N/A
 Vignesh Divakaran      8/4/2022        I2RT-6864       Added utility method to escape single quotes    T01
 Vignesh Divakaran      8/30/2022       I2RT-6872       Added utility method to return community user   T02
                                                        user contact id
 Vignesh Divakaran      9/28/2022       I2RT-6880       Added utility method to escape single quotes    T03
                                                        on List of Strings
 Vignesh Divakaran      4/28/2023       I2RT-6895	    Added utility method to check external user     T04
 */

public with sharing class GlobalUtility {
    
    /*
     Method Name : getOrganizationDate
     Description : This method returns Organization's today's date.
     Parameters  : None
     Return Type : Date
     */
    public static Date getOrganizationDate(){
        DateTime dtToday = System.now();
        String strOrgTimezone = [SELECT TimeZoneSidKey FROM Organization]?.TimeZoneSidKey;
        Integer intYear = Integer.valueOf(dtToday.format('yyyy', strOrgTimezone));
        Integer intMonth = Integer.valueOf(dtToday.format('MM', strOrgTimezone));
        Integer intDay = Integer.valueOf(dtToday.format('dd', strOrgTimezone));

        return date.newInstance(intYear, intMonth, intDay);
    }

    /*
     Method Name : escapeSingleQuotes
     Description : This method escapes the single quotes from the string.
     Parameters  : String, called from GlobalUtility, strInput
     Return Type : String
     */
    public static String escapeSingleQuotes(String strInput){ //<T01>
        return String.isNotBlank(strInput) ? String.escapeSingleQuotes(strInput) : strInput;
    }

    /*
     Method Name : getCommunityUserContactId
     Description : This method returns the contact id associated on the community user record.
     Parameters  : None
     Return Type : Id
     */
    public static Id getCommunityUserContactId(){ //<T02>
        return [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()]?.ContactId;
    }

    /*
     Method Name : escapeSingleQuotes
     Description : This method escapes single quotes from the list of strings.
     Parameters  : List<String>, called from GlobalUtility, lstValues
     Return Type : List of Strings
     */
    public static List<String> escapeSingleQuotes(List<String> lstValues){ //<T03>
        List<String> lstEscapedValues = new List<String>();
        for(String strValue : lstValues){
            lstEscapedValues.add(escapeSingleQuotes(strValue));
        }
        return lstEscapedValues;
    }

    /*
     Method Name : isExternalUser
     Description : This method checks whether the running user is a portal user.
     Parameters  : None
     Return Type : Boolean
     */
    public static Boolean isExternalUser(){ //<T04>
        return [SELECT IsPortalEnabled FROM User WHERE Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;
    }
}