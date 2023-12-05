/*
    Class:          AccountTriggerHandler
    @Author:        Ambica Pyati
    @Created Date:  23/3/2018
    @Description:   handler class for Account triggers

    Change History
*******************************************************************************************************************************************************
ModifiedBy            Date        Requested By             Description                                                           Tag
*******************************************************************************************************************************************************
Chandana Gowda       03 Mar 21      TAX-19              Added logic to create and associate ERP Customre record                  <T1>  
Ambica Pyati         03 Jan  21     I2RT                Added method to handle after update triggers                             <T02>
Chandana Gowda       02-jun-2021    SALESRT-12973       Added validation to allow editing of company data section                <T03>
                                                        only by Integration USer      
Vignesh Divakaran    31-Jan-2022    I2RT-5360           Activate primary contact, once the support account is activated          <T04>
Vignesh Divakaran    25-Mar-2022    I2RT5484            Replace EndUser contact with ShipTo contact on support account           <T05>
                                                        activation            
Ramya Ravi           23-Mar-2022    I2C-1520            To send chatter notification to CMS team             			         <I2C-1520>
														when account name or customer ID is changed
Puneet Lohia         20-May-2022    SALESRT-13728       New LOGO SPIFF Changes                                                   <SALESRT-13728> 
Karthi G             24-Feb-2023    AR-3107             Added logic and method to handle Success Portfolio change                <T06>                         
*******************************************************************************************************************************************************
*/

