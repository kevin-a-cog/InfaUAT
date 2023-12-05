/*
Class:          OpportunityTeamMemberTriggerHandler

@Author:        Thejaswini Sattenapalli
@Created Date:  07/09/2017
@Description:   handler class for OpportunityTeamMember triggers
*/
/*
Change History
***********************************************************************************************
ModifiedBy          Date            Requested By        Description                         Tag
***********************************************************************************************
Vivek Warrier       06-Jun-2019     Liz Matthews        Commenting out logic related to 
                                                        Secondary Opportunity               <T01>
***********************************************************************************************
*/
/*
------------------------------------------------------------------------------< T01>
//Changes done
------------------------------------------------------------------------------</T01>
*/
public class OpportunityTeamMemberTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    private static String noOpportunity = Label.stage_value_for_NoOpportunity;
    
    /*//<T01>
    Method Name : updateOppotunityTeamOnSecondaryInsert,
    * @param triggerNew - list of new OpportunityTeamMember
    * @return return-void
    * @throws exception - try/catch + use handleError method on DML operation
    
    * this method call from 'opportunityTeamMemberAfterInsert' Trigger on OpportunityTeamMember Object
    * in this method we are update the OpportunityTeamMembers in Secondary Opportunity,(if Secondary Opportunity available)
    * Part Of Deal Type = 'Hybird' Requirement. 
    */   
    
    /*public static void updateOppotunityTeamOnSecondaryInsert(List<OpportunityTeamMember> triggerNew){ 
        try{ 
            // create a set of Opportunity Id's  
            set<id> setOfOpportunityId = new set<Id>();
            // do a for loop on OpportunityTeamMember and add Opportunity Id to the setOfOpportunityId 
            for(OpportunityTeamMember otm: triggerNew){
                setOfOpportunityId.add(otm.OpportunityId);
            }
            
            // create a list of OpportunityTeamMember for Insert new team member to secondary opportunity   
            List<OpportunityTeamMember> lstOppTeamMembersForInsert = new List<OpportunityTeamMember>();
            // create a map of opportunity Id and Opportunity 
            map<id,opportunity> mapOpportunityIdWiseOpportunity = new map<id,opportunity>();
            // fill the map with opportunity id along with oppoertunity where ID In :setOfOpportunityId  
            for(opportunity opp : [select id, Name, Related_Opportunity__c, (select id,Name,Deal_Type__c,Primary_or_Secondary__c,StageName from Opportunities2__r where StageName !=: noOpportunity) from opportunity WHERE Id IN : setOfOpportunityId AND Primary_or_Secondary__c = 'Primary']){
                mapOpportunityIdWiseOpportunity.put(opp.Id, opp);   
            }
            
            // play a for loop on OpportunityTeamMember and clone the OpportunityTeamMember from Primary Opportunity.
            for(OpportunityTeamMember otm: triggerNew){
                opportunity primaryOpportunity = mapOpportunityIdWiseOpportunity.get(otm.OpportunityId);
                if(primaryOpportunity != null){
                    for(opportunity secOpp:primaryOpportunity.Opportunities2__r){
                        OpportunityTeamMember cloneTeamMembers = otm.clone(false, true, false, false);
                        //system.debug('secOpp-->' + secOpp);
                        cloneTeamMembers.OpportunityId = secOpp.Id;
                        lstOppTeamMembersForInsert.add(cloneTeamMembers);
                    }
                }     
            }
            
            // check if the size of lstOppTeamMembersForInsert List greater then 0 then Insert the OpportunityTeamMember
            // for secondary Opportunity.     
            GAM.CreateLogs('updateOppotunityTeamOnSecondaryInsert',lstOppTeamMembersForInsert,'lstOppTeamMembersForInsert: ');
            if(lstOppTeamMembersForInsert.size() > 0){
                Database.SaveResult[] insertTMList = Database.insert(lstOppTeamMembersForInsert, false);
                // if Exception come then call the handleError() method for handel it    
                if(insertTMList.size()>0){
                    handleError(insertTMList);
                }
            }    
            GAM.InsertDebugLogs();
        }catch(Exception e){
            GAM.CreateExceptionRecords('updateOppotunityTeamOnSecondaryInsert', 'Error from updateOppotunityTeamOnSecondaryInsert: ', e.getMessage());
        }
    }*/
    
    /*
    Method Name : updateOppotunityTeamOnSecondaryUpdate,
    * @param triggerNew - list of new OpportunityTeamMember
    * @return return-void
    * @throws exception - try/catch + use handleError method on DML operation
    
    * this method call from 'opportunityTeamMemberAfterUpdate' Trigger on OpportunityTeamMember Object
    * in this method we are update the OpportunityTeamMembers in Secondary Opportunity,(if Secondary Opportunity available)
    * Part Of Deal Type = 'Hybird' Requirement. 
    */     
    /*public static void updateOppotunityTeamOnSecondaryUpdate(List<OpportunityTeamMember> triggerNew){ 
        try{ 
            // create a set of Opportunity Id's     
            set<id> setOfOpportunityId = new set<Id>();
            // do a for loop on OpportunityTeamMember and add Opportunity Id to the setOfOpportunityId    
            for(OpportunityTeamMember otm: triggerNew){
                setOfOpportunityId.add(otm.OpportunityId);
            }
                
            // create a list of OpportunityTeamMember for Update new team member to secondary opportunity    
            List<OpportunityTeamMember> lstOppTeamMembersForUpdate = new List<OpportunityTeamMember>();
            // create a map of opportunity Id and Opportunity  
            map<id,opportunity> mapOpportunityIdWiseOpportunity = new map<id,opportunity>();
            
            set<Id> setOfSecondaryOppId = new set<Id>();
            // fill the mapOpportunityIdWiseOpportunity Map with opportunity id and opportunity [primary Opportunity]   
            // fill the set with opportunity id in the for loop where opportunity Id In :setOfOpportunityId 
            
            for(opportunity opp : [select id,(select id,Name,Deal_Type__c,Primary_or_Secondary__c,StageName from Opportunities2__r where StageName != :noOpportunity) from opportunity WHERE Id IN : setOfOpportunityId AND Primary_or_Secondary__c = 'Primary']){
                mapOpportunityIdWiseOpportunity.put(opp.Id, opp);   
                for(opportunity oppSec:opp.Opportunities2__r){
                    setOfSecondaryOppId.add(oppSec.Id);
                } 
            }
            // create another map for secondary Opportunity id Wise Opportunity      
            map<id,opportunity> mapSecondaryOppIDWiseOpportunity = new map<id,opportunity>();
            // add values to Map Where Opportunity Id IN : setOfSecondaryOppId   
            for(opportunity oppSec : [select id,(select id,CurrencyIsoCode,Name,OpportunityAccessLevel,OpportunityId,PhotoURL,TeamMemberRole,Title,UserId from OpportunityTeamMembers) from opportunity WHERE Id IN : setOfSecondaryOppId]){
                mapSecondaryOppIDWiseOpportunity.put(oppSec.Id, oppSec);
            }
            
            // play a for loop on OpportunityTeamMember List (Trigger.New)    
            for(OpportunityTeamMember otm: triggerNew){
                // check if mapOpportunityIdWiseOpportunity contains key OpportunityTeamMember.Opportunity Id then    
                if(mapOpportunityIdWiseOpportunity.containsKey(otm.OpportunityId)){
                    // get the Primary Opportunity From Map with Key OpportunityTeamMember.Opportunity Id  
                    opportunity oppPrimary = mapOpportunityIdWiseOpportunity.get(otm.OpportunityId);
                    // if primary Opportunity have secondary Opportunity List then 
                    if(oppPrimary.Opportunities2__r != null){
                        // play a for loop on secondary Opportunity List which is store in oppPrimary.Opportunities2__r 
                        for(opportunity opp2 : oppPrimary.Opportunities2__r){
                            if(mapSecondaryOppIDWiseOpportunity.containsKey(opp2.Id)){
                                // if the mapSecondaryOppIDWiseOpportunity Map contains secondary Opportunity Id then 
                                // get the secondary Opportunity Record    
                                opportunity oppSecondary = mapSecondaryOppIDWiseOpportunity.get(opp2.Id);    
                                if(oppSecondary.OpportunityTeamMembers != null){
                                    // check if OpportunityTeamMembers is not null on secondary Opportunity then play a for loop on Opportunity Team Members
                                    for(OpportunityTeamMember otm2 : oppSecondary.OpportunityTeamMembers){
                                        // match the Opportunity Team Member with unique UserId  
                                        if(otm.UserId == otm2.UserId){
                                            // set the secondary Opp. TeamMemberRole with the primary Opportunity TeamMemberRole  
                                            otm2.TeamMemberRole =  otm.TeamMemberRole;
                                            // add Secondary Opportunity In List to Update it.      
                                            lstOppTeamMembersForUpdate.add(otm2);  
                                            break;
                                        }      
                                    }
                                }    
                            }
                        } 
                    } 
                }
            }
            // check if lstOppTeamMembersForUpdate greater then 0 then update the lstOppTeamMembersForUpdate List
            if(lstOppTeamMembersForUpdate.size() > 0){
                Database.SaveResult[] updateTMList = Database.update(lstOppTeamMembersForUpdate, false);
                // if Exception come then call the handleError() method for handel it  
                if(updateTMList.size()>0){
                    handleError(updateTMList);
                }
            }  
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('updateOppotunityTeamOnSecondaryUpdate', 'Exception Error From OpportunityTeamMemberTriggerHandler || updateOppotunityTeamOnSecondaryUpdate-->', e.getMessage());
        } 
    }*/
    
    /*
    Method Name : updateOppotunityTeamOnSecondaryDelete,
    * @param triggerNew - list of Old Deleted OpportunityTeamMember
    * @return return-void
    * @throws exception - try/catch + use handleError method on DML operation
    
    * this method call from 'opportunityTeamMemberAfterDelete' Trigger on OpportunityTeamMember Object
    * in this method we are Delete the OpportunityTeamMembers in Secondary Opportunity,(if Secondary Opportunity available)
    * Part Of Deal Type = 'Hybird' Requirement. 
    */   
    /*public static void updateOppotunityTeamOnSecondaryDelete(List<OpportunityTeamMember> triggerOld){ 
        try{  
            // create a set of Opportunity Id's   
            set<id> setOfOpportunityId = new set<Id>();
            // do a for loop on OpportunityTeamMember and add Opportunity Id to the setOfOpportunityId       
            for(OpportunityTeamMember otm: triggerOld){
                setOfOpportunityId.add(otm.OpportunityId);
            }
            // create a list of OpportunityTeamMember for Delete team member to secondary opportunity  
            List<OpportunityTeamMember> lstOppTeamMembersForDelete = new List<OpportunityTeamMember>();
            // create a map of opportunity Id and Opportunity   
            map<id,opportunity> mapOpportunityIdWiseOpportunity = new map<id,opportunity>();
            // create a set of Secondary Opportunity Id's
            set<Id> setOfSecondaryOppId = new set<Id>();
            // fill the mapOpportunityIdWiseOpportunity Map with opportunity id and opportunity [primary Opportunity]   
            // fill the set with secondary opportunity id in the for loop where opportunity Id In :setOfOpportunityId 
            
            for(opportunity opp : [select id,(select id,Name,Deal_Type__c,Primary_or_Secondary__c,StageName from Opportunities2__r where StageName != :noOpportunity ) from opportunity WHERE Id IN : setOfOpportunityId AND Primary_or_Secondary__c != 'Primary']){
                mapOpportunityIdWiseOpportunity.put(opp.Id, opp);   
                for(opportunity oppSec:opp.Opportunities2__r){
                    setOfSecondaryOppId.add(oppSec.Id);
                } 
            }
            // create a map for store Opportunity ID and Seconday Opportunity        
            map<id,opportunity> mapSecondaryOppIDWiseOpportunity = new map<id,opportunity>();
            // fill the Map mapSecondaryOppIDWiseOpportunity In for Loop Where Id In setOfSecondaryOppId  
            for(opportunity oppSec : [select id, Name, (select id,CurrencyIsoCode,Name,OpportunityAccessLevel,OpportunityId,PhotoURL,TeamMemberRole,Title,UserId from OpportunityTeamMembers) from opportunity WHERE Id IN : setOfSecondaryOppId]){
                mapSecondaryOppIDWiseOpportunity.put(oppSec.Id, oppSec);
            }
            
            // create a for loop on OpportunityTeamMember List Deleted Records        
            for(OpportunityTeamMember otm: triggerOld){
                if(mapOpportunityIdWiseOpportunity.containsKey(otm.OpportunityId)){
                    // check if mapOpportunityIdWiseOpportunity map contains deleted OpportunityId then 
                    // get the opportunity Record from mapOpportunityIdWiseOpportunity using OpportunityId as a key
                    opportunity oppPrimary = mapOpportunityIdWiseOpportunity.get(otm.OpportunityId);
                    if(oppPrimary.Opportunities2__r != null){
                        // check if primary Opportunity Having Secondary Opportunity Records Then 
                        // play a for loop on Secondary (child) opportunity List which is store in oppPrimary.Opportunities2__r 
                        for(opportunity opp2 : oppPrimary.Opportunities2__r){
                            if(mapSecondaryOppIDWiseOpportunity.containsKey(opp2.Id)){
                                // get the seconday opportunity From the Map  
                                opportunity oppSecondary = mapSecondaryOppIDWiseOpportunity.get(opp2.Id);
                                
                                if(oppSecondary.OpportunityTeamMembers != null){
                                    // if secondary Opportunity Team Member not Equal to Null then play a for loop on OpportunityTeamMembers 
                                    for(OpportunityTeamMember otm2 : oppSecondary.OpportunityTeamMembers){
                                        // match the Opportunity Team Member with unique UserId 
                                        if(otm.UserId == otm2.UserId){
                                            // add OpportunityTeamMember in the list of  lstOppTeamMembersForDelete     
                                            lstOppTeamMembersForDelete.add(otm2);  
                                            break;
                                        }      
                                    }
                                }    
                            }
                        } 
                    } 
                }
            }
            // check if lstOppTeamMembersForDelete greater then 0 then Delete the lstOppTeamMembersForDelete List
            if(lstOppTeamMembersForDelete.size() > 0){
                Database.DeleteResult[] DeleteResultTMEList = Database.delete(lstOppTeamMembersForDelete, false);
                if(DeleteResultTMEList.size()>0){
                    // if Exception come then call the handleError() method for handel it . 
                    handleError(DeleteResultTMEList);
                }
            }
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('updateOppotunityTeamOnSecondaryDelete', 'Exception Error From OpportunityTeamMemberTriggerHandler || updateOppotunityTeamOnSecondaryDelete-->', e.getMessage());
        }
    }
    //</T01>
    */
    
    
    /*
    Method Name : handleError,
    * @param saveResult - list of Database.Saveresult
    * @return return-void
    * @throws exception - N/A
    
    * for Exceptions_Log__c creation [for update and insert] 
    */ 
    
    // @Developer ---- 20/18/2017  // for Exceptions_Log__c creation [for update and insert] 
    /*public static void handleError(List<Database.Saveresult> saveResult){
        string error;
        for (Database.SaveResult sr : saveResult) {
            if (!sr.isSuccess()){
                
                for(Database.Error err : sr.getErrors()){
                    error = error + err.getMessage();
                }
            }
            
        } 
        GAM.CreateExceptionRecords('OpportunityTeamMemberTriggerHandler', 'Error From OpportunityTeamMemberTriggerHandler: ' ,error);
    }*/
    
    /*
    Method Name : handleError [Override],
    * @param saveResult - list of Database.DeleteResult
    * @return return-void
    * @throws exception - N/A
    
    * for Exceptions_Log__c creation  [for delete] [override]
    */
    
    /*public static void handleError(List<Database.DeleteResult> deleteResult){
        string error;
        for (Database.DeleteResult sr : deleteResult) {
            if (!sr.isSuccess()){
                
                for(Database.Error err : sr.getErrors()){
                    error = error + err.getMessage();
                }
            }
            
        }
        GAM.CreateExceptionRecords('OpportunityTeamMemberTriggerHandler', 'Error From OpportunityTeamMemberTriggerHandler while deleting record: ' ,error);
    }*/
}