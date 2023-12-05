/*
@created by       : MAHESH GANTI
@created on       : 10/30/2020
@Purpose          : Trigger HELPER Class for TIMECARD Trigger.

Change History
******************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                             Jira No.       Tag
******************************************************************************************************************************
Vivek Warrier   25-Jan-2022     Neha Kumari         Stop creation of a timecard when it falls on 2 months   PSA-2164        T1  
*/
public class psa_tm_TimeCardTriggerHelper {
    
    static final String TOTAL_PROJECT_EXCEEDED_BUDGET_ERR_MSG_FORMAT = 'Timecard cannot be saved. The "{0}" Assignments total project budget has been exceeded by {1}.  Please reduce the timecard hours by this amount in order to save.';
    static final String ASSIGNMENT_HOURS_EXCEEDED_ERR_MSG_FORMAT = 'Timecard cannot be saved.  The "{0}" Assignment planned hours has been exceeded by {1} hours.  Please reduce the timecard hours by this amount in order to save.';
    static final String ASSIGNMENT_HOURS_EXCEEDED_BY_ANOTHER_ERR_MSG_FORMAT = 'Timecard cannot be saved.  The "{0}" Assignment planned hours has been exceeded by another {1} hours.  Please reduce the timecard hours by this amount in order to save.';

    /**
    * this method is invoked from Before insert trigger context to run custom validation before inserting a timecard rec.
    *
    * @param lstNew - list of new timecard
    * @return return-void
    * @throws exception - NA
    */
    public void runValidationsOnTCInsert(List<pse__Timecard_Header__c> newTCList){
        runGenericValidations(newTCList);
    }

    /**
    * this method is invoked from Before insert trigger context to populate fields on insert of a timecard record.
    *
    * @param lstNew - list of new timecard
    * @return return-void
    * @throws exception - NA
    */
    public void populateFieldsOnTimeCardInsert(List<pse__Timecard_Header__c> newTCList){
        populateCommonFields(newTCList);

        List<PSA_Approver_Info__c> lstApproverInfo = new List<PSA_Approver_Info__c>();
        for(pse__Timecard_Header__c tcRec : newTCList){
            PSA_Approver_Info__c approverInfo = new PSA_Approver_Info__c();
            lstApproverInfo.add(approverInfo);
        }
        insert lstApproverInfo;

        Integer i=0;
        for(pse__Timecard_Header__c tcRec : newTCList){
            tcRec.PSA_TM_Approver_Info__c = lstApproverInfo.get(i++).Id;
        }
    }

