/*********************************************************************************************************************************************
*  @Class Name: ProjectRegistrationTriggerHandler
*  @Author: Deloitte
*  @Date: 2017-12-13 
*  @Description:This is a handler class which holds all the controller logics implemented for ProjectRegistartion Object.
*********************************************************************************************************************************************
ChangeHistory      
*********************************************************************************************************************************************/
public class ProjectRegistrationTriggerHandler
{
    //Add All Before Insert Logic Here
    public static void ProjectRegistrationBeforeInsert(List<Project_Registration__c> newRegsList,Map<Id,Project_Registration__c> newRegMap)
    {
        //US-1796 : Changes Begin
        ProjectRegAccountPopulator(newRegsList);
        ProjectRegProgramPopulator(newRegsList,null,true);
        //US-1796 : Changes End
    }
    
    //Add All Before Update Logic Here
    public static void ProjectRegistrationBeforeUpdate(List<Project_Registration__c> newRegsList,Map<Id,Project_Registration__c> oldRegMap)
    {
        //US-1796 : Changes Begin
        ProjectRegProgramPopulator(newRegsList,oldRegMap,false);
        ProjectRegCSATProgramPopulator(newRegsList,oldRegMap);
        //US-1796 : Changes End
    }
    
    //Add All After Insert Logic Here
    public static void ProjectRegistrationAfterInsert(List<Project_Registration__c> newRegsList)
    {
        apexSharingAfterInsert(newRegsList);
    }
    
    //Add All After Update Logic Here
    public static void ProjectRegistrationAfterUpdate(List<Project_Registration__c> newRegsList,Map<Id,Project_Registration__c> oldRegMap)
    {
        apexSharingAfterUpdate(newRegsList,oldRegMap);
    }
    
