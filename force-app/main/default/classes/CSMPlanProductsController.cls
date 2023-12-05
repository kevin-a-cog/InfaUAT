/*
 * Name			:	CSMPlanProductsController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/15/2021
 * Description	:	Manage Plan Products controller.

 Change History
 ********************************************************************************************************************************
 Modified By			Date		Jira No.		Description															  Tag
 ********************************************************************************************************************************
 Monserrat Pedroza	   6/15/2021		N/A			Initial version.									N/A
 Narpavi Prabu        09/22/2022      AR-2933        PP should be group by PPA should not consider TPL for displaying PP    T01
 */
public with sharing class CSMPlanProductsController {

	//Public variables.
	public static String STRING_FIELD_SET_NAME_ASSIGNED = 'Plan_Products_Assigned';
	public static String STRING_FIELD_SET_NAME_UNASSIGNED = 'Plan_Products_Unassigned';
	public static String STRING_FIELD_SET_NAME_All_ASSIGNED = 'Plan_Products_All_Assigned';

	/*
	 Method Name : getRecords
	 Description : This method returns the Related Account Plan records related to the provided Plan Id and Account Id.
	 Parameters	 : String, called from getRecords, strPlanId Plan Id.
	 			   String, called from getRecords, strAccountId Account Id.
				   List<String>, called from getRecords, lstStatusNotIn List of Statuses to not include.
				   List<String>, called from getRecords, lstStageNotIn List of Stages to not include.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId, String strAccountId, List<String> lstStatusNotIn, List<String> lstStageNotIn, Boolean showAllAssigned) {
		String strQuery;
		String strCleanPlanId;
		String strCleanAccountId;
		String strPlanAliasId;
		String strPlanAliasName;
		String strStaticResourceURL;
		String strObjectName = Related_Account_Plan__c.class.getName();
		CSMPlanProductsWrapperClass.IconWrapper objAction;
		CSMPlanProductsWrapperClass objRecordCustomStructure;
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		List<String> lstOpportunityIds = new List<String>();
		List<String> lstPlanIds = new List<String>();
		List<string> lAssignedPlanProdOfferingTypes = new List<String>();
		Map<String, CSMPlanProductsWrapperClass> mapParents = new Map<String, CSMPlanProductsWrapperClass>();
        lAssignedPlanProdOfferingTypes= Label.CSMAutomatePlanProdOfferingTypes.split(';');

		//We prepare the common table data.
		objDataTable.strObjectName = strObjectName;
		objDataTable.mapCustomColumnLabels = new Map<String, String>();
		objDataTable.mapCustomColumnLabels.put(Schema.Related_Account_Plan__c.Name.getDescribe().getName(), Label.Related_Risk_Product_Name_Field_Label);
		
		//If we received a Account Id.
		if(String.isNotBlank(strAccountId)) {

			//We clean the Account Id.
			strCleanAccountId = String.escapeSingleQuotes(strAccountId);

			//If we received Stages to exclude.
			if(lstStatusNotIn != null && !lstStatusNotIn.isEmpty()) {

				//Now we get the table details.
				objDataTable.strFielSetName = STRING_FIELD_SET_NAME_UNASSIGNED;
				objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
				strQuery = 'SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + ' WHERE ' + 
						'Status__c = \'Active\' AND Account__c = :strCleanAccountId AND Account_Plan__c = NULL AND Status__c NOT IN :lstStatusNotIn ';
				if(lstStageNotIn != null && !lstStageNotIn.isEmpty()) {
					strQuery += ' AND Stage__c NOT IN :lstStageNotIn';
				}
				objDataTable.lstRecords = Database.query(strQuery + 'ORDER BY Status__c,Forecast_Product__c ASC LIMIT 1000');
			} else {

				//Now we get the table details.
				objDataTable.strFielSetName = STRING_FIELD_SET_NAME_All_ASSIGNED;
				objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
				objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
						' WHERE Status__c = \'Active\' AND Account_Plan__r.Account__c = :strCleanAccountId AND ' + 
						'Account_Plan__c != NULL ORDER BY Status__c ASC LIMIT 1000');
			}
		} else if(String.isNotBlank(strPlanId)) {

			//We get the static resource URL.
			for(StaticResource objStaticResource : [SELECT Name, SystemModStamp FROM StaticResource WHERE Name = 'DetailsOn' LIMIT 1]) {
				strStaticResourceURL = '/resource/' + objStaticResource.SystemModStamp.getTime() + '/' + objStaticResource.Name;
			}

			//If we receive the Plan Id, we clean the Account Id.
			strCleanPlanId = String.escapeSingleQuotes(strPlanId);

			//Now we get the table details.
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME_ASSIGNED;
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
			strQuery = 'SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ', Account_Plan__c, Plan_Product_Alias__c, Plan_Product_Alias__r.Name__c, Product_Name__c, ' + 
					'Contract__r.Id, Plan_Product_Alias__r.Technical_Product_Line__r.Status__c FROM ' + strObjectName + ' WHERE Account_Plan__c = :strCleanPlanId' ;
			if(showAllAssigned == false){
				strQuery += ' AND Offering_Type__c in:lAssignedPlanProdOfferingTypes AND ARR__c > 0';
			}

			//Now we prepare the grouped response.
			objDataTable.lstRecords = new List<SObject>();
			objDataTable.lstRecordsCustomStructure = new List<CSMPlanProductsWrapperClass>();
			objDataTable.mapParentChildRelationship = new Map<String, String>();
			for(Related_Account_Plan__c objPlanProduct : Database.query(strQuery + ' ORDER BY Status__c,Forecast_Product__c ASC LIMIT 1000')) {
				objDataTable.lstRecords.add(objPlanProduct);

				//We generate the Plan Product record.
				objRecordCustomStructure = new CSMPlanProductsWrapperClass();
				//objRecordCustomStructure.boolRisk = objPlanProduct.Has_Risk_Associated__c;
				objRecordCustomStructure.Id = objPlanProduct.Id;
				objRecordCustomStructure.Name = objPlanProduct.Product_Name__c;
				objRecordCustomStructure.strContract = objPlanProduct.Contract__r.ContractNumber;
				objRecordCustomStructure.strContractId = objPlanProduct.Contract__r.Id;
				objRecordCustomStructure.strDeliveryMethod = objPlanProduct.Delivery_Method__c;
				objRecordCustomStructure.strOfferingType = objPlanProduct.Offering_Type__c;
				objRecordCustomStructure.strProductName = objPlanProduct.Forecast_Product__c;
				objRecordCustomStructure.strRenewalOpportunity = objPlanProduct.Opportunity__r.Name;
				objRecordCustomStructure.strRenewalOpportunityId = objPlanProduct.Opportunity__c;
				objRecordCustomStructure.strPlanId = objPlanProduct.Account_Plan__c;
				objRecordCustomStructure.strStatus = objPlanProduct.Status__c;
				objRecordCustomStructure.lstIcons = new List<CSMPlanProductsWrapperClass.IconWrapper>();
				objAction = new CSMPlanProductsWrapperClass.IconWrapper();
				objAction.boolIsStaticResource = true;
				objAction.intAction = 4;
				objAction.intWidth = 20;
				objAction.strURL = strStaticResourceURL;
				objRecordCustomStructure.lstIcons.add(objAction);
				objRecordCustomStructure.mapStyles = new Map<String, String>();
				objRecordCustomStructure.mapStyles.put('lstIcons', 'padding: 0px;');
				objDataTable.lstRecordsCustomStructure.add(objRecordCustomStructure);

				//We save the data to be used to calculate the risk.
				if(String.isNotBlank(objRecordCustomStructure.strRenewalOpportunityId)) {
					lstOpportunityIds.add(objRecordCustomStructure.strRenewalOpportunityId);
				}
				if(String.isNotBlank(objRecordCustomStructure.strPlanId)) {
					lstPlanIds.add(objRecordCustomStructure.strPlanId);
				}

				//<T01> - Removed the condition check for TPL in groupping the PP
				//Now we generate its parent.
				strPlanAliasId = '-';
				strPlanAliasName = '-';
				if(objPlanProduct.Plan_Product_Alias__c != null) {
					strPlanAliasId = objPlanProduct.Plan_Product_Alias__c;
					strPlanAliasName = objPlanProduct.Plan_Product_Alias__r.Name__c;
				}
				if(mapParents.get(strPlanAliasId) == null) {
					mapParents.put(strPlanAliasId, new CSMPlanProductsWrapperClass());
				}
				objRecordCustomStructure = mapParents.get(strPlanAliasId);
				objRecordCustomStructure.Id = strPlanAliasId;
				objRecordCustomStructure.strProductName = strPlanAliasName;
				mapParents.put(strPlanAliasId, objRecordCustomStructure);

				//Now we generate the relationship between the child and parent.
				objDataTable.mapParentChildRelationship.put(objPlanProduct.Id, strPlanAliasId);
			}

			//If we have at least 1 record.
			if(!objDataTable.lstRecordsCustomStructure.isEmpty()) {

				//We add the parent records to the list.
				objDataTable.lstRecordsCustomStructure.addAll(mapParents.values());
			}
		}else{

			//Now we get the table details.
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME_ASSIGNED;
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
			objDataTable.lstRecords = new List<Related_Account_Plan__c>();
		}

		//We now set the custom table configuration.
		for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objDataTable.lstColumns) {
			if(objColumn.fieldName == Schema.Related_Account_Plan__c.Forecast_Product__c.getDescribe().getName()) {
				objColumn.initialWidth = 150;
			}
		}
		return objDataTable;
	}

	/*
	 Method Name : getRecordsDeleted
	 Description : This method removes the relationship with the provided list of records.
	 Parameters	 : List<Related_Risk_Product__c>, called from getRecordsDeleted, lstRecords Records to be deattached.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Related_Account_Plan__c> lstRecords) {
		if(lstRecords != null && !lstRecords.isEmpty()) {
			for(Related_Account_Plan__c objRecord : lstRecords){
				objRecord.Account_Plan__c = null;
			}
			update lstRecords;
		}
	}

	/*
	 Method Name : getRecordInserted
	 Description : This method creates a new record.
	 Parameters	 : Plan__c, called from getRecordInserted, Record to be inserted.
	 Return Type : String
	 */
    @AuraEnabled(cacheable = false)
    public static String getRecordInserted(Plan__c objRecord) {

        if(objRecord?.Account__c <> null){
			String ownerId = getPlanOwner(objRecord.Account__c);
			if(ownerId <> ''){
				objRecord.OwnerId = ownerId;
			}
		}
		Database.SaveResult sr = Database.insert(objRecord, false);	
		return objRecord.Id;
	}

	/*
	 Method Name : createPlanTeamMembers
	 Description : This method creates Plan Team Members
	 Parameters	 : planId Plan to be related to the records.	 			   
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
    public static void createPlanTeamMembers(String planId) {
		List<AccountTeamMember> csmList = new List<AccountTeamMember>();
		List<Plan_Team__c> planTeamInsertList = new List<Plan_Team__c>();
		//List<CSMUtilsWrapper.PlanTeam> planTeamWrapperList = new List<CSMUtilsWrapper.PlanTeam>();

		Plan__c objRecord = [SELECT Id,Account__c FROM Plan__c WHERE Id =:planId LIMIT 1];
		if(objRecord?.Account__c <> null){
			csmList = [SELECT Id,UserId,User.Email,User.ManagerId,User.Manager.Email from AccountTeamMember where TeamMemberRole = 'CSM' AND AccountId =:objRecord.Account__c ORDER BY CreatedDate DESC];
		}

		if(csmList.size()>0){
			/** Create Plan Team Members - CSM and CSM Manager **/
			//Csm
			Plan_Team__c objCsm = CSMUtilities.createPlanTeamMember(planId,csmList[0].User.Email,csmList[0].UserId,CSMUtilities.ROLE_CSM);
			objCsm.Primary__c=true;			
			planTeamInsertList.add(objCsm);

			//Csm manager
			Plan_Team__c objCsmManager = CSMUtilities.createPlanTeamMember(planId,csmList[0].User.Manager.Email,csmList[0].User.ManagerId,CSMUtilities.ROLE_CSM_MANAGER);
			objCsmManager.Primary__c=true;
			planTeamInsertList.add(objCsmManager);
			//Insert plan team members
			if(planTeamInsertList.size()>0){
				insert planTeamInsertList;
			}

			Plan__c objPlanREcord = new Plan__c(Id=planId,OwnerId=csmList[0].UserId);
			if(csmList[0].User.ManagerId!=null){
				objPlanREcord.Csm_Manager__c =  csmList[0].User.ManagerId;
			}
			update objPlanREcord;
			/*	
			CSMUtilsWrapper.PlanTeam planTeamMember = new CSMUtilsWrapper.PlanTeam();
			planTeamMember.planId = planId;
			planTeamMember.userId = csmList[0].UserId;
			planTeamMember.userEmail = csmList[0].User.Email;
			planTeamMember.role = 'CSM';
			planTeamMember.Primary__c=true;
			planTeamWrapperList.add(planTeamMember);					
			
			if(csmList[0].User.ManagerId <> null){
				CSMUtilsWrapper.PlanTeam csmManager = new CSMUtilsWrapper.PlanTeam();
				csmManager.planId = planId;
				csmManager.userId = csmList[0].User.ManagerId;
				csmManager.userEmail = csmList[0].User.Manager.Email;
				csmManager.role = 'CSM Manager';
				csmManager.Primary__c=true;
				planTeamWrapperList.add(csmManager);
			}
				
			if(planTeamWrapperList?.size()>0){
				planTeamInsertList = CSMUtilities.createPlanTeamMember(planTeamWrapperList);
				insert planTeamInsertList;
			}*/
		}
	}

	@AuraEnabled(cacheable = false)
    public static String getPlanOwner(String accountId) {
		String ownerId = '';
		List<AccountTeamMember> csmList = new List<AccountTeamMember>();
		csmList = [SELECT Id,UserId,User.Email,User.ManagerId,User.Manager.Email from AccountTeamMember where TeamMemberRole = 'CSM' AND AccountId =:accountId ORDER BY CreatedDate DESC];
		if(csmList?.size()>0){
			ownerId = csmList[0].UserId;
		}
		return ownerId;
	}

	/*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsRelated, strRecordId Plan to be related to the records.
	 			   List<Related_Account_Plan__c>, called from getRecordsRelated, lstRecords Records to be related.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<Related_Account_Plan__c> lstRecords) {
		String strCleanRecordId;

		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);
			for(Related_Account_Plan__c objRecord : lstRecords) {
				objRecord.Account_Plan__c = strCleanRecordId;
			}
			update lstRecords;
		}
	}

    /*
	 Method Name : getRecordsUpdated
	 Description : This method updates the provided records.
	 Parameters	 : List<Related_Account_Plan__c>, called from getRecordsUpdated, lstRecords Records to be updated.
	 Return Type : None
	 */
    @AuraEnabled
    public static void getRecordsUpdated(List<Related_Account_Plan__c> lstRecords){
        update lstRecords;
    }
    
    /*Method to fetch record types.
    * @param Name - none
    * @throws exception -n/a
    * @return Map<Id,String>
    */
    @AuraEnabled       
    public static Map<Id,String> getRecordTypeValues(){
        
        Boolean isSalesUser = FeatureManagement.checkPermission('CSM_Create_Sales_Account_Plan');
        
        Map<Id, String> recordtypeMap = new Map<Id, String>();
        //Get all record types of Plan object
        List<Schema.RecordTypeInfo> recordTypeInfoList = Plan__c.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo info: recordTypeInfoList) {
            //Check record type is available for current user profile
            if(info.isAvailable()) {
                if(isSalesUser && info.getDeveloperName() == 'Sales_Account_Plan' && info.getName().trim() != ''){
                    recordtypeMap.put(info.getRecordTypeId(), info.getName());  
                }
                else if(!isSalesUser && info.getDeveloperName() == 'New_Product_Implementation' && info.getName().trim() != ''){
                    recordtypeMap.put(info.getRecordTypeId(), info.getName());
                }                
            }
        }    
        
        return recordtypeMap;
    }
    
    /*Method to get the plan product count.
    * @param Name - planId
    * @throws exception -n/a
    * @return Boolean---Response will be true if Account has atleast one assigned/unassigned plan products
    */
    @AuraEnabled
    public static Boolean planproductcount(String recid){
        List<string> lstIncludeOfferingType = Label.A2RIncludeOfferingTypes.split(';');
        Boolean planproducexist = false;
        List<Related_Account_Plan__c> planproducst = new List<Related_Account_Plan__c>();
        for(Related_Account_Plan__c rp: [SELECT Id from Related_Account_Plan__c where (Account__c = :recid OR Account_Plan__r.Account__c = :recid) and Offering_Type__c IN :lstIncludeOfferingType and Status__c = 'Active' LIMIT 1]){
            planproducexist = true;
        }
         
        return planproducexist;
    }

	/*Method to delete the Interlocks
    * @param Name - getInterlockstoDelete
    * @throws exception -n/a
    * @return String - List of Plan Products
    */
    @AuraEnabled
    public static List<Related_Opportunity_Plan__c> getInterlockstoDelete(List<Related_Account_Plan__c> removePlanProductsList){
        Set<Id> planIdSet = new Set<Id>();
        Set<String> removedPlanProductSet = new Set<String>();
        Map<String,List<Related_Account_Plan__c>> planProductsMap = new Map<String,List<Related_Account_Plan__c>>();
        List<Related_Opportunity_Plan__c> deleteInterlockList = new List<Related_Opportunity_Plan__c>();

        // Plan Products to be removed
        for(Related_Account_Plan__c planproduct :[Select Id,Name,Account_Plan__r.Account__c,Account_Plan__c,Contract__c,Opportunity__c,Contract__r.SBQQ__Opportunity__c from Related_Account_Plan__c where Id in:removePlanProductsList]){
           
            string UniqueKey =  planproduct.Account_Plan__c+';'+planproduct.Contract__c+';'+planproduct.Opportunity__c+';'+planproduct.Contract__r.SBQQ__Opportunity__c;
            removedPlanProductSet.add(UniqueKey);

            //Get the Plan Id to check existing interlock
            if(planproduct.Account_Plan__c <> null){
                planIdSet.add(planproduct.Account_Plan__c);
            }
        }
        //Other Assigned Plan Products
        for(Related_Account_Plan__c planproduct :[Select Id,Name,Account_Plan__r.Account__c,Account_Plan__c,Contract__c,Opportunity__c,Contract__r.SBQQ__Opportunity__c from Related_Account_Plan__c where Id not in:removePlanProductsList and Account_Plan__c in:planIdSet]){
               string UniqueKey =  planproduct.Account_Plan__c+';'+planproduct.Contract__c+';'+planproduct.Opportunity__c+';'+planproduct.Contract__r.SBQQ__Opportunity__c;
               
               if(planProductsMap.containsKey(UniqueKey)){
                List<Related_Account_Plan__c> tempList = planProductsMap.get(UniqueKey);
                tempList.add(planproduct);
                planProductsMap.put(UniqueKey,tempList);
                }else{
                    planProductsMap.put(UniqueKey,new List<Related_Account_Plan__c>{planproduct});
                }
        }
        
        //Existing Interlocks under this Plan
        for(Related_Opportunity_Plan__c interlock : [Select Id,Original_Opportunity__c,Opportunity__c,Plan__c,Contract__c from Related_Opportunity_Plan__c where Plan__c in:planIdSet]){
            string UniqueKey =  interlock.Plan__c+';'+interlock.Contract__c+';'+interlock.Opportunity__c+';'+interlock.Original_Opportunity__c;
            if(removedPlanProductSet.contains(UniqueKey) && !planProductsMap.keySet().contains(UniqueKey)){
                deleteInterlockList.add(interlock);
            }
        }

        return deleteInterlockList;
    }

	/*
	 Method Name : deleteInterlocks
	 Description : This method deletes the Interlock
	 Parameters	 : List of Interlocks
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void deleteInterlocks(List<Related_Opportunity_Plan__c> lstRecords) {
		delete lstRecords;
	}
    
    //@Akhilesh 10 Jan 2022
    @AuraEnabled(cacheable = false)
    public static boolean hasUnasignedProductPlans(string planAccountId) {
       string strCleanAccountId  = String.escapeSingleQuotes(planAccountId);          
       boolean hasunAssignedPlanProduct = false;
				
        List<string> lAssignedPlanProdOfferingTypes = new List<String>();
        lAssignedPlanProdOfferingTypes= Label.CSMAutomatePlanProdOfferingTypes.split(';');
		/*AND Offering_Type__c IN ('On-Premise Subscription','DaaS On-Premise Subscription','Cloud Hosted Subscription','DaaS Hosted Subscription')*/		
        List<Related_Account_Plan__c> planProducts = [Select Id
                                                    From Related_Account_Plan__c 
                                                    Where Account__c =: strCleanAccountId 
                                                    AND Account_Plan__c = null 
                                                    AND ARR__c > 0
                                                    AND Offering_Type__c IN :lAssignedPlanProdOfferingTypes
                                                    AND Status__c NOT IN ('Expired') 
                                                    Order By Status__c ASC
                                                    Limit 1];
																										
				

        if(planProducts.size() > 0){
            hasunAssignedPlanProduct = true;
        }

        return hasunAssignedPlanProduct;        
	}
    
}