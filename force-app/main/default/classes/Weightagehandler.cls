/*
Class:          weightagehandler 
@Author:        Venky K
@Created Date:  24-Nov-2021
@Description:   Handler class for weightage rating
        
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip			01/10/2023	I2RT-7593	T01		To include relevant Cases based on if the User is a Owner 
													OR is part of Case Team.
Sandeep Duggi  10/05/2023 I2RT-9227 T02 Regression_On giving feedback for AAE case
*/

public class Weightagehandler {

	//weightagehandler  -    Constructor for weightagehandler. 
	
	public Weightagehandler (List<Weightage_Rating__c> listNewWR, List<Weightage_Rating__c> listOldWR, Map<Id, Weightage_Rating__c> wrNewMap, Map<Id,Weightage_Rating__c> wrOldMap){
		sendemail(listNewWR[0]);
	}
		
	public static void sendemail(Weightage_Rating__c weightageRating){
		Boolean isUserOwner = true;
		String curUserId = UserInfo.getUserId();
		weightageRating = [Select Id, Comments__c, Rating__c, Case__c, Case__r.CaseNumber, Case__r.OwnerId, 
								Case__r.Case_Weightage_Calc__c, Case__r.Case_Weightage__r.Weightage__c, 
								Case_Weightage__c, Case_Weightage__r.Name, Case_Weightage__r.Weightage__c
							From Weightage_Rating__c Where id = :weightageRating.Id];
		
		//T01 get the relevant list of Cases based on if the User is the Owner or part of Case Team.
		Set<Id> setCaseId = new Set<Id>();
		if(weightageRating.Case__r.OwnerId == curUserId){
			isUserOwner = true;
			for(Case cse: [Select Id From Case 
							Where OwnerId = :curUserId 
							And Status NOT IN ('Resolved', 'Closed', 'Cancelled', 'Delivered', 'Complete')]){
				setCaseId.add(cse.Id);
			}
		}else{
			isUserOwner = false;
			List<Case_Team__c> lstCaseTeam = [Select Id, Case__c, User__c, Role__c 
												From Case_Team__c 
												Where Case__c = :weightageRating.Case__c And User__c = :curUserId];
			if(!lstCaseTeam.isEmpty()){
				String role = lstCaseTeam[0].Role__c;
				lstCaseTeam = [Select Id, Case__c, User__c, Role__c 
									From Case_Team__c 
									Where User__c = :curUserId And Role__c = :role
									And Case__r.Status NOT IN ('Resolved', 'Closed', 'Cancelled', 'Delivered', 'Complete')];
				for(Case_Team__c caseTeam : lstCaseTeam){
					setCaseId.add(caseTeam.Case__c);
				}
			}
		}

		List<Case> lstCase = [Select Id, CaseNumber, Record_Type_Name__c, Case_Weightage_Calc__c, Case_Weightage__r.name, 
									Case_Weightage__r.Weightage__c, Case_Weightage__r.Full_Case_Weightage__c 
								From Case 
								Where Id in :setCaseId And (Case_Weightage__c != NULL OR Case_Weightage_Calc__c != NULL) 
								ORDER BY Case_Weightage_Calc__c DESC NULLS LAST, Case_Weightage__r.Full_Case_Weightage__c DESC NULLS LAST];                

		Integer rank = 1;
		Map<Id,Integer> mapCaseIdToRank = new Map<Id,Integer>();
		for(Case cse : lstCase){
			mapCaseIdToRank.put(cse.Id, rank++);
		}
		system.debug('@@mapCaseIdToRank'+Json.serializePretty(mapCaseIdToRank));
		String tempbody = 'Hi,';
		tempbody += '<br/>';
		tempbody += '<br/>';
        system.debug('@@@tempbody'+Json.serializePretty(tempbody));
		tempbody += 'Case prioritization view card for Case #'+weightageRating.Case__r.CaseNumber+' was rated ' +weightageRating.Rating__c+ ' by '+UserInfo.getFirstName()+' '+UserInfo.getLastName();
		tempbody += '<br/>';
        system.debug('@@@tempbody'+Json.serializePretty(tempbody));
        system.debug('Casemap@@'+Json.serializePretty(mapCaseIdToRank.get(weightageRating.Case__c)));
		tempbody += 'case '+weightageRating.Case__r.CaseNumber+ ', Weightage:' +weightageRating.Case__r.Case_Weightage_Calc__c+', Ranking:'+mapCaseIdToRank.get(weightageRating.Case__c);
    // T02 added Null check 
    if(weightageRating.Case__r.Case_Weightage__r.Weightage__c != null){
		tempbody += weightageRating.Case__r.Case_Weightage__r.Weightage__c;
    }
		tempbody += '<br/>';
		system.debug('@@@tempbody'+Json.serializePretty(tempbody));
		tempbody += 'Comments:'+weightageRating.Comments__c;
		tempbody += weightageRating.Case__r.Case_Weightage_Calc__c;
		tempbody += '<br/>';
		tempbody += '<br/>';
		
		tempbody += 'Engineers snapshot';
		tempbody += '<br/>';
		for(Case c : lstCase){
			if(c.Id != weightageRating.Case__c){
				if(c.record_type_name__c ==  'Ask An Expert'){
					tempbody += 'case '+' '+c.CaseNumber+ ', Weightage:' +c.Case_Weightage_Calc__c+', Ranking:'+mapCaseIdToRank.get(c.Id);
					tempbody += '<br/>';
					tempbody += '<br/>';
				}else {
					tempbody += 'case '+' '+c.CaseNumber+ ', Weightage:' +c.Case_Weightage_Calc__c+', Ranking:'+mapCaseIdToRank.get(c.Id);
					tempbody += c.Case_Weightage__r.Weightage__c;
					tempbody += '<br/>';
				} 
			} 
		}
		tempbody += '<br/>';
		tempbody += '<br/>';
		tempbody += 'Regards,';
		tempbody += '<br/>';
		tempbody += 'GCS.';
		System.debug(tempbody);

		String[] toAddresses = new String[] {Label.Salt_feedback_email};
		String orgwideemail = ' ';
		for(OrgWideEmailAddress oea: [Select Id From OrgWideEmailAddress Where DisplayName = 'Informatica Support']){
			orgwideemail = oea.Id;
		}
		if(String.isblank(orgwideemail)){
			orgwideemail = 'support@informatica.com';
		}

		//T01 - added prefix if the User is not the Owner of the Case.
		String subjectLine = 'Case Card Rated ' + weightageRating.Rating__c;
		if(!isUserOwner){
			subjectLine = 'Collaboration ' + subjectLine;
		}

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setOrgWideEmailAddressId(orgwideemail);
		mail.setToAddresses(toAddresses );
		mail.setSubject(subjectLine);
		mail.setHtmlBody(tempbody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}