    /**
    * Method to implement managed sharing of the Project Reg for all partner users of the account
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
    public static void apexSharingAfterInsert(List<Project_Registration__c> newRegsList)
    {
        String AccType; 
        Id userId = UserInfo.getUserId();
        List<User> userList;
        //Map of PR Id and Acc Id
        Map<Id,Id> prwiseAccMap = new Map<Id,Id>();
        //Map of Account id and list of users
        map<id, List<User>> accIdWiseUserMap = new Map<id,List<User>>();
        //Map of PR id and list of users
        map<id, List<User>> PRIdWiseUserMap = new Map<id,List<User>>();
        for(Project_Registration__c pr:newRegsList)
        {
            if(null != pr.Partner_Account__c)
            {
                prwiseAccMap.put(pr.Id,pr.Partner_Account__c);
            }
        }
        
        
        if(!prwiseAccMap.isEmpty())
        {
            //Fetch all active users for the accounts
            for(User u : [select id, contact.accountid from user where contact.accountid IN :prwiseAccMap.values() and contact.Is_Active__c = TRUE and IsActive  = True]){
                  //Ignore current user
                  if(UserInfo.getUserId() != u.id)
                  {
                    //populate accIdWiseUserMap
                    if(null == accIdWiseUserMap.get(u.contact.accountid))
                      {
                        userList = new List<User>();
                        userList.add(u);
                        accIdWiseUserMap.put(u.contact.accountid,userList);
                      }
                      else
                      {
                        userList = accIdWiseUserMap.get(u.contact.accountid);
                        userList.add(u);
                        accIdWiseUserMap.put(u.contact.accountid,userList);
                      }
                  }
            }
            
            
            //Populate PRIdWiseUserMap with PR Ids against the list of users
            for(Project_Registration__c pr:newRegsList)
            {
                if(null != prwiseAccMap.get(pr.id) && null != accIdWiseUserMap.get(prwiseAccMap.get(pr.id)))
                {
                    PRIdWiseUserMap.put(pr.Id,accIdWiseUserMap.get(prwiseAccMap.get(pr.id)));
                }
            }
            
            ApexSharingUtility.enablesharingForPartnerUsers(PRIdWiseUserMap, label.PRM_ProjectReg_Share, 'Edit');
        }
    }
    
    /**
    * Method to implement managed sharing of the Project Reg for all partner users of the account on after update
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
    public static void apexSharingAfterUpdate(List<Project_Registration__c> newRegsList,Map<Id,Project_Registration__c> oldRegMap)
    {
        String AccType; 
        Id userId = UserInfo.getUserId();
        List<User> userList;
        //Map of PR Id and Acc Id to activate
        Map<Id,Id> prwiseAccMapNew = new Map<Id,Id>();
        //Map of PR Id and Acc Id to de-activate
        Map<Id,Id> prwiseAccMapOld = new Map<Id,Id>();
        //Map of Account id and list of users
        map<id, List<User>> accIdWiseUserMap = new Map<id,List<User>>();
        //Map of PR id and list of users
        map<id, List<User>> PRIdWiseUserMap = new Map<id,List<User>>();
        
        //Fetch current partner account of the PR
        for(Project_Registration__c pr : newRegsList){
            IF(oldRegMap.containsKey(pr.Id))
            {
                if(pr.Partner_Account__c != oldRegMap.get(pr.Id).Partner_Account__c){
                    if(null != pr.Partner_Account__c)
                    {
                        prwiseAccMapNew.put(pr.Id,pr.Partner_Account__c);
                    }
                    if(null != oldRegMap.get(pr.Id).Partner_Account__c)
                    {
                        prwiseAccMapOld.put(pr.Id,oldRegMap.get(pr.Id).Partner_Account__c);
                    }
                }
            }
        }
        
        //enable sharing for new account
        if(!prwiseAccMapNew.isEmpty())
        {
            //Fetch all active users for the accounts
            for(User u : [select id, contact.accountid from user where contact.accountid IN : prwiseAccMapNew.values() and contact.Is_Active__c = TRUE and IsActive  = True]){
                //Ignore current user
                if(UserInfo.getUserId() != u.id)
                {
                    //populate accIdWiseUserMap
                    if(null == accIdWiseUserMap.get(u.contact.accountid))
                      {
                        userList = new List<User>();
                        userList.add(u);
                        accIdWiseUserMap.put(u.contact.accountid,userList);
                      }
                      else
                      {
                        userList = accIdWiseUserMap.get(u.contact.accountid);
                        userList.add(u);
                        accIdWiseUserMap.put(u.contact.accountid,userList);
                      }
                }
            }
            
            
            //Populate PRIdWiseUserMap with PR Ids against the list of users
            for(Project_Registration__c pr:newRegsList)
            {
                if(null != prwiseAccMapNew.get(pr.id) && null != accIdWiseUserMap.get(prwiseAccMapNew.get(pr.id)))
                {
                    PRIdWiseUserMap.put(pr.Id,accIdWiseUserMap.get(prwiseAccMapNew.get(pr.id)));
                }
            }
            
            ApexSharingUtility.enablesharingForPartnerUsers(PRIdWiseUserMap, label.PRM_ProjectReg_Share, 'Edit');
            
        }
        
        //disable sharing for old account
        if(!prwiseAccMapOld.isEmpty())
        {
            ApexSharingUtility.disablesharingForPartnerUsers(prwiseAccMapOld, label.PRM_ProjectReg_Share);
        }
    }
    
    /**
    * This method autopopulates the partner program if an active version is available and if it's left blank when Partner's close a Project Registration
    * This method also roll up the no. of projects completed towards the active partner program
    * @param parameter- newProjRegs- list of new projectregistartions,oldProjRegsMap - map of old projectregistartions
    * @return return- void
    */
    
