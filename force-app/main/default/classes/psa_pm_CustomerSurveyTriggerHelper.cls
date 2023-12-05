/*
@created by       : MAHESH GANTI
@created on       : 10/27/2020
@Purpose          : To Handle Customer Survey Trigger Logic.
@Testclass        : 
@JIRA             : 
Change History
***********************************************************************************************************************************************
ModifiedBy              Date            Requested By        Description                                           Jira No.       Tag
***********************************************************************************************************************************************
Pavithra V		        01-12-2021        -                Update the 'Last Customer Survey Created' format 	  PSA-929		T01
Praveen sharma          02-10-2021        -                The primary contact name in the survey-Customer Contact field PSA-936
Rohit Niranjanamath     18-09-2023      PSA Nov Build 23   Tech Debt: Code refactoring to align with Unit of Work Framework     T03
*/
public class psa_pm_CustomerSurveyTriggerHelper {
    //<T03>
    private static List<Schema.SObjectType> MY_SOBJECTS =
        new Schema.SObjectType[] {
                pse__Proj__c.SObjectType
                };
    public static UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
    //<T03>
    public static globalApexManager GAM = new globalApexManager();
    
    /**
    * Method to populate survey field values before inserting the survey record.
    *
    * @param List<CustomerSurveyRecs>.
    * @return return-void
    * @throws exception - NA
    */
    public void populateSurveyFieldsBeforeInsert(List<psa_pm_IPS_Customer_Survey__c> newList){
        system.debug('**CSTH-newList**________'+newList);

        for(psa_pm_IPS_Customer_Survey__c surRec : newList){

            surRec.psa_pm_Sum_Of_Project_Ratings__c = 0;
            surRec.psa_pm_Count_Of_Project_Ratings__c = 0;
            
            //Populating Count_Of_Project_Ratings__c field. This field is the count of project rating fields which are having value >0
            if(surRec.psa_pm_understood_project_requirements__c <> null && surRec.psa_pm_understood_project_requirements__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_Overall_competence_and_experience__c <> null && surRec.psa_pm_Overall_competence_and_experience__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_Managed_engagement_initial_close__c <> null && surRec.psa_pm_Managed_engagement_initial_close__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_Overall_communication_n_teamwork__c <> null && surRec.psa_pm_Overall_communication_n_teamwork__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_deliver_on_your_expectations__c <> null && surRec.psa_pm_deliver_on_your_expectations__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_knowledge_transfer_and_coaching__c <> null && surRec.psa_pm_knowledge_transfer_and_coaching__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_estimating_and_meeting_deadlines__c <> null && surRec.psa_pm_estimating_and_meeting_deadlines__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            if(surRec.psa_pm_Rate_our_Velocity_methodology__c <> null && surRec.psa_pm_Rate_our_Velocity_methodology__c > 0){
                surRec.psa_pm_Count_Of_Project_Ratings__c++; 
            }
            

            //Populating Sum_Of_Project_Ratings__c field. This field is populated by summing all the project rating fields if they are available.
            if(surRec.psa_pm_understood_project_requirements__c <> null){
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_understood_project_requirements__c; 
            }
            if(surRec.psa_pm_Overall_competence_and_experience__c <> null){   
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_Overall_competence_and_experience__c; 
            }
            if(surRec.psa_pm_Managed_engagement_initial_close__c <> null){ 
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_Managed_engagement_initial_close__c; 
            }
            if(surRec.psa_pm_Overall_communication_n_teamwork__c <> null){     
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_Overall_communication_n_teamwork__c; 
            }
            if(surRec.psa_pm_deliver_on_your_expectations__c <> null){       
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_deliver_on_your_expectations__c; 
            }
            if(surRec.psa_pm_knowledge_transfer_and_coaching__c <> null){     
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_knowledge_transfer_and_coaching__c; 
            }
            if(surRec.psa_pm_estimating_and_meeting_deadlines__c <> null){     
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_estimating_and_meeting_deadlines__c; 
            }
            if(surRec.psa_pm_Rate_our_Velocity_methodology__c <> null){       
                surRec.psa_pm_Sum_Of_Project_Ratings__c+=surRec.psa_pm_Rate_our_Velocity_methodology__c; 
            }    
        }
    }

    /**
    * Method to populate Project Manager and Consultant fields based on ProjectId and Timeperiods
    *
    * @param List<CustomerSurveyRecs>.
    * @return return-void
    * @throws exception - NA
    */
    public void populateSurveyConsultantsBeforeInsert(List<psa_pm_IPS_Customer_Survey__c> newList){
        Map<Id,pse__Time_Period__c> timePeriodMap = new Map<Id,pse__Time_Period__c>();
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>();
        Map<Id,psa_pm_Project_Contact__c> projContMap = new Map<Id,psa_pm_Project_Contact__c>();
        Set<Id> tpIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();

        for(psa_pm_IPS_Customer_Survey__c surRec : newList){
            if(surRec.psa_pm_Time_Period_Quarter__c <> null){
                tpIdSet.add(surRec.psa_pm_Time_Period_Quarter__c);
            }
            if(surRec.psa_pm_Project__c <> null){
                projIdSet.add(surRec.psa_pm_Project__c);
            }
        }
        system.debug('**CSTH-tpIdSet**________'+tpIdSet);
        system.debug('**CSTH-projIdSet**________'+projIdSet);
        
        if(tpIdSet.size()>0){
            timePeriodMap = getTimePeriods(tpIdSet);
        }
        if(projIdSet.size()>0){
            projMap = getProjects(projIdSet);
            projContMap = getProjContMap(projIdSet);

        }
        system.debug('**CSTH-timePeriodMap**________'+timePeriodMap);
        system.debug('**CSTH-projMap**________'+projMap);
        //**Looping through the standard field **/
        for (psa_pm_IPS_Customer_Survey__c c : newList) {
           
            if (c.psa_pm_Project__c <> null && projContMap.containsKey(c.psa_pm_Project__c) ) {
                c.psa_pm_Customer_Contact__c = projContMap.get(c.psa_pm_Project__c).psa_pm_Contact__c;
            }
        }
        if(projMap.size()>0 && timePeriodMap.size()>0){
            Date tcMinStart = null;
            Date tcMaxEnd = null;
            Set<Id> projIds = new Set<Id>();

            // used to maintain project to survey-wrapper mapping
            Map<String, SurveyWrapper[]> projIdSurveys = new Map<String, SurveyWrapper[]>();
            for (psa_pm_IPS_Customer_Survey__c c : newList){
                SurveyWrapper[] projSurveys = projIdSurveys.get(c.psa_pm_Project__c) != null ? projIdSurveys.get(c.psa_pm_Project__c) : new SurveyWrapper[]{};
                system.debug('**CSTH-projSurveys**________'+projSurveys);
                
                pse__Time_Period__c timePd = timePeriodMap.get(c.psa_pm_Time_Period_Quarter__c);
                system.debug('**CSTH-timePd**________'+timePd);
                
                if (c.psa_pm_Project__c <> null && timePd <> null){
                    SurveyWrapper sw = new SurveyWrapper(c.psa_pm_Project__c, timePd.pse__start_date__c, timePd.pse__end_date__c, c);
                    system.debug('**CSTH-sw**________'+sw);
                    pse__Proj__c projectInfo = projMap.get(c.psa_pm_Project__c);
                    system.debug('**CSTH-projectInfo**________'+projectInfo);
                    
                    if (projectInfo <> null && projectInfo.pse__Project_Manager__c <> null){
                        sw.addProjectManager(projectInfo.pse__Project_Manager__c);
                    }

                    projSurveys.add(sw);
                    projIdSurveys.put(c.psa_pm_Project__c, projSurveys);
                    projIds.add(c.psa_pm_Project__c);
                    tcMinStart = (tcMinStart == null || tcMinStart > timePd.pse__start_date__c) ? timePd.pse__Start_Date__c : tcMinStart;
                    tcMaxEnd = (tcMaxEnd == null || tcMaxEnd > timePd.pse__end_date__c) ? timePd.pse__end_Date__c : tcMaxEnd;
                }
                else{
                    c.addError('Missing required fields for customer survey.');
                }
            }

            if (tcMinStart != null && tcMaxEnd != null && !projIds.isEmpty()){
                pse__Timecard__c[] tcs = [SELECT pse__Resource__c, pse__Start_Date__c, pse__End_Date__c, pse__Project__c
										    FROM pse__Timecard__c
										    WHERE pse__Project__c in :projIds
										    AND pse__Start_Date__c >= :tcMinStart
										    AND pse__End_Date__c <= :tcMaxEnd];
                
                system.debug('**CSTH-tcs**________'+tcs);
                if (tcs != null && tcs.size() > 0){
                    for (pse__Timecard__c tc : tcs){
                        // lookup survey by project/end date
                        SurveyWrapper[] projSurveys = projIdSurveys.get(tc.pse__project__c);
                        system.debug('**CSTH-projSurveys**________'+projSurveys);
                        if (projSurveys != null && projSurveys.size() > 0){
                            for (SurveyWrapper surveyWrapper : projSurveys){
                                if (surveyWrapper.needsSurveyConsultants() &&
                                    tc.pse__start_date__c >= surveyWrapper.timePdStartDate &&
                                    tc.pse__end_date__c <= surveyWrapper.timePdEndDate){
                                    surveyWrapper.addConsultant(tc.pse__Resource__c);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    /**
    * Method to populate survey field values before update of the survey record.
    *
    * @param List<OldSurveyRecs>, List<NewSurveyRecs>,Map<oldId,OldSurveyRec>,Map<newId,newSurveyRec>
    * @return return-void
    * @throws exception - NA
    */
    public void populateSurveyFieldsBeforeUpdate(List<psa_pm_IPS_Customer_Survey__c> oldList,List<psa_pm_IPS_Customer_Survey__c> newList, Map<Id,psa_pm_IPS_Customer_Survey__c> oldMap, Map<Id,psa_pm_IPS_Customer_Survey__c> newMap){

        List<IPS_Customer_Survey_Line_Item__c> csLineItemRecs = new List<IPS_Customer_Survey_Line_Item__c>([SELECT id,Name,Consultant__c,Consultant__r.Name, IPS_Customer_Survey__c,
                                                                                                            Consultant_overall_abilities_score__c,Adoption_Consultant_Overall_Ability__c 
                                                                                                            FROM IPS_Customer_Survey_Line_Item__c WHERE IPS_Customer_Survey__c IN :newMap.Keyset()]);

        system.debug('**CSTH-csLineItemRecs**'+csLineItemRecs);    
        if(csLineItemRecs.size()>0){
            for(IPS_Customer_Survey_Line_Item__c lineItemRec : csLineItemRecs){
                //Base If check to process the logic
                if((newMap.containsKey(lineItemRec.IPS_Customer_Survey__c)) && (lineItemRec.Consultant__c !=null) && (lineItemRec.Consultant_overall_abilities_score__c!=null || lineItemRec.Adoption_Consultant_Overall_Ability__c!=null)){
                    
                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_1__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_1__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C1_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C1_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C1_Overall_Abilities_Score__c= lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_2__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_2__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C2_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C2_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C2_Overall_Abilities_Score__c= lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_3__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_3__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C3_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C3_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C3_Overall_Abilities_Score__c= lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_4__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_4__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C4_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C4_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C4_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_5__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_5__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C5_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C5_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C5_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_6__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_6__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C6_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C6_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C6_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_7__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_7__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C7_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C7_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C7_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_8__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_8__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C8_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C8_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C8_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_9__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_9__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C9_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C9_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C9_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }

                    if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_10__c <> null && newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_Consultant_10__c == lineItemRec.Consultant__c){
                        newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C10_Overall_Abilities_Score__c = lineItemRec.Consultant_overall_abilities_score__c;
                    
                        if(newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C10_Overall_Abilities_Score__c == null){              
                            newMap.get(lineItemRec.IPS_Customer_Survey__c).psa_pm_C10_Overall_Abilities_Score__c = lineItemRec.Adoption_Consultant_Overall_Ability__c ;
                        }                       
                    }
                }
            }
        }
    }

    /**
    * Method to update Parent-Project fields on Creation of a Customer Survey Record.
    *
    * @param lstNew - list<SurveyRecs>, Map<Id,SurveyRec>
    * @return return-void
    * @throws exception - NA
    */
    public void updateProjectAfterSurveyInsert(List<psa_pm_IPS_Customer_Survey__c> newList, Map<Id,psa_pm_IPS_Customer_Survey__c> newMap){
        
        system.debug('**CSTH-newList**'+newList);
        system.debug('**CSTH-newMap**'+newMap);      
        Set<Id> projIdSet = new Set<Id>();
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        List<pse__Proj__c> projListToupdate = new List<pse__Proj__c>();
        for(psa_pm_IPS_Customer_Survey__c csRec : newList){
            if(csRec.psa_pm_Project__c <> null){
                projIdSet.add(csRec.psa_pm_Project__c);
            }
        }
        system.debug('**CSTH-projIdSet**'+projIdSet);
        if(projIdSet.size()>0){
            projList = [SELECT id,Name,pse_pm_Last_Customer_Survey_Created__c FROM pse__Proj__c WHERE Id IN :projIdSet];
            system.debug('**CSTH-projList**'+projList);
            string formatDate = getFormattedCurrentDate();
            system.debug('**CSTH-formatDate**'+formatDate);
            for(pse__Proj__c projRec : projList){
                projRec.pse_pm_Last_Customer_Survey_Created__c = formatDate;
                uow.registerDirty(projRec);//T03
            }
        }
        // system.debug('**CSTH-projListToupdate**'+projListToupdate);
        // if(projListToupdate.size()>0){
        //     try{
        //     update projListToupdate;
        //     }catch(Exception e){
        //         GAM.CreateLogs('CLASS: psa_pm_CustomerSurveyTriggerHelper | METHOD: updateProjectAfterSurveyInsert', projListToupdate , 'projListToupdate');
        //     }
        //     GAM.InsertDebugLogs();
        // }UOW
    }

    public void callCommitMethod(List<SObject> newList){
       
        try{
            uow.commitWork();
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('Error caused from psa_pm_CustomerSurveyTriggerHelper class', e.getMessage(),newList[0].id);
        }
    }


    public static Map<Id,pse__Time_Period__c> getTimePeriods(Set<Id> timePeriodIds){
        Map<Id,pse__Time_Period__c> timePeriodMap = new Map<Id,pse__Time_Period__c>([SELECT Id,Name,pse__start_date__c,pse__end_date__c FROM pse__Time_Period__c WHERE Id IN :timePeriodIds]);
        
        return timePeriodMap;
    }

    public static Map<Id,pse__Proj__c> getProjects(Set<Id> projIds){
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([SELECT Id,Name,pse__Project_Manager__c FROM pse__Proj__c WHERE Id IN :projIds]);
        
        return projMap;
    }

    public static Map<Id,psa_pm_Project_Contact__c> getProjContMap(Set<Id> projIds){
        Map<Id,psa_pm_Project_Contact__c> projMap = new Map<Id,psa_pm_Project_Contact__c>();
        
        List<psa_pm_Project_Contact__c> projContactList = new List<psa_pm_Project_Contact__c>([SELECT Id,Name,psa_pm_Contact__c,psa_pm_Contact_Role__c,psa_pm_Project__c
                                                                                                FROM psa_pm_Project_Contact__c 
                                                                                                WHERE psa_pm_Project__c IN :projIds and psa_pm_Primary_Contact__c = true order by createddate desc]);
        
        if(projContactList.size()>0){
            for(psa_pm_Project_Contact__c projCon : projContactList){
                if(projCon.psa_pm_Contact_Role__c == 'PS Customer' && projCon.psa_pm_Contact__c <> null
                        && projMap.get(projCon.psa_pm_Project__c) == null){
                    projMap.put(projCon.psa_pm_Project__c,projCon);
                }
            }
        }
        return projMap;
    }


    /**
    * Inner Class to store Consultant and Project Manager details.
    *
    * @param NA
    * @return NA
    * @throws exception - NA
    */

    public class SurveyWrapper{
        public String projectId {get; set;}
        public Date timePdStartDate {get; set;}
        public Date timePdEndDate {get; set;}
        public Set<String> consultants {get; set;}
        public String projectManager {get; set;}
        public psa_pm_IPS_Customer_Survey__c customerSurvey {get; set;}

        public SurveyWrapper(String projId, Date startDate, Date endDate, psa_pm_IPS_Customer_Survey__c customerSurvey){
            this.projectId = projId;
            this.timePdStartDate = startDate;
            this.timePdEndDate = endDate;
            this.customerSurvey = customerSurvey;
            this.consultants = new Set<String>();
        }

        public SurveyWrapper addProjectManager(String pmresourceId){
            if (String.isEmpty(this.customerSurvey.psa_pm_Project_Manager__c) && String.isNotEmpty(pmresourceId)){
                this.customerSurvey.psa_pm_Project_Manager__c = pmresourceId;
            }
            return this;
        }

        public SurveyWrapper addConsultant(String resourceId){
            if (!consultants.contains(resourceId)){
                consultants.add(resourceId);
                psa_pm_IPS_Customer_Survey__c csurvey = this.customerSurvey;
                for (Integer i = 1; i < 11; i++){
                    Id surveyContact = (Id)((SObject)csurvey).get('psa_pm_Consultant_' + i + '__c');
                    if (surveyContact == null) {
                        ((SObject)csurvey).put('psa_pm_Consultant_' + i + '__c', resourceId);
                        break;
                    }
                }
            }
            return this;
        }

        // returns true if a new consultant or project manager can be added to the customer survey
        public boolean needsSurveyConsultants(){
            return (this.customerSurvey.psa_pm_Project_Manager__c == null ||
                    this.customerSurvey.psa_pm_Consultant_1__c == null ||
                    this.customerSurvey.psa_pm_Consultant_2__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_3__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_4__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_5__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_6__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_7__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_8__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_9__c  == null ||
                    this.customerSurvey.psa_pm_Consultant_10__c == null );
        }
    }


    // will need to fetch the below methos from utils class
    public static string getFormattedCurrentDate(){
        
        string requiredFormat;
        Integer currentMonth = (System.today()).month(); 
        system.debug('**CSTH-currentMonth**'+currentMonth);
        Integer currentYear = (System.today()).year();
        system.debug('**CSTH-currentYear**'+currentYear);
        
        if(currentMonth == 1 || currentMonth == 2 || currentMonth == 3){
            requiredFormat='Q1';
        }
        else if(currentMonth == 4 ||currentMonth == 5 ||currentMonth == 6){
            requiredFormat='Q2';
        }
        else if(currentMonth == 7 ||currentMonth == 8 || currentMonth == 9){
            requiredFormat='Q3';
        }
        else if(currentMonth == 10 ||currentMonth == 11 ||currentMonth == 12){
            requiredFormat='Q4';
        }
        requiredFormat+= ' '+currentYear;/**<T01>**/
        system.debug('**CSTH-requiredFormat**'+requiredFormat);
        return requiredFormat;
    }
}