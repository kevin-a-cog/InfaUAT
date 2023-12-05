/*
@created by       : MAHESH GANTI
@created on       : 11/05/2020
@Purpose          : Resource Request Trigger Helper.

Change History
*************************************************************************************************************************************************************************
ModifiedBy              Date            Requested By            Description                                                         Jira No.        Tag
*************************************************************************************************************************************************************************
Pavithra V              01-08-2021        NA                  Resource Request's "MSA Code" and "Work Location - MSA"               PSA-933         <T01>
                                                              must be populated with Project's Primary Location
K. Goutam               01-15-2021        NA                  Fixed null pointer issue on trigger
P. Sharma               02-08-2020        NA                  if the parent Opportunity has no project and if so, 
                                                              default status=Forecast on RR.
S. Chouhan              23-02-2021        NA                  if pse__Resource_Held__c changes from checked to unchecked, 
                                                              make the lookup pse__Resource__c=blank value
S. Chouhan              22-02-2021        NA                  When Submit for staffing is checked the Status 
                                                              Should change to "Ready for Staffing"
S. Chouhan              23-02-2021        NA                  we changed in trigger when status value is 'Tentative' 
                                                              than Suggested Resources should be blank.
Vivek Warrier           23-Mar-2021       NA                  Making sure Time Credited != Billable                                                 <T02>
Vivek Warrier           23-Mar-2021       NA                  Ensuring Status is not updated when Resource is Held                                  <T03>
Ranjan                  01-Apr-2021       NA                  Mapping RR fields using Project Location fields                       PSA-1499        <T04>
                                                              (Not on MSA Code Mapping Fields)
Ranjan                  28-04-2021        NA                  Populate MSA code Mapping on Assignment                               PSA-1537        <T05>
                                                              on Insert/Update  
Ranjan                  19-05-2021        NA                  Ensuring status is not updated back to Ready to staff                 PSA-1584        <T06>
                                                              after assignment
Vivek Warrier           14-Mar-2022       Neha Kumari         Ensuring the Requested Bill Rate is flown down to 
                                                              Assignments and timecards                                             PSA-2276        <T07>
Wasim Akram             25-Jul-2022      Neha Kumari          Alert while creating Billable Hours RR when Budget is used            PSA-2048        <T08>              
Wasim Akram             22-Mar-2023      Neha Kumari          Default fields when the Type = Shadowing                              PSA-2917        <T09>
Rohit Niranjanamath     09-Sep-2023      Neha Kumari          Resource Manager field addition to RR and PSA Contact Page layouts    PSA-3079        <T10>
Wasim Akram             04-Oct-2023      NA                   Tech debt-Separate PSG for Ops-Rev Ops and Sub-con                    PSA-2925        <T11>

*/
public without Sharing class psa_rm_ResourceRequestTriggerHelper {
    
    public static globalApexManager GAM = new globalApexManager();
    public static Boolean isReadyToStaff = false;
    @TestVisible private static Boolean isTestRun = false;
    
    public void defaultResReqFieldValOnInsert(List<pse__Resource_Request__c> resReqList){
        system.debug('**RRTH-resReqList**________'+resReqList);
        
        List<pse__Resource_Request__c> calAllocPercentRecs = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> checkForMSALocationList = new List<pse__Resource_Request__c>();
        Map<Id,Id> resReqMSAIdMap = new Map<Id,Id>();
        Set<Id> staffResIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>(); /**<T01>**/
        
        Set<Id> setProjectId = new Set<Id>();
        Set<Id> setOpptyId = new Set<Id>();
        
        // First loop to check the records - PRE CONDITIONS.
        for(pse__Resource_Request__c rrRec : resReqList){
            //Update RR Name
            String name = String.isBlank(rrRec.Name) ? '' : rrRec.Name;
            String reportProjectName = String.isBlank(rrRec.psa_report__Project_Name__c) ? '' : rrRec.psa_report__Project_Name__c;
            String resourceRole = String.isBlank(rrRec.pse__Resource_Role__c) ? '' : rrRec.pse__Resource_Role__c;
            rrRec.pse__Resource_Request_Name__c =  name + ' ' + reportProjectName + ' '+ resourceRole;

            if(rrRec.pse__Start_Date__c <> null && rrRec.pse__End_Date__c <> null && rrRec.pse__Staffer_Resource__c <> null){
                staffResIdSet.add(rrRec.pse__Staffer_Resource__c);
                calAllocPercentRecs.add(rrRec);
            }
            
            if(rrRec.psa_rm_Resource_Location__c == null){
                setProjectId.add(rrRec.pse__Project__c);
            }
            
            if(rrRec.pse__Project__c != null){
                projectIdSet.add(rrRec.pse__Project__c); /**<T01>**/
            }
            if(rrRec.pse__Opportunity__c != null){
                setOpptyId.add(rrRec.pse__Opportunity__c); /**<T01>**/
            }
        }
        system.debug('**RRTH-staffResIdSet**________'+staffResIdSet);
        system.debug('**RRTH-calAllocPercentRecs**________'+calAllocPercentRecs);
        system.debug('**RRTH-projectIdSet**________'+projectIdSet);
        
        Map<Id, Id> mapProjectIdToPrimaryLocationId = new Map<Id, Id>();
        List<pse__Project_Location__c> lstProjectLocation = [Select Id,psa_pm_Primary__c,pse__Project__c, PSA_Work_Street__c,psa_PM_Work_City__c, PSA_PM_Work_State__c, 
                                                             PSA_PM_Work_County__c,PSA_PM_Work_Province__c, PSA_Work_Country__c,PSA_Work_Zip_Postal_Code__c,
                                                             psa_pm_MSA_Code_Mapping__c, psa_pm_MSA_Code_Mapping__r.psa_pm_MSA_Code__c
                                                             from pse__Project_Location__c Where pse__Project__c in :projectIdSet];// <T04>
        
        Map<Id,pse__Project_Location__c> projectLocationMap = new Map<Id,pse__Project_Location__c>(lstProjectLocation);
        
        for(pse__Project_Location__c projectLocation : lstProjectLocation){
            if(projectLocation.psa_pm_Primary__c){ // <T04>
                mapProjectIdToPrimaryLocationId.put(projectLocation.pse__Project__c, projectLocation.Id);  
            }
        }
        
        if(staffResIdSet.size()>0){
            populateAllocationPercentage(staffResIdSet,calAllocPercentRecs); 
        }
        Map<Id, Integer> mapOpportunitywithProject = new Map<Id, Integer>();
        List<Opportunity> lstofOpportunity =[select id,(select id from pse__Projects__r ) from Opportunity where Id IN: setOpptyId];
        for(Opportunity Oppty : lstofOpportunity){
            mapOpportunitywithProject.put(Oppty.id, Oppty.pse__Projects__r.Size());
        }
        
        /*Map<Id,pse__Proj__c> projectMap = new Map<Id,pse__Proj__c>([SELECT Id,psa_pm_Primary_Project_Location__c FROM pse__Proj__c WHERE Id IN: projectIdSet]);
        Map<Id,pse__Project_Location__c> projectLocationMap = new Map<Id,pse__Project_Location__c>([SELECT Id,pse__Project__c,psa_pm_MSA_Code_Mapping__c FROM pse__Project_Location__c 
        WHERE pse__Project__c IN: projectIdSet]);*/  // <T04>
        
        for(pse__Resource_Request__c rrRec : resReqList){
            
            if(String.isBlank(rrRec.psa_rm_Resource_Location__c) && !String.isBlank(rrRec.pse__Project__c)
               && mapProjectIdToPrimaryLocationId.containsKey(rrRec.pse__Project__c)){
                   rrRec.psa_rm_Resource_Location__c = mapProjectIdToPrimaryLocationId.get(rrRec.pse__Project__c);
                   system.debug('Checking Res Req Projec '+mapProjectIdToPrimaryLocationId.get(rrRec.pse__Project__c));
                   
                   // Mapping project Location field values to Resource Request Record
                   populateMSAFieldsFromProjLoc(rrRec,projectLocationMap.get(mapProjectIdToPrimaryLocationId.get(rrRec.pse__Project__c)));
               }
            
            if(rrRec.pse__Opportunity__c != null && rrRec.pse__Project__c == null ){
                 rrRec.pse__Status__c = 'Forecast'; 
            }            
            if(rrRec.PSA_RM_Submit_for_Staffing__c == true && rrRec.pse__Resource_Held__c == false){//Adding Held condition <T03>
                rrRec.pse__Status__c = 'Ready to Staff';
            }   
        }
        // <T04>
        /* system.debug('**RRTH-resReqMSAIdMap**________'+resReqMSAIdMap);
        if(resReqMSAIdMap.size()>0){
        populateMSAFields(resReqMSAIdMap,resReqList);
        } */
        
    }
    //<T10> - Start
    public void updateRMOContactFieldOnRR(Map<Id, pse__Resource_Request__c> oldRRMap,List<pse__Resource_Request__c> newRRList){

        Set<Id> regionIds = new Set<Id>();
        // Collect the unique pse__Region__c IDs from the newRRList
        for(pse__Resource_Request__c rrRec : newRRList){
            if (rrRec.pse__Region__c!=null && (oldRRMap == null || (oldRRMap !=null && oldRRMap.get(rrRec.Id).pse__Region__c != rrRec.pse__Region__c && rrRec.pse__Region__c != null))) {
                regionIds.add(rrRec.pse__Region__c);
            }
        }
        if(!regionIds.isEmpty()){
        // Query for pse__Region__c records in bulk and update ResourceRequest records with psa_RMO_Contact__c from corresponding pse__Region__c records
        Map<Id, pse__Region__c> regionMap = new Map<Id, pse__Region__c>([SELECT Id, psa_RMO_Contact__c FROM pse__Region__c WHERE Id IN :regionIds]);

        // Update resourceRequest records with psa_RMO_Contact__c from corresponding pse__Region__c records
        for(pse__Resource_Request__c rrRec : newRRList){
            rrRec.psa_RMO_Contact__c = regionMap.get(rrRec.pse__Region__c)?.psa_RMO_Contact__c;
        } 
        }
            
    }
    //<T10> - End 

    public void defaultResReqFieldValOnUpdate(List<pse__Resource_Request__c> oldRRList,List<pse__Resource_Request__c> newRRList, Map<Id,pse__Resource_Request__c> oldRRMap, Map<Id,pse__Resource_Request__c> newRRMap){
        
        List<pse__Resource_Request__c> calAllocPercentRecs = new List<pse__Resource_Request__c>();
        Set<Id> staffResIdSet = new Set<Id>();
        List<pse__Resource_Request__c> filteredMSALocationList = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> checkForMSALocationList = new List<pse__Resource_Request__c>();
        Map<Id,Id> resReqMSAIdMap = new Map<Id,Id>();
        Set<Id> projectIdSet = new Set<Id>(); /**<T01>**/
    
        for(pse__Resource_Request__c rrRec : newRRList){
            //Update RR Name
            String name = String.isBlank(rrRec.Name) ? '' : rrRec.Name;
            String reportProjectName = String.isBlank(rrRec.psa_report__Project_Name__c) ? '' : rrRec.psa_report__Project_Name__c;
            String resourceRole = String.isBlank(rrRec.pse__Resource_Role__c) ? '' : rrRec.pse__Resource_Role__c;
            rrRec.pse__Resource_Request_Name__c =  name + ' ' + reportProjectName + ' '+ resourceRole;

            if((rrRec.pse__Start_Date__c <> oldRRMap.get(rrRec.Id).pse__Start_Date__c && rrRec.pse__Start_Date__c <> NULL) ||
               (rrRec.pse__End_Date__c <> oldRRMap.get(rrRec.Id).pse__End_Date__c && rrRec.pse__End_Date__c <> NULL) ||
               (rrRec.pse__Staffer_Resource__c <> oldRRMap.get(rrRec.Id).pse__Staffer_Resource__c && rrRec.pse__Staffer_Resource__c <> NULL)){
                   staffResIdSet.add(rrRec.pse__Staffer_Resource__c);
                   calAllocPercentRecs.add(rrRec);
               }
            
            if(rrRec.pse__Project__c != null){
                projectIdSet.add(rrRec.pse__Project__c); /**<T01>**/
            }
            
            if(rrRec.PSA_RM_Submit_for_Staffing__c == true && rrRec.pse__Resource_Held__c == false
              && String.isBlank(rrRec.pse__Assignment__c)){//Adding Held condition <T03> // Adding Assignment check <T06>
                rrRec.pse__Status__c = 'Ready to Staff';
                isReadyToStaff = true;
            }
            
            if(rrRec.pse__Resource_Held__c == false && oldRRMap.get(rrRec.Id).pse__Resource_Held__c == true){
                rrRec.pse__Resource__c = null;
            } 
            if(rrRec.pse__Status__c == 'Tentative'){
                rrRec.pse__Resource__c = null;
            } 
        }
        system.debug('**RRTH-calAllocPercentRecs**________'+calAllocPercentRecs);
        
        if(staffResIdSet.size()>0){
            populateAllocationPercentage(staffResIdSet,calAllocPercentRecs); 
        }
        
        // MSA LOGIC STARTS
        
        /**<T01> ~ START **/
        List<pse__Project_Location__c> lstProjectLocation = [Select Id,psa_pm_Primary__c,pse__Project__c, PSA_Work_Street__c,psa_PM_Work_City__c, PSA_PM_Work_State__c, 
                                                             PSA_PM_Work_County__c,PSA_PM_Work_Province__c, PSA_Work_Country__c,PSA_Work_Zip_Postal_Code__c,
                                                             psa_pm_MSA_Code_Mapping__c, psa_pm_MSA_Code_Mapping__r.psa_pm_MSA_Code__c
                                                             from pse__Project_Location__c Where pse__Project__c in :projectIdSet];// <T04>
        
        Map<Id,pse__Project_Location__c> projectLocationMap = new Map<Id,pse__Project_Location__c>(lstProjectLocation);
        
        if(!projectLocationMap.isEmpty() && projectLocationMap!=null){
            for(pse__Resource_Request__c rrRec : newRRList){
                pse__Resource_Request__c oldResReq =  oldRRMap.get(rrRec.Id);
                if(!String.isBlank(rrRec.psa_rm_Resource_Location__c) &&
                   oldResReq.psa_rm_Resource_Location__c!=rrRec.psa_rm_Resource_Location__c &&
                   projectLocationMap.containsKey(rrRec.psa_rm_Resource_Location__c)){
                       populateMSAFieldsFromProjLoc(rrRec,projectLocationMap.get(rrRec.psa_rm_Resource_Location__c)); 
                   }
                
                
            }
        }
    }
    //<T08>
     /**
    * Method to validate Expense Budget Limit during the RR Submit for Staffing.
    * @param List<pse__Expense__c>,List<pse__Expense__c>,Map<Id,pse__Expense__c>,Map<Id,pse__Expense__c>
    * @return 
    * @throws exception - NA
    */
    public void validateRRExceededBudget(List<pse__Resource_Request__c> oldRRList,List<pse__Resource_Request__c> newRRList, Map<Id,pse__Resource_Request__c> oldRRMap, Map<Id,pse__Resource_Request__c> newRRMap){
        Set<Id> projectIdSet = new Set<Id>();
        String errorMessage;
        Map<Id,Decimal> mapProjectTotalBudgetAmt = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProjectTotalBillableRRAmt = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProjectTotalMilestoneAmt = new Map<Id,Decimal>();
        Map<Id,String> mapProjectName = new Map<Id,String>();
        Map<String,Decimal> mapCurrencyExcRate = new Map<String,Decimal>();
        Decimal totalBudgetAmt, totalMilestoneAmt, totalBillableRRAmt;
        Decimal billableRRAmt = 0;
        Map<Id,String> mapProjIdCurrencyCode = new Map<Id,String>();
        //Get Unique set of project Ids
        for(pse__Resource_Request__c rr: newRRList){
            //If Submit for Staffing is checked and RR is billable
            if(rr.psa_rm_Billable__c && rr.PSA_RM_Submit_for_Staffing__c && !oldRRMap.get(rr.Id).PSA_RM_Submit_for_Staffing__c){
                projectIdSet.add(rr.pse__Project__c);
                if(!mapProjIdCurrencyCode.containsKey(rr.pse__Project__c)){
                    mapProjIdCurrencyCode.put(rr.pse__Project__c,rr.CurrencyIsoCode);
                }
            }
            //If it is updated from RR record page UI
            if(newRRList.size() == 1 && isReadyToStaff && rr.psa_rm_Billable__c && rr.pse__Request_Billable_Amount__c != null){
                billableRRAmt = rr.pse__Request_Billable_Amount__c;
            }
        }
        if(projectIdSet.size() > 0 || isTestRun){
            //Get the Total of Expense Budget for the Projects
            AggregateResult[] agrBudgetAmount = [SELECT SUM(pse__Amount__c) totalBudgetAmount, pse__Project__c FROM pse__Budget__c 
                                                 WHERE pse__Project__c IN :projectIdSet AND pse__Type__c != 'Internal Budget' 
                                                 AND pse__Include_In_Financials__c = TRUE AND pse__Approved__c = TRUE
                                                 GROUP BY pse__Project__c];

            //Get the Total Billable RR for the project
            AggregateResult[] agrBillableRRAmount = [SELECT SUM(pse__Request_Billable_Amount__c) totalBillableRRAmount, pse__Project__c FROM pse__Resource_Request__c
                                                     WHERE pse__Project__c IN :projectIdSet AND psa_rm_Billable__c = TRUE 
                                                     AND pse__Status__c IN ('Ready to Staff','Assigned') 
                                                     GROUP BY pse__Project__c]; 
            
            //Get the Total Milestone Amount for the project
            AggregateResult[] agrMilestoneAmount = [SELECT SUM(pse__Milestone_Amount__c) totalMilestoneAmount, pse__Project__c FROM pse__Milestone__c
                                                    WHERE pse__Project__c IN :projectIdSet AND pse__Status__c != 'Canceled'
                                                    GROUP BY pse__Project__c]; 
            //Get the Conversion Rate for the Currencies
            for(DatedConversionRate DCR : [SELECT Id,ConversionRate,IsoCode FROM DatedConversionRate WHERE StartDate = THIS_MONTH]){
                mapCurrencyExcRate.put(DCR.IsoCode, DCR.ConversionRate);
            }

            for (AggregateResult ar : agrBudgetAmount)  {
                //Add it to a map of Project Id and Total Expense Budget for the project
                mapProjectTotalBudgetAmt.put((Id) ar.get('pse__Project__c'), (Decimal) ar.get('totalBudgetAmount'));
            }
            for (AggregateResult ar : agrBillableRRAmount)  {
                //Add it to a map of Project Id and Total Billable RR Amount for the project
                mapProjectTotalBillableRRAmt.put((Id) ar.get('pse__Project__c'), (Decimal) ar.get('totalBillableRRAmount'));  
            }
            for (AggregateResult ar : agrMilestoneAmount)  {
                //Add it to a map of Project Id and Total Milestone Amount for the project
                mapProjectTotalMilestoneAmt.put((Id) ar.get('pse__Project__c'), (Decimal) ar.get('totalMilestoneAmount'));
            }
            //Loop through the projects and compare the Expense Budget amount and Sum of Total Milestone amount and Billable RR amount for the project
            projectIdSet.clear();
            Decimal currencyConversionRate;       
            for(Id projectId : mapProjectTotalBudgetAmt.KeySet()){                
                currencyConversionRate = mapCurrencyExcRate.get(mapProjIdCurrencyCode.get(projectId)) == null ? 1 : mapCurrencyExcRate.get(mapProjIdCurrencyCode.get(projectId));
                totalBudgetAmt = mapProjectTotalBudgetAmt.get(projectId) == null ? 0 : mapProjectTotalBudgetAmt.get(projectId) * currencyConversionRate;
                totalBillableRRAmt = mapProjectTotalBillableRRAmt.get(projectId) == null ? 0 : mapProjectTotalBillableRRAmt.get(projectId);
                totalMilestoneAmt = mapProjectTotalMilestoneAmt.get(projectId) == null ? 0 : mapProjectTotalMilestoneAmt.get(projectId) * currencyConversionRate;
                totalBillableRRAmt = totalBillableRRAmt + billableRRAmt;

                if(totalBudgetAmt.setScale(2,System.RoundingMode.CEILING) < totalMilestoneAmt.setScale(2,System.RoundingMode.DOWN) + totalBillableRRAmt){
                    projectIdSet.add(projectId);                   
                }
            }
            if(projectIdSet.size() > 0 || isTestRun){
                //Check if the current logged in user belongs to PS Ops
                Boolean isPSOpsUser = checkifPSOpsUser();
                if(isPSOpsUser || isTestRun){                   
                    if(newRRList.size() == 1){
                        newRRList[0].Show_Notification__c = true;
                    }
                }
                //Hard alert for Other PS Users
                else{
                    Trigger.new[0].addError(Label.RR_Budget_Exceeded_Msg);
                }
            }
        }    
    }
    /**
    * Method to check if the current login user has PS Ops PSG
    * @param 
    * @return Boolean
    * @throws exception - NA
    */
    public static Boolean checkifPSOpsUser(){
        Boolean isPSOpsUser = false;
        //<T11> - Included the PSA Rev Ops condition in the below select query
        List<Permissionsetassignment> psaPSAssignment = [SELECT Id FROM Permissionsetassignment WHERE AssigneeId = :UserInfo.getUserId() 
                                                         AND (PermissionSetGroup.MasterLabel = 'PSA Operations' OR PermissionSetGroup.MasterLabel = 'PSA Rev Ops') LIMIT 1];        
        if(psaPSAssignment.size() > 0){
            isPSOpsUser = true;
        }
        return isPSOpsUser;
    }
    //</T08>
    public void processAfterInsertActions(List<pse__Resource_Request__c> newRRList, Map<Id,pse__Resource_Request__c> newRRMap){
        system.debug('**RRTH-newRRList**________'+newRRList);
        system.debug('**RRTH-newRRMap**________'+newRRMap);
        Map<Id,pse__Resource_Request__c> assResReqMap = new Map<Id,pse__Resource_Request__c>();
        
        for(pse__Resource_Request__c resReq : newRRList){
            system.debug('**RRTH-newRRList Assignment**________'+resReq.pse__Assignment__c);
            /* <T05> */ 
            if(resReq.pse__Assignment__c <> null && (!String.isBlank(resReq.psa_rm_MSA_Code_Mapping__c) ||resReq.psa_rm_Assign_Held_Resource__c == true ||
                resReq.psa_rm_Billable__c == true || resReq.psa_rm_Time_Credited__c == true || (resReq.psa_rm_Billable__c == false && resReq.psa_rm_Time_Credited__c == false) || resReq.pse__Status__c == 'Assigned')){
                    assResReqMap.put(resReq.pse__Assignment__c,resReq);
                }
        }
        system.debug('**RRTH-assResReqMap**________'+assResReqMap);
        if(assResReqMap.size()>0){
            updateAssignementRecords(assResReqMap);
        }
        
    }
    
    public void processAfterUpdateActions(List<pse__Resource_Request__c> oldRRList,List<pse__Resource_Request__c> newRRList, Map<Id,pse__Resource_Request__c> oldRRMap, Map<Id,pse__Resource_Request__c> newRRMap){
        
        Map<Id,pse__Resource_Request__c> assResReqMap = new Map<Id,pse__Resource_Request__c>();
        Map<Id,pse__Resource_Request__c> assignmentUpdateMap = new Map<Id,pse__Resource_Request__c>();//<T07>
        
        // NEED TO CHECK IF WE NEED TO HANDLE ASSIGNEMENT RECORD UPDATES AND NULL CONDTIONS.
        for(pse__Resource_Request__c resReq : newRRList){
            pse__Resource_Request__c oldResReq =  oldRRMap.get(resReq.Id);
            if((resReq.pse__Assignment__c <> null && resReq.pse__Assignment__c <> oldResReq.pse__Assignment__c) &&
               ((resReq.psa_rm_Assign_Held_Resource__c <> oldResReq.psa_rm_Assign_Held_Resource__c) && resReq.psa_rm_Assign_Held_Resource__c == true) || 
               ((resReq.psa_rm_Billable__c <> oldResReq.psa_rm_Billable__c) && resReq.psa_rm_Billable__c == true) || 
               ((resReq.psa_rm_Time_Credited__c <> oldResReq.psa_rm_Time_Credited__c) && resReq.psa_rm_Time_Credited__c == true)|| 
               ((resReq.psa_rm_Billable__c <> oldResReq.psa_rm_Billable__c) && (resReq.psa_rm_Time_Credited__c <> oldResReq.psa_rm_Time_Credited__c) && 
               (resReq.psa_rm_Billable__c == false && resReq.psa_rm_Time_Credited__c == false)) || 
               ((resReq.pse__Status__c <> oldResReq.pse__Status__c) && resReq.pse__Status__c == 'Assigned')){
                   
                   assResReqMap.put(resReq.pse__Assignment__c,resReq);
            }
            if(!String.isBlank(resReq.psa_rm_MSA_Code_Mapping__c) && oldResReq.psa_rm_MSA_Code_Mapping__c!=resReq.psa_rm_MSA_Code_Mapping__c){
                assResReqMap.put(resReq.pse__Assignment__c,resReq);
            }
            //<T07>
            if(oldResReq.pse__Requested_Bill_Rate__c <> resReq.pse__Requested_Bill_Rate__c && resReq.pse__Requested_Bill_Rate__c != null){
                assignmentUpdateMap.put(resReq.pse__Assignment__c,resReq);
            }
            //</T07>
        }
        
        if(assResReqMap.size()>0){
            updateAssignementRecords(assResReqMap);
        }
        //<T07>
        if(assignmentUpdateMap.size() > 0){
            updateAssignementRecords(assignmentUpdateMap,'pse__Requested_Bill_Rate__c');
        }
        //</T07>
    }
    
    /************************************************************************************************************************************************* */
    
    public void populateAllocationPercentage(Set<Id> staffIdSet,List<pse__Resource_Request__c> rrReqsToProcess){
        
        system.debug('**RRTH-staffIdSet**________'+staffIdSet);
        system.debug('**RRTH-rrReqsToProcess**________'+rrReqsToProcess);
        List<pse__HolidayObj__c> holidayList= new List<pse__HolidayObj__c>();
        Set<Date> holidayDatesSet = new Set<Date>();
        List<Contact> baseConList = new List<Contact>([SELECT id,Name,pse__Work_Calendar__c,pse__Work_Calendar__r.name,pse__Work_Calendar__r.pse__Standard_Hours_Per_Day__c,
                                                       pse__Work_Calendar__r.pse__Friday_Hours__c,pse__Work_Calendar__r.pse__Monday_Hours__c,
                                                       pse__Work_Calendar__r.pse__Saturday_Hours__c,pse__Work_Calendar__r.pse__Sunday_Hours__c,
                                                       pse__Work_Calendar__r.pse__Thursday_Hours__c,pse__Work_Calendar__r.pse__Tuesday_Hours__c,
                                                       pse__Work_Calendar__r.pse__Wednesday_Hours__c
                                                       FROM Contact 
                                                       WHERE Id IN :staffIdSet]);
        
        system.debug('**RRTH-baseConList**________'+baseConList);
        Map<Id,pse__Work_Calendar__c> contWorkCalenderMap = new Map<Id,pse__Work_Calendar__c>();
        Set<Id> workCalIdSet =new Set<Id>();
        if(baseConList.size()>0){
            for(Contact conRec:baseConList){
                if(conRec.pse__Work_Calendar__c!=null){
                    contWorkCalenderMap.put(conRec.Id,conRec.pse__Work_Calendar__r);
                    workCalIdSet.add(conRec.pse__Work_Calendar__c);
                }
            }
        }
        system.debug('**RRTH-contWorkCalenderMap**________'+contWorkCalenderMap);
        system.debug('**RRTH-workCalIdSet**________'+workCalIdSet);
        
        Date minStartDate = rrReqsToProcess[0].pse__Start_Date__c;      
        Date maxEndDate = rrReqsToProcess[0].pse__End_Date__c;
        
        for(pse__Resource_Request__c rReq : rrReqsToProcess){
            if(minStartDate > rReq.pse__Start_Date__c){
                minStartDate = rReq.pse__Start_Date__c;
            }
            if(maxEndDate < rReq.pse__End_Date__c){
                maxEndDate = rReq.pse__End_Date__c;
            }
        }
        system.debug('**RRTH-minStartDate**________'+minStartDate);
        system.debug('**RRTH-maxEndDate**________'+maxEndDate);
        //Creating holiday dates set
        if(workCalIdSet.size()>0){
            holidayList = [SELECT id,pse__Date__c,pse__Work_Calendar__c  FROM pse__HolidayObj__c WHERE pse__Work_Calendar__c IN :workCalIdSet and pse__Date__c >= :minStartDate and pse__Date__c <= :maxEndDate];
        }
        system.debug('**RRTH-holidayList**________'+holidayList);
        
        if(holidayList.size()>0){
            for(pse__HolidayObj__c hol:holidayList){
                holidayDatesSet.add(hol.pse__Date__c);
            }
        }
        system.debug('**RRTH-holidayDatesSet**________'+holidayDatesSet);
        
        for(pse__Resource_Request__c resReqToDefault : rrReqsToProcess){
            if(resReqToDefault.pse__Staffer_Resource__c <> resReqToDefault.pse__Resource__c){
                resReqToDefault.pse__Resource__c = resReqToDefault.pse__Staffer_Resource__c;
            }
            pse__Work_Calendar__c workCal =contWorkCalenderMap.get(resReqToDefault.pse__Staffer_Resource__c);
            Decimal workingHours=calculateWorkingHoursBetweenTwoDates(resReqToDefault.pse__Start_Date__c,resReqToDefault.pse__End_Date__c, workCal,holidayDatesSet);
            Decimal allocationPercent;
            if(workingHours==0 && resReqToDefault.pse__SOW_Hours__c <> NULL){
                resReqToDefault.psa_rm_Allocation_Percentage__c = null;
            }else{
                allocationPercent= (resReqToDefault.pse__SOW_Hours__c/workingHours)*100 ;
                resReqToDefault.psa_rm_Allocation_Percentage__c=allocationPercent.setScale(2);
            }
            system.debug('**RRTH-resReqToDefault**________'+resReqToDefault);
        }
        
    }
    
    public static Decimal calculateWorkingHoursBetweenTwoDates(Date startDate,Date endDate,pse__Work_Calendar__c WorkCal,Set<Date> holidayDateSet){
        
        Integer allDaysBetween = startDate.daysBetween(endDate);
        Decimal allWorkingHours=0;
        Datetime dt;
        Date tempDate;
        
        if(WorkCal != null){ 
            //Processing all dates between start and end dates
            for(Integer k=0;k<=allDaysBetween ;k++ ){
                tempDate=startDate.addDays(k);
                if(checkifItisWorkingDay(tempDate,holidayDateSet)){                    
                    dt = datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
                    String dayOfWeek=dt.format('EEE');
                    
                    if(dayOfWeek == 'Sun'){
                        allWorkingHours+=WorkCal.pse__Sunday_Hours__c;
                    }
                    else if(dayOfWeek == 'Mon'){
                        allWorkingHours+=WorkCal.pse__Monday_Hours__c;
                    }
                    else if(dayOfWeek == 'Tue'){
                        allWorkingHours+=WorkCal.pse__Tuesday_Hours__c;
                    }
                    else if(dayOfWeek == 'Wed'){
                        allWorkingHours+=WorkCal.pse__Wednesday_Hours__c;
                    }
                    else if(dayOfWeek == 'Thu'){
                        allWorkingHours+=WorkCal.pse__Thursday_Hours__c;
                    }
                    else if(dayOfWeek == 'Fri'){
                        allWorkingHours+=WorkCal.pse__Friday_Hours__c;
                    }
                    else if(dayOfWeek == 'Sat'){
                        allWorkingHours+=WorkCal.pse__Saturday_Hours__c;
                    }
                }
            }
        }
        return allWorkingHours;
    }
    
    public static boolean checkifItisWorkingDay(Date myDate,Set<Date> holidayDateSet){       
        return !holidayDateSet.contains(myDate);
    }
    
    /**public List<pse__Resource_Request__c> getFullResReqList(List<pse__Resource_Request__c> baseList){

return [SELECT Id,Name,psa_rm_MSA_Code_Mapping__c,pse__Project__c,pse__Project__r.psa_pm_Primary_Project_Location__c, 
pse__Project__r.psa_pm_Primary_Project_Location__r.psa_pm_MSA_Code_Mapping__c 
FROM pse__Resource_Request__c 
WHERE Id IN :baseList];
}**/ /**<T01>**/
    
    /* public void populateMSAFields(Map<Id,Id> resReqMSAIdMap,List<pse__Resource_Request__c> rrReqsToProcess){

system.debug('**RRTH-rrReqsToProcess**________'+rrReqsToProcess);
Map<Id,PSA_MSA_Code_Mapping__c> msaCodeMap = new Map<Id,PSA_MSA_Code_Mapping__c>([SELECT Id,Name,psa_pm_MSA_Code__c,psa_pm_City_Name__c,psa_pm_MSA_Name__c,
psa_pm_State_Code__c,psa_pm_ZIP_Code__c,psa_pm_Work_Street__c,psa_pm_Work_Country__c
FROM PSA_MSA_Code_Mapping__c
WHERE Id IN:resReqMSAIdMap.values()]);
system.debug('**RRTH-msaCodeMap**________'+msaCodeMap);
if(msaCodeMap.size()>0){
for(pse__Resource_Request__c resReq : rrReqsToProcess){  
// NEED TO REFACTOR THE NEXT LINE. for project vs RR
if(resReq.psa_rm_MSA_Code_Mapping__c == null){
resReq.psa_rm_MSA_Code_Mapping__c = msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).Id;
}                         
resReq.psa_rm_MSA_Code__c = msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).psa_pm_MSA_Code__c;
resReq.pse__Work_City_PSA__c = msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).psa_pm_City_Name__c;
resReq.pse__Work_State_PSA__c = msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).psa_pm_State_Code__c;
resReq.pse__Work_PostalCode_PSA__c = msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).psa_pm_ZIP_Code__c;
resReq.pse__Work_Country_PSA__c =  msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).psa_pm_Work_Country__c;  
resReq.pse__Work_Street_PSA__c = msaCodeMap.get(resReqMSAIdMap.get(resReq.Id)).psa_pm_Work_Street__c; 
system.debug('**RRTH-resReq**________'+resReq);
}
}       
} */
    
    public void updateAssignementRecords(Map<Id,pse__Resource_Request__c> assRRMap){
        
        List<pse__Assignment__c> updateAssigntList = new List<pse__Assignment__c>();
        List<pse__Assignment__c> baseAssigntList = new List <pse__Assignment__c>([SELECT id,Name,PSA_MSA_Code_Mapping__c,pse__Resource_Request__c, pse__Is_Billable__c, pse__Time_Credited__c,PSA_RM_Assignment_Type__c
                                                                                  FROM  pse__Assignment__c 
                                                                                  WHERE Id IN:assRRMap.keyset()]);
        
        for(pse__Assignment__c assRec : baseAssigntList){
            
            pse__Resource_Request__c resReq = assRRMap.get(assRec.Id);
            if(resReq.psa_rm_Assign_Held_Resource__c){
                assRec.pse__Resource_Request__c = resReq.Id;
            }
            
            if(resReq.psa_rm_Billable__c){
                assRec.pse__Is_Billable__c = true;
                assRec.pse__Time_Credited__c = false;//<T02>
            }
            
            if(resReq.psa_rm_Time_Credited__c){
                assRec.pse__Time_Credited__c = true;
                assRec.pse__Is_Billable__c = false;//<T02>
            }
            
            if(!resReq.psa_rm_Billable__c && !resReq.psa_rm_Time_Credited__c){
                assRec.pse__Is_Billable__c = false;
                assRec.pse__Time_Credited__c = false;
            }
            if(resReq.pse__Status__c == 'Assigned'){
                assRec.PSA_RM_Assignment_Type__c = resReq.PSA_RM_Assignment_Type__c;
                //<T09>
                if(resReq.PSA_RM_Assignment_Type__c == 'Shadowing'){
                    assRec.pse__Cost_Rate_Amount__c = 0;
                    assRec.pse__Use_Resource_Default_Cost_Rate__c = false;
                }
                //</T09>
            }
            if(!String.isBlank(resReq.psa_rm_MSA_Code_Mapping__c)){ // <T05>
                assRec.PSA_MSA_Code_Mapping__c = resReq.psa_rm_MSA_Code_Mapping__c;
            }
            updateAssigntList.add(assRec);
        }
        
        if(updateAssigntList.size()>0){
            try{                
                update updateAssigntList;                
            }catch(Exception e){
                GAM.CreateLogs('CLASS: psa_rm_ResourceRequestTriggerHelper | METHOD: updateAssignementRecords', updateAssigntList , 'updateAssigntList');
            }
            GAM.InsertDebugLogs();
        }
    }

    //<T07>
    public void updateAssignementRecords(Map<Id,pse__Resource_Request__c> assRRMap, String fieldName){
        List<pse__Assignment__c> updateAssigntList = new List<pse__Assignment__c>();
        List<pse__Assignment__c> baseAssigntList = new List<pse__Assignment__c>([SELECT id,Name,pse__Bill_Rate__c,PSA_MSA_Code_Mapping__c,pse__Resource_Request__c, pse__Is_Billable__c, pse__Time_Credited__c,PSA_RM_Assignment_Type__c
                                                                                  FROM  pse__Assignment__c 
                                                                                  WHERE Id IN:assRRMap.keyset()]);

        for(pse__Assignment__c assRec : baseAssigntList){
            
            pse__Resource_Request__c resReq = assRRMap.get(assRec.Id);
            if(fieldName.contains('pse__Requested_Bill_Rate__c')){
                assRec.pse__Bill_Rate__c = resReq.pse__Requested_Bill_Rate__c;
            }
            updateAssigntList.add(assRec);
        }

        if(updateAssigntList.size()>0){
            try{                
                update updateAssigntList;                
            }catch(Exception e){
                GAM.CreateLogs('CLASS: psa_rm_ResourceRequestTriggerHelper | METHOD: updateAssignementRecords(RRMap,String) {Overloaded}', updateAssigntList , 'updateAssigntList');
            }
            GAM.InsertDebugLogs();
        }
    }
    //</T07>
    
    // <T04>
    public void populateMSAFieldsFromProjLoc(pse__Resource_Request__c resReq,pse__Project_Location__c projLocRec){
        
        if(!String.isBlank(projLocRec.psa_pm_MSA_Code_Mapping__c)){
            resReq.psa_rm_MSA_Code_Mapping__c = projLocRec.psa_pm_MSA_Code_Mapping__c;
            resReq.psa_rm_MSA_Code__c = projLocRec.psa_pm_MSA_Code_Mapping__r.psa_pm_MSA_Code__c;
        }
        resReq.pse__Work_Street_PSA__c = projLocRec.PSA_Work_Street__c;
        resReq.pse__Work_City_PSA__c =projLocRec.psa_PM_Work_City__c;
        resReq.psa_rm_Work_County__c =projLocRec.PSA_PM_Work_County__c;
        resReq.pse__Work_State_PSA__c =projLocRec.PSA_PM_Work_State__c;
        resReq.PSA_Work_Province__c = projLocRec.PSA_PM_Work_Province__c;
        resReq.pse__Work_Country_PSA__c =projLocRec.PSA_Work_Country__c;
        resReq.pse__Work_PostalCode_PSA__c = projLocRec.PSA_Work_Zip_Postal_Code__c;
        
    }
    
}