    public static void ProjectRegProgramPopulator(List<Project_Registration__c> newProjRegs,Map<Id,Project_Registration__c> oldProjRegsMap,Boolean onlyInsert)
    {
        Id userId = UserInfo.getUserId();
        Id AccId;
        Id NewProgramId;
        Date ProjectCloseDate;
        Set<Id> OldProgramId = new Set<Id>();
        Set<Id> RemovedProgramId = new Set<Id>();
        Boolean ProjCloseFlagWithoutProgram = false;
        Boolean ProjCloseFlagWithProgram = false;
        Integer rollupCount=0;
        Map<Id,Integer> OldrollupCountMap = new Map<Id,Integer>();  
        Map<Id,Integer> RemovedrollupCountMap = new Map<Id,Integer>();              
        List<Partner_Program__c> NewPartnerProgramsToUpdate = new List<Partner_Program__c>();
        List<Partner_Program__c> OldPartnerProgramsToUpdate = new List<Partner_Program__c>();
        List<Partner_Program__c> RemovedPartnerProgramsToUpdate = new List<Partner_Program__c>();
        set<string> statusSet = new set<string>();
        statusSet.add(Label.PRM_ProjectRegistration_Status_Complete_Send_Survey);
        statusSet.add(Label.PRM_ProjectRegistration_Status_Complete_Do_Not_Send_Survey);
        statusSet.add(Label.PRM_ProjectRegistration_Status_Complete_Survey_Completed);
        String projRegCountry;
        String mappedCountryValue;
        Map<String,String> countryMAp = mappedCountryValue();
        
        //Instanciated the globalApexManager class to pass parameters for error log creation when exception occurs
        globalApexManager GAM = new globalApexManager();
        
        User loggedInUser;
        loggedInUser = userAccountDetails();
        
        //Iterate Over the User to get the AccountId which will help us to find the Program Id to populate on Project Registartion
        If(loggedInUser != null)
        {    
                if(loggedInUser.Contact.AccountId != null )
                AccId = loggedInUser.Contact.AccountId;
        }      
        
        //Fetch the Last Modified Date for the Newly Closed Project Registration
        for(Project_Registration__c prg : newProjRegs)
        {
          //This block is executed only when Project Registrations are newly Inserted not updated   
          if(onlyInsert == true)
          {
            if(prg.Status__c != null && (prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete) && prg.Partner_Program__c != null)
            {
                OldProgramId.add(prg.Partner_Program__c);
                ProjCloseFlagWithProgram = true;
            }
            
            if(prg.Status__c != null && (prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete) && prg.Partner_Program__c == null)
            {
                ProjectCloseDate = system.today();
                ProjCloseFlagWithoutProgram = true;
                projRegCountry = prg.Customer_Account_Country__c;
                
            }
          }
          
          //This block is executed only when Project Registrations are updated not newly Inserted   
          if(onlyInsert == false)
          {
            //This IF block handles the scenario when Partner Program is blank on a Project Registration
            if(prg.Status__c != null && (prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete) && prg.Partner_Program__c == null)
            {                
                    ProjectCloseDate = (prg.LastModifiedDate).date();
                    ProjCloseFlagWithoutProgram = true;
                    projRegCountry = prg.Customer_Account_Country__c;
            }
          
          
            //This IF block handles the scenario when Partner Program is already present on a Project Registration
            if(prg.Partner_Program__c != null)
            {
               //Capture the Old Program Ids Which are removed from the Project Registration when Project is Not Completed
               If(prg.Partner_Program__c != oldProjRegsMap.get(prg.Id).Partner_Program__c && !(prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete))
               {
                    RemovedProgramId.add(oldProjRegsMap.get(prg.Id).Partner_Program__c);
                    
               }
               
               //Capture the New Program Ids which are added and Old Program Ids Which are removed from the Project Registration, when Project is Completed
               If(prg.Partner_Program__c != oldProjRegsMap.get(prg.Id).Partner_Program__c && (prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete))
               {
                    RemovedProgramId.add(oldProjRegsMap.get(prg.Id).Partner_Program__c);
                    OldProgramId.add(prg.Partner_Program__c);                   
                    ProjCloseFlagWithProgram = true;
                    
               }
                //Checking if the Partner Program on the Project Registration is unchanged(not null) but the Project is completed
                If((prg.Partner_Program__c == oldProjRegsMap.get(prg.Id).Partner_Program__c) && (prg.Status__c != oldProjRegsMap.get(prg.Id).Status__c))
                {
                    If(!(oldProjRegsMap.get(prg.Id).Status__c).contains(Label.PRM_Program_Status_Contains_Complete) && (prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete))
                    {
                        OldProgramId.add(prg.Partner_Program__c);                   
                        ProjCloseFlagWithProgram = true;
                    }
                    If((oldProjRegsMap.get(prg.Id).Status__c).contains(Label.PRM_Program_Status_Contains_Complete) && !(prg.Status__c).contains(Label.PRM_Program_Status_Contains_Complete))
                    {                   
                        RemovedProgramId.add(prg.Partner_Program__c);
                    }
                }
                          
            }
 
          }
        }
        
        
        if(countryMAp.containskey(projRegCountry))
        {
            mappedCountryValue = countryMAp.get(projRegCountry);
        }
        else
        {
            mappedCountryValue = countryMAp.get('Default');
        }
        
        
    //This Block handles when Program is available and Partners are closing the Project Registrations    
    if(ProjCloseFlagWithoutProgram == true)
    {
        
        //Find the Partner Program using the Partner Users AccountId
        If(ProjectCloseDate != null && mappedCountryValue != null)
        {
            
            for(Partner_Program__c pp :[SELECT Id from Partner_Program__c where Start_Date__c <=:ProjectCloseDate AND End_Date__c >= :ProjectCloseDate AND Program_Type__c =: Label.PRM_Prgrm_Type_CSI_Value AND Program_Status__c =: Label.PRM_Program_Status_Active_Value AND Partner__c=:AccId AND Country__c =:mappedCountryValue LIMIT 1])
            {
                NewProgramId = pp.Id;
            } 
        }
        //Check if the Partner Program has already closed Project Registrations
        for(Project_Registration__c prgOld : [SELECT Id from Project_Registration__c where Partner_Program__c=:NewProgramId AND Status__c IN :statusSet])
        {
            rollupCount++;
        }
        
        If(NewProgramId != null)
        {
            //Autopopulate the Program For the Closed Project Registration
            for(Project_Registration__c prgNew : newProjRegs)
            {
                prgNew.Partner_Program__c = NewProgramId;
            }
            
            //Update the Partner Program with the new Rollup Count Value
            for(Partner_Program__c pp :[SELECT Id,No_of_projects_registered__c from Partner_Program__c where Id=:NewProgramId LIMIT 1])
            {
                //Program has already Closed projects then just add +1 to the count
                If(rollupCount > 0){
                    pp.No_of_projects_registered__c = rollupCount + 1;
                }
                
                //Program will have the newly closed Project Registration only, so set the count to 1
                If(rollupCount == 0){
                    pp.No_of_projects_registered__c = 1;
                }
                
                NewPartnerProgramsToUpdate.add(pp);
            }
        
            if(NewPartnerProgramsToUpdate != null && !NewPartnerProgramsToUpdate.isEmpty())
            {
                try
                {
                    update NewPartnerProgramsToUpdate;
                }
                catch (System.DmlException e) { GAM.CreateLogs('ProjectRegistrationTriggerHandler:ProjectRegProgramPopulator At 179','ApexClass:ProjectRegistrationTriggerHandler');            
                }
            }
        }       
     }
     
     //This Block handles when Program is not available and Partners are closing the Project Registrations, and then Admin will populate the Partner Program      
     If(ProjCloseFlagWithProgram == true && !OldProgramId.isEmpty())
     {
            for(AggregateResult ar : [SELECT Count(Id),Partner_Program__c from Project_Registration__c where Partner_Program__c IN :OldProgramId AND Status__c IN :statusSet group by Partner_Program__c]){
                OldrollupCountMap.put((Id)ar.get('Partner_Program__c'),(Integer)ar.get('expr0'));
            }
            //Update the New Partner Program with the new Rollup Count Value
            for(Partner_Program__c pp :[SELECT Id,No_of_projects_registered__c from Partner_Program__c where Id IN :OldProgramId])
            {
                //Program has already Closed projects then just add +1 to the count
                if(OldrollupCountMap.containskey(pp.Id) && OldrollupCountMap.get(pp.Id) > 0){
                    pp.No_of_projects_registered__c = OldrollupCountMap.get(pp.Id) + 1;
                }
                
                //Program will have the newly closed Project Registration only, so set the count to 1
                If(OldrollupCountMap.containskey(pp.Id) && OldrollupCountMap.get(pp.Id) == 0){
                    pp.No_of_projects_registered__c = 1;
                }
                
                If(!OldrollupCountMap.containskey(pp.Id)){
                    pp.No_of_projects_registered__c = 1;
                }
                
                OldPartnerProgramsToUpdate.add(pp);
            }
        
            if(OldPartnerProgramsToUpdate != null && !OldPartnerProgramsToUpdate.isEmpty())
            {
                try
                {
                    update OldPartnerProgramsToUpdate;
                }
            
                catch (System.DmlException e) { 
                    GAM.CreateLogs('ProjectRegistrationTriggerHandler:ProjectRegProgramPopulator At 221','ApexClass:ProjectRegistrationTriggerHandler');            
                }
            }
            
      }
      
      //This block handles the roll up count towards the removed program Ids from the project registration
      If(RemovedProgramId != null && !RemovedProgramId.isEmpty())
      {
          for(AggregateResult ar : [SELECT Count(Id),Partner_Program__c from Project_Registration__c where Partner_Program__c IN :RemovedProgramId AND Status__c IN :statusSet group by Partner_Program__c])
          {
                RemovedrollupCountMap.put((Id)ar.get('Partner_Program__c'),(Integer)ar.get('expr0'));               
          }
          
          //Update the Removed Partner Program with the new Rollup Count Value
          for(Partner_Program__c pp :[SELECT Id,No_of_projects_registered__c from Partner_Program__c where Id IN :RemovedProgramId])
          {                
                //Program has already Closed projects then just substract -1 to the count
                if(RemovedrollupCountMap.containskey(pp.Id) && RemovedrollupCountMap.get(pp.Id) > 0){
                    pp.No_of_projects_registered__c = RemovedrollupCountMap.get(pp.Id) - 1;
                 }
                
                RemovedPartnerProgramsToUpdate.add(pp);               
          }
          
          if(RemovedPartnerProgramsToUpdate != null && !RemovedPartnerProgramsToUpdate.isEmpty())
          {
                try
                {
                    update RemovedPartnerProgramsToUpdate;
                }
            
                catch (System.DmlException e) { GAM.CreateLogs('ProjectRegistrationTriggerHandler:ProjectRegProgramPopulator At 255','ApexClass:ProjectRegistrationTriggerHandler');            
                }
          }
      
      }
      
    }
    
