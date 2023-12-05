/*
Class:          ValidationDetail 
@Author:        Uday Gangula
@Created Date:  10/30/2023
@Description:   Supporting Class for ScheduleLimitsMonitoringAlerts 


Change History
*****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag
******************************************************************************************************************************
Uday Gangula		10/30/2023	Prasanth Sagar		SFPLAT-108; Automate Validation Rules to Clari on Oppty  <T01>
*/

public class validationDetail {  //<T01>
    public String Id;
    public String ValidationName;
    public String description;
    public String errorConditionFormula;
    public String errorMessage;  
    public boolean active;
    public String EntityName;
}