    /**
    * this method is invoked from Before Update trigger context to run validation on Update of Timecard record.
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public void runValidationsOnTCUpdate(List<pse__Timecard_Header__c> oldTCList,List<pse__Timecard_Header__c> newTCList, Map<Id,pse__Timecard_Header__c> oldTCMap, Map<Id,pse__Timecard_Header__c> newTCMap){
        List<pse__Timecard_Header__c> tcFilteredList = new List<pse__Timecard_Header__c>();
        for(pse__Timecard_Header__c tc : newTCList){
            if(tc.pse__Approved__c == false && tc.pse__Status__c != 'Approved'){
                tcFilteredList.add(tc);
            }
        }
        runGenericValidations(tcFilteredList);
    }

    /**
    * this method is invoked from Before Update trigger context to populate fields on Update of Timecard record.
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public void populateFieldsOnTimeCardUpdate(List<pse__Timecard_Header__c> oldTCList,List<pse__Timecard_Header__c> newTCList, Map<Id,pse__Timecard_Header__c> oldTCMap, Map<Id,pse__Timecard_Header__c> newTCMap){
        
        populateCommonFields(newTCList);

        User userRec = getLoggedInUser();
        for(pse__Timecard_Header__c newTCRec : newTCList){
            for(pse__Timecard_Header__c oldTCRec : oldTCList){
                if((oldTCRec.Id == newTCRec.Id) && (oldTCRec.pse__Status__c <> newTCRec.pse__Status__c) && (newTCRec.pse__Status__c == 'Submitted')){
                    if(userRec.ManagerId <> null){
                        newTCRec.psa_tm_Submitted_User_Manager__c = userRec.ManagerId;
                    }                 
                }
            }
        }
    }

    /**
    * this method is invoked from After  Insert trigger context to Process logic post insert
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public void handleAfterTCInsertLogic(List<pse__Timecard_Header__c> newTCList, Map<Id,pse__Timecard_Header__c> newTCMap){
        Set<Id> projIdSet = new Set<Id>();
        List<pse__Timecard_Header__c> tcRecsToProcess = new List<pse__Timecard_Header__c>();

        for(pse__Timecard_Header__c tcRec : newTCList){
            if(tcRec.pse__Project__c <> null){
                projIdSet.add(tcRec.pse__Project__c);
                tcRecsToProcess.add(tcRec);
            }
        }

        if(projIdSet.size()>0){
           handleFieldUpdatesFromTimeCardTrigger(projIdSet,tcRecsToProcess,true);
        }
    }

    /**
    * this method is invoked from After  Update  trigger context to Process logic post update
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public void handleAfterTCUpdateLogic(List<pse__Timecard_Header__c> oldTCList,List<pse__Timecard_Header__c> newTCList, Map<Id,pse__Timecard_Header__c> oldTCMap, Map<Id,pse__Timecard_Header__c> newTCMap){

        Set<Id> projIdSet = new Set<Id>();
        List<pse__Timecard_Header__c> tcRecsToProcess = new List<pse__Timecard_Header__c>();

        Set<Id> setApprovedTimecardId = new Set<Id>();

        for(pse__Timecard_Header__c newTCRec : newTCList){
            pse__Timecard_Header__c oldTCRec = oldTCMap.get(newTCRec.Id);
            if(((oldTCRec.pse__Sunday_Hours__c <> newTCRec.pse__Sunday_Hours__c)
            || (oldTCRec.pse__Monday_Hours__c <> newTCRec.pse__Monday_Hours__c)
            || (oldTCRec.pse__Tuesday_Hours__c <> newTCRec.pse__Tuesday_Hours__c)
            || (oldTCRec.pse__Wednesday_Hours__c <> newTCRec.pse__Wednesday_Hours__c)
            || (oldTCRec.pse__Thursday_Hours__c <> newTCRec.pse__Thursday_Hours__c)
            || (oldTCRec.pse__Friday_Hours__c <> newTCRec.pse__Friday_Hours__c)
            || (oldTCRec.pse__Saturday_Hours__c <> newTCRec.pse__Saturday_Hours__c)
            || (oldTCRec.pse__Status__c <> newTCRec.pse__Status__c))
            && (newTCRec.pse__Project__c <> null)){
                projIdSet.add(newTCRec.pse__Project__c);
                tcRecsToProcess.add(newTCRec);
            }

            if(newTCRec.pse__Approved__c && !oldTCRec.pse__Approved__c){
                System.debug('the timecard ' + newTCRec.Name + ' is approved');
                setApprovedTimecardId.add(newTCRec.Id);
            }
        }

        Map<Id, String> mapTimecardIdToOrigActorName = new Map<Id, String>();
        if(!setApprovedTimecardId.isEmpty()){
            System.debug('getting the approval information for the timecards ' + setApprovedTimecardId);
            List<ProcessInstance> lstProcessInstance = [Select Id, Status, TargetObjectId, 
                                                          (Select IsPending, StepStatus, OriginalActorId, OriginalActor.Name, ActorId From StepsAndWorkitems) 
                                                        From ProcessInstance 
                                                        Where TargetObjectId in :setApprovedTimecardId Order By LastModifiedDate Desc];
            for(ProcessInstance processInstance : lstProcessInstance){
                System.debug('processInstance id ' + processInstance.Id + ' for timecard id ' + processInstance.TargetObjectId);
                if(!mapTimecardIdToOrigActorName.containsKey(processInstance.TargetObjectId)){
                    System.debug('processing processInstance id ' + processInstance.Id);
                    String origActorName;
                    for(ProcessInstanceHistory piHistory : processInstance.StepsAndWorkitems){
                        System.debug('piHistory status = ' + piHistory.StepStatus);
                        System.debug('piHistory isPending = ' + piHistory.isPending);
                        if('Approved'.equals(piHistory.StepStatus)){
                            origActorName = piHistory.OriginalActor.Name;
                            break;
                        }else if(piHistory.isPending){
                            origActorName = piHistory.OriginalActor.Name;
                        }
                        System.debug('origActorName = ' + origActorName);
                    }
                    if(!String.isEmpty(origActorName)){
                        mapTimecardIdToOrigActorName.put(processInstance.TargetObjectId, origActorName);
                    }
                }
            }
        }

        List<PSA_Approver_Info__c> lstApproverInfo = new List<PSA_Approver_Info__c>();
        for(pse__Timecard_Header__c newTCRec : newTCList){
            if(setApprovedTimecardId.contains(newTCRec.Id) && newTCRec.PSA_TM_Approver_Info__c != null){
                PSA_Approver_Info__c approverInfo = new PSA_Approver_Info__c();
                approverInfo.Id = newTCRec.PSA_TM_Approver_Info__c;
                approverInfo.Original_Approver_Name__c = mapTimecardIdToOrigActorName.get(newTCRec.Id);
                approverInfo.Actual_Approver__c = UserInfo.getUserId();
                lstApproverInfo.add(approverInfo);
            }
        }

        if(!lstApproverInfo.isEmpty()){
            update lstApproverInfo;
        }

        if(projIdSet.size()>0){
            handleFieldUpdatesFromTimeCardTrigger(projIdSet,tcRecsToProcess,false);
        }
    }

    /**
    * this method is invoked from After Delete trigger context to Process delete post update
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public void handleAfterTCDeleteLogic(List<pse__Timecard_Header__c> tcDelList){

        Set<Id> projIdSet = new Set<Id>();
        List<pse__Timecard_Header__c> tcRecsToProcess = new List<pse__Timecard_Header__c>();

        for(pse__Timecard_Header__c tcRec : tcDelList){
            if(tcRec.pse__Project__c <> null){
                projIdSet.add(tcRec.pse__Project__c);
                tcRecsToProcess.add(tcRec);
            }
        }

        if(projIdSet.size()>0){
            handleFieldUpdatesFromTimeCardTrigger(projIdSet,tcRecsToProcess,false);
        }
    }

    /**
    * Method to populate common field during insert or update operation from trigger context.
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public static void populateCommonFields(List<pse__Timecard_Header__c> tcList){
            
        Set<Id> conSet = new Set<Id>();
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        Set<Id> projSet = new Set<Id>();
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>();
        for(pse__Timecard_Header__c tcRec : tcList){
            if(tcRec.pse__Resource__c <> null){
                conSet.add(tcRec.pse__Resource__c);
            }
            if(tcRec.pse__Project__c <> null){
                projSet.add(tcRec.pse__Project__c);
            }
        }  
        if(conSet.size()>0){
            conMap = getcontactMap(conSet);
        }
        if(projSet.size()>0){
            projMap = getProjectMap(projSet);
        }

        for(pse__Timecard_Header__c tcRec : tcList){
           
            if(tcRec.pse__Resource__c <> null && conMap.size()>0 && conMap.containsKey(tcRec.pse__Resource__c)){
                tcRec.psa_pm_Resource_Manager__c = conMap.get(tcRec.pse__Resource__c).pse__Salesforce_User__c <> null ? conMap.get(tcRec.pse__Resource__c).pse__Salesforce_User__r.ManagerId : null;
            }
            
            if(tcRec.pse__Project__c <> null && projMap.size()>0 && projMap.containsKey(tcRec.pse__Project__c)){
                tcRec.psa_pm_Project_Portfolio_Manager__c = projMap.get(tcRec.pse__Project__c).psa_pm_Portfolio_Manager__c <> null ? projMap.get(tcRec.pse__Project__c).psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c : null;
            }
        }   
            
    }
    /**
    * Method to update field on Project from Timecard Trigger context.
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public static void handleFieldUpdatesFromTimeCardTrigger(Set<Id> projIds,List<pse__Timecard_Header__c> timeCardList,Boolean isInsert){
        
        List<pse__Proj__c> projRecsToUpdate = new List<pse__Proj__c>();
        Map<Id, pse__Proj__c> projBaseMap = new Map<Id, pse__Proj__c>([SELECT Id,Name,psa_tm_First_Time_Entry_Date__c,psa_tm_Last_Created_Timesheet__c,psa_tm_Last_Time_Entry_Date__c
                                                                        FROM pse__Proj__c
                                                                        WHERE Id IN: projIds]);

        Map<Id, AggregateResult> mapProjAggResults = new Map<Id, AggregateResult>();
        for(AggregateResult ar : [SELECT  pse__Project__c,MIN(psa_tm_Actual_Start_Date__c) MINDATE,
                                    MAX(psa_tm_Actual_End_Date__c) MAXDATE
                                    FROM pse__Timecard_Header__c
                                    WHERE pse__Project__c IN :projIds 
                                    GROUP BY pse__Project__c]) {
            mapProjAggResults.put((Id)ar.get('pse__Project__c'), ar);
        }

        for(Id projId : projIds){
            pse__Proj__c projRec = projBaseMap.get(projId);
            AggregateResult projARResult = mapProjAggResults.get(projId);
            if(projRec <> null && projARResult <> null){
                projRec.psa_tm_First_Time_Entry_Date__c = (Date)projARResult.get('MINDATE');
                projRec.psa_tm_Last_Time_Entry_Date__c = (Date)projARResult.get('MAXDATE');
                projRecsToUpdate.add(projRec);
            }
            // need to check if need to populate last time sheet created date.
        }

        if(projRecsToUpdate.size()>0){
            update projRecsToUpdate;
        }
        
    }
    
    
    /**************************************************  TIMECARD VALIDATION CALCULATION METHODS - START  ********************************************/
    /**
    * Method to run  common validation  during insert or update operation from trigger context.
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public static void runGenericValidations(List<pse__Timecard_Header__c> newTCList){

        //<T1>        
        for(pse__Timecard_Header__c tcHeader : newTCList){
            
            Integer currentMonth = 0;
            Map<String,Double> temporalMap = new Map<String,Double>{'Sunday' => tcHeader.pse__Sunday_Hours__c, 'Monday' => tcHeader.pse__Monday_Hours__c,'Tuesday' => tcHeader.pse__Tuesday_Hours__c,'Wednesday' => tcHeader.pse__Wednesday_Hours__c,'Thursday' => tcHeader.pse__Thursday_Hours__c,'Friday' => tcHeader.pse__Friday_Hours__c,'Saturday' => tcHeader.pse__Saturday_Hours__c};
            Map<String,Integer> monthMap = new Map<String,Integer>{'Sunday' => tcHeader.pse__Start_Date__c.month(),'Monday' => tcHeader.pse__Start_Date__c.addDays(1).month(),'Tuesday' => tcHeader.pse__Start_Date__c.addDays(2).month(),'Wednesday' => tcHeader.pse__Start_Date__c.addDays(3).month(),'Thursday' => tcHeader.pse__Start_Date__c.addDays(4).month(),'Friday' => tcHeader.pse__Start_Date__c.addDays(5).month(),'Saturday' => tcHeader.pse__Start_Date__c.addDays(6).month()};

            for(String str : temporalMap.keySet()){
                if(temporalMap.get(str) <= 0){
                    continue;
                }
                else{
                    if(currentMonth == 0){
                        currentMonth = monthMap.get(str);
                    }
                    else if(currentMonth == monthMap.get(str)){
                        continue;
                    }
                    else{
                        tcHeader.addError('When the week belongs to two different months, the Timecard cannot be filed. Please try entering the hours for each month on separate lines.');
                    }
                }
            }
        }
        //</T1>
        
        Set<Id> projIdSet = new Set<Id>();
        Set<Id> assignIdSet = new Set<Id>();
        Set<Id> timeCardToProcessSet = new Set<Id>();
        Map<Id,pse__Proj__c> projIdMap = new Map<Id,pse__Proj__c>();

        //First loop to get the Project Id's
        for(pse__Timecard_Header__c tcRec : newTCList){
            if(tcRec.pse__Project__c <> null){
                projIdSet.add(tcRec.pse__Project__c);
            }
        }
        if(projIdSet.size()>0){
            projIdMap = getProjectMap(projIdSet);
        }
        
        //Second loop to get AssignementId and TimeCardRecId to be processed.
        for(pse__Timecard_Header__c tcRec : newTCList){
            if(tcRec.pse__Project__c <> null){
                pse__Proj__c projRec = projIdMap.get(tcRec.pse__Project__c);
                if((projRec <> null) && (projRec.psa_pm_Disable_Timecard_Hours_Cap__c == false) && (projRec.pse__Project_Type__c <> 'Internal') && (tcRec.pse__Assignment__c <> null)){
                    assignIdSet.add(tcRec.pse__Assignment__c);
                    timeCardToProcessSet.add(tcRec.Id);
                }

            }
        }

        //Get the AssignmentWrapper
        if(assignIdSet.size()>0 && timeCardToProcessSet.size()>0){
            AssignmentTCWrapper assignWrap = loadPlannedHours(assignIdSet,timeCardToProcessSet);
            Map<Id,Decimal> assignmentPlannedHours = assignWrap.assignmentPlannedHours;
            Map<Id,Decimal> assignmentBillRates = assignWrap.assignmentBillRates;
            Map<Id,Decimal> totalAssignedTCHours = assignWrap.totalAssignedTCHours;
            Map<Id,String> assignmentNames = assignWrap.assignmentNames;
            Set<Id> errorTCIdSet = new Set<Id>();

            //Loop 3 - To actually filter out the TimeCard Recs with Errors.
            for(pse__Timecard_Header__c tcRec : newTCList){
                if (tcRec.pse__Project__c <> null && tcRec.pse__Assignment__c <> null && timeCardToProcessSet.contains(tcRec.id) && assignIdSet.contains(tcRec.pse__Assignment__c)){
                    pse__Proj__c projRec = projIdMap.get(tcRec.pse__Project__c);
                    if(projRec <> null ){
                        //GET ASSIGNMENT NAME
                        String assignmentName = assignmentNames.get(tcRec.pse__Assignment__c);
                        assignmentName = assignmentName != null ? assignmentName : '';

                        // Project field checks
                        if ((projRec.pse__Stage__c  <> null || projRec.pse__Stage__c  <> '') && projRec.pse__Stage__c <> 'Proposed' && projRec.pse__Is_Billable__c == true){
                            Decimal assignmentRate = assignmentBillRates.get(tcRec.pse__Assignment__c) != null ? assignmentBillRates.get(tcRec.pse__Assignment__c) : 0.0;
                           system.debug('AssignmentRate'+assignmentRate);
                            Decimal tcBillableAmt = calculateTimecardBillableAmount(tcRec,assignmentRate);
                            system.debug('tcBillableAmt'+tcBillableAmt);
                            Decimal remainingProjAmount = projRec != null ? projRec.psa_pm_Remaining_Bookings__c : 0.0;
                            system.debug('remainingProjAmount'+remainingProjAmount);
                            
                            Decimal totalAmount = 0.0;
                            if(projRec.pse__Bookings__c <> null){
                                totalAmount += projRec.pse__Bookings__c;
                            }
                            if(projRec.pse__Internal_Budget__c <> null){
                                totalAmount += projRec.pse__Internal_Budget__c;
                            }
                            if(projRec.pse__Billings__c <> null){
                                totalAmount -= projRec.pse__Billings__c;
                            }
                            system.debug('totalAmount'+totalAmount);
                            if (totalAmount <> null && tcBillableAmt <> null && (totalAmount < tcBillableAmt) && (assignmentRate > 0)) {
                                
                                Decimal exceededByHours = (tcBillableAmt - remainingProjAmount) / assignmentRate;
                                system.debug('exceededByHours'+exceededByHours);
                                String errMessage =  String.format(TOTAL_PROJECT_EXCEEDED_BUDGET_ERR_MSG_FORMAT, new String[]{assignmentName, String.valueOf(exceededByHours)});
                                tcRec.addError(errMessage);
                            }
                        }

                        Decimal assignPlannedHours = assignmentPlannedHours.get(tcRec.pse__Assignment__c) != null ? assignmentPlannedHours.get(tcRec.pse__Assignment__c) : 0.0;
                        system.debug('assignPlannedHours'+assignPlannedHours);
                        Decimal tcCurrentHours = tcRec.pse__Total_Hours__c;
                        system.debug('tcCurrentHours'+tcCurrentHours);
                        Decimal totalTCHoursToDate = totalAssignedTCHours.get(tcRec.pse__Assignment__c) != null ? totalAssignedTCHours.get(tcRec.pse__Assignment__c) : 0.0;
                        system.debug('totalTCHoursToDate'+totalTCHoursToDate);
                        
                        totalAssignedTCHours.put(tcRec.pse__Assignment__c, (totalTCHoursToDate + tcCurrentHours));
                        
                        if ((totalTCHoursToDate > assignPlannedHours) || ((totalTCHoursToDate + tcCurrentHours) > assignPlannedHours)){
                            Decimal exceeded = (totalTCHoursToDate + tcCurrentHours) - assignPlannedHours;
                            system.debug('exceeded'+exceeded);
                            String errMessage =  String.format(ASSIGNMENT_HOURS_EXCEEDED_ERR_MSG_FORMAT, new String[]{assignmentName, String.valueOf(exceeded)});

                            // when already exceeded just show the hours and a different message.
                            if (errorTCIdSet.contains(tcRec.pse__Assignment__c)){
                                exceeded = tcCurrentHours;
                                errMessage =  String.format(ASSIGNMENT_HOURS_EXCEEDED_BY_ANOTHER_ERR_MSG_FORMAT, new String[]{assignmentName, String.valueOf(exceeded)});
                            }
                            tcRec.addError(errMessage);
                            errorTCIdSet.add(tcRec.pse__assignment__c);
                        }
                    }
                }                  
            }
        }

    }

    public static Decimal calculateTimecardBillableAmount(pse__Timecard_Header__c tch, Decimal assignmentRate){
        Decimal returnVal = 0.0;

        if (tch != null && assignmentRate != null && tch.pse__Billable__c == true){
            if (tch.pse__Daily_Bill_Rate__c == true){
                returnVal = (tch.pse__Total_Days_Worked__c * assignmentRate);
            }
            else{
                Decimal totalHours = tch.pse__Total_Hours__c !=null ? tch.pse__Total_Hours__c : 0;
                returnVal = (totalHours * assignmentRate);
            }
        }
        return returnVal;
    }

    public static AssignmentTcWrapper loadPlannedHours(Set<Id> assignIds, Set<Id> timeCardIds){
        
        AssignmentTCWrapper  assignWrapper = new AssignmentTCWrapper();
 
        for (pse__Assignment__c assignment : [SELECT Id,Name,pse__planned_hours__c,pse__Bill_rate__c FROM pse__Assignment__c where Id IN :assignIds]){
            
            assignWrapper.assignmentPlannedHours.put(assignment.Id,assignment.pse__planned_hours__c);
            assignWrapper.assignmentBillRates.put(assignment.Id,assignment.pse__Bill_rate__c);
            assignWrapper.assignmentNames.put(assignment.Id,assignment.Name);
        }
        // load timecard data for this assignment
        for(pse__Timecard_Header__c tch : [SELECT Id,Name, pse__Total_Hours__c, pse__assignment__c,pse__status__c
                                            FROM pse__timecard_header__c 
                                            WHERE pse__assignment__c IN :assignIds AND Id NOT IN :timeCardIds AND 
                                            (pse__status__c = 'Saved' OR pse__status__c = 'Approved' OR pse__status__c = 'Submitted')]){
            
            Decimal tcaHrs = assignWrapper.totalAssignedTCHours.get(tch.pse__assignment__c) != null ? assignWrapper.totalAssignedTCHours.get(tch.pse__assignment__c) : 0.0;
            tcaHrs += (tch.pse__Total_Hours__c != null ? tch.pse__Total_Hours__c : 0.0);

            assignWrapper.totalAssignedTCHours.put(tch.pse__assignment__c,tcaHrs);
        }

        return assignWrapper;
    }

    public class AssignmentTCWrapper {
        Map<Id,Decimal> assignmentPlannedHours {get; set;}
        Map<Id,Decimal> assignmentBillRates {get; set;}
        Map<Id,Decimal> totalAssignedTCHours {get; set;}
        Map<Id,String> assignmentNames {get; set;}
        
        public AssignmentTCWrapper() {
            this.assignmentPlannedHours = new Map<Id,Decimal>();
            this.assignmentBillRates = new Map<Id,Decimal>();
            this.totalAssignedTCHours = new Map<Id,Decimal>();
            this.assignmentNames = new Map<Id,String>();
        }
    }

    /**************************************************  TIMECARD VALIDATION CALCULATION METHODS - END  ********************************************/