    /**
    * This method autopopulates the CSAT partner program if an active version is available
    * This method also roll up the no. of Evaluation Score greater than 85 towards the active partner program
    * @param parameter- newProjRegs- list of new projectregistartions,oldProjRegsMap - map of old projectregistartions
    * @return return- void
    */
    public static void ProjectRegCSATProgramPopulator(List<Project_Registration__c> newProjRegs,Map<Id,Project_Registration__c> oldProjRegsMap){
        
        //set of Account id of PRoj Reg   
        set<id> setOfProjRegAccountId = new set<id>(); 
        
        //set of CSAT Partner Program of Proj Reg
        set<id> setOfProjRegCSATPrtrnPrgrmId = new set<id>();
        //set of Partner Program, whose roll up is to be updated by addition of new CSAT 85%+.
        Set<Id> NewPrtnrPrgrmtoUpdate = new Set<Id>();
        
        //set of Partner Program, whose roll up is to be updated by removing CSAT85%+
        Set<Id> RemovedPrtnrPrgrmtoUpdate = new Set<Id>();
        
        //set of project registration id
        Set<Id> setProjRegId = new Set<Id>();
        
        //Map of Project Registration Account Id and Partner Program
        Map<Id,Partner_Program__c> ProjRegAccountIdPrtrPrgrm = new Map<Id,Partner_Program__c>();
        
        //Map of PRoject Registration Id and CSAT Score.
        Map<Id,Evaluation__c> ProjRegIdUpdtdCSATScore = new Map<Id,Evaluation__c>();
        
        //String to search for country to be mapped for csat partner program
        String partnerCountry;
        Map<String,String> countryMAp = mappedCountryValue();
        
        //set of proj reg country from PRoj Reg   
        set<String> setOfProjRegCountry = new set<String>();
        
        for(Project_Registration__c prg : newProjRegs)
        {
            setProjRegId.add(prg.Id);
            IF(oldProjRegsMap.containsKey(prg.Id))
            {
                If((prg.Dev_CSAT_Completed_Date__c != oldProjRegsMap.get(prg.Id).Dev_CSAT_Completed_Date__c) && (prg.Dev_CSAT_Completed_Date__c != null) && (prg.CSAT_Program__c == null)) {
                    setOfProjRegAccountId.add(prg.Partner_Account__c);
                    if(countryMAp.containskey(prg.Customer_Account_Country__c))
                    {
                        partnerCountry = countryMAp.get(prg.Customer_Account_Country__c);
                    }
                    else
                    {
                        partnerCountry = countryMAp.get('Default');
                    }
                    setOfProjRegCountry.add(partnerCountry);
                }
                If(((prg.CSAT_Program__c != oldProjRegsMap.get(prg.Id).CSAT_Program__c) && (prg.Dev_CSAT_Completed_Date__c != null) && (prg.CSAT_Program__c != null)) || ((prg.Dev_CSAT_Completed_Date__c != oldProjRegsMap.get(prg.Id).Dev_CSAT_Completed_Date__c) && (prg.Dev_CSAT_Completed_Date__c != null) && (prg.CSAT_Program__c != null)))
                {
                    
                    setOfProjRegCSATPrtrnPrgrmId.add(prg.CSAT_Program__c);
                    
                    if(countryMAp.containskey(prg.Customer_Account_Country__c))
                    {
                        partnerCountry = countryMAp.get(prg.Customer_Account_Country__c);
                    }
                    else
                    {
                        partnerCountry = countryMAp.get('Default');
                    }
                    setOfProjRegCountry.add(partnerCountry);
                }
            }
        }
        
        if(!setOfProjRegAccountId.isEmpty() && !setOfProjRegCountry.isEmpty())
        {
            
            for(Partner_Program__c pp :[SELECT Id,Start_Date__c,End_Date__c,Partner__c from Partner_Program__c where Program_Type__c = :Label.PRM_Prgrm_Type_CSI_Value AND Program_Status__c = :Label.PRM_Program_Status_Active_Value AND Partner__c In : setOfProjRegAccountId AND Country__c In : setOfProjRegCountry ORDER BY LastModifiedDate ASC Limit 1]) {
                ProjRegAccountIdPrtrPrgrm.put((Id)pp.Partner__c,pp);
            }
        }
        
        if(!setOfProjRegCSATPrtrnPrgrmId.isEmpty() && !setOfProjRegCountry.isEmpty())
        {
            for(Partner_Program__c pp :[SELECT Id,Start_Date__c,End_Date__c,Partner__c from Partner_Program__c where Program_Type__c = :Label.PRM_Prgrm_Type_CSI_Value AND Program_Status__c = :Label.PRM_Program_Status_Active_Value AND Id In : setOfProjRegCSATPrtrnPrgrmId AND Country__c In : setOfProjRegCountry ORDER BY LastModifiedDate ASC Limit 1])
            {
                ProjRegAccountIdPrtrPrgrm.put((Id)pp.Partner__c,pp);
                
            }
        
        }
        
        
        
        If((!setOfProjRegAccountId.isEmpty()) || (!setOfProjRegCSATPrtrnPrgrmId.isEmpty()))
        {
            
            
            for(Evaluation__c updtd_prg :[SELECT Project_Registration__c,CSAT_Score__c from Evaluation__c where Project_Registration__c In : setProjRegId])
            {
                ProjRegIdUpdtdCSATScore.put((Id)updtd_prg.Project_Registration__c,updtd_prg);
            }
            
            
            //Fetch the variables for the updated Project Registration
            for(Project_Registration__c prg : newProjRegs)
            {
                //Checking if the Dev Completed Date on the Project Registration is changed and not null and CSAT partner Prgrm is null
                //Find active CSAT Prtnr Program and do a Roll-up.      
                if(ProjRegAccountIdPrtrPrgrm.containsKey(prg.Partner_Account__c) && (prg.Dev_CSAT_Completed_Date__c <= ProjRegAccountIdPrtrPrgrm.get(prg.Partner_Account__c).End_Date__c) && (prg.Dev_CSAT_Completed_Date__c >= ProjRegAccountIdPrtrPrgrm.get(prg.Partner_Account__c).Start_Date__c))
                {
                    If((prg.Dev_CSAT_Completed_Date__c != oldProjRegsMap.get(prg.Id).Dev_CSAT_Completed_Date__c) && (prg.Dev_CSAT_Completed_Date__c != null) && (prg.CSAT_Program__c == null))
                    {
                        prg.CSAT_Program__c = ProjRegAccountIdPrtrPrgrm.get(prg.Partner_Account__c).Id;
                    }
                    
                    if(ProjRegIdUpdtdCSATScore.get(prg.Id).CSAT_Score__c > 85)
                    {
                        NewPrtnrPrgrmtoUpdate.add(ProjRegAccountIdPrtrPrgrm.get(prg.Partner_Account__c).Id);
                    }
                }
            
                //If CSAT partner program has been updated then add 1 to new pp roll up  and subtract 1 from old pp roll up
                If((prg.CSAT_Program__c != oldProjRegsMap.get(prg.Id).CSAT_Program__c) && (prg.CSAT_Program__c != null) && (oldProjRegsMap.get(prg.Id).CSAT_Program__c != null))
                {
                    if(ProjRegIdUpdtdCSATScore.get(prg.Id).CSAT_Score__c > 85)
                    {
                        NewPrtnrPrgrmtoUpdate.add(prg.CSAT_Program__c);
                        RemovedPrtnrPrgrmtoUpdate.add(oldProjRegsMap.get(prg.Id).CSAT_Program__c);      
                    }
                }
                
                If((prg.CSAT_Program__c == oldProjRegsMap.get(prg.Id).CSAT_Program__c) && (prg.Dev_CSAT_Completed_Date__c != oldProjRegsMap.get(prg.Id).Dev_CSAT_Completed_Date__c) && (prg.Dev_CSAT_Completed_Date__c != null) && (prg.CSAT_Program__c != null))
                {
                    
                    if(ProjRegIdUpdtdCSATScore.get(prg.Id).CSAT_Score__c != oldProjRegsMap.get(prg.Id).CSAT_Score__c)
                    {
                        if(ProjRegIdUpdtdCSATScore.get(prg.Id).CSAT_Score__c > 85 && oldProjRegsMap.get(prg.Id).CSAT_Score__c <= 85)
                        {
                            NewPrtnrPrgrmtoUpdate.add(prg.CSAT_Program__c);
                        }
                        else if(ProjRegIdUpdtdCSATScore.get(prg.Id).CSAT_Score__c <= 85 && oldProjRegsMap.get(prg.Id).CSAT_Score__c > 85)
                        {
                            RemovedPrtnrPrgrmtoUpdate.add(oldProjRegsMap.get(prg.Id).CSAT_Program__c);
                        }
                    }
                }           
                //Rollup sum of eval score > 85 for
                if(!NewPrtnrPrgrmtoUpdate.isEmpty())
                {
                    AddPartnerProgramRollupCalculate(NewPrtnrPrgrmtoUpdate);
                }
                if(!RemovedPrtnrPrgrmtoUpdate.isEmpty())
                {
                    RemovePartnerProgramRollupCalculate(RemovedPrtnrPrgrmtoUpdate);
                }
                
            }
        }
    }
    
