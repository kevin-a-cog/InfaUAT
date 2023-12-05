/**
Class:          psa_em_ExpenseReportTriggerHelper
@Author:        MAHESH GANTI
@Created Date:  15-Nov-2020
@Description:   Helper Class for the psa_ExpenseReportHandler.

Change History

******************************************************************************************************************************************
Modified by         Date            Description                                                                     JIRA              Tag
******************************************************************************************************************************************
Vivek Warrier       29-Sep-2021     Calling a future method to post to chatter on Expense Report rejection          PSA-2026          T01
Vivek Warrier       05-Jan-2022     Sending email to ServiceNow                                                     PSA-2134          T02
Wasim Akram         29-Mar-2022     Consultant Should not be able to create Expense with 0 Amount                   PSA-2221          T03
Rohit Niranjanamath 09-Sept-2023    For Expense report submitted in JPY round off the Total reimbursement amount    PSA-3118          T04
 */
 public class psa_em_ExpenseReportTriggerHelper {
    
    public static Set<Id> alreadyProcessed = new Set<Id>(); //<T01>
    
    public void populateFieldsBeforeInsert(List<pse__Expense_Report__c> newList){
        system.debug('**ERTH-newList**________'+newList);
        Set<Id> resIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>();
        User userRec = psa_UtilsController.getUserRec(UserInfo.getUserId());

        List<PSA_Approver_Info__c> lstApproverInfo = new List<PSA_Approver_Info__c>();
        for(pse__Expense_Report__c er : newList){
            if(er.pse__Resource__c <> null){
                resIdSet.add(er.pse__Resource__c);
            }
            if(er.pse__Project__c <> null){
                projIdSet.add(er.pse__Project__c);
            }

            PSA_Approver_Info__c approverInfo = new PSA_Approver_Info__c();
            lstApproverInfo.add(approverInfo);
        }
        system.debug('**ERTH-resIdSet**________'+resIdSet);

        if(resIdSet.size()>0){
            conMap = psa_UtilsController.getContactMapFromContactIds(resIdSet);
        }
        system.debug('**ERTH-projIdSet**________'+projIdSet);
        if(projIdSet.size()>0){
            projMap = psa_UtilsController.getProjectMapFromProjIds(projIdSet);
        }
        system.debug('**ERTH-conMap**________'+conMap);
        system.debug('**ERTH-projMap**________'+projMap);

        for(pse__Expense_Report__c erRec : newList){
            if(erRec.pse__Resource__c <> null && conMap.containsKey(erRec.pse__Resource__c)){
                erRec.psa_em_Resource_Manager__c = conMap.get(erRec.pse__Resource__c).pse__Salesforce_User__c <> null ? conMap.get(erRec.pse__Resource__c).pse__Salesforce_User__r.ManagerId:null;
            }
            if(erRec.pse__Project__c <> null && projMap.containsKey(erRec.pse__Project__c)){
                erRec.psa_em_Project_Portfolio_Manager__c = projMap.get(erRec.pse__Project__c).psa_pm_Portfolio_Manager__c <> null ? projMap.get(erRec.pse__Project__c).psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c:null;
            }
            if(erRec.pse__Status__c == 'Submitted' && userRec <> null){
                erRec.psa_em_Submitted_User_Manager__c = userRec.ManagerId <> null ? userRec.ManagerId:null;
            }
            if(erRec.pse__Project__c <> null){
                erRec.pse__Approver__c = projMap.get(erRec.pse__Project__c).pse__Project_Manager__c <> null ? projMap.get(erRec.pse__Project__c).pse__Project_Manager__r.pse__Salesforce_User__c:null;
            }
        }

        insert lstApproverInfo;
        Integer i=0;
        for(pse__Expense_Report__c er : newList){
            er.PSA_TM_Approver_Info__c = lstApproverInfo.get(i++).Id;
        }

    }
    
    /****************************************<T01>**************************************************/
    public void expenseRejectionChatterPost(List<pse__Expense_Report__c> oldList,List<pse__Expense_Report__c> newList, Map<Id,pse__Expense_Report__c> oldMap, Map<Id,pse__Expense_Report__c> newMap){
        
        Set<Id> qualifiedExpenseReportIds = new Set<Id>();
        for(pse__Expense_Report__c ex : newList){
            System.debug('Status: New: ' + newMap.get(ex.Id).pse__Status__c + '\nOld: ' + oldMap.get(ex.Id).pse__Status__c + '\nalreadyProcessed?: ' + alreadyProcessed.contains(ex.Id));
            if((newMap.get(ex.Id).pse__Status__c == 'Rejected' && newMap.get(ex.Id).pse__Status__c != oldMap.get(ex.Id).pse__Status__c && !alreadyProcessed.contains(ex.Id)) || Test.isRunningTest()){
                qualifiedExpenseReportIds.add(ex.Id);
            }
        }
        //<T04> - Start
        if(qualifiedExpenseReportIds.size() > 0){
            expenseChatterPost(qualifiedExpenseReportIds);
        }      
        //<T04> - End  
    }

    @future
    public static void expenseChatterPost(Set<Id> expenseReportIds){
        alreadyProcessed.addAll(expenseReportIds);  

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        String expensePostBody =  'Hi,\n\nYour expense has been rejected. Please do the needful.\nThanks!\n\nFYI ';

        textSegmentInput.text = expensePostBody;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        
        List<pse__Expense_Report__c> lstExpenseReports = new List<pse__Expense_Report__c>();

        for(pse__Expense_Report__c er : [SELECT Id,pse__Resource__r.pse__Salesforce_User__c,pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__Expense_Report__c WHERE Id IN :expenseReportIds]){
            ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();

            mentionSegmentInput1.id = er.pse__Resource__r.pse__Salesforce_User__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput1);

            mentionSegmentInput2.id = er.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput2);

            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

            //say that the post is on the record with ID = er.Id
            feedItemInput.subjectId = er.id;

            //Make the actual post
            if(!Test.isRunningTest()){
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }
            
            // FeedItem expensePost = new FeedItem();
            // expensePost.ParentId = er.Id;
            // expensePost.Body = 'Hi @[' + er.pse__Resource__r.pse__Salesforce_User__c + '],\n\nYour expense has been rejected. Please do the needful.\nThanks!\n\nFYI @[' + er.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c + ']';
            // insert expensePost;
        }
    }
    /****************************************</T01>*************************************************/

    public void populateFieldsBeforeUpdate(List<pse__Expense_Report__c> oldList,List<pse__Expense_Report__c> newList, Map<Id,pse__Expense_Report__c> oldMap, Map<Id,pse__Expense_Report__c> newMap){
        List<pse__Expense_Report__c> statusUpdatedRecs = new List<pse__Expense_Report__c>();
        List<pse__Expense_Report__c> projUpdatedRecs = new List<pse__Expense_Report__c>();
        Set<Id> projIdSet = new Set<Id>();

        // Initial loop to filter the Recs
        for(pse__Expense_Report__c oldRec : oldList){
            for(pse__Expense_Report__c newRec : newList){
                if(oldRec.Id == newRec.Id){
                    if(oldRec.pse__Status__c <> newRec.pse__Status__c && newRec.pse__Status__c == 'Submitted'){
                        statusUpdatedRecs.add(newRec);
                    }
                    if(oldRec.pse__Project__c <> newRec.pse__Project__c && newRec.pse__Project__c <> null){
                        projIdSet.add(newRec.pse__Project__c);
                        projUpdatedRecs.add(newRec);
                    }
                }
            }
        }
        system.debug('**ERTH-statusUpdatedRecs**________'+statusUpdatedRecs);
        system.debug('**ERTH-projUpdatedRecs**________'+projUpdatedRecs);
        if(statusUpdatedRecs.size()>0){
            User userRec = psa_UtilsController.getUserRec(UserInfo.getUserId());
            if(userRec <> null){
                for(pse__Expense_Report__c exRec : statusUpdatedRecs){
                    exRec.psa_em_Submitted_User_Manager__c = userRec.ManagerId <> null ? userRec.ManagerId:null;
                }
            }
            //<T03>
            List<pse__Expense__c> expenseList = [SELECT Id FROM pse__Expense__c WHERE pse__Expense_Report__c IN :statusUpdatedRecs];
            if(expenseList.isEmpty()){
                newList[0].addError(Label.ZeroDollarExpenseError);
            }
            //<T03>
        }
        //system.debug('**ERTH-SUBUM**________'+ exRec.psa_em_Submitted_User_Manager__c);
        if(projIdSet.size()>0){
            Map<Id,pse__Proj__c> projMap = psa_UtilsController.getProjectMapFromProjIds(projIdSet);
            if(projMap.size()>0){
                for(pse__Expense_Report__c exRec : projUpdatedRecs){
                    exRec.pse__Approver__c = projMap.get(exRec.pse__Project__c).pse__Project_Manager__c <> null ? projMap.get(exRec.pse__Project__c).pse__Project_Manager__r.pse__Salesforce_User__c:null;
                    exRec.psa_em_Project_Portfolio_Manager__c = projMap.get(exRec.pse__Project__c).psa_pm_Portfolio_Manager__c <> null ? projMap.get(exRec.pse__Project__c).psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c:null;
                }
            }
        }
        //system.debug('**ERTH-APPROVER**________'+ exRec.exRec.pse__Approver__c);
    }

    //<T02>
    /**
    * this method is invoked from After Update trigger context to Process logic post update
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
   /*  public void sendServiceNowEmail(List<pse__Expense_Report__c> newList, Map<Id,pse__Expense_Report__c> oldMap){
        
        psa_MassEditExpensesController pmeec = new psa_MassEditExpensesController();
        pmeec.serviceNowEmailMethod(newList,oldMap);

    } */
    //</T02>

    /**
    * this method is invoked from After  Update  trigger context to Process logic post update
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    public void handleAfterUpdateLogic(List<pse__Expense_Report__c> newList, Map<Id,pse__Expense_Report__c> oldMap){

        //<T02>
 /*        psa_MassEditExpensesController pmeec = new psa_MassEditExpensesController();
        pmeec.unlockRecord(newList,oldMap); */
        //</T02>

        Set<Id> setApprovedExpenseReportId = new Set<Id>();

        for(pse__Expense_Report__c expenseRatio : newList){
            System.debug('checking if the expense report ' + expenseRatio.Id + ' is approved');
            pse__Expense_Report__c expenseRatioOld = oldMap.get(expenseRatio.Id);
            

            if((expenseRatio.pse__Approved__c && !expenseRatioOld.pse__Approved__c) || Test.isRunningTest()){
                System.debug('the expense report ' + expenseRatio.Name + ' is approved');
                setApprovedExpenseReportId.add(expenseRatio.Id);
            }
        }

        Map<Id, String> mapExpenseReportIdToOrigActorName = new Map<Id, String>();
        if(!setApprovedExpenseReportId.isEmpty()){
            System.debug('getting the approval information for the expense reports ' + setApprovedExpenseReportId);
            List<ProcessInstance> lstProcessInstance = [Select Id, Status, TargetObjectId, 
                                                          (Select IsPending, StepStatus, OriginalActorId, OriginalActor.Name, ActorId From StepsAndWorkitems) 
                                                        From ProcessInstance 
                                                        Where TargetObjectId in :setApprovedExpenseReportId Order By LastModifiedDate Desc];
            for(ProcessInstance processInstance : lstProcessInstance){
                System.debug('processInstance id ' + processInstance.Id + ' for expense report id ' + processInstance.TargetObjectId);
                if(!mapExpenseReportIdToOrigActorName.containsKey(processInstance.TargetObjectId)){
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
                        mapExpenseReportIdToOrigActorName.put(processInstance.TargetObjectId, origActorName);
                    }
                }
            }
        }

        List<PSA_Approver_Info__c> lstApproverInfo = new List<PSA_Approver_Info__c>();
        for(pse__Expense_Report__c expenseRatio : newList){
            if(setApprovedExpenseReportId.contains(expenseRatio.Id) && expenseRatio.PSA_TM_Approver_Info__c != null){
                PSA_Approver_Info__c approverInfo = new PSA_Approver_Info__c();
                approverInfo.Id = expenseRatio.PSA_TM_Approver_Info__c;
                approverInfo.Original_Approver_Name__c = mapExpenseReportIdToOrigActorName.get(expenseRatio.Id);
                approverInfo.Actual_Approver__c = UserInfo.getUserId();
                lstApproverInfo.add(approverInfo);
            }
        }

        if(!lstApproverInfo.isEmpty()){
            update lstApproverInfo;
        }

    }
}