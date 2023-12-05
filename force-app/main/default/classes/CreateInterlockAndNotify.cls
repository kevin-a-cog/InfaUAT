/*
Class:          CreateInterlockAndNotify  
@Author:        Chandana Gowda 
@Created Date:  20-Jan-2020
@Description:   Invocable class to Automate the SMG Interlock creation for Digital/High Touch Plans
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
*************************************************************************************************************************************
    Harshita J            07/29/2022     AR-2592            Updated RT from SMG to Related Opp  <t1>
*/

public with sharing class CreateInterlockAndNotify {

    public static globalApexManager GAM = new globalApexManager();

    private final static string PLAN_RT = Label.Plan_Record_Type;
    private final static string Related_Interlock=Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId(); //<t1/>
    private final static string newInterlockMsg = 'Handoff for Opportunity Number ';

    /*Method to create SMG Interlock
    * @param Name - ObjIds:Renewal Opportunity REcord Ids
    * @throws exception -n/a
    * @return- void
    */        
    @InvocableMethod(label='Create InterLock and Notify CSM' description='Create InterLock and Notify CSM')
    public static void createInterlock(List<Id> ObjIds){
        
        Map<Id,Opportunity> mapRenewalOpty =new Map<Id,Opportunity>([SELECT Id,AccountId,SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.SBQQ__Opportunity__c,SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c,SBQQ__RenewedContract__r.SBQQ__Opportunity__r.RecordTypeId,SBQQ__RenewedContract__r.SBQQ__Opportunity__r.RecordType.DeveloperName,SBQQ__RenewedContract__r.StartDate,SBQQ__RenewedContract__r.EndDate,SBQQ__RenewedContract__r.SBQQ__Order__r.BillToContactId FROM Opportunity WHERE Id IN :ObjIds]);
        Map<Id,Id> mapOptyAccount = new Map<Id,Id>();
        Set<Id> lstOriginalOpty = new Set<Id>();
        Map<Id,Related_Opportunity_Plan__c> mapOriginalOptyInterlock = new Map<Id,Related_Opportunity_Plan__c>();
        Map<Id,List<Id>> mapAccountPlan = new Map<Id,List<Id>>();
        List<String> planRecordTypes = PLAN_RT.split(';');
        List<Related_Opportunity_Plan__c> lstInterlockInsert = new List<Related_Opportunity_Plan__c>();

        //Creating a map of Opty and Account
        for(Opportunity opp:mapRenewalOpty.values()){
            if(mapRenewalOpty.get(opp.Id).SBQQ__RenewedContract__r.SBQQ__Opportunity__r.RecordType.DeveloperName == 'Renewal_Opportunity')
                lstOriginalOpty.add((ID)mapRenewalOpty.get(opp.Id).SBQQ__RenewedContract__r.SBQQ__Opportunity__c);
            mapOptyAccount.put(opp.Id,(ID)opp.AccountId);
        }

        //Fetching the list of plan and creating a map of account and plan 
        List<Plan__c> lstPlansRenewalOptys=[SELECT Id,Account__c,RecordType.DeveloperName FROM Plan__c WHERE Account__c IN :mapOptyAccount.values() AND Status__c = 'Active']; 
        if(lstPlansRenewalOptys != null || lstPlansRenewalOptys.size()>0){
            for(Plan__c plan:lstPlansRenewalOptys){
                if(planRecordTypes.contains(plan.RecordType.DeveloperName)){
                    if(!mapAccountPlan.keySet().contains((Id)plan.Account__c)){
                        mapAccountPlan.put(plan.Account__c,new List<Id>{plan.Id});
                    }
                    else{
                        List<Id> lstAccPlan = mapAccountPlan.get(plan.Account__c);
                        lstAccPlan.add(plan.Id);
                        mapAccountPlan.put(plan.Account__c,lstAccPlan);                
                    }
                }
            }
        }
       

        //Fetching the list of plan and creating a map of account and plan 
        List<Related_Opportunity_Plan__c> lstInterlockOriginalOptys=[SELECT Id,Plan__c,Opportunity__c FROM Related_Opportunity_Plan__c WHERE Opportunity__c IN :lstOriginalOpty AND Plan__r.Status__c = 'Active' AND Plan__r.RecordType.DeveloperName IN :planRecordTypes]; 
        if(lstInterlockOriginalOptys != null || lstInterlockOriginalOptys.size()>0){
            for(Related_Opportunity_Plan__c interlock:lstInterlockOriginalOptys){
                mapOriginalOptyInterlock.put((ID)interlock.Opportunity__c,interlock);
            }
        }        

        //Creating a list of Interlock to Insert
        for(ID oppId:mapRenewalOpty.keySet()){            
            Related_Opportunity_Plan__c Interlock = new Related_Opportunity_Plan__c();
            Interlock.put('RecordTypeId',Related_Interlock);
            Interlock.put('Opportunity__c',oppId);
            Interlock.put('Account__c',mapRenewalOpty.get(oppId).AccountId);
            if(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__c != null){
                Interlock.put('Contract__c',mapRenewalOpty.get(oppId).SBQQ__RenewedContract__c);
                if(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.StartDate != null)
                    Interlock.put('Contract_StartDate__c',mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.StartDate);                
                if(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.EndDate != null)
                    Interlock.put('Contract_EndDate__c',mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.EndDate);
                if(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Opportunity__c != null)                                         
                    Interlock.put('Original_Opportunity__c',mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Opportunity__c);                
                if(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c != null) 
                    Interlock.put('Original_Opportunity_Number_Text__c',mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c);
              //  if(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Order__r.BillToContactId != null)
               //     Interlock.put('Contact__c',mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Order__r.BillToContactId);
            }
            if(!(mapAccountPlan != null && mapAccountPlan.get(mapOptyAccount.get(oppId)) != null)){
                lstInterlockInsert.add(Interlock);
            }
            else if(mapAccountPlan != null && mapAccountPlan.get(mapOptyAccount.get(oppId)) != null && mapAccountPlan.get(mapOptyAccount.get(oppId)).size() == 1){
                Interlock.put('Plan__c',mapAccountPlan.get(mapOptyAccount.get(oppId))[0]);
                lstInterlockInsert.add(Interlock);
            }
            
            else if(mapAccountPlan != null && mapOptyAccount.get(oppId) != null && mapAccountPlan.get(mapOptyAccount.get(oppId)).size() > 1 && mapOriginalOptyInterlock != null && mapOriginalOptyInterlock.keySet().contains(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Opportunity__c)){
                Interlock.put('Plan__c',mapOriginalOptyInterlock.get(mapRenewalOpty.get(oppId).SBQQ__RenewedContract__r.SBQQ__Opportunity__c).Plan__c);
                lstInterlockInsert.add(Interlock);
            }

        }

        try{
            if(lstInterlockInsert!=null && lstInterlockInsert.size()>0){
                Database.SaveResult[] saveRes = Database.insert(lstInterlockInsert, false);
                List<Id> lstInterlock = new List<Id>();
                for(Database.SaveResult sr:saveRes)
                    lstInterlock.add(sr.getId());
                //notifing the CSM on Account Territory
                notifyCSMOnAccount(lstInterlock,mapOptyAccount.values());
            }
        }
        catch(Exception e){
            GAM.CreateLogs('CreateInterlockAndNotify.createInterlock', lstInterlockInsert, 'lstInterlockInsert');
        }
        GAM.InsertDebugLogs();       

    }

    /*Method to post chatter mentioning the CSM on territory on Interlock creation
    * @param Name - lstInterlockIds:Interlock Ids,mapOptyAccount:Map of Opportunity to Account
    * @throws exception -n/a
    * @return- void
    */  
    public static void notifyCSMOnAccount(List<Id> lstInterlockIds,List<Id> lstAccIds){
        
        Map<Id,Id> mapAccToCSM = new Map<Id,Id>();
        Map<Id,Id> mapInterlockAcc = new Map<Id,Id>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        //Fetching the list of Interlock and create a map of Interlock and Accounnt
        Map<Id,Related_Opportunity_Plan__c> mapInterlockRec = new Map<Id,Related_Opportunity_Plan__c>([SELECT Id,Account__c,Plan__c,Plan__r.Name,Opportunity__c,Opportunity__r.New_Org_Opportunity_Number__c FROM Related_Opportunity_Plan__c WHERE Id IN :lstInterlockIds]);
        for(Related_Opportunity_Plan__c interlock:mapInterlockRec.values())
            mapInterlockAcc.put(interlock.Id,interlock.Account__c);

        List<AccountTeamMember> lstAccTeamMembers = [SELECT AccountId,TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId IN :lstAccIds AND TeamMemberRole ='CSM'] ;
        for(AccountTeamMember csm:lstAccTeamMembers){
            mapAccToCSM.put((ID)csm.AccountId,(ID)csm.UserId);
        }            

        //Posting chatter on Interlock
        for(Related_Opportunity_Plan__c interlock:mapInterlockRec.values()){
             if(mapAccToCSM.get(mapInterlockAcc.get(interlock.Id)) !=null){
                String ChatterMessageString = '{'+mapAccToCSM.get(mapInterlockAcc.get(interlock.Id))+'} '+newInterlockMsg +mapInterlockRec.get(interlock.Id).Opportunity__r.New_Org_Opportunity_Number__c;
                if(mapInterlockRec.get(interlock.Id).Plan__c != null)
                    ChatterMessageString += '\nPlan: '+mapInterlockRec.get(interlock.Id).Plan__r.Name;
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.subjectId = interlock.Id;
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();                
                body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(ChatterMessageString);                   
                input.body = body;
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);  
            }                      
        }
        if(!Test.isRunningTest() &&  batchInputs!=null && batchInputs.size()>0)
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);                
    }
}