    /**
    * This method roll ups the value of CSAT score > 85 and updates count for newly added or updated CSAT Partner Program
    * @param parameter- NewPrtnrPrgrm- list of new and updated CSAT partner programs
    * @return return- void
    */  
    public static void AddPartnerProgramRollupCalculate(Set<Id> NewPrtnrPrgrm)
    {
        //Instanciated the globalApexManager class to pass parameters for error log creation when exception occurs
        globalApexManager GAM = new globalApexManager();
        
        Map<Id,Integer> NewRollupCountMap = new Map<Id,Integer>(); 
        
        List<Partner_Program__c> NewPrtrPrgrmsToUpdate = new List<Partner_Program__c>();
        
        for(AggregateResult ar : [SELECT Count(Id),CSAT_Program__c from Project_Registration__c where CSAT_Program__c IN :NewPrtnrPrgrm AND CSAT_Score__c > :Integer.valueOf(Label.PRM_CSAT_Score_85) group by CSAT_Program__c]) {
            NewRollupCountMap.put((Id)ar.get('CSAT_Program__c'),(Integer)ar.get('expr0'));
        }
        
        //Update the New Partner Program with the new Rollup Count Value
        for(Partner_Program__c pp :[SELECT Id,No_of_Projects_CSAT_85__c from Partner_Program__c where Id IN :NewPrtnrPrgrm])
        {
            //Program has already CSAT score 85%+ then just add +1 to the count
            if(NewRollupCountMap.containskey(pp.Id) && NewRollupCountMap.get(pp.Id) > 0 &&
            Schema.sObjectType.Partner_Program__c.fields.No_of_Projects_CSAT_85__c.isUpdateable()){
                pp.No_of_Projects_CSAT_85__c = NewRollupCountMap.get(pp.Id) + 1;
            }
            
            //Program will have the newly CSAT Score 85%+ only, so set the count to 1
            if(NewRollupCountMap.containskey(pp.Id) && NewRollupCountMap.get(pp.Id) == 0 &&
            Schema.sObjectType.Partner_Program__c.fields.No_of_Projects_CSAT_85__c.isUpdateable()){
                pp.No_of_Projects_CSAT_85__c = 1;
            }
            
            if(!NewRollupCountMap.containskey(pp.Id) && 
            Schema.sObjectType.Partner_Program__c.fields.No_of_Projects_CSAT_85__c.isUpdateable()){
                pp.No_of_Projects_CSAT_85__c = 1;
            }
            
            NewPrtrPrgrmsToUpdate.add(pp);
            
        }
        if(NewPrtrPrgrmsToUpdate != null && !NewPrtrPrgrmsToUpdate.isEmpty() &&
        Schema.getGlobalDescribe().get('Partner_Program__c').getDescribe().isUpdateable())
        {
            try
            {
                update NewPrtrPrgrmsToUpdate;
            }
        
            catch (System.DmlException e) { GAM.CreateLogs('ProjectRegistrationTriggerHandler:PartnerProgramRollupCalculate At 433','ApexClass:ProjectRegistrationTriggerHandler');            
            }
        }
    
    }
    
