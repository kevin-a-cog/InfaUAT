/*
Class:          SupportAccountService 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Service Class for Support Account changes
**************************************************************************************************************
MODIFIED BY         MODIFIED Date   JIRA          DESCRIPTION                                           TAG
**************************************************************************************************************
apyati              15-Feb-2021   I2RT-450        Added methods for partner support account             T01

apyati              15-apr-2021   I2RT-2490       Added menthod for updating No of cases allowed        T02
Vignesh Divakaran   05-Jan-2022   I2RT-4972       Update Standard entitlement on support account        T03
Vignesh Divakaran   09-Feb-2022   I2RT-5360       Create Primary Contact as inactive                    T04
Vignesh Divakaran   21-Feb-2022   I2RT-5185       Project Booster changes                               T05
Vignesh Divakaran   24-Feb-2022   I2RT-5443       Populate max number of cases for Basic success        T06
Vignesh Divakaran   25-Mar-2022   I2RT-5783       Remove automatic downgrade based on amend/renewal     T07
                                                  and check Nominations if any field for downgrade
Vignesh Divakaran   22-Jun-2022   I2RT-6476       Rollup latest active certification request            T08
Sandeep D           6/28/2022     I2RT-6485       technical product line clean up                       T09  
Sandeep D           7/26/2022     I2RT-6742       Entitled Products creation for Support Accounts       T10
Vignesh Divakaran   18-May-2023   I2RT-8349       Added filter to ignore EPs when Partner account's		T11
												  Partner Support Entitlement is equal to No Support
Vignesh Divakaran   16-Jun-2023   I2RT-8398       Added filter to exclude Archived EPs          		T12
Vignesh Divakaran   21-Jul-2023   I2RT-8640       Commented the code to rollup certification request    T13
                                                  onto support account.
**********************************************************************************************************


*/

public class SupportAccountService {

    static final String BASIC_SUCCESS = 'Basic Success';
    static final String PREMIUM_SUCCESS = 'Premium Success';
    static final String SIGNATURE_SUCCESS = 'Signature Success';
    static final String STANDARD = 'Standard';
    static final String SIGNATURE_SELECT = 'Signature Select'; //<T05>
    
    public static final String Hosted_Single_Tenant = 'Hosted Single Tenant'; // t10


    static final Integer MAX_COUNT_BASIC_SUCCESS = 2;
    static final Integer MAX_COUNT_STANDARD = 6;
    static final Integer MAX_COUNT_PREMIUM_SUCCESS = 8;
    static final Integer MAX_COUNT_SIGNATURE_SUCCESS = 12;

    public static final String BASIC_PACK = 'Case Pack';



