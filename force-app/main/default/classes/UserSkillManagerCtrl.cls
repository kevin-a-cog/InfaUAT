/*

@description       : 
@author            : SF Developer
@group             : 
@last modified on  : 01-10-2021
@last modified by  : SF Developer
 
Change History
****************************************************************************************************
ModifiedBy		Date        Jira No.    Tag     Description
****************************************************************************************************
balajip			03/17/2022	I2RT-5677	T01		Rewrote the whole class
****************************************************************************************************
*/
public without sharing class UserSkillManagerCtrl {

	public class SkillType{
		@AuraEnabled public String type{get;set;}
		@AuraEnabled public Boolean assigned{get;set;}
		@AuraEnabled public Id profileSkillId{get;set;}
	}

	public class UserSkill{
		@AuraEnabled public ProfileSkillUser oProfileSkillUser{get;set;}
		@AuraEnabled public boolean pendingapproval{get;set;}
		@AuraEnabled public boolean rejected{get;set;}
	}

  	// wrapper classes 
   	public class WrapperSkillData{
		@AuraEnabled public List<UserSkill> lstUserSkill{get;set;}
		@AuraEnabled public List<Skill> lstSkill{get;set;}
	}

	public class Skill{
		@AuraEnabled public String skillName{get;set;}  
		@AuraEnabled public boolean roleBased{get;set;}  
		@AuraEnabled public List<SkillType> lstSkillType{get;set;}
	}
  
   	public class MultiPicklistWrapper{
		@AuraEnabled public string label{get;set;}
		@AuraEnabled public string value{get;set;}  
   	}
   
	// method to fetch picklist values 
	@AuraEnabled
	public static List < MultiPicklistWrapper > getselectOptions(string fld) {
		ProfileSkillUser  objObject = new ProfileSkillUser();
		system.debug('objObject --->' + objObject);
		system.debug('fld --->' + fld);
		List < MultiPicklistWrapper > allOpts = new list < MultiPicklistWrapper > ();

      
		// Get the object type of the SObject.
		Schema.sObjectType objType = objObject.getSObjectType();
		
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		
		// Get a map of fields for the SObject
		map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
		
		// Get the list of picklist values for this field.
		list < Schema.PicklistEntry > values =
			fieldMap.get(fld).getDescribe().getPickListValues();
		
		// Add these values to the selectoption list.
		for (Schema.PicklistEntry a: values) {
			MultiPicklistWrapper oMultiPicklistWrapper = new MultiPicklistWrapper();
			oMultiPicklistWrapper.label = a.getLabel();
			oMultiPicklistWrapper.value = a.getValue();
			allOpts.add(oMultiPicklistWrapper);
		}
		system.debug('allOpts ---->' + allOpts);
		//allOpts.sort();
		return allOpts;
	}

    // method to delete skill
    @AuraEnabled
    public static void removeSkill(string sRecId){
		List<ProfileSkillUser> lstSkillUser = [Select Id, Name, Status__c, UserId, ProfileSkillId, 
													Profileskill.Product_Name__c, ProfileSkill.Type__c, ProfileSkill.Domain__c
												From ProfileSkillUser Where Id = :sRecId];

		List<ProfileSkillUser> lstSkillUserToDelete = new List<ProfileSkillUser>();
		ProfileSkillUser skillUserToDelete;
		if(!lstSkillUSer.isEmpty()){
			skillUserToDelete = lstSkillUser.get(0);
			lstSkillUserToDelete.add(skillUserToDelete);

			//To check if the related Product Engineer/Specialist Skill to be deleted as well
			if(skillUserToDelete.ProfileSkill.Domain__c == 'Service Cloud' && (skillUserToDelete.ProfileSkill.Type__c == 'Product Engineer' || skillUserToDelete.ProfileSkill.Type__c == 'Product Specialist')){
				lstSkillUser = [Select Id, Name, Status__c, UserId, ProfileSkillId, 
						Profileskill.Product_Name__c, ProfileSkill.Type__c, ProfileSkill.Domain__c
						From ProfileSkillUser 
						Where UserId = :skillUserToDelete.UserId And ProfileSkill.Domain__c = 'Service Cloud' 
							And ProfileSkill.Product_Name__c = :skillUserToDelete.ProfileSkill.Product_Name__c];
				
				Integer userSkillCount = 0;
				ProfileSkillUser skillUserEngSpecialist;
				for(ProfileSkillUser skillUser : lstSkillUser){
					if(skillUser.ProfileSkill.Type__c == 'Product Engineer' || skillUser.ProfileSkill.Type__c == 'Product Specialist'){
						userSkillCount++;
					}else if(skillUser.ProfileSkill.Type__c == 'Product Engineer/Specialist'){
						skillUserEngSpecialist = skillUser;
					}
				}

				if(userSkillCount <= 1 && skillUserEngSpecialist != null){
					lstSkillUserToDelete.add(skillUserEngSpecialist);
				}
			}
		}

		try {
			DELETE lstSkillUserToDelete;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
    }

	public static String getSkillType(ProfileSkill profileSkill){
		String skillType = 'Default';
		if(String.isNotEmpty(profileSkill.Type__c)){
			skillType = profileSkill.Type__c;
		}

		return skillType;
	}

	public static String getSkillName(ProfileSkill profileSkill){
		String skillName = profileSkill.Name;
		if(String.isNotEmpty(profileSkill.Product_Name__c)){
			skillName = profileSkill.Product_Name__c;
		}
		return skillName;
	}

	public static Map<String, Map<String, ProfileSkill>> getAllProfileSkills(string sSearch){
		List<ProfileSkill> lstProfileSkill = [Select Id, Name, Type__c, Product_Name__c
												From ProfileSkill 
												Where Visible__c = true And Domain__c in ('Service Cloud', 'Knowledge')
													And Name LIKE : sSearch];

		Map<String, Map<String, ProfileSkill>> mapSkillNameToMapTypeToSkill = new Map<String, Map<String, ProfileSkill>>();
		for(ProfileSkill profileSkill : lstProfileSkill){
			String skillName = getSkillName(profileSkill);
			String skillType = getSkillType(profileSkill);
			
			Map<String, ProfileSkill> mapTypeToSkill = new Map<String, ProfileSkill>();
			if(mapSkillNameToMapTypeToSkill.containsKey(skillName)){
				mapTypeToSkill = mapSkillNameToMapTypeToSkill.get(skillName);
			}
			mapTypeToSkill.put(skillType, profileSkill);

			mapSkillNameToMapTypeToSkill.put(skillName, mapTypeToSkill);
		}

		return mapSkillNameToMapTypeToSkill;
	}

  	// fetch all avaiable profile skills to add on user profile 
    @AuraEnabled
    public static WrapperSkillData fetchProfileSkills(string sUserId, string sSearch) {
		WrapperSkillData wrapperSkillData = new WrapperSkillData();

		system.debug('sUserId---> ' + sUserId);

		String sWildCardText = '%' + sSearch + '%';
		List<ProfileSkillUser> lstPSU =  [SELECT Id, Name, EndorsementCount, ProfileSkillId, 
												ProfileSkill.Name, ProfileSkill.Product_Name__c, ProfileSkill.Type__c,
												UserId, User.Name
											FROM ProfileSkillUser
											WHERE UserId = :sUserId
												AND ProfileSkill.Domain__c IN ('Service Cloud', 'Knowledge')
											ORDER BY ProfileSkill.Name ASC];

		Map<Id, ProfileSkillUser> mapSkillIdToPSU = new Map<Id, ProfileSkillUser>();
		List<UserSkill> lstUserSkill = new List<UserSkill>();
		for(ProfileSkillUser profileSkillUser : lstPSU){
			mapSkillIdToPSU.put(profileSkillUser.ProfileSkillId, profileSkillUser);
			
			if(profileSkillUser.ProfileSkill.Type__c != 'Product Engineer/Specialist'){
				UserSkill userSkill = new UserSkill();
				userSkill.oProfileSkillUser = profileSkillUser;
				lstUserSkill.add(userSkill);	
			}
		}
		wrapperSkillData.lstUserSkill = lstUserSkill;

		Map<String, Map<String, ProfileSkill>> mapSkillNameToMapTypeToSkill = getAllProfileSkills(sWildCardText);
		Map<String, Skill> mapNameToSkill = new Map<String, Skill>();
		for(String skillName : mapSkillNameToMapTypeToSkill.keySet()){
			Map<String, ProfileSkill> mapTypeToSkill = mapSkillNameToMapTypeToSkill.get(skillName);

			Skill wsud = new Skill(); 
			if(mapNameToSkill.containsKey(skillName)){
				wsud = mapNameToSkill.get(skillName);            
			}else{
				wsud.skillName = skillName;
				wsud.roleBased = false;
				wsud.lstSkillType = new List<SkillType>();
			}
	
			for(String skillType : mapTypeToSkill.keySet()){
				ProfileSkill profileSkill = mapTypeToSkill.get(skillType);
				
				Boolean skillAssigned = false;
				if(mapSkillIdToPSU.containsKey(profileSkill.Id)){
					skillAssigned = true;
				}

				SkillType skillTypeWrapper = new SkillType();
				skillTypeWrapper.type = skillType;
				skillTypeWrapper.assigned = skillAssigned;
				skillTypeWrapper.profileSkillId = profileSkill.Id;
				wsud.lstSkillType.add(skillTypeWrapper);

				if(String.isEmpty(profileSkill.Product_Name__c)){
					wsud.roleBased = true;
				}         
			}
			mapNameToSkill.put(skillName, wsud);
		}
		wrapperSkillData.lstSkill = mapNameToSkill.values();
        
    	return wrapperSkillData;
    }

    /**
    *————————————————————————————————————————————————————
    * @Description: When user adds product skill (Engineer/PS), one more skill (Engineer/Specialist) will be added to his skillist
    * hasapprovalneeded is not being used but kept in the code for future enhancement
    *————————————————————————————————————————————————————
    * @param    inputresponse, hasApprovalNeeded, sUserId
    * @return   void
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static void addNewProfileSkillUser(String inputresponse, Boolean hasApprovalNeeded, Id sUserId){
      	try{
			system.debug('oProfileSkillUserData-----> ' +  inputresponse);
			
			//Deserialize input parameter and add the skill if the user does not have it
			List<Skill> lstSkillUserData = (List<Skill>)JSON.deserialize(inputresponse,List<Skill>.class);

			Map<Id, ProfileSkillUser> mapSkillIdToPSU = new Map<Id, ProfileSkillUser>();
			for(ProfileSkillUser psu: [Select Id, ProfileSkillId, ProfileSkill.Name, ProfileSkill.Type__c, ProfileSkill.Product_Name__c
											From ProfileSkillUser Where UserId = :sUserId]){
				mapSkillIdToPSU.put(psu.ProfileSkillId, psu);
				System.debug('existing skill name:' + psu.ProfileSkill.Name);
			}

			List<ProfileSkillUser> lstPSUToInsert = new List<ProfileSkillUser>();
			List<ProfileSkillUser> lstPSUToDelete = new List<ProfileSkillUser>();
			for(Skill skillUserData : lstSkillUserData){
				for(SkillType skillType : skillUserData.lstSkillType){
					if(skillType.assigned){
						if(!mapSkillIdToPSU.containsKey(skillType.profileSkillId)){
							ProfileSkillUser psu = new ProfileSkillUser();
							psu.ProfileSkillId = skillType.profileSkillId;
							psu.UserId = sUserId;
							lstPSUToInsert.add(psu);
						}
					}else{
						if(mapSkillIdToPSU.containsKey(skillType.profileSkillId)){
							lstPSUToDelete.add(mapSkillIdToPSU.get(skillType.profileSkillId));
						}
					}
				}
			}

			if(!lstPSUToInsert.isEmpty()){
				insert lstPSUToInsert;
			}

			if(!lstPSUToDelete.isEmpty()){
				delete lstPSUToDelete;
			}
		}
		catch (Exception e) { 
			system.debug('selectedname'+e.getmessage()+','+e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
    }
}