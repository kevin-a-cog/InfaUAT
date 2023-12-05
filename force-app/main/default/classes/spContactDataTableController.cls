/*
 * Name      :  spContactDataTableController
 * Author    :  Akhilesh Soni
 * Created Date  :   1/17/2022
 * Description  :  Class to handle contact creation/updation from community 

 Change History
 **********************************************************************************************************
 Modified By      Date      Jira No.    Description                      Tag
 **********************************************************************************************************
 Harshita Joshi  08/06/2022 AR-2754    handle the email error mesage issue     T01
 Narpavi Prabu   28/07/2022 AR-2738    Remove delete for the users in community and send an inbound comment to csm to delete the plan conatct T02
 */
public without sharing class spContactDataTableController {
    public static String STRING_FIELD_SET_NAME = 'spPlanContactTable';
    	/*
	 Method Name : getRecords 
	 Description : This method returns the Plan Contactrecords related to the provided Id.
	 Parameters	 : String, called from getRecords, strRecordId Record Id.
	 Return Type : Columns and records.
	 */
    @AuraEnabled
    public static GlobalDataTableWrapperClass getPCRecords(String strRecordId) {
		String strCleanRecordId;
		String strObjectName = Plan_Contact__c.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
 
		
		if(String.isNotBlank(strRecordId)) {

			//We clean the Risk Id.
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);

			//If we received Plan id, we get Plan Product records.
			objDataTable.strObjectName = strObjectName;
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME;			
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);		
			
			//Now we prepare the response.
			objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
					' WHERE Plan__c = :strCleanRecordId  ORDER BY LastModifiedDate DESC LIMIT 1000');
		}
		return objDataTable;
	}


     @AuraEnabled
     public static List<Plan_Contact__c> fetchPlanRelatedContact(string planId){

        list<Plan_Contact__c> lstPlan_Contact = new list<Plan_Contact__c>();
        //set<Id> setConId = new set<Id>();
        for(Plan_Contact__c pc : [SELECT Id,Name,Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.Name,Contact__r.Email, Contact__r.Phone, Plan__c,Role__c
                                  FROM Plan_Contact__c WHERE Plan__c =: planId]){
            lstPlan_Contact.add(pc);            
        }

        /*for(contact oCon : [SELECT Id, Name, Email, Level__c, Phone FROM Contact Where Id IN : setConId] ){
            lstPlan_Contact.add(oCon);
        }*/
        return lstPlan_Contact;

     }
     


     @AuraEnabled
    public static string updateContact(String ContactRec, string SupportAccountId, string planId, string planContactRole,string planContactId){
        String returnMessage = 'SUCCESS';
        List<Id> RecTypeIds = new List<Id>();
        Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();    
        Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();    
        RecTypeIds.add(AccRecTypeId_PrtnrAccnt);
        RecTypeIds.add(AccRecTypeId_CustAccnt);
        Id newContactId ;
        System.debug('ContactRec'+ContactRec);
        System.debug('SupportAccountId'+SupportAccountId);
        System.debug('planId'+planId);
        System.debug('AccRecTypeId_PrtnrAccnt'+AccRecTypeId_PrtnrAccnt);
        System.debug('AccRecTypeId_CustAccnt'+AccRecTypeId_CustAccnt);
        Account SupportAccount = CaseControllerWithoutSharing.getSupportAccount(SupportAccountId)[0];
        Contact newContact = (Contact)JSON.deserialize(ContactRec, Contact.class);
        newContact.MailingCountry = SupportAccount.BillingCountry;
        System.debug('newContact'+newContact);
        Boolean isExternalUser = [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;
        try{          
            if(isExternalUser || test.isRunningTest()){
 
                UPDATE newContact;

                Plan_Contact__c objPlanCon = new Plan_Contact__c();
                objPlanCon.Id = planContactId;
                objPlanCon.Role__c = planContactRole;
                UPDATE objPlanCon;
                returnMessage = 'Contact has been updated successfully.';

            }

        }catch (Exception e) {
            System.debug(e.getmessage());
            String message =e.getmessage();
            new globalApexManager().CreateLogs('ManageCaseContacts - createNewContact',e.getMessage());
            message = message != '' ? message : 'Please Contact your System Administrator';
           // returnMessage = message;
            throw new AuraHandledException(message);
            
        }
        return returnMessage;


    }
     
     //Create New Contact for plan detail
    @AuraEnabled
    public static string CreateNewContact(String ContactRec, string SupportAccountId, string planId, string planContactRole){
        String returnMessage = 'SUCCESS';
        List<Id> RecTypeIds = new List<Id>();
        Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();    
        Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();    
        RecTypeIds.add(AccRecTypeId_PrtnrAccnt);
        RecTypeIds.add(AccRecTypeId_CustAccnt);
        Id newContactId ;
        System.debug('ContactRec'+ContactRec);
        System.debug('SupportAccountId'+SupportAccountId);
        System.debug('planId'+planId);
        System.debug('AccRecTypeId_PrtnrAccnt'+AccRecTypeId_PrtnrAccnt);
        System.debug('AccRecTypeId_CustAccnt'+AccRecTypeId_CustAccnt);

        Contact newContact = (Contact)JSON.deserialize(ContactRec, Contact.class);
        System.debug('newContact'+newContact);
        Boolean isExternalUser = [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;
        try{

          ///  if((isExternalUser && CaseControllerWithoutSharing.isPrimaryContact(SupportAccountId)) || !isExternalUser){
            if(isExternalUser || test.isRunningTest()){
                Account SupportAccount = CaseControllerWithoutSharing.getSupportAccount(SupportAccountId)[0];
    
                if(newContact!= null& newContact.email!= null){
                    List<Contact> lstDupContacts = [Select Id,Name,Timezone__c,INFA_Language__c, MailingCountry,Account.BillingCountry,AccountId,Account.RecordtypeId,Account.Recordtype.Name from contact where email = :newContact.email and Account.RecordtypeId in : RecTypeIds limit 1  ];
 
                    System.debug('lstDupContacts'+lstDupContacts);

                    if(lstDupContacts?.size()>0){
                        Contact dupContact = lstDupContacts[0];
                        Contact updateContact = new Contact(Id =dupContact.Id );
                        returnMessage = 'DUPLICATE';
                    }
                    else{
                        if(!CaseControllerWithoutSharing.isLeadExists(newContact.email)){
                            newContact.AccountId = SupportAccountId;
                            newContact.MailingCountry = SupportAccount.BillingCountry;
                            if(isExternalUser){ //Fix for standard error "portal users cannot own partner accounts" when enforcing sharing on class. Default owner of the contact will be set to Support Account's Parent Account's Owner
                                newContact.OwnerId = SupportAccount.OwnerId; // should be  
                            }
                            //atabase.SaveResult sr = Database.insert(newContact);
                            CaseControllerWithoutSharing.createContact(newContact);
                           
                            newContactId = newContact.Id;
                            System.debug('newContactId Inserted -->'+ newContactId);

                        }
                        else{
                          ////  throw new CustomException('POTENTIAL DUPLICATES DETECTED');
                        }
                    }
                }

                if(newContactId != null &&  SupportAccountId != null){
                    List<AccountContactRelation>  lstoldACR = [Select id, ContactId, AccountId from AccountContactRelation where ContactId =:newContactId and AccountId =:SupportAccountId limit 1];

                    if (lstoldACR?.size()>0){
                        returnMessage = 'CONTACTPRESENT';
                    }
                    else{
                        AccountContactRelation newAcr = new AccountContactRelation();
                        newAcr.contactId = newContactId;
                        newAcr.AccountId = SupportAccountId;
                       // newAcr.Timezone__c = newContact.Timezone__c != null ? newContact.Timezone__c :'';
                        //newAcr.Language__c = newContact.INFA_Language__c != null ? newContact.INFA_Language__c : '';
                        //newAcr.Phone__c = newContact.Phone != null ? newContact.Phone:'';
                       // newAcr.Access_Level__c = newContact.Access_Level__c != null ? newContact.Access_Level__c:'';
                        Database.SaveResult sr = Database.insert(newAcr) ;
                        System.debug('newAcr Inserted -->'+ sr.getId());

                    }


                    if(planId != null){

                    List<Plan_Contact__c> lstcaseCon = [Select id, Contact__c, Plan__c,Role__c  from Plan_Contact__c where Contact__c =:newContactId and Plan__r.Account__c =:SupportAccountId and Plan__c =:planId limit 1];
                    System.debug('lstcaseCon'+lstcaseCon);
                    if (lstcaseCon?.size()>0){
                        returnMessage = 'Contact is added to plan already';
                    }
                    else {
                        Plan_Contact__c newPlanContact = new Plan_Contact__c();
                        newPlanContact.Plan__c = planId;
                        newPlanContact.Contact__c = newContactId;
                        newPlanContact.Contact_email__c = newContact.Email;
						newPlanContact.Role__c = planContactRole;
                        Database.SaveResult sr = Database.insert(newPlanContact) ;
                        System.debug('newPlanContact Inserted -->'+ sr.getId());
                        returnMessage = 'Contact is added to Plan successfully';

                    }

                    }
                } 
            }
            else{
               //// throw new CustomException('INSUFFICIENT ACCESS TO CREATE CONTACT');
            }

        }catch (Exception e) {
            System.debug(e.getmessage());
            //Amarender - Made changes as part of I2RT-4227
            String message ='';
            new globalApexManager().CreateLogs('ManageCaseContacts - createNewContact',e.getMessage());
            if(e.getMessage().contains('DUPLICATES_DETECTED, Use one of these records')){
                message = 'Contact already exist in the System';
            }
            if(e.getMessage().contains('POTENTIAL DUPLICATES DETECTED')){
                message = System.Label.Potential_Duplicate_Lead_Validation_Message;
            }//<T01>
            if(e.getMessage().contains('INVALID_EMAIL_ADDRESS, Email: invalid email address')){
                message = 'Please enter valid Email';
            }
            //</T01>
            //Amarender - Made changes as part of I2RT-4227
            message = message != '' ? message : 'Please contact your System Administrator';
            throw new AuraHandledException(message);
        }
        return returnMessage;
    }


    @AuraEnabled
    public static String removePlanContact(String planContactId){
        try{

          //DELETE [Select Id From Plan_Contact__c WHERE Id =:planContactId];
          //<T02> - Removed the delete functinality and add the inbound comment
          List<Plan_Comment__c> planCommentList = new List<Plan_Comment__c>();
          List<Plan_Contact__c> plancontact = new List<Plan_Contact__c>([Select Id,Contact__r.Name,Plan__c From Plan_Contact__c WHERE Id =:planContactId]);         
          if(plancontact.size()>0)
          {
            for (Plan_Contact__c pc:plancontact)
            {
                planCommentList.add(CSMUtilities.createPlanComment(pc.Plan__c,'<p>Please delete the following Plan Contact from the Plan:</p>'+pc.Contact__r.Name,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INBOUND,CSMUtilities.SUBTYPE_PLAN,TRUE));
            }                       
          }
          
        if(planCommentList.size()>0){
                insert planCommentList;
        }
        return 'SUCCESS';   
       //</T02>   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}