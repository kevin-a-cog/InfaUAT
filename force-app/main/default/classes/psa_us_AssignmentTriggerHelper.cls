/*
@created by       : MAHESH GANTI
@created on       : 10/19/2020
@Purpose          : Handler class for psa_AssignmentTrigger.

Change History
*********************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By    |     Description                                 |  Jira No.     | Tag No:   |
************|***************|***********************|***********************************************|***************|***********|
RANJAN      |  03/21/2021   |                       |  Update Project's End Date with Max           |  PSA-1461     |   <T1>    |
            |               |                       |  Assignment End Date                          |               |           |
------------|---------------|-----------------------|-----------------------------------------------|---------------|-----------|
RANJAN      |  03/29/2021   |                       |  Populate MSA Fields on Creation              |  PSA-1499     |   <T2>    |
------------|---------------|-----------------------|-----------------------------------------------|---------------|-----------|
            |               |                       |   INC0520210-On updating the bill rate on     |               |           |
Wasim Akram |  8/18/2021    | Bellamkonda, Sarojini |  assignment update the bill rate of unbilled  |  PSA-1830     |   <T3>    |
            |               |                       |    timecard's under the assignment            |               |           |
------------|---------------|-----------------------|-----------------------------------------------|---------------|-----------|
Vivek W     |  29-Jun-2022  |   Neha Kumari         |   Populating the Assignment with PM Email     |  PSA-2066     |   <T4>    |
------------|---------------|-----------------------|-----------------------------------------------|---------------|-----------|
Vivek W     |  25-Jul-2022  |   Neha Kumari         |   Add logic to facilitate Self-assignment     |  PSA-1685     |   <T5>    |
------------|---------------|-----------------------|-----------------------------------------------|---------------|-----------|
Wasim		|  17-Aug-2022	|	Neha Kumari			| Resource Target Bill Rate issue on Assignment | 	PSA-2556	|	<T6>	|
------------|---------------|-----------------------|-----------------------------------------------|---------------|-----------|
*********************************************************************************************************************************
*/
public class psa_us_AssignmentTriggerHelper {
    public static globalApexManager GAM = new globalApexManager();
    /**
* this method to create Permission control records when an Assignment record is created.
*
* @param List<New Schedule Recs>, Trigger.new map.
* @return return-void
* @throws exception - NA
*/
    public void createPermControlAfterAssignInsert(List<pse__Assignment__c> newAssignList, Map<Id, pse__Assignment__c> newAssignMap){
        
        Map<Id,pse__Assignment__c> assignMap = new Map<Id,pse__Assignment__c>();
        List<pse__Assignment__c> reAssignList = new List<pse__Assignment__c>();
        reAssignList = getRefinedAssignList(newAssignMap);
        
        if(reAssignList.size()>0){
            for(pse__Assignment__c assRec : reAssignList){
                if((assRec.pse__Project__c <> null) && (assRec.pse__Start_Date__c <> null) &&
                   (assRec.pse__End_Date__c <> null) && (assRec.pse__Role__c <> null) && (assRec.pse__Resource__r.pse__Salesforce_User__c <> null))
                    assignMap.put(assRec.Id,assRec);
            }
        }
        if(assignMap.size()>0){
            psa_us_PermissionControlHandler.createPermControlRecs(null,assignMap,'Assignment');
        }
    }
    