    /**
    * This method roll ups the value of CSAT score > 85 and updates count for removed CSAT Partner Program
    * @param parameter- OldPrtnrPrgrm- list of removed CSAT partner programs
    * @return return- void
    */
    public static void RemovePartnerProgramRollupCalculate(Set<Id> OldPrtnrPrgrm)
    {
        
        //Instanciated the globalApexManager class to pass parameters for error log creation when exception occurs
        globalApexManager GAM = new globalApexManager();
        
        
        List<Partner_Program__c> OldPrtrPrgrmsToUpdate = new List<Partner_Program__c>();
        //Update the Old Partner Program with the new Rollup Count Value
        for(Partner_Program__c pp :[SELECT Id,No_of_Projects_CSAT_85__c from Partner_Program__c where Id IN :OldPrtnrPrgrm])
        {
               if( pp.No_of_Projects_CSAT_85__c != 0 && pp.No_of_Projects_CSAT_85__c > 0 &&
               Schema.sObjectType.Partner_Program__c.fields.No_of_Projects_CSAT_85__c.isUpdateable())
            {
               pp.No_of_Projects_CSAT_85__c = pp.No_of_Projects_CSAT_85__c - 1;
               OldPrtrPrgrmsToUpdate.add(pp);
            }            
        }
        
        if(OldPrtrPrgrmsToUpdate != null && !OldPrtrPrgrmsToUpdate.isEmpty() && 
        Schema.getGlobalDescribe().get('Partner_Program__c').getDescribe().isUpdateable())
        {
            try
            {
                update OldPrtrPrgrmsToUpdate;
            }
        
            catch (System.DmlException e) { 
                GAM.CreateLogs('ProjectRegistrationTriggerHandler:PartnerProgramRollupCalculate','ApexClass:ProjectRegistrationTriggerHandler');            
            }
        }
    
    }
    
    
    