    @AuraEnabled
    public static string supportAccountRollup( Id SupportAccountId){        
        set<id> setSupportAccountIds = new set<id>();
        try{
            if(SupportAccountId != null){
                setSupportAccountIds.add(SupportAccountId);
                updateSupportAccounts(setSupportAccountIds);
            }
            return 'SUCCESS';
        }catch(Exception e){
            System.debug('ERROR'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

  

    
    @Future
    public static void updateSupportAccountsFuture(Set<id> setSupportAccountIds){
        updateSupportAccounts(setSupportAccountIds);
    }

    //Rollup Support Account
    public static void updateSupportAccounts( Set<id> setSupportAccountIds) {

        System.debug('Enter Method updateSupportAccounts');

        /* Commented as part of <T05>
        GlobalApexManager GAM = new GlobalApexManager();
        Map<Id,Date> mapSupportAccountMaxEndDate = new map<Id,Date>();
        Map<Id,Entitlement> mapSupportAccountEnt = new map<Id,Entitlement>();
        Map<Id,Entitled_Product__c> mapSupportAccountEP = new Map<Id,Entitled_Product__c>();
        Map<Id,Entitled_Product__c> mapSupportAccountEPStandard = new Map<Id,Entitled_Product__c>();
        Map<Id,string> mapSupportAccountLevel = new map<Id,string>();
        map<id,id> mapServiceAccountSignEnt = new map<Id,Id>();
        map<id,id> mapServiceAccountSignAsset = new map <Id,Id>();
        List<Account> lstUpdateSupportAcccount = new List<Account>();
        //List<Asset> lstUpsertAssets = new List<Asset>();
        List<Entitlement> lstUpsertEntitlements = new List<Entitlement>();
        //set<id> setNewAssets = new set<id>();
        set<id> setNewEntitlements = new set<Id>(); 
        map<String,id> mapEntitlementProcess = new map<string,id>();
        set<Account>  setSignatureSupportAccounts = new Set<Account>();



        //Get Max end date for each Support Account
        //Amarender - I2RT-2949 -- Modified SOQL to fetch entitlements of provided Support Account only.
        // "Support_Account__c in :setSupportAccountIds" changed to "Entitlement__c != null and Support_Account__c in :setSupportAccountIds"
        for(AggregateResult ar: [Select max(End_date__c) maxEndDate, Support_Account__c SupportAccountId from Entitled_Product__c where End_Date__c >= Today and Entitlement__c != null and Support_Account__c  in :setSupportAccountIds group by Support_Account__c]){
            mapSupportAccountMaxEndDate.put((Id)ar.get('SupportAccountId'),(Date)ar.get('maxEndDate'));
        }
        system.debug('mapSupportAccountMaxEndDate'+mapSupportAccountMaxEndDate);	


        //Get hightest Support level entitlement for each support account	
        //Amarender - I2RT-2949 -- Modified SOQL to fetch entitlements of provided Support Account only.
        // "Support_Account__c in :setSupportAccountIds" changed to "Entitlement__c != null and Support_Account__c in :setSupportAccountIds"
        for(Entitled_Product__c EP :[Select Id,Name,Entitlement__c,Support_Account__c,Support_level__c,End_date__c from Entitled_Product__c where Entitlement__c != null and Support_Account__c in :setSupportAccountIds and End_Date__c >= Today and  Support_Level__c != : SIGNATURE_SUCCESS and Support_Level__c != : STANDARD  order by Support_Account__c ,Support_Level__c desc ,End_date__c desc]){	
            if(!mapSupportAccountEP.containskey(EP.Support_Account__c))	
                mapSupportAccountEP.put(EP.Support_Account__c,EP);	
        }	
        system.debug('mapSupportAccountEP'+mapSupportAccountEP);	

        //Get  Support level entitlement of Standard
        //Order - Signature - Premium - Stadard - Basic KG
        for(Entitled_Product__c EP :[Select Id,Name,Entitlement__c,Support_Account__c,Support_level__c,End_date__c from Entitled_Product__c where Entitlement__c != null and Support_Account__c in :setSupportAccountIds and End_Date__c >= Today and Support_Level__c = : STANDARD  order by Support_Account__c ,Support_Level__c desc ,End_date__c desc]){	
            if(!mapSupportAccountEPStandard.containskey(EP.Support_Account__c))	
                mapSupportAccountEPStandard.put(EP.Support_Account__c,EP);	
        }	
        system.debug('mapSupportAccountEP'+mapSupportAccountEP);

        //Get Signature Asset & Entilement for each Support account	
        for(Entitlement ent : [Select id, AssetId, Support_Account__c from entitlement where Support_Account__c in :setSupportAccountIds and Support_Level__c = : SIGNATURE_SUCCESS ]){	
            mapServiceAccountSignEnt.put(ent.Support_Account__c ,Ent.Id);	
        }	
        system.debug('mapServiceAccountSignEnt'+mapServiceAccountSignEnt);	

        //get Entitlement Process
        For( SlaProcess sp :[Select Id, Name from SlaProcess where isActive =true]){
            mapEntitlementProcess.put(sp.Name,sp.id);
        }
        system.debug('mapEntitlementProcess'+mapEntitlementProcess);

        
        for(Account sa : [Select id,Max_Number_of_Cases_Allowed__c, ParentId,Parent.Signature_Success__c,Max_Customer_R_W_Contacts__c,Admin_Overirde__c from Account where id in: setSupportAccountIds ] ){
            
        
            //Support Level as Signature Success 
            if(sa.Parent.Signature_Success__c && mapSupportAccountMaxEndDate?.get(sa.Id) !=null && mapSupportAccountMaxEndDate?.get(sa.Id) >= System.Today()){
                
                system.debug('create signature success');
                Account updateSA = new Account(Id= sa.Id);
                updateSA.Success_Offering__c = SIGNATURE_SUCCESS;
                updateSA.End_Date__c = mapSupportAccountMaxEndDate?.get(sa.Id);
                if(!sa.Admin_Overirde__c){
                    updateSA.Max_Customer_R_W_Contacts__c = MAX_COUNT_SIGNATURE_SUCCESS;
                }
                
                //Update Signature entitlement if present
                if(mapServiceAccountSignEnt.containskey(sa.Id)){
                    updateSA.Entitlement__c = mapServiceAccountSignEnt.get(sa.Id);
                    lstUpdateSupportAcccount.add(updateSA);

                    Entitlement updateEnt = new Entitlement (Id = mapServiceAccountSignEnt.get(sa.id));
                    updateEnt.EndDate= mapSupportAccountMaxEndDate.get(sa.id);
                    lstUpsertEntitlements.add(updateEnt);
                }
                //Create new Signature Success  Entitlement
                else{
                    Entitlement ent = new Entitlement();
                    ent.Name = SIGNATURE_SUCCESS;
                    ent.Support_Level__c = SIGNATURE_SUCCESS;
                    ent.slaprocessId = mapEntitlementProcess?.get(SIGNATURE_SUCCESS);
                    ent.AccountId = sa.ParentId;
                    ent.Support_Account__c = sa.id;
                    ent.StartDate = System.Today();
                    ent.EndDate =mapSupportAccountMaxEndDate.get(sa.id);
                    lstUpsertEntitlements.add(ent);
                    setSignatureSupportAccounts.add(sa);
                }

            }
            //Support Level from higest entitlment
            else {

                system.debug('end signature success');

                Account updateSA = new Account(Id= sa.Id);
                if(mapSupportAccountEP?.get(sa.Id)?.Entitlement__c!= null){
                    updateSA.Entitlement__c = mapSupportAccountEP?.get(sa.Id)?.Entitlement__C;
                }
                if(mapSupportAccountEP?.get(sa.Id)?.Support_Level__c != null){
                    updateSA.Success_Offering__c = mapSupportAccountEP?.get(sa.Id)?.Support_Level__c;
                }
                if(mapSupportAccountEPStandard.containsKey(sa.Id) && mapSupportAccountEP?.get(sa.Id)?.Support_Level__c != PREMIUM_SUCCESS && !sa.Parent.Signature_Success__c){
                    updateSA.Entitlement__c = mapSupportAccountEPStandard?.get(sa.Id)?.Entitlement__c; //<T03>
                    if(mapSupportAccountEPStandard?.get(sa.Id)?.Support_Level__c != null){
                        updateSA.Success_Offering__c = mapSupportAccountEPStandard?.get(sa.Id)?.Support_Level__c;
                    }
                }
                if(mapSupportAccountMaxEndDate?.get(sa.Id)!= null){
                    updateSA.End_Date__c = mapSupportAccountMaxEndDate?.get(sa.Id);
                }
                if(!sa.Admin_Overirde__c && mapSupportAccountEP?.get(sa.Id)?.Support_Level__c == BASIC_SUCCESS){
                    updateSA.Max_Customer_R_W_Contacts__c = MAX_COUNT_BASIC_SUCCESS ;
                }
                else if(!sa.Admin_Overirde__c && mapSupportAccountEP?.get(sa.Id)?.Support_Level__c == PREMIUM_SUCCESS){
                    updateSA.Max_Customer_R_W_Contacts__c = MAX_COUNT_PREMIUM_SUCCESS;
                }
                else if(!sa.Admin_Overirde__c && mapSupportAccountEP?.get(sa.Id)?.Support_Level__c == PREMIUM_SUCCESS){
                    updateSA.Max_Customer_R_W_Contacts__c = MAX_COUNT_PREMIUM_SUCCESS;
                }
                else if(!sa.Admin_Overirde__c && mapSupportAccountEP?.get(sa.Id)?.Support_Level__c == STANDARD){
                    updateSA.Max_Customer_R_W_Contacts__c = MAX_COUNT_STANDARD;
                }
                //  <T02> Update Maximum Number of cases allowed 
                if( mapSupportAccountEP?.get(sa.Id)?.Support_Level__c == BASIC_SUCCESS && sa.Max_Number_of_Cases_Allowed__c == 'Unlimited' ){
                    updateSA.Max_Number_of_Cases_Allowed__c = '10';
                }
                else if( mapSupportAccountEP?.get(sa.Id)?.Support_Level__c == BASIC_SUCCESS && sa.Max_Number_of_Cases_Allowed__c!= null && sa.Max_Number_of_Cases_Allowed__c.isNumeric()){
                    updateSA.Max_Number_of_Cases_Allowed__c = sa.Max_Number_of_Cases_Allowed__c;
                }else{ 
                    updateSA.Max_Number_of_Cases_Allowed__c = 'Unlimited';
                }
                //</T02>
                lstUpdateSupportAcccount.add(updateSA);

                //End Signature Assets & entitlements if present
                if(mapServiceAccountSignEnt?.containskey(sa.Id)){
                    Entitlement updateEnt = new Entitlement (Id = mapServiceAccountSignEnt?.get(sa.Id));
                    updateEnt.EndDate= System.Today();
                    lstUpsertEntitlements.add(updateEnt);
                }
            }            

        }*/

        //---------------------------------------<T05>-------------------------------

        GlobalApexManager GAM = new GlobalApexManager();
        // Date cutOffDate = date.newinstance(2022, 4, 19); //(Year, Month, Day) Commented as part of <T07>
        Set<String> setSupportLevels = new Set<String>();
        // Set<Id> setProcessedSupportAccountIds = new Set<Id>(); Commented as part of <T07>
        List<Account> lstUpdateSupportAcccount = new List<Account>();
        List<Entitlement> lstUpdateEntitlements = new List<Entitlement>();
        Map<Id, Entitled_Product__c> mapSupportAccountEP = new Map<Id, Entitled_Product__c>();
        Map<String, Success_Offering__mdt> mapSuccessOfferingMDT = new Map<String, Success_Offering__mdt>();
        // Date dToday = GlobalUtility.getOrganizationDate(); //<T08> //<T13>
        // Set<String> setRequestTypes = new Set<String>(); //<T08> //<T13>

        //Get success offering custom metadata records
        for(Success_Offering__mdt objSuccessOffering : Success_Offering__mdt.getAll().values()){

            //Check if the record is active and add it to the success offering map
            if(objSuccessOffering.Active__c){
                if(objSuccessOffering.Label != SIGNATURE_SUCCESS){
                    setSupportLevels.add(objSuccessOffering.Label);
                }
                mapSuccessOfferingMDT.put(objSuccessOffering.Label, objSuccessOffering);
            }
        }

        //------------------------------<T08>------------------------------
        //Get picklist values from Request Type field on Certification Request object
        /*Schema.DescribeFieldResult objFieldDescribe = Certification_Request__c.Request_Type__c.getDescribe();
        for (Schema.PicklistEntry objPickList : objFieldDescribe.getPickListValues()) {
            //Add an entry for each request type
            setRequestTypes.add(objPickList.getValue());
        }*/ //<T13>
        //------------------------------</T08>------------------------------

        //Now, we query support accounts and the associated Signature Success entitlements
        Map<Id, Account> mapSupportAccounts = new Map<Id, Account>([Select Id,
                                                                    ParentId,
                                                                    Parent.RecordType.Name,
                                                                    Admin_Overirde__c,
                                                                    Max_Number_of_Cases_Allowed__c,
                                                                    Nominations_if_any__c,
                                                                    /*GCS_Segment__c,
                                                                    Certification_Request__c,
                                                                    Certification_Request_Start_Date__c,
                                                                    Certification_Request_End_Date__c,
                                                                    Product__c,*/
                                                                    (Select Id,Support_Level__c,EndDate from Entitlements__r Where Support_Level__c = :SIGNATURE_SUCCESS Order by EndDate DESC LIMIT 1)
                                                                    /*(Select Id, Start_Date__c, End_Date__c, Request_Type__c,CreatedDate,Product__c FROM Certification_Requests__r 
                                                                        WHERE Status__c = 'Approved' AND ((Start_Date__c <= :dToday AND End_Date__c >= :dToday) OR (Start_Date__c >= :dToday AND End_Date__c >= :dToday))
                                                                        ORDER BY Start_Date__c ASC, End_Date__c DESC)*/ //<T08> //<T13>
                                                                    from Account Where Id IN :setSupportAccountIds]);

        //Now, we query entitled products associated to support accounts
        Map<Id, Entitled_Product__c> mapEntitledProducts = new Map<Id, Entitled_Product__c>([Select Id,
                                                                                             Name,
                                                                                             Support_Account__c,
                                                                                             Entitlement__c,
                                                                                             Support_Level__c,
                                                                                             End_Date__c 
                                                                                             from Entitled_Product__c 
                                                                                             Where Support_Account__c IN :setSupportAccountIds AND Support_Level__c IN :setSupportLevels AND Entitlement__c != null AND Archived__c = false //<T12>
                                                                                             order by Support_Account__c, End_Date__c DESC LIMIT 50000]);

        for(Entitled_Product__c objEntitledProduct : mapEntitledProducts.values()){  
            if(mapSupportAccountEP.containsKey(objEntitledProduct.Support_Account__c)){
                
                //Check if the current entitled product's EndDate >= today and support level is higher in precedence, than that of existing entitled product
                Entitled_Product__c objEntitledProductExisting = mapSupportAccountEP.get(objEntitledProduct.Support_Account__c);
                if(objEntitledProduct.End_Date__c >= System.today()
                    && (mapSuccessOfferingMDT.containsKey(objEntitledProduct.Support_Level__c)
                    && (mapSuccessOfferingMDT.get(objEntitledProduct.Support_Level__c).Order_of_Precedence__c < mapSuccessOfferingMDT.get(objEntitledProductExisting.Support_Level__c).Order_of_Precedence__c))){

                    mapSupportAccountEP.put(objEntitledProduct.Support_Account__c, objEntitledProduct);
                }
            }
            else{
                mapSupportAccountEP.put(objEntitledProduct.Support_Account__c, objEntitledProduct);
            }
        }

        /* Commented as part of <T07>
        for(AggregateResult ar : [Select MAX(SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__r.CreatedDate) orderCreatedDate,Entitled_Product__r.Support_Account__c supportAccountId FROM Asset Where Entitled_Product__c IN :mapEntitledProducts.keySet() AND SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__r.Type IN ('Amendment','Renewal','New')
                                  AND SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__c != null Group By Entitled_Product__r.Support_Account__c]){

            if((DateTime)ar.get('orderCreatedDate') > cutOffDate){
                setProcessedSupportAccountIds.add((Id)ar.get('supportAccountId'));
            }
        }*/

        for(Id supportAccountId : mapSupportAccountEP.keySet()){

            Account objSupportAccount = new Account(Id = supportAccountId);
            Account objSupportAccountOld = mapSupportAccounts.get(supportAccountId);
            Entitled_Product__c objEntitledProduct = mapSupportAccountEP.get(supportAccountId);

            if(objSupportAccountOld.Nominations_if_any__c != SIGNATURE_SUCCESS || (objSupportAccountOld.Nominations_if_any__c == SIGNATURE_SUCCESS && mapSuccessOfferingMDT.get(objEntitledProduct.Support_Level__c).Order_of_Precedence__c < mapSuccessOfferingMDT.get(SIGNATURE_SUCCESS).Order_of_Precedence__c) /*|| (objSupportAccountOld.Nominations_if_any__c == SIGNATURE_SUCCESS && setProcessedSupportAccountIds.contains(supportAccountId))*/){  //<T07>     
                objSupportAccount.Nominations_if_any__c = null;
                objSupportAccount.Entitlement__c = objEntitledProduct?.Entitlement__c;
                objSupportAccount.End_Date__c = objEntitledProduct?.End_Date__c;
                objSupportAccount.Success_Offering__c = objEntitledProduct?.Support_Level__c;

                //Now, we expire Signature Success entitlements
                for(Entitlement objEntitlement : objSupportAccountOld.Entitlements__r){
                    if(objEntitlement.EndDate > System.Today()){ //<T07>
                        objEntitlement.EndDate = System.Today();
                        lstUpdateEntitlements.add(objEntitlement);
                    }
                }
            }
            else if(objSupportAccountOld.Nominations_if_any__c == SIGNATURE_SUCCESS  && mapSuccessOfferingMDT.get(objEntitledProduct.Support_Level__c).Order_of_Precedence__c > mapSuccessOfferingMDT.get(SIGNATURE_SUCCESS).Order_of_Precedence__c/*&& !setProcessedSupportAccountIds.contains(supportAccountId)*/){  //<T07>
                
                //Now, we rollup the highest entitlement enddate onto Signature Success entitlement
                for(Entitlement objEntitlement : objSupportAccountOld.Entitlements__r){
                    objEntitlement.EndDate = objEntitledProduct?.End_Date__c;
                    lstUpdateEntitlements.add(objEntitlement);
                    objSupportAccount.Entitlement__c = objEntitlement.Id;
                    objSupportAccount.End_Date__c = objEntitledProduct?.End_Date__c;
                    objSupportAccount.Success_Offering__c = objEntitlement.Support_Level__c; 
                }
            }
            
            if(!objSupportAccountOld.Admin_Overirde__c){
                objSupportAccount.Max_Customer_R_W_Contacts__c = mapSuccessOfferingMDT.get(objSupportAccount.Success_Offering__c)?.Max_Read_Write_Contacts__c;
            }

            //Set the number of cases allowed
            if(objSupportAccount?.Success_Offering__c == BASIC_SUCCESS &&  objSupportAccountOld.Max_Number_of_Cases_Allowed__c == 'Unlimited'){
                objSupportAccount.Max_Number_of_Cases_Allowed__c = '10';
            }
            else if(objSupportAccount?.Success_Offering__c != BASIC_SUCCESS){
                objSupportAccount.Max_Number_of_Cases_Allowed__c = 'Unlimited';
            }

            //------------------------------<T08>-------------------------------
            //Rollup Active Certification Request
            /*Certification_Request__c objActiveCertificationRequest;
            for(Certification_Request__c objCertificationRequest : mapSupportAccounts.get(supportAccountId).Certification_Requests__r){
                if(objActiveCertificationRequest == null){
                    objActiveCertificationRequest = objCertificationRequest;
                }
                else{
                    if(objCertificationRequest.Start_Date__c <= dToday && objCertificationRequest.End_Date__c >= dToday && objCertificationRequest.CreatedDate > objActiveCertificationRequest.CreatedDate){
                        objActiveCertificationRequest = objCertificationRequest;
                    }
                }
            }

            if(objActiveCertificationRequest != null){
                objSupportAccount.Certification_Request__c = objActiveCertificationRequest?.Id;
                objSupportAccount.Certification_Request_Start_Date__c = objActiveCertificationRequest?.Start_Date__c;
                objSupportAccount.Certification_Request_End_Date__c = objActiveCertificationRequest?.End_Date__c;
                objSupportAccount.Product__c = objActiveCertificationRequest?.Product__c;
                //Now, we check for inprogress certification request and update GCS Segment
                if((objActiveCertificationRequest.Start_Date__c <= dToday && objActiveCertificationRequest.End_Date__c >= dToday) && objSupportAccount.GCS_Segment__c != objActiveCertificationRequest.Request_Type__c){
                    objSupportAccount.GCS_Segment__c = objActiveCertificationRequest.Request_Type__c;
                }
                //Now, we check for future certification request and reset the GCS Segment to null
                if((objActiveCertificationRequest.Start_Date__c > dToday && objActiveCertificationRequest.End_Date__c >= dToday) && setRequestTypes.contains(objSupportAccount?.GCS_Segment__c)){
                    objSupportAccount.GCS_Segment__c = null;
                }
                if(objSupportAccountOld.Certification_Request__c != objSupportAccount.Certification_Request__c || 
                   objSupportAccountOld.Certification_Request_Start_Date__c != objSupportAccount.Certification_Request_Start_Date__c ||
                   objSupportAccountOld.Certification_Request_End_Date__c != objSupportAccount.Certification_Request_End_Date__c){

                    mapSupportAccounts.put(objSupportAccount.Id, objSupportAccount);       
                }
            }*/
            //------------------------------</T08>------------------------------

            lstUpdateSupportAcccount.add(objSupportAccount);
        }

        //---------------------------------------</T05>------------------------------
    
        /* Commented as part of <T05>
        system.debug('lstUpdateSupportAcccount-->'+lstUpdateSupportAcccount);
  
        //Upsert Entitlements
        System.debug('lstUpsertEntitlements'+lstUpsertEntitlements);

        if(lstUpsertEntitlements!=null && lstUpsertEntitlements.size()>0){
            Database.UpsertResult[] srList = Database.upsert(lstUpsertEntitlements);
            for (Database.UpsertResult sr : srList) {
                if (sr.isCreated()){
                    setNewEntitlements.add(sr.getId());
                }
                if(!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->updateSupportAccounts-->upsert of signature entitlements failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        System.debug('setNewEntitlements'+setNewEntitlements);

        //New Signature Entitlements
        for(Entitlement ent : [Select id,AccountId from Entitlement where id in :setNewEntitlements]){
            for(Account sa : setSignatureSupportAccounts){
                if(ent.AccountId == sa.ParentId && !mapServiceAccountSignEnt.containsKey(sa.id)){
                    mapServiceAccountSignEnt.put(sa.id,ent.Id);
                    break;
                }
            }
        }
        System.debug('mapServiceAccountSignEnt'+mapServiceAccountSignEnt);


        //Update Support Account with new Signature Entitlement
        for(Account sa : lstUpdateSupportAcccount){
            if(sa.Success_Offering__c == SIGNATURE_SUCCESS & mapServiceAccountSignEnt.containsKey(sa.id)){
                sa.Entitlement__c =mapServiceAccountSignEnt.get(sa.id);
            }
        }*/

        //---------------------------------------<T05>-------------------------------

        //Update Signature Success Entitlements
        if(lstUpdateEntitlements!= null && lstUpdateEntitlements.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateEntitlements);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->updateSupportAccounts-->update of Signature Success entitlements failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        //---------------------------------------</T05>------------------------------

        //Update Support Account
        system.debug('lstUpdateSupportAcccount-->'+lstUpdateSupportAcccount);

        if(lstUpdateSupportAcccount!= null && lstUpdateSupportAcccount.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateSupportAcccount);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->updateSupportAccounts-->update of Support level on support account failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        System.debug('Exit Method updateSupportAccounts');

    }

//---------------------------------------------------------------------<T01>
    @Future
    public static void upsertPartnerSupportAccountsFuture(Set<id> setPartnerAccountIds){
        upsertPartnerSupportAccounts(setPartnerAccountIds);
    }

    //Partner Support Account
    public static void upsertPartnerSupportAccounts( Set<id> setPartnerAccountIds) {

        GlobalApexManager GAM = new GlobalApexManager();

        List<Account> lstInsertSupportAccount=  new List<Account>();
        List<Entitlement> lstUpsertEnt= new List<Entitlement>();
        List<AccountContactRelation> lstInsertSupportContacts = new List<AccountContactRelation>();
        map<id,id> mapPartnerContact = new map<id,id>();
        set<id> hasSupportAccount = new set<id>();
        set<id> setNewSupportAccounts = new set<id>();
        map<id,Account> mapExistingSupportAccounts = new map<id,Account>();
        map<String,List<String>> mapUntentitledProducts = new map<String,List<String>>();
        List<Entitled_Product__c> lstInsertEntitledProduct = new List<Entitled_Product__c>();
        set<id> setNewEntitledProducts = new set<id>();
        set<id> setEntitledProductToRecalculate = new set<id>();
        set<id> setSupportAccountsToRecalculate  = new set<id>();
        List<Engagement__c> lstInsertEngagement = new List<Engagement__c>();
        List<Engagement__c> lstUpdateEngagements = new List<Engagement__c>();
        Set<id> setNewEngagementIds = new Set<Id>();
        set<id> setNewEtitlements = new set<Id>();
        map<id,Id> mapAccountEngagement= new map<Id,Id>();
        List<Entitled_Product__c> lstUpdateEp = new List<Entitled_Product__c>();
        map<id,Account> mapUpdateSupportAccount = new map<id,Account>();
        List<Entitlement> lstExistingEnt = new List<Entitlement>();
        List<Entitled_Product__c> lstExistingEP = new List<Entitled_Product__c>();
        Set<Id> setEndEnt = new set<Id>();
        //set<id> setEPToRecalculate = new set<id>();
        List<Entitled_Product__c> lstUpEP = new List<Entitled_Product__c>();


        system.debug('setPartnerAccountIds  ->'+setPartnerAccountIds);

        //check if support account exits or not
        for( Account sa : [Select id,End_Date__c,Success_Offering__c, Active__c, Parent.Partner_Support_End_Date__c,Parent.Partner_Support_Entitlement__c from Account where parentId in :setPartnerAccountIds and RecordType.developername ='Support_Account'and Support_Account_Type__c ='Partner']){
            mapExistingSupportAccounts.put(sa.id, sa);
            hasSupportAccount.add(sa.ParentId);
        }

        system.debug('mapExistingSupportAccounts  ->'+mapExistingSupportAccounts);
        system.debug('hasSupportAccount  ->'+hasSupportAccount);


        //Update existing support acccount entitled products
        lstExistingEnt = [Select id, Name,Entitled_Product__c,Entitled_Product__r.Support_Account__c,AccountId,Support_level__c,Startdate ,EndDate from Entitlement where Enddate >= Today and Entitled_Product__r.Support_Account__c in : mapExistingSupportAccounts.keyset()];

        for(Entitlement ent :lstExistingEnt){
            
            System.debug('Update existing Entitlement' + ent);

            if(ent.EndDate > mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_End_Date__c){
                //End existing ent by date
                Entitlement endEnt = new Entitlement(Id=ent.Id);
                endEnt.EndDate = mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_End_Date__c <ent.startdate ? 
                ent.startdate : mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_End_Date__c ;
                lstUpsertEnt.add(endEnt);
                System.debug(' //End existing ent by date' + endEnt);
                setEndEnt.add(ent.Entitled_Product__r.Support_Account__c);
            } 
            else if( mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_Entitlement__c == null ||
                    mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_Entitlement__c == 'No Support' ){
                //End existing ent by support level
                Entitlement endEnt = new Entitlement(Id=ent.Id);
                endEnt.EndDate = ent.Startdate<system.Today()?system.Today()-1:system.Today();
                lstUpsertEnt.add(endEnt);
                System.debug(' //End existing ent by support level' + endEnt);
                setEndEnt.add(ent.Entitled_Product__r.Support_Account__c);
                //setEPToRecalculate.add(ent.Entitled_Product__c);
                Entitled_Product__c entEp = new Entitled_Product__c(Id=ent.Entitled_Product__c);
                entEP.End_Date__c = ent.Startdate<system.Today()?system.Today()-1:system.Today();
                lstUpEP.add(entEP);

            }
            else if( ent.Support_level__c != mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_Entitlement__c || 
                    ent.EndDate != mapExistingSupportAccounts?.get(ent.Entitled_Product__r.Support_Account__c)?.Parent?.Partner_Support_End_Date__c){
                //End existing ent by change
                Entitlement endEnt = new Entitlement(Id=ent.Id);
                endEnt.EndDate =  ent.Startdate<system.Today()?system.Today()-1:system.Today() ;
                lstUpsertEnt.add(endEnt);
                System.debug(' //End existing ent by change' + endEnt);
            }
            
            
        }
        System.debug('setEndEnt' + setEndEnt);

        lstExistingEP = [Select Id,Account__c, Support_Account__c,Forecast_Product__c, Delivery_method__c from Entitled_Product__c where support_account__c not in : setEndEnt and support_account__c in : mapExistingSupportAccounts.keySet() and support_account__r.Parent.Partner_Support_Entitlement__c != 'No Support']; //<T11>
         
        for(Entitled_Product__c EP : lstExistingEP ){
            //Create new ent
            if(!setEntitledProductToRecalculate.contains(EP.Id)){
                Entitlement newEnt = new Entitlement();
                newEnt.Name = mapExistingSupportAccounts?.get(EP.Support_Account__c)?.Parent?.Partner_Support_Entitlement__c;
                newEnt.Support_Level__c = mapExistingSupportAccounts?.get(EP.Support_Account__c)?.Parent?.Partner_Support_Entitlement__c;
                newEnt.Entitled_Product__c = EP.Id;
                newEnt.AccountId = EP.Account__c;
                newEnt.StartDate = system.today();
                newEnt.EndDate = mapExistingSupportAccounts?.get(EP.Support_Account__c)?.Parent?.Partner_Support_End_Date__c;
                lstUpsertEnt.add(newEnt);
                System.debug('//Create new ent' + newEnt);
            }
            //Rollup Support Level on Entitled Products 
             setEntitledProductToRecalculate.add(EP.Id);
        }

        system.debug('lstUpsertEnt'+ lstUpsertEnt);
        system.debug('setEntitledProductToRecalculate'+ setEntitledProductToRecalculate);

        
        //Get Support Account RecordType
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id EngagementRecType = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('GCS Administration').getRecordTypeId();

        String GCSAdminQueueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and Name = :Label.GCSAdminQueue Limit 1].Id;

        Map<id,Account>  mapPartnerAccounts =new Map<id,Account>([Select id, Name,Partner_Support_Entitlement__c, Partner_Support_End_Date__c,billingcountry ,CurrencyIsoCode from account where Id in :setPartnerAccountIds and Id not in:hasSupportAccount and
        Partner_Support_Entitlement__c != null  and Partner_Support_Entitlement__c != 'No Support' and   Partner_Support_End_Date__c >= Today ]);


        //get primary contact for new support accounts
        for(Contact con : [Select id,Name,AccountId from Contact where  Partner_Role__c = 'Partner Portal Admin' and AccountId in (Select Id from Account where id in :mapPartnerAccounts.keyset())]){
            mapPartnerContact.put(con.AccountId,con.Id);
        }

        //Create new support account
        for(Account pa : mapPartnerAccounts.values()){
            Account newAccount = new Account();
            newAccount.RecordTypeId = SupportAccountRecType;
            newAccount.Support_Account_Type__c= 'Partner';
            newAccount.ParentId= pa.Id;
            newAccount.Name= pa.Name+' '+'Support Account';
            newAccount.billingcountry= pa.billingcountry;
            newAccount.CurrencyIsoCode = pa.CurrencyIsoCode;
            newAccount.Success_offering__c = pa.Partner_Support_Entitlement__c;
            newAccount.End_Date__c = pa.Partner_Support_End_Date__c;
            //---------------------------------------<T06>-------------------------------
            newAccount.Max_Number_of_Cases_Allowed__c = newAccount.Success_Offering__c == BASIC_SUCCESS ? '10' : '';
            //---------------------------------------</T06>------------------------------
            lstInsertSupportAccount.add(newAccount);

            Engagement__c newEngagement = new Engagement__c();
            newEngagement.Account__c = pa.id;
            newEngagement.Primary_Contact__c = mapPartnerContact?.get(pa.id);
            newEngagement.RecordtypeId =EngagementRecType ;
            newEngagement.Name = pa.Name +' '+'Engagement';
            newEngagement.OwnerId= GCSAdminQueueId;
            lstInsertEngagement.add(newEngagement);
        }


        system.debug('lstInsertEngagement'+ lstInsertEngagement);
        
        if(lstInsertEngagement!=null && lstInsertEngagement.size()>0){
            Database.SaveResult[] srList = Database.insert(lstInsertEngagement);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setNewEngagementIds.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('CreateSupportAccountBatchHandler-->CreateSupportAccounts-->insert of support account failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        //get newly created enagegment
        For(Engagement__c eng : [Select id,Account__c from Engagement__c where id in :setNewEngagementIds]){
            mapAccountEngagement.put(eng.Account__c, eng.id);
        }
        //Map Support account with nee enagement
        for( Account  acc :lstInsertSupportAccount){
            acc.Engagement__c = mapAccountEngagement?.get(acc.ParentId);
        }
        system.debug('lstInsertSupportAccount'+ lstInsertSupportAccount);


        system.debug('lstInsertSupportAccount  ->'+lstInsertSupportAccount);
        if(lstInsertSupportAccount!=null && lstInsertSupportAccount.size()>0){
            Database.SaveResult[] srList = Database.insert(lstInsertSupportAccount);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setNewSupportAccounts.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->insert of partner support account failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        

        //get all unentitled products // t08 //t09 active condition added; T10
        for(Technical_Product_Line__c tp :[select Id,Name,Delivery_method__c from Technical_Product_Line__c where status__c = 'Active'])
        {
            if(tp.Name!=null && tp.Delivery_method__c!=null)
            {
                if(tp.Delivery_method__c.contains(';'))
                {   
                    
                    List<String> lstDeliveryMethod = tp.delivery_method__c.split(';'); 
                    for (Integer i = (lstDeliveryMethod.size()-1) ; i>= 0 ; i--){    //T10 
                    if(lstDeliveryMethod[i].contains(Hosted_Single_Tenant)){
                        lstDeliveryMethod.remove(i);
                      }                                                                
                    } 
                    if(lstDeliveryMethod?.size()>0)
                    {
                        mapUntentitledProducts.put(tp.Name,lstDeliveryMethod);
                    }
                }else {
                    if(tp.Delivery_method__c != Hosted_Single_Tenant){           //T10
                        mapUntentitledProducts.put(tp.Name,new List<String>{tp.Delivery_method__c});
                    }
                }
            } 
        }

        //update new support account
        for( Account sa : [Select id,End_Date__c,Success_Offering__c,ParentId,Active__c, Parent.Partner_Support_End_Date__c,Parent.Partner_Support_Entitlement__c from Account where id in :setNewSupportAccounts]){
            
            //Add Support Contact
            if(mapPartnerContact.containsKey(sa.ParentId)){
                AccountContactRelation acr = new AccountContactRelation();
                acr.ContactId= mapPartnerContact?.get(sa.ParentId);
                acr.AccountId = sa.id;
                acr.Primary__c = true;
                acr.isActive = false; //<T04>
                acr.Access_Level__c = 'Read/Write';
                lstInsertSupportContacts.add(acr); 
            }

            //Add Support account on engagement
            if(mapAccountEngagement.containsKey(sa.ParentId)){
                Engagement__c updateEng = new Engagement__c(Id = mapAccountEngagement.get(sa.ParentId));
                updateEng.Support_Account__c = sa.Id;
                lstUpdateEngagements.add(updateEng);
            }
            
            //Add new Entitled Products of all variations
            for(string ForecastProduct : mapUntentitledProducts.keyset()){
                for(string Delivery : mapUntentitledProducts.get(ForecastProduct)){
                    Entitled_Product__c newEP = new Entitled_Product__c();
                    newEP.Account__c = sa?.ParentId;
                    newEP.Support_Account__c = sa.Id;
                    newEP.Name = ForecastProduct+'('+Delivery+')';
                    newEP.Forecast_Product__c=ForecastProduct;
                    newEP.Delivery_method__c = Delivery;
                    newEP.End_Date__c = sa.Parent.Partner_Support_End_Date__c;
                    newEP.Support_level__c = sa.Parent.Partner_Support_Entitlement__c;
                    lstInsertEntitledProduct.add(newEP);   
                }
            }

        }

        //KG Update the Engagements with newly created support account
        if(lstUpdateEngagements!=null && lstUpdateEngagements.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateEngagements);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->update of Support account failes', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        system.debug('lstInsertSupportContacts'+ lstInsertSupportContacts);
        if(lstInsertSupportContacts!= null && lstInsertSupportContacts.size()>0){
            Database.SaveResult[] srList = Database.Insert(lstInsertSupportContacts);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->insert of support account contact failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }


        system.debug('lstInsertEntitledProduct'+ lstInsertEntitledProduct);
        if(lstInsertEntitledProduct!= null && lstInsertEntitledProduct.size()>0){
            Database.SaveResult[] srList = Database.Insert(lstInsertEntitledProduct);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setNewEntitledProducts.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->insert of Entitled Products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        
        //create new temporary entitlement for newly created EPs
        System.debug('setNewEntitledProducts'+setNewEntitledProducts);

        for (Entitled_Product__c EP:  [Select id, name, Account__c, Support_Account__c, support_level__c, end_date__c from Entitled_Product__c where id in :setNewEntitledProducts]){
            Entitlement newEnt = new Entitlement();
            newEnt.Name = EP.Support_Level__c;
            newEnt.Support_Level__c = EP.Support_Level__c;
            newEnt.Entitled_Product__c = EP.Id;
            newEnt.AccountId = EP.Account__c;
            newEnt.StartDate = system.today();
            newEnt.EndDate =EP.end_date__c;
            lstUpsertEnt.add(newEnt);
        }
        System.debug('lstUpsertEnt'+lstUpsertEnt);
        if(lstUpsertEnt!=null && lstUpsertEnt.size()>0){
            Database.UpsertResult[] srList = Database.upsert(lstUpsertEnt);
            for (Database.UpsertResult sr : srList) {
                if (sr.iscreated()) {
                    setNewEtitlements.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->insert of f temporary entitlements failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        //Upate the EP end date when No Support
        Map<Id,Entitled_Product__c> mapUpdatesEP = new Map<Id,Entitled_Product__c>();   
        mapUpdatesEP.putall(lstUpEp);
        if(mapUpdatesEP.size()>0){
            Database.SaveResult[] srList = Database.update(mapUpdatesEP.values());            
        }

        //rollup support level on EP and Support Account
        for(Entitlement ent :[select id ,name,Support_Level__c,Enddate, Entitled_Product__c, Entitled_Product__r.Support_Account__c from Entitlement where id in :setNewEtitlements]){
            System.debug('New ent created'+ent);
            Entitled_Product__c updateEp = new Entitled_Product__c(id=ent.Entitled_Product__c);
            updateEp.Entitlement__c = ent.Id;
            updateEp.Support_Level__c  = ent.Support_Level__c;
            updateEp.End_Date__c  = ent.Enddate;
            lstUpdateEp.add(updateEp);
            System.debug('EP for New ent created'+updateEp);


            if( ent?.Entitled_Product__r?.Support_Account__c != null && !mapUpdateSupportAccount.containskey(ent.Entitled_Product__r.Support_Account__c)){
            Account updateSa = new Account(Id= ent.Entitled_Product__r.Support_Account__c );
            updateSa.Entitlement__c = ent.Id;
            updateSa.Success_Offering__c  = ent.Support_Level__c;
            updateSa.End_Date__c  = ent.Enddate;
            mapUpdateSupportAccount.put(ent.Entitled_Product__r.Support_Account__c,updateSa);
            }

        }

        System.debug('lstUpdateEp'+lstUpdateEp);
        if(lstUpdateEp!=null && lstUpdateEp.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateEp);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->update of EP failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }


        System.debug('mapUpdateSupportAccount'+mapUpdateSupportAccount.values());
        if(mapUpdateSupportAccount!=null && mapUpdateSupportAccount.values().size()>0){
            Database.SaveResult[] srList = Database.update(mapUpdateSupportAccount.values());
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('SupportAccountService-->upsertPartnerSupportAccounts-->update of Support Account failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        // Rollup EndDate on EP when No Support is set - KG    
        /*if(setEPToRecalculate?.size()>0){
            EntitledProductService.updateEntitledProducts(setEPToRecalculate);
        }*/

        /*

        //Rollup Support Level on Entitled Products 
        setEntitledProductToRecalculate.addall(setNewEntitledProducts);
        
        //Rollup Support Level on Entitled Products 
        if(setEntitledProductToRecalculate?.size()>0){
            EntitledProductService.updateEntitledProducts(setEntitledProductToRecalculate);
        }
        
        //Rollup Support Level on Account 
        setSupportAccountsToRecalculate.addall(mapExistingSupportAccounts.keyset());
        setSupportAccountsToRecalculate.addall(setNewSupportAccounts);


        //Rollup Support Level on Account in future call
        if(setSupportAccountsToRecalculate?.size()>0){

            if(!System.isFuture() && !system.isBatch() && !Test.IsRunningTest()){
                SupportAccountService.updateSupportAccountsFuture(setSupportAccountsToRecalculate);
            }
            else{
                SupportAccountService.updateSupportAccounts(setSupportAccountsToRecalculate);
            }
        }
        */
    }
    
//---------------------------------------------------------------------</T01>


// <T02> Update Support Accounts
    public static void updateSupportAccountBasicPack(List<Account> lstAccounts){

        GlobalApexManager GAM = new GlobalApexManager();

        map<Id, Account> mapAccounts = new map<Id,Account>(lstAccounts);
        map<Id, Asset> mapSABasicPack = new map<Id,Asset>();
        List<Account> lstUpdateSupportAcccount = new List<Account>();

        //check if the Support Account has active Basic Pack
        for (Asset a :[Select Id,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Support_Account__r.End_date__c from Asset where Support_Account__c in : mapAccounts.keySet() and Product2.Edition__c =: BASIC_PACK and SBQQ__SubscriptionEndDate__c> Today]){
            mapSABasicPack.put(a.Support_Account__c,a);
        }

        system.debug('mapSABasicPack'+mapSABasicPack);
        for(Account Sa : mapAccounts.values()){
            system.debug('Sa'+Sa);
            system.debug('StartDate'+sa.Entitlement__r.StartDate);
            system.debug('today'+System.today());

            Account updateSA = new Account(Id= sa.id );
            //check if it is multiyear deal 
            if(sa.Entitlement__c!= null && sa.Entitlement__r.StartDate.month() == System.today().month() &&  sa.Entitlement__r.StartDate.Day() == System.today().day() ){
                updateSA.Number_of_Cases_Created__c =0;
            }
            //check if basic pack is started today
            if(mapSABasicPack.containskey(sa.id) &&  mapSABasicPack.get(sa.id).SBQQ__SubscriptionStartDate__c == System.Today()){
                updateSA.Max_Number_of_Cases_Allowed__c = (sa.Max_Number_of_Cases_Allowed__c!= null && sa.Max_Number_of_Cases_Allowed__c.isNumeric()) ? (Integer.valueOf(sa.Max_Number_of_Cases_Allowed__c) +10+''):('10');
            }else if (mapSABasicPack.containskey(sa.id) &&  mapSABasicPack.get(sa.id).SBQQ__SubscriptionEndDate__c == System.Today()){
                updateSA.Max_Number_of_Cases_Allowed__c = ( sa.Max_Number_of_Cases_Allowed__c!= null && sa.Max_Number_of_Cases_Allowed__c.isNumeric() && (Integer.valueOf(sa.Max_Number_of_Cases_Allowed__c) >= 10) ) ? ((Integer.valueOf(sa.Max_Number_of_Cases_Allowed__c)-10)+'') : sa.Max_Number_of_Cases_Allowed__c;
            }

            lstUpdateSupportAcccount.add(updateSA);
            System.debug('updateSA'+updateSA);

        }


        //Update Support Account
        system.debug('lstUpdateSupportAcccount-->'+lstUpdateSupportAcccount);

        if(lstUpdateSupportAcccount!= null && lstUpdateSupportAcccount.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateSupportAcccount);
            for (Database.SaveResult sr : srList) {
               if (!sr.isSuccess()){
                   // Operation failed, so get all errors  
                   for(Database.Error err : sr.getErrors()) {          
                       GAM.CreateExceptionRecords('SupportAccountService-->updateSupportAccountBasicPack-->update of Support level on support account failed', err.getMessage(), sr.getId());
                   }
               }
            }   
        }
    }
//</T02>


}