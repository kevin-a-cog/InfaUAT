/*
* Name          :   CSMDuplicatePlanTeamValidation
* Author        :   Deva M
* Created Date  :   08/07/2021
* Description   :   this class will call from trigger if it configured in validation settings

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M                  08/07/2021      N/A             Initial version.            N/A

Harshita J              28/06/2022      AR-2791         replace map with list       <t1>
*/
public class CSMDuplicatePlanTeamValidation{
    String errorMessage = 'Duplicate Plan Team User is not Allowed on same plan';
    public void validate(List<Plan_Team__c> planTeamList) {           
        //Set<String> planIdSet = new Set<String>();
        map<string,string> planIdMap = new map<string,string>();// <t1></t1>
        Set<String> userEmailSet = new Set<String>();
        Set<String> exisitngUserIdSet = new Set<String>();
        if(planTeamList!=null && planTeamList.size()>0){
            //Iterate over new list and add unique field to set
            for(Plan_Team__c pteam:planTeamList){
                if(String.isNotBlank(pteam.User_Email__c)){
                    userEmailSet.add(pteam.User_Email__c); 
                }
                //<t1>               
                if(String.isNotBlank(pteam.Plan__c) && !planIdMap.containskey(pteam.Plan__c)){
                    //planIdSet.add(pteam.Plan__c);
                    planIdMap.put(pteam.Plan__c,pteam.User_Email__c);  
                }//</t1>               
            }
        }
        //Check if emailset collection not empty
        if(userEmailSet.size()>0 && planIdMap.size()>0){   
            //query existing records based on email
            for(Plan_Team__c pTeam:[SELECT Id, User__c,Plan__c, User_Email__c, Role__c FROM Plan_Team__c where Plan__c IN : planIdMap.keyset() AND User_Email__c IN : planIdMap.values()]){
               //<t1>
               if(planIdMap.containskey(pteam.Plan__c) && planIdMap.get(pteam.Plan__c) == pTeam.User_Email__c){
                  exisitngUserIdSet.add(pTeam.User_Email__c);
                }
                //</t1>   
             } 
           for(Plan_Team__c pteam:planTeamList){
               System.debug('-->'+pteam.User_Email__c);
                //Check if the new records email over exisitng records and throw error
                if(exisitngUserIdSet.size()>0 && exisitngUserIdSet.contains(pteam.User_Email__c)){
                      pteam.addError(errorMessage);
                }else{
                   // exisitngUserIdSet.add(pteam.User_Email__c);
                }
            }
        }
    }
}