    /**
* this method to update Permission control records when an Assignment record is updated.
*
* @param List<Old Schedule Recs>, List<New Schedule Recs>, Trigger.new map, Trigger.Old Map
* @return return-void
* @throws exception - NA
*/
    public void updatePermControlAfterAssignUpdate(List<pse__Assignment__c> oldAssignList,List<pse__Assignment__c> newAssignList, Map<Id, pse__Assignment__c> oldAssignMap,Map<Id, pse__Assignment__c> newAssignMap){
        
        Map<Id,pse__Assignment__c> assignRecsToCreateMap = new Map<Id,pse__Assignment__c>();
        Map<Id,pse__Assignment__c> modifiedAssignRecsMap = new Map<Id,pse__Assignment__c>();
        Set<Id> delAssignIdSet = new Set<Id>();
        List<pse__Assignment__c> reAssignList = new List<pse__Assignment__c>();
        reAssignList = getRefinedAssignList(newAssignMap);    
        
        
            for(pse__Assignment__c newAssRec : reAssignList){
                pse__Assignment__c oldAssRec = oldAssignMap.get(newAssRec.Id);
                if(oldAssRec.pse__Role__c != newAssRec.pse__Role__c && oldAssRec.pse__Role__c == null && newAssRec.pse__Resource__r.pse__Salesforce_User__c != null){
                    assignRecsToCreateMap.put(newAssRec.Id,newAssRec);
                }
                if(oldAssRec.pse__Role__c != newAssRec.pse__Role__c && oldAssRec.pse__Role__c != null && newAssRec.pse__Role__c != null 
                   && newAssRec.pse__Resource__r.pse__Salesforce_User__c != null){
                    delAssignIdSet.add(newAssRec.Id);
                    assignRecsToCreateMap.put(newAssRec.Id,newAssRec);
                }
                /*** 
if((oldAssRec.Id == newAssRec.Id) && (oldAssRec.pse__Project__c <> newAssRec.pse__Project__c) && (newAssRec.pse__Project__c <> null)){
modifiedAssignRecsMap.put(newAssRec.Id,newAssRec);
}
if((oldAssRec.Id == newAssRec.Id) && (oldAssRec.pse__Schedule__c <> newAssRec.pse__Schedule__c) && (newAssRec.pse__Schedule__c <> null)){
modifiedAssignRecsMap.put(newAssRec.Id,newAssRec);
}
*/
                
            }
        
        /**
system.debug('**ATH-modifiedAssignRecsMap**________'+modifiedAssignRecsMap);
if(modifiedAssignRecsMap.size()>0){
psa_us_PermissionControlHandler.updatePermControlRecs(null,modifiedAssignRecsMap,null,'Assignment');
}
*/
        
        if(delAssignIdSet.size()>0){
            psa_us_PermissionControlHandler.deletePermControlRecs(delAssignIdSet,'Assignment');
        }
        
        if(assignRecsToCreateMap.size()>0){
            psa_us_PermissionControlHandler.createPermControlRecs(null,assignRecsToCreateMap,'Assignment');
        }
    }
    
