/*

*******************************************************************************************************************
MODIFIED BY     MODIFIED Date   JIRA        DESCRIPTION                                                         TAG
*******************************************************************************************************************
balajip         27-Sep-2022     I2RT-7159   updated the method getAccountDetails to check for null              T01
ChaitanyaT      12-Sep-2023     AR-3383     Expansion Lead workflow added file upload for Source=Plan           T02
ChaitanyaT      02-Nov-2023     AR-3472     code refactoring for unit of work                                   T03
*/

public with sharing class ReferralManagementController {
    public static globalApexManager GAM = new globalApexManager();//<T03>
    @AuraEnabled    
    public static string getAccountDetails(String recId , String objAPIName){
        String accountId ='';
        String SupportAccountId='';

        if(objAPIName == 'Plan__c'){
           Plan__c plan = [SELECT Id, Account__c FROM Plan__c WHERE Id=:recId];
           accountId = plan.Account__c;
        }else if(objAPIName == 'Case'){
            Case cs = [SELECT Id, Support_Account__c , Support_Account__r.ParentId FROM Case WHERE Id=:recId];
            //T01 - check for null before assigning the values
            if(cs.Support_Account__c != null){
                accountId = cs.Support_Account__r.ParentId;
                SupportAccountId = cs.Support_Account__c;    
            }
        }else if(objAPIName == 'pse__Proj__c'){
            pse__Proj__c project = [SELECT Id,pse__Account__c FROM pse__Proj__c WHERE Id =:recId];
            accountId = project.pse__Account__c;
        }else{
            accountId = recId;
        }

        return accountId+';'+SupportAccountId;
    }

    @AuraEnabled
    public static string getReferralOwner(String source , String product){
        String ownerId;        
        String referralOwnerQueue;

        Map<String, Referral_Owner_Queues__mdt> referralOwnerMap = new Map<String, Referral_Owner_Queues__mdt>();
        for(Referral_Owner_Queues__mdt refOwner : [SELECT Id,Label,DeveloperName,Queue_Name__c FROM Referral_Owner_Queues__mdt]){
            referralOwnerMap.put(refOwner.DeveloperName , refOwner);
        }
        
        System.System.debug('referralOwnerMap >> '+ referralOwnerMap);
        if(source == 'Case'){
            referralOwnerQueue = referralOwnerMap.get('Case')?.Queue_Name__c;
        }else if(source == 'Project'){
            referralOwnerQueue = referralOwnerMap.get('Project')?.Queue_Name__c;
        }else if(source == 'Plan'){
            referralOwnerQueue = referralOwnerMap.get('Plan')?.Queue_Name__c;
        }else if(product == 'Professional Services'){
            referralOwnerQueue = referralOwnerMap.get('Professional_Services')?.Queue_Name__c;
        }else if(product == 'Education Services'){
            referralOwnerQueue = referralOwnerMap.get('Educational_Services')?.Queue_Name__c;
        }else{
            referralOwnerQueue = referralOwnerMap.get('Other')?.Queue_Name__c;
        }
        Group referralOwner = Database.query('SELECT Id FROM Group WHERE Type = \'Queue\' and DeveloperName  =:referralOwnerQueue LIMIT 1');

        if(referralOwner <> null){
            ownerId = referralOwner.Id;
        }
        return ownerId;

    }

    
    @AuraEnabled(Cacheable=true)
    public static iCare_Referral__c getReferralDetails(String refId){
        iCare_Referral__c referral = [SELECT Id,Status__c,OwnerId,Name,Cancellation_Reason__c,Other_Cancellation_Reason__c from iCare_Referral__c WHERE Id =:refId];
        return referral;
    }

    /** Custom Lookup search */
	@AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupSearch(String searchTerm, List<String> selectedIds, String accountId) {
        // Prepare query parameters
              
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Execute search query
            searchTerm += '*';
            List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
            Contact (Id, Name WHERE Id NOT IN :selectedIds AND AccountId =:accountId)               
            LIMIT 10
            ];
        
            String contactIcon = 'standard:contact';
            Contact[] lContact = (List<Contact>) searchResults[0];
            for (Contact con : lContact) {
                results.add(new LookupSearchResult(con.Id, 'Contact', contactIcon, con.Name, ''));
            } 
 
        // Sort all results on title
        results.sort();
 
        return results;
    }
     /*
	 Method Name : lookupSearchPlan
	 Description : This method returns the searched records of lookup for referal when source = plan.
	 Parameters	 : searchTerm,selectedIds,planId.
	 Return Type : list<LookupSearchResult>
     Added by : Harshita Joshi as part of part of AR-2509 <tag1>
	 */
     //<tag1>
	@AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupSearchPlan(String searchTerm, List<String> selectedIds, String accountId, String planId) {
      List<LookupSearchResult> results = new List<LookupSearchResult>();
     searchTerm = '%'+searchTerm+'%';
		Plan_Contact__c[] lPlanContact = [Select Id,Name,Contact_Name__c,Contact__r.Name,Contact__c FROM Plan_Contact__c WHERE Id NOT IN :selectedIds AND Plan__c =:planId AND Contact__r.Name LIKE :searchTerm ORDER BY Contact__r.Name ];

		String contactIcon = 'standard:contact';		
			for (Plan_Contact__c con : lPlanContact) {
				results.add(new LookupSearchResult(con.Contact__c, 'Contact', contactIcon, con.Contact_Name__c, ''));
			}
         return results;            
    }//</tag1>
    /*
	 Method Name : getDefaultRecords
	 Description : This method returns the dfault records of lookup for referal when source = plan.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : list<LookupSearchResult>
     Added by : Harshita Joshi as part of part of AR-2509 <tag1>
	 */
     //<tag1>
    @AuraEnabled(cacheable = false)
    public static List<LookupSearchResult> getDefaultRecords(String strRecordId) {
		String strCleanRecordId;
		List<LookupSearchResult> results = new List<LookupSearchResult>();
		String contactIcon = 'standard:contact';	
		//If we received a Risk Id.
		if(String.isNotBlank(strRecordId)) {
			//We clean the plan Id.
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for (Plan_Contact__c con : [Select Id,Name,Contact_Name__c,Contact__r.Name,Contact__c FROM Plan_Contact__c WHERE Plan__c = : strCleanRecordId ORDER BY Contact__r.Name ]) {
				results.add(new LookupSearchResult(con.Contact__c, 'Contact', contactIcon, con.Contact_Name__c, ''));
			}
		}		
		return results;	
	}//</tag1>
    
    //<T02> start
    /*
	 Method Name : deleteFile
	 Description : This method deletes the uploaded file
	 Parameters	 : Id
	 Return Type : none
	*/
    @AuraEnabled
    public static Boolean deleteFile(List<Id> fileIdsToDelete) {
        if(!fileIdsToDelete.isEmpty()){
            Database.delete(fileIdsToDelete, false);
            return true;
        }
        return false;
	}

    /*
	 Method Name : linkFiles
	 Description : This method links the uploaded file ids to the mentioned recordId
	 Parameters	 : Id - record Id for the which the files should be linked
                   List<Id> - list of uploaded file Ids
	 Return Type : none
	*/
    @AuraEnabled
    public static void linkFiles(Id recordId, List<Id> uploadedFileIds) {
		if(recordId!=null && !uploadedFileIds.isEmpty()){
            List<Schema.SObjectType> sObjects = new Schema.SObjectType[] {ContentDocumentLink.SobjectType};
            UnitOfWork uow = new UnitOfWork(sObjects);
            List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
            for(Id fileId:uploadedFileIds){
                ContentDocumentLink cdlink = New ContentDocumentLink();
                cdlink.LinkedEntityId = recordId;
                cdlink.ContentDocumentId = fileId;
                cdlink.shareType = 'V';
                cdLinkList.add(cdlink);
            }
            if(!cdLinkList.isEmpty()){
                //<T03> start
                try{
                    uow.registerNew(cdLinkList);
                    uow.commitWork();
                }catch(Exception e){
                    GAM.CreateExceptionRecords('Error caused from linking the file to the referral in the class ReferralManagementController in linkFiles method', e.getMessage(),recordId);
                }
                //</T03> end
            }
            List<Id> refIdList = new List<Id>();
            refIdList.add(recordId);
            ReferralManagementTriggerHelper.notifyOwnerOnReferralCreation(refIdList);
        }
	}

    /*
	 Method Name : isSMGGrpMember
	 Description : This method checks whether the current user belongs to the SMG queue or not
	 Parameters	 : String - source will be plan/case/project etc
	 Return Type : Boolean
	*/
    @AuraEnabled(Cacheable=true)
    public static Boolean isSMGGrpMember(String source) {
        if(source == null || source == ''){
            return null;
        }
        if(source != 'Plan'){
            return true;
        }
		Group smgGrp = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'SMG'];
        List<GroupMember> smgGrpMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:smgGrp.Id AND UserOrGroupId=:UserInfo.getUserId()];
        Boolean isUserGrpMember = false;
        if(smgGrpMembers?.size()>0){
            isUserGrpMember = true;
        }
        return isUserGrpMember;
	}

    /*
	 Method Name : invokeChatterPost
	 Description : This method invokes the chatter post
	 Parameters	 : Id record Id
	 Return Type : void
	*/
    @AuraEnabled(Cacheable=false)
    public static void invokeChatterPost(Id recordId) {
        List<Id> refIdList = new List<Id>();
        refIdList.add(recordId);
        ReferralManagementTriggerHelper.notifyOwnerOnReferralCreation(refIdList);
	}
    //</T02> end
}