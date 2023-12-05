public with sharing class LinkUtilityHandler {

    @AuraEnabled
    public static List<Link_Utility__mdt> getLinkUtilitiesMTD(){
        List<Link_Utility__mdt> lstLinkUtilities = [Select Id,Group_Name__c,Icon__c,Sort_Order__c from Link_Utility__mdt order by Sort_Order__c ASC];

        return lstLinkUtilities;
    }
    
    @AuraEnabled
    public static List<LinkUtilityWrapperClass> getLinkItems(String appName, String userId) {
		Boolean boolApplicationAllowed;
		Boolean boolShouldAdd;
		Boolean boolCanPerformAllOperations;
		Boolean boolHasAllAccess = false;
		LinkUtilityWrapperClass objWrappedLink;
        Set<String> skills = new Set<String>();
        Set<String> publicGroups = new Set<String>();
		Set<String> setApplications = new Set<String>();
		List<String> lstApplications = new List<String>();
        Map<Id, LinkUtilityWrapperClass> lstLinkItems = new Map<Id, LinkUtilityWrapperClass>();

		//We get the permission set groups from the current user.
		for(PermissionSetAssignment objRecord : [SELECT PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND 
				(PermissionSetGroup.DeveloperName = 'CSMSuccess_Manager' OR PermissionSetGroup.DeveloperName = 'CSM_SuccessOperations') LIMIT 1]) {
			boolHasAllAccess = true;
		}
        
        //Query the list of skills assigned to the logged in user
        for(ProfileSkillUser s: [Select Id,ProfileSkill.Name from ProfileSkillUser where UserId =: userId]){
            skills.add(s.ProfileSkill.Name);
        }

        //Query the list of Public Groups assigned to the logged in user
        for(GroupMember g: [Select Group.Name from GroupMember where UserOrGroupId =: userId]){
            publicGroups.add(g.Group.Name);
        }

		//Now we get the current App Name.
		for(UserAppInfo objUserApplicationInformation : [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1]) {
			for(AppDefinition objApplicationDefinition : [SELECT DurableId, Label FROM AppDefinition Where DurableId = :objUserApplicationInformation.AppDefinitionId LIMIT 1]) {
				setApplications.add(objApplicationDefinition.Label);
			}
		}
        if(Test.isRunningTest()){
            setApplications.add('Success');
        }
		if(!setApplications.isEmpty()) {
			lstApplications.addAll(setApplications);
			appName = String.join(lstApplications, ';');
		}

		//Now we get the links.
        for(Link__c l : [Select Id,Name,Link_URL__c,Target__c,Group_Name__c,Skills__c,Public_Groups__c,Applications__c, CreatedById from Link__c where ((Start_date__c = null and End_date__c = null) or 
				(Start_date__c != null and End_date__c = null) or (End_date__c > TODAY and Start_date__c < TODAY)) and (Applications__c INCLUDES (:appName) OR Applications__c = NULL) 
				order by Order__c, LastModifiedDate ASC]){
			boolShouldAdd = false;
			boolApplicationAllowed = false;
			boolCanPerformAllOperations = false;
            
            //Precendence-1: links without applications specified will be added to the list.
            if(l.Applications__c == null) {
                boolApplicationAllowed = true;
            } else if(!lstApplications.isEmpty()) {
				for(String strApplicationNameRecord : l.Applications__c.split(';')) {
					for(String strApplicationName : lstApplications) {
						if(strApplicationNameRecord == strApplicationName) {
							boolApplicationAllowed = true;
						}
					}
				}
            }

			//If the user has access to the Application.
			if(boolApplicationAllowed) {

				//Now we check the Skills and Groups.
				if(l.Skills__c == null && l.Public_Groups__c == null) {
					boolShouldAdd = true;
				} else {
					if(l.Skills__c != null && !skills.isEmpty()) {
						for(String skill : skills){
							if(l.Skills__c.contains(skill)){
								boolShouldAdd = true;
								break;
							}
						}
					}
					if(!boolShouldAdd && l.Public_Groups__c != null && !publicGroups.isEmpty()) {
						for(String publicGroup : publicGroups) {
							if(l.Public_Groups__c.contains(publicGroup)){
								boolShouldAdd = true;
								break;
							}
						}
					}
				}

				//We check if the user belongs to the group, so he can perform operations.
				if(l.Public_Groups__c != null && !publicGroups.isEmpty()) {
					for(String publicGroup : publicGroups) {
						if(l.Public_Groups__c.contains(publicGroup)){
							boolCanPerformAllOperations = true;
							break;
						}
					}
				}
	
				//Now we display "Personal" group only if the links were created by the current user.
				if(l.Group_Name__c.toLowerCase() == 'personal' && l.CreatedById != UserInfo.getUserId()) {
					boolShouldAdd = false;
				}
	
				//We add the data to the list.
				if(boolShouldAdd && !lstLinkItems.containsKey(l.Id)) {
	
					//If it is a super user.
					if(boolHasAllAccess || l.Group_Name__c.toLowerCase() == 'personal') {
						boolCanPerformAllOperations = true;
					}
	
					//Now we generate the wrapper.
					objWrappedLink = new LinkUtilityWrapperClass();
					objWrappedLink.objLink = l;
					objWrappedLink.boolCanAdd = boolCanPerformAllOperations;
					objWrappedLink.boolCanDelete = boolCanPerformAllOperations;
					objWrappedLink.boolCanEdit = boolCanPerformAllOperations;
					objWrappedLink.boolHasAllAccess = boolHasAllAccess;
					lstLinkItems.put(l.Id, objWrappedLink);
				}
			}
        }
        return lstLinkItems.values();
    }
    
    /*
     Method Name : getLinkDeleted
     Description : This method deletes the given link record.
     Parameters  : String, called from getLinkDeleted, strRecordId Record Id.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getLinkDeleted(List<Link__c> lstRecords) {
		delete lstRecords;
	}
}