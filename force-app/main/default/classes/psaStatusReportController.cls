/*
Name             : psaStatusReportController 
@Author          : Ambica
@Created Date    : April 14, 2017
@Description     : FF-787:Reparent Status Report to Projects rather than Engagements    

Change Log
**************************************************************************************************************************
ModifiedBy  Date           JIRA No.  Requested By  Description                                            Tag
Lokesh      9/8/17        FF-1058     Agnes                                                               T01
**************************************************************************************************************************
*/


public class psaStatusReportController {
    
    
    public Status_Report__c statsRec {get;set;}   // Holds Details of Status Report Record
    public pse__Proj__c project{get;set;}   // Holds Details of Project associated to status report
    public List<pse__Milestone__c> milestones {get;set;}  // Holds details of Milestones on the Project associated to status report
    public List<pse__Assignment__c> assignments{get;set;}  // Holds details of Assignmnets on the Project associated to status report
    public List<pse__Timecard_Header__c> timecards;  // Holds details of all timcards on the Project associated to status report
    public List<pse__Timecard_Header__c> priorTimecards{get;set;}  // Holds details of timecards submitted in the previous week of status report generated 
    public Map<String,List<pse__Assignment__c>> mapAssign {get;set;}  //Holds map of Assignments grouped by Role
    public Map<String,double> mapTotal {get;set;}   //Holds  Sum of Planned hours from Assignments grouped by Role
    public Map<String,double> mapTotalAH {get;set;}     //Holds  Sum of Approved hours from Assignments grouped by Role
    public Map<pse__Assignment__c,Double> mapAH{get;set;} // holds the map of Approved hours for the assignment
    public boolean hasKey{get;set;} // boolean to render key accomplishments;
    public boolean hasIssue{get;set;}// boolean to render Issues;
    public boolean hasRisk{get;set;} // boolean to render Risks;
    public boolean hasNext{get;set;} //boolean to render Next steps;
   /* public boolean hasProject{get;set;}   //Boolean used to render the pageblock of all tables
    public boolean hasMilestones {get;set;} //Boolean used to render the pageblock  of milestone table
    public boolean hasSummaries {get;set;}  //Boolean used to render the pageblock  of Project Budget table */
    public boolean hastimecards{get;set;}   //Boolean used to render the pageblock  of time cards table 
    public double  priorWeekHours {get;set;} // Sum of hours from timecards submitted in the previous week of status report generated
   /* public List<pse__Risk__c> lstOfRisk{get;set;}
    public List<pse__Issue__c> lstOfIssue{get;set;} */
    public List<Status_Report_Detail__c> issuesLst{get;set;}
    public List<Status_Report_Detail__c> timecardsLst{get;set;}
    public List<Status_Report_Detail__c> risksLst{get;set;}
   // public string role{get;set;} //Holds the role of the Asssignment 
    public Decimal subtotal{get;set;} // Planned hours for the assignment grouped by role
   // public double subtotalAH{get;set;} //Approved hours for the assignment grouped by role
    public double grandtotal{get;set;} // total Planned hours for assignmnets on the project
    public double grandtotalAH{get;set;} //total Approved hours for assignmnets on the project
    public double approvedHours{get;set;} //approved hours for assignment from the timecards submitted 
    public string projectManagerName{get;set;} // Project Manager name
    private string milestoneQuery;  // Temp variable to hold the mailestoneQuery based on theproject billing type
    private string milstoneLabor ; //Temp variable to hold Milestone rec type name
    private string milstoneBilling ; //Temp variable to hold Milestone rec type name
    private Date previousWeekEndDate; //Temp variable to hold the Milestone Created Date minus 3 days.
  //  public String milestoneHeader{get;set;} // Temp variable to store the Milestones Heading to be displayed On VF Page
    public Map<Id,pse__Timecard_Header__c> mapTimecardSummary{get;set;} // Map of Timecard Rollup Summary Grouped By Resource
    public Map<Id,pse__Timecard_Header__c> mapTimecardSummaryNonBillable{get;set;}
    public double nonBillableHours{get;set;} // non bilable hours for assignment from the timecards submitted 
    public Map<pse__Assignment__c,Double> mapNBAH{get;set;} // holds the map of Non Billable hours for the assignment
  //  public double subtotalNBAH{get;set;} //Non Billable hours for the assignment grouped by role
    public Map<String,double> mapTotalNBAH {get;set;}   //Holds  Sum of Non Billable hours from Assignments grouped by Role
    public double grandtotalNBAH{get;set;} //total Non Billable hours for assignmnets on the projects
    public double grandtotalBH {get;set;}
    public Map<pse__Assignment__c,Double> mapBH{get;set;}
    public Map<String,String> stopLightMap{get;set;}
    public List<String> stopLightStr{get;set;}
    public boolean hasStopLight{get;set;}
   /* public boolean hasBillableTimeCards{get;set;}
    public boolean hasNonBillableTimeCards{get;set;} */
    public double billableHours ;
   // public double subtotalBAH{get;set;} // Billable Approved hours for the assignment grouped by role
    public Map<String,double> mapTotalBAH {get;set;}     //Holds  Sum of Billabel Approved hours from Assignments grouped by Role
    
    
    
