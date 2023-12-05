/*Change History
 ****************************************************************************************************************************
 Modified By			Date			Jira No.		Description					                                    Tag
 *****************************************************************************************************************************
 Narpavi Prabu          01/03/2023     AR-3113       Automated survey to be sent only if there has not been any 
 													 manual survey sent already     									T01
 Chaitanya T			10-Nov-2023	   AR-3549       Chatter post to tag CSM logic is now changed to get it from 
 													 Plan Teams if plan is present else get it from Account CSM			T02
 */
public without sharing class CsmEngagementTriggerHelper  implements Queueable{
    static Id GEMEngSRecTypeID = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId(); 
    static Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
    static Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();


 	 /*
	 Method Name : 	engagementBeforeInsert
	 Description :	helper method on before insert
	 Parameters	 :  List<Engagement__c> newEngList        
	 Return Type : 	n/a
	 */
	public static void engagementBeforeInsert(List<Engagement__c> newEngagementList){
		populateDevActiveEngagedStartTime(newEngagementList,false,null);
		populateOpptyDetails(newEngagementList);
        
        /** Check the VS/JS Eligliblity for Engagement **/
        List<Engagement__c> IPSEngagementList = new List<Engagement__c>();
        for(Engagement__c eng: newEngagementList){
            if(eng.RecordTypeId == IPSJumpStartRT){
                IPSEngagementList.add(eng);
            }
        }
        if(IPSEngagementList?.size()>0){
            checkVAJSEligiblity(IPSEngagementList);
        }
    }

	/*
	 Method Name : 	engagementBeforeUpdate
	 Description :	helper method on before Update
	 Parameters	 :  List<Engagement__c> newEngList        
	 Return Type : 	n/a
	 */
	public static void engagementBeforeUpdate(List<Engagement__c> newEngagementList, map<id,Engagement__c> oldMap){
		List<Engagement__c> updatedEngagementList = new List<Engagement__c>();
		Map<Id,Engagement__c> rejectedEngagementMap = new Map<Id,Engagement__c>();
		populateDevActiveEngagedStartTime(newEngagementList,true,oldMap);
        supportEscalation(newEngagementList, oldMap);
		for(Engagement__c eng : newEngagementList){
			//Assign the Approver as the Owner of CST Engagement
			if(eng.Status__c == 'Accepted' && oldMap.get(eng.Id).Status__c != 'Accepted' && eng.RecordTypeId == CSTEngagementRT){
				if(eng.OwnerId <> UserInfo.getUserId()){
					eng.OwnerId = UserInfo.getUserId();
				}
			}
			//Update the Oppty and Contract details when Renewal Oppty is changed
			if(eng.Opportunity__c <> oldMap.get(eng.Id).Opportunity__c && eng.RecordTypeId == CSTEngagementRT){	
				updatedEngagementList.add(eng);
			}
			if(eng.Status__c == 'Close without Engagement' && oldMap.get(eng.Id).Status__c != 'Close without Engagement' && eng.RecordTypeId == CSTEngagementRT){
				rejectedEngagementMap.put(eng.Id,eng);
			}
		}
		if(updatedEngagementList?.size()>0){
			populateOpptyDetails(updatedEngagementList);
		}
		/*if(rejectedEngagementMap?.size()>0){
			checkApprovalRejectComments(rejectedEngagementMap);
		}*/
	}

	/*public static void checkApprovalRejectComments(Map<Id,Engagement__c> rejectedEngagementMap){
		List<ProcessInstance> instances = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :rejectedEngagementMap.keySet()];
		Map<Id,Id> EngProcessMap = new Map<Id,Id>();
		List<Id> Ids = New List <Id>();
		for(ProcessInstance pi:instances){
			EngProcessMap.put(pi.TargetObjectId,pi.Id); 
			Ids.add (pi.Id);
		}

		List<ProcessInstanceStep> instancesSteps = [select Comments,ProcessInstanceId from ProcessInstanceStep where ProcessInstanceId in :Ids];
		Map<Id,String> EngProcessStepMap = new Map<Id,String>();
		for(ProcessInstanceStep pis:instancesSteps){
			EngProcessStepMap.put (pis.ProcessInstanceId, pis.Comments);
		}

		for(Engagement__c eng: rejectedEngagementMap.values()){
			if(EngProcessStepMap.get(EngProcessMap.get(eng.Id))==null){
				eng.addError('Please enter comments while rejecting');
			}else{
				eng.Closing_Notes__c = EngProcessStepMap.get(EngProcessMap.get(eng.Id));
			}
		}
	}*/
	
   
	
	/*
	 Method Name : 	engagementAfterInsert
	 Description :	helper method on after insert
	 Parameters	 :  List<Engagement__c> newEngagementList,      
	 Return Type : 	n/a
	 */
	public static void engagementAfterInsert(List<Engagement__c> newEngagementList){ 

		notify(newEngagementList, null); 
        
        //Check if the engagement is IPS Jumpstart and if Eligible for VA/JS
        Set<Id> engagementIdSet = new Set<Id>();
        Set<Id> approvalEngagementSet = new Set<Id>();

		List<Engagement__c>  englist = new List<Engagement__c>();
		Set<Id> csawithoutPlans = new Set<Id>();
		List<Id> csatoFavorite = new List<Id>();
		List<Engagement__c> csatoconsumeinternalEU = new List<Engagement__c>();
		Set<Id> commentOnCreate = new Set<Id>();
        
        //Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
        for(Engagement__c eng:[Select Id, RecordTypeId,Status__c,Plan__c,Plan__r.Override_Eligibility__c,Plan__r.COE_Group__c, VA_JS_Eligible__c, Account__c, OwnerId,Engagement_Id__c,Title__c,Primary_Contact__c,AEM_EC_Id__c,Requested_By_Group__c,Engagement_Units__c,CSM_Summary__c, Milestone__r.Name,Engagement_Model__c,Is_Internal_Engagement__c from Engagement__c where Id in:newEngagementList]){
          if(IPSJumpStartRT<> null && IPSJumpStartRT == eng.RecordTypeId && (eng.Plan__r.Override_Eligibility__c == true || (eng.VA_JS_Eligible__c == true && eng.Plan__r.Override_Eligibility__c == false) || eng.Status__c == 'Approved') && eng.Plan__r.COE_Group__c <>'PC2IICS' ){
              engagementIdSet.add(eng.Id);
            }
		}

		for(Engagement__c eng:newEngagementList){
            if(eng.Status__c == 'Submitted for Approval'){
                approvalEngagementSet.add(eng.Id);
            }
			//<T01>
			if(CSTEngagementRT <> null && CSTEngagementRT == eng.RecordTypeId){
				if(eng.Plan__c <> null){
					englist.add(eng);
					if(eng.Engagement_Model__c=='Repeatable' && eng.Requested_By_Group__c=='Customer'){
						csawithoutPlans.add(eng.Id);
					}
				}
				else{
					csawithoutPlans.add(eng.Id);
				}

				if(eng.Primary_Contact__c <> null && eng.Engagement_Model__c=='Repeatable' && !eng.Is_Internal_Engagement__c){
					csatoFavorite.add(eng.Id);
				}
				
				if(eng.Requested_By_Group__c=='CSM' && eng.Engagement_Model__c=='Repeatable'){
					csatoconsumeinternalEU.add(eng);
				}

				if(eng.Status__c == 'Submitted for Approval' && eng.Engagement_Model__c=='Repeatable' && !eng.Is_Internal_Engagement__c){
					commentOnCreate.add(eng.Id);
				}
			 }
			//</T01>
        }
        if(engagementIdSet?.size()>0){
            CSMCreateProjectfromEngagement.createIPSProject(engagementIdSet);

        }        
        if(approvalEngagementSet?.size()>0){
            String comments = '#EngType# engagement has been created by #CSMNAME# and has been sent for Approval.';
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(approvalEngagementSet, comments);
        }
		//<T01>
		if(englist?.size()>0){
			CSMSendSurveyToPlanContacts.updateengowneronplan(englist);
		}

		if(csawithoutPlans?.size()>0){
			CSMEngagementTgrHelper_WithoutSharing.chatterOnCreate(csawithoutPlans);
		}

		if(csatoFavorite?.size()>0){
			CSMEngagementTgrHelper_WithoutSharing.invokeAEMFavourite(csatoFavorite);
		}

		if(csatoconsumeinternalEU?.size()>0){
			consumeEUInternal(csatoconsumeinternalEU);
		}

		if(commentOnCreate?.size()>0){
			CSMEngagementTgrHelper_WithoutSharing.createCommentonCSACreate(commentOnCreate);
		}
		//</T01>
	}
	/*
	 Method Name : 	engagementAfterUpdate
	 Description :	helper method on after update on engagement
	 Parameters	 :  List<Engagement__c> newEngagementList,     
	 				Map<Id,Engagement__c> oldEngMap 
	 Return Type : 	n/a
	 */
	public static void engagementAfterUpdate(List<Engagement__c> newEngagementList,Map<Id,Engagement__c> oldEngMap){
		notify(newEngagementList, oldEngMap);   
        
        /** Update the Approval/Rejection status of Engagement in Plan as Plan Comments**/
        Set<Id> approvalEngagementSet = new Set<Id>();		
        Set<Id> approvedIPSEngagementSet = new Set<Id>();
        Set<Id> approvedIPSEngagementSetforProject = new Set<Id>();
        Set<Id> rejectedIPSEngagementSet = new Set<Id>();
		Set<Id> acceptedCSTEngagementSet = new Set<Id>();
		Set<Id> rejectedCSTEngagementSet = new Set<Id>();
		Set<Id> acceptedMFAEngagementSet = new Set<Id>();
		Set<Id> rejectedMFAEngagementSet = new Set<Id>();
		Set<Id> csaStatusChangedList = new Set<Id>();
		Set<Id> csaStatusAccSet = new Set<Id>();
		Set<Id> csaStatusPlanSet = new Set<Id>();//<T02>
		List<Engagement__c> csacompleted_cancelled_List = new List<Engagement__c>();

		Set<Id> completedCSTEngagementSet = new Set<Id>();

		Set<Id> planIdSet = new Set<Id>();
		Set<Id> cstEngagementIdSet = new Set<Id>();
		Set<Id> ipsEngagementIdSet = new Set<Id>();
		Set<Id> GEMSEngagementIdSet = new Set<Id>();

		Map<Id,Set<String>> planToOwnerMap = new Map<Id,Set<String>>();	
		Map<Id,Set<String>> planToOldOwnerMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> planToPMMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> planToOldPMMap = new Map<Id,Set<String>>();	//
		Map<Id,Set<String>> planToOldEMMap = new Map<Id,Set<String>>();
        //AR-1734	
		Map<Id,Engagement__c> mapEnagementForPlanComments = new Map<Id,Engagement__c>();

        List<String> cstSurveyPlanIdList = new List<String>();
		List<String> mfaSurveyPlanIdList = new List<String>();

		Set<Id> oldOwnerIdSet = new Set<Id>();
		Set<Id> oldPMIdSet = new Set<Id>();
        List<Engagement__c> englist = new List<Engagement__c>();
		


		//Get the Old Owner / PM / EM details
		for(Engagement__c eng : oldEngMap.values()){
			if(eng.RecordTypeId == CSTEngagementRT || eng.RecordTypeId == GEMEngSRecTypeID){
				if(eng.ownerId <> null){
					oldOwnerIdSet.add(eng.OwnerId);
				}
			}

			if(eng.RecordTypeId == IPSJumpStartRT){
				if(eng.Project_Manager__c <> null){
					oldPMIdSet.add(eng.Project_Manager__c);
				}
			}
		}
		Map<Id,User> oldOwnerMap;
		Map<Id,Contact> oldPMMap;
		if(oldOwnerIdSet.size()>0){
			oldOwnerMap = new Map<Id,User>([Select Id,Name,Email from User where Id in:oldOwnerIdSet]);
		}
		if(oldPMIdSet.size()>0){
			oldPMMap = new Map<Id,Contact>([Select Id,Name,Email,FirstName,LastName from Contact where Id in:oldPMIdSet]);
		}

        for(Engagement__c eng : [Select Id,Name , Owner.Name,Plan__c,Project_Manager__c,OwnerId,Project_Manager__r.Email,Owner.Email,Status__c,RecordTypeId,Plan__r.COE_Group__c,createdDate, Plan__r.OwnerId,title__c,Engagement_Id__c,Requested_By_Group__c,Account__c,Primary_Contact__c,Engagement_Units__c,Engagement_Model__c,Is_Internal_Engagement__c,RecType__c from Engagement__c where Id in:newEngagementList]){
            
			/** Actions based on Engagement Status */
            if(eng.Status__c == 'Submitted for Approval' && oldEngMap.get(eng.Id).Status__c != 'Submitted for Approval'){
                approvalEngagementSet.add(eng.Id);
            }else if(eng.Status__c == 'Approved' && oldEngMap.get(eng.Id).Status__c != 'Approved' && eng.RecordTypeId == IPSJumpStartRT){
				approvedIPSEngagementSet.add(eng.Id); 
            }else if(eng.Status__c == 'Approved' && oldEngMap.get(eng.Id).Status__c != 'Approved' && eng.RecordTypeId == IPSJumpStartRT && eng.Plan__r.COE_Group__c <>'PC2IICS'){
				approvedIPSEngagementSetforProject.add(eng.Id); 
            }else if(eng.Status__c == 'Rejected' && oldEngMap.get(eng.Id).Status__c != 'Rejected' && eng.RecordTypeId == IPSJumpStartRT){
                rejectedIPSEngagementSet.add(eng.Id);
            }else if(eng.Status__c == 'Accepted' && oldEngMap.get(eng.Id).Status__c != 'Accepted' && eng.RecordTypeId == CSTEngagementRT){
                if(eng.RecType__c=='CSA'){
					acceptedCSTEngagementSet.add(eng.Id);
				}else if(eng.RecType__c=='MFA'){
					acceptedMFAEngagementSet.add(eng.Id);
				}
            }else if(eng.Status__c == 'Close without Engagement' && oldEngMap.get(eng.Id).Status__c != 'Close without Engagement' && eng.RecordTypeId == CSTEngagementRT){
				if(eng.RecType__c=='CSA'){
					rejectedCSTEngagementSet.add(eng.Id);
				}else if(eng.RecType__c=='MFA'){
					rejectedMFAEngagementSet.add(eng.Id);
				}
            }else if (eng.Status__c == 'Completed' && oldEngMap.get(eng.Id).Status__c != 'Completed' && eng.RecordTypeId == CSTEngagementRT){
				if(planToOwnerMap.containsKey(eng.Plan__c)){
					Set<String> tempSet = planToOwnerMap.get(eng.Plan__c);
					tempSet.add(eng.Owner.Email);
					planToOwnerMap.put(eng.Plan__c ,tempSet);
				}else{
					planToOwnerMap.put(eng.Plan__c, new Set<String>{eng.Owner.Email});
				}
				//Deva: AR-1734	
				mapEnagementForPlanComments.put(eng.Id,eng);
				//Delete the CSTs from Plan Team Members after Completion
				deletePlanTeamMembers(planToOwnerMap,'CST',new Set<Id>());
			}else if( ((eng.Status__c == 'Completed' && oldEngMap.get(eng.Id).Status__c != 'Completed') ||( eng.Status__c == 'Cancelled' && oldEngMap.get(eng.Id).Status__c != 'Cancelled')) && eng.RecordTypeId == IPSJumpStartRT ){
				if(planToPMMap.containsKey(eng.Plan__c)){
					Set<String> tempSet = planToOwnerMap.get(eng.Plan__c);
					tempSet.add(eng.Project_Manager__r.Email);
					planToPMMap.put(eng.Plan__c ,tempSet);
				}else{
					planToPMMap.put(eng.Plan__c, new Set<String>{eng.Project_Manager__r.Email});
				}

				//Delete the PMs from Plan Team Members after Completion
				deletePlanTeamMembers(planToPMMap,'IPS_Jumpstart',new Set<Id>());
			} 
			
			//Deva: AR-1734	
            if((eng.Status__c == 'Closed' || eng.Status__c == 'Completed') && oldEngMap.get(eng.Id).Status__c!= eng.Status__c  && eng.RecordTypeId == IPSJumpStartRT ){
				mapEnagementForPlanComments.put(eng.Id,eng);
			}
			if((eng.Status__c == 'Closed' || eng.Status__c == 'Completed') && oldEngMap.get(eng.Id).Status__c!= eng.Status__c && eng.RecordTypeId == GEMEngSRecTypeID ){
				mapEnagementForPlanComments.put(eng.Id,eng);
			}
            //Check if the CST engagement is closed trigger the survey email
            if(eng.RecordTypeId == CSTEngagementRT && CSTEngagementRT <> null && eng.Plan__c <> null && ( eng.Status__c == 'Completed')){
            	if(eng.RecType__c == 'CSA'){
					cstSurveyPlanIdList.add(eng.Plan__c);
			   	}else if(eng.RecType__c == 'MFA'){
					mfaSurveyPlanIdList.add(eng.Plan__c);
			   	}
            }

			//<T01>
			if(eng.RecordTypeId == CSTEngagementRT && CSTEngagementRT <> null && eng.Plan__c <> null)
			{
               englist.add(eng);
            }
			//</T01>

			//When Owner is changed , remove the Old Owner from CST Team Member and add the new owner to the Plan Teams as CST
			if(eng.OwnerId <> oldEngMap.get(eng.Id).OwnerId && eng.RecordTypeId == CSTEngagementRT && CSTEngagementRT <> null){
				cstEngagementIdSet.add(eng.Id);

				/**To remove the Old Owner CST from the Plan Teams on changing the Owner of CST Engagement*/
				if(String.valueOf(oldEngMap.get(eng.Id).OwnerId).startsWith('005') && oldOwnerMap!=null){
					if(planToOldOwnerMap.containsKey(eng.Plan__c)){
						Set<String> tempSet = planToOldOwnerMap.get(eng.Plan__c);						
						tempSet.add(oldOwnerMap.get(oldEngMap.get(eng.Id).OwnerId).Email);
						planToOldOwnerMap.put(eng.Plan__c ,tempSet);
					}else{
						planToOldOwnerMap.put(eng.Plan__c, new Set<String>{oldOwnerMap.get(oldEngMap.get(eng.Id).OwnerId).Email});
					}
				}

			}

			//When the Project Manager is changed in IPS Jumpstart Engagement , remove the Old Manager from Plan Team and add the new Manager
			if(eng.Project_Manager__c <> oldEngMap.get(eng.Id).Project_Manager__c && eng.RecordTypeId == IPSJumpStartRT && IPSJumpStartRT <> null){
				ipsEngagementIdSet.add(eng.Id);

				/**To remove the Old Project Manager from the Plan Teams on changing the PM of IPS Jumpstart Enaggement*/
				if(oldEngMap.get(eng.Id).Project_Manager__c <> null && oldPMMap!=null){
					if(planToOldPMMap.containsKey(eng.Plan__c)){
						Set<String> tempSet = planToOldPMMap.get(eng.Plan__c);
						tempSet.add(oldPMMap.get(oldEngMap.get(eng.Id).Project_Manager__c).Email);
						planToOldPMMap.put(eng.Plan__c ,tempSet);
					}else{
						planToOldPMMap.put(eng.Plan__c, new Set<String>{oldPMMap.get(oldEngMap.get(eng.Id).Project_Manager__c).Email});
					}
				}
			}

			//When the Support escalation owner is changed , add them to Plan Team
			if(GEMEngSRecTypeID <> null && eng.RecordTypeId == GEMEngSRecTypeID && String.valueOf(eng.OwnerId).startsWith('005') && eng.Plan__c <> null && eng.OwnerId <> oldEngMap.get(eng.Id).OwnerId){
				GEMSEngagementIdSet.add(eng.Id);
				
				/**To remove the Old Owner EM from the Plan Teams on changing the Owner of EM Engagement*/
				if(String.valueOf(oldEngMap.get(eng.Id).OwnerId).startsWith('005')){ //String.valueOf(oldEngMap.get(eng.Id).OwnerId).startsWith('005')
					if(planToOldEMMap.containsKey(eng.Plan__c)){
						Set<String> tempSet = planToOldEMMap.get(eng.Plan__c);
						tempSet.add(oldOwnerMap.get(oldEngMap.get(eng.Id).OwnerId).Email);
						planToOldEMMap.put(eng.Plan__c ,tempSet);
					}else{
						planToOldEMMap.put(eng.Plan__c, new Set<String>{oldOwnerMap.get(oldEngMap.get(eng.Id).OwnerId).Email});
					}
				}
				
			}
			
			if(oldEngMap.get(eng.Id).Status__c != eng.Status__c && eng.RecordTypeId == CSTEngagementRT && eng.Engagement_Model__c=='Repeatable' && !eng.Is_Internal_Engagement__c){
				csaStatusChangedList.add(eng.Id);
				csaStatusAccSet.add(eng.Account__c);
				if(eng.Plan__c!=null){//<T02> start
					csaStatusPlanSet.add(eng.Plan__c);
				}//</T02> end
				if(eng.Status__c =='Completed' || eng.Status__c =='Close without Engagement'){
					csacompleted_cancelled_List.add(eng);
				}
			}
		}

		if(csaStatusChangedList?.size()>0){
			CSMEngagementTgrHelper_WithoutSharing.createCSAExternalComments(csaStatusChangedList,csaStatusAccSet,csaStatusPlanSet);//<T02>
		}

		if(csacompleted_cancelled_List?.size()>0){
			updateEUConsumptionStatus(csacompleted_cancelled_List);
		}
        
        
        if(approvalEngagementSet?.size()>0){
            String comments = '#EngType# engagement has been created by #CSMNAME# and has been sent for Approval.';
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(approvalEngagementSet, comments);
        }
        
        if(approvedIPSEngagementSet?.size()>0){
            String comments = 'IPS engagement has been approved by '+ UserInfo.getName();
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(approvedIPSEngagementSet, comments);
        }
        if(approvedIPSEngagementSetforProject?.size()>0){
            CSMCreateProjectfromEngagement.createIPSProject(approvedIPSEngagementSetforProject);
        }
        if(rejectedIPSEngagementSet?.size()>0){
            String comments = 'IPS engagement has been rejected by '+ UserInfo.getName();
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(rejectedIPSEngagementSet, comments);
        }

		if(acceptedCSTEngagementSet?.size()>0){
            String comments = 'CSA engagement has been accepted by '+ UserInfo.getName();
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(acceptedCSTEngagementSet, comments);
			//assignCSTOwnerToEngagement(acceptedCSTEngagementSet);
			//Now Add the CST Engagement owner to Plan Team
			insertTeamMembers(acceptedCSTEngagementSet , 'CST');
        }

		if(rejectedCSTEngagementSet?.size()>0){
            String comments = 'CSA engagement has been Close without Engagement by '+ UserInfo.getName();
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(rejectedCSTEngagementSet, comments);
        }		

		if(acceptedMFAEngagementSet?.size()>0){
            String comments = 'MFA engagement has been accepted by '+ UserInfo.getName();
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(acceptedMFAEngagementSet, comments);
			//Now Add the CST Engagement owner to Plan Team
			insertTeamMembers(acceptedMFAEngagementSet , 'CST');
        }

		if(rejectedMFAEngagementSet?.size()>0){
            String comments = 'MFA engagement has been Close without Engagement by '+ UserInfo.getName();
            CSMEngagementTgrHelper_WithoutSharing.createPlanCommentforApproval(rejectedMFAEngagementSet, comments);
        }
        
        if(cstSurveyPlanIdList?.size()>0){
			CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(cstSurveyPlanIdList,'CST_SURVEY');
        }
		if(mfaSurveyPlanIdList?.size()>0){
			CSMSendSurveyToPlanContacts.updateSurveyFlagOnPlanContact(mfaSurveyPlanIdList,'MFA_SURVEY');
	   	}
		//<T01>
		if(englist?.size()>0)
		{
			CSMSendSurveyToPlanContacts.updateengowneronplan(englist);
		}
		//</T01>

		if(cstEngagementIdSet?.size()>0 ){
			insertTeamMembers(cstEngagementIdSet,'CST');
		}

		if(ipsEngagementIdSet?.size()>0){
			insertTeamMembers(ipsEngagementIdSet,'IPS_Jumpstart');
		}

		if(GEMSEngagementIdSet?.size()>0){
			insertTeamMembers(GEMSEngagementIdSet,'Support_Escalation');
		}

		if(planToOldOwnerMap?.size()>0){
			deletePlanTeamMembers(planToOldOwnerMap,'CST',cstEngagementIdSet);
		}

		if(planToOldPMMap?.size()>0){
			deletePlanTeamMembers(planToOldPMMap,'IPS_Jumpstart',ipsEngagementIdSet);
		}

		if(planToOldEMMap?.size()>0){
			deletePlanTeamMembers(planToOldEMMap,'Support_Escalation',GEMSEngagementIdSet);
		}
		//Deva: AR-1734	
		if(mapEnagementForPlanComments.size()>0){
			CSMPlanCommsInternalCommentHelper.createEngagementInternalComment(mapEnagementForPlanComments);
		}

	}

	/*
	 Method Name : 	engagementAfterUpdate
	 Description :	helper method on after update on engagement
	 Parameters	 :  Map<Id,Engagement__c> oldEngMap
	 Return Type : 	n/a
	 */
	public static void engagementAfterDelete(Map<Id,Engagement__c> oldEngMap){	
		Map<Id,Set<String>> planToOldOwnerMap = new Map<Id,Set<String>>();
		Map<Id,Set<String>> planToOldPMMap = new Map<Id,Set<String>>();	
		Map<Id,Set<String>> planToOldEMMap = new Map<Id,Set<String>>();

		Set<Id> cstEngagementIdSet = new Set<Id>();
		Set<Id> ipsEngagementIdSet = new Set<Id>();
		Set<Id> GEMSEngagementIdSet = new Set<Id>();

		Set<Id> oldOwnerIdSet = new Set<Id>();
		Set<Id> oldPMIdSet = new Set<Id>();

		for(Engagement__c eng : oldEngMap.values()){
			if(eng.RecordTypeId == CSTEngagementRT || eng.RecordTypeId == GEMEngSRecTypeID){
				if(eng.ownerId <> null){					oldOwnerIdSet.add(eng.OwnerId);
				}
			}

			if(eng.RecordTypeId == IPSJumpStartRT){
				if(eng.Project_Manager__c <> null){					oldPMIdSet.add(eng.Project_Manager__c);
				}
			}
		}

		Map<Id,User> oldOwnerMap = new Map<Id,User>([Select Id,Name,Email from User where Id in:oldOwnerIdSet]);
		Map<Id,Contact> oldPMMap = new Map<Id,Contact>([Select Id,Name,Email,FirstName,LastName from Contact where Id in:oldPMIdSet]);

		for(Engagement__c eng : oldEngMap.values()){
			
				if(eng.RecordTypeId == CSTEngagementRT && CSTEngagementRT <> null){
					cstEngagementIdSet.add(eng.Id);

					/**To remove the CST from the Plan Teams on deleting the CST Engagement*/
					if(String.valueOf(eng.OwnerId).startsWith('005')){
						if(planToOldOwnerMap.containsKey(eng.Plan__c)){
							Set<String> tempSet = planToOldOwnerMap.get(eng.Plan__c);							tempSet.add(oldOwnerMap.get(eng.OwnerId).Email);							planToOldOwnerMap.put(eng.Plan__c ,tempSet);
						}else{
							planToOldOwnerMap.put(eng.Plan__c, new Set<String>{oldOwnerMap.get(eng.OwnerId).Email});
						}
					}
				}

				//To remove the Project Manager from the Plan Teams on deleting the IPS Jumpstart Engagement
				if(eng.RecordTypeId == IPSJumpStartRT && IPSJumpStartRT <> null){
					ipsEngagementIdSet.add(eng.Id);

					if(eng.Project_Manager__c <> null){
						if(planToOldPMMap.containsKey(eng.Plan__c)){
							Set<String> tempSet = planToOldPMMap.get(eng.Plan__c);							tempSet.add(oldPMMap.get(eng.Project_Manager__c).Email);							planToOldPMMap.put(eng.Plan__c ,tempSet);
						}else{
							planToOldPMMap.put(eng.Plan__c, new Set<String>{oldPMMap.get(eng.Project_Manager__c).Email});
						}
					}
				}

				//To remove the Escalation Manager from the Plan Teams on deleting the Support Escalation Engagement
				if(GEMEngSRecTypeID <> null && eng.RecordTypeId == GEMEngSRecTypeID && String.valueOf(eng.OwnerId).startsWith('005') && eng.Plan__c <> null){
					GEMSEngagementIdSet.add(eng.Id);
					
					if(String.valueOf(eng.OwnerId).startsWith('005')){
						if(planToOldEMMap.containsKey(eng.Plan__c)){
							Set<String> tempSet = planToOldEMMap.get(eng.Plan__c);							tempSet.add(oldOwnerMap.get(eng.OwnerId).Email);							planToOldEMMap.put(eng.Plan__c ,tempSet);
						}else{
							planToOldEMMap.put(eng.Plan__c, new Set<String>{oldOwnerMap.get(eng.OwnerId).Email});
						}
					}
					
				}
			}

			if(planToOldOwnerMap?.size()>0){
				deletePlanTeamMembers(planToOldOwnerMap,'CST',cstEngagementIdSet);
			}
	
			if(planToOldPMMap?.size()>0){
				deletePlanTeamMembers(planToOldPMMap,'IPS_Jumpstart',ipsEngagementIdSet);
			}
	
			if(planToOldEMMap?.size()>0){
				deletePlanTeamMembers(planToOldEMMap,'Support_Escalation',GEMSEngagementIdSet);
			}
	}
	/*
	 Method Name : 	supportEscalation
	 Description :	Validate Support escalation engagement
	 Parameters	 :  List<Engagement__c> newEngList,
	 				Map<Id,Engagement__c> oldEngMap        
	 Return Type : 	n/a
	 */
	public static void supportEscalation(List<Engagement__c> newEngList,Map<Id,Engagement__c> oldEngMap){
        String strRecordTypeName = 'Support_Escalation';
		List<String> lstClosedStatus = new List<String>{'Closed', 'Closed Duplicate'}; //I2RT-4422        
        Id recid =  Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
        for(Engagement__c eng : newEngList){            
			if(eng.recordtypeid == recid) {
                if(eng.Status__c == 'Analysis' && oldEngMap.get(eng.Id).Status__c != eng.Status__c){
                    eng.Analysis_Date__c = date.today();
                }                
				//I2RT-4422
                if(lstClosedStatus.contains(eng.Status__c) && oldEngMap.get(eng.Id).Status__c != eng.Status__c){
                    eng.Closed_On__c = system.now();
                }
				if(eng.Status__c == 'Active Wait' && oldEngMap.get(eng.Id).Status__c != eng.Status__c){
                    Boolean validchange = false;
                    for(Task t : [Select Id from Task where WhatId = :eng.Id and Status = 'Open' LIMIT 1]){
                        validchange = true;
					}
                    if(!validchange){
                        eng.addError('Atleast one open Task should be created before moving to Active Wait');
                    }
                }                
            }        
        }
    }
	
  /*
	 Method Name : checkVAJSEligiblity
	 Description :Check if the Engagement is eligible for VA/JS
	 Parameters	 : String strRiskId, record id from Risk PAge        
	 Return Type : n/a
	 */
    public static void checkVAJSEligiblity(List<Engagement__c> newList){
        Set<Id> opportunitySet = new Set<Id>();
        Set<Id> planIdSet = new Set<Id>();
        for(Engagement__c eng : newList){
            if(eng.Opportunity__c <> null){
                opportunitySet.add(eng.Opportunity__c); 
            }
            if(eng.Plan__c <> null){
               planIdSet.add(eng.Plan__c); 
            }
        }
		if(opportunitySet.size()>0){
			Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([Select Id,Name,RecordType.DeveloperName,Cloud_ABV__c,On_Prem_Subscription_ABV__c,Account.Signature_Success__c,Account.Success_Offering__c,Account.Active_Contracts_ACV_USD__c from Opportunity where Id in:opportunitySet]);
			if(planIdSet.size()>0){
				Map<Id,Plan__c> planMap = new Map<Id,Plan__c>([Select Id,Override_Eligibility__c,Account__r.Signature_Success__c from Plan__c where Id in:planIdSet]);
				for(Engagement__c eng : newList){
					//opptyMap.get(eng.Opportunity__c).RecordType.DeveloperName=='New_Sales_Opportunity' &&
					if(planMap.get(eng.Plan__c).Account__r.Signature_Success__c == true ||(opptyMap.get(eng.Opportunity__c).On_Prem_Subscription_ABV__c >=100000) ||(opptyMap.get(eng.Opportunity__c).Cloud_ABV__c >=50000)){
						eng.VA_JS_Eligible__c = true;							
					}
					if(eng.VA_JS_Eligible__c == false && planMap.get(eng.Plan__c).Override_Eligibility__c == false){
						eng.Status__c = 'Submitted for Approval';
					}
				}
			}
		}       
    }

	/*
	 Method Name : 	notify
	 Description :	helper method to send notification
	 Parameters	 :  List<Engagement__c> newEngList,
	 				Map<Id,Engagement__c> oldEngMap        
	 Return Type : 	n/a
	 */
	public static void notify(List<Engagement__c> newEngList,Map<Id,Engagement__c> oldEngMap){        
		/*List<Engagement__c> lstNewEng = new List<Engagement__c>();
		for(Engagement__c engagement : newEngList){
			if(engagement.RecordTypeId == GEMEngSRecTypeID){
				lstNewEng.add(engagement);
			}
		}
		if(lstNewEng.size() > 0){
			NotificationService.notify(lstNewEng, oldEngMap);
		}*/
    }

	 	/**
    * Method to update Dev_Active_Engaged_Start_Time__c based on status
    *
    * @param newEngagementList - list of new Engagement
    * @return return-void
    * @throws exception - NA
    */
	public static void populateDevActiveEngagedStartTime(List<Engagement__c> newEngagementList,boolean isUpdate, map<id,Engagement__c> oldMap){
		for(Engagement__c eng : newEngagementList){
          if( (eng.Status__c == 'Active Engaged' && isUpdate == false ) ||  (isUpdate &&  oldMap.get(eng.id).Status__c != eng.Status__c && eng.Status__c == 'Active Engaged') ){
			eng.Dev_Active_Engaged_Start_Time__c = system.now();
		  }		
        } 
	}
    /*
	 Method Name : populateOpptyDetails
	 Description : This method on before event to update renewal opportunity and contract on CST Engagement
	 Parameters	 : List<Engagement__c> newList, List of engagements        
	 Return Type : n/a
	 */
    public static void populateOpptyDetails(List<Engagement__c> newList){
		Set<Id> OpptyIdSet = new Set<Id>();

		for(Engagement__c eng : newList){
			if(eng.RecordTypeId == CSTEngagementRT && eng.Opportunity__c <> null){
				OpptyIdSet.add(eng.Opportunity__c);
			}
		}

		if(OpptyIdSet.size()>0){

			Map<Id,Contract> opptyToContractMap = new Map<Id,Contract>();
			//Map Contract and opportunity from engagement
			for(Contract con : [Select Id,SBQQ__Opportunity__c,SBQQ__RenewalOpportunity__c from Contract where SBQQ__Opportunity__c in:OpptyIdSet order by CreatedDate asc]){
				opptyToContractMap.put(con.SBQQ__Opportunity__c , con);
			}
			//Set engagemetnt values from contract
			for(Engagement__c eng : newList){
				if(eng.RecordTypeId == CSTEngagementRT && 
                    eng.Opportunity__c != null && 
                    opptyToContractMap.get(eng.Opportunity__c)!=null){
					eng.Renewal_Opportunity__c = opptyToContractMap.get(eng.Opportunity__c).SBQQ__RenewalOpportunity__c;				
					eng.Contract__c =  opptyToContractMap.get(eng.Opportunity__c).Id;
				}
			}
		}
	}

	 /*
	 Method Name : deletePlanTeamMembers
	 Description : This method on will delete plan team members from plan
	 Parameters	 : Map<Id,Set<String>> planToOwnerMap, String engagementType , Set<Id> currentEngagementIdSet 
	 Return Type : n/a
	 */
	public static void deletePlanTeamMembers(Map<Id,Set<String>> planToOwnerMap, String engagementType , Set<Id> currentEngagementIdSet){

		List<Plan_Team__c> delPlanTeamList = new List<Plan_Team__c>();
		String teamMemberRole = '';

		/**Select the Team Member Role based on type of engagement */
		if(engagementType == 'CST'){
			teamMemberRole = 'CSA';
		}else if(engagementType == 'IPS_Jumpstart'){
			teamMemberRole = 'IPS Project Manager';
		}else if(engagementType == 'Support_Escalation'){
			teamMemberRole = 'Escalation Manager';
		}

		//Get the Existing Open CST Engagements under this Plan
		for(Engagement__c eng : [Select Id,Plan__c,OwnerId,RecordTypeId,Owner.Email,Project_Manager__c,Project_Manager__r.Email from Engagement__c where Plan__c in :planToOwnerMap.keySet() and Status__c NOT IN ('Completed','Cancelled') and Id NOT IN :currentEngagementIdSet]){
			if(planToOwnerMap.get(eng.Plan__c)?.contains(eng.Owner.Email) && (eng.RecordTypeId == CSTEngagementRT || eng.RecordTypeId == GEMEngSRecTypeID)){
			   planToOwnerMap.get(eng.Plan__c).remove(eng.Owner.Email);
			}else if( eng.Project_Manager__c <> null && planToOwnerMap.get(eng.Plan__c)?.contains(eng.Project_Manager__r.Email) && eng.RecordTypeId == IPSJumpStartRT )	{
				planToOwnerMap.get(eng.Plan__c).remove(eng.Project_Manager__r.Email);
			}		
		}
   
		   //Delete the Plan Team Members created from Engagement
			if(planToOwnerMap.keySet()?.size()>0){			
				for(Plan_Team__c pTeam : [Select Id,User__c,User_Email__c,Plan__c from Plan_Team__c where  Role__c=:teamMemberRole and Plan__c in:planToOwnerMap.keySet() and Source__c ='Engagement']){ //Engagement_Team_Member__c = true
					if(planToOwnerMap.get(pTeam.Plan__c)?.contains(pTeam.User_Email__c) ){
						delPlanTeamList.add(pTeam);
					}				
				}
			   
			   if(delPlanTeamList?.size() >0){	
					//Now we delete the data in a queue, only if we are not already in a queue.
					if(!System.isBatch() && !System.isQueueable()) {
						System.enqueueJob(new CsmEngagementTriggerHelper(delPlanTeamList));
					} else {
						delete delPlanTeamList;
					}
			   }
		   }
	}
	globalApexManager gam = new globalApexManager();
	public List<Plan_Team__c> lstPlanTeamRecords ; 
	public CsmEngagementTriggerHelper(List<Plan_Team__c> lstPlanTeamRecords){
        this.lstPlanTeamRecords = lstPlanTeamRecords ;  
    }

		/*
	 Method Name : execute
	 Description : This method starts the queueable process.
	 Parameters	 : Object, called from execute, objContext Queueable context.
	 Return Type : None
	 */
    public void execute(QueueableContext objContext) {
		if(lstPlanTeamRecords!=null && lstPlanTeamRecords.size()>0){
			try{
				delete lstPlanTeamRecords;
			}catch(Exception e){
				gam.CreateLogs('CLASS: CsmEngagementTriggerHelper | METHOD: deletePlanTeamMembers', lstPlanTeamRecords , 'delPlanTeamList - deleting plan team members for cosmos');
			}
		}
    }
		 /*
	 Method Name : insertTeamMembers
	 Description : This method on will insert plan team members from plan
	 Parameters	 : Set<Id> engagementIdSet , String engagementType
	 Return Type : n/a
	 */
	public static void insertTeamMembers(Set<Id> engagementIdSet , String engagementType){

		Map<Id,List<String>> planToUserMap = new Map<Id,List<String>>();
		List<CSMUtilsWrapper.PlanTeam> planTeamWrapperList = new List<CSMUtilsWrapper.PlanTeam>();
		List<Plan_Team__c> planTeamToInsert = new List<Plan_Team__c>();
		Set<Id> planIdSet = new Set<Id>();

		String teamMemberRole = '';
		/**Select the Team Member Role based on type of engagement */
		if(engagementType == 'CST'){
			teamMemberRole = 'CSA';
		}else if(engagementType == 'IPS_Jumpstart'){
			teamMemberRole = 'IPS Project Manager';
		}else if(engagementType == 'Support_Escalation'){
			teamMemberRole = 'Escalation Manager';
		}	

		/**Get the Plan ID from Engagement */
		for(Engagement__c eng : [Select Id,Plan__c,OwnerId from Engagement__c where Id in:engagementIdSet]){
			if(eng.Plan__c <> null){
				planIdSet.add(eng.Plan__c);
			}			
		}

		//Get the map of existing CST/ProjectManager/EM Plan Team Members
		for(Plan_Team__c pTeam :[Select Id,User__c,User_Email__c,Plan__c,Role__c from Plan_Team__c where Plan__c in:planIdSet]){
			if(planToUserMap.containsKey(pTeam.Plan__c)){
				List<String> tempList = planToUserMap.get(pTeam.Plan__c);				tempList.add(pTeam.User_Email__c);				planToUserMap.put(pTeam.Plan__c,tempList);
			}else{
				planToUserMap.put(pTeam.Plan__c, new List<String>{pTeam.User_Email__c});	
			}
		}

		/**Check if the CST/Project Manager is already added to Plan Team and add them to Plan Teams if not already present */
		for(Engagement__c eng : [Select Id,Plan__c,OwnerId,Owner.Email,Owner.Type,Project_Manager__c,Project_Manager__r.LastName,Project_Manager__r.FirstName,Project_Manager__r.pse__Salesforce_User__c,Project_Manager__r.Email,RecType__c from Engagement__c where Id in:engagementIdSet]){
			if(engagementType == 'CST' || engagementType == 'Support_Escalation'){
				if( (planToUserMap?.get(eng.Plan__c)?.contains(eng.Owner.Email) == false || planToUserMap?.get(eng.Plan__c) == null) && eng.Owner.Type == 'User' ){
					//Create Plan Team Member from Engagement
					CSMUtilsWrapper.PlanTeam planTeamMember = new CSMUtilsWrapper.PlanTeam();
					planTeamMember.planId = eng.Plan__c;
					planTeamMember.userId = eng.OwnerId;
					planTeamMember.userEmail = eng.Owner.Email;
					if(engagementType == 'Support_Escalation'){
						planTeamMember.role = 'Escalation Manager';
					}else if(engagementType == 'CST' && eng.RecType__c == 'CSA'){					
						planTeamMember.role = 'CSA';
					}else if(engagementType == 'CST' && eng.RecType__c == 'MFA'){					
						planTeamMember.role = 'MFA';
					}
					//planTeamMember.enagagementTeamMember = true;
					planTeamMember.source = 'Engagement';
					planTeamWrapperList.add(planTeamMember);
				}
			}else if(engagementType == 'IPS_Jumpstart'){
				if(planToUserMap?.get(eng.Plan__c)?.contains(eng.Project_Manager__r.Email) == false || planToUserMap?.get(eng.Plan__c) == null){
					//Create Plan Team Member from Engagement
					CSMUtilsWrapper.PlanTeam planTeamMember = new CSMUtilsWrapper.PlanTeam();
					//if(eng.Project_Manager__r.pse__Salesforce_User__c <> null){
						planTeamMember.planId = eng.Plan__c;
						//planTeamMember.userId = eng.Project_Manager__r.pse__Salesforce_User__c;
						planTeamMember.firstName = eng.Project_Manager__r.FirstName <> null ? eng.Project_Manager__r.FirstName : eng.Project_Manager__r.LastName ;
						planTeamMember.lastName = eng.Project_Manager__r.LastName;
						planTeamMember.userEmail = eng.Project_Manager__r.Email;
						planTeamMember.role = 'IPS Project Manager';
						//planTeamMember.enagagementTeamMember = true;
						planTeamMember.source = 'Engagement';

						planTeamWrapperList.add(planTeamMember);
					//}
				}
			}
		}
		

		if(planTeamWrapperList?.size() > 0){
			planTeamToInsert = CSMUtilities.createPlanTeamMember(planTeamWrapperList);

			if(planTeamToInsert?.size()>0){
                try{
				insert planTeamToInsert;
                }catch(Exception e){
                    
                }
			}
		}
	}

	public static void processBeforeDelete (List<Engagement__c> newList)
    { 
        //do not run if the current user is sys admin, integration user, superuser
            List<Id> allIds=new List<Id>();
            Map<Id,Boolean> idvsbool=new Map<Id,boolean>();
           
            for( Engagement__c ac:newList){
                //restricts non-admins/non-superusers/CSOs from delting account
                allIds.add(ac.Plan__c);
               
               
            }
            if(!allIds.isEmpty()){
                List<Plan__c> allPlans=[Select Id,CSM_isAutoPilot__c from Plan__c where Id IN:allIds];

                for(Plan__c pc:allPlans){
                    if(pc.CSM_isAutoPilot__c==true){
                       
                        idvsbool.put(pc.Id,pc.CSM_isAutoPilot__c);
                    }
                }
            }
            if(!idvsbool.isEmpty()){
                for( Engagement__c ac:newList){
                   
                    //restricts non-admins/non-superusers/CSOs from delting account
                    Boolean val=idvsbool.get(ac.Plan__c);
                    if(val==true){
                        if(!Test.isRunningTest()){
                        ac.addError('Cannot Delete In Auto Pilot Mode');
                        }
                    }
                }
            }
        
    }


	public static void consumeEUInternal(List<Engagement__c> engList){
		for(Engagement__c eng: engList){
			EngagementUnitServiceWrapper req= new EngagementUnitServiceWrapper();

			req.boolIsInternalUser = true;
			req.idAccount = eng.Account__c;
			req.idUser = UserInfo.getUserId();
			req.intUnits = Integer.valueof(eng.Engagement_Units__c);
			req.strType = 'Success';
			req.strContextId = eng.Id;

			SuccessEngagementUnitService.consumeEngagementUnits(req);
		}
	}

	public static void updateEUConsumptionStatus(List<Engagement__c> engList){
		for(Engagement__c eng: engList){
			EngagementUnitServiceWrapper req= new EngagementUnitServiceWrapper();

			req.boolIsInternalUser = eng.Requested_By_Group__c=='CSM';
			req.strStatus = eng.Status__c=='Close without Engagement'?'Cancelled':'Completed';
			req.strContextId = eng.Id;

			SuccessEngagementUnitService.updateEngagementUnitConsumptionStatus(req);
		}
	}
	
}