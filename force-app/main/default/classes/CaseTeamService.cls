/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to CaseTeam Object
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag             Description
****************************************************************************************************
Deva M          27-07-21                Utopia phase2   Modified the logic to merge standard 
                                                            case team logic to custom case team logic                  
balajip         11/22/2021  I2RT-4953   T02             To include the "Iam on it" user in the notifications
balajip         07/05/2022  I2RT-6655   T03             Overridden the method getCaseSubscribers to handle bulk
balajip         11/18/2022  I2RT-7505   T04             method swapOwner - dont create Team Member if the coOwner is a Queue
balajip         01/17/2023  I2RT-7643   T05             added method updateEscalationManager
*/
public with sharing class CaseTeamService {

    public static final String TEAM_ROLE_CO_OWNER = 'CoOwner';
    public static final String TEAM_ROLE_OWNER = 'Owner';
    //public static final String TEAM_ROLE_MULTI_PRODUCT = 'MultiProduct';
    public static final String TEAM_ROLE_ESCALATION_MANAGER = 'Escalation Manager';
    public static final String TEAM_ROLE_COLLABORATOR = 'Collaborator'; //I2RT-4456

    //checks if the given user is part of the Case Team
    //Deva updated the query to fetch the custom case team object instead Standard CaseTeamMember Object
    public static Boolean isUserPartOfTeam(Id caseId, Id userId){
        //Deva Commented to Exclude CaseTeamMember
      /*  List<CaseTeamMember> lstCaseTM = [Select Id, ParentId, MemberId, TeamRoleId 
                                            From CaseTeamMember 
                                            Where ParentId = :caseId And MemberId = :userId];*/
                                            

        Boolean userPartOfTeam = false;
        // if(!lstCaseTM.isEmpty()){
        // Deva check if the user already in case team and set the boolean variable 
        List<Case_Team__c> caseTeamList = getCaseTeamMember(new set<Id>{caseId}, new Set<Id>{userId});
        if(caseTeamList.size()>0){
            userPartOfTeam = true;
        }
        return userPartOfTeam;
    }

     /*
     * @description: Get the case team based on case record and user id
     * @date: 27-07-2021
     * Author: Deva
     * @param:  Case record id and user record id
     * @returns: Case Team Record List
     */
    public static List<Case_Team__c> getCaseTeamMember(Set<Id> caseRecordIdSet, Set<Id> userRecordIdSet){
        List<Case_Team__c> caseTeamList = new List<Case_Team__c>([SELECT Id, Case__c, Role__c, User__c, Last_Read_TimeStamp__c 
                                        FROM Case_Team__c where Case__c IN : caseRecordIdSet AND User__c IN : userRecordIdSet]);
        return caseTeamList;
    }

     /*
     * @description: create case team instance and set the fields with provided params
     * @date: 27-07-2021
     * Author: Deva
     * @param:  Case record id, user record id and role
     * @returns: Case Team instance
     */
    public static Case_Team__c createMember(Id caseId, Id userId, String teamRole){
        Case_Team__c caseTM = new Case_Team__c(Case__c=caseId,User__c=userId,Role__c=teamRole); 
        return caseTM;   
    }

    /*
     * @description: get the set of co owners associated with provided case id
     * @date    : 27-07-2021
     * Author   : Deva
     * @param   : Case record id
     * @returns : set of case team users
     */
    public static Set<Id> getCoOwners(Id caseId){
        Set<Id> setUserId = new Set<Id>();   
        List<Case_Team__c> caseTeamList = new List<Case_Team__c>([SELECT Id, Case__c, Role__c, User__c, Last_Read_TimeStamp__c 
                                        FROM Case_Team__c where Case__c = : caseId  AND User__c != null AND Role__c = : TEAM_ROLE_CO_OWNER]); 
        for(Case_Team__c teamMember : caseTeamList){            
            setUserId.add(teamMember.User__c);
        }
        return setUserId;
    }

    public class CaseTeam {
        public List<Case_Team__c> lstToUpsert = new List<Case_Team__c>();
        public List<Case_Team__c> lstToDelete = new List<Case_Team__c>();

        CaseTeam(){

        }
    }

    //I2RT-3908
    //Update the Team Role of current owner as Co-owner and new owner as Owner
    public static void swapOwner(Id caseId, Id newOwnerId, Id currentOwnerId){
        List<Case_Team__c> lstCaseTeamToUpdate = new List<Case_Team__c>();
        List<Case_Team__c> lstCaseTeamToDelete = new List<Case_Team__c>();
        Case_Team__c caseTeamOwner = new Case_Team__c();
        Case_Team__c caseTeamCoOwner = new Case_Team__c();

        List<Case_Team__c> lstCaseTeam = [Select Id, Case__c, Role__c, User__c 
                                From Case_Team__c 
                                Where Case__c = :caseId And (User__c = :newOwnerId Or User__c = :currentOwnerId)];
        
        for(Case_Team__c caseTeam : lstCaseTeam){
            if(TEAM_ROLE_OWNER.equals(caseTeam.Role__c)){
                caseTeamOwner = caseTeam;
            }else if(TEAM_ROLE_CO_OWNER.equals(caseTeam.Role__c)){
                caseTeamCoOwner = caseTeam;
            }
        }

        //T04 - only if the given Id is of a User and not a Queue
        if('User'.equals(currentOwnerId.getSobjectType().getDescribe().getName())){
            caseTeamOwner.User__c = currentOwnerId;
            caseTeamOwner.Case__c = caseId;
            caseTeamOwner.Role__c = TEAM_ROLE_CO_OWNER;    
            lstCaseTeamToUpdate.add(caseTeamOwner);
        }else{
            lstCaseTeamToDelete.add(caseTeamOwner);
        }

        //T04 - only if the given Id is of a User and not a Queue
        if('User'.equals(newOwnerId.getSobjectType().getDescribe().getName())){
            caseTeamCoOwner.User__c = newOwnerId;
            caseTeamCoOwner.Case__c = caseId;
            caseTeamCoOwner.Role__c = TEAM_ROLE_OWNER;
            lstCaseTeamToUpdate.add(caseTeamCoOwner);
        }else{
            lstCaseTeamToDelete.add(caseTeamCoOwner);
        }

        if(!lstCaseTeamToUpdate.isEmpty()){
            upsert lstCaseTeamToUpdate;
        }

        if(!lstCaseTeamToDelete.isEmpty()){
            delete lstCaseTeamToDelete;
        }
    }

    //I2RT-4175
    //Replace the current owner with new owner in the Case Team
    public static CaseTeam changeOwner(Id caseId, Id currentOwnerId, Id newOwnerId){
        CaseTeam caseTeam = new CaseTeam();

        Case_Team__c caseTeamOwnerCurrent;
        Case_Team__c caseTeamOwnerNew;

        Set<Id> setUserId = new Set<Id>();
        if(currentOwnerId != null && 'User'.equals(currentOwnerId.getSobjectType().getDescribe().getName())){
            setUserId.add(currentOwnerId);
        }
        if('User'.equals(newOwnerId.getSobjectType().getDescribe().getName())){
            setUserId.add(newOwnerId);
        }
        List<Case_Team__c> lstCaseTeam = [Select Id, Case__c, Role__c, User__c 
                                From Case_Team__c 
                                Where Case__c = :caseId And User__c in :setUserId];
        
        for(Case_Team__c caseTeamMember : lstCaseTeam){
            if(currentOwnerId == caseTeamMember.User__c){
                caseTeamOwnerCurrent = caseTeamMember;
            }else if(newOwnerId == caseTeamMember.User__c){
                caseTeamOwnerNew = caseTeamMember;
            }
        }

        Boolean deleteCurrentOwner = true;
        if('User'.equals(newOwnerId.getSobjectType().getDescribe().getName())){
            if(caseTeamOwnerNew == null){
                deleteCurrentOwner = false;
                if(caseTeamOwnerCurrent == null){
                    caseTeamOwnerNew = new Case_Team__c();
                }else{
                    caseTeamOwnerNew = caseTeamOwnerCurrent;
                }
            }

            caseTeamOwnerNew.User__c = newOwnerId;
            caseTeamOwnerNew.Case__c = caseId;
            caseTeamOwnerNew.Role__c = TEAM_ROLE_OWNER;
            caseTeam.lstToUpsert.add(caseTeamOwnerNew);
        }

        if(deleteCurrentOwner && caseTeamOwnerCurrent != null){
            caseTeam.lstToDelete.add(caseTeamOwnerCurrent);
        }

        return caseTeam;
    }

     /*
     * @description: Check if the case team member already there if not create a new one
     * @date    : 27-07-2021
     * Author   : Deva
     * @param   : List<Case_Team__c>, List of case tea records
     * @returns : n/a
     */
    public static void checkAndCreate(List<Case_Team__c> lstCaseTM){
        //Set to Hold case id's
        Set<Id> setCaseId = new Set<Id>();
        List<Case_Team__c> lstCaseTMToInsert = new List<Case_Team__c>();
        //Iterate the List of case team records and the case id to set
        for(Case_Team__c caseTM : lstCaseTM){
            //Check if the case field is not blank
            if(caseTM.Case__c!=null){
                setCaseId.add(caseTM.Case__c);
            }
        }
        //If the case id set is not blank
        if(setCaseId.size()>0){
            //Map to check the exisitng case team records and remove the already added team member records while insert
            Map<String,Case_Team__c> caseTeamMap = new Map<String,Case_Team__c>();
            for(Case_Team__c caseTM :[SELECT Id, Case__c, Role__c, User__c FROM Case_Team__c where Case__c IN :setCaseId]){
                //Keay as unique param and value as exisitng team member
                caseTeamMap.put(caseTM.Case__c+'|'+caseTM.User__c,caseTM);
            }
            //Iterate the case team records that need to insert and check if the team member already there
            for(Case_Team__c caseTM : lstCaseTM){
                if(!caseTeamMap.containsKey(caseTM.Case__c+'|'+caseTM.User__c)){
                    //Add the case team record to list
                    lstCaseTMToInsert.add(caseTM);
                }
            }
            //check if the case team records are not empty
            if(!lstCaseTMToInsert.isEmpty()){
                //Partial insert the records 
                Database.SaveResult[] saveResultList = Database.insert(lstCaseTMToInsert, false); 
                //Chatter follow logic                 
                for(Case_Team__c caseTM : lstCaseTMToInsert){
                    if (!Test.isRunningTest()) { //Skip it for a test class
                        try{
                            ConnectApi.ChatterUsers.follow(null, caseTM.User__c, caseTM.Case__c);
                        }catch(Exception ex){
                            System.debug('exception occurred while making the user follow the case, ' + ex.getMessage());
                        }
                    }
                }
            }
        }
    }

    public static Set<Id> getCaseSubscribers(Id caseId, Boolean includeOwner, Boolean includeOwnerManager, Boolean includeCoOwners, Boolean includeSubscribers){
        Set<Id> setUserId = new Set<Id>();

        if(includeOwner || includeOwnerManager){
            List<Case> lstCase = [Select Id, OwnerId, 
                                    Is_case_claimed_weekend_holiday__c, Case_claimed_by_user_weekend_holiday__c //T02
                                    From Case Where Id = :caseId];
            if(!lstCase.isEmpty()){
                Case cse = lstCase.get(0);
                if('User'.equals(cse.OwnerId.getSobjectType().getDescribe().getName())){
                    if(includeOwner){
                        setUserId.add(cse.OwnerId);
                    }
    
                    if(includeOwnerManager){
                        User usr = CaseControllerWithoutSharing.getUser(cse.OwnerId);
                        if(usr.ManagerId != null){
                            setUserId.add(usr.ManagerId);
                        }
                    }    
                }
                //T02
                if(includeOwner && cse.Is_case_claimed_weekend_holiday__c){
                    setUserId.add(cse.Case_claimed_by_user_weekend_holiday__c);
                }
            }
        }

        if(includeCoOwners){
            setUserId.addAll(getCoOwners(caseId));
        }

        List<Subscription__c> lstSubscription = [Select Id, Record_Id__c, Subscriber_Id__c, Subscribed__c 
                                            From Subscription__c Where Record_Id__c = :caseId];

        for(Subscription__c sub : lstSubscription){
            if(sub.Subscribed__c){
                if(includeSubscribers){
                    setUserId.add(sub.Subscriber_Id__c);
                }
            }else{
                setUserId.remove(sub.Subscriber_Id__c);
            }
        }

        return setUserId;
    }

    //T03 - overridden to handle bulk by avoiding SOQL
    public static Set<Id> getCaseSubscribers(Case cse, Set<Subscription__c> setSubscription, Boolean includeOwner, Boolean includeOwnerManager, Boolean includeCoOwners, Boolean includeSubscribers){
        Set<Id> setUserId = new Set<Id>();

        if(includeOwner || includeOwnerManager){
            if('User'.equals(cse.OwnerId.getSobjectType().getDescribe().getName())){
                if(includeOwner){
                    setUserId.add(cse.OwnerId);
                }

                if(includeOwnerManager){
                    User usr = CaseControllerWithoutSharing.getUser(cse.OwnerId);
                    if(usr.ManagerId != null){
                        setUserId.add(usr.ManagerId);
                    }
                }    
            }
            //T02
            if(includeOwner && cse.Is_case_claimed_weekend_holiday__c){
                setUserId.add(cse.Case_claimed_by_user_weekend_holiday__c);
            }
        }

        if(includeCoOwners){
            setUserId.addAll(getCoOwners(cse.Id));
        }

        for(Subscription__c sub : setSubscription){
            if(sub.Subscribed__c){
                if(includeSubscribers){
                    setUserId.add(sub.Subscriber_Id__c);
                }
            }else{
                setUserId.remove(sub.Subscriber_Id__c);
            }
        }

        return setUserId;
    }

    //T05 - to add/remove Escalation Manager from Case Team for the given Engagements.
    public static void updateEscalationManager(Map<Id, Id> mapEngIdToOwnerIdToAdd, Set<Id> setEngIdToRemove, Set<Id> setCaseIdToRemove){
        List<Case_Team__c> lstCaseTeam = [Select Id, Case__c, User__c, Role__c, Case__r.Engagement__c
                                            From Case_Team__c
                                            Where Role__c = :CaseTeamService.TEAM_ROLE_ESCALATION_MANAGER
                                                And Case__r.Status != 'Closed'
												And (Case__c in :setCaseIdToRemove Or Case__r.Engagement__c in :setEngIdToRemove
                                                    Or Case__r.Engagement__c in :mapEngIdToOwnerIdToAdd.keyset())];

        Set<Id> setCaseTeamIdToRemove = new Set<Id>();
        List<Case_Team__c> lstCaseTeamToRemove = new List<Case_Team__c>();
        
        Set<Id> setCaseIdAddressed = new Set<Id>();
        List<Case_Team__c> lstCaseTeamToUpsert = new List<Case_Team__c>();

        for(Case_Team__c caseTeam : lstCaseTeam){
            for(Id cseId : setCaseIdToRemove){
                if(caseTeam.Case__c == cseId && !setCaseTeamIdToRemove.contains(caseTeam.Id)){
                    setCaseTeamIdToRemove.add(caseTeam.Id);
                    lstCaseTeamToRemove.add(caseTeam);
                }
            }

            for(Id engId : setEngIdToRemove){
                if(caseTeam.Case__r.Engagement__c == engId && !setCaseTeamIdToRemove.contains(caseTeam.Id)){
                    setCaseTeamIdToRemove.add(caseTeam.Id);
                    lstCaseTeamToRemove.add(caseTeam);
                }
            }

            for(Id engId : mapEngIdToOwnerIdToAdd.keyset()){
                if(caseTeam.Case__r.Engagement__c == engId){
                    setCaseIdAddressed.add(caseTeam.Case__c);
                    if(caseTeam.User__c != mapEngIdToOwnerIdToAdd.get(engId)){
                        caseTeam.User__c = mapEngIdToOwnerIdToAdd.get(engId);
                        lstCaseTeamToUpsert.add(caseTeam);
                    }
                }
            }
        }

        if(!mapEngIdToOwnerIdToAdd.isEmpty()){
            List<Case> lstCase = [Select Id, Engagement__c From Case 
									Where Status != 'Closed'
                                    And Id not in :setCaseIdAddressed 
                                    And Engagement__c in :mapEngIdToOwnerIdToAdd.keyset()];
			for(Case cse: lstCase){
                Case_Team__c caseTeam = new Case_Team__c();
                caseTeam.Case__c = cse.Id;
                caseTeam.User__c = mapEngIdToOwnerIdToAdd.get(cse.Engagement__c);
                caseTeam.Role__c = CaseTeamService.TEAM_ROLE_ESCALATION_MANAGER;
                lstCaseTeamToUpsert.add(caseTeam);
			}

            if(!lstCaseTeamToUpsert.isEmpty()){
                upsert lstCaseTeamToUpsert;
            }
        }
        
        if(!lstCaseTeamToRemove.isEmpty()){
            delete lstCaseTeamToRemove;
        }
    }
}