    /**
    * This method auto-populates the partner account on the project registration
    * It checks the Logged in Partner's Account and populates the same
    * @param parameter- newRegs- list of new projectregistartions
    * @return return- void
    */
    
    public static void ProjectRegAccountPopulator(List<Project_Registration__c> newRegs)
    {
        Id userId = UserInfo.getUserId();
        Id AccId;
        String psmEmail;
        User loggedInUser;
        
        loggedInUser = userAccountDetails();
        //Iterate Over the User to get the AccountId and Account Type
        If(loggedInUser != null)
        {
                  
                If(loggedInUser.Contact.AccountId !=null )
                AccId = loggedInUser.Contact.AccountId;
                //If(loggedInUser.Contact.Account.PSM__r.Email != null )
                //psmEmail = loggedInUser.Contact.Account.PSM__r.Email;       
                
                //Fetch the PSM user id from Account Team of the logged in user account
                for (AccountTeamMember atm : [SELECT ID,User.Email FROM AccountTeamMember WHERE TeamMemberRole = 'PSM' AND AccountId = :AccId limit 1])
                {
                    psmEmail = atm.User.Email;
                }
        }
        //Pre-populate the Partner Account and PSM Email for the Project Registration
        for(Project_Registration__c prg : newRegs)
        {
            If(AccId != null)
            prg.Partner_Account__c = AccId;
            If(psmEmail != null)
            prg.DEV_PSM_Email__c = psmEmail;
        } 
    }
    
