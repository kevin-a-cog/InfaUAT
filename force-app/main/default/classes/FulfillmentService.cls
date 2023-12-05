/****************************************************************************************************************
Class:          FulfillmentService
@Author:        vsabbell
@Created Date:  8/7/2019.
@Description:   Provides Utility Methods and Mapping information for fulfillment header and lines.
******************************************************************************************************************
Change History
*******************************************************************************************************************
        ModifiedBy          Date        Requested By        Description                                         Tag
        Chandana Gowda     9/10/2019                        Returning the list of related ffline inserted       T01
                                                            instead of null 
        Ambica            11/20/2019        kka             F2A- 201 Add filter provisionable to true to create T02
                                                            fulfillment lines         

        Ambica            11/20/2019        F2A             F2A- 194 Remove the defaulting of ship via to ESD   T03
        Ramya Ravi        09/06/2020        F2A             F2A-237 Ability to track provisioning/shipping 
                                                            completed date                                      T04
                              
        Vignesh D         7/29/2020         F2A-240         Fulfillment creation for Cloud/Daas products        T05
        Vignesh D         7/29/2020         F2A-244         Skip Provisioning for MR only orders                T06
        Vignesh D         8/26/2020         F2A-241         Populate the Org from the existing asset into       T07
                                                            fulfillment line on renewal/amend
        Vignesh D         9/22/2020         F2A-265         Update Order Products only when Order is not        T08
                                                            'Bill & Contract' / 'Completed'
        Pavithra V        11/19/2020        F2A-313         To create the Fulfillment lines for Educational     T09
                                                            Services
        Pavithra V        11/19/2020        F2A-331         Modified condition to create fulfillment lines only T10
                                                            for the Provisionable products
        Pavithra V        12/31/2020        F2A-329         To update the Ship date on the order product to be  T11
                                                            in line with order generation date 
        Pavithra V        02/03/2020        F2A-327         To skip the fulfilment line creation for the        T12
                                                            perpetual lines
        Pavithra V        02/03/2020        F2A-364/F2A-354 Update the edition value for the fulfillment Line   T13
        Nishit S            02/10/2020      F2A-453         Manage Fulfillment Apex Class: FulfillmentService   <F2A-453> 
                                                            has hardcoded string for IPU Editions
        Narpavi Prabu      28-SEP-2022      F2A-471         Replace the provisionable formula field ('Provisionable__c) 
                                                            with new checkbox field in Product ('Provisionable_New__c')
        Vignesh D          2/2/2023         F2A-493         Refactored existing FL creation logic to accomodate T16
                                                            FL creation for Flex IPU products  
        Vignesh D          2/28/2023        F2A-552         Updated logic to add Product Id instead of order    T17
                                                            product Id
        Vignesh D          2/28/2023        F2A-476         Updated fulfillment logic for IPU 1.0 metering      T18
        Narpavi Prabu      2/20/2022        F2A-513         Populate Opportunity owner as Account Manager when the account
                                                            team member is not available in Opportunity          T19
        Vignesh D          5/08/2023        F2A-576         Populate org from wrapper to options		        T20
		Nishit S		   10/24/2022		F2A-664			Allow Fulfillment line creation for On-Premise		F2A-664
															SKUs for Renewal Orders
*************************************************************************************************************************/