    public psaStatusReportController(ApexPages.StandardController stdController) {
        
        
        //get the details of status report from the controller variable
        Status_Report__c statusReportRec =(Status_Report__c)stdController.getRecord();
        system.debug('srrec**' +statusReportRec);
        
        // Query for the Status Report record
        statsRec = [Select Id,PSA_PM_Project__c,PSA_PM_Project__r.pse__Project_Manager__r.Name,PSA_PM_Status_Report_Week__c,PSA_PM_List_of_Issues_Id__c,PSA_PM_List_of_Risks_Id__c,
                    PSA_PM_Resources__c,PSA_PM_Schedule__c,PSA_PM_Scope__c,PSA_PM_Technical__c,PSA_PM_Cost__c, PSA_PM_Key_Accomplishments__c , PSA_PM_Issues__c,PSA_PM_Next_Steps__c from Status_Report__c where Id = :statusReportRec.id];
        
        List<Status_Report_Detail__c> statRepDetailLst = [Select Id,PSA_Issue__r.PSA_Issue_Owner__c,  PSA_Issue__r.PSA_Due_Date__c,PSA_Status_Report__c,PSA_Status_Report__r.PSA_PM_Project__c,
                                                          PSA_Risk__c,PSA_Risk__r.PSA_Risk_Owner__c,PSA_Risk__r.pse__Risk_Description__c, PSA_Risk__r.pse__Mitigation_Plan__c, PSA_Risk__r.PSA_Status__c, PSA_Risk__r.PSA_Impact__c,
                                                          PSA_Timecard__c,PSA_Timecard__r.pse__Resource__r.Name,PSA_Timecard__r.PSA_TM_Resource_Role__c, PSA_Timecard__r.pse__Total_Hours__c, 
                                                          PSA_Issue__c,PSA_Issue__r.pse__Issue_Description__c, PSA_Issue__r.pse__Action_Plan__c, PSA_Issue__r.PSA_Status__c,PSA_Issue__r.PSA_Priority__c
                                                          from Status_Report_Detail__c  where PSA_Status_Report__c=:statusReportRec.id];
        
        
        issuesLst = new List<Status_Report_Detail__c>();
        timecardsLst = new List<Status_Report_Detail__c>();
        risksLst = new List<Status_Report_Detail__c>();
        for(Status_Report_Detail__c statRepDetailRec : statRepDetailLst){
            if(!String.isBlank(statRepDetailRec.PSA_Risk__c)){
                risksLst.add(statRepDetailRec);
            }
            if(!String.isBlank(statRepDetailRec.PSA_Issue__c)){
                issuesLst.add(statRepDetailRec);
            }
            if(!String.isBlank(statRepDetailRec.PSA_Timecard__c)){
                timecardsLst.add(statRepDetailRec);
            }
        }
        
        
        
        if(!issuesLst.isEmpty()){
            hasIssue = true;
        }
        if(!risksLst.isEmpty()){
            hasRisk = true;
        }
        if(!timecardsLst.isEmpty()){
            hastimecards = true;
        }
        
        
        /* // Query for List of Issues attached to the Report
if(!String.isBlank(statsRec.PSA_PM_List_of_Issues_Id__c)){
List<Id> issueIdList = new List<Id>();
issueIdList = statsRec.PSA_PM_List_of_Issues_Id__c.split(',');
Set<Id> issueIds = new Set<Id>(issueIdList);
lstOfIssue = [Select Id,PSA_Status__c,pse__Issue_Name__c,PSA_Priority__c, pse__Issue_Description__c,pse__Action_Plan__c,pse__Priority__c, pse__Date_Raised__c, pse__Closed_Date__c, pse__Status__c,pse__Severity__c  
from pse__Issue__c where Id=:issueIds order by pse__Priority__c asc];

}
// Query for List of Risks attached to the Report
if(!String.isBlank(statsRec.PSA_PM_List_of_Risks_Id__c)){
List<Id> risKIdList = new List<Id>();
risKIdList = statsRec.PSA_PM_List_of_Risks_Id__c.split(',');
Set<Id> riskIds = new Set<Id>(risKIdList);
lstOfRisk = [Select Id,PSA_Status__c,pse__Risk_Name__c,PSA_Risk_History__c,PSA_Impact__c, pse__Risk_Description__c,pse__Mitigation_Plan__c,pse__Severity__c, pse__Date_Raised__c, pse__Closed_Date__c, pse__Status__c  
from pse__Risk__c where Id=:riskIds order by pse__Severity__c asc];            
} */
        //initialize all variables
        stopLightMap = new Map<String,String>();
        
        
        if(!String.isBlank(statsRec.PSA_PM_Cost__c)){
            stopLightMap.put('Budget',getStopLightColor(statsRec.PSA_PM_Cost__c));
        }
        if(!String.isBlank(statsRec.PSA_PM_Resources__c)){
            stopLightMap.put('Resource',getStopLightColor(statsRec.PSA_PM_Resources__c));
        }
        if(!String.isBlank(statsRec.PSA_PM_Schedule__c)){
            stopLightMap.put('Schedule',getStopLightColor(statsRec.PSA_PM_Schedule__c));
        }
        if(!String.isBlank(statsRec.PSA_PM_Scope__c)){
            stopLightMap.put('Scope',getStopLightColor(statsRec.PSA_PM_Scope__c));
        }
        if(!String.isBlank(statsRec.PSA_PM_Technical__c)){
            stopLightMap.put('Technical',getStopLightColor(statsRec.PSA_PM_Technical__c));
        }
        
        if(!stopLightMap.isEmpty()){
            hasStopLight = true;
            stopLightStr = new List<String>(stopLightMap.keySet());
        }
        system.debug('value of stopLightMap'+stopLightMap);
        hasKey= statsRec.PSA_PM_Key_Accomplishments__c!=null? true :false;
        // hasIssue=statsRec.PSA_PM_List_of_Issues_Id__c!=null? true :false;
        // hasRisk=statsRec.PSA_PM_List_of_Risks_Id__c!=null? true :false;
        hasNext=statsRec.PSA_PM_Next_Steps__c !=null? true : false;
        projectManagerName = statsRec.PSA_PM_Project__r.pse__Project_Manager__r.Name;
        milstoneLabor ='Labor'; 
        milstoneBilling ='Billing';
        priorWeekHours=0;
        subtotal=0;
        grandtotal=0;
        approvedHours=0;
        billableHours=0;
        grandtotal=0;
        grandtotalAH=0;
        grandtotalNBAH=0;
        nonBillableHours=0;
        grandtotalBH=0;
        priorTimecards= new List<pse__Timecard_Header__c>();
        mapAssign = new Map<String , List<pse__Assignment__c>>();
        mapTotal= new map<string,double>();
        project = new pse__Proj__c();
        milestones= new List<pse__Milestone__c>();
        assignments= new List<pse__Assignment__c>();
        timecards = new List<pse__Timecard_Header__c>();
        mapTotalAH = new MAP<String,Double>();
        mapAH= new Map<pse__Assignment__c,Double>();
        mapNBAH = new Map<pse__Assignment__c,Double>();
        mapBH = new Map<pse__Assignment__c,Double>();
        mapTotalNBAH = new MAP<String,Double>();
        previousWeekEndDate = statsRec.PSA_PM_Status_Report_Week__c - 2; // calculate previous week end Date
        system.debug('previousWeekEndDate'+previousWeekEndDate);
        mapTimecardSummary = new Map<Id,pse__Timecard_Header__c>();
        mapTimecardSummaryNonBillable = new Map<Id,pse__Timecard_Header__c>(); 
        mapTotalBAH = new Map<String, Double>();
        
        /*
If(statsRec.PSA_PM_Project__c!=null ){

//get project deatils
project =[Select id, name , pse__Planned_Hours__c,psa_pm_Total_Billable_Hours__c,pse__Billing_Type__c from pse__Proj__c where id =:statsRec.PSA_PM_Project__c limit 1 ];
project.pse__Planned_Hours__c = (project.pse__Planned_Hours__c==null)?0:project.pse__Planned_Hours__c;

//get project milstones - the Labor Milestones for the Time and Materials Projects and the Billing Milestones for the Fixed Price Projects

milestoneHeader= project.pse__Billing_Type__c =='Time and Materials'? 'Milestones':'Approved/Completed Milestones';
milestoneQuery=(project.pse__Billing_Type__c =='Time and Materials')?'Select Id,name,  pse__Planned_Hours__c,psa_pm_Record_Type__c,PSA_PM_Remaining_Hours__c,psa_pm_Original_Target_Date__c,pse__Target_Date__c from pse__Milestone__c where (DAY_ONLY(CreatedDate) <=:previousWeekEndDate OR (DAY_ONLY(CreatedDate) >= :previousWeekEndDate and pse__Target_Date__c <= :previousWeekEndDate)) and pse__Project__c = \''+ statsRec.PSA_PM_Project__c +'\'and psa_pm_Record_Type__c =\''+ milstoneLabor +'\'':'Select Id,name, psa_pm_Record_Type__c, pse__Planned_Hours__c,PSA_PM_Remaining_Hours__c,psa_pm_Original_Target_Date__c,pse__Target_Date__c from pse__Milestone__c where pse__Actual_Date__c <= :previousWeekEndDate and (NOT Name like \'%Per Diem%\') and pse__Project__c =\''+statsRec.PSA_PM_Project__c+'\' and psa_pm_Record_Type__c =\''+milstoneBilling+'\' and pse__Approved__c=true';

system.debug('++++++'+milestoneQuery);
milestones= database.query(milestoneQuery);

//get timecards associated to project
// Timecards= [select id,pse__Assignment__c, name,pse__Resource__c,pse__Resource__r.Name, pse__Sunday_Hours__c, pse__Monday_Hours__c,pse__Tuesday_Hours__c,pse__Wednesday_Hours__c,pse__Thursday_Hours__c,pse__Friday_Hours__c,pse__Saturday_Hours__c,pse__Total_Hours__c ,pse__End_Date__c from pse__Timecard_Header__c where  pse__Project__c=:sr.PSA_PM_Project__c and  pse__Approved__c=true and pse__Billable__c=true ];

/*------------------------<T01> Removed the psa__Billable__c = true from the Timecard SOQL Query to include the Non Billable Hours ------------------------ *
timecards= [select id,pse__Assignment__c,pse__Status__c,pse__Timecard_Header__c.pse__Approved__c,pse__Billable__c, name,pse__Resource__c,pse__Resource__r.Name, pse__Sunday_Hours__c, pse__Monday_Hours__c,pse__Tuesday_Hours__c,pse__Wednesday_Hours__c,pse__Thursday_Hours__c,pse__Friday_Hours__c,pse__Saturday_Hours__c,pse__Total_Hours__c ,pse__End_Date__c from pse__Timecard_Header__c where pse__End_Date__c <= :previousWeekEndDate and pse__Project__c=:statsRec.PSA_PM_Project__c];

/* --------------------------------------------</T01>------------------------------------------------------------------- *

//get project assignments
assignments = [Select id,name,pse__Role__c, pse__Resource__c, pse__Resource__r.name,pse__Planned_Hours__c from pse__Assignment__c where pse__Start_Date__c <= :previousWeekEndDate and pse__Project__c=:statsRec.PSA_PM_Project__c];




//calculate budget summary 
for(pse__Assignment__c a :assignments){
List<pse__Assignment__c> lstassgn = new List<pse__Assignment__c>();
subtotal=0;
subtotalAH=0;
subtotalNBAH=0;
subtotalBAH =0;
for (pse__Assignment__c  assgn : assignments){
if(!string.isBlank(assgn.pse__Role__c) && !string.isBlank(a.pse__Role__c) && assgn.pse__Role__c.equals(a.pse__Role__c)){
assgn.pse__Planned_Hours__c =  (assgn.pse__Planned_Hours__c==null)?0:assgn.pse__Planned_Hours__c;
lstassgn.add(assgn);
subtotal+=assgn.pse__Planned_Hours__c!=null?assgn.pse__Planned_Hours__c:0;                      
ApprovedHours=0;
BillableHours=0;
NonBillableHours=0;
for(pse__Timecard_Header__c tmcard : Timecards){     
if(tmcard.pse__Assignment__c==assgn.id &&  tmcard.pse__Approved__c){
ApprovedHours+=tmcard.pse__Total_Hours__c!=null?tmcard.pse__Total_Hours__c:0 ;
/* ----------------------------------<T01>----------------------------------------------------------------------*
if(!tmcard.pse__Billable__c){
NonBillableHours+= tmcard.pse__Total_Hours__c!=null?tmcard.pse__Total_Hours__c:0 ;
}
else{
BillableHours+= tmcard.pse__Total_Hours__c!=null?tmcard.pse__Total_Hours__c:0 ;
}
/* ----------------------------------</T01>----------------------------------------------------------------------*
}

}
mapBH.put(assgn,BillableHours); 
mapAh.put(assgn,ApprovedHours);
mapNBAH.put(assgn,NonBillableHours);  //<T01>
subtotalAH+=mapAh.get(assgn);
subtotalNBAH+=mapNBAH.get(assgn); //<T01>
subtotalBAH+=mapBH.get(assgn); //<T01>


}
}  
grandtotal+=a.pse__Planned_Hours__c;
if(mapAh.containsKey(a)){
grandtotalAH += mapAh.get(a); 
}
if(mapNBAH.containsKey(a)){
grandtotalNBAH += mapNBAH.get(a); //<T01>
}
if(mapBH.containsKey(a)){
grandtotalBH += mapBH.get(a);
}

mapAssign.put((String)a.pse__Role__c, lstassgn);
mapTotal.put((String)a.pse__Role__c,subtotal);
mapTotalAH.put((String)a.pse__Role__c,subtotalAH );
mapTotalNBAH.put((String)a.pse__Role__c,subtotalNBAH); //<T01>
mapTotalBAH.put((String)a.pse__Role__c,subtotalBAH); //<T01>

}


//calucuate time card summary
for (pse__Timecard_Header__c tm :timecards){
if(tm.pse__End_Date__c == statsRec.PSA_PM_Status_Report_Week__c-2 && !tm.pse__Approved__c && tm.pse__Status__c=='Submitted'){
pse__Timecard_Header__c tmcard = new pse__Timecard_Header__c();
if(tm.pse__Billable__c){
if(!mapTimecardSummary.containsKey(tm.pse__Resource__c)){
mapTimecardSummary.put(tm.pse__Resource__c,tm);
}else{
tmcard = mapTimecardSummary.get(tm.pse__Resource__c);
tmcard.pse__Monday_Hours__c     += tm.pse__Monday_Hours__c;
tmcard.pse__Tuesday_Hours__c    += tm.pse__Tuesday_Hours__c;
tmcard.pse__Wednesday_Hours__c  += tm.pse__Wednesday_Hours__c;
tmcard.pse__Thursday_Hours__c   += tm.pse__Thursday_Hours__c;
tmcard.pse__Friday_Hours__c     += tm.pse__Friday_Hours__c;
tmcard.pse__Saturday_Hours__c   += tm.pse__Saturday_Hours__c;
tmcard.pse__Sunday_Hours__c     += tm.pse__Sunday_Hours__c;
mapTimecardSummary.put(tm.pse__Resource__c,tmcard);
}
}else{
if(!mapTimecardSummaryNonBillable.containsKey(tm.pse__Resource__c)){
mapTimecardSummaryNonBillable.put(tm.pse__Resource__c,tm);
}else{
tmcard = mapTimecardSummaryNonBillable.get(tm.pse__Resource__c);
tmcard.pse__Monday_Hours__c     += tm.pse__Monday_Hours__c;
tmcard.pse__Tuesday_Hours__c    += tm.pse__Tuesday_Hours__c;
tmcard.pse__Wednesday_Hours__c  += tm.pse__Wednesday_Hours__c;
tmcard.pse__Thursday_Hours__c   += tm.pse__Thursday_Hours__c;
tmcard.pse__Friday_Hours__c     += tm.pse__Friday_Hours__c;
tmcard.pse__Saturday_Hours__c   += tm.pse__Saturday_Hours__c;
tmcard.pse__Sunday_Hours__c     += tm.pse__Sunday_Hours__c;
mapTimecardSummaryNonBillable.put(tm.pse__Resource__c,tmcard);
}  
}

priorWeekHours +=tm.pse__Total_Hours__c!=null?tm.pse__Total_Hours__c:0;
}
}

}

hasProject=(statsRec.PSA_PM_Project__c!=null);
hasMilestones = (milestones!= null && milestones.size() > 0 );
hasSummaries = (Assignments != null && Assignments .size() > 0 && Project.pse__Billing_Type__c !='Fixed Price');
hasBillableTimeCards = (mapTimecardSummary!= null && !mapTimecardSummary.isEmpty());
hasNonBillableTimeCards = (mapTimecardSummaryNonBillable!= null && !mapTimecardSummaryNonBillable.isEmpty());
//  hastimecards=((hasBillableTimeCards || hasNonBillableTimeCards) && Project.pse__Billing_Type__c !='Fixed Price'); */
        
        
    }
    public string getStopLightColor(String stopLightcolor){
        
        String imageUrl ='/s.gif';
        if(!string.isBlank(stopLightcolor)){
            if(stopLightcolor.equalsIgnoreCase('Red')){
                imageUrl = '/resource/1612763763000/StatusReportIndication_Red?';
            }else if(stopLightcolor.equalsIgnoreCase('Yellow')){
                imageUrl = '/resource/1612843438000/StatusReportIndication_Yellow?';
            }else if(stopLightcolor.equalsIgnoreCase('Green')){
                imageUrl = '/resource/1612763353000/StatusReportIndication_Green';
            }
        }
        return imageUrl;
        
    }
}