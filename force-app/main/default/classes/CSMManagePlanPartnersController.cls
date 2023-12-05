/*
 * Name			:	CSMManagePlanPartnersController
 * Author		:	Gabriel Coronel
 * Created Date	: 	6/2/2021
 * Description	:	Manage Plan Partners controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Gabriel Coronel		6/2/2021		N/A				Initial version.			N/A
 */
public without sharing class CSMManagePlanPartnersController {

	//Public variables.
	public static String STRING_FIELD_SET_NAME = 'Plan_Partner';
	public static String STRING_UNASSIGNED_FIELD_SET_NAME = 'Unassigned_Plan_Partner';
	public static String STRING_RECORD_TYPE_NAME = 'Plan Partner';
	public static String STRING_ACCOUNT_RECORD_TYPE_NAME = 'Partner Account';
	public static String strPartnerAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(STRING_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
    public static String strPartnerRelationShipRecordType = Schema.SObjectType.Partner_Relationship__c.getRecordTypeInfosByName().get(STRING_RECORD_TYPE_NAME).getRecordTypeId();

	/*
	 Method Name : getPlanPartnerRecordType
	 Description : This method returns the default records type for the feature.
	 Parameters	 : None
	 Return Type : Record Type Id
	 */
    @AuraEnabled(cacheable = false)
    public static String getPlanPartnerRecordType() {
		return Schema.SObjectType.Partner_Relationship__c.getRecordTypeInfosByName().get(STRING_RECORD_TYPE_NAME).getRecordTypeId();
	}
	/*
	 Method Name : getUnassignedRecords
	 Description : This method returns the Plan Partner records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static DataTableWrapperClass getUnassignedRecords(String strPlanId) {
        String strCleanPlanId;
        String strCleanAccountId;
        DataTableWrapperClass objDataTable = new DataTableWrapperClass();
        set<String> opportunityIdset = new Set<String>();
        set<String> contractIdSet = new Set<String>();
        set<String> accountIdSet = new Set<String>(); //To remove the duplicates within the Unassigned Partners List
        
        set<String> existingAccountIdSet = new Set<String>();
        List<DataTableWrapperClass.TableRowWrapper> planAccountObjList = new List<DataTableWrapperClass.TableRowWrapper>();
        Map<Id,SObject> partnerTeamMap = new Map<Id,SObject>();
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            //Query Plan Contracts and add the Opportunity to set
            for(Plan_Contract__c pc:CSMDataTableQueryUtilities.getPlanContractByPlanId(new Set<String>{strCleanPlanId})){
                if(pc.Opportunity__c!=null){
                    opportunityIdset.add(pc.Opportunity__c);
                    contractIdSet.add(pc.Contract__c);
                }               
            }
            //Query Assinged Records to filter accounts
            for(Partner_Relationship__c pr:CSMDataTableQueryUtilities.getPartnerRelationShipRecords(new Set<String>{strCleanPlanId},strPartnerAccountRecordType)){
                existingAccountIdSet.add(pr.Partner_Account__c);
            }
            //Select the parter relation records
            if(opportunityIdset.size()>0){                
                for(Partner_Relationship__c pr:CSMDataTableQueryUtilities.getPartnerRelationShipRecords(opportunityIdset,new Set<String>{strCleanPlanId},strPartnerAccountRecordType)){
                    if(!existingAccountIdSet.contains(pr.Partner_Account__c)){
                        partnerTeamMap.put(pr.Partner_Account__c,pr);
                    }
                }
            }
            
            //Query order records and get the accounts to set
            /* if(contractIdSet.size()>0){
                for(Order od:CSMDataTableQueryUtilities.getOrderByContractId(contractIdSet)){
                    
                    if(od.SoldToAccount__c!=null && !existingAccountIdSet.contains(od.SoldToAccount__c) && od.SoldToAccount__r.RecordTypeId == strPartnerAccountRecordType && !accountIdSet.contains(od.SoldToAccount__c) && od.SoldToAccount__r.Status__c == 'Active'){
                        DataTableWrapperClass.TableRowWrapper partnerAccObj = new DataTableWrapperClass.TableRowWrapper();
                        partnerAccObj.accountName= od.SoldToAccount__r.Name;
                        partnerAccObj.opportunityName= od.Opportunity.Name;
                        partnerAccObj.Id= od.SoldToAccount__c;
                        planAccountObjList.add(partnerAccObj);
                        accountIdSet.add(od.SoldToAccount__c);
                    }                    
                    if(od.EndUserAccount__c!=null && !existingAccountIdSet.contains(od.EndUserAccount__c)&& od.EndUserAccount__r.RecordTypeId == strPartnerAccountRecordType && !accountIdSet.contains(od.EndUserAccount__c) && od.EndUserAccount__r.Status__c == 'Active'){
                        DataTableWrapperClass.TableRowWrapper partnerAccObj = new DataTableWrapperClass.TableRowWrapper();
                        partnerAccObj.accountName= od.EndUserAccount__r.Name;
                        partnerAccObj.opportunityName= od.Opportunity.Name;
                        partnerAccObj.Id= od.EndUserAccount__c;
                        planAccountObjList.add(partnerAccObj);
                        accountIdSet.add(od.EndUserAccount__c);
                    }                    
                    if(od.ShipToAccount__c!=null && !existingAccountIdSet.contains(od.ShipToAccount__c) && od.ShipToAccount__r.RecordTypeId == strPartnerAccountRecordType && !accountIdSet.contains(od.ShipToAccount__c) && od.ShipToAccount__r.Status__c == 'Active'){
                        DataTableWrapperClass.TableRowWrapper partnerAccObj = new DataTableWrapperClass.TableRowWrapper();
                        partnerAccObj.accountName= od.ShipToAccount__r.Name;
                        partnerAccObj.opportunityName= od.Opportunity.Name;
                        partnerAccObj.Id= od.ShipToAccount__c;
                        planAccountObjList.add(partnerAccObj);
                        accountIdSet.add(od.ShipToAccount__c);
                    }
                    if(od.BilltoAccount__c!=null && !existingAccountIdSet.contains(od.BilltoAccount__c) && od.BilltoAccount__r.RecordTypeId == strPartnerAccountRecordType  && !accountIdSet.contains(od.BilltoAccount__c) && od.BilltoAccount__r.Status__c == 'Active'){
                        DataTableWrapperClass.TableRowWrapper partnerAccObj = new DataTableWrapperClass.TableRowWrapper();
                        partnerAccObj.accountName= od.BilltoAccount__r.Name;
                        partnerAccObj.opportunityName= od.Opportunity.Name;
                        partnerAccObj.Id= od.BilltoAccount__c;
                        planAccountObjList.add(partnerAccObj);
                        accountIdSet.add(od.BilltoAccount__c);
                    }
                }
            }
            //Query parner accounts assocaited to order
          * if(accountIdSet.size()>0){
                for(Account acc:CSMDataTableQueryUtilities.getParnerAccountByAccountId(accountIdSet,strPartnerAccountRecordType)){
                    partnerTeamMap.put(acc.Id,acc);
                }
            } **/
            //Process Un assinged records
            if(partnerTeamMap.size()>0){
                for(SObject obj:partnerTeamMap.values()){  
                    DataTableWrapperClass.TableRowWrapper partnerAccObj = new DataTableWrapperClass.TableRowWrapper(); 
                    if(obj instanceof Partner_Relationship__c){   // Type cast from sobject type to apprpriate object 
                        Partner_Relationship__c pt = (Partner_Relationship__c)obj;
                        partnerAccObj.accountName=pt.Partner_Account__r.Name;
                        partnerAccObj.accountId=pt.Partner_Account__c;
                        //String createdDdateValue = pt.createdDate.format('MMM')+' '+ pt.createdDate.format('dd')+', '+ pt.createdDate.format('YYYY');
                        //partnerAccObj.createdDate=createdDdateValue;
                        partnerAccObj.opportunityName=pt.Opportunity__r.Name;
                        partnerAccObj.Id=pt.Id;
                       // partnerAccObj.source ='Partner Relationship';
                        planAccountObjList.add(partnerAccObj);
                    }  
                    /**if(obj instanceof Account){   // Type cast from sobject type to apprpriate object 
                        Account acc = (Account)obj;
                        partnerAccObj.accountName=acc.Name;
                        String createdDdateValue = acc.createdDate.format('MMM')+' '+ acc.createdDate.format('dd')+', '+ acc.createdDate.format('YYYY');
                        partnerAccObj.createdDate=createdDdateValue;                        
                        //partnerAccObj.source= 'Partner Account';
                        partnerAccObj.Id=acc.Id;
                        //partnerAccObj.opportunityName=;
                        planAccountObjList.add(partnerAccObj);
                    }   **/ 
                }     
            }
            
            //Now assing the actual coloumns that need to display on table 
            objDataTable.lstColumns=new List<DataTableWrapperClass.ColumnWrapper>();      
            objDataTable.lstColumns.add(prepareColumn('accountName','Name','String'));
            //objDataTable.lstColumns.add(prepareColumn('createdDate','Created Date','String'));
            objDataTable.lstColumns.add(prepareColumn('opportunityName','Opportunity Name','String'));
           // objDataTable.lstColumns.add(prepareColumn('source','Source','String'));
            objDataTable.lstRecords = planAccountObjList;
        }
        return objDataTable;
    }
	/*
	 Method Name : getAssingedRecords
	 Description : This method returns the Plan Partner records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getAssingedRecords(String strPlanId) {	
        String strCleanPlanId;
        String strObjectName = Partner_Relationship__c.class.getName();
        Map<Id,Partner_Relationship__c> partnerAccountMap  = new Map<ID,Partner_Relationship__c >();
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();        
        //If we received a Plan Id.
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            //Now we get the table details.
            objDataTable.strObjectName = strObjectName;
            objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
            objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
            for(Partner_Relationship__c partenerRelation:Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Partner_Account__c  FROM ' + strObjectName + ' WHERE Plan__c = :strCleanPlanId AND RecordTypeId=:strPartnerRelationShipRecordType LIMIT 1000')){
                partnerAccountMap.put(partenerRelation.Partner_Account__c ,partenerRelation);
            }
            //Now we prepare the response.
            objDataTable.lstRecords = partnerAccountMap.values();
        }
		return objDataTable;
    }
	 /*
	 Method Name : prepareColumn
	 Description : This generic methiod will prepare a coloumn wrppaer instance with provided valies 
	 Parameters	 : String fieldName, this will fieldname declared from wrapper instance
                   String label, this will label declared from wrapper instance
                   String objType, this will objType declared from wrapper instance
	 Return Type : None
	 */
    private static DataTableWrapperClass.ColumnWrapper prepareColumn(String fieldName,  string  label, string type){      
        DataTableWrapperClass.ColumnWrapper objColumn = new DataTableWrapperClass.ColumnWrapper();
        objColumn.fieldName = fieldName;
        objColumn.label = label;
        objColumn.type = type; 
        objColumn.sortable = true;         		
        return objColumn;
    }   

	/*
	 Method Name : getRecordsDeleted
	 Description : This method deletes the Partner Relationship record.
	 Parameters	 : List<Partner_Relationship__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Partner_Relationship__c> lstRecords) {
		/*for(Partner_Relationship__c prRec : lstRecords){
            prRec.Plan__c=null;
        }
        update lstRecords;*/
        delete lstRecords;
	}

	/*
	 Method Name : getRecordsRelated
	 Description : This method relates the corresponding records with the provided Id.
	 Parameters	 : String, called from getRecordsDeleted, strRecordId Plan to be related to the records.
	 			   List<Partner_Relationship__c>, called from getRecordsDeleted, lstRecords Records to be related.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<Partner_Relationship__c> lstRecords) {
		String strCleanRecordId;
        String msg = '';
		//If we received a Plan Id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);			
            //List<Partner_Relationship__c> upsertPartnerRelationList = new List<sobject>();
            List<Partner_Relationship__c> insertPartnerRelationList = new List<sobject>();
           // List<Partner_Relationship__c> castRecords = (List<Partner_Relationship__c>)lstRecords;
           for(Partner_Relationship__c accRecord:lstRecords){
                System.debug('Record'+accRecord);
               // System.debug('objectname'+Id.valueOf(accRecord.Id).getSObjectType().getDescribe().getName());
                //If it's Partner relation record update the plan for the record
               /* if(Id.valueOf(accRecord.Id).getSObjectType().getDescribe().getName().equals('Partner_Relationship__c')){
                    upsertPartnerRelationList.add(new Partner_Relationship__c(Id=accRecord.Id,Plan__c=strCleanRecordId));
                }else{
                    //For Account create new Partner_Relationship__c record with plan and account
                    upsertPartnerRelationList.add(new Partner_Relationship__c(Partner_Account__c=accRecord.Id,Plan__c=strCleanRecordId));
                }*/
                //New Changes added on 14/10
                insertPartnerRelationList.add(new Partner_Relationship__c(Partner_Account__c=accRecord.Partner_Account__c,Plan__c=strCleanRecordId,RecordTypeId=strPartnerRelationShipRecordType));
            }
            if(insertPartnerRelationList.size()>0){
                CSMDuplicatePartRelationshipValidation validationHelp=new CSMDuplicatePartRelationshipValidation();
                validationHelp.validate(insertPartnerRelationList);
                insert insertPartnerRelationList;
            }
            /*Below Code no longer required
            System.debug('REcods inser'+upsertPartnerRelationList);
            try{
                //Upsert list if it have values
                   /* if(upsertPartnerRelationList.size()>0){
                        upsert upsertPartnerRelationList;
                    }*/
                   /*
                    if(insertPartnerRelationList.size()>0){
                        CSMDuplicatePartRelationshipValidation validationHelp=new CSMDuplicatePartRelationshipValidation();
                        validationHelp.validate(insertPartnerRelationList);
                        insert insertPartnerRelationList;
                    }
                }catch(DmlException e){
                //Get All DML Messages
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //Get Validation Rule & Trigger Error Messages
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                //throw DML exception message
                throw new AuraHandledException(msg);
                
            }catch (Exception e) {
                System.debug(e.getmessage());
                throw new AuraHandledException(e.getMessage());
            } */   
            }
	}


}