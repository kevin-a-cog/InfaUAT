/*
Name             : psaGenerateStatusReportPDFController 
@Author          : Wasim
@Created Date    : Aug 3, 2023
@Description     : PSA:3086 - Generate Status Report in pdf format using the new template  

Change Log
**************************************************************************************************************************
ModifiedBy  Date            JIRA No.  Requested By  Description                             Tag
**************************************************************************************************************************
*/

public class psaGenerateStatusReportPDFController {
    
    public Status_Report__c statsRec {get;set;}   // Holds Details of Status Report Record
    //<T02>
     public boolean hasIssue{get;set;}// boolean to render Issues;
    public boolean hasRisk{get;set;} // boolean to render Risks;
    public boolean hasIssueandRisks{get;set;} // boolean to render Risks and Issues;
    public boolean hasAsgmt{get;set;} // boolean to render Assignments;
    public boolean hasProjActivity{get;set;} // boolean to render Project Activity;
    public boolean hasAccTask{get;set;} // boolean to render Accomplished tasks;
    public boolean hasIncompleteTask{get;set;} // boolean to render Incomplete tasks;
    public boolean hasUpcomingTask{get;set;} // boolean to render Upcoming tasks;
    public boolean hasMilestones {get;set;} //Boolean used to render the pageblock  of milestone table
    public List<Status_Report_Detail__c> issuesLst{get;set;} //List to store the Issues
    public List<Status_Report_Detail__c> risksLst{get;set;} //List to store the Risks
    public List<Status_Report_Detail__c> asgmtLst{get;set;} //List to store the Assignments
    public List<Status_Report_Detail__c> milestoneList{get;set;} //List to store the Milestones
    public List<Task> upcomTaskList{get;set;}   //List to store the Upcoming Tasks
    public List<Task> incompTaskList{get;set;}  //List to store the Incomplete Tasks
    public List<Task> accTaskList{get;set;}    //List to store the Accomplished Tasks
    public string todaysDate{get;set;}  // String to store Today's Date
    public String greenTickImageURL {get; set;} //String to store the static Resource Green Tick Box Image URL
    public String greenBoxImageURL {get; set;}  //String to store the static Resource Green Box Image URL
    public String yellowTickImageURL {get; set;}    //String to store the static Resource Yellow Tick Box Image URL
    public String yellowBoxImageURL {get; set;} //String to store the static Resource Yellow Box Image URL
    public String redTickImageURL {get; set;}   //String to store the static Resource Red Tick Box Image URL
    public String redBoxImageURL {get; set;}    //String to store the static Resource Red Box Image URL
    public Decimal totalPlannedHours {get; set;} //String to store the total Planned Hours for Assignments
    public Decimal totalHoursLogged {get; set;} //String to store the total Hours logged for Assignments
    public Decimal totalRemainingHours {get; set;} //String tp store the total Remaining Hours for Assignments
    //</T02>
    public psaGenerateStatusReportPDFController(ApexPages.StandardController stdController) {
        //get the details of status report from the controller variable
        Status_Report__c statusReportRec =(Status_Report__c)stdController.getRecord();
        //initialize all variables
        hasProjActivity = false;
        greenTickImageURL = '/resource/1687948168000/GreenCheckMark';
        greenBoxImageURL = '/resource/1687948122000/GreenBox';
        yellowTickImageURL = '/resource/1687949015000/YellowCheckMark';
        yellowBoxImageURL = '/resource/1687948964000/YellowBox';
        redTickImageURL = '/resource/1687951345000/RedCheckMark';
        redBoxImageURL = '/resource/1687951301000/RedBox';
        todaysDate = date.today().format();
        issuesLst = new List<Status_Report_Detail__c>();
        risksLst = new List<Status_Report_Detail__c>();
        asgmtLst = new List<Status_Report_Detail__c>();
        milestoneList = new List<Status_Report_Detail__c>();
        upcomTaskList = new List<Task>();
        incompTaskList = new List<Task>();
        accTaskList = new List<Task>();
        Set<ID> taskIds = new Set<ID>();
        // Query to get the Status Report and Project details
        statsRec = [Select Id,PSA_PM_Project__c,PSA_PM_Project__r.psa_Project_Name__c,PSA_PM_Project__r.Owner.Name, PSA_PM_Project__r.pse__Project_Manager__r.Name,PSA_PM_Status_Report_Week__c,PSA_PM_List_of_Issues_Id__c,PSA_PM_List_of_Risks_Id__c, PSA_PM_Project__r.pse__Project_Status_Notes__c,
                    PSA_PM_Project__r.pse__Billing_Type__c,PSA_PM_Resources__c,PSA_PM_Schedule__c,PSA_PM_Scope__c,PSA_PM_Technical__c,Technical_Quality_Status__c,PSA_PM_Cost__c,Project_Status__c,Overall_Project_Status_Trend__c,Financial_Status__c,
                    PSA_PM_Key_Accomplishments__c , PSA_PM_Issues__c,PSA_PM_Next_Steps__c,PSA_PM_Project__r.pse__Account__r.Name from Status_Report__c where Id = :statusReportRec.id];
        //Get the Status Report Detail Records for Risks, Issues, Assignments, Milestones, and Project Activity
        List<Status_Report_Detail__c> statRepDetailLst = [Select Id,PSA_Issue__r.PSA_Issue_Owner__c,  PSA_Issue__r.PSA_Due_Date__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c,
                                                          PSA_Risk__c,PSA_Risk__r.pse__Risk_Name__c, PSA_Risk__r.PSA_Risk_Owner__c,PSA_Risk__r.pse__Risk_Description__c, PSA_Risk__r.pse__Mitigation_Plan__c, PSA_Risk__r.PSA_Status__c, PSA_Risk__r.PSA_Impact__c,                                                          
                                                          PSA_Issue__r.pse__Issue_Name__c,PSA_Issue__r.pse__Status__c, PSA_Issue__r.pse__Date_Raised__c,PSA_Issue__c,PSA_Issue__r.pse__Issue_Description__c, PSA_Issue__r.pse__Action_Plan__c,PSA_Issue__r.PSA_Priority__c,
                                                          PSA_Assignment__c, PSA_Assignment__r.pse__Resource__r.Name,PSA_Assignment__r.pse__Planned_Hours__c,PSA_Assignment__r.pse__Billable_Hours_Submitted__c,
                                                          PSA_Project_Activity__c, 
                                                          PSA_Milestone__c, PSA_Milestone__r.Name,PSA_Milestone__r.psa_pm_Project_Manager_Notes__c
                                                          from Status_Report_Detail__c  where PSA_Status_Report__c=:statusReportRec.id];
        totalPlannedHours = 0;
        totalHoursLogged = 0;
        totalRemainingHours = 0;
        //Display Tables for Risks, Issues, Assignments, Milestones
        for(Status_Report_Detail__c statRepDetailRec : statRepDetailLst){
            if(!String.isBlank(statRepDetailRec.PSA_Risk__c)){
                risksLst.add(statRepDetailRec);
                hasRisk = true;
                hasIssueandRisks = true;
            }
            if(!String.isBlank(statRepDetailRec.PSA_Issue__c)){
                issuesLst.add(statRepDetailRec);
                hasIssue = true;
                hasIssueandRisks = true;
            }           
            if(!String.isBlank(statRepDetailRec.PSA_Assignment__c)){
                asgmtLst.add(statRepDetailRec);
                hasAsgmt = true;
                totalPlannedHours = totalPlannedHours + statRepDetailRec.PSA_Assignment__r.pse__Planned_Hours__c;
                totalHoursLogged = totalHoursLogged + statRepDetailRec.PSA_Assignment__r.pse__Billable_Hours_Submitted__c;
            }
            if(!String.isBlank(statRepDetailRec.PSA_Milestone__c)){
                milestoneList.add(statRepDetailRec);
                hasMilestones = true;
            }
            if(!String.isBlank(statRepDetailRec.PSA_Project_Activity__c)){
                taskIds.add(statRepDetailRec.PSA_Project_Activity__c);
                hasProjActivity = true;
            }     
        }
        totalRemainingHours = totalPlannedHours - totalHoursLogged;
        //For Project Activity - Display Tables based on different Task Status
        if(hasProjActivity){
            List<Task> taskList = [SELECT Id,psa_Target_Date__c,psa_Actual_Date__c,psa_Comments__c,psa_Reason__c,psa_Critical_Path__c,psa_Status_Notes__c,psa_Status__c,subject,psa_Action_Plan__c FROM Task WHERE Id IN :taskIds];
            for(Task t : taskList){
                if(t.psa_Status__c == 'Accomplished'){
                    accTaskList.add(t);
                    hasAccTask = true;
                }
                else if(t.psa_Status__c == 'Incomplete'){
                    incompTaskList.add(t);
                    hasIncompleteTask = true;
                }
                else if(t.psa_Status__c == 'Upcoming'){
                    upcomTaskList.add(t);
                    hasUpcomingTask = true;
                }
            }
        }
    }
}