    /**
    * This method fetched the user's contact and account details if the contact of account exists
    * @return return- User
    */
    public static User userAccountDetails(){
        Id userId = UserInfo.getUserId();
        User loggedInUser;
        //Iterate Over the User to get the AccountId and Account Type
        If(userId != null)
        {
            for(User u : [select Id,Contact.AccountId from User where Id = :userId and Contact.AccountId  != NULL])
            {
                loggedInUser = u;       
            }
        }
        
        return loggedInUser;
    }
    
    /**
    * This method fetched the country mapping of partner program for the country on project registration to fetch and set partner program
    * @return return- string
    */
    public static Map<String,String> mappedCountryValue(){
        Set<String> CountryMap = new Set<String>();
        Map<String,String> projectRegPartnerPrgrmCountryMap = new Map<String,String>();
        for(PRM_Custom_Data_Settings__mdt metadata : [SELECT Country_Map__c from PRM_Custom_Data_Settings__mdt limit 1])
        {
            if(metadata.Country_Map__c != null && metadata.Country_Map__c != ''){
            CountryMap.addAll((metadata.Country_Map__c).split('#'));
            }
        }
        for(String cmap : CountryMap)
        {
            string[] splitCmap = ((cmap).trim()).split('\\|');
            projectRegPartnerPrgrmCountryMap.put(splitCmap[0],splitCmap[1]);
        }
        
        return projectRegPartnerPrgrmCountryMap;
    }
}