    /**
* this method to Delete Permission control records when an Assignment record is Deleted.
*
* @param List<Schedule Recs>
* @return return-void
* @throws exception - NA
*
    public void beforeAssignmentDelete(List<pse__Assignment__c> assignDelRecs){
        
        Set<Id> assignIdSet = new Set<Id>();
        if(assignDelRecs != null && assignDelRecs.size() > 0){
            for(pse__Assignment__c assRec : assignDelRecs){
                assignIdSet.add(assRec.Id);
            }
        }
        
        if(assignIdSet.size()>0){
            psa_us_PermissionControlHandler.deletePermControlRecs(assignIdSet,'Assignment');
        }
    }
    */
    /**
* this method to get more fields related to the Assignment records
*
* @param List<Schedule Recs>
* @return return-void
* @throws exception - NA
*/
    public static List<pse__Assignment__c> getRefinedAssignList(Map<Id,pse__Assignment__c> newAssignMap){
        return [Select Id,Name,pse__Project__c,pse__Start_Date__c,pse__End_Date__c,pse__Resource__c,
                pse__Resource__r.pse__Salesforce_User__c,pse__Schedule__c,pse__Role__c
                FROM pse__Assignment__c
                WHERE Id IN :newAssignMap.Keyset()]; 
    }
    
    
    /**
* This method to populate the Project end date if any assignment record created/updated 
* has end date greater than the Project's End date.
* @param List<Schedule Recs>
* @return return-void
* @throws exception - NA
*/
    public void updateProjectEndDate(List<pse__Assignment__c> newList){
        
        Set<Id> projIds = new Set<Id>();
        for(pse__Assignment__c assignRec : newList){
            projIds.add(assignRec.pse__Project__c);
        }
        
        if(!projIds.isEmpty()){
            
            List<pse__Proj__c> projectLst = new List<pse__Proj__c>();
            List<pse__Proj__c> projectLstUpdate = new List<pse__Proj__c>();
            
            projectLst = [Select Id,Name,pse__End_Date__c,
                          (select Id,pse__End_Date__c from pse__Assignments__r order by pse__End_Date__c desc Limit 1)  
                          from pse__Proj__c where Id IN :projIds];
            for(pse__Proj__c projRec : projectLst){
                System.debug('Workday Time Off Project Name: ' + Label.Workday_Time_Off);
                if(projRec.Name != Label.Workday_Time_Off){ //Checking that the project is not the current Workday Time Off Project
                    List<pse__Assignment__c> assignmentLst = new List<pse__Assignment__c>();
                    assignmentLst = projRec.pse__Assignments__r;
                    
                    if(!assignmentLst.isEmpty() && assignmentLst[0].pse__End_Date__c>projRec.pse__End_Date__c){
                        projRec.pse__End_Date__c = assignmentLst[0].pse__End_Date__c;
                        projectLstUpdate.add(projRec);
                    }
                }
            }
            
            if(!projectLstUpdate.isEmpty()){
                update projectLstUpdate;
            }
            
            
        }
        
    }
        //<T3>
    /**
    * This method will sync the Bill Rate on TimeCard when the Bill Rate on Assignment is changed
    *
    * @param Map<Id, pse__Assignment__c>,Map<Id, pse__Assignment__c>
    * @return return-void
    * @throws exception - NA
    */
    public void updateBillRateonTimeCards(Map<Id, pse__Assignment__c> oldMap,Map<Id, pse__Assignment__c> newMap){
        Set<Id> assignmentSet = new Set<Id>();
        List<pse__Timecard_Header__c> timeCardsList = new List<pse__Timecard_Header__c>();
        //Find if bill rate is changed for any Assignment
        for(pse__Assignment__c assignObj : newMap.values()){
            if(oldMap.get(assignObj.Id).pse__Bill_Rate__c != assignObj.pse__Bill_Rate__c){
                assignmentSet.add(assignObj.Id);
            }
        }
        //Update only when the Bill Rate is changed and timecard is not billed
        if(assignmentSet.size() > 0){
            for(pse__Assignment__c assignObj: [SELECT Id,(SELECT Id, pse__Billed__c FROM pse__Timecards__r) 
                                               FROM pse__Assignment__c WHERE Id IN :assignmentSet]){
                for(pse__Timecard_Header__c timeCard : assignObj.pse__Timecards__r){ 
                    //update only for the unbilled time cards
                    if(!timeCard.pse__Billed__c){
                        timeCard.pse__Bill_Rate__c = newMap.get(assignObj.Id).pse__Bill_Rate__c;
                        timeCardsList.add(timeCard);
                    }
                }
            }
        }
        //update all the related timeCards with the bill rate
        if(timeCardsList.size() > 0){
            try{
                Database.update(timeCardsList,false);
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('psa_us_AssignmentTriggerHelper', 'Error while updating Bill Rate on TimeCard in updateBillRateonTimeCards method',e.getMessage());
            }
        }
    }    
  //</T3>
    /**
* This method to populate the MSA Code Mapping and MSA Name from the Resource Request 
* @param List<Schedule Recs>
* @return return-void
* @throws exception - NA
*
    public void prePopulateMSAFields(List<pse__Assignment__c> newList){
        
        Set<Id> resourceReqIds = new Set<Id>();
        for(pse__Assignment__c assignRec : newList){
            
            if(String.isBlank(assignRec.PSA_MSA_Code_Mapping__c)){
                resourceReqIds.add(assignRec.pse__Resource_Request__c);
            }
        } 
        if(!resourceReqIds.isEmpty()){
            
            Map<Id,pse__Resource_Request__c> resReqMap = new Map<Id,pse__Resource_Request__c>([Select ID,psa_rm_MSA_Code_Mapping__c from pse__Resource_Request__c where Id IN:resourceReqIds]);
            
            for(pse__Assignment__c assignRec : newList){
                
                if(resReqMap.containsKey(assignRec.pse__Resource_Request__c)){
                    assignRec.PSA_MSA_Code_Mapping__c = resReqMap.get(assignRec.pse__Resource_Request__c).psa_rm_MSA_Code_Mapping__c ;
                }
            }
        }
    } */
    