    /**************************************************  GENERIC  METHODS FOR THE MAIN METHOD - START  ********************************************/
    
    public static Map<Id,Contact> getcontactMap(Set<Id> conIdset){
        Map<Id,Contact> contactIdMap = new  Map<Id,Contact>();
        for(Contact conRec : [SELECT Id,Name,pse__Salesforce_User__c,pse__Salesforce_User__r.ManagerId FROM Contact WHERE Id IN:conIdset]){
            contactIdMap.put(conRec.Id,conRec);
        }
        return contactIdMap;
    }

    public static User getLoggedInUser(){
        return [SELECT Id,Name,ManagerId FROM User WHERE Id=:UserInfo.getUserId()];
    }

    public static Map<Id,pse__Proj__c> getProjectMap(Set<Id> projIdSet){
        
        Map<Id, pse__Proj__c> projMap = new Map<Id, pse__Proj__c>();       
        for (pse__proj__c proj : [SELECT Id,Name,psa_pm_Remaining_Bookings__c,psa_pm_Disable_Timecard_Hours_Cap__c,pse__Stage__c,pse__Project_Type__c,pse__Is_Billable__c,
                                    pse__Region__c,pse__Practice__c,pse__Group__c,pse__Bookings__c,pse__Internal_Budget__c,pse__Billings__c,
                                    psa_pm_Portfolio_Manager__c,psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c
                                    FROM pse__proj__c
                                    WHERE Id IN :projIdSet]){
            projMap.put(proj.Id,proj);
        }
        return projMap;
    }

     /**************************************************  GENERIC  METHODS FOR THE MAIN METHOD - STOP  ********************************************/
}