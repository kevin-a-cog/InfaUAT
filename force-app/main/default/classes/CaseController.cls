/*
@created by       : balajip
@created on       : 01/02/2020
@Purpose          : Controller class for Case Lightning components
@Testclass        : 
@JIRA             : 
Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.    Tag     Description
*********************************************************************************************************************
Venky          08/30                        T01     To complete all open milestones when case is moved to closed 
                                                    from console quick actions
Vignesh D      09/15            I2RT-4361   T02     Show only entitled products available in the technical product line 
                                                    while creating case
Vignesh D      09/24            I2RT-4611   T03     Execute SOQL & DML operations for objects in "Without Sharing" 
                                                    context for community users.
Vignesh D      10/08            I2RT-4603   T04     Case Record Type changes
Amarender      12/01            I2RT-4999   T05     When Inbound Case comment is posted, Case Next Action to be 
                                                    updated to "Case Owner"
Vignesh D      01/05            I2RT-5218   T06     Create entitled product in without sharing context.
balajip        02/22/22         I2RT-5456   T05     Added condition to check if the Org is active
balajip        02/22/22         I2RT-5455   T06     Added logic to include the child Orgs
Vignesh D      02/04            I2RT-5185   T07     Signature Select to be added to Initial Response datetime calculation
Sandeep Duggi  02/23/22         I2RT - 5372  T08    fixed - Re-opened cases are not having env details captured from old case
Vignesh D      03/08            I2RT-5620   T09     Create a method to return support account.
balajip        03/15/22         I2RT-5456   T10     Reverted the condition to check if the Org is active
Vignesh D      05/04/22         I2RT-5733   T11     Copy Org Id from closed to repopened case, if there is value
Vignesh D      05/05/22         I2RT-5733   T12     Add Org_Formula_Id__c field to the query
balajip        06/16/22         I2RT-6222   T13     new method getDelMethodsForSelectedProduct.
Vignesh D      06/22/22         I2RT-6484   T14     Add UserId and Product__c field to the query
balajip        06/16/22         I2RT-6487   T15     removed unwanted commented code and the dummy method that was created for code coverage
Vignesh D      07/22/22         I2RT-6593   T16     Added Business_Impact__c and Estimated_Date_for_Milestone__c fields to the query
balajip        07/19/22         I2RT-6596   T17     accounted for Business Hours while calculating the response time for eOGR
Vignesh D      07/28/22         I2RT-6864   T18     SOQL injection fixed
Sandeep Duggi  July- 23-2022   I2RT-6741     T19      eSupport: hide delivery method of Hosted Single Tenant
balajip        08/24/22         I2RT-6871   T20     bypass Support Account Contact validation for Case Lite cases
Vignesh D      08/31/22         I2RT-6865   T21     Refactored method to accomodate Case Lite creation
Vignesh D      08/31/22         I2RT-6865   T22     Added new methods to fetch initial case details required for case lite creation
                          and ecommerce account contacts.
Sandeep D       09/15/22        I2RT-6869   T23     PayGo: eSupport - My Lite Cases & Case Details page
balajip        09/29/2022       I2RT-7200   T24     PayGo: eSupport - Fixed Accept/Decline Solution and Need More Time actions
Vignesh D      10/07/22         I2RT-7179   T25     Refactored and updated method to validate both Support Account &
                                                    Case Lite users
Amit Garg      10/07/2022       I2RT-7210   T26     PayGo: eSupport caselite detail page to have Add Alternate contact button
Vignesh D      10/25/22         I2RT-7256   T27   	Updated method to query and return list of org users
Vignesh D	   10/25/22			I2RT-7256	T28     Updated method to create case contacts
Vignesh D      10/31/22         I2RT-7424   T29   	Show subscription expired message when the user has access to the org.
Vignesh D      10/31/22         I2RT-7210   T30     Added caseId parameter and updated logic to verify case access before
													deleting case contact.
Vignesh D      11/08/22         I2RT-7456   T31   	Added filter condition to include only cases with support account
balajip        01/12/2023       I2RT-7537   T32     changed the sorting order based on Priority from Descending to Ascending 
                                                        while fetching all the cases for the given account.
balajip        01/24/23         I2RT-7224   T34   	Removed unused methods getReportInfo, caseCommentonDeletion, updateCaseContacts, getOGRDate, createCaseContactRecord, fetchExistingServiceAppointment
Vignesh D      03/22/23         I2RT-7749   T35   	Cancel zoom meeting when AAE case is cancelled.
Vignesh D      04/28/23         I2RT-6895   T36   	Use org entitled product junction object to fetch the orgs & its child orgs. 
Shashikanth    05/22/23         I2RT-8140   T37   	Attention Requests and Escalations: Avoid multiple requests.
Vignesh D      06/16/23         I2RT-8398   T38     Added filter to exclude Archived EPs.
Shashikanth    07/05/23         I2RT-8520   T39   	Regression-eSupport-IR communication on confirm case creation screen is incorrect.
Vignesh D      08/28/23         N/A         T40     checkmarx SOQL issue fix.
Vignesh D      09/20/23         I2RT-9063   T41     Replaced standard with custom object Service Appointment.
Shashikanth    10/16/23         I2RT-8987   T42     Need to show the escalate button always in eSupport
*/
public with sharing class CaseController {

    public static final String Hosted_Single_Tenant = 'Hosted Single Tenant'; // T19
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}

    public CaseController() {
        
    } 
    public static String accId;
    public static globalApexManager GAM = new globalApexManager();
    
    // eSupport portal get the support account
    @AuraEnabled(cacheable=true)
    public static List<selectOption> allSupportAccounts(){
        try {
            List<selectOption> supportAccounts = new List<selectOption>();
            for(AccountContactRelation account:getSupportAccWithRWAccess()){
                supportAccounts.add(new selectOption(account.Account.Name, account.Account.Id));                
            }
                    
            system.debug('supportAccounts= '+supportAccounts);
            return supportAccounts;
        } catch (Exception e) {
            system.debug('@@--e.getMessage()--->>'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // eSupport portal -get the support account
    @AuraEnabled(cacheable=true)
    public static List<WrapperSupportAcc> allSupportAccountswrp(){
        try {
            List<WrapperSupportAcc> lstwrpper=new List<WrapperSupportAcc>();
            WrapperSupportAcc objwrapacc;
            
            for(AccountContactRelation account:getAllSupportAcc()){
                objwrapacc= new WrapperSupportAcc();
                if(account.favorite__c)
                    objwrapacc.isBlnSUpportAccFav=true;
                else
                    objwrapacc.isBlnSUpportAccFav=false;
                objwrapacc.AccConRel=account;                                        
                lstwrpper.add(objwrapacc);//add value to list         
            }
            
            system.debug('supportAccounts= '+lstwrpper);
            return lstwrpper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //get all the Support Account
    public static list<AccountContactRelation> getAllSupportAcc(){
        //update all ACR record
        list<AccountContactRelation> lstACR=new list<AccountContactRelation>();
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<User> userContact = [SELECT Id, ContactId, Contact.AccountId FROM USER WHERE Id =: UserInfo.getUserId() and ContactId!=null];
        
        for(AccountContactRelation account: [SELECT Id, Account.Name,favorite__c, Account.End_Date__c FROM AccountContactRelation 
                                             WHERE Account.RecordTypeId=: SupportAccountRecType AND Account.Active__c = true
                                             AND ContactId =: userContact[0].ContactId  Order By  favorite__c  desc,Account.Name asc]){
                                                 if(account.Account.End_Date__c!=null){
                                                     if(system.today() <=  account.Account.End_Date__c.addDays(10)){
                                                         lstACR.add(account);  
                                                     }
                                                 }
                                                 
                                             }
        System.debug(' all suppo '+lstACR);
        return lstACR; 
    }
    
    //get Support Accounts where the Contact has ReadWrite Access to display on eSupport CaseCreation
    public static list<AccountContactRelation> getSupportAccWithRWAccess(){
        //update all ACR record
        list<AccountContactRelation> lstACR=new list<AccountContactRelation>();
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        List<User> userContact = [SELECT Id, ContactId, Contact.AccountId FROM USER WHERE Id =: UserInfo.getUserId()and ContactId!=null];
        
        for(AccountContactRelation account: [SELECT Id, Account.Name,favorite__c, Account.End_Date__c FROM AccountContactRelation 
                                             WHERE Account.RecordTypeId=: SupportAccountRecType AND Account.Active__c = true
                                             AND ContactId =: userContact[0].ContactId AND Access_Level__c = 'Read/Write'  Order By  favorite__c  desc,Account.Name asc]){
                                                 if(account.Account.End_Date__c!=null){
                                                     if(system.today() <=  account.Account.End_Date__c.addDays(10)){
                                                         lstACR.add(account);  
                                                     }
                                                 }
                                                 
                                             }
        System.debug(' all suppo '+lstACR);
        return lstACR; 
    }
    
    
    //get all the support account
    //update Accountcontact relationship record story#3053
    @AuraEnabled
    public static void updateAccountContactRel(id acrID){
        try{
            Boolean blnFlg=true;//set true
            list<AccountContactRelation> lstupdate=new list<AccountContactRelation>();
            for(AccountContactRelation account:getAllSupportAcc()){
                if( account.favorite__c){
                    account.favorite__c=false;
                    lstupdate.add(account);
                }
            }
            for(AccountContactRelation  varac: [select id from AccountContactRelation  where id=:acrID and favorite__c=true]){
                blnFlg=false;//set false
            }
            //update (remove favorite list) all the ACR
            if(lstupdate.size()>0)
                update lstupdate;
            
            AccountContactRelation objacr=new AccountContactRelation(id=acrID,favorite__c=blnFlg);
            Update objacr; 
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static string removeCurrentFiles(){
        try {
            //Remove files which are linked with contact
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() and ContactId!=null];
            List<Id> contentDocuments =  new List<Id>();
            for(ContentDocumentLink documentLink : [SELECT Id, ContentDocumentId from ContentDocumentLink Where LinkedEntityId =: currentUser.ContactId ]){
                contentDocuments.add(documentLink.ContentDocumentId);
            }
            if(!contentDocuments.isEmpty()){
                Delete [SELECT Id FROm ContentDocument WHERE ID IN: contentDocuments];
            }
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static caseFieldsDropdown getCaseFieldsDropdownOptions(){
        try {
            caseFieldsDropdown caseFieldsDropdownOptions = new caseFieldsDropdown();
            List<selectOption> activityOptions = new List<selectOption>();
            List<selectOption> environmentOptions = new List<selectOption>();
            List<selectOption> priorityOptions = new List<selectOption>();
            List<selectOption> problemTypeOptions = new List<selectOption>();
            List<selectOption> problemAreaOptions = new List<selectOption>();
            
            Schema.DescribeFieldResult fieldResult = Case.Activity_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                activityOptions.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
            }
            fieldResult = Case.Environment__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                environmentOptions.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
            }
            fieldResult = Case.Priority.getDescribe();
            ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                priorityOptions.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
            }
            fieldResult = Case.Problem_Type__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                problemTypeOptions.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
            }
            
            fieldResult = Case.Problem_Area__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                problemAreaOptions.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
            }
            
            caseFieldsDropdownOptions.activities = activityOptions;
            caseFieldsDropdownOptions.environments = environmentOptions;
            caseFieldsDropdownOptions.priorities = priorityOptions;
            caseFieldsDropdownOptions.problemTypes = problemTypeOptions;
            caseFieldsDropdownOptions.problemAreas = problemAreaOptions;
            for(User u: [SELECT Id,ContactId FROM USER WHERE ID=: UserInfo.getUserId()]){
                if(u.ContactId != null){
                    caseFieldsDropdownOptions.contactId = u.ContactId;
                }
            }
            //caseFieldsDropdownOptions.contactId = [SELECT Id,ContactId FROM USER WHERE ID=: UserInfo.getUserId() and ContactId!=null].ContactId;
            system.debug('caseFieldsDropdownOptions= '+caseFieldsDropdownOptions);
            return caseFieldsDropdownOptions;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createCase(string caseJson, String recordTypeName, List<AccountContactRelation> caseRelatedContacts, List<Case_Contact__c> lstCaseContactsToAdd, String environmentType, List<DateTime> slotSelected, List<String> product, String strOrgUUID){ //<T21> <T28>
        try {
            Case objCase = (Case) JSON.deserialize(caseJson, case.class);
            Id casePrimaryContactId = GlobalUtility.getCommunityUserContactId();
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            List<Case_Contact__c> lstCaseContactsToInsert = new List<Case_Contact__c>();
            List<ContentDocumentLink> lstContentDocumentLinksToAdd = new List<ContentDocumentLink>();
            List<ContentDocumentLink> lstContentDocumentLinksToDelete = new List<ContentDocumentLink>();
            
            if((recordTypeName != 'Case_Lite' && !CaseControllerWithoutSharing.isValidUser(null, objCase?.Support_Account__c, 'Read/Write')) || (recordTypeName == 'Case_Lite' && !SupportLiteSharing.validateUserAccess('Case','CREATE', strOrgUUID))){
                throw new CustomException('Insufficient access to create case');
            }
    
            if(recordTypeName != 'Case_Lite'){
               
                Id entitlementId;
                String productName;
                List<Account> parentAccount = CaseControllerWithoutSharing.getSupportAccount(objCase.Support_Account__c); //</T03>                 
                                
                    if(product.size() == 3){
                        productName = product[0]+'('+product[1]+')';
                        entitlementId = String.isNotEmpty(product[2]) ? product[2] : null;
                    }
                
                objCase.AccountId = parentAccount[0].ParentId;
                objCase.EntitlementId = parentAccount[0].Entitlement__c;
                objCase.Intial_Response_time__c = getCaseIRDateTime(objCase.Support_Account__c,objCase.Priority, recordTypeName, '', String.isNotEmpty(entitlementId) ? (String) entitlementId : '');
                
                if(entitlementId != null){
                    objCase.Entitled_Product__c = entitlementId;
                }
                else{
                    // KG - If selected EP is unentitled then create EP with below details
                    if(String.isNotEmpty(productName) && String.isNotEmpty(recordTypeName) && recordTypeName != 'Administrative'){ //Skip EP creation for Admin cases
                        Entitled_Product__c newEntitledProduct = new Entitled_Product__c();
                        String deliveryMethod = '';
                        Integer indexOfStartBracket = productName.lastIndexOf('(');
                        deliveryMethod = productName.substring(indexOfStartBracket +1, productName.length() -1);
                        newEntitledProduct.Name = productName;
                        newEntitledProduct.End_Date__c = system.today();
                        newEntitledProduct.Account__c = parentAccount[0].ParentId;
                        newEntitledProduct.Support_Account__c = objCase.Support_Account__c;
                        newEntitledProduct.Delivery_Method__c = deliveryMethod;
                        newEntitledProduct.Manual_Creation_override__c = true;
                        newEntitledProduct.Override_Entitlement_Date__c = true;
                        CaseControllerWithoutSharing.createEntitledProduct(newEntitledProduct); //<T06>
                        objCase.Unentitled_Product__c  = true;
                        objCase.Entitled_Product__c = newEntitledProduct.Id;
                    }
                    }
                    }
                
            if(recordTypeName == 'Case_Lite'){
                Org__c objOrg = CaseControllerWithoutSharing.getOrg(strOrgUUID);
                objCase.AccountId = objOrg.Account__c;
                objCase.Org__c = objOrg.Id;
                objCase.Delivery_Method_Overridden_Value__c = 'Hosted Multi Tenant';
                }
                
            objCase.ContactId = casePrimaryContactId;
            objCase.Is_AssignmentRules__c = true;
            objCase.Origin = 'Web';
            objCase.Next_Action__c = 'Case Owner';
            objCase.recordTypeId = caseRecordTypeId;

            //Create Case in system context
            CaseControllerWithoutSharing.createCase(objCase); //</T03>
            
            for(AccountContactRelation objAccountContactRelation : caseRelatedContacts){
                if(objAccountContactRelation.ContactId != casePrimaryContactId){ //CaseTrigger will handle adding case createdby contact as CaseContact. Skipping here to prevent duplicates.
                            Case_Contact__c caseContact = new Case_Contact__c();
                    caseContact.Case__c = objCase.Id;
                    caseContact.Contact__c = objAccountContactRelation.ContactId;
                    caseContact.Primary__c = objAccountContactRelation.Primary__c;
                    lstCaseContactsToInsert.add(caseContact);
                        }
                        }
              //---------------------------------------<T28>-------------------------------
              if(lstCaseContactsToAdd != null){
                for(Case_Contact__c objCaseContact : lstCaseContactsToAdd){
                    objCaseContact.Case__c = objCase.Id;
                    lstCaseContactsToInsert.add(objCaseContact);
                    }
              }
              //---------------------------------------<T28>-------------------------------
                    
            //Create Case Contacts in system context
            if(!lstCaseContactsToInsert.isEmpty()){
                CaseControllerWithoutSharing.createCaseContacts(lstCaseContactsToInsert); //</T03>
                }     
                
            initialResponseCaseComment(objCase.Id);
                
                if(String.isNotEmpty(environmentType) && recordTypeName == 'Operations' && slotSelected != null && slotSelected.size() > 0){
                OperationsSchedulerController.createServiceAppointment(objCase, slotSelected, 'Create');  
                }
                
            for(ContentDocumentLink objContentDocumentLink : [Select id,LinkedEntityId, ContentDocumentId, visibility,ShareType from ContentDocumentLink Where LinkedEntityId =: casePrimaryContactId]){
                ContentDocumentLink objContentDocumentLinkNew = new ContentDocumentLink();
                objContentDocumentLinkNew.ContentDocumentId = objContentDocumentLink.ContentDocumentId;
                objContentDocumentLinkNew.shareType = 'V';
                objContentDocumentLinkNew.visibility = 'AllUsers';
                objContentDocumentLinkNew.LinkedEntityId = objCase.Id;
                lstContentDocumentLinksToAdd.add(objContentDocumentLinkNew);
                lstContentDocumentLinksToDelete.add(objContentDocumentLink);
                }
                
            if(!lstContentDocumentLinksToAdd.isEmpty()){
                insert lstContentDocumentLinksToAdd;
                }
            if(!lstContentDocumentLinksToDelete.isEmpty()){
                delete lstContentDocumentLinksToDelete;
                }
            return objCase.Id;
        } catch (Exception e) {
            GAM.CreateExceptionRecords('CaseController.createCase', 'Error while creating case: ', e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createCaseGCS(string caseJson, String recordTypeName, String productName, String environmentType, List<DateTime> slotSelected){
        try{
            
            Id getCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            Case newCase = new Case();
            newCase = (Case) JSON.deserialize(caseJson, case.class);
            
            List<Entitled_Product__c> products = new List<Entitled_Product__c>();
            if(!String.isEmpty(productName)){
                products = [SELECT Id from Entitled_Product__c WHERE Name =:  productName AND Support_Account__c =: newCase.Support_Account__c LIMIT 1];
            }
            
            newCase.recordTypeId = getCaseRecordType;
            string IRTime = getCaseIRDateTime(newCase.Support_Account__c,newCase.Priority, recordTypeName, newCase.ContactId, products.size() > 0 ? (String) products[0].Id : '');
            newCase.Intial_Response_time__c = IRTime;
            
            if(products.size() > 0){
                newCase.Entitled_Product__c = products[0].Id;
            }
            else{
                if(String.isNotEmpty(productName) && String.isNotEmpty(recordTypeName) && recordTypeName != 'Administrative'){ //Skip EP creation for Admin cases
                    Entitled_Product__c newEntitledProduct = new Entitled_Product__c();
                    String deliveryMethod = '';
                    Integer indexOfStartBracket = productName.lastIndexOf('(');
                    deliveryMethod = productName.substring(indexOfStartBracket +1, productName.length() -1);
                    system.debug('deliveryMethod- '+deliveryMethod);
                    newEntitledProduct.Name = productName;
                    newEntitledProduct.End_Date__c = system.today();
                    newEntitledProduct.Account__c = newCase.AccountId;
                    newEntitledProduct.Support_Account__c = newCase.Support_Account__c;
                    newEntitledProduct.Delivery_Method__c = deliveryMethod;
                    newEntitledProduct.Manual_Creation_override__c = true;
                    newEntitledProduct.Override_Entitlement_Date__c = true;
                    Insert newEntitledProduct;
                    newCase.Unentitled_Product__c  = true;
                    newCase.Entitled_Product__c = newEntitledProduct.Id;                    
                }
            }
            Insert newCase;

            //I2RT-4416 - clone Case Contacts
            if(newCase.Cloned_From__c != null){
                List<Case_Contact__c> lstCaseContactSource = [Select Id, Contact__c, Primary__c, Email__c 
                                                                From Case_Contact__c 
                                                                Where Case__c = :newCase.Cloned_From__c
                                                                  And Contact__c != :newCase.ContactId];

                List<Case_Contact__c> lstCaseContactClone = new List<Case_Contact__c>();
                for(Case_Contact__c caseContactSource : lstCaseContactSource){
                    Case_Contact__c caseContactClone = new Case_Contact__c();
                    caseContactClone.Case__c = newCase.Id;
                    caseContactClone.Contact__c = caseContactSource.Contact__c;
                    caseContactClone.Primary__c = caseContactSource.Primary__c;
                    caseContactClone.Email__c = caseContactSource.Email__c;
                    lstCaseContactClone.add(caseContactClone);
                }

                if(!lstCaseContactClone.isEmpty()){
                    Database.insert(lstCaseContactClone, false);
                }
            }
            
            initialResponseCaseComment(newCase.Id);
            
            if(String.isNotEmpty(environmentType) && recordTypeName == 'Operations' && slotSelected != null && slotSelected.size() > 0){
                OperationsSchedulerController.createServiceAppointment(newCase, slotSelected, 'Create');  
            }
            
            return newCase.Id;
            
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static CaseDetail getCaseDetails(String caseId){
        try {
            Set<Id> contactIds = new Set<Id>();
            CaseDetail caseInfo = new CaseDetail();
            List<Case_Contact__c> caseContacts = new List<Case_Contact__c>();
            List<AccountContactRelation> accountContacts = new List<AccountContactRelation>();
            List<ContentDocumentLink> documentsToShow =  new List<ContentDocumentLink>();
            Map<Id,String> contentDownloadUrlMap =  new Map<Id,String>();
            ServiceAppointment sA = new ServiceAppointment();

            //I2RT-2674 Amarender - Added  Old_Case_Number__c, Escalated_Date__c to the SOQL Query  T23 starts
            Case caseRecord = CaseControllerWithoutSharing.getCase(caseId); 
            if((caseRecord.RecordType.DeveloperName == 'Case_Lite' && !SupportLiteSharing.validateUserAccess('Case','READ',caseRecord.Id)) || (caseRecord.RecordType.DeveloperName != 'Case_Lite' && !CaseControllerWithoutSharing.isValidUser(caseRecord.Id, null, ''))){
                throw new CustomException('Insufficient access to view the case');
            }
            // T23 ends
            caseContacts = caseRecord != null ? CaseControllerWithoutSharing.getCaseContacts((Id) caseId) : new List<Case_Contact__c>(); //</T03>
            
            for(Case_Contact__c cc : caseContacts){
                if(String.isNotEmpty(cc?.Contact__c)){
                    contactIds.add(cc.Contact__c);
                }
            }
            
            if(caseRecord?.Service_Appointment_AAE__c != null){
                sA = [SELECT Id, Case__c, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id =: caseRecord.Service_Appointment_AAE__c];
            }            
            
            String supportAccId = String.isNotEmpty(caseRecord?.Support_Account__c) ? caseRecord.Support_Account__c : null;    // T23
            
            if(String.isNotEmpty(supportAccId)){
                accountContacts = caseRecord != null ? CaseControllerWithoutSharing.getAssignedSupportAccountContacts((Id) supportAccId, contactIds) : new List<AccountContactRelation>(); //</T03>
            }
            
            documentsToShow = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.LastmodifiedDate, ContentDocument.CreatedBy.Name, ContentDocument.FileType from ContentDocumentLink Where LinkedEntityId =: caseId ];
            System.debug('@Developer --> documentsToShow :' + documentsToShow);
            for(ContentDistribution conDist : [SELECT Id,  ContentVersion.FirstPublishLocationId ,ContentDownloadUrl,ContentVersion.ContentDocumentId from ContentDistribution where ContentVersion.FirstPublishLocationId = :caseId ]){
                contentDownloadUrlMap.put(conDist.ContentVersion.ContentDocumentId, conDist.ContentDownloadUrl);
            }
            if(caseRecord.ClosedDate != null && caseRecord.ClosedDate.addDays(30) > system.today()){
                caseInfo.disableReOpen = false;
            } else {
                caseInfo.disableReOpen = true;
            }
            caseInfo.caseRecord = caseRecord;
            caseInfo.caseContacts = caseContacts;
            caseInfo.accountContacts = accountContacts;
            caseInfo.caseDocuments = documentsToShow;
            caseInfo.contentDownloadUrlMap = contentDownloadUrlMap;
            caseInfo.serviceAppointment = sA;
            setMilestoneFlags(caseInfo);         //<T37>
            
            //Amarender - Added as part of I2Rt-564 
            Map<String, Service_Cloud_General_Setting__mdt> serCloudSettings = Service_Cloud_General_Setting__mdt.getAll();
            caseInfo.tsftpLocationUrl = serCloudSettings.get('TSFTP_Location_Url') != null ? serCloudSettings.get('TSFTP_Location_Url').TSFTP_Url__c : '';
            //Amarender - Added as part of I2Rt-564 
            return caseInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //<T37>
    private static void setMilestoneFlags(CaseDetail caseInfo)
    {
        caseInfo.isActiveARMilestoneExists = null;
        caseInfo.isActiveIRMilestoneExists = false;

        String caseId = caseInfo.caseRecord.Id;
        List<CaseMilestone> caseMileStoneList =(List<CaseMilestone>)CaseControllerWithoutSharing.getSObjectRecords('SELECT Id,CaseId,MilestoneTypeId,IsCompleted,IsViolated,TargetResponseInMins,TimeRemainingInMins,ElapsedTimeInMins,TimeSinceTargetInMins,MilestoneType.Name FROM CaseMilestone WHERE CaseId =\''+caseId+'\' AND MilestoneType.Name  IN (\'Attention Request Response\',\'Initial Response\')');

        if(!(caseMileStoneList != null && caseMileStoneList.size() > 0))
        {
            return;
        }

        for(CaseMilestone milestoneDetail: caseMileStoneList )
        {
            if(milestoneDetail.MilestoneType.Name == 'Attention Request Response' 
                && caseInfo.isActiveARMilestoneExists != true)
            {
                if(!milestoneDetail.IsCompleted && !milestoneDetail.IsViolated)
                {
                    caseInfo.isActiveARMilestoneExists = true;
                }
                else if(caseInfo.isActiveARMilestoneExists == null)
                {
                    caseInfo.isActiveARMilestoneExists = false;
                }
            }
            else if(milestoneDetail.MilestoneType.Name == 'Initial Response' 
                    && !milestoneDetail.IsCompleted && !milestoneDetail.IsViolated
                    && (getDifferenceInMinutes(milestoneDetail.TargetResponseInMins, milestoneDetail.TimeRemainingInMins) <= 120))
            {
                caseInfo.isActiveIRMilestoneExists = true;
            }
        }

        //<T42>
        if(caseInfo.isActiveIRMilestoneExists)
        {
            caseInfo.irSLATime  =  getResponseTime(caseId, 'Initial Response');
        }
        //</T42>

        if(String.isNotBlank(caseInfo.caseRecord.Attention_Request__c))
        {
            caseInfo.arSLATime  =  getResponseTime(caseId, caseInfo.caseRecord.Attention_Request__c);
        }
    }

    private static double getDifferenceInMinutes(integer targetResponseInMins, string remainingTimeInMins)
    {
        String[] timeParts = remainingTimeInMins.split(':');
        double totalRemainingMinutes = 0;

        if(timeParts!=null)   
        {
            if(timeParts.size() > 0 && timeparts[0].isNumeric())
            {
                totalRemainingMinutes += Double.ValueOf(timeParts[0]);
            }
            if(timeParts.size() > 1 && timeparts[1].isNumeric())
            {
                totalRemainingMinutes += (Double.ValueOf(timeParts[1])/60);
            }
        }

        return (Double.ValueOf(targetResponseInMins) - totalRemainingMinutes);
    }
    //</T37>
    
    
    // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    @AuraEnabled
    public static Boolean getLiveAssistVisibility(String caseId) {
        System.debug('getLiveAssistVisibility caseId => ' + caseId);
        
        Boolean isVisible;
        
        List<Case> caseList = [SELECT Id, OwnerId 
                               FROM Case 
                               WHERE Id = :caseId 
                               AND RecordType.Name = 'Technical' 
                               AND Status IN ('Assess', 'Research')
                               AND Forecast_Product__c <> NULL
                               AND Forecast_Product__c <> ''
                               AND Entitled_Product__r.Business_Critical_Success_Plan__c = true 
                               LIMIT 1]; 
        System.debug('caseList (single case) -> ' + caseList); 
        
        isVisible = (caseList.isEmpty() || String.valueOf(caseList[0].OwnerId).startsWith('00G')) ? false : true;  
        
        return isVisible;
    }
    
    // Tejasvi Royal -> I2RT-1966: Live Assistance Request
    @AuraEnabled
    public static void confirmLiveAssistReason(String caseId, String requestReason){
        System.debug('confirmLiveAssistReason caseId => ' + caseId);
        
        List<Case> caseListUpdate = [SELECT Id, OwnerId, Live_Assistance_Request_Reason__c 
                                     FROM Case 
                                     WHERE Id = :caseId 
                                     AND RecordType.Name = 'Technical' 
                                     AND Status IN ('Assess', 'Research')
                                     AND Forecast_Product__c <> NULL
                                     AND Forecast_Product__c <> ''
                                     AND Entitled_Product__r.Business_Critical_Success_Plan__c = true 
                                     LIMIT 1];
        
        System.debug('caseList (single case) -> ' + caseListUpdate); 
        
        if(!caseListUpdate.isEmpty() && String.valueOf(caseListUpdate[0].OwnerId).startsWith('005')) {
            try {
                caseListUpdate[0].Live_Assistance_Request_Reason__c = requestReason;
                UPDATE caseListUpdate;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        //Deva: I2RT-3566 : Adding the logic to capture the live assistance request as case comment
        //call the Case Service method to raise the Live Assistane Comment
        CaseService.requestAttn(caseId, 'Live Assistance', 'Request to raise Live Assistance  <br/>' + requestReason,'',null);  
    }
    
    // Tejasvi Royal -> I2RT-2136: eSupport: Basic Support Technical Case Count Calculations
    @AuraEnabled
    public static String getESupportMetadataId() {        
        String recordIdToReturn = '';
        
        Map<String, Service_Cloud_General_Setting__mdt> gcs_meta = Service_Cloud_General_Setting__mdt.getAll();
        
        for(String currentRecId : gcs_meta.keySet()) {
            Service_Cloud_General_Setting__mdt currentRec = gcs_meta.get(currentRecId);
            if(currentRec.Developername == 'eSupport_Application_Cache') {
                recordIdToReturn = currentRec.Id;
            }
        }
        return recordIdToReturn;
    }
    
    // Tejasvi Royal -> I2RT-2136: eSupport: Basic Support Technical Case Count Calculations
    @AuraEnabled
    public static Integer getCaseCreatedCount_S1(String accId) {
        
        Integer caseCount_Default = -11;
        Integer caseCount = caseCount_Default;
        Integer caseCount_NotBasicSupportAccount = -2;
        //Integer caseCount_BasicSupportSelected_AND_MultipleSupportAccountsPresent = -3;
        
        User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() and ContactId!=null];
        
        if(loggedInUser.ContactId <> NULL) {          
            List<AccountContactRelation> multipleSupportAccountsList = [SELECT AccountId, ContactId, 
                                                                        Account.RecordType.Name, Account.Success_Offering__c
                                                                        FROM AccountContactRelation 
                                                                        WHERE ContactId = :loggedInUser.ContactId 
                                                                        AND IsActive = true 
                                                                        AND Account.RecordTypeId <> NULL
                                                                        AND Account.RecordType.Name = 'Support Account']; 
            //AND Account.Success_Offering__c <> ''
            //AND Account.Success_Offering__c <> 'Basic Success'
            
            List<Account> accountList = [SELECT Id, Number_of_Cases_Created__c, 
                                         RecordType.Name, Success_Offering__c 
                                         FROM Account 
                                         WHERE Id = :accId 
                                         AND RecordType.Name = 'Support Account' 
                                         AND Success_Offering__c = 'Basic Success' 
                                         LIMIT 1];
            
            if(!accountList.isEmpty() && multipleSupportAccountsList.size() >= 1) {                 
                caseCount = Integer.valueOf(accountList[0].Number_of_Cases_Created__c);
            }     
            if(accountList.isEmpty()) {
                caseCount = caseCount_NotBasicSupportAccount;
            }
        }       
        return caseCount;
    }
    
    // Tejasvi Royal -> I2RT-3285: eSupport: Basic Support Technical Case Count Calculations
    @AuraEnabled
    public static Integer getCaseCreatedCount_S2(String selectedAccId) {
        
        Integer caseCount_Default = -11;
        Integer caseCount = caseCount_Default;
        //Integer caseCount_NonBasicPacksPresent = -1;
        //Integer caseCount_NotBasicSupportAccount = -2;
        //Integer caseCount_MultipleSupportAccountsPresent = -3;
        //Integer caseCount_BasicSupportAccount_AND_SingleSupportAccountPresent = -4;
        Integer caseCount_NotBasicSupportAccount_AND_SingleSupportAccountPresent = -5;
        Integer caseCount_NotBasicSupportAccount_AND_MultipleSupportAccountsPresent = -6;
        
        User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() and ContactId!=null];
        
        if(loggedInUser.ContactId <> NULL) {          
            List<AccountContactRelation> multipleSupportAccountsList = [SELECT AccountId, ContactId, 
                                                                        Account.RecordType.Name, Account.Success_Offering__c
                                                                        FROM AccountContactRelation 
                                                                        WHERE ContactId = :loggedInUser.ContactId 
                                                                        AND IsActive = true 
                                                                        AND Account.RecordTypeId <> NULL
                                                                        AND Account.RecordType.Name = 'Support Account']; 
            //AND Account.Success_Offering__c <> ''
            //AND Account.Success_Offering__c <> 'Basic Success'
            
            List<Account> accountList = [SELECT Id, Number_of_Cases_Created__c, 
                                         RecordType.Name, Success_Offering__c 
                                         FROM Account 
                                         WHERE Id = :selectedAccId 
                                         AND RecordType.Name = 'Support Account' 
                                         AND Success_Offering__c = 'Basic Success' 
                                         LIMIT 1];
            
            if(!accountList.isEmpty() && multipleSupportAccountsList.size() >= 1) { // TRUTHY
                // IF: Selected Account is Basic Support AND More than 1 Support Account Present
                caseCount = Integer.valueOf(accountList[0].Number_of_Cases_Created__c);
            }
            if(accountList.isEmpty() && multipleSupportAccountsList.size() == 1) {  // FALSEY
                // IF: Selected Account is NOT Basic Support AND Single Support Account Present
                caseCount = caseCount_NotBasicSupportAccount_AND_SingleSupportAccountPresent;
            }
            if(accountList.isEmpty() && multipleSupportAccountsList.size() > 1) {  // FALSEY
                // IF: Selected Account is NOT Basic Support AND Multiple Support Accounts Present
                caseCount = caseCount_NotBasicSupportAccount_AND_MultipleSupportAccountsPresent;
            }
        }       
        return caseCount;
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> getUploadedFiles(){
        try {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() and ContactId!=null];
            List<ContentDocumentLink> documentsToShow =  new List<ContentDocumentLink>();
            documentsToShow = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.LastmodifiedDate, ContentDocument.CreatedBy.Name, ContentDocument.FileType from ContentDocumentLink Where LinkedEntityId =: currentUser.ContactId ];
            return documentsToShow;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> removeFile(String documentId, String caseId){
        try {
            List<ContentDocument> contentDocuments = new List<ContentDocument>();
            List<contentDocumentLink> documentLinks = new List<contentDocumentLink>();
            
            contentDocuments = [SELECT Id, Title FROM  ContentDocument WHERE Id=: documentId];
            //String filename = contentDocuments[0].Title;
            if(!contentDocuments.isEmpty()){
                delete contentDocuments;
            }
            if(!String.isEmpty(caseId)){
                return getRelatedFiles(caseId);                
            }
            return getUploadedFiles();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static UserAccountInfo getSupportAccountInfo(String accountId){
        
        System.debug('@AccountId- '+accountId);
        UserAccountInfo accountInfoWrapper = new UserAccountInfo();
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        List<AccountTeamMember> accountTeamMemberswrp = new List<AccountTeamMember>();
        List<AccountContactRelation> primaryContacts = new List<AccountContactRelation>();
        AccountMembersWrapper objwrapp=new AccountMembersWrapper();
        List<AccountMembersWrapper> accountMembersWrp=new List<AccountMembersWrapper>();
        List<Case> openCases = new List<Case>();
        List<Case> allOpenCases = new List<Case>();
        List<Case> allClosedCases = new List<Case>();
        
        //3053
        List<String> lstAccTeamRoleName=new List<String>();
        String strRoles='';
        String supportguidelink='';
        //get all the values from metadata
        Map<String, Service_Cloud_General_Setting__mdt> gcs_meta = Service_Cloud_General_Setting__mdt.getAll();
        //Iteterate thru loop
        for(String var : gcs_meta.keySet()) {
            if(var=='AccountTeam'){
                if(gcs_meta.get(var)!=null){
                    if(gcs_meta.get(var).RoleType__c!=null){
                        strRoles=gcs_meta.get(var).RoleType__c;         
                    }
                }
            }   
            if(var=='SupportGuide'){
                if(gcs_meta.get(var)!=null){
                    if(gcs_meta.get(var).SupportGuide__c!=null){
                        supportguidelink=gcs_meta.get(var).SupportGuide__c;         
                    }
                }
            }   
        }
        //get the role names
        if(strRoles!=''){
            lstAccTeamRoleName=strRoles.split(',');
            System.debug(lstAccTeamRoleName+' data '+strRoles );
        }
        //end 3053
        /*<T03>
        Id custID;//hold customer id 
        for(Account varAcc: [SELECT Id, parentid  FROM Account WHERE Id=: accountId]){
            custID=varAcc.parentid;//set Customer Id based on support Acc
        }</T03>*/
        //get logged user's contact id.
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() and ContactId!=null];//get contactid
        map<id,id> mapcaseId=new map<id,id>();//map to store caseid  
        for(Case_Contact__c varCCon:[select id,Contact__c,Case__c,Case__r.Support_Account__c FROM Case_Contact__c where
                                     Contact__c=:currentUser.ContactId and Case__r.Support_Account__c=:accountId
                                     and case__r.isClosed = false]){
                                         mapcaseId.put(varCCon.Case__c,varCCon.Case__c);
                                     }
        //  Account supportAccount = [SELECT Id, Success_Offering__c FROM Account WHERE Id=: accountId];
        
        
        accountTeamMembers = CaseControllerWithoutSharing.getAccountTeamMembers((Id) accountId,lstAccTeamRoleName); //</T03>
        map<string,string> mapRole=new map<string,string>();
        list<AccountMembersWrapper> lstAccountMembersWrp=new  list<AccountMembersWrapper>();
        list<AccountTeamMember> tempnew=new list<AccountTeamMember>();
        list<AccountTeamMember> temp=new list<AccountTeamMember>();
        map<string,list<AccountTeamMember>> mapval=new map<string,list<AccountTeamMember>>();
        for(AccountTeamMember varTeam: accountTeamMembers){
            
            temp=new list<AccountTeamMember>();
            temp.add(varTeam);
            if(mapval.get(varTeam.TeamMemberRole)==null){
                mapval.put(varTeam.TeamMemberRole,temp);//put role name and team member
            }else{
                tempnew=new   list<AccountTeamMember>();
                tempnew=(list<AccountTeamMember>)mapval.get(varTeam.TeamMemberRole);
                tempnew.add(varTeam);//add team member
                mapval.put(varTeam.TeamMemberRole,tempnew);        
            }
        }
        //iterate thru loop 
        for(string val:mapval.keyset()){
            objwrapp=new AccountMembersWrapper();
            objwrapp.strRoleName=val;
            objwrapp.accountMembers=mapval.get(val);
            lstAccountMembersWrp.add(objwrapp);
            
        }
        primaryContacts= CaseControllerWithoutSharing.getPrimarySupportAccountContacts((Id) accountId); // </T03>
        System.debug('@accountTeamMembers- '+accountTeamMembers);
        System.debug('@primaryContacts- '+primaryContacts);
        System.debug('@lstAccountMembersWrp- '+lstAccountMembersWrp);
        
        //get all the cases
        For(Case caseObj : [SELECT Id, Subject, Support_Account__c, Description, CaseNumber,Old_Case_Number__c, isClosed,NextAction__c,
                            Priority, Status, RecordType.Name, Forecast_Product__c,Case_Type__c, CreatedById,Next_Action__c 
                            FROM Case
                            WHERE Support_Account__c =: accountId 
                            And Is_Internal_Or_External_Case__c != 'Internal' AND Support_Account__c != null //<T31>
                            Order by NextAction__c   
                            DESC,Priority NULLS LAST]){ //T32
                                //check case created by logged-in user Next_Action__c
                                if(!caseObj.isClosed){
                                    if(caseObj.CreatedById == UserInfo.getUserId()){
                                        openCases.add(caseObj);//bind case created by loggedin user
                                    }else{
                                        if(mapcaseId.size()>0){
                                            if(mapcaseId.get(caseObj.id)!=null){
                                                openCases.add(caseObj);//bind the  case list tagged to loggedin user
                                            }
                                        }
                                        
                                    }
                                    
                                    // add all the cases assciated with supprt account
                                    allOpenCases.add(caseObj);
                                }else{
                                    allClosedCases.add(caseObj);
                                }
                            }
        
        accountInfoWrapper.accountMembersWrp=lstAccountMembersWrp.size()>0?lstAccountMembersWrp:new list<AccountMembersWrapper>();
        accountInfoWrapper.accountMembers = accountTeamMembers.size() > 0 ? accountTeamMembers : new List<AccountTeamMember>();
        accountInfoWrapper.primaryContacts = primaryContacts.size() > 0 ? primaryContacts : new List<AccountContactRelation>();
        accountInfoWrapper.myOpenCases = openCases;
        accountInfoWrapper.allOpenCases = allOpenCases; 
        accountInfoWrapper.allClosedCases = allClosedCases; 
        accountInfoWrapper.successOffering=primaryContacts.size() > 0?primaryContacts[0].account.Success_Offering__c:'';
        accountInfoWrapper.supportguide = supportguidelink;
        //  accountInfoWrapper.successOffering = supportAccount.Success_Offering__c;
        //return accwrapper
        return accountInfoWrapper;
        
    }
    
    @AuraEnabled
    public static List<AccountTeamMember> getAccountTeamMembers(String accountId){
        accountId = (accountId != null) ? String.escapeSingleQuotes(accountId) : accountId;
        
        List<AccountTeamMember> accountTeamMembers = [Select Id, AccountId, Account.Success_Offering__c, TeamMemberRole, User.Name, User.FirstName, User.LastName, User.Email, UserId, Product__c from AccountTeamMember where AccountId =: accountId]; //<T14>
        
        return accountTeamMembers;
    }
    
    //Amarender - I2RT-3151 - Added uploadComments parameter to the updateDocVersion Method Syntax
    @AuraEnabled
    public static CaseDetail updateDocVersion(String docToDelete, List<String> docToUpdate, String docDescription,String uploadComments,String caseId){
        try {
            system.debug('@@docToDelete= '+docToDelete);
            system.debug('@@docToUpdate= '+docToUpdate);
            system.debug('@@docDescription= '+docDescription);
            system.debug('@@caseId= '+caseId);
            CaseDetail caseInfo = new CaseDetail();
            List<ContentDocumentLink> documentsToShow =  new List<ContentDocumentLink>();
            Map<Id,String> contentDownloadUrlMap =  new Map<Id,String>();
            if(!string.isEmpty(docToDelete)){
                Delete [Select Id FROM ContentDocument WHERE Id=: docToDelete];
            }
            //Amarender - I2RT-3151 -- Modified Code to update description for multiple documents
            if(docToUpdate != null && !docToUpdate.isEmpty()){
                List<ContentDocument> updateDocuments = new List<ContentDocument>();
                for(ContentDocument document : [SELECT Id, Description FROM ContentDocument WHERE Id=: docToUpdate]){
                    document.Description = docDescription;
                    updateDocuments.add(document);
                }
                Update updateDocuments;
            }
            //Amarender - Added as part of I2RT-2908 - Start
            if(uploadComments != null && uploadComments != '' && uploadComments != 'undefined'){
                Case cse;
                cse = [Select Id,Status From Case where Id = :caseId];
                if(cse.Status == 'Solution'){
                    cse.Status = 'Research'; //Vignesh - I2RT-2796 - When case is in Solution and there is any inbound comment, change status to Research
                    update cse;
                }
                //<T05>
                else{
                    cse.Next_Action__c = 'Case Owner';   
                    update cse;
                }
                //</T05>
                Case_Comment__c newCaseComment= new Case_Comment__c();
                newCaseComment.Comment__c = uploadComments;         //Amarender - I2RT-3151 - Modified docDescription to uploadComments
                newCaseComment.Comment_Category__c = null;
                newCaseComment.Sub_Type__c = 'General Response';
                newCaseComment.Status__c = 'Submitted';
                newCaseComment.Inbound__c = true;
                newCaseComment.Visibility__c = 'External';
                newCaseComment.Case__c = caseId;
                insert newCaseComment;
            }
            //Amarender - Added as part of I2RT-2908 - End
            
            documentsToShow = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.LastmodifiedDate, ContentDocument.CreatedBy.Name, ContentDocument.FileType from ContentDocumentLink Where LinkedEntityId =: caseId ];

            for(ContentDistribution conDist : [SELECT Id,  ContentVersion.FirstPublishLocationId ,ContentDownloadUrl,ContentVersion.ContentDocumentId from ContentDistribution where ContentVersion.FirstPublishLocationId = :caseId ]){
                contentDownloadUrlMap.put(conDist.ContentVersion.ContentDocumentId, conDist.ContentDownloadUrl);
            }
            caseInfo.caseDocuments = documentsToShow;
            caseInfo.contentDownloadUrlMap = contentDownloadUrlMap;

            return caseInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Amarender - I2RT-4148 - Added method to create and Download Documents from eSupport
    @AuraEnabled
    public static String generateDownloadUrl(Id contentDocumentId){
        try {
            ContentVersion conVer = [Select Id,Title From ContentVersion where ContentDocumentId = :contentDocumentId and IsLatest=true Limit 1];
            ContentDistribution  cdl = new ContentDistribution ();
            cdl.ContentVersionId = conVer.Id;
            cdl.PreferencesNotifyOnVisit = false;
            cdl.name = conVer.Title;
            upsert cdl;
            cdl = [Select Id,ContentDownloadUrl From ContentDistribution where Id = :cdl.Id Limit 1];
            return cdl.ContentDownloadUrl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Amarender - I2RT-3151 - Added method for Delete Documents
    @AuraEnabled
    public static String deleteDoc(List<String> deleteDocuments){
        try {
            if(deleteDocuments != null && !deleteDocuments.isEmpty()){
                Delete [Select Id FROM ContentDocument WHERE Id in  :deleteDocuments];
            }
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String removeCaseContact(String caseContactId, String caseId){ //<T30>
        try{
            //---------------------------------------<T30>-------------------------------
            Case objCase = CaseControllerWithoutSharing.getCase((Id) caseId);
            //Now, we validate the user's access to delete case contact
            String strCaseAccessMessage = CaseController.getCaseAccess(objCase.Id, 'Read/Write');
            if(String.isNotBlank(strCaseAccessMessage) && !Test.isRunningTest()){
                throw new CustomException(strCaseAccessMessage);
            }
            CaseControllerWithoutSharing.deleteCaseContact((Id) caseContactId);
            //---------------------------------------<T30>-------------------------------
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> getRelatedFiles(String caseId){
        try {
            List<ContentDocumentLink> documentsToShow =  new List<ContentDocumentLink>();
            documentsToShow = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.Description, ContentDocument.LastmodifiedDate, ContentDocument.CreatedBy.Name, ContentDocument.FileType from ContentDocumentLink Where LinkedEntityId =: caseId ];
            return documentsToShow;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Case reOpenCase(Id caseId, String reopenReason){
        try {
            
            Id supportAccId;
            Case caseToDisplay = new Case();
            reopenReason = escapeHtml(escapeQuotes(reopenReason));
            Boolean HasAccess = CaseControllerWithoutSharing.isValidUser(caseId, supportAccId, 'Read/Write'); //</T03>
            if(HasAccess){
                Case closedCase = CaseControllerWithoutSharing.getCase(caseId); //</T03>
            
                Case reOpenedCase = new Case();
                reOpenedCase.ParentId = closedCase.Id;
                reOpenedCase.Subject = closedCase.Subject;
                reOpenedCase.Description = closedCase.Description;
                reOpenedCase.Error_Message__c = closedCase.Error_Message__c;
                reOpenedCase.Priority = closedCase.Priority;
                reOpenedCase.Is_Reopened__c = true;
                if(closedCase.Forecast_Product__c != null){
                    reOpenedCase.Forecast_Product__c = closedCase.Forecast_Product__c;
                }
                if(closedCase.Version__c != null){
                    reOpenedCase.Version__c = closedCase.Version__c;
                }
                if(closedCase.Component__c != null){
                    reOpenedCase.Component__c = closedCase.Component__c;
                }
                if(closedCase.Subcomponent__c != null){
                    reOpenedCase.Subcomponent__c = closedCase.Subcomponent__c;
                }
                if(closedCase.Problem_Type__c != null){
                    reOpenedCase.Problem_Type__c = closedCase.Problem_Type__c;
                }
                if(closedCase.Entitled_Product__c != null){
                    reOpenedCase.Entitled_Product__c = closedCase.Entitled_Product__c;
                }   
                // Start T08
                if(closedCase.Org__c != null){
                    reOpenedCase.Org__c = closedCase.Org__c;
                }
                if(closedCase.Org_ID__c != null){ // <T11>
                    reOpenedCase.Org_ID__c = closedCase.Org_ID__c ;
                }
                // End T08
                reOpenedCase.Secure_Agent__c = closedCase.Secure_Agent__c;
                reOpenedCase.RecordTypeId = closedCase.RecordTypeId;
                reOpenedCase.AccountId = closedCase.AccountId;
                reOpenedCase.ContactId = closedCase.ContactId;
                reOpenedCase.Support_Account__c = closedCase.Support_Account__c;
                reOpenedCase.EntitlementId = closedCase.EntitlementId;
                reOpenedCase.Is_AssignmentRules__c = true;
                reOpenedCase.Environment__c = closedCase.Environment__c;
                reOpenedCase.Activity_Type__c = closedCase.Activity_Type__c;
                string recordTypeName =Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosById().get(reOpenedCase.RecordTypeId).getName();
                string IRTime = getCaseIRDateTime(reOpenedCase.Support_Account__c,reOpenedCase.Priority, recordTypeName, reOpenedCase.ContactId,  reOpenedCase.Entitled_Product__c);
                if(!String.isEmpty(IRTime)){
                    reOpenedCase.Intial_Response_time__c = IRTime;
                }
                CaseControllerWithoutSharing.createCase(reOpenedCase); //</T03>
                // Adding the closed case contact to reopended Case with old conid.
                List<Case_Contact__c> caseContactsToInsert = new List<Case_Contact__c>();

                // Adding the closed case contact to reopended Case.            
                Id closedCaseContactId = closedCase.ContactId;

                for(Case_Contact__c caseContact : CaseControllerWithoutSharing.getCaseContacts(closedCase.Id)){//</T03>
                    Case_Contact__c reOpnedCaseContact = new Case_Contact__c();
                    reOpnedCaseContact.Contact__c = caseContact?.Contact__c;
                    reOpnedCaseContact.Case__c = reOpenedCase.Id;
                    reOpnedCaseContact.Email__c = caseContact?.Email__c;
                    reOpnedCaseContact.Primary__c = caseContact?.Primary__c;
                    if(String.isEmpty(caseContact.Contact__c) || (String.isNotEmpty(caseContact.Contact__c) && closedCaseContactId != caseContact.Contact__c)){
                        caseContactsToInsert.add(reOpnedCaseContact);
                    }     
                }
                if(!caseContactsToInsert.isEmpty()){
                    CaseControllerWithoutSharing.createCaseContacts(caseContactsToInsert); //</T03>
                }
                
                List<ContentDocumentLink> documentLinksToAdd = new List<ContentDocumentLink>();
                for(ContentDocumentLink file: [Select id,LinkedEntityId, ContentDocumentId, visibility,ShareType from ContentDocumentLink Where LinkedEntityId =: caseId]){
                    ContentDocumentLink newDocumentLink = new ContentDocumentLink();
                    newDocumentLink.ContentDocumentId = file.ContentDocumentId;
                    newDocumentLink.shareType = file.ShareType; //'V';
                    newDocumentLink.visibility = file.visibility; //'AllUsers';
                    newDocumentLink.LinkedEntityId = reOpenedCase.Id;
                    documentLinksToAdd.add(newDocumentLink);
                }
                
                if(!documentLinksToAdd.isEmpty()){
                    insert documentLinksToAdd;
                }
                
                caseToDisplay = [SELECT ID, CaseNumber FROM Case where Id =: reOpenedCase.Id];
                
                CaseControllerWithoutSharing.initialResponseCaseComment(caseToDisplay.Id);
                
                List<Case_Comment__c> lstComments = new List<Case_Comment__c>();
                Case_Comment__c newCaseComment= new Case_Comment__c();
                newCaseComment.Comment_Category__c = 'General Comments';
                newCaseComment.Comment__c = 'Reopen Requested. Old Case # '+closedCase.CaseNumber+'.<br>'+reopenReason;
                newCaseComment.Status__c = 'Submitted';
                newCaseComment.Sub_Type__c = 'Initial Response';
                newCaseComment.Visibility__c = 'External';
                newCaseComment.Case__c = reOpenedCase.Id;
                lstComments.add(newCaseComment);
                
                Case_Comment__c oldCaseComment = new Case_Comment__c();
                oldCaseComment.Comment_Category__c = 'General Comments';
                oldCaseComment.Comment__c = 'Reopen Requested. New Case # '+caseToDisplay.CaseNumber+'.<br>'+reopenReason;
                oldCaseComment.Inbound__c = false;
                oldCaseComment.Status__c = 'Submitted';
                oldCaseComment.Sub_Type__c = 'General Response';
                oldCaseComment.Visibility__c = 'External';
                oldCaseComment.Case__c = closedCase.Id;
                lstComments.add(oldCaseComment);
                
                Insert lstComments;
            }
            
            return caseToDisplay;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Vignesh D: Method to get response datetime for Callback/Revise Priority and Escalation
    @AuraEnabled
    public static Datetime getResponseTime(String caseId, String type){
        try{
            DateTime targetDate;
            caseId = escapeQuotes(caseId);
            type = escapeQuotes(type);
            
            if(!String.isEmpty(caseId) && !String.isEmpty(type)){
                if(type == 'Callback' || type == 'Revise Priority'){
                    for(CaseMilestone cm : [Select Id,TargetDate from CaseMilestone where CaseId =: caseId and MilestoneType.Name = 'Attention Request Response' order by CreatedDate DESC LIMIT 1 ]){
                        targetDate = cm?.TargetDate;
                    } 
                }
                else if(type == 'Escalation'){
                    for(CaseMilestone cm : [Select Id,TargetDate from CaseMilestone where CaseId =: caseId and MilestoneType.Name = 'Escalation Response' order by CreatedDate DESC LIMIT 1 ]){
                        targetDate = cm?.TargetDate;
                    }
                }
                //<T42>
                else if(type == 'Initial Response'){
                    for(CaseMilestone cm : [Select Id,TargetDate from CaseMilestone where CaseId =: caseId and MilestoneType.Name = 'Initial Response' order by CreatedDate DESC LIMIT 1 ]){
                        targetDate = cm?.TargetDate;
                    }
                }
                //</T42>
            }
            return targetDate;     
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> getAcceptedFileFormates(){
        try {
            List<String> acceptedFormates = new List<String>();
            List<Accepted_File_Type__mdt> fileFormates = New List<Accepted_File_Type__mdt>();
            fileFormates = [SELECT Id, Developername from Accepted_File_Type__mdt];
            if(!fileFormates.isEmpty()){
                for(Accepted_File_Type__mdt fileFormate : fileFormates){
                    acceptedFormates.add('.'+fileFormate.Developername);
                }
            }
            return acceptedFormates;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Create case comment when new case is created.
    @AuraEnabled
    Public static void initialResponseCaseComment(String caseId){
        try{
            if(!String.isEmpty(caseId)){
                CaseControllerWithoutSharing.initialResponseCaseComment((Id) caseId); //</T03>
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        
    //Vignesh D: I2RT-3426
    @AuraEnabled
    public static String getCaseIRDateTime(String supportAccId, String casePriority, String recordTypeName, String primaryCaseContactId, String entitlementId){
        try{
            
            Id usrTimeZoneID;
            String caseTimeZoneName = '';
            String timeZoneName = '';
            String IRDateTime = '';
            String caseSupportAddOn = '';
            
            //Escape string characters from user.
            supportAccId = escapeQuotes(supportAccId);
            casePriority = escapeQuotes(casePriority);
            recordTypeName = escapeQuotes(recordTypeName);
            primaryCaseContactId = escapeQuotes(primaryCaseContactId);
            
            //Get entitlement process from the support account
            Account acc = CaseControllerWithoutSharing.getSupportAccount((Id) supportAccId)[0];

            //Get Entitled Product to check BCSP/XS case
            if(String.isNotEmpty(entitlementId)){
                caseSupportAddOn = [Select Id,Name,Business_Critical_Success_Plan__c from Entitled_Product__c where Id =: entitlementId]?.Business_Critical_Success_Plan__c ? 'BCSP' : '';
            }
            
            //Get timezone from community user's contact record (or) get timezone from primary case contact
            if(String.isEmpty(primaryCaseContactId)){
                User communityUser = [Select Id,ContactId,Contact.TimeZone_Lookup__c from User where Id =: UserInfo.getUserId() and ContactId!=null];
                usrTimeZoneID = communityUser?.Contact?.TimeZone_Lookup__c;
            }
            else{
                Contact casePrimaryContact = CaseControllerWithoutSharing.getContact((Id) primaryCaseContactId); //</T03>
                usrTimeZoneID = casePrimaryContact?.TimeZone_Lookup__c;
            }
            
            if(String.isEmpty(usrTimeZoneID)){
                //User usr = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId() and ContactId!=null];
                timeZoneName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId() and ContactId!=null]?.TimeZoneSidKey;
                /*for(TimeZone__c timezone : [Select Id,Name,TimeZoneSidKey__c from TimeZone__c where TimeZoneSidKey__c =: usr.TimeZoneSidKey]){
                timeZoneName = timezone?.Name;
                }*/
            }
            else{
                for(TimeZone__c timezone : [Select Id,Name,TimeZoneSidKey__c from TimeZone__c where Id =: usrTimeZoneID]){
                    timeZoneName = timezone?.TimeZoneSidKey__c;
                }
            }
            
            //determine timezone to consider based on entitlement process
            if(String.isNotEmpty(acc?.Entitlement__r?.Support_Level__c)){
                if(acc.Entitlement__r.Support_Level__c == 'Signature Success' || acc.Entitlement__r.Support_Level__c == 'Premium Success' || acc.Entitlement__r.Support_Level__c == 'Signature Select'){ //<T07>
                    caseTimeZoneName = timeZoneName;
                }
                else if(acc.Entitlement__r.Support_Level__c == 'Standard' || acc.Entitlement__r.Support_Level__c == 'Basic Success'){
                    caseTimeZoneName = acc?.TimeZone__r?.TimeZoneSidKey__c;
                }
            }
            
            if(String.isNotEmpty(acc?.Entitlement__r?.Support_Level__c) && String.isNotEmpty(caseTimeZoneName)){
                if(acc.Entitlement__r.Support_Level__c == 'Signature Success' || acc.Entitlement__r.Support_Level__c == 'Signature Select'){ //<T07>
                    if(/*acc?.Support_Add_On__c == 'BCSP'*/ caseSupportAddOn == 'BCSP' && (recordTypeName == 'Technical' || recordTypeName == 'Operations')){
                        if(casePriority == 'P1'){
                            //15mins
                            IRDateTime = caseControllerHelper.ResponseDate(15,caseTimeZoneName);
                        }
                        else if(casePriority == 'P2'){
                            //60mins
                            IRDateTime = caseControllerHelper.ResponseDate(60,caseTimeZoneName);
                        }
                        else if(casePriority == 'P3'){
                            //240mins
                            IRDateTime = caseControllerHelper.ResponseDate(240,caseTimeZoneName);
                        }
                    }
                    else{
                        if(casePriority == 'P1'){
                            //30mins
                            IRDateTime = caseControllerHelper.ResponseDate(30,caseTimeZoneName);
                        }
                        else if(casePriority == 'P2'){
                            //120mins
                            IRDateTime = caseControllerHelper.ResponseDate(120,caseTimeZoneName);
                        }
                        else if(casePriority == 'P3'){
                            //480mins
                            IRDateTime = caseControllerHelper.ResponseDate(480,caseTimeZoneName);
                        }
                    }
                }
                else if(acc.Entitlement__r.Support_Level__c == 'Premium Success'){
                    if(/*acc?.Support_Add_On__c == 'BCSP'*/ caseSupportAddOn == 'BCSP' && (recordTypeName == 'Technical' || recordTypeName == 'Operations')){
                        if(casePriority == 'P1'){
                            //30mins
                            IRDateTime = caseControllerHelper.ResponseDate(30,caseTimeZoneName);
                        }
                        else if(casePriority == 'P2'){
                            //120mins
                            IRDateTime = caseControllerHelper.ResponseDate(120,caseTimeZoneName);
                        }
                        else if(casePriority == 'P3'){
                            //240mins
                            IRDateTime = caseControllerHelper.ResponseDate(240,caseTimeZoneName);
                        }
                    }
                    else{
                        if(casePriority == 'P1'){
                            //60mins
                            IRDateTime = caseControllerHelper.ResponseDate(60,caseTimeZoneName);
                        }
                        else if(casePriority == 'P2'){
                            //240mins
                            IRDateTime = caseControllerHelper.ResponseDate(240,caseTimeZoneName);
                        }
                        else if(casePriority == 'P3'){
                            //480mins
                            IRDateTime = caseControllerHelper.ResponseDate(480,caseTimeZoneName);
                        }
                    }
                }
                else if(acc.Entitlement__r.Support_Level__c == 'Standard'){
                    if(casePriority == 'P1'){
                        //240mins
                        IRDateTime = caseControllerHelper.ResponseDate(240,caseTimeZoneName);    //<T39>   
                    }
                }
                else if(acc.Entitlement__r.Support_Level__c == 'Basic Success'){
                    if(casePriority == 'P1'){
                        //960mins
                        IRDateTime = caseControllerHelper.ResponseDate(960,caseTimeZoneName);
                    }
                }
            }
            
            return IRDateTime;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    //gets the list of Co-owners from the given Case Team
    @AuraEnabled
    public static Map<String, String> getCoOwners(String caseId){
        System.debug('caseId = ' + caseId);
        
        List<Case_Team__c> lstCaseTM =  [Select Id, Case__c, User__c, User__r.Name, Role__c From Case_Team__c 
                                         Where Case__c = :caseId
                                         And Role__c = :CaseTeamService.TEAM_ROLE_CO_OWNER];
        
        Map<String, String> mapCoOwnerIdToName = new Map<String, String>();
        for(Case_Team__c caseTM : lstCaseTM){
            mapCoOwnerIdToName.put(caseTM.User__c, caseTM.User__r.Name);
        }
        
        return mapCoOwnerIdToName;
    }
    
    //changes the owner of the given Case
    @AuraEnabled
    public static void switchOwner(String caseId, String newOwnerId){
        System.debug('caseId = ' + caseId);
        System.debug('newOwnerId = ' + newOwnerId);
        
        try {
            //call the Case Service method to switch the owner
            CaseService.switchOwner(caseId, newOwnerId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //raises attention request for the given case
    @AuraEnabled
    public static void requestAttn(String caseId, String requestType, String comment,String selectedImapact,Date estimateDate){
        System.debug('caseId = ' + caseId);
        
        // try {
        String caseComment = '';
        if(!String.isEmpty(comment)){
            caseComment = comment;
        }
        //call the Case Service method to raise the attention request
        CaseService.requestAttn(caseId, requestType, caseComment,selectedImapact,estimateDate);
    }
    
    //escalates the given set of cases
    @AuraEnabled
    public static void escalateCase(String caseIds, String reason, String comment){
        System.debug('escalateCase caseIds = ' + caseIds);
        
        Set<Id> setCaseId = new Set<Id>();
        for(String caseId:caseIds.split(',')){
            if(!String.isEmpty(caseId)){
                setCaseId.add(Id.valueOf(caseId));
            }
        }
        
        try {
            //call the Case Service method to escalate the given set of cases.
            CaseService.escalate(setCaseId, reason, comment);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getAllProducts(String accountId)
    {
        System.debug('getAllProducts-accountId->'+accountId);
        accId=accountId;
        List<String> productOptions= new List<String>();
        List<Entitled_product__c> eplist;
        Map<Id,Product2> mapIdToProduct2=new Map<Id,Product2>();
        Set<String> unepset = new Set<String>(); 
        Set<String> epset = new Set<String>();
        List<String> lstDeliveryMethod;
        Set<String> technicalProducts = new Set<String>();//</T02>
        Map<Id, Technical_Product_Line__c> technicalProductLineMap = new Map<Id, Technical_Product_Line__c>();//</T02>

        //</T02> Query technical product line
        for(Technical_Product_Line__c TP : [Select Id,Name,Delivery_Method__c from Technical_Product_Line__c Where status__c = 'Active' order by Name ASC]){
            technicalProductLineMap.put(TP.Id, TP);
            if(String.isNotEmpty(TP?.Name)){
                String productName;
                if(TP.Delivery_Method__c.contains(';')){
                    for(String DM : TP.Delivery_Method__c.split(';')){
                        productName = TP.Name+'('+DM+')';
                        technicalProducts.add(productName);
                    }
                }
                else{
                    productName = TP.Name+'('+TP.Delivery_Method__c+')';
                }
                technicalProducts.add(productName);
            }
        }
        //</T02>

        eplist = new List<Entitled_product__c>([SELECT Id,Name,End_Date__c  from Entitled_product__c where Support_Account__c = : accountId AND Archived__c = false]); //<T38>
        system.debug('entiled product list:'+eplist);
        
        for(Entitled_product__c e : eplist){   
            
            if(technicalProducts.contains(e?.Name)){//</T02>
                //KG
                Date epEndDate ;
                if(e.End_Date__c!=null){
                    epEndDate = e.End_Date__c.addDays(10);
                }
                if(epEndDate >= System.TODAY()){
                    epset.add(e.Name);
                }
            }
            
        } 
        
        if(!epset.isEmpty())
        {
            productOptions.add('----Entitled Products----');
            productOptions.addAll(epset);
            productOptions.sort();
        }
        productOptions.add('----Unentitled Products----');
        
        for(Technical_Product_Line__c tp : technicalProductLineMap.values())
        {
            if(tp!=null && tp.Name!=null && tp.delivery_method__c!=null)
            {
                lstDeliveryMethod=new List<String>();
                if(tp.delivery_method__c.contains(';'))
                {
                    lstDeliveryMethod=tp.delivery_method__c.split(';');
                    
                    if(!lstDeliveryMethod.isEmpty())
                    {
                        for(String dm: lstDeliveryMethod)
                        {
                            if(!epset.contains(tp.Name +'('+ dm + ')'))
                            {
                                productOptions.add(tp.Name +'('+ dm + ')');
                            }
                            
                        }
                    }
                }else {
                    if(!epset.contains(tp.Name +'('+ tp.delivery_method__c + ')'))
                    {
                        productOptions.add(tp.Name +'('+ tp.delivery_method__c + ')');
                    }
                }
            }
        }
        System.debug('productOptions-->'+productOptions);
        return productOptions;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getAllProductsinternal()
    {
        
        
        List<String> productOptions = new List<String>();
        for(Technical_Product_Line__c tp :[select Id,Name,delivery_method__c from Technical_Product_Line__c Where status__c = 'Active'])
        {
            productOptions.add(tp.Name);
        }
        
        return productOptions;
        
    }
    
    public class ProductWrapper{
        @AuraEnabled
        public String productName {get; set;}
        @AuraEnabled
        public Map<String, String> deliveryMethodEntIdMap {get; set;}
        @AuraEnabled
        public Boolean isEntitledProduct {get; set;}
    }
    
    //Vignesh D: I2RT-4203
    @AuraEnabled
    public static List<ProductWrapper> getProducts(Id supportAccId){
        
        Set<String> technicalProducts = new Set<String>();
        List<ProductWrapper> products = new List<ProductWrapper>();
        Map<String, ProductWrapper> entitledProducts = new Map<String, ProductWrapper>();
        Map<String, ProductWrapper> unEntitledProducts = new Map<String, ProductWrapper>();
        Map<Id, Technical_Product_Line__c> technicalProductLineMap = new Map<Id, Technical_Product_Line__c>();

        //Query technical product line
        for(Technical_Product_Line__c TP : [Select Id,Name,Delivery_Method__c from Technical_Product_Line__c where status__c = 'Active'order by Name ASC]){
            technicalProductLineMap.put(TP.Id, TP);
            if(String.isNotEmpty(TP?.Name)){
                String productName;
                if(TP.Delivery_Method__c.contains(';')){
                    for(String DM : TP.Delivery_Method__c.split(';')){
                        productName = TP.Name+'('+DM+')';
                        technicalProducts.add(productName);
                    }
                }
                else{
                    productName = TP.Name+'('+TP.Delivery_Method__c+')';
                }
                technicalProducts.add(productName);
            }
        }
        
        //Query entitled products
        for(Entitled_Product__c EP : [Select Id,Name,Delivery_Method__c,End_Date__c from Entitled_Product__c where Support_Account__c =: supportAccId AND Archived__c = false order by Name ASC]){ //<T38>
            
            if(String.isNotEmpty(EP?.Name) && String.isNotEmpty(EP?.Delivery_Method__c) && technicalProducts.contains(EP?.Name)){
                if(EP?.End_Date__c != null){
                    
                    //If product is in grace period, include it to the list
                    if(EP.End_Date__c.addDays(10) >= System.today()){
                        
                        String deliveryMethod = '('+EP.Delivery_Method__c+')';
                        String productName = EP.Name.contains(deliveryMethod) ? EP.Name.remove(deliveryMethod) : EP.Name;
                        
                        if(entitledProducts.containsKey(productName)){
                            ProductWrapper product = new ProductWrapper();
                            product.productName = productName;
                            product.deliveryMethodEntIdMap = entitledProducts.get(productName).deliveryMethodEntIdMap;
                            product.deliveryMethodEntIdMap.put(EP.Delivery_Method__c, EP.Id);
                            product.isEntitledProduct = true;
                            
                            entitledProducts.put(productName, product);
                        }
                        else{
                            ProductWrapper product = new ProductWrapper();
                            product.deliveryMethodEntIdMap = new Map<String, String>();
                            product.productName = productName;
                            product.deliveryMethodEntIdMap.put(EP.Delivery_Method__c, EP.Id);
                            product.isEntitledProduct = true;
                            
                            entitledProducts.put(productName, product);
                        }
                    }
                }
            }
        }
        
        for(Technical_Product_Line__c TP: technicalProductLineMap.values()){
            
            if(String.isNotEmpty(TP?.Name)){
                if(!entitledProducts.containsKey(TP.Name)){
                    
                    if(TP.Delivery_Method__c.contains(';')){
                        ProductWrapper product = new ProductWrapper();
                        product.deliveryMethodEntIdMap = new Map<String, String>();
                        product.productName = TP.Name;
                        for(String DM : TP.Delivery_Method__c.split(';')){
                            if(DM != Hosted_Single_Tenant){ 
                            product.deliveryMethodEntIdMap.put(DM, '');
                            }
                            product.isEntitledProduct = false;
                        }
                        
                        unEntitledProducts.put(TP.Name, product);
                    }
                    else{
                        if(TP.Delivery_method__c != Hosted_Single_Tenant){   // T19
                        ProductWrapper product = new ProductWrapper();
                        product.deliveryMethodEntIdMap = new Map<String, String>();
                        product.productName = TP.Name;
                        product.deliveryMethodEntIdMap.put(TP.Delivery_Method__c, '');
                        product.isEntitledProduct = false;
                        
                        unEntitledProducts.put(TP.Name, product);
                    }
                }
            }
        }
        }
        
        if(entitledProducts.values().size() > 0){
            products.addAll(entitledProducts.values());
        }
        if(unEntitledProducts.values().size() > 0){
            products.addAll(unEntitledProducts.values());
        }
        
        for(ProductWrapper p : products){
            System.debug('Product--> '+p);
        }
        return products;
    }
    
    @AuraEnabled
    public static list<AccountContactRelation> getAccountRelatedContacts(String recordId){
        try {
            system.debug('accountId= '+recordId);
            //List<Id> accountIds = new List<Id>();
            List<AccountContactRelation> contacts = new List<AccountContactRelation>();
            Id ContactId = [Select Id,ContactId from User Where Id =: UserInfo.getUserId()]?.ContactId;
            for(AccountContactRelation ACR : CaseControllerWithoutSharing.getSupportAccountContacts((Id) recordId)){//</T03>
                if(String.isEmpty(ContactId) || (String.isNotEmpty(ContactId) && ACR.ContactId != ContactId)){
                    contacts.add(ACR);
                }
            }
            return contacts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getVersionforSelectedProduct(String selectedProduct)
    {
        List<Technical_Product_Line__c> lstTP=new List<Technical_Product_Line__c>();
        List<String> lstVersion= new List<String>();
        String finalProduct='';
        System.debug('Entry--Product selected->'+selectedProduct);
        
        finalProduct=selectedProduct;
        if(finalProduct!='')
        {
            finalProduct=finalProduct.trim();
            lstTP=[select Id,Name,delivery_method__c,Version__c from Technical_Product_Line__c WHERE Name=: finalProduct And status__c = 'Active'limit 1];
            System.debug('lstTP-->'+lstTP);
            if(!lstTP.isEmpty())
            {
                for(Technical_Product_Line__c tp:lstTP)
                {
                    if(tp.Version__c!=null && tp.Version__c!='')
                    {
                        lstVersion=tp.Version__c.split(';');
                        
                    }
                }
            }
        }
        List<String> finalList = new List<String>();
        System.debug('lstVersion-->'+lstVersion);
        if(lstVersion.size()>0){
            lstVersion.sort();           
            for(Integer i = lstVersion.size()-1; i>=0;i--){
                finalList.add(lstVersion.get(i));//make decending order
            }
        }
        
        return finalList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getComponentForSelectedProduct(String selectedProduct){
        try {
            List<Technical_Product_Line__c> technicalProducts = new List<Technical_Product_Line__c>();
            List<String> dependentComponents= new List<String>();
            String finalProduct='';
            System.debug('Entry--Product selected->'+selectedProduct);
            
            finalProduct=selectedProduct;
            if(finalProduct!='')
            {
                finalProduct=finalProduct.trim();
                technicalProducts =[select Id,Name,delivery_method__c,Version__c,Component_SubComponent__c from Technical_Product_Line__c WHERE Name=: finalProduct And status__c = 'Active' limit 1];
                System.debug('technicalProducts-->'+technicalProducts);
                if(!technicalProducts.isEmpty())
                {
                    for(Technical_Product_Line__c technicalProduct:technicalProducts)
                    {
                        if(!string.isEmpty(technicalProduct.Component_SubComponent__c)){
                            String componentSubComp = '';
                            if(technicalProduct.Component_SubComponent__c.contains(';')){
                                for(String components:technicalProduct.Component_SubComponent__c.split(';')){
                                    componentSubComp = components;
                                    Integer indecOfColon = componentSubComp.indexOf(':');
                                    componentSubComp = componentSubComp.substring(0,indecOfColon);
                                    dependentComponents.add(componentSubComp);
                                }
                            } else {
                                componentSubComp = technicalProduct.Component_SubComponent__c;
                                Integer indecOfColon = componentSubComp.indexOf(':');
                                componentSubComp = componentSubComp.substring(0,indecOfColon);
                                dependentComponents.add(componentSubComp);
                            }
                        }
                    }
                }
            }
            system.debug('dependentComponents= '+dependentComponents);
            return dependentComponents;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<SelectOption> getOrgIds(String productName,Id SuppoAccId){ //<T36>

        productName = GlobalUtility.escapeSingleQuotes(productName); //<T40>
            productName = productName.removeEnd(' ');
        Set<Id> setOrgIds = new Set<Id>();
        List<SelectOption> lstOrgOptions = new List<SelectOption>();

        if(GlobalUtility.isExternalUser() && !CaseControllerWithoutSharing.isValidUser(null, SuppoAccId, 'Read/Write') && !Test.isRunningTest())
            return lstOrgOptions;
            
            if(String.isNotEmpty(productName)){
            String strQuery = 'SELECT Org__r.Id,Org__r.Name,Org__r.OrgID__c FROM Org_Entitled_Product__c WHERE (Org__r.EditionExpirationDate__c = null OR Org__r.EditionExpirationDate__c >= TODAY) AND Entitled_Product__r.Name = \''+productName+'\' AND Entitled_Product__r.Support_Account__c = \''+SuppoAccId+'\'';
            List<SObject> lstSobjects = CaseControllerWithoutSharing.getSObjectRecords(strQuery);
            List<Org_Entitled_Product__c> lstOrgEntitledProducts = !lstSobjects.isEmpty() ? (List<Org_Entitled_Product__c>) lstSobjects : new List<Org_Entitled_Product__c>();

            for(Org_Entitled_Product__c objOrgEntitledProduct : lstOrgEntitledProducts){
                setOrgIds.add(objOrgEntitledProduct.Org__r.Id);
            }

            for(Org__c objOrg: CaseControllerWithoutSharing.getAllOrgs(setOrgIds)){
                lstOrgOptions.add(new SelectOption(objOrg.OrgID__c, objOrg.Id));
            }
            }

        return lstOrgOptions;
    }
    
    //T17 - rewrote the method to calcuate the response time accounting for the business hours
    @AuraEnabled
    public static Long calculateeOGRinMins(Datetime eOGRTime, String caseId){
        System.debug('calculateeOGRinMins Entry-->');
        System.debug('eOGRTime -->'+eOGRTime);
        System.debug('caseId -->'+caseId);

        Long durationInMins = 0;

        //get the BusinessHoursId from the given case
        List<Case> lstCase = [Select Id, BusinessHoursId From Case Where Id =: caseId];

        //find the duration from now till the given eOGR Time.
        if(!lstCase.isEmpty()){
            Case cse = lstCase.get(0);
            if(cse.BusinessHoursId != null){
                Long duration = BusinessHours.diff(cse.BusinessHoursId, DateTime.now(), eOGRTime);
                System.debug('duration in milliseconds --> '+duration);
        
                //convert from milliseconds to minutes.
                durationInMins = (duration / 60000);
                System.debug('durationInMins --> ' + durationInMins);    
            }
        }
        return durationInMins;
    }
    
    @AuraEnabled
    public static boolean updateNextAction(String caseId, String nextAction, Boolean isExternal){//Vignesh D: added isExternal parameter to complete eOGR for external comment
        System.debug('updateNextAction entry==>'+caseId);
        boolean isMilestoneUpdateSuccess=false;
        boolean isCaseUpdateSuccess=false;
        List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
        Set<String> setMilestoneName = new Set<String>();
        setMilestoneName.add('Extended Ongoing Response');
        setMilestoneName.add('Engineer Ongoing Response');

        //check if comment type is customer action then only complete the eogr
        for(CaseMilestone cm:[Select Id,MilestoneTypeId,milestonetype.name 
                              From CaseMilestone 
                              Where CaseId = :caseId 
                              And  milestonetype.name In :setMilestoneName
                              And IsCompleted=false  and CompletionDate=null]){
                                  cm.CompletionDate=System.now();
                                  lstCaseMilestones.add(cm);
                              }
        
        System.debug('lstCaseMilestones->'+lstCaseMilestones);
        if(!lstCaseMilestones.isEmpty() && isExternal){ //Vignesh D
            Case c= new Case(Id=caseId);
            
            //@Akhilesh 13 May 2021 -- start 
            //c.Next_Action__c='Customer';
            c.Next_Action__c = nextAction;
            //@Akhilesh 13 May 2021 -- end
            
            c.eOGR_in_Mins__c=0;
            c.Inbound_comment__c=false;
            
            Database.SaveResult [] updateResult = Database.update(lstCaseMilestones, false);
            if(!updateResult.isEmpty()){
                for (Database.SaveResult r : updateResult){
                    if(r.isSuccess()){
                        System.debug('milestone upadte is successfull');
                        isMilestoneUpdateSuccess=true;
                        Database.SaveResult updateCase=Database.update(c, false);
                        if(updateCase.isSuccess()){
                            System.debug('case upadte is successfull');
                            isCaseUpdateSuccess=true;
                        }
                        break;
                    }
                }                
            }
        } else {
            //@Venky 08 August 2021 -- start 
            Case cas= new Case(Id=caseId);            
            cas.Next_Action__c = nextAction;
            Database.SaveResult updateCase2 =Database.update(cas, false);
            if(updateCase2.isSuccess()){                
                isCaseUpdateSuccess=true;
            }
        }
        
        if(isCaseUpdateSuccess && isMilestoneUpdateSuccess){
            return true;
        }else {
            return false;
        }
    }
    
    
    @AuraEnabled
    public static Boolean seteOGRVisibility(String caseId)
    {
        System.debug('seteOGRVisibility'+caseId);
        Boolean isFlag=false;
        Set<String> setMilestoneName = new Set<String>();
        setMilestoneName.add('Ongoing Response');
        setMilestoneName.add('Extended Ongoing Response');
        setMilestoneName.add('Engineer Ongoing Response');

        for(CaseMilestone cm:[select Id,MilestoneTypeId,milestonetype.name 
                              from CaseMilestone 
                              where CaseId = :caseId 
                              and  milestonetype.name In :setMilestoneName
                              and IsCompleted = false  
                              and CompletionDate = null]){
                                  isFlag= true;
                                  break;
                              }
        return isFlag;
    }
        
    @AuraEnabled
    public static void completemilestone(String caseId)
    {
        try{
            Boolean isSuccess=false;
            List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
            Set<String> setMilestoneName = new Set<String>();
            setMilestoneName.add('Initial Response');
            setMilestoneName.add('Initial Response Migrated');
            setMilestoneName.add('Ongoing Response');
            setMilestoneName.add('Ongoing Response Migrated');
            setMilestoneName.add('Extended Ongoing Response');
            setMilestoneName.add('Engineer Ongoing Response');
            setMilestoneName.add('Attention Request Response');
            setMilestoneName.add('Escalation Response');
            setMilestoneName.add('Target Service Restoration Response');
            
            for(CaseMilestone cm:[select Id,MilestoneTypeId,milestonetype.name from CaseMilestone where CaseId = :caseId and 
                                  milestonetype.name IN :setMilestoneName
                                  and IsCompleted=false  and CompletionDate=null])
            {
                
                cm.CompletionDate=System.now();
                lstCaseMilestones.add(cm);
            }
            
            if(!lstCaseMilestones.isEmpty())
            {
                Database.SaveResult [] updateCaseMilestones=Database.update(lstCaseMilestones, false);
            } 
            
            Case c=new Case(Id=caseId);
            c.IR_in_Mins__c = 0;
            c.OGR_in_Mins__c = 0;
            c.eOGR_in_Mins__c = 0;            
            c.Inbound_comment__c = false;
            update c;
            
        }catch(Exception e){
            system.debug('exception while updating milestone:'+e.getmessage()+e.getlinenumber());
        }
    }

    @AuraEnabled
    public static Boolean updateeOGR(String caseId,Long eOGRinMins)
    {
        System.debug('updateeOGR entry');
        System.debug('caseId --->'+caseId);
        System.debug('eOGRinMins-->'+eOGRinMins);
        //3 flags
        Boolean isSuccess=false;
        List<CaseMilestone> lstCaseMilestones=new List<CaseMilestone>();
        
        
        Case c=new Case(Id=caseId);
        c.eOGR_in_Mins__c=eOGRinMins;
        
        for(CaseMilestone cm:[select Id,MilestoneTypeId,milestonetype.name from CaseMilestone where CaseId = :caseId and   milestonetype.name='Ongoing Response' and IsCompleted=false  and CompletionDate=null])
        {
            cm.CompletionDate=System.now();
            lstCaseMilestones.add(cm);
        }
        
        if(!lstCaseMilestones.isEmpty())
        {
            Database.SaveResult [] updateCaseMilestones=Database.update(lstCaseMilestones, false);
        }
        if(c!=null)
        {
            Database.SaveResult updateCase=Database.update(c, false);
            System.debug('updateCase.isSuccess()-->'+updateCase.isSuccess());
            isSuccess=updateCase.isSuccess();
        }
        return isSuccess;
    }
    
    //Amarender  -- check User Language Supported for CDQI API Calls - Start
    private static Boolean isUserLanguageSupported(){
        List<String> supportedLanguages = new List<String>();
        for(String lang : Service_Cloud_General_Setting__mdt.getInstance('CDQI_Supported_Languages')?.Languages_Supported__c?.split(';')){
            supportedLanguages.add(lang.toLowerCase());
        }
        return supportedLanguages?.contains(UserInfo.getLanguage()?.toLowerCase());
    }
    //Amarender  -- check User Language Supported for CDQI API Calls - End

    @AuraEnabled(cacheable=true)
    public static String processCaseDescQualityIndicator(String caseDesc, String errorMsg,String subject,String product){
        try {
            //Amarender  -- check User Language Supported for CDQI API Calls - Start
            if(!isUserLanguageSupported()){
                return null;
            }
            //Amarender  -- check User Language Supported for CDQI API Calls - End
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            CaseQualityRequestWrapper req = new CaseQualityRequestWrapper();
            req.CaseDesc = caseDesc;
            req.ErrorMsg = errorMsg;
            req.Title = subject;
            req.Product = product;
            String body = JSON.serialize(req);
            System.debug('body' + body);
            // Provide the Named Credentials
            request.setEndpoint('callout:Case_Description_Quality_Indicator_Process');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            request.setBody(body);
            request.setMethod('POST');        
            HttpResponse response = http.send(request);
            System.debug('Sent API Call');
            if (response.getStatusCode() == 200) {
                CaseQualityResponseWrapper res = (CaseQualityResponseWrapper) JSON.deserialize(response.getBody(), CaseQualityResponseWrapper.class);
                return  JSON.serialize(res);
            }
            return null;
        } catch (Exception e) {
            new globalApexManager().CreateLogs('CaseController - processCaseDescQualityIndicator',e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static CaseRecommendationResponseWrapper processCaseRecommendation(String caseDesc, String errorMsg,String title,String product,String component, String version){
        try {
            //Amarender  -- check User Language Supported for CDQI API Calls - Start
            if(!isUserLanguageSupported()){
                return null;
            }
            //Amarender  -- check User Language Supported for CDQI API Calls - End
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            CaseRecommendationRequestWrapper req = new CaseRecommendationRequestWrapper();
            req.casedesc = caseDesc;
            req.errormsg = errorMsg;
            req.title = title;
            req.prod = product;
            req.component = component;
            req.version = version;
            String body = JSON.serialize(req);
            System.debug('body' + body);
            // Provide the Named Credentials
            request.setEndpoint('callout:Case_Recommendation_API');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            request.setBody(body);
            request.setMethod('POST');        
            HttpResponse response = http.send(request);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('Response : ' + m.get('Response'));
            String xmlResponse = (String) m.get('Response');
            DOM.Document doc=new DOM.Document();
            doc.load(xmlResponse);
            
            //Retrieve the root element for this document.
            Dom.XMLNode kbNode = doc.getRootElement();
            CaseRecommendationResponseWrapper res = new CaseRecommendationResponseWrapper();
            res.kbUrl = kbNode.getChildElement('kb_url', null).getText();
            res.kbHtmlText = kbNode.getChildElement('kb_html_text', null).getText();
            // print out specific elements
            System.debug('kbUrl: ' + res.kbUrl);
            System.debug('kbHtmlText: ' + res.kbHtmlText);
            
            System.debug('Sent API Call');
            if (response.getStatusCode() == 200) {
                return res;
            }else{
                new globalApexManager().CreateLogs('CaseController - processCaseRecommendation',response.getBody());
            }
            return null;
        } catch (Exception e) {
            new globalApexManager().CreateLogs('CaseController - processCaseRecommendation',e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class selectOption
    {
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        public selectOption(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    public class caseFieldsDropdown{
        @AuraEnabled
        public list<selectOption> activities{get; set;}
        @AuraEnabled
        public list<selectOption> environments{get; set;}
        @AuraEnabled
        public list<selectOption> priorities{get; set;}
        @AuraEnabled
        public list<selectOption> problemTypes{get; set;}
        @AuraEnabled
        public list<selectOption> problemAreas{get; set;}
        @AuraEnabled
        public String contactId{get; set;}
        @AuraEnabled
        public list<AccountContactRelation> relatedContacts {get; set;}
    }
    
    public class CaseDetail{
        @AuraEnabled
        Public Case caseRecord{get; set;}
        @AuraEnabled
        Public List<Case_Contact__c> caseContacts{get; set;}
        @AuraEnabled
        Public List<AccountContactRelation> accountContacts{get; set;}
        @AuraEnabled
        Public List<ContentDocumentLink> caseDocuments{get; set;}
        @AuraEnabled
        Public Map<Id,String> contentDownloadUrlMap{get; set;}
        @AuraEnabled
        Public Boolean disableReOpen{get;set;}
        @AuraEnabled
        Public String tsftpLocationUrl{get;set;}    //Amarender - Added as part of I2Rt-564 
        @AuraEnabled
        Public ServiceAppointment serviceAppointment{get;set;}    //Utkarsh - Added as part of I2Rt-4495 
        
        //<T37>
        @AuraEnabled
        Public Boolean isActiveARMilestoneExists {get;set;}
        @AuraEnabled
        Public Boolean isActiveIRMilestoneExists  {get;set;}
        @AuraEnabled
        Public DateTime arSLATime  {get;set;}
        //</T37>
        //<T42>
        @AuraEnabled
        Public DateTime irSLATime  {get;set;} 
        //</T42>
    }
    
    Public class UserAccountInfo{
        @AuraEnabled
        Public List<AccountMembersWrapper> accountMembersWrp{get; set;}
        @AuraEnabled
        Public List<AccountTeamMember> accountMembers{get; set;}
        @AuraEnabled
        Public List<AccountContactRelation> primaryContacts{get; set;}
        @AuraEnabled
        Public List<Case> myOpenCases{get; set;}
        @AuraEnabled
        Public List<Case> allOpenCases{get; set;}
        @AuraEnabled
        Public List<Case> allClosedCases{get; set;}
        @AuraEnabled
        Public String successOffering{get; set;}
        @AuraEnabled
        Public String supportguide{get; set;}
    }
    public class AccountMembersWrapper{
        @AuraEnabled
        Public string strRoleName{get; set;}
        @AuraEnabled
        Public List<AccountTeamMember> accountMembers{get; set;}
    }
    
    public class CaseQualityRequestWrapper {
        String CaseDesc;
        String ErrorMsg;
        String Title;
        String Product;
    }
    
    //Amarender - UAT Issue Fix
    public class CaseQualityResponseWrapper {
        @AuraEnabled
        public String ActionTaken{get; set;}
        @AuraEnabled
        public String IncidentTime{get; set;}
        @AuraEnabled
        public String DescriptionQualityColor{get; set;}
        @AuraEnabled
        public String ActionTakenExample{get; set;}
        @AuraEnabled
        public String ProblemSymptom{get; set;}
        @AuraEnabled
        public String ErrorMessage{get; set;}
        @AuraEnabled
        public String ErrorMessageExample{get; set;}
        @AuraEnabled
        public String IncidentTimeExample{get; set;}
        @AuraEnabled
        public String AdditionalDetails{get; set;}
        @AuraEnabled
        public String ProblemSymptomExample{get; set;}
        @AuraEnabled
        public String ComponentExample{get; set;}
        @AuraEnabled
        public String Component{get; set;}
        @AuraEnabled
        public String DescriptionQualityScore{get; set;}
        @AuraEnabled
        public String AdditionalDetailsExample{get; set;}
    }
    //Amarender - UAT Issue Fix
    
    public class CaseRecommendationRequestWrapper {
        String casedesc;
        String errormsg;
        String title;
        String prod;
        String version;
        String component;
    }
    
    
    public class CaseRecommendationResponseWrapper {
        @AuraEnabled
        public String kbUrl{get; set;}
        @AuraEnabled
        public String kbHtmlText{get; set;}
    }
    
    public class SupportContactDetail {
        @AuraEnabled
        public Boolean isPrimary{get; set;}
        @AuraEnabled
        public Boolean isReadWrite{get; set;}
        @AuraEnabled
        public Boolean isCasePrimaryContact{get; set;}
        @AuraEnabled
        public String loggedInUser{get; set;}
        @AuraEnabled//<T26>
        public Boolean isEcommContact{get; set;} //<T26>
    }
    
    //Vignesh D: I2RT-2555
    public class caseResolution{
        @AuraEnabled
        public Map<String, String> resolutionTypes {get; set;}
        
        @AuraEnabled
        public Map<String, String> resolutionCodes {get; set;}
        
        @AuraEnabled
        public Map<String, List<String>> resolutionMap {get; set;}
    }
    
    
    //@Akhilesh 28 Apr 2021 -- start
    //create case comment for record type change #584/#585
    @AuraEnabled
    public static void doCaseRecordTypeChange(Case oCase,string existingRecordTypeName,String newRecordTypeName,List<DateTime> slotSelected,List<String> product){
        System.debug('@Developer -->doCaseRecordTypeChange:' );
        System.debug('@Developer -->oCase:' + oCase );
        System.debug('@Developer -->existingRecordTypeName:' + existingRecordTypeName );
        System.debug('@Developer -->newRecordTypeName:' + newRecordTypeName );
        System.debug('@Developer -->product:'+ product);
        try{
            if(oCase != null){
                Case c = new Case();
                if(newRecordTypeName == 'Technical' || newRecordTypeName == 'Fulfillment'){
                    String productName;
                    String deliveryMethod;
                    Id entitlementId;
                
                    if(product.size() > 0){
                        if(product.size() == 3){
                            productName = product[0];
                            deliveryMethod = product[1];
                            entitlementId = String.isNotEmpty(product[2]) ? product[2] : null;
                        }
                    }
                    if(entitlementId != null){
                        oCase.Entitled_Product__c = entitlementId;
                    }
                    else{
                        c = [Select Id,Subject,Description,Support_Account__c,Environment__c,Priority,Activity_Type__c,ContactId,Problem_Area__c,AccountId from Case where Id =: oCase.Id];
                        Id unentitledProductId = CaseController.createUnEntitledProduct(productName, deliveryMethod, c.AccountId, c.Support_Account__c);
                        if(String.isNotEmpty(unentitledProductId)){
                            oCase.Unentitled_Product__c  = true;
                            oCase.Entitled_Product__c = unentitledProductId;
                        }
                    }
                }
                
                // invoke asigment rule card# 4768
				update oCase;

                if(newRecordTypeName == 'Administrative'){
                    c = [Select Id,Subject,Description,Support_Account__c,Environment__c,Priority,Activity_Type__c,ContactId,Problem_Area__c,AccountId,RecordTypeId from Case where Id =: oCase.Id];
                    CaseControllerWithoutSharing.createIcareReferral(c);
                }
                if(newRecordTypeName == 'Operations' && slotSelected != null && slotSelected.size() > 0){
                    c = [Select Id,Subject,Description,Support_Account__c,Environment__c,Priority,Activity_Type__c,ContactId,Problem_Area__c,AccountId from Case where Id =: oCase.Id];                
                    OperationsSchedulerController.cancelSession(c.Id, '');
                    OperationsSchedulerController.createServiceAppointment(c, slotSelected, 'Create');
                }
            }
            
            Case_Comment__c oCC = new Case_Comment__c();
            oCC.Case__c = oCase.Id;
            oCC.Visibility__c = 'Internal';
            oCC.Comment_Category__c = 'General Comments';
            if(newRecordTypeName == 'Operations'){
                oCC.Comment__c = 'Environment Type: ' + oCase.Environment__c;
                oCC.Comment__c += '<br/>';
                oCC.Comment__c += 'Case Record Type is changed to "' + newRecordTypeName + '" from "' + existingRecordTypeName + '"';
            }
            else {
                oCC.Comment__c = 'Case Record Type is changed to "' + newRecordTypeName + '" from "' + existingRecordTypeName + '"';
            }
            oCC.Inbound__c = false;
            oCC.Status__c = 'Submitted';
            insert oCC;
        }
        catch(Exception ex){
            System.debug('@Developer -->Exception:' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //<T04>
    private static Id createUnEntitledProduct(String productName, String deliveryMethod, Id accountId, Id supportAccId){
        Entitled_Product__c newEntitledProduct = new Entitled_Product__c();
        newEntitledProduct.Name = productName;
        newEntitledProduct.End_Date__c = System.today();
        newEntitledProduct.Account__c = accountId;
        newEntitledProduct.Support_Account__c = supportAccId;
        newEntitledProduct.Delivery_Method__c = deliveryMethod;
        newEntitledProduct.Manual_Creation_override__c = true;
        newEntitledProduct.Override_Entitlement_Date__c = true;
        Insert newEntitledProduct;
        return newEntitledProduct.Id;
    }
    
    //I2RT-4574
    public static String getCaseClosureComment(Case cse){
        String folderPrefix = 'Case QuickText Templates ';
        String folderNameDefault = folderPrefix + 'English';
        String defaultComment = '<html><head><title></title></head><body style="height: auto; min-height: auto;">Thank you for confirming the Case Closure.<br /><br />Please find the Case Summary and the provided Solution.<br /><br /><u><b>Case Summary</b></u><br />' + cse.Problem_Statement__c + '<br /><u><b>Solution</b></u><br />' + cse.Closing_Notes__c + '<br /><br /></body></html>';

        String language = '';
        if(String.isNotEmpty(cse?.Contact?.INFA_Language__c)){
            language = cse.Contact.INFA_Language__c;
            Integer indexOfSpace = language.indexOf(' ');
            if(indexOfSpace != -1){
                language = language.substring(0, indexOfSpace);
            }
        }
        String emailTemplateFolderName = folderPrefix + language;
        System.debug('folder name per case contact language --> ' + emailTemplateFolderName);    

        Set<String> setFolderName = new Set<String>{folderNameDefault, emailTemplateFolderName};
        List<EmailTemplate> lstEmailTemplate = [Select Id, HtmlValue, Folder.Name From EmailTemplate 
                                                    Where Name = 'Close Case' And Folder.Name IN :setFolderName];

        Map<String, EmailTemplate> mapFolderNameToEmailTemplate = new Map<String, EmailTemplate>(); 
        for(EmailTemplate emailTemplate : lstEmailTemplate){
            mapFolderNameToEmailTemplate.put(emailTemplate.Folder.Name, emailTemplate);
        }

        EmailTemplate emailTemplate = mapFolderNameToEmailTemplate.get(folderNameDefault);
        if(mapFolderNameToEmailTemplate.containsKey(emailTemplateFolderName)){
            emailTemplate = mapFolderNameToEmailTemplate.get(emailTemplateFolderName);
        }
        System.debug('selected folder name --> ' + emailTemplate.Folder.Name);

        String output = defaultComment;
        if(emailTemplate != null){
            output = CaseCommentController.getParsedEmailTemplate(emailTemplate, cse);
        }

        return output;  
    }

    //@Amarender 06 May 2021 -- start
    //Track Solution Status on Case Solution Stage
    @AuraEnabled
    public static String trackSolutionStatus(String caseId, String decision, String comments,Date expectedDate, String reason){
        Case cse;
        String result;
        
        if(caseId != null){
            //T24 - get Case details in without sharing context 
            cse = CaseControllerWithoutSharing.getCase(caseId);
        }
        //I2RT-4574
        //String caseClosureComment = '<html><head><title></title></head><body style="height: auto; min-height: auto;">Thank you for confirming the Case Closure.<br /><br />Please find the Case Summary and the provided Solution.<br /><br /><u><b>Case Summary</b></u><br />' + cse.Problem_Statement__c + '<br /><u><b>Solution</b></u><br />' + cse.Closing_Notes__c + '<br /><br /></body></html>';
        
        Case_Comment__c newCaseComment= new Case_Comment__c();
        switch on decision{
            when 'Accepted' {       
                System.debug('Accepted');
                if(cse != null && cse.Status == 'Solution' && cse.Status != 'Closed'){
                    cse.Status = 'Closed';
                    cse.Closure_Validated__c = 'Customer Confirmed';
                    //cse.Comments = comments; //I2RT-4520

                    //I2RT-4574
                    newCaseComment.Comment__c = getCaseClosureComment(cse);//caseClosureComment;                  
                }
            }   
            when 'Declined' {       
                System.debug('Declined');
                if(cse != null && cse.Status == 'Solution' && cse.Status != 'Closed'){
                    cse.Status = 'Research';
                    cse.Reason_For_Rejection__c = reason;
                    cse.Reason_For_This_Delay__c = '';
                    cse.Expected_Date__c = expectedDate;
                    //cse.Comments = comments; //I2RT-4520
                    newCaseComment.Comment__c = comments;
                    newCaseComment.Inbound__c = true;
                }
            }
            when 'NeedMoreTime' { 
                if(cse != null && cse.Status  == 'Solution' && cse.Status != 'Closed'){
                    cse.Expected_Date__c = expectedDate;
                    cse.Reason_For_This_Delay__c = reason;
                    cse.Reason_For_Rejection__c = '';
                    //cse.Comments = comments; //I2RT-4520
                    newCaseComment.Comment__c = comments;
                }
            }
        }
        
        if(cse != null){
            try {
                if(cse.Status == 'Closed'){
                    CaseCommentController.deleteScheduledComments(new List<Id>{cse.Id});
                }
                //T24 - update Case in without sharing context 
                CaseControllerWithoutSharing.updateCase(cse);

                //newCaseComment.Inbound__c = true;
                newCaseComment.Sub_Type__c = 'Solution Response';
                newCaseComment.Status__c = 'Submitted';
                newCaseComment.Visibility__c = 'External';
                newCaseComment.Case__c = caseId;
                //T24 - insert Case Comment in without sharing context 
                CaseControllerWithoutSharing.insertCaseComment(newCaseComment);
                result = cse.Status;
            } catch (Exception e) {
                new globalApexManager().CreateLogs('CaseController - trackSolutionStatus',e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        return result;
        
    }
    
    //@Amarender 06 May 2021 -- end
    
    @AuraEnabled
    public static SupportContactDetail getSupportContactDetails(String caseId, String supportAccountId){
        try {
            caseId = (caseId != null) ? String.escapeSingleQuotes(caseId) : caseId;
            supportAccountId = (supportAccountId != null) ? String.escapeSingleQuotes(supportAccountId) : supportAccountId;
            SupportContactDetail supportContact = new supportContactDetail();
            String supportAccId;
            String contactId;
            String caseCreatedById;
            Id caseContactId;
            for(User u : [Select Id, ContactId from User where Id =: UserInfo.getUserId() and ContactId!=null ]){
                //contactId = u.ContactId != null ? u.ContactId : '';
                contactId = u?.ContactId;
                supportContact.loggedInUser = u?.Id;
            }
            
            if(!String.isEmpty(caseId)){
                caseId = String.escapeSingleQuotes(caseId);
                for(Case c : (List<Case>)CaseControllerWithoutSharing.getSObjectRecords('Select Id, Support_Account__c, CreatedById, ContactId, accountId,org__c, RecordType.developerName from Case where Id =\''+caseId+'\' limit 1')){//<T26>
                    //supportAccId = c.Support_Account__c != null ? c.Support_Account__c : '';
                    supportAccId = c?.Support_Account__c;
                    //caseCreatedById = c.CreatedById != null ? c.CreatedById : '';
                    caseCreatedById = c?.CreatedById;
                    caseContactId = c?.ContactId;
                    
                    supportContact.isEcommContact = (c.RecordType.developerName == 'Case_Lite' && SupportLiteSharing.validateUserAccess('Case','READ',caseId));//<T26>
                    
                }
                if(!String.isEmpty(supportAccId) && !String.isEmpty(contactId)){
                    for(AccountContactRelation c : [Select Id,AccountId,ContactId,Contact.AccountId,Contact.Account.Name,Account.Name,
                                                    Contact.Name,Contact.Email,Contact.Phone, Roles,Timezone__c, Primary__c,IsActive,Access_Level__c from AccountContactRelation 
                                                    where AccountId =: supportAccId and ContactId =: contactId limit 1]){
                                                        
                                                        supportContact.isPrimary = c.Primary__c != null ? c.Primary__c : false;
                                                        supportContact.isReadWrite = c.Access_Level__c != null && c.Access_Level__c == 'Read/Write' ? true : false;
                                                    }
                }
                if(!String.isEmpty(caseCreatedById)){
                    supportContact.isCasePrimaryContact = (caseCreatedById == UserInfo.getUserId()) || (caseContactId == contactId) ? true : false;
                }
            }
            
            if(!String.isEmpty(supportAccountId) && !String.isEmpty(contactId)){
                for(AccountContactRelation c : [Select Id,AccountId,ContactId,Contact.AccountId,Contact.Account.Name,Account.Name,
                                                Contact.Name,Contact.Email,Contact.Phone, Roles,Timezone__c, Primary__c,IsActive,Access_Level__c from AccountContactRelation 
                                                where AccountId =: supportAccountId and ContactId =: contactId limit 1]){
                                                    
                                                    supportContact.isPrimary = c.Primary__c != null ? c.Primary__c : false;
                                                    supportContact.isReadWrite = c.Access_Level__c != null && c.Access_Level__c == 'Read/Write' ? true : false;
                                                    supportContact.isCasePrimaryContact = false;
                                                }
            }
            
            return supportContact;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getServiceCloudMetadata(String metadataName){
        String recordIdToReturn = '';
        metadataName = String.escapeSingleQuotes(metadataName);
        if(!String.isEmpty(metadataName)){
            Map<String, Service_Cloud_General_Setting__mdt> gcs_meta = Service_Cloud_General_Setting__mdt.getAll();
            
            for(String currentRecId : gcs_meta.keySet()) {
                Service_Cloud_General_Setting__mdt currentRec = gcs_meta.get(currentRecId);
                if(currentRec.Developername == metadataName) {
                    recordIdToReturn = currentRec.Id;
                }
            }
        }
        return recordIdToReturn;
    }
    
        //AMIT G: I2RT - 4215
    @AuraEnabled
    public static string getQuickActionLink(id recordId,string type){
        
        Service_Cloud_General_Setting__mdt  meta = [select id, TSFTP_quick_Action_Link__c, South_Deep_Quick_Action_Link__c, Cassini_Quick_Action_Link__c from Service_Cloud_General_Setting__mdt where DeveloperName = 'Quick_Action_Links' limit 1 ];
        system.debug( meta.TSFTP_quick_Action_Link__c);
        Case cas = new Case();
        if(recordId.getSObjectType().getDescribe().getName() == 'Case'){
            cas= [select id, caseNumber,Support_Account__r.parent.New_Org_Account_Number__c from case where id = :recordId];
        }
        if(type == 'TSFTP'){
            string st = meta.TSFTP_quick_Action_Link__c;
            system.debug('@@---->>>'+st);
            return st;
        }
        if(type == 'Cassini'){                       
                if(cas != null && cas.Support_Account__r.parent.New_Org_Account_Number__c != null)
                    return meta.Cassini_quick_Action_Link__c + cas.Support_Account__r.parent.New_Org_Account_Number__c;
                else 
                    return meta.Cassini_quick_Action_Link__c;            
        }
        if(type == 'South Deep'){          
            if(cas != null)
                return meta.South_Deep_quick_Action_Link__c + cas.CaseNumber;
            else
                return meta.South_Deep_quick_Action_Link__c;
        }
        
        return null;
    }
    //Vignesh D: I2RT-2555
    @AuraEnabled
    public static caseResolution getCaseResolution(){
        String defaultMetadataRecName = 'Case_Resolution_Types_and_Codes';
        String metaDataRecId = getServiceCloudMetadata(defaultMetadataRecName);
        caseResolution CR = new caseResolution();
        Map<String,String> resolutionTypes = new Map<String,String>();
        Map<String,String> resolutionCodes = new Map<String,String>();
        Map<String, List<String>> resolutionMap = new Map<String, List<String>>();
        
        if(!String.isEmpty(metaDataRecId)){
            Service_Cloud_General_Setting__mdt metaDataRecord = [Select Id,Case_Resolution_Types_and_Codes__c from Service_Cloud_General_Setting__mdt where Id =: metaDataRecId limit 1];
            if(metaDataRecord != null && metaDataRecord.Case_Resolution_Types_and_Codes__c != null){
                for(String resolution : metaDataRecord.Case_Resolution_Types_and_Codes__c.split(';')){
                    System.debug('Resolution ==> '+resolution);
                    String key;
                    
                    //Level-1 Split: Resolution Type with Help Text & Resolution Codes with Help Text
                    List<String> level1 = resolution.split('::');
                    if(level1.size() != null && level1.size() == 2){
                        String RT_With_HelpText = level1[0];
                        String RC_With_HelpText = level1[1];
                        
                        //Level-2 Split: Resolution Type and Help Text
                        if(!String.isEmpty(RT_With_HelpText)){
                            List<String> level2 = RT_With_HelpText.split('##');
                            if(level2.size() != null && level2.size() == 2){
                                resolutionTypes.put(level2[0],level2[1]);
                                key=level2[0];
                            }
                        }
                        
                        //Sub-Level Split
                        List<String> resCodes = RC_With_HelpText.split('~');
                        for(String resolutionCode : resCodes){
                            System.debug('Resolution Code ==> '+resolutionCode);
                            
                            //Sub-Level-1 Split: Resolution Code and Help Text
                            List<String> subLevel1 = resolutionCode.split('##');
                            if(subLevel1.size() != null && subLevel1.size() == 2){
                                resolutionCodes.put(subLevel1[0],subLevel1[1]);
                                if(!resolutionMap.containsKey(key)){
                                    List<String> temp = new List<String>();
                                    temp.add(subLevel1[0]);
                                    resolutionMap.put(key,temp);
                                }
                                else if(resolutionMap.containsKey(key)){
                                    List<String> temp = resolutionMap.get(key);
                                    temp.add(subLevel1[0]);
                                    resolutionMap.put(key, temp);
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        CR.resolutionTypes = resolutionTypes;
        CR.resolutionCodes = resolutionCodes;
        CR.resolutionMap = resolutionMap;
        
        return CR;
    }
    
    @AuraEnabled
    public static Boolean checkIRCompletion(String caseId){
        try{
            Boolean isIRCompleted = false;
            Boolean isIRPresent = false;
            
            caseId = (caseId != null) ? String.escapeSingleQuotes(caseId) : caseId;
            
            for(CaseMilestone cm : [SELECT Id,MilestoneType.Name,IsCompleted,IsViolated from CaseMilestone where CaseId =: caseId and MilestoneType.Name = 'Initial Response' limit 1]){
                isIRPresent = true;
                if(cm.IsCompleted){
                    isIRCompleted = true;
                }
                else if(cm.IsViolated){
                    isIRCompleted = false;
                }
            }
            if(!isIRPresent){
                isIRCompleted = true;
            }
            System.debug('isIRCompleted: '+isIRCompleted);
            return isIRCompleted;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String closeCaseRequest(String caseId, String comment){
        try{
            caseId = escapeQuotes(caseId);
            comment = escapeHtml(escapeQuotes(comment));
            
            String returnMessage = 'SUCCESS';
            
            if(String.isNotEmpty(caseId) && String.isNotEmpty(comment)){
                Case_Comment__c cc = new Case_Comment__c();
                cc.Case__c = caseId;
                cc.Type__c = '';
                cc.Status__c = 'Submitted';
                cc.Inbound__c = true;
                cc.Visibility__c = 'External';
                cc.Comment__c = '<b>Close Case Requested:</b><br>'+comment;
                insert cc;
            }
            
            return returnMessage;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //get the Source URL path from metadata 'Tableau_Dashboards'
    @AuraEnabled(cacheable=true)
    public static string getTableauDashboardLinks(string strFilter){
        system.debug('@@@------>>>>'+strFilter);
        String recordIdToReturn = '';
        
        Map<String, Service_Cloud_General_Setting__mdt> gcs_meta = Service_Cloud_General_Setting__mdt.getAll();
        
        for(String currentRecId : gcs_meta.keySet()) {
            Service_Cloud_General_Setting__mdt currentRec = gcs_meta.get(currentRecId);
            if(currentRec.Developername == 'Tableau_Dashboards') {
                if(strFilter == 'Manager'){
                    recordIdToReturn = currentRec.Manager_Dashboard_Tableau_Link__c;
                }else{
                    recordIdToReturn = currentRec.Engineer_Dashboard_Tableau_Link__c;
                }
            }
        }
        return recordIdToReturn;
        
    }
    @AuraEnabled(cacheable=true)
    public static DownloadFormWrapper allDataForDownloadForm(){
        DownloadFormWrapper dfw = new DownloadFormWrapper();
        dfw.Statuses = new list<selectOption>();
        dfw.Types = new list<selectOption>();
        dfw.Priorities = new list<selectOption>();
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        dfw.Statuses.add(new selectOption('--None--', 'None'));
        for( Schema.PicklistEntry pickListVal : ple){
            dfw.Statuses.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        }
        
        //fieldResult = Case.Type.getDescribe();
        //ple = fieldResult.getPicklistValues();
        dfw.Types.add(new selectOption('--None--', 'None'));
        for(Recordtype rd:[select id , name from recordType where sObjectType = 'Case']){
            dfw.Types.add(new selectOption(rd.name, rd.id));
        }
        
        fieldResult = Case.Priority.getDescribe();
        ple = fieldResult.getPicklistValues();
        dfw.Priorities.add(new selectOption('--None--', 'None'));
        for( Schema.PicklistEntry pickListVal : ple){
            dfw.Priorities.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        }
        List<selectOption> supportAccounts = new List<selectOption>();
        for(AccountContactRelation account:getAllSupportAcc()){
            supportAccounts.add(new selectOption(account.Account.Name, account.Account.Id));  
            if(account.favorite__c == true){
                dfw.favAccountId = account.Account.Id;
            }              
        }
        dfw.AllAccounts = supportAccounts;
        return dfw;
    }
    @AuraEnabled(cacheable = true)
    public static  downloadcaseWrapper getcasesToDownload(string caseNumber, string status, string priority,string type,string fromDate, string toDate,string accId, string prodId  ){
        downloadcaseWrapper objwrap=new downloadcaseWrapper();
       /* I2RT-4421*/ string query = 'select id, casenumber,priority,Contact.Name,subject,Description ,Forecast_Product__c,Version__c,CreatedDate,status,Next_Action__c,NextAction__c,RecordType.Name,LastModifiedDate,ClosedDate,Closing_Notes__c,Account.name,     Entitled_Product__r.name,type from case where Support_Account__c =:accId ';
        if(status != null && status != '' && status != 'None'){
            query  = query + ' and status = :status ';
        }
        if(priority != null && priority != '' && priority != 'None'){
            query  = query + ' and priority = :priority ';
        }
        if(prodId != null && prodId != '' && prodId != 'None'){
            query = query + ' and Entitled_product__r.name =:prodId';
        }
        if(caseNumber != null && caseNumber != ''){
            query  = query + ' and caseNumber like \'%' + String.escapeSingleQuotes(caseNumber) + '%\' '; //<T18>
        }
        if(Type != null && Type != '' && type != 'None'){
            query  = query + ' and recordtypeId = :type ';
        }
        system.debug(status);
        system.debug(type);
        system.debug(fromdate);
        if(fromdate != null && fromdate != ''){
            date fromdt = date.valueOf(fromdate);
            System.debug(' date frm '+fromdt);
            // datetime fromdatetime = datetime.valueof(fromdt);
            query  = query + ' and createddate >= :fromdt' ;
        }
        if(Todate != null && todate != ''){
            date todt = date.valueOf(todate);
            // datetime fromdatetime = datetime.valueof(fromdt);
            query  = query + ' and createddate <= :todt' ;
        }
        system.debug('from date '+fromdate);
        system.debug('todate   '+todate);
        system.debug('acc id '+accid);
        query = query + ' order by createddate desc limit 20000';
        system.debug(query);
        
        list<case> caseList = database.query(query);
        objwrap.lstcase=caseList;
        // objwrap.lstcase.addAll(caseList);
        return objwrap;
    }
    public class downloadcaseWrapper{
        @auraenabled
        public  list<case> lstcase{get;set;}
    }
    
    @AuraEnabled
    public static void CancelAaeAppointmentHandler(string caseId, string uploadComments){
        try {
            system.debug('caseId===> ' + caseId);
            
            Case oCase = [Select Id,Service_Appointment__c ,status From Case Where Id =: caseId AND Service_Appointment__c  != null LIMIT 1]; //<T41>
            oCase.status = 'Cancelled';
            update oCase;
            
            if(uploadComments != ''){
                Case_Comment__c newCaseComment= new Case_Comment__c();
                newCaseComment.Comment__c = uploadComments;         
                newCaseComment.Comment_Category__c = null;
                newCaseComment.Sub_Type__c = 'General Response';
                newCaseComment.Status__c = 'Submitted';
                newCaseComment.Inbound__c = true;
                newCaseComment.Visibility__c = 'External';
                newCaseComment.Case__c = oCase.id;
                insert newCaseComment;
                
            }
            
            //---------------------------------------<T35>-----------------------------
            Id eventId = CaseControllerWithoutSharing.getEventFromCase(oCase.Id);
            if(eventId != null){
                GCSCancelZoomMeetingController.getMeetingCanceledInFuture(eventId);
            }
            List<Service_Appointment__c> lstSA = [Select Id From Service_Appointment__c WHERE Id =: oCase.Service_Appointment__c LIMIT 1]; //<T41>
            if(lstSA.size() > 0){
                CaseControllerWithoutSharing.deleteSobjects(new List<SObject>{lstSA[0]});
            }
            //---------------------------------------</T35>-----------------------------
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //I2RT-4229
    @AuraEnabled
    public static void createCaseComment(String caseid) {
        List<Case_Comment__c> lstCaseComment = new List<Case_Comment__c>();
        caseid  = caseid.replace('"','');
        Case c = [Select Id, Cloned_From_Case_Number__c,Cloned_From__c from case where Id = :caseid];
        
            if(c.Cloned_From__c != null){
                String comment = 'This case is cloned from the Case #' + c.Cloned_From_Case_Number__c;
                lstCaseComment.add(CaseCommentService.createClonedCaseComment(c.Id, comment));
            }
        
 
        if(!lstCaseComment.isEmpty()){
            Database.insert(lstCaseComment, false);
        }
    }
    
    public class DownloadFormWrapper{
        @AuraEnabled
        public list<selectOption> Statuses{get; set;}
        @AuraEnabled
        public list<selectOption> Types{get; set;}
        @AuraEnabled
        public list<selectOption> Priorities{get; set;}
        @AuraEnabled
        public list<selectOption> AllAccounts{get; set;}
        @AuraEnabled
        public string favAccountId{get;set;}
    }
    //Wrapper to bind support account information
    public class WrapperSupportAcc{
        @AuraEnabled
        public boolean isBlnSUpportAccFav{get;set;}
        @AuraEnabled
        public AccountContactRelation AccConRel{get;set;}
    }

    @AuraEnabled
    public static string UpdateCaseRecord(String caseObj){
        try {
            Case caseToUpdate = (Case) JSON.deserialize(caseObj, case.class);
            String caseId = caseToUpdate?.Id;
            String caseContactId = caseToUpdate?.ContactId;
            Boolean isContactValid = false; //T20
            String errorMsg = ''; //T20
            
            //T20
            Case caseDetail = new Case();
            if(String.isNotEmpty(caseContactId) && String.isNotEmpty(caseId)){
                caseDetail = [Select Id, AccountId, Support_Account__c, RecordType.Name From Case Where Id = :caseId];
                Id accId;
                if(caseDetail.RecordType.Name == 'Case Lite'){
                    accId = caseDetail.AccountId;
                    errorMsg = 'Please select a contact associated with the eCommerce Account';
                }else{
                    accId = caseDetail.Support_Account__c;
                    errorMsg = 'Please select a contact associated with the Support Account';
                }
                if(String.isNotEmpty(accId)){
                    isContactValid = [Select Id from AccountContactRelation where AccountId = :accId and ContactId = :caseContactId]?.size() > 0 ? true : false;
                }
            }

            if((isContactValid && String.isNotEmpty(caseToUpdate?.ContactId)) || String.isEmpty(caseToUpdate?.ContactId)){
                update caseToUpdate;
                return 'SUCCESS';
            }
            else{
                throw new CustomException(errorMsg); //T20
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Vignesh D
    private static String escapeQuotes(String s){        
        return (s != null) ? String.escapeSingleQuotes(s) : s;
    }
    
    private static String escapeHtml(String s){
        return s = (s != null) ? s.escapeHtml4() : s;
    }

    // Amarender -> I2RT-4656: Console_Able to remove the case primary contact from the case as a GCS user
    // params -> Metadata record API Name
    @AuraEnabled
    public static Service_Cloud_General_Setting__mdt getMedataDataRecord(String metadataRecordName) {        
        return Service_Cloud_General_Setting__mdt.getInstance(metadataRecordName);
    }
    //I2RT-4421
    @AuraEnabled
    public static String getCaseAccess(Id caseId, String strAccessLevel){ //<T26>
        String strResponse = '';
        Case objCase = CaseControllerWithoutSharing.getCase(caseId);

        //Now, we check user's access to see the case
        if(objCase.RecordType.DeveloperName == 'Case_Lite' && !SupportLiteSharing.validateUserAccess('Case', 'READ', caseId)){
            strResponse = CaseControllerWithoutSharing.getOrgs().toString().contains(objCase?.Org__c) ? System.Label.Case_Lite_Subscription_ended_Message : String.format(System.Label.Case_Lite_Access_Error_Message, new List<Object> {objCase?.Org__r?.Name}); //<T29>
        }
        else if(objCase.RecordType.DeveloperName != 'Case_Lite' && !CaseControllerWithoutSharing.isValidUser(objCase.Id, null, strAccessLevel)){
            List<Account> lstSupportAccounts = CaseControllerWithoutSharing.getSupportAccount(objCase?.Support_Account__c);
            String strSupportAccountName = !lstSupportAccounts.isEmpty() ? lstSupportAccounts[0].Name : '';
            strResponse = String.isNotBlank(strSupportAccountName) ? String.format(System.Label.Support_Account_Case_Access_Error_Message, new List<Object> {strSupportAccountName}) : 'Invalid Access';
        }
        return strResponse;
    } 
    //I2RT-4421


    //---------------------------------------<T09>-------------------------------
    @AuraEnabled
    public static Account getSupportAccountDetails(Id supportAccountId){
        Account objSupportAccount = [Select Id,Success_Offering__c from Account where Id =:supportAccountId];
        return objSupportAccount;
    }
    //---------------------------------------</T09>------------------------------
        
    //T13
    @AuraEnabled(cacheable=true)
    public static List<String> getDelMethodsForSelectedProduct(String selectedProduct){
        List<String> lstDeliveryMethod = new List<String>();

        List<Technical_Product_Line__c> lstTechProdLine = [Select Id, Name, Delivery_Method__c 
                                                            From Technical_Product_Line__c Where Name = :selectedProduct Limit 1];

        for(Technical_Product_Line__c techProdLine : lstTechProdLine){
            lstDeliveryMethod = techProdLine.Delivery_Method__c.split(';');
        }

        return lstDeliveryMethod;
    }

  //---------------------------------------<T22>-------------------------------
    @AuraEnabled(cacheable = false)
    public static CaseLiteDetail getCaseLiteDetails(String strProductName) {
        CaseLiteDetail objCaseLiteDetail = new CaseLiteDetail();
        objCaseLiteDetail.contactId = GlobalUtility.getCommunityUserContactId();
        String strOrgServiceName = '';    
        
        //Get support lite product custom metadata type records
        Map<String, Support_Lite_Product__mdt> mapSupportLiteProduct = Support_Lite_Product__mdt.getAll();
        for(Support_Lite_Product__mdt objSupportLiteProduct : mapSupportLiteProduct.values()){

            //Now, we check if the support lite product is active
            if(objSupportLiteProduct.Active__c && objSupportLiteProduct.Is_Case_Creation_Allowed__c && objSupportLiteProduct.Product_Name_on_Community__c == strProductName){
                objCaseLiteDetail.objSupportLiteProduct = new Support_Lite_Product__mdt(Product_Name_on_Support__c=objSupportLiteProduct.Product_Name_on_Support__c,IN_Redirect_URL__c=objSupportLiteProduct.IN_Redirect_URL__c);
                strOrgServiceName = objSupportLiteProduct.Org_Service_Name__c;
            }
        }

        if(String.isBlank(strOrgServiceName)){
            throw new CustomException('Invalid Access');
        }

        List<Org__c> lstOrgs = CaseControllerWithoutSharing.getOrgs(strOrgServiceName);
        objCaseLiteDetail.lstOrgs = lstOrgs;

        if(lstOrgs.isEmpty()){
            throw new CustomException('Insufficient access to create case');
        }

        return objCaseLiteDetail;
    }

    @AuraEnabled(cacheable = false)
    public static List<Org_User__c> getAccountContacts(Id orgId) { //<T27>
        Boolean boolHasAccess = false;
        for(Org__c objOrg : CaseControllerWithoutSharing.getOrgs()){
            if(objOrg.Id == orgId && objOrg.Support_Lite__c){
                boolHasAccess = true;
                break;
            }
        }
        if(!boolHasAccess){
            throw new CustomException('Insufficient access to view contact');
        }
        String strQuery = 'SELECT Id,Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.Phone,Contact__r.INFA_Language__c,Contact__r.TimeZone_Lookup__r.Name,FirstName__c,LastName__c,Email__c,PhoneNumber__c FROM Org_User__c WHERE Org__c = \''+orgId+'\' AND (Contact__c != null OR Email__c != null) AND Contact__c != \''+GlobalUtility.getCommunityUserContactId()+'\' LIMIT 2000';
        return (List<Org_User__c>) (List<Org_User__c>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
    }

    public class CaseLiteDetail{
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public Support_Lite_Product__mdt objSupportLiteProduct {get; set;}
        @AuraEnabled
        public List<Org__c> lstOrgs {get; set;}
    }
    //---------------------------------------</T22>-------------------------------
    }