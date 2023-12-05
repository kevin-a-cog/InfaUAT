/****************************************************************************************************************
Class:          FulfillmentData 
@Author:        vsabbell
@Created Date:  8/7/2019.
@Description:   Provides inner classes, Utility methods to retrive and update fulfillment data for orchestration with Shipping Application.
******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By            Description                                                 Tag
Ambica Pyati        11/20/2019      F2A               F2A-194 Map Ship via and Ship date to orderproduct            T01
Ramya Ravi          09/06/2020      F2A               F2A-237 Ability to track provisioning/shipping completed date T02
Vignesh D           08/06/2020      F2A-238           Added AuraMethods to provide data to the Fulfillment UI       T03
Vignesh D           08/26/2020      F2A-283           Fix for excluding duplicate order product records on update   T04
Vignesh D           09/30/2020      I2C-726           Added check to allow Fulfillment Line update                  T05
                                                      only for Shipping User            
Vignesh D           09/30/2020      F2A-265           Add comment on Fulfillment Line when user tries to update     T06
                                                      Ship Date for already provisioned product                 
Pavithra V          10/28/2020      F2A-257           Updated to accept earlier/any dates for the fulfillment date  T07
Pavithra V          11/19/2020      F2A-313           Modified to display the Educational fulfillment lines in the  T08
                                                      Fulfillment UI
Pavithra V          01/28/2021      F2A-344           To update the Org UUID to the related assets                  T09
Pavithra V          04/05/2021      F2A-364           Change the logic to update the Org UUID through 
                                                      an invokable method. Change the status to 'Invoking API'
                                                      on org provision                                              T10
Pavithra V          05/31/2021      F2A-382           Fulfillment Line level changes                                T11
Pavithra V          06/29/2021      F2A-402           Add Manual Fulfillment Lines                                  T12
Vignesh D           02/03/2023      F2A-493           Added Parent_ID__c & GTM_Model__c fields to the SOQL query    T13
Vignesh D           02/08/2023      F2A-519           Updated condition to allow ship date rollup from FL to order  T14
                                                      product for IPU child fulfillment lines
Vignesh D           02/14/2023      F2A-523           Added method to return the fulfillment line record            T15
Vignesh D           02/28/2023      F2A-476           Updated logic for IPU 1.0 metering                            T16
Vignesh D           06/23/2023      F2A-594           Added logic to process org contracts when the org is          T17
                                                      changed on the fulfillment line
**********************************************************************************************************************
*/
public with sharing class FulfillmentData {   
    public virtual class BaseException extends Exception {}
    public class FulfillmentLineException extends BaseException {}
    public class NoAccessException extends BaseException {}
    public FulfillmentData() {

    }

    public class FulfillmentLine { 

         @AuraEnabled public String id;
         @AuraEnabled public String screentype;
         @AuraEnabled public String shipdate;
         @AuraEnabled public String startdate;
         @AuraEnabled public String ffstatus;
         @AuraEnabled public String contact;
         @AuraEnabled public String phone;
         @AuraEnabled public String shipvia;
         @AuraEnabled public String TrackingNumber;
         @AuraEnabled public Decimal amount;
         @AuraEnabled public Sobject flobj;


         private List<Id> products;
         private List<Id> installBases;

         public FulfillmentLine(Fulfillment_Line__c fl){
              this.id  = String.valueOf(fl.Id);
              this.screentype         = String.valueOf(fl.name);
              this.shipdate           = String.valueOf(fl.Ship_Date__c);
              this.startdate          = String.valueOf(fl.Start_Date__c);
              this.ffstatus           = String.valueOf(fl.Ship_Status__c);
              this.contact            = 'me@example.com';
              this.phone              = '1234567890';
              this.shipvia            = String.valueOf(fl.Ship_via__c);
              this.TrackingNumber     = String.valueOf(fl.Tracking_Number__c);
              this.amount             = 100.00;
              products = new List<Id>();
              installBases = new List<Id>();
              this.flobj= (Sobject)fl;
         }

         /*Fulfillment_Line__c getFulfillmentLineSobj(){
             Fulfillment_Line__c ff = new Fulfillment_Line__c(
                 name = this.screentype,
                 Ship_Date__c = this.shipdate!=null?Date.valueOf(this.shipdate):null,
                 Start_Date__c = this.startdate!=null?Date.valueOf(this.startdate):null,
                 Ship_Status__c = this.ffstatus,
                 Ship_via__c = this.shipvia,
                 Tracking_Number__c= this.TrackingNumber
             );
             ff.Id = this.id;
             return ff;

         }*/

         public void addProduct(Id productId){
             products.add(productId);
         }

         public void addinstallBase(Id installBaseId){
             installBases.add(installBaseId);
         }

         /*public List<Id> getProducts(){
          return products;
         }*/
         
          public List<Id> getInstallBases(){
          return installBases;
         }
    }

    public class RelatedLine{
       @AuraEnabled public String productName;
       @AuraEnabled public String OrderProductId;
       @AuraEnabled public String orderProductNumber;
       @AuraEnabled public String id;
       @AuraEnabled public String parentid;

       public string productId;

       public RelatedLine(Related_Fulfillment_Line__c rflsobj){
       this.productName= rflsobj.Order_Product__r.Product2.Name;
       this.OrderProductId= rflsobj.Order_Product__c;
       this.orderProductNumber = rflsobj.Order_Product__r.OrderItemNumber;
       this.productId = rflsobj.Order_Product__r.Product2Id;
       this.id = rflsobj.Id;
       this.parentid = rflsobj.Fullfillment_Line__c;
       }
    }
    
    @AuraEnabled
    public static List<Fulfillment_Line__c> getFulfillmentLines(String fulfillmentId){
        fulfillmentId = String.escapeSingleQuotes(fulfillmentId); 
        List<Fulfillment_Line__c> fflines = [select id,name ,License_Screen_Type2__c, 
                                             Ship_Date__c,Start_Date__c,Ship_Status__c,Ship_via__c,Tracking_Number__c,Fullfillment__c,License_Serial_Number__c,
                                             (select id,name,
                                                  Fullfillment_Line__c, Order_Product__c,Quantity__c,
                                                  Order_Product__r.OrderItemNumber,Order_Product__r.Product2Id,Order_Product__r.Product2.Name,Order_Product__r.EndDate,Order_Product__r.ServiceDate
                                                  from Related_Fullfillment_Lines__r)
                                             from Fulfillment_Line__c
                                             where Fullfillment__c =:fulfillmentId];      
       return fflines;
        
    }

    public static  List<FulfillmentLine> getFulfillmentLinesDT(List<Fulfillment_Line__c> flSobjList){
      List<FulfillmentLine> ffLines = new List<FulfillmentLine>();
      for(Fulfillment_Line__c flsobj: flSobjList){
          FulfillmentLine flobj = new FulfillmentLine(flsobj);
          ffLines.add(flobj);
      }
      return ffLines;
    }
    public static  List<RelatedLine> getRelatedLinesDT(List<Fulfillment_Line__c> flSobjList){
      List<RelatedLine> rfLines = new List<RelatedLine>();

       for(Fulfillment_Line__c flSobj:flSobjList){
            
            for(Related_Fulfillment_Line__c rflsobj:flSobj.getSobjects('Related_Fullfillment_Lines__r') ){
                                                  RelatedLine rfl = new RelatedLine(rflsobj); 
                                                  rfLines.add(rfl);
                                              }
           }

        
       
        return rfLines;
    }
    
    //<T03>

    @AuraEnabled
    public static Map<String, Integer> getAllffLines(String fulfillmentHeaderId){
        Integer All=0;
        Integer Cloud=0;
        Integer Daas=0;
        Integer MDM=0;
        Integer EducationalServices =0;/**<T08>**/
        Map<String, Integer> flRecordsCount = new Map<String, Integer>();
        
        for(Fulfillment_Line__c fl: [Select License_Screen_Type2__c from Fulfillment_Line__c where Fullfillment__c =: fulfillmentHeaderId]){
            All = All + 1;
            if(fl.License_Screen_Type2__c == 'Cloud'){
                Cloud = Cloud + 1;
            }
            else if(fl.License_Screen_Type2__c == 'Daas' || fl.License_Screen_Type2__c == 'DaaS Cloud'){
                Daas = Daas + 1;
            }
            else if(fl.License_Screen_Type2__c == 'MDM'){
                MDM = MDM + 1;
            }
            /**<T08>**/
            else if(fl.License_Screen_Type2__c == 'Informatica University'){
                EducationalServices = EducationalServices + 1;
            }
            /**<T08>**/
            
        }
        if(All > 0){
            flRecordsCount.put('All', All);
        }
        if(All > (Cloud + Daas + MDM + EducationalServices)){ /**<T08>**/
            Integer OnPremise = All - (Cloud + Daas + MDM + EducationalServices);/**<T08>**/
            flRecordsCount.put('OnPremise',OnPremise);
        }
        if(Cloud > 0){
            flRecordsCount.put('Cloud', Cloud);
        }
        if(Daas > 0){
            flRecordsCount.put('Daas', Daas);
        }
        if(MDM > 0){
            flRecordsCount.put('MDM', MDM);
        }
        /**<T08>**/
        if(EducationalServices > 0){
            flRecordsCount.put('Educational Services', EducationalServices);
        }
        /**<T08>**/
        return flRecordsCount;
    }

    @AuraEnabled
    public static Map<String, List<String>> getFulfillmentLineFieldSet(String fieldSetName){
        /**<T08>**/
        if(fieldSetName =='Educational Services'){
            fieldSetName = 'Educational_Services';
        }
        /**<T08>**/
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Fulfillment_Line__c.fieldSets.getMap();

        List<String> allFieldSets = new List<String>();

        for(String fieldSet : FsMap.keyset()){
            allFieldSets.add(fieldSet);
        }
        
        String fieldSet;
        
        for(String str : allFieldSets){
            if(str.startsWithIgnoreCase(fieldSetName)){
                fieldSet = str;
            }
        }
        System.debug(fieldSet);

        Map<String, List<String>> fields = new Map<String, List<String>>();
        List<Schema.FieldSetMember> fflineFieldSet = Schema.SObjectType.Fulfillment_Line__c.fieldSets.getMap().get(fieldSet).getFields();

        for(Schema.FieldSetMember fsField : fflineFieldSet){
            String fieldAPIName = String.valueOf(fsField.getSObjectField());
            List<String> tempStr = new List<String>();
            tempStr.add(String.valueOf(fsField.getLabel()));
            tempStr.add(String.valueOf(fsField.getType()));
            tempStr.add(String.valueOf(fsField.getRequired()));
            fields.put(fieldAPIName, tempStr);
        }
        System.debug(fields);
        return fields;
    }


    @AuraEnabled
    public static List<Fulfillment_Line__c> getFulfillmentLinesLWC(List<String> lstString){
                
        String fulfillmentHeaderId = lstString.get(0);
        String fulfillmentSystem = lstString.get(1);

        String querystr= 'Select Id,License_Screen_Type2__c,License_Generation__c,Start_date__c,End_Date__c,Ship_Status__c,Ship_Date__c,Provisioning_Environment__c,Org_UUID__c,Tracking_Number__c,License_Serial_Number__c,Skip_Fulfillment__c,Training_Units__c,Key_Code__c,Org__c,Pod_Location__c,Edition__c,Fullfillment__c,Fullfillment__r.Ship_To_Contact__r.MailingCountry,Parent_ID__c,GTM_Model__c from Fulfillment_Line__c where Fullfillment__c = \''+fulfillmentHeaderId+'\''; //<T13>

        List<Fulfillment_Line__c> ffLines = new List<Fulfillment_Line__c>();
                if(fulfillmentSystem == 'Cloud' || fulfillmentSystem == 'MDM'){
                    querystr = querystr+'and License_Screen_Type2__c IN (\''+fulfillmentSystem+'\')';
                }
                else if(fulfillmentSystem == 'OnPremise'){
                    querystr = querystr+'and License_Screen_Type2__c NOT IN (\'Cloud\',\'Daas\',\'DaaS Cloud\',\'MDM\',\'Informatica University\')';
                }
                else if(fulfillmentSystem == 'Daas'){
                    querystr = querystr+'and License_Screen_Type2__c IN (\'Daas\',\'DaaS Cloud\')';
                }
                /**<T08>**/
                else if(fulfillmentSystem == 'Educational Services'){
                    querystr = querystr+'and License_Screen_Type2__c IN (\'Informatica University\')';
                }
                /**<T08>**/
            
        querystr = querystr+' order by License_Screen_Type2__c ASC';
        ffLines = Database.query(querystr);
        System.debug('querystr ==> '+querystr);
        System.debug('ffLines.size = '+ffLines.size());

        return ffLines;
    }
    
    @AuraEnabled
    public static List<Related_Fulfillment_Line__c> getAllRelatedFFLines(List<String> lstString){

        Map<Id, Fulfillment_Line__c> fflinesIdMap = new Map<Id, Fulfillment_Line__c>(getFulfillmentLinesLWC(lstString));
        Set<Id> SetfflineIds = fflinesIdMap.keyset();

        List<Related_Fulfillment_Line__c> relatedffline = [Select Id,Order_Product_Name__c,Order_Product__c,Order_Product__r.Product2Id,Order_Product__r.OrderItemNumber,Quantity__c from Related_Fulfillment_Line__c where Fullfillment_Line__c IN :SetfflineIds] ;

        Map<Id, Related_Fulfillment_Line__c> uniqueRelatedfflines = new Map<Id, Related_Fulfillment_Line__c>();

        for(Related_Fulfillment_Line__c rffline: relatedffline){
            if(!uniqueRelatedfflines.containsKey(rffline.Order_Product__c)){
                uniqueRelatedfflines.put(rffline.Order_Product__c, rffline);
            }
        }

        return uniqueRelatedfflines.values();

    }

    @AuraEnabled
    public static List<Related_Fulfillment_Line__c> getRelatedFulfillmentLines(String fulfillmentLineId){
        
        List<Related_Fulfillment_Line__c> relatedffline = [Select Id,Order_Product_Name__c,Order_Product__c,Order_Product__r.Product2Id,Order_Product__r.OrderItemNumber,Quantity__c from Related_Fulfillment_Line__c where Fullfillment_Line__c =: fulfillmentLineId];
        system.debug('fulfillmentLineId --> '+fulfillmentLineId);
        system.debug('relatedffline --> '+relatedffline);

        return relatedffline;
    }
    

    //<T03/>
    @AuraEnabled    
    public static List<Fulfillment_Line__c>  updateFulfillments(String fulfillmentLines){
        globalApexManager GAM = new globalApexManager();
        
        List<Fulfillment_Line__c> fflinesToUpdate = new List<Fulfillment_Line__c>();
        Set<Id> ffLineIdSet = new Set<Id>();   /**<T12>**/     
        //try{
             fflinesToUpdate = getfflinesToUpdate(fulfillmentLines); /**<T11>**/
        
           //<T05>
            if(ManageFulfillmentCtrl.checkUserPermission()){
                if(fflinesToUpdate.size() > 0 && fflinesToUpdate != null){
                    //upsert fflinesToUpdate; 
                    /**<T12>**/ 
                    List<Database.UpsertResult> srList = Database.upsert(fflinesToUpdate, false);
                    
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess() && sr.isCreated()) {
                            ffLineIdSet.add(sr.getId());
                            System.debug('Successfully inserted FFLine ID: ' + sr.getId());
                        }
                    }
                    
                    if(ffLineIdSet<> null && ffLineIdSet.size()>0){
                        createRelatedFFlineAsset(ffLineIdSet);/**<T12>**/ 
                    }
                    /**<T12>**/ 
                }
                    
                
            }
            else{
                Throw New NoAccessException('You do not have access to update. Only Shipping User can update Fulfillment Line.');
            }
           //</T05>
              
              
        /*}
        catch(Exception Ex){
            GAM.CreateExceptionRecords('FulfillmentData', 'Exception in FulfillmentData',ex.getMessage());
            String ErrorMessage='Error: '+ex.getMessage();
            Throw New FulfillmentLineException(ErrorMessage);

        }
        GAM.InsertDebugLogs();*/
        return fflinesToUpdate;
        
    }

    /**<T11>**/
    public static List<Fulfillment_Line__c> getfflinesToUpdate(String fulfillmentLines){

        String SKIP_FULFILLMENT = 'Skip_Fulfillment__c';
        String SHIP_STATUS = 'Ship_Status__c';
        String SHIP_DATE ='Ship_Date__c';/**<T07/>*/
        String PROVISIONING_COMPLETE = 'Provisioning Complete';
        String ORG_UUID = 'Org_UUID__c';/**<T09>**/

        List<Fulfillment_Line__c> ffSobjList;
        List<Fulfillment_Line__c> fflinesToUpdate = new List<Fulfillment_Line__c>();
        
        System.debug('fulfillmentLines > '+ fulfillmentLines);
        
        ffSobjList = (List<Fulfillment_Line__c>)JSON.deserialize(fulfillmentLines,  List<Fulfillment_Line__c>.class);
        
        System.debug('Before===>Fulfillment Lines to update : '+ffSobjList);
        
                if(ffSobjList.size() > 0){
                
                    Id fulfillmentId;/**<T12>**/ 
                    
                    if(ffSobjList[0].Fullfillment__c <> null){
                        fulfillmentId = ffSobjList[0].Fullfillment__c ;/**<T12>**/ 
                    }else{
                        Fulfillment_Line__c tempFFLine = [Select id,Fullfillment__c from Fulfillment_Line__c where Id =: ffSobjList[0].Id];
                        fulfillmentId = tempFFLine.Fullfillment__c ;
                    }
                    
                    Map<Id, Fulfillment_Line__c> ffLineOldMap= new Map<Id, Fulfillment_Line__c>([Select Id,Skip_Fulfillment__c,Org_UUID__c,Start_date__c,End_Date__c,Ship_Date__c,Ship_Status__c,Key_Code__c,Training_Units__c,Provisioning_Environment__c from Fulfillment_Line__c where Fullfillment__c =: fulfillmentId]);
                    
                    System.debug('ffLineOldMap ===> '+ffLineOldMap);

                    for(Fulfillment_Line__c fl : ffSobjList){
                        
                        Boolean isManualFFline = string.valueOf(fl.Id).startsWith('FFL');
                        
                        Fulfillment_Line__c ffline = fl;
                        String jsonSerializedStr = JSON.Serialize(fl);
                        Boolean skipProvisioning = false;
                        
                        System.debug('fulfillmentLineId ===>'+ffline.Id);
                        System.debug('jsonSerializedStr.Skipfulfillment ===> '+jsonSerializedStr.contains(SKIP_FULFILLMENT));                        
                        
                        if(jsonSerializedStr.contains(SKIP_FULFILLMENT)){
                        
                            if(ffline.Skip_Fulfillment__c == true && ((ffLineOldMap.get(ffline.Id) <> null && ffLineOldMap.get(ffline.Id).Skip_Fulfillment__c != true && !isManualFFline)|| (isManualFFline)) ){/**<T12>**/ 
                                
                                if(ffLineOldMap.get(ffline.Id) <> null){
                                     ffline.Ship_Date__c = ffLineOldMap.get(fl.Id).Start_date__c;
                                }else{
                                    ffline.Ship_Date__c = ffline.Start_date__c;
                                }
                                skipProvisioning = true;
                            }
                        }
                        System.debug('jsonSerializedStr.shipStatus ===> '+jsonSerializedStr.contains(SHIP_STATUS));
                        System.debug('isManualFFline ===> '+isManualFFline);
                        
                        if(jsonSerializedStr.contains(SHIP_STATUS)){
                            
                            if(ffline.Ship_Status__c == PROVISIONING_COMPLETE && !skipProvisioning && ((ffLineOldMap.get(ffline.Id) != null && ffLineOldMap.get(ffline.Id).Ship_Status__c != PROVISIONING_COMPLETE && !isManualFFline) || (isManualFFline)) ){/**<T12>**/ 
                                //System.debug('ffline.Ship_Date__c ===>' + ffline.Ship_Date__c + '  OldDate ===> '+ffLineOldMap.get(ffline.Id).Ship_Date__c );
                                /** <T07> */
                                /** Pavithra 28/10/2020 - Updated the code to accept earlier dates for the fulfillment date **/
                                /** Pavithra 29/10/2020 - If fulfillment date value is not entered , default to today's date*/
                                if(jsonSerializedStr.contains(SHIP_DATE)){
                                    if(ffline.Ship_Date__c == null ){
                                        ffline.Ship_Date__c = date.today(); 
                                    }
                                }else {
                                    if(ffLineOldMap.get(ffline.Id) <> null && ffLineOldMap.get(ffline.Id)?.Ship_Date__c != null && !isManualFFline){/**<T12>**/ 
                                        ffline.Ship_Date__c = ffLineOldMap.get(ffline.Id).Ship_Date__c;
                                    }else{
                                        ffline.Ship_Date__c = date.today();
                                    }
                                }
                                /** </T07> */
                            }
                            
                        }
                        
                        /**<T12> - Mark the ID as null for the manually added fflines **/
                        if(string.valueOf(fl.Id).startsWith('FFL')){
                            ffline.Id = null;
                        }

                        fflinesToUpdate.add(ffline);
                    }
                }              
        
            System.debug('After===>Fulfillment Lines to update size: '+fflinesToUpdate.size());
            
        return fflinesToUpdate;
    }
    /**<T11>**/

    
    /**<T10>**/
    @InvocableMethod(label='Update OrgUUID for Asset' description='Update OrgUUID')
    public static void updateOrgUUIDtoAssets(List<Id> fflineIdSet){
        
       globalApexManager GAM = new globalApexManager();
       
       Set<Id> OrderItemIdSet = new Set<Id>();
       Set<Id> setAssetIds = new Set<Id>(); //<T17>
       List<Asset> assetsToUpdate = new List<Asset>();
        
        
        for(Asset a: [Select id,SBQQ__OrderProduct__c,Org_UUID_Timestamp__c from Asset where SBQQ__OrderProduct__c IN (Select Order_Product__c from Related_Fulfillment_Line__c where Fullfillment_Line__c IN : fflineIdSet OR Fullfillment_Line__r.Parent_ID__c IN : fflineIdSet)]){ //<T17>
            a.Org_UUID_Timestamp__c = System.now();
            assetsToUpdate.add(a);
            setAssetIds.add(a.Id); //<T17>
        }
       System.debug('assetsToUpdate  => ' + assetsToUpdate); 
        
        //try{
        update assetsToUpdate;
        OrgContractService.createOrgContracts(setAssetIds); //<T17>
        /*}catch(Exception Ex){
            GAM.CreateExceptionRecords('FulfillmentData', 'Exception while updating Org UUID timestamp to assets',ex.getMessage());
            String ErrorMessage='Error: '+ex.getMessage();
            Throw New FulfillmentLineException(ErrorMessage);

        }
        GAM.InsertDebugLogs();*/
        
    }
    /**<T10>**/
    
    public static void updateOrderProductsToShipComplete(List<Id> fulfillmentLines){

        Set<String> orderStatus = new Set<String>(Label.F2AOrderActivatedStatus.split(';'));

        List<Fulfillment_Line__c> fflines = InvokableShipCompleteOrderProducts.getFulfillmentLines(fulfillmentLines);
        Set<String> setConsumptionModels = new Set<String>{System.Label.IPU_Product_GTM_Value, System.Label.IPU}; //<T16>

        Map<Id, OrderItem> orderProductsToUpdate = new Map<Id, OrderItem>();
        Map<Id, Fulfillment_Line__c> ffLinesToUpdate = new Map<Id, Fulfillment_Line__c>();

        for(Fulfillment_Line__c ffline: fflines){
            for(Related_Fulfillment_Line__c rffline: ffline.Related_Fullfillment_Lines__r){
                //<T06>
                if(!orderStatus.contains(rffline.Order_Product__r.Order.Status) && !rffline.Order_Product__r.Order.Revenue_Agreement_Processed__c && ((rffline.Order_Product__r.Ship_Date__c == null) || (rffline.Order_Product__r.Ship_Date__c != null && ffline.Ship_Date__c <= System.today())) && (rffline.Fullfillment_Line__r.Parent_ID__c == null || (rffline.Fullfillment_Line__r.Parent_ID__c != null && setConsumptionModels.contains(rffline.Fullfillment_Line__r.GTM_Model__c)))){/** <T07/> <T12> */ //<T14> //<T16>
                        OrderItem oitem = new OrderItem();
                        oitem.Id = rffline.Order_Product__c;
                        oitem.Ship_Date__c = ffline.Ship_Date__c;/** <T07/> */
                        oitem.Fulfillment_Method__c = ffline.Ship_via__c;

                        if(!orderProductsToUpdate.containsKey(oitem.Id)){
                            orderProductsToUpdate.put(oitem.Id, oitem);
                        }
                }
                else{     
                    Fulfillment_Line__c f = new Fulfillment_Line__c();
                    f.Id = rffline.Fullfillment_Line__c;
                    f.Comment__c = 'Fulfillment date ('+ffline.Ship_Date__c+') is not updated in the order because the product was already shipped. \nComment Updated on '+System.now();
                    ffLinesToUpdate.put(rffline.Fullfillment_Line__c, f);
                }
               //</T06>
            }
        }

        system.debug(LoggingLevel.ERROR, JSON.serialize(orderProductsToUpdate));
             
        if(orderProductsToUpdate != null && orderProductsToUpdate.size()>0){
            update orderProductsToUpdate.values();
        }
        //<T04/>
        
        //<T06>
        if(ffLinesToUpdate.values() != null && ffLinesToUpdate.values().size()>0){
            update ffLinesToUpdate.values();
        }
        //<T06>
    }
    
    /** <T10> **/ /** <T11> **/ 
    /** Save the changes and Update the Fulfillment status to 'Invoking API' to trigger the CAI call for org provisioning **/
    @AuraEnabled
    public static void updateProvisionOrg(String ffLineId, String fulfillmentLines){
        globalApexManager GAM = new globalApexManager();
        List<Fulfillment_Line__c> ffSobjList = (List<Fulfillment_Line__c>)JSON.deserialize(fulfillmentLines,  List<Fulfillment_Line__c>.class);
        List<Fulfillment_Line__c> fflinesToUpdate = new List<Fulfillment_Line__c>();
        Set<Id> ffLineIdSet = new Set<Id>();
        
        for(Fulfillment_Line__c ffl :ffSobjList){
            if(String.valueOf(ffl.Id) == ffLineId){
                //ffl.Id = null;
                fulfillmentLines = JSON.Serialize(new List<Fulfillment_Line__c>{ffl});
                break;
            }
        }
        
        if(ffSobjList.size() > 0){        
             fflinesToUpdate = getfflinesToUpdate(fulfillmentLines);   
             fflinesToUpdate[0].Ship_Status__c = 'Invoking API';
        }else{
            fflinesToUpdate = [Select Id,Ship_Status__c from Fulfillment_Line__c where Id =:ffLineId LIMIT 1];
            if(fflinesToUpdate != null && fflinesToUpdate.size()>0){
                fflinesToUpdate[0].Ship_Status__c = 'Invoking API';
            }           
        }

        //try{
            if(fflinesToUpdate != null && fflinesToUpdate.size() >0){
                List<Database.UpsertResult> srList = Database.upsert(fflinesToUpdate, false);/**<T12>**/ 
                    
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess() && sr.isCreated()) {
                            ffLineIdSet.add(sr.getId());
                            System.debug('Successfully inserted FFLine ID: ' + sr.getId());
                        }
                    }
                    
                    if(ffLineIdSet<> null && ffLineIdSet.size()>0){
                        createRelatedFFlineAsset(ffLineIdSet);/**<T12>**/ 
                    }
            }
            
       /* }catch(exception ex){
            
            GAM.CreateExceptionRecords('FulfillmentData', 'Exception while updating Org UUID timestamp to assets',ex.getMessage());
            String ErrorMessage='Error: '+ex.getMessage();
            Throw New FulfillmentLineException(ErrorMessage);
            
        }
        
        GAM.InsertDebugLogs();*/
    }
    /** <T11> **/ 

    /** <T12> **/ /** Create Related Fulfillment Line and Asset for Manual fulfillment Lines **/
    public static void createRelatedFFlineAsset(Set<Id> ffLineIdSet){
        
        List<Fulfillment_Line__c> fflinesUpsertedList = new List<Fulfillment_Line__c>();
        List<Related_Fulfillment_Line__c> rffList = new List<Related_Fulfillment_Line__c>();

        Set<Id> parentFFLineIdSet = new Set<Id>();
        Map<String,String> childParentMap = new Map<String,String>();
        Map<String,String> parentOrderItemMap = new Map<String,String>();
        
        Set<Id> rffLineIdSet = new Set<Id>();
        List<Asset> lstInsertClonedAssets = new List<Asset>();
        List<Entitlement> lstInsertClonedEntlments = new List<Entitlement>();
        
        fflinesUpsertedList = [SELECT Id, Parent_ID__c from Fulfillment_Line__c where Id in:ffLineIdSet];
                        if(fflinesUpsertedList <> null && fflinesUpsertedList.size() >0){
                            
                            for (Fulfillment_Line__c ffline : fflinesUpsertedList){
                                if(ffline.Parent_ID__c <> null){
                                   parentFFLineIdSet.add(ffline.Parent_ID__c); 
                                   childParentMap.put(ffline.Id, ffline.Parent_ID__c); 
                                }
                            }
                            if(parentFFLineIdSet <> null && parentFFLineIdSet.size()>0){
                                for(Related_Fulfillment_Line__c rffl : [Select Id, Order_Product__c,Fullfillment_Line__c from Related_Fulfillment_Line__c where Fullfillment_Line__c =:parentFFLineIdSet and Order_Product__r.SBQQ__RequiredBy__c = null]){
                                    parentOrderItemMap.put(rffl.Fullfillment_Line__c,rffl.Order_Product__c);
                                }  
                            }
                            Map<Id,OrderItem> orderItemDetailMap = new Map<Id,OrderItem>([Select Id,Quantity,Product2.Name from OrderItem where Id in:parentOrderItemMap.values()]);
                            
                            for(String fflineId : childParentMap.keySet()){
                                Related_Fulfillment_Line__c rffl = new Related_Fulfillment_Line__c();
                                rffl.Fullfillment_Line__c = fflineId;
                                rffl.Order_Product__c = parentOrderItemMap.get(childParentMap.get(fflineId));
                                rffl.Quantity__c = orderItemDetailMap.get(parentOrderItemMap.get(childParentMap.get(fflineId))).Quantity;
                                rffl.Order_Product_Name__c = orderItemDetailMap.get(parentOrderItemMap.get(childParentMap.get(fflineId))).Product2.Name;
                                rffList.add(rffl);
                                
                                /** If there are any existing assets , clone and create a shadow asset **/
                                for(Asset asset : [Select Id,Name,Quantity,InstallDate,SBQQ__QuoteLine__c,SBQQ__OrderProduct__c,Original_Order_Product__c,
                                                  SBQQ__CurrentSubscription__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Product2Id,AccountId,AssetServicedById,Status                                                  
                                                  from Asset where (Fulfillment_Id__c = '' or Fulfillment_Id__c = null)  and SBQQ__OrderProduct__c =: parentOrderItemMap.get(childParentMap.get(fflineId))]){
                                    
                                    Asset cloneasset = asset.clone();
                                    cloneasset.ParentId = asset.id;
                                    //cloneasset.SBQQ__CurrentSubscription__c = null;
                                    cloneasset.Fulfillment_Id__c = fflineId;
                                    lstInsertClonedAssets.add(CloneAsset);
                                }
                            }
    
                            if(rffList.size()>0 && rffList <> null){
                                insert rffList;
                            }
                            if(lstInsertClonedAssets<> null && lstInsertClonedAssets.size() >0){
                                
                                Set<Id> shadowAssetIdSet = new Set<Id>();
                                Map<String,String> shadowAssetParentAssetMap = new Map<String,String>();
                                Map<String,List<Entitlement>> AssetEntitlementMap = new Map<String,List<Entitlement>>();
                                List<AssetRelationship> lstInsertAssetRelationship = new List<AssetRelationship>();
                                
                                Database.SaveResult[] srList = Database.insert(lstInsertClonedAssets, false);
                                for (Database.SaveResult sr : srList) {
                                    if (sr.isSuccess()) {
                                        shadowAssetIdSet.add(sr.getId());
                                    }
                                }
                                
                                List<Asset> shadowAssetlist = [Select Id,Name,Quantity,Status,ParentId,SBQQ__SubscriptionEndDate__c from Asset where Id in:shadowAssetIdSet];
                                for(Asset a : shadowAssetlist){
                                    
                                    AssetRelationship ar = new AssetRelationship();
                                    ar.AssetId = a.Id;
                                    ar.FromDate= System.now();
                                    ar.ToDate= a.SBQQ__SubscriptionEndDate__c;
                                    ar.RelatedAssetId =a.ParentId;
                                    ar.RelationshipType ='Shadow';
                                    lstInsertAssetRelationship.add(ar);
                                    
                                    shadowAssetParentAssetMap.put(a.Id,a.ParentId);
                                }
                                
                                List<Entitlement> parentEntitlementList = [Select id, name, AccountId,StartDate,EndDate,Order_Product__c,Subscription__c,Assetid,SlaProcessId,Support_Level__c from Entitlement where AssetId in:shadowAssetParentAssetMap.values()];    
                                if(parentEntitlementList<> null && parentEntitlementList.size() >0){
                                    
                                    for(Entitlement en : parentEntitlementList){
                                        if(!AssetEntitlementMap.containsKey(en.AssetId)){
                                            AssetEntitlementMap.put(en.AssetId,new List<Entitlement>{en});
                                        }else{
                                            List<Entitlement> tempList = AssetEntitlementMap.get(en.AssetId);
                                            tempList.add(en);
                                            AssetEntitlementMap.put(en.AssetId,tempList);
                                        }
                                    }
                                }
                                
                                for(Asset a : shadowAssetlist){
                                    for(Entitlement ent : AssetEntitlementMap.get(shadowAssetParentAssetMap.get(a.Id))){
                                        Entitlement cloneEntitlement = ent.clone();
                                        //cloneEntitlement.Subscription__c = null;
                                        cloneEntitlement.AssetId = a.Id;
                                        lstInsertClonedEntlments.add(cloneEntitlement);
                                    }
                                }
                                
                                if(lstInsertClonedEntlments <> null && lstInsertClonedEntlments.size()>0){
                                    insert lstInsertClonedEntlments;
                                }
                                
                                if(lstInsertAssetRelationship <> null && lstInsertAssetRelationship.size()>0){
                                    insert lstInsertAssetRelationship;
                                }
                                
                            }
                            
                    }
    }
    /** <T12> **/
    
    
    /*** Update Podlocation on org change **/
    @AuraEnabled
    public static String getPodLocation(String orgId){ 
        String podLocation ='';
        Org__c org = [SELECT Id,Server_Information__c from Org__c where Id =: orgId LIMIT 1];
        if(org.Server_Information__c != null){
            podLocation = org.Server_Information__c;
        }
        return podLocation;        
    }
   /** <T10> **/

   /*
    Method Name : getEmailTemplate
    Description : This method returns the fulfillment line record.
    Parameters  : String, called from getFulfillmentLineDetails, strRecordId Record Id.
    Return Type : Fulfillment_Line__c
   */
    @AuraEnabled(cacheable = false) 
    public static Fulfillment_Line__c getFulfillmentLineDetails(String strRecordId) { //<T15>
        return [SELECT Id,Ship_Status__c FROM Fulfillment_Line__c WHERE Id = :strRecordId];
    }
}