public Class AccountTriggerHandler{

    public static globalApexManager GAM = new globalApexManager();
    public static CustomPermissionsReader csm = new CustomPermissionsReader();// to check the user permission
    public static Boolean IsExemptUser = (csm.hasPermission('SystemAdmin') || csm.hasPermission('IntegrationUser') || csm.hasPermission('SalesSuperUser'));//Check if the current user has Admin,Integration, Superuser permissions
    public static Boolean IsIntegrationUser = csm.hasPermission('IntegrationUser'); //<T03>
   
    
    /**
    * this method is invoked from before delete event of account
    * @param lstNew - list of old account
    * @return return-void
    * @throws exception - NA
    */
    

    public static void AccountBeforeDelete (List<Account> LstOld)
    { 
        //do not run if the current user is sys admin, integration user, superuser
        if(!IsExemptUser){
            for( Account ac:LstOld){
                //restricts non-admins/non-superusers/CSOs from delting account
                ac.adderror('Insufficient privileges to delete account, please contact your system administrator' );          
            }
        }
    }
    //--------------------------------------------------------------------------------------------------------------------<T1>
        /**
        * this method is invoked from before update event of account
        * @param newMap,oldMap
        * @return return-void
        * @throws exception - NA
        */
        
        
    public static void AccountBeforeUpdate (Map<Id,Account> newMap,Map<Id,Account> oldMap){
        
        List<ERP_Company__c> lstErpCompanyToInsert = new List<ERP_Company__c>();
        Map<String,Set<Id>> mapERPIdAccs = new Map<String,Set<Id>>(); //Map of ERP Customer Id and AccIds
        String customerAccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        String prospectAccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        String partnerAccountRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        
        for(Account accRec:newMap.values()){
            //If ERP Customer Id is changed
            if(accRec.Peoplesoft_External_ID__c != null && accRec.Peoplesoft_External_ID__c != oldMap.get(accRec.Id).Peoplesoft_External_ID__c && (accRec.RecordTypeId == customerAccountRecordTypeID || accRec.RecordTypeId == prospectAccountRecordTypeID || accRec.RecordTypeId == partnerAccountRecordTypeID)){
                Set<Id> setAccIds = new Set<Id>();
                if(mapERPIdAccs.containsKey(accRec.Peoplesoft_External_ID__c)){
                    setAccIds = mapERPIdAccs.get(accRec.Peoplesoft_External_ID__c);
                }
                setAccIds.add(accRec.Id);
                mapERPIdAccs.put(accRec.Peoplesoft_External_ID__c,setAccIds);
            }
        }
        
        if(!mapERPIdAccs.isEmpty()){
            //List of Accounts with existing ERP Company
            List<Account> lstAccount = [SELECT Id,Peoplesoft_External_ID__c,ERP_Company__c FROM Account WHERE Peoplesoft_External_ID__c In :mapERPIdAccs.keySet() AND ERP_Company__c != null];
            
            //If an Account with same ERP Customer Id exists, do not create a new ERP Company
            if(!lstAccount.isEmpty()){
                for(Account accRec: lstAccount){
                    if(mapERPIdAccs.containsKey(accRec.Peoplesoft_External_ID__c)){
                        Set<Id> setAccIds = mapERPIdAccs.get(accRec.Peoplesoft_External_ID__c);
                        for(Id accId:setAccIds){
                            newMap.get(accId).ERP_Company__c = accRec.ERP_Company__c; //update with the existing ERP company record
                        }
                        mapERPIdAccs.remove(accRec.Peoplesoft_External_ID__c);
                    }
                }
            }
            
            //If an Account with same ERP Customer Id does not exist, Create a new ERP Company
            if(!mapERPIdAccs.isEmpty()){
                for(String erpId:mapERPIdAccs.keySet()){
                    ERP_Company__c erpCompany = new ERP_Company__c();
                    lstErpCompanyToInsert.add(erpCompany);                
                }
            }
            
            //Inserting ERP Company Records records
            if(!lstErpCompanyToInsert.isEmpty()){
                List<String> lstErpIds = new List<String>(mapERPIdAccs.keySet());
                try{
                    Database.SaveResult[] insertResult = Database.insert(lstErpCompanyToInsert, false);
                    for (Database.SaveResult sr : insertResult) {
                        //Associating the Account with ERP Company records
                        if (sr.isSuccess()) {
                            Set<Id> setAccIds = mapERPIdAccs.get(lstErpIds.remove(0));
                            for(Id accId:setAccIds){
                                newMap.get(accId).ERP_Company__c = sr.getId();
                            }
                        }
                    }                    
                }        
                catch(DmlException e){
                    GAM.CreateExceptionRecords('AccountTriggerHandler.AccountBeforeUpdate', 'Error while creating the ERP Custmoer Records: ', e.getMessage());
                }             
            }         
        }
    }
    
    
    //--------------------------------------------------------------------------------------------------------------------<T1> 
    
    //----------------------------------------------------------------------------------<T03>
    /**
    * this method is invoked from before update event of account
    * @param newMap - map of new Accounts, oldMap - map of old Accounts
    * Checks if an of the fields in company data section was updated by the users other than Integration User
    * @return return-void
    * @throws exception - NA
    public static void checkCompanyDataUpdate(map<Id,Account> newMap, map<Id,Account> oldMap){
        Set<Account> setAccountErr = new Set<Account>();
        List<Schema.FieldSetMember> fs =Schema.SObjectType.Account.fieldSets.Company_Data_Section.getFields();
        List<String> lstFields = new List<String>();
        if(fs != null){
            for(Schema.FieldSetMember fsMember:fs){
                lstFields.add(fsMember.getFieldPath());
            }
        } 
        for(Account accRec:newMap.values()){
            for(String field:lstFields){
                if(accRec.get(field) != oldMap.get(accRec.Id).get(field)){
                    setAccountErr.add(accRec);
                }
            }
        }
        if(!setAccountErr.isEmpty()){
            String errMsg = Label.Account_Company_Data_section_Error;
            for( Account ac:setAccountErr){
                ac.adderror(errMsg);          
            }  
        }
    }
    //----------------------------------------------------------------------------------</T03>    */
    
    //-------------------------------------------------------------------------------------------------------------<T02>
     Public static void handleAccountAfterUpdate (List<Account> newLst, map<Id,Account> oldMap ){

        Id PartnerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        Id supportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId(); //<T04>
        Id customerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); //<T06>

        set<Id> setCustomerAccountIds = new set<Id>();
        set<Id> setPartnerAccountIds = new set<Id>();
        set<Id> setAccUpdated = new set<Id>();
        Set<Id> setSupportAccountIds = new Set<Id>(); //<T04>
        Set<Id> setPrimaryContactIds = new Set<Id>(); //<T04>
        Set<Id> setPartnerAccounts = new Set<Id>(); //<T04>
        Map<Id, AccountContactRelation> mapPrimaryContacts = new Map<Id, AccountContactRelation>(); //<T04>
        Set<Id> setSuccessPortfolioChangedIds = new Set<Id>();//<T06>


        List<Account> lstPartnerAccounts = new List<Account>();
        for(Account acc : newLst){
            if(acc.Signature_Success__c != oldMap.get(acc.id).Signature_Success__c){
                setCustomerAccountIds.add(acc.id);
            }

            //---------------------------------------<T06>------------------------------
            if(acc.RecordtypeId == customerAccountRecType && acc.Success_Portfolio__c != oldMap.get(acc.id).Success_Portfolio__c){
                setSuccessPortfolioChangedIds.add(acc.id);
            }
            //---------------------------------------</T06>------------------------------

            if(acc.RecordtypeId ==PartnerAccountRecType && 
            (acc.Partner_Support_Entitlement__c != oldMap.get(acc.id).Partner_Support_Entitlement__c ||
            acc.Partner_Support_End_Date__c!=oldMap.get(acc.id).Partner_Support_End_Date__c )){
                setPartnerAccountIds.add(acc.Id);
            }
            //@Akhilesh 22 Aug 2021 -- start
            if(acc.Acc__c != oldMap.get(acc.Id).Acc__c){
                setAccUpdated.add(acc.Id);
            }
            //@Akhilesh 22 Aug 2021 -- end

            //---------------------------------------<T04>------------------------------
            if(acc.RecordTypeId == supportAccountRecType && acc.Active__c != oldMap.get(acc.Id).Active__c && acc.Active__c){
                setSupportAccountIds.add(acc.Id);
            }
            //---------------------------------------</T04>-----------------------------
        }
        System.debug('@Developer --> setAccUpdated :' + setAccUpdated);

        Map<Id,Account> mapSupportAccounts = new Map<Id,Account>([Select id from Account where parentId in :setCustomerAccountIds and Active__c = true and End_Date__c>=Today and RecordType.developername ='Support_Account']);

        if(mapSupportAccounts?.keySet()?.size()>0){

            if(!System.isFuture() && !system.isBatch() && !Test.IsRunningTest()){
                SupportAccountService.updateSupportAccountsFuture(mapSupportAccounts.keySet());
            }
            else{
                SupportAccountService.updateSupportAccounts(mapSupportAccounts.keySet());
            }
        }



        if(setPartnerAccountIds?.size()>0){

            /*if(!System.isFuture() && !system.isBatch() && !Test.IsRunningTest()){
                SupportAccountService.upsertPartnerSupportAccountsFuture(setPartnerAccountIds);
            }
            else{*/
                SupportAccountService.upsertPartnerSupportAccounts(setPartnerAccountIds);
            //}
        }
        
        //@Akhilesh 22 Aug 2021 -- start
        if(setAccUpdated.size() > 0){
            list<Case> lstCase = [Select Id From Case Where Support_Account__c  In :setAccUpdated And IsClosed = false];
            System.debug('@Developer --> lstCase.size() :' + lstCase.size());
            update lstCase;
        }
        //@Akhilesh 22 Aug 2021 -- end

        //---------------------------------------<T04>-------------------------------
        for(Account objAccount : [Select Id,Active__c,Contract__r.SBQQ__Order__r.ShipToContactId,ParentId,Parent.RecordtypeId from Account where Id IN :setSupportAccountIds]){ //<T05>
            
            //Support Accounts created under Customer Account
            if(String.isNotEmpty(objAccount?.Contract__r?.SBQQ__Order__r?.ShipToContactId)){ //<T05>
                setPrimaryContactIds.add(objAccount.Contract__r.SBQQ__Order__r.ShipToContactId); //<T05>
            }

            //Support Accounts created under Partner Account
            if(objAccount.Parent.RecordTypeId == PartnerAccountRecType){
                setPartnerAccounts.add(objAccount.ParentId);
            }
        }

        //Query all Partner Portal Admin contacts from Partner Accounts
        for(Contact objContact : [Select Id,Name,AccountId from Contact where Partner_Role__c = 'Partner Portal Admin' and AccountId IN :setPartnerAccounts]){
            setPrimaryContactIds.add(objContact.Id);
        }

        for(AccountContactRelation objAccountContactRelation : [Select Id,IsActive,AccountId from AccountContactRelation where ContactId IN :setPrimaryContactIds and IsActive = false and Account.RecordTypeId =: supportAccountRecType]){
            if(setSupportAccountIds.contains(objAccountContactRelation.AccountId)){
                objAccountContactRelation.IsActive = true;
                mapPrimaryContacts.put(objAccountContactRelation.Id, objAccountContactRelation);
            }
        }

        if(!mapPrimaryContacts.isEmpty()){ 
            try{
                Database.update(mapPrimaryContacts.values(), false);                  
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('AccountTriggerHandler.AccountAfterUpdate', 'Error while activating primary supportaccount contact', e.getMessage());
            }              
        }
        //---------------------------------------</T04>------------------------------
        //<SALESRT-13728> start
        newLogoSpiffCalculator(newLst,(Map<Id,Account>)Trigger.newMap,oldMap);
        //<SALESRT-13728> end
        sendChatterNotification(newLst,oldMap); //<I2C-1520>

        //---------------------------------------<T06>------------------------------
        if(!setSuccessPortfolioChangedIds.isEmpty()){
            handleSuccessPortfolioChange(setSuccessPortfolioChangedIds, (Map<Id,Account>)Trigger.newMap);
        }
        //---------------------------------------</T06>------------------------------
    }
    //------------------------------------------------------------------------------------------------<T02>

    //--------------------------------------------------------------------------------------------------------------------<I2C-1520>
        /**
        * this method is invoked from after update event of account
        * @param AccountList,oldMap
        * @return return-void
        * @throws exception - NA
        */
    //<I2C-1520> - To send chatter notification to CMS team when account name or customer ID is changed
    public static void sendChatterNotification(List<Account> AccountList,Map<id,Account> oldMap )
    {
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId(); //<I2C-1520>
        Id PotentialPartnerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Potential Partner Account').getRecordTypeId();  //<I2C-1520>
        Map<id, String> chatterAccountList = new Map<id, String>();        
        Id collabGroup  ;
        
        //Get the CMS Team Collaboration group 
        List<CollaborationGroup> collGroup = new List<CollaborationGroup>(); 
        collGroup = [select ID, name from CollaborationGroup where Name = 'CMS Team' limit 1];
        if(!collGroup.isEmpty()) collabGroup = collGroup[0].ID;
                
        for(Account acc:AccountList)
        {    // Check if the name or ERP Customer ID is changed       
            if(  acc.RecordTypeId != SupportAccountRecType && acc.RecordTypeId != PotentialPartnerAccountRecType &&
               (
                   acc.Name != oldMap.get(acc.id).name  ||
                    acc.Peoplesoft_External_ID__c != oldMap.get(acc.id).Peoplesoft_External_ID__c  
               ) )              
            {    // update the chatter message                          
                String message = ' Team, Below SFDC Account Name/ERP Customer ID is modified:'+'\n' +
                    'Old Account Name: '+oldMap.get(acc.id).name + '\n' +
                    'New Account Number: '+acc.name +  '\n' +
                    'Old ERP Customer ID: '+oldMap.get(acc.id).Peoplesoft_External_ID__c  + '\n' +
                    'New ERP Customer ID:'+acc.Peoplesoft_External_ID__c +'\n' +
                    'Modified By User: '+ UserInfo.getName() + '\n' +
                    'Modified Date & Time: '+ acc.LastModifiedDate ;                              
                chatterAccountList.put(acc.id,message);               
            }              
        }
        
        for(id ids: chatterAccountList.keySet() )
        {
            String message = chatterAccountList.get(ids);                       
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            //chatter ID 
            if(collabGroup!=null)          
            { messageBodyInput.messageSegments.add(ChatterService.inputMention(collabGroup));}
             //get message body
            messageBodyInput.messageSegments.add(ChatterService.inputText(message));                            
            //assign subjectid, body
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            feedItemInput.subjectId = ids;
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;            
            //send chatter notification
            if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }
        }
     }

    //<SALESRT-13728> start
    /*
    * this method calculates and populates New logo spiff checkbox on opportunity
    * @param parameter- newOpps - list of new Accounts, newMap - Map of new accounts, oldMap - trigger.oldMap for accounts
    * @return return- void
    * @throws exception-captures exception in a debug log
    */
    public static void newLogoSpiffCalculator(List<Account> newList, Map<Id,Account> newMap, Map<Id,Account> oldMap){
        String eligible =  System.Label.Spiff_Eligible;
        String activeCus =  System.Label.Spiff_ActiveCustomer;
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : newList){
            if(oldMap != null && oldMap.get(acc.Id).New_Logo_SPIFF__c != acc.New_Logo_SPIFF__c &&
                ( String.isBlank(acc.New_Logo_SPIFF__c) || acc.New_Logo_SPIFF__c.containsIgnoreCase(eligible) || acc.New_Logo_SPIFF__c.containsIgnoreCase(activeCus))){
                accIdSet.add(acc.Id);
            }
        }
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        if(!accIdSet.isEmpty()){
            for(Opportunity opp : [SELECT Id,AccountId,New_Logo_SPIFF__c,IsClosed FROM Opportunity WHERE AccountId IN :accIdSet AND IsClosed = false]){
                //The Eligible Scenario
                Boolean check = false;
                if(newMap.containsKey(opp.AccountId) && String.isBlank(newMap.get(opp.AccountId).New_Logo_SPIFF__c) && !opp.IsClosed){
                    opp.New_Logo_SPIFF__c = false;
                    check = true;
                }
                else if(newMap.containsKey(opp.AccountId) && newMap.get(opp.AccountId).New_Logo_SPIFF__c.containsIgnoreCase(eligible) && !opp.IsClosed ){
                    opp.New_Logo_SPIFF__c = true;
                    check = true;
                }
                else if(newMap.containsKey(opp.AccountId) && newMap.get(opp.AccountId).New_Logo_SPIFF__c.containsIgnoreCase(activeCus) && !opp.IsClosed){
                    opp.New_Logo_SPIFF__c = false;
                    check = true;
                }
                
                if(check){
                    oppsToUpdate.add(opp);
                }
            }
        }
        if(!oppsToUpdate.isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(oppsToUpdate, false);             
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('AccountTriggerHandler.newLogoSpiffCalculator', 'Error while updating Opportunities: ', e.getMessage());
            } 
        }
    }
    //<SALESRT-13728> end


    //---------------------------------------<T06>------------------------------
    /*
    * this method handles account team member removal and addition based on the success portfolio value on the Account
    * @param parameter- newOpps - list of new Accounts, newMap - Map of new accounts, oldMap - trigger.oldMap for accounts
    * @return return- void
    * @throws exception-captures exception in a debug log
    */
    public static void handleSuccessPortfolioChange(Set<Id> changedAccSet, Map<Id,Account> newMap){
        String spmRole = 'Success Portfolio Manager';
        List<AccountTeamMember> insertList= new List<AccountTeamMember>();
        List<AccountTeamMember> deleteList= new List<AccountTeamMember>();
        Map<String, String>  spmMapping = new Map<String, String>();
        Map<String, Id>  userMap = new Map<String, Id>();

        for(Success_Portfolio_Manager_Mappings__mdt spm: Success_Portfolio_Manager_Mappings__mdt.getAll().values()){
            spmMapping.put(spm.Success_Portfolio__c,spm.Manager_Email__c);
        }

        if(!spmMapping.isEmpty()){
            for(User usr: [Select Id, email from User where IsActive=true AND userType='Standard' AND email IN :spmMapping.values()]){
                userMap.put(usr.email,usr.Id);
            }
        }

        deleteList = [Select Id from AccountTeamMember where TeammemberRole= :spmRole AND accountId IN :changedAccSet];

        if(!deleteList.isEmpty()){
            try{
                Database.DeleteResult[] deleteResult = Database.delete(deleteList, false);             
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('AccountTriggerHandler.handleSuccessPortfolioChange', 'Error while deleting AccountTeamMember: ', e.getMessage());
            } 
        }

        for(Id accid:changedAccSet){
            AccountTeamMember atm = new AccountTeamMember();
            atm.AccountId = accid;
            atm.TeammemberRole = spmRole;
            atm.UserId = userMap.get(spmMapping.get(newMap.get(accid).Success_Portfolio__c));
            atm.AccountAccessLevel = 'Edit';
            atm.ContactAccessLevel = 'Edit';
            atm.CaseAccessLevel = 'Edit';
            atm.OpportunityAccessLevel = 'Edit';
            insertList.add(atm);
        }

        if(!insertList.isEmpty()){
            try{
                Database.SaveResult[] insertResult = Database.insert(insertList, false);             
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('AccountTriggerHandler.handleSuccessPortfolioChange', 'Error while inserting AccountTeamMember: ', e.getMessage());
            } 
        }
        GAM.InsertDebugLogs();
    }
    
    //---------------------------------------</T06>------------------------------
  }