public with sharing class FulfillmentService {
    
    private static final String PRODUCT_CATEGORY_ADDON = 'Add-ons';
    private static final String PRODUCTION = 'Production';
    private static final String SANDBOX = 'Sandbox';
    private static final String OPTIONS = 'Options';
    private static final String BASE = 'Base';
    private static final String DEVELOPMENT = 'Development';
    private static final String INCREMENTAL = 'Incremental';
    private static final String POC = 'POC';
    private static final String SHIP_VIA_ELECTRONIC = 'Electronic';
    private static final String PROVISIONING_ENV_INFORMATICA_HOSTED = 'Informatica Hosted';
    private static final String EDUCATIONAL_SERVICES='Educational Services';/** <T09>**/
    private static final String EDUCATION_SERVICES='Education Services';/** <T09>**/    
    private final static String OPTION_SCALE = 'Base Product'; //<T16>
    private final static Set<String> CONSUMPTION_MODEL = new Set<String>{System.Label.IPU_Product_GTM_Value, System.Label.IPU}; //<T16> //<T18>
    public static Map<Id,List<OrderItem>> parentChildOrderItemMap = new Map<Id,List<OrderItem>>();/** <T14>**/
    public static globalApexManager GAM = new globalApexManager();

    public static Fulfillment__c createFulfillment(Id orderId){
        Map<String, String> fulfillmentToOrderFieldMap = getFulfillmentHeaderMapping();
        Set<String> setOrderFields = new Set<String>{'ShippingStreet','ShippingCity','ShippingState','ShippingCountry','ShippingPostalCode','SBQQ__Quote__c','OrderNumber','SBQQ__Quote__r.SBQQ__Opportunity2__r.ownerID'};
        setOrderFields.addAll(fulfillmentToOrderFieldMap.values());
        Order objOrder = getOrder(orderId, new List<String>(setOrderFields));
        Fulfillment__c objFulfillment = new Fulfillment__c();

        for(String strFulfillmentField : fulfillmentToOrderFieldMap.keySet()){
            String strOrderField = fulfillmentToOrderFieldMap.get(strFulfillmentField);
            objFulfillment.put(strFulfillmentField, objOrder.get(strOrderField));
        }
        objFulfillment.Ship_To_Address__c = String.escapeSingleQuotes(objOrder.ShippingStreet +' '+objOrder.ShippingCity  +' '+objOrder.ShippingState+' '+ objOrder.ShippingCountry +' '+objOrder.ShippingPostalCode).replace('\n', ' ').replace('\r',' ');
        objFulfillment.Fullfillment_Name__c = String.escapeSingleQuotes('Fulfillment for Order# '+objOrder.OrderNumber);
        //<T19>
        //objFulfillment.Account_Manager__c = [SELECT UserId FROM OpportunityTeamMember WHERE OpportunityId IN (SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :objOrder.SBQQ__Quote__c ) AND TeamMemberRole ='Account Manager' LIMIT 1]?.UserId;
        List<OpportunityTeamMember> opptyteam=new List<OpportunityTeamMember>([SELECT UserId FROM OpportunityTeamMember WHERE OpportunityId IN (SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :objOrder.SBQQ__Quote__c ) AND TeamMemberRole ='Account Manager' LIMIT 1]);
        If(!opptyteam.isEmpty())
        {
            objFulfillment.Account_Manager__c=opptyteam[0].UserId;
        }
        else{
            objFulfillment.Account_Manager__c =objOrder.SBQQ__Quote__r.SBQQ__Opportunity2__r.ownerID;
        }
       //</T19>
        insert objFulfillment;

        return objFulfillment;
    }
  
     public static Order getOrder(Id OrderId, List<String> fields){  
         
        String fieldStr = String.join(fields,',');
        String queryStr = 'Select '+fieldStr+' From Order where Id='+'\''+OrderId+'\'';
        Order Order = (Order)Database.query(queryStr);
        return Order;        
     }
  
    // Map fields from Order to Fulfillment Header.
    static Map<String,String> getFulfillmentHeaderMapping(){
        Map<String,String> fulfillmentHederMap = new  Map<String,String>{
            'Shipping_Preference__c'=>'Shipping_Preference__c',
            'ShipToAccount__c'=>'ShipToAccount__c',
            'Ship_To_Contact__c'=>'ShipToContactId', 
            'Order__c'=>'Id',
            'Order_Start_Date__c'=>'EffectiveDate',
            'Sold_To_Account__c'=>'SoldToAccount__c',
            'Sold_To_Contact__c'=>'SoldToContact__c',
            'Bill_To_Account__c'=>'BilltoAccount__c',
            'Bill_To_Contact__c'=>'BillToContactId',
            'Legal_Entity__c'=>'Legal_Entity__c',  
            'Ship_To_Email__c'=>'Shipping_Email__c'     
        };
        return fulfillmentHederMap;
    }
    

    public static Map<Id, Fulfillment_Line__c> createFulfillmentLines(Id orderId, List<OrderItem> lstOrderProducts, Fulfillment__c objFulfillment){ //<T16>
        Map<Id, Asset> relatedAssets = getRelatedAssets(lstOrderProducts);
        Set<String> setPerpetualOfferingTypes = new Set<String>{'On-Premise Perpetual License'}; //<F2A-664> Removed On-Premise One Time Term License
        Set<String> setLicenseGeneration = new Set<String>{PRODUCTION, SANDBOX, BASE, DEVELOPMENT, POC, EDUCATIONAL_SERVICES};
        Map<Id, Fulfillment_Line__c> orderProductToFulfillmentLineMap = new Map<Id, Fulfillment_Line__c>();
        List<Fulfillment_Line__c> lstFulfillmentLinesToUpdate = new List<Fulfillment_Line__c>();
        Map<Id, Id> wrapperToAddonMap = new Map<Id, Id>();
        Set<Id> setParentIds = new Set<Id>();

        for(OrderItem objOrderProduct : lstOrderProducts){
            if(setPerpetualOfferingTypes.contains(objOrderProduct.Product2.Offering_Type__c) && objOrderProduct.SBQQ__QuoteLine__r.Transaction_Type__c == 'Renewal'){
                continue;
            }
            else if(CONSUMPTION_MODEL.contains(objOrderProduct.Product2?.GTM_Model__c) && objOrderProduct.Product2.Option_Scale__c == OPTION_SCALE && objOrderProduct.Product_Category__c == 'Wrapper' && objOrderProduct.Quantity >= 1 && objOrderProduct.Product2.Provisionable_New__c){ //<T18>
                orderProductToFulfillmentLineMap.put(objOrderProduct.Id, addFulfillmentLine(objOrderProduct, objFulfillment.Id, relatedAssets));
            }
            else if(CONSUMPTION_MODEL.contains(objOrderProduct.Product2?.GTM_Model__c) && objOrderProduct.Product2.Option_Scale__c == OPTION_SCALE && objOrderProduct.Product_Category__c == 'Add-ons' && objOrderProduct.Quantity >= 1 && objOrderProduct.Product2.Provisionable_New__c){ //<T18>
                if(!wrapperToAddonMap.containsKey(objOrderProduct?.SBQQ__RequiredBy__c) && objOrderProduct?.SBQQ__RequiredBy__c != null){
                    orderProductToFulfillmentLineMap.put(objOrderProduct.Id, addFulfillmentLine(objOrderProduct, objFulfillment.Id, relatedAssets));
                    wrapperToAddonMap.put(objOrderProduct.SBQQ__RequiredBy__c, objOrderProduct.Id);
                }
                //We create FL for add-ons from the upgraded subscription bundle
                if(objOrderProduct.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__c != null && !setParentIds.contains(objOrderProduct.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__c)){
                    orderProductToFulfillmentLineMap.put(objOrderProduct.Id, addFulfillmentLine(objOrderProduct, objFulfillment.Id, relatedAssets));
                    setParentIds.add(objOrderProduct.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                }
            }
            else if(objOrderProduct.Product2.License_Screen_Type__c != null && objOrderProduct.Product2.License_Generation__c != null && objOrderProduct.Quantity >= 1 && objOrderProduct.TotalPrice >= 0 && objOrderProduct.Product2.Provisionable_New__c){
                
                if(setLicenseGeneration.contains(objOrderProduct.Product2.License_Generation__c)){
                    orderProductToFulfillmentLineMap.put(objOrderProduct.Id, addFulfillmentLine(objOrderProduct, objFulfillment.Id, relatedAssets));
                }
                else if(objOrderProduct.Product2.License_Generation__c == OPTIONS){
                    if(objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c != PRODUCTION && objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c != SANDBOX){
                        orderProductToFulfillmentLineMap.put(objOrderProduct.Id, addFulfillmentLine(objOrderProduct, objFulfillment.Id, relatedAssets));
                    }
                }
                else if(objOrderProduct.Product2.License_Generation__c == INCREMENTAL){
                    if(objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c != BASE && objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c != DEVELOPMENT){
                        orderProductToFulfillmentLineMap.put(objOrderProduct.Id, addFulfillmentLine(objOrderProduct, objFulfillment.Id, relatedAssets));
                    }
                }
            }
        }

        if(!orderProductToFulfillmentLineMap.isEmpty()){
            insert orderProductToFulfillmentLineMap.values();
        }
        
        for(Id wrapperOrderProductId : wrapperToAddonMap.keySet()){
            Fulfillment_Line__c objWrapperFulfillmentLine = orderProductToFulfillmentLineMap.get(wrapperOrderProductId); //<T20>
            Fulfillment_Line__c objFulfillmentLine = orderProductToFulfillmentLineMap.get(wrapperToAddonMap.get(wrapperOrderProductId)); //<T20>
            objFulfillmentLine.Parent_ID__c = objWrapperFulfillmentLine.Id;//<T20>
            if(objFulfillmentLine.Org__c == null && objWrapperFulfillmentLine.Org__c != null){ //<T20>
                objFulfillmentLine.Org__c = objWrapperFulfillmentLine.Org__c;
                objFulfillmentLine.Org_UUID__c = objWrapperFulfillmentLine.Org_UUID__c;
                objFulfillmentLine.Pod_Location__c = objWrapperFulfillmentLine.Pod_Location__c;
            }
            lstFulfillmentLinesToUpdate.add(objFulfillmentLine);
        }

        if(!lstFulfillmentLinesToUpdate.isEmpty()){
            update lstFulfillmentLinesToUpdate;
        }

        return orderProductToFulfillmentLineMap;
    }
  
     //---------------------------------------------------<T05>
     public static Fulfillment_Line__c addFulfillmentLine(OrderItem oItem, Id ffHeaderId,Map<Id, Asset> relatedAssets){
       String Ship_Via = 'Electronic';
       String Prov_Environment = 'Informatica Hosted';
       String CSOD = 'CSOD'; /** <T09>**/
       Set<String> fuflfillmentCategory = new Set<String>{'Production' ,'Options', 'Sandbox'};
       
        Fulfillment_Line__c fulfillmentLine = new Fulfillment_Line__c(Fullfillment__c = ffHeaderId ,
                                                                      Name = oItem.Product2.License_Screen_Type__c, 
                                                                      License_Screen_Type2__c =oItem.Product2.License_Screen_Type__c,
                                                                      License_Generation__c=oItem.Product2.License_Generation__c,
                                                                      Start_date__c=oItem.ServiceDate,
                                                                      End_Date__c=oItem.EndDate,
                                                                      Ship_via__c = Ship_Via,
                                                                      Provisioning_Environment__c = Prov_Environment
                                                                    );
        //<T07>
        if(fuflfillmentCategory.contains(oItem.Product2.License_Generation__c) || CONSUMPTION_MODEL.contains(oItem.Product2?.GTM_Model__c)){ //<T16> //<T18>

            if(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null && oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c == null && relatedAssets.containsKey(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                if(relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c) != null){
                    fulfillmentLine.Org__c = relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).Org__c != null ? relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).Org__c : null;
                    fulfillmentLine.Org_UUID__c = relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).Org__r.OrgID__c != null ? relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).Org__r.OrgID__c : null;
                    fulfillmentLine.Pod_Location__c = relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).Org__r.Server_Information__c != null ? relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).Org__r.Server_Information__c : null;/**<T13>**/

                }
            }
            else if(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null && oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null && relatedAssets.containsKey(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c)){
                if(relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c) != null){
                    fulfillmentLine.Org__c = relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c).Org__c != null ? relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c).Org__c : null;
                    fulfillmentLine.Org_UUID__c = relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c).Org__r.OrgID__c != null ? relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c).Org__r.OrgID__c : null;
                    fulfillmentLine.Pod_Location__c = relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c).Org__r.Server_Information__c != null ? relatedAssets.get(oItem.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c).Org__r.Server_Information__c : null;/**<T13>**/
                }
            }
        }
        
        fulfillmentLine.GTM_Model__c = oItem?.Product2?.GTM_Model__c; //<T16>

        //<T07/>
         /** <T09>**/
             if(oItem.Product2.License_Generation__c == EDUCATIONAL_SERVICES){
                 /**<T14>**/
                 if(parentChildOrderItemMap.get(oItem.Id) <> null && parentChildOrderItemMap.get(oItem.Id).size() >0){
                     Double childQuanity = 0.0;
                     for(OrderItem item : parentChildOrderItemMap.get(oItem.Id)){
                          childQuanity = item.Quantity;
                     }
                     fulfillmentLine.Training_Units__c = childQuanity;
                 }else{
                     fulfillmentLine.Training_Units__c = oItem.Quantity;
                 }
                /**<T14>**/
             
             fulfillmentLine.Provisioning_Environment__c = CSOD;
             
             /** Generate the Training Unit Code for ES Lines**/
             String KeyCode ='';
             KeyCode+= 'C';
             if(oItem.Product2.Pricing_Business_Model__c == 'Subscription'){
                 KeyCode += 'SB';
             }else if(oItem.Product2.Pricing_Business_Model__c == 'Fixed Term'){
                 KeyCode += 'TU';
             }
             
            KeyCode+= oItem.OrderItemNumber;
             
            fulfillmentLine.Key_Code__c = KeyCode;
             
         }
         /** <T09>**/
        return fulfillmentLine;
   }
   //<T05/>
   
   //<T07>
    public static Map<Id, Asset> getRelatedAssets(List<OrderItem> orderProducts){
        Set<Id> currentSubscriptionIds = new Set<Id>();
        Map<Id, Asset> relatedAssets = new Map<Id, Asset>();

        for(OrderItem op : orderProducts){
            if(op.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null && op.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c == null){
                currentSubscriptionIds.add(op.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
            }
            else if(op.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null && op.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null){
                currentSubscriptionIds.add(op.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c);
            }
            /** T14 **/
            if(op.SBQQ__RequiredBy__c <> null){
                if(parentChildOrderItemMap.containsKey(op.SBQQ__RequiredBy__c)){
                    List<OrderItem> tempList = parentChildOrderItemMap.get(op.SBQQ__RequiredBy__c);
                    tempList.add(op);
                    parentChildOrderItemMap.put(op.SBQQ__RequiredBy__c,tempList);
                }else{
                    parentChildOrderItemMap.put(op.SBQQ__RequiredBy__c,new List<OrderItem>{op});
                }
            }
            /** T14 **/
        }

        for(Asset a : [Select Id,SBQQ__CurrentSubscription__c,Org__c,Org__r.OrgID__c,Org__r.Server_Information__c from Asset where SBQQ__CurrentSubscription__c IN :currentSubscriptionIds and Org__c != null]){
            if(a.SBQQ__CurrentSubscription__c != null){
                if(!relatedAssets.containsKey(a.SBQQ__CurrentSubscription__c)){
                    relatedAssets.put(a.SBQQ__CurrentSubscription__c, a);
                }
            }
        }
        return relatedAssets;
    }
   //<T07/>    

    public static List<Related_Fulfillment_Line__c> createRelatedFulfillmentLines(Id orderId, List<OrderItem> lstOrderProducts, Map<Id, List<OrderItem>> orderProductParentToChildMap, Id fulfillmentId, Map<Id,Fulfillment_Line__c> orderProductToFulfillmentLineMap){ //<T16>
        Set<Id> setOrderProductIds = new Set<Id>(); 
        List<String> lstProductsOrdered = new List<String>{' '};
        List<Related_Fulfillment_Line__c> lstRelatedFulfillmentLines = new List<Related_Fulfillment_Line__c>();
        Set<String> setPerpetualOfferingTypes = new Set<String>{'On-Premise Perpetual License'}; //<F2A-664> Removed On-Premise One Time Term License
        Map<Id, Id> wrapperToAddonMap = new Map<Id, Id>();

        for(OrderItem objOrderProduct : lstOrderProducts){
            setOrderProductIds.add(objOrderProduct.Product2.Id); //<T17>
            if(setPerpetualOfferingTypes.contains(objOrderProduct.Product2.Offering_Type__c) && objOrderProduct.SBQQ__QuoteLine__r.Transaction_Type__c == 'Renewal'){
                continue;
            }
            else if(CONSUMPTION_MODEL.contains(objOrderProduct.Product2?.GTM_Model__c) && objOrderProduct.Product2.Option_Scale__c == OPTION_SCALE && objOrderProduct.Product_Category__c == 'Wrapper' && objOrderProduct.Quantity >= 1 && objOrderProduct.Product2.Provisionable_New__c){ //<T18>
               lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
               lstProductsOrdered.add(objOrderProduct.Product2.Name); 
            }
            else if(CONSUMPTION_MODEL.contains(objOrderProduct.Product2?.GTM_Model__c) && objOrderProduct.Product2.Option_Scale__c == OPTION_SCALE && objOrderProduct.Product_Category__c == 'Add-ons' && objOrderProduct.Quantity >= 1 && objOrderProduct.Product2.Provisionable_New__c){ //<T18>
               if(wrapperToAddonMap.containsKey(objOrderProduct?.SBQQ__RequiredBy__c) && objOrderProduct?.SBQQ__RequiredBy__c != null){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(wrapperToAddonMap.get(objOrderProduct.SBQQ__RequiredBy__c)).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
               }
               else if(objOrderProduct?.SBQQ__RequiredBy__c != null){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    wrapperToAddonMap.put(objOrderProduct.SBQQ__RequiredBy__c, objOrderProduct.Id);
                }
                //we create RFL for the amended add-ons
                if(objOrderProduct?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__c != null && wrapperToAddonMap.containsKey(objOrderProduct?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__c)){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(wrapperToAddonMap.get(objOrderProduct.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                }
                else if(objOrderProduct?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__c != null && !wrapperToAddonMap.containsKey(objOrderProduct?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__c)){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    wrapperToAddonMap.put(objOrderProduct.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c, objOrderProduct.Id);
                }
                lstProductsOrdered.add(objOrderProduct.Product2.Name); 
            }
            else if(objOrderProduct.Product2.License_Screen_Type__c != null && objOrderProduct.Product2.License_Generation__c != null && objOrderProduct.Quantity >= 1 && objOrderProduct.TotalPrice >= 0 && objOrderProduct.Product2.Provisionable_New__c){
                if(objOrderProduct.Product2.License_Generation__c == PRODUCTION || objOrderProduct.Product2.License_Generation__c == BASE || objOrderProduct.Product2.License_Generation__c == POC){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    lstProductsOrdered.add(objOrderProduct.Product2.Name);
                }
                else if(objOrderProduct.Product2.License_Generation__c == SANDBOX || objOrderProduct.Product2.License_Generation__c == DEVELOPMENT){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    lstProductsOrdered.add(objOrderProduct.Product2.Name);

                    if(objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c == PRODUCTION || objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c == BASE){
                        List<OrderItem> lstChildOrderProducts = orderProductParentToChildMap.containsKey(objOrderProduct.SBQQ__RequiredBy__c) ? orderProductParentToChildMap.get(objOrderProduct.SBQQ__RequiredBy__c) : new List<OrderItem>();
                        
                        for(OrderItem objChildOrderProduct : lstChildOrderProducts){
                            if(objChildOrderProduct.Product2.License_Generation__c == OPTIONS || objChildOrderProduct.Product2.License_Generation__c == INCREMENTAL){
                                lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objChildOrderProduct.Id, Integer.valueOf(objChildOrderProduct.Quantity), objChildOrderProduct.Product2.Name));
                                lstProductsOrdered.add(objChildOrderProduct.Product2.Name);
                            }
                        }
                    }
                }
                else if(objOrderProduct.Product2.License_Generation__c == OPTIONS || objOrderProduct.Product2.License_Generation__c == INCREMENTAL){
                    if(objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c == PRODUCTION || objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c == SANDBOX || objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c == BASE || objOrderProduct.SBQQ__RequiredBy__r.Product2.License_Generation__c == DEVELOPMENT){
                        lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.SBQQ__RequiredBy__c).Id, objOrderProduct.Id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    }
                    else{
                        lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.Id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    }
                    lstProductsOrdered.add(objOrderProduct.Product2.Name);
                }
                else if(objOrderProduct.Product2.License_Generation__c == EDUCATIONAL_SERVICES){
                    lstRelatedFulfillmentLines.add(addRelatedFulfillmentLine(orderProductToFulfillmentLineMap.get(objOrderProduct.Id).Id, objOrderProduct.Id, Integer.valueOf(objOrderProduct.Quantity), objOrderProduct.Product2.Name));
                    lstProductsOrdered.add(objOrderProduct.Product2.Name);
                }
            }
        }

        Fulfillment__c objFulfillment = new Fulfillment__c(Id = fulfillmentId);
        objFulfillment.Products_Ordered__c = String.join(lstProductsOrdered, '\n            ');
        objFulfillment.Provision_External_System__c = updateFulfillmentHeader(setOrderProductIds);

        update objFulfillment;
        insert lstRelatedFulfillmentLines;    

        return lstRelatedFulfillmentLines;
    }
  
    /** <T13> **/
    public static void updateEditionInffline(List<Related_Fulfillment_Line__c> relatedFulfilLinesList){
        
            List<Related_Fulfillment_Line__c> relatedfflineList = [Select Id,Name,Fullfillment_Line__c,Order_Product__r.Product2.Edition__c,
                                                                   Order_Product__r.Product2.Product_Family__c 
                                                                   from Related_Fulfillment_Line__c 
                                                                   where Id in:relatedFulfilLinesList];
        
            Map<Id, List<Related_Fulfillment_Line__c>> ffLineRffLineMap = new Map<Id,List<Related_Fulfillment_Line__c>>();
            List<Fulfillment_Line__c> ffLineUpdateList = new List<Fulfillment_Line__c>();
             
             for(Related_Fulfillment_Line__c  rffl : relatedfflineList){
                 if(ffLineRffLineMap.containsKey(rffl.Fullfillment_Line__c)){
                     List<Related_Fulfillment_Line__c> tempList = ffLineRffLineMap.get(rffl.Fullfillment_Line__c);
                     tempList.add(rffl);
                     ffLineRffLineMap.put(rffl.Fullfillment_Line__c,tempList);
                 }else{
                     ffLineRffLineMap.put(rffl.Fullfillment_Line__c,new List<Related_Fulfillment_Line__c>{rffl});
                 }
             }
        /** F2A-354 : If the fulfillment line is from atleast one order product with the product's edition as "Informatica Processing Unit"
        or if one of the product's product family is "IPU", use the edition "Intelligent Cloud Data Management" else, use the edition "Integration Base" **/
        
             for(Id ffLineId : ffLineRffLineMap.keySet()){                 
                 Fulfillment_Line__c ffl = new Fulfillment_Line__c(Id=ffLineId,Edition__c='Integration Base'); 
                 
                 for(Related_Fulfillment_Line__c rffl :ffLineRffLineMap.get(ffLineId)){
                     //<F2A-453>
                     if(rffl.Order_Product__r.Product2.Edition__c != NULL){ 
                         ffl.Edition__c = rffl.Order_Product__r.Product2.Edition__c; // First non-blank order product's edition assigned into the fulfillment line's edition                      
                         break;
                     }
                     //</F2A-453>
                 }
                 ffLineUpdateList.add(ffl);
             }
             
             if(ffLineUpdateList.size()>0){
                 update ffLineUpdateList;
             }        
    }
    /** <T13> **/
  
    //---------------------------------------------------<T05>
    public static Related_Fulfillment_Line__c addRelatedFulfillmentLine(Id fulfillLine, Id orderProduct, Integer qty, String productName){
        Related_Fulfillment_Line__c  relatedfulfilmentLine = new Related_Fulfillment_Line__c(Fullfillment_Line__c = fulfillLine ,
                                                                                                        Order_Product__c = orderProduct  ,
                                                                                                        Quantity__c = qty,
                                                                                                        Order_Product_Name__c = productName
                                                                                                        );
        return relatedfulfilmentLine;
    }
     //<T05/>
     
     //<---------------------------------------------------T06>
     public static boolean checkMRSkipProvisioning(Id OrderId){
          Order order = [Select Id, OpportunityId, Opportunity.SBQQ__RenewedContract__c from Order where Id =: OrderId];
          List<OrderItem> orderProducts = [Select Id,Product2.Offering_Type__c,Ship_Date__c,Order.Generate_Date__c,ServiceDate,Product2.Provisionable_New__c,SBQQ__QuoteLine__c,TotalPrice,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c from OrderItem where OrderId =: OrderId 
                                           and Product2.Offering_Type__c NOT IN ('Maintenance') and Product2.Provisionable_New__c = true];/**<T11>**/
          List<OrderItem> ordersProductsToUpdate = new List<OrderItem>();
          Boolean Is_MR_Only_Order;
          
          if(order.Opportunity.SBQQ__RenewedContract__c != null){
          
            Is_MR_Only_Order = true;
        
              for(OrderItem oItem : orderProducts){
                  if( oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null &&
                  ((oItem.Product2.Offering_Type__c != 'On-Premise One Time Term License' && oItem.Product2.Offering_Type__c != 'On-Premise Perpetual License') || 
                      ((oItem.Product2.Offering_Type__c == 'On-Premise One Time Term License' || oItem.Product2.Offering_Type__c == 'On-Premise Perpetual License') && oItem.TotalPrice != 0))){
                  
                      Is_MR_Only_Order = false;
                  }
                  else if(oItem.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null && oItem.Product2.Offering_Type__c  != null){ 
                      Is_MR_Only_Order = false;
                  }
              }
  
          }
          else if(order.Opportunity.SBQQ__RenewedContract__c == null){
              
              Is_MR_Only_Order = false;
          
          }
        if(Is_MR_Only_Order){
            for(OrderItem oItem : orderProducts){
                if(oItem.Product2.Provisionable_New__c && oItem.Ship_Date__c == null){
                    ordersProductsToUpdate.add (new OrderItem (Id= oItem.id, Ship_Date__c = oItem.Order.Generate_Date__c)); /**<T11>**/
                }
            }
        }

        if(ordersProductsToUpdate.size() > 0 && ordersProductsToUpdate != null){
            try{
                Database.update(ordersProductsToUpdate, false);
            } catch(Exception e){
                GAM.CreateLogs('FulfillmentService.checkMRSkipProvisioning() -> ' + e.getCause(), ordersProductsToUpdate, 'ordersProductsToUpdate');
            }
        }
        
        GAM.InsertDebugLogs();
      return Is_MR_Only_Order;  
      }
     //<T06/>
  
   
    public static void deactivateOrderProducts(List<Id> orderIds){  
        Set<String> orderStatus = new Set<String>(Label.F2AOrderActivatedStatus.split(';'));
        
        for(List<OrderItem> orderProducts : [Select Id, Product2.Delivery_Method__c 
                                            from OrderItem where OrderId  In: orderIds 
                                            and Id IN (Select Order_Product__c from Related_Fulfillment_Line__c) // Additional check to include only order products with Related Fulfillment Lines as part of T05
                                            and Ship_Date__c != null//and SBQQ__Status__c In ('Provisioning Complete','Activated' ) // commented as a part of T04
                                            and Order.Status NOT IN :orderStatus //<T08> Additional check to query order products only when order is not activated
                                            ]){
            for(OrderItem orderProduct :orderProducts){
                //orderProduct.SBQQ__Status__c='Draft'; // commented as a part of T04
                orderProduct.Ship_Date__c= null;
            }
            update orderProducts;
        }
    }
  
  
     /**
         1. Find fulfillment header that have ship completed fulfillment lines for an order. 
         2. Delete the rest of the fulfillment headers that does not have ship completed fulfillment lines.  Also delete the 
      */
     public static void reset(Id OrderId){
       if(String.isNotBlank(OrderId)){
         List<Fulfillment__c> fulfillmentHeaderList = [select id from Fulfillment__c where Id In  (select Fullfillment__c from Fulfillment_Line__c where Ship_Status__c  In ('Provisioning Complete' )) and Order__c = :OrderId];
         if(fulfillmentHeaderList.size()>0){
            Delete [select id from Fulfillment_Version__c where Order__c=:OrderId and Fullfillment_Line__r.Fullfillment__c Not IN :fulfillmentHeaderList];
            Delete [select id from Related_Fulfillment_Line__c where Fullfillment_Line__r.Fullfillment__r.Order__c =:OrderId and Fullfillment_Line__r.Fullfillment__c Not In :fulfillmentHeaderList];
            Delete [select id from Fulfillment_Line__c where Fullfillment__r.Order__c =:OrderId and Fullfillment__c Not In :fulfillmentHeaderList];        
            Delete [select id from Fulfillment__c where Id Not In :fulfillmentHeaderList and Order__c = :OrderId];       
         
         }
       }        
     }
  
    /**<T09>**/
    public static Boolean updateFulfillmentHeader(Set<Id> ProductIdSet){
        
        Boolean ProvisionExternalSystem = false;
        List<InstallBase_Mapping__c> IBMappingList = new List<InstallBase_Mapping__c>();
        
        IBMappingList = [SELECT Id,Product__c,Install_Base__c,Install_Base__r.RecordType.DeveloperName  
                         FROM InstallBase_Mapping__c
                         WHERE Product__c IN :ProductIdSet 
                         AND Install_Base__r.RecordType.DeveloperName='API'];
        
            if(IBMappingList.size()>0){
                ProvisionExternalSystem =true;
            }
        return ProvisionExternalSystem;
    }
    /**<T09>**/

    //---------------------------------------<T16>---------------------------------------

    /*
     Method Name : getOrderProducts
     Description : This method queries order products.
     Parameters  : Id, called from createFulfillments, orderId  order record id.
     Return Type : List<OrderItem>
     */
    public static List<OrderItem> getOrderProducts(Id orderId){
        return [Select Id,
                       OrderId,
                       OrderItemNumber,
                       ServiceDate,
                       EndDate,
                       Quantity,
                       TotalPrice,
                       Product_Category__c,
                       SBQQ__RequiredBy__c,
                       Order.OpportunityId,
                       Order.SBQQ__Quote__c,
                       Product2.Id, //<T17>
                       Product2.Name,
                       Product2.GTM_Model__c,
                       Product2.Option_Scale__c,
                       Product2.Pricing_Business_Model__c,
                       Product2.Offering_Type__c,
                       Product2.Provisionable_New__c,
                       Product2.License_Generation__c,
                       Product2.License_Screen_Type__c,
                       SBQQ__RequiredBy__r.ServiceDate,
                       SBQQ__RequiredBy__r.EndDate,
                       SBQQ__RequiredBy__r.Quantity,
                       SBQQ__RequiredBy__r.TotalPrice,
                       SBQQ__RequiredBy__r.Product2.License_Generation__c,
                       SBQQ__RequiredBy__r.Product2.License_Screen_Type__c,
                       SBQQ__QuoteLine__c,
                       SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,
                       SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,
                       SBQQ__QuoteLine__r.Transaction_Type__c,
                       SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
                       SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c
                       FROM OrderItem 
                       WHERE OrderId =: orderId AND Order.OpportunityId != null AND Order.SBQQ__Quote__c != null];
    }

    /*
     Method Name : sortOrderProductsByParentAndChild
     Description : This method returns the map of the parent order product to the child order products.
     Parameters  : Id, called from createFulfillments, orderId  order record id.
     Return Type : Map<Id, List<OrderItem>>
     */
    public static Map<Id, List<OrderItem>> sortOrderProductsByParentAndChild(List<OrderItem> lstOrderProducts){
        Map<Id, List<OrderItem>> orderProductParentToChildMap = new Map<Id, List<OrderItem>>();
        
        for(OrderItem objOrderProduct : lstOrderProducts){
            if(objOrderProduct.SBQQ__RequiredBy__c != null){
                if(!orderProductParentToChildMap.containsKey(objOrderProduct.SBQQ__RequiredBy__c)){
                    orderProductParentToChildMap.put(objOrderProduct.SBQQ__RequiredBy__c, new List<OrderItem>{objOrderProduct});
                }
                else{
                    List<OrderItem> lstChildOrderProducts = orderProductParentToChildMap.get(objOrderProduct.SBQQ__RequiredBy__c);
                    lstChildOrderProducts.add(objOrderProduct);
                    orderProductParentToChildMap.put(objOrderProduct.SBQQ__RequiredBy__c, lstChildOrderProducts);
                }
            }
        }

        return orderProductParentToChildMap;
    }

    //---------------------------------------</T16>---------------------------------------
}