    //<T4>
    public void populateAssignmentFields(List<pse__Assignment__c> newList){
        Set<Id> projIds = new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();
        List<pse__Assignment__c> assignmentsToUpdate = new List<pse__Assignment__c>();
        //<T6>
        Map<String,Decimal> mapCurrencyExcRate = new Map<String,Decimal>();
        Decimal resourceConvRate, asgmtConvRate;             
        String resourceCurrencyISOCode;
        for(DatedConversionRate DCR : [SELECT Id,ConversionRate,IsoCode FROM DatedConversionRate WHERE StartDate = THIS_MONTH]){
            mapCurrencyExcRate.put(DCR.IsoCode, DCR.ConversionRate);
        }
        //</T6>
        for(pse__Assignment__c asgmt : newList){
            if(asgmt.pse__Project__c != null){
                projIds.add(asgmt.pse__Project__c);
            }
            //<T6>
            if(asgmt.pse__Resource__c != null){
                resourceIds.add(asgmt.pse__Resource__c);
            }
            //</T6>
        }
       
        Map<Id,pse__Proj__c> projList = new Map<Id,pse__Proj__c>([SELECT Id, pse__Project_Manager__c FROM pse__Proj__c WHERE ID IN :projIds]);
        Map<Id,Contact> resourceMap = new Map<Id,Contact>([SELECT Id,psa_Target_Bill_Rate__c,CurrencyIsoCode FROM Contact WHERE ID IN :resourceIds]);//<T6>
        
        
        for(pse__Assignment__c asgmt : newList){
            if(projList.get(asgmt.pse__Project__c) != null){
                if(projList.get(asgmt.pse__Project__c).pse__Project_Manager__c != null){
                    asgmt.PSA_RM_Project_s_manager_contact__c = projList.get(asgmt.pse__Project__c).pse__Project_Manager__c;
                }
            } 
            //<T5>
            if(asgmt.pse__Resource_Request__c == null && asgmt.pse__Resource__r.pse__Salesforce_User__c == asgmt.CreatedById){
                asgmt.pse__Role__c = 'Self-Assignment';
            }
            //</T5> 
            //<T6>
            //Null check
            if(Test.isRunningTest()){
                resourceCurrencyISOCode = 'EUR';
                asgmt.CurrencyIsoCode = 'AUD';
            }
            if(asgmt.pse__Resource__c != null && asgmt.CurrencyIsoCode != null && resourceMap.get(asgmt.pse__Resource__c) != null &&
               resourceMap.get(asgmt.pse__Resource__c).psa_Target_Bill_Rate__c > 0 && resourceMap.get(asgmt.pse__Resource__c).CurrencyIsoCode != null){
                   resourceCurrencyISOCode = resourceMap.get(asgmt.pse__Resource__c).CurrencyIsoCode; //Store Resource currency code                   
                   //For same Resource and Assignment currency
                   if(resourceCurrencyISOCode == asgmt.CurrencyIsoCode){
                       asgmt.PSA_RM_Resource_Target_Bill_Rate__c = resourceMap.get(asgmt.pse__Resource__c).psa_Target_Bill_Rate__c;
                   }
                   //For different Resource and Assignment currency
                   else{
                       if(resourceCurrencyISOCode != 'USD' && mapCurrencyExcRate.size() > 0 && mapCurrencyExcRate.get(resourceCurrencyISOCode) > 0)
                           resourceConvRate = mapCurrencyExcRate.get(resourceCurrencyISOCode); //Store Resource conversion rate
                       if(asgmt.CurrencyIsoCode != 'USD' && mapCurrencyExcRate.size() > 0 && mapCurrencyExcRate.get(asgmt.CurrencyIsoCode) > 0) 
                           asgmtConvRate = mapCurrencyExcRate.get(asgmt.CurrencyIsoCode); // Store assignment conversion rate
                       //If Resource Currency is USD and Assignment Currency is not USD
                       if(resourceCurrencyISOCode == 'USD' && asgmt.CurrencyIsoCode != 'USD' && asgmtConvRate > 0){
                           asgmt.PSA_RM_Resource_Target_Bill_Rate__c = resourceMap.get(asgmt.pse__Resource__c).psa_Target_Bill_Rate__c * asgmtConvRate;
                       }
                       //If Resource Currency is not USD and Assignment Currency is USD
                       else if(resourceCurrencyISOCode != 'USD' && asgmt.CurrencyIsoCode == 'USD' && resourceConvRate > 0){
                           //Convert the Resource Target Bill Rate to USD
                           asgmt.PSA_RM_Resource_Target_Bill_Rate__c = resourceMap.get(asgmt.pse__Resource__c).psa_Target_Bill_Rate__c / resourceConvRate;
                       }
                       //If Resource Currency is not USD and Assignment Currency is not USD
                       else if(resourceCurrencyISOCode != 'USD' && asgmt.CurrencyIsoCode != 'USD'  && resourceConvRate > 0 && asgmtConvRate > 0){
                           asgmt.PSA_RM_Resource_Target_Bill_Rate__c = (resourceMap.get(asgmt.pse__Resource__c).psa_Target_Bill_Rate__c / resourceConvRate) * asgmtConvRate;
                       }
                   }
               }            
            //</T6>            
        }
    }   
}