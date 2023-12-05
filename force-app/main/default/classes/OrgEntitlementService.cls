/*
 * Name         :   OrgEntitlementService
 * Author       :   Vignesh Divakaran
 * Created Date :   2/1/2023
 * Description  :   Service class for Flex IPU Org Entitlement functionality.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      2/1/2023        F2A-500         Initial version.                            N/A
 Vignesh Divakaran      2/20/2023       F2A-539         Changed DML from delete to update           T01
 Vignesh Divakaran      2/28/2023       F2A-540         Order the records by Id in ascending        T02
 Vignesh Divakaran      2/28/2023       F2A-476         Updated logic for IPU 1.0 metering          T03
 Vignesh Divakaran      3/2/2023        F2A-551         Use floor for -negative quantity            T04
 Nishit Sardessai		10/19/2023		F2A-660			Apex CPU time limit issue on Fulfillment 	F2A-660
														creation(Org Entitlement Line)
 */

 public without sharing class OrgEntitlementService {

    private final static String PRODUCT_CATEGORY = 'Add-ons';
    private final static String OPTION_SCALE = 'Base Product';
    private final static Set<String> CONSUMPTION_MODEL = new Set<String>{System.Label.IPU_Product_GTM_Value, System.Label.IPU}; //<T03>
    private static Map<Id, Map<String, blng__UsageSummary__c>> usageSummaryMap = new Map<Id, Map<String, blng__UsageSummary__c>>();
    public static globalApexManager GAM = new globalApexManager();


    /*
     Method Name : createOrgEntitlements
     Description : This method creates org entitlements.
     Parameters  : Id, Called from createOrgEntitlements, orderId Record Id.
     Return Type : None
     */
    public static void createOrgEntitlements(Id orderId){
        try{
            List<OrderItem> lstFlexOrderLines = [SELECT Id, 
                                                   Quantity,
                                                   ServiceDate,
                                                   EndDate,
                                                   SBQQ__RequiredBy__c,
                                                   SBQQ__ProrateMultiplier__c,
                                                   SBQQ__UpgradedSubscription__c,
                                                   Product2.Option_Scale__c,
                                                   Product2.GTM_Model__c,
                                                   Order.SBQQ__Quote__c,
                                                   Order.SBQQ__Quote__r.SBQQ__StartDate__c,
                                                   SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c,
                                                   SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c,
                                                   SBQQ__QuoteLine__r.End_Date_Output_QL__c,
                                                   SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c,
                                                   SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
                                                   SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c,
                                                   SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__r.OrderId,
                                                   SBQQ__RequiredBy__r.ServiceDate, 
                                                   SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c
                                                   FROM OrderItem 
                                                   WHERE OrderId =: orderId AND Product2.GTM_Model__c IN :CONSUMPTION_MODEL AND Product2.Option_Scale__c =: OPTION_SCALE AND Product_Category__c =: PRODUCT_CATEGORY
                                                   ORDER BY SBQQ__RequiredBy__c, ServiceDate, SBQQ__UpgradedSubscription__c DESC NULLS LAST];
            Map<Id, List<OrderItem>> bundleMap = new Map<Id, List<OrderItem>>();
            List<OrgEntitlement> lstOrgEntitlementsWrapper = new List<OrgEntitlement>();
            List<Org_Entitlement__c> lstOrgEntitlements = new List<Org_Entitlement__c>();
            List<Org_Entitlement_Line__c> lstOrgEntitlementLines = new List<Org_Entitlement_Line__c>();
            Map<Id, List<OrderItem>> wrapperToAmendedFlexLines = new Map<Id, List<OrderItem>>();
            Set<Id> setOrderIds = new Set<Id>();
            usageSummaryMap = getUsageSummaries(orderId);

            if(!lstFlexOrderLines.isEmpty()){

                //Now, we create a bundle of parent and its child order products.
                for(OrderItem objOrderLine : lstFlexOrderLines){

                    //We check for NNB and Renewal order products
                    if(objOrderLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c == null){
                        List<OrderItem> lstChildFlexOrderLines = bundleMap.containsKey(objOrderLine.SBQQ__RequiredBy__c) ? bundleMap.get(objOrderLine.SBQQ__RequiredBy__c) : new List<OrderItem>();
                        lstChildFlexOrderLines.add(objOrderLine);
                        bundleMap.put(objOrderLine.SBQQ__RequiredBy__c, lstChildFlexOrderLines);
                    }

                    //We check for amend order products
                    if(objOrderLine.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__r?.SBQQ__OrderProduct__r?.OrderId != null){
                        setOrderIds.add(objOrderLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__r.OrderId);
                        List<OrderItem> lstAmendedFlexLines = new List<OrderItem>();
                        if(wrapperToAmendedFlexLines.containsKey(objOrderLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c)){
                            lstAmendedFlexLines = wrapperToAmendedFlexLines.get(objOrderLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c);
                        }
                        lstAmendedFlexLines.add(objOrderLine);
                        wrapperToAmendedFlexLines.put(objOrderLine.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c, lstAmendedFlexLines);
                    }
                }

                if(!bundleMap.isEmpty()){
                    lstOrgEntitlementsWrapper.addAll(getOrgEntitlementForNewAndRenewal(bundleMap));
                }

                if(!setOrderIds.isEmpty() && !wrapperToAmendedFlexLines.isEmpty()){
                    lstOrgEntitlementsWrapper.addAll(getOrgEntitlementForAmend(setOrderIds, wrapperToAmendedFlexLines));
                }


                if(!lstOrgEntitlementsWrapper.isEmpty()){

                    for(OrgEntitlement objOrgEntitlementWrapper : lstOrgEntitlementsWrapper){
                        lstOrgEntitlements.add(objOrgEntitlementWrapper.objOrgEntitlement);
                    }

                    //Now, we upsert master records
                    upsert lstOrgEntitlements;

                    for(OrgEntitlement objOrgEntitlementWrapper : lstOrgEntitlementsWrapper){
                        for(Org_Entitlement_Line__c objOrgEntitlementLine : objOrgEntitlementWrapper.lstOrgEntitlementLines){
                            if(objOrgEntitlementLine.Id == null){
                                objOrgEntitlementLine.Org_Entilement__c = objOrgEntitlementWrapper.objOrgEntitlement.Id;
                                lstOrgEntitlementLines.add(objOrgEntitlementLine);
                            }
                        }
                    }

                    //Now, we create detail records
                    if(!lstOrgEntitlementLines.isEmpty()){
                        insert lstOrgEntitlementLines;
                    }
                }
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OrgEntitlementService.createOrgEntitlements', 'Error while creating org entitlements', ex.getMessage());
        }
    }

    /*
     Method Name : getOrgEntitlementForNewAndRenewal
     Description : This method creates org entitlements for NNB and Renewal orders.
     Parameters  : Map<Id, List<OrderItem>>, Called from createOrgEntitlements, bundleMap Parent and Child order lines.
     Return Type : List<OrgEntitlement>
     */
    private static List<OrgEntitlement> getOrgEntitlementForNewAndRenewal(Map<Id, List<OrderItem>> bundleMap){
        List<OrgEntitlement> lstOrgEntitlements = new List<OrgEntitlement>();
        Map<Id, List<OrgEntitlement>> flexWrapperToOrgEntitlements = new Map<Id, List<OrgEntitlement>>();

        for(Id flexWrapperOrderLineId : bundleMap.keySet()){

            Integer intVisitedFlexOrderLineCount = 0;

            for(OrderItem objChildOrderLine : bundleMap.get(flexWrapperOrderLineId)){
                List<OrgEntitlement> lstChildOrgEntitlements = flexWrapperToOrgEntitlements.containsKey(objChildOrderLine.SBQQ__RequiredBy__c) ? flexWrapperToOrgEntitlements.get(objChildOrderLine.SBQQ__RequiredBy__c) : new List<OrgEntitlement>();
                intVisitedFlexOrderLineCount++;
                lstChildOrgEntitlements = getOrgEntitlement(objChildOrderLine, lstChildOrgEntitlements, bundleMap.get(flexWrapperOrderLineId).size() == intVisitedFlexOrderLineCount, false);
                flexWrapperToOrgEntitlements.put(objChildOrderLine.SBQQ__RequiredBy__c, lstChildOrgEntitlements);
            }
        }

        for(Id flexWrapperOrderLineId : flexWrapperToOrgEntitlements.keySet()){
            lstOrgEntitlements.addAll(flexWrapperToOrgEntitlements.get(flexWrapperOrderLineId));
        }

        return lstOrgEntitlements;
    }

    /*
     Method Name : getOrgEntitlementForAmend
     Description : This method creates org entitlements for amend orders.
     Parameters  : Set<Id>, Called from getOrgEntitlementForAmend, setOrderIds Order record ids.
                   Map<Id, List<OrderItem>>, Called from getOrgEntitlementForAmend, wrapperToAmendedFlexLines amended order lines map
     Return Type : List<OrgEntitlement>
     */
    @TestVisible
    private static List<OrgEntitlement> getOrgEntitlementForAmend(Set<Id> setOrderIds, Map<Id, List<OrderItem>> wrapperToAmendedFlexLines){
        Set<Id> setOrgEntitlementIds = new Set<Id>();
        Map<Id, Org_Entitlement__c> mapOrgEntitlements = new Map<Id, Org_Entitlement__c>();
        Map<Id, List<OrgEntitlement>> wrapperToOrgEntitlements = new Map<Id, List<OrgEntitlement>>();
        List<OrgEntitlement> lstOrgEntitlements = new List<OrgEntitlement>();

        for(Org_Entitlement__c objOrgEntitlement : [SELECT Id,Start_Date__c,End_Date__c,Total_Qunatity__c,Type__c,
                                                    (SELECT Id,Start_Date__c,End_Date__c,IPUs__c,Order_Line__c,Order_Line__r.SBQQ__RequiredBy__c FROM Org_Entitlement_Lines__r ORDER BY Id ASC) //<T02>
                                                    FROM Org_Entitlement__c WHERE Id IN (SELECT Org_Entilement__c FROM Org_Entitlement_Line__c WHERE Order_Line__r.OrderId IN :setOrderIds) ORDER BY Id ASC]){ //<T02>
            Id wrapperOrderLineId;

            for(Org_Entitlement_Line__c objOrgEntitlementLine : objOrgEntitlement.Org_Entitlement_Lines__r){
                //<F2A-660> START- Stopping the for loop execution after the first wrapper is found
                if(objOrgEntitlementLine.Order_Line__r.SBQQ__RequiredBy__c != NULL){
                    wrapperOrderLineId = objOrgEntitlementLine.Order_Line__r.SBQQ__RequiredBy__c;
                    break;
                }
                //</F2A-660> END
            }
        
            if(wrapperOrderLineId != null){
                OrgEntitlement objOrgEntitlementWrapper = new OrgEntitlement();
                objOrgEntitlementWrapper.objOrgEntitlement = objOrgEntitlement;
                objOrgEntitlementWrapper.lstOrgEntitlementLines = objOrgEntitlement.Org_Entitlement_Lines__r;
                List<OrgEntitlement> lstOrgEntitlementsWrapper = wrapperToOrgEntitlements.containsKey(wrapperOrderLineId) ? wrapperToOrgEntitlements.get(wrapperOrderLineId) : new List<OrgEntitlement>();
                lstOrgEntitlementsWrapper.add(objOrgEntitlementWrapper);
                wrapperToOrgEntitlements.put(wrapperOrderLineId, lstOrgEntitlementsWrapper);
            }
        }

        for(Id wrapperOrderLineId : wrapperToAmendedFlexLines.keySet()){
            List<OrderItem> lstAmendedFlexLines = wrapperToAmendedFlexLines.get(wrapperOrderLineId);
            List<OrgEntitlement> lstExistingOrgEntitlements = wrapperToOrgEntitlements.containsKey(wrapperOrderLineId) ? wrapperToOrgEntitlements.get(wrapperOrderLineId) : new List<OrgEntitlement>();
            Integer intVisitedFlexOrderLineCount = 0;
            
            for(OrderItem objOrderLine : lstAmendedFlexLines){
                intVisitedFlexOrderLineCount++;
                wrapperToOrgEntitlements.put(wrapperOrderLineId, getOrgEntitlement(objOrderLine, lstExistingOrgEntitlements, wrapperToAmendedFlexLines.get(wrapperOrderLineId).size() == intVisitedFlexOrderLineCount, true));
            }
        }

        for(Id wrapperOrderLineId : wrapperToOrgEntitlements.keySet()){
            lstOrgEntitlements.addAll(wrapperToOrgEntitlements.get(wrapperOrderLineId));
        }

        return lstOrgEntitlements;
    }

    /*
     Method Name : getOrgEntitlement
     Description : This method creates org entitlement and org entitlement lines for the given order line.
     Parameters  : OrderItem, Called from getOrgEntitlementForNewAndRenewal, objOrderLine Record.
                   OrgEntitlement, Called from getOrgEntitlementForNewAndRenewal, lstExistingOrgEntitlements wrapper record.
                   Boolean, Called from getOrgEntitlementForNewAndRenewal, boolAmendedOrderLine indicates the order line is from amended bundle.
     Return Type : List<OrgEntitlement>
     */
    private static List<OrgEntitlement> getOrgEntitlement(OrderItem objOrderLine, List<OrgEntitlement> lstExistingOrgEntitlements, Boolean boolLastLine, Boolean boolAmendedOrderLine){
        Decimal decProrateMultipler = objOrderLine.SBQQ__ProrateMultiplier__c;
        List<OrgEntitlement> lstOrgEntitlements = new List<OrgEntitlement>();

        if(!lstExistingOrgEntitlements.isEmpty()){

            Date lineStartDate;

            while(decProrateMultipler > 0){

                for(OrgEntitlement objExistingOrgEntitlementWrapper : lstExistingOrgEntitlements){
                    Org_Entitlement__c objExistingOrgEntitlement = objExistingOrgEntitlementWrapper.objOrgEntitlement;
                    Decimal decOrgEntitlementLineQTY;

                    if(objExistingOrgEntitlement.Start_Date__c >= objOrderLine.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c){
                        
                        if(decProrateMultipler >= 1){
                            objExistingOrgEntitlement.Total_Qunatity__c = objExistingOrgEntitlement.Total_Qunatity__c + objOrderLine.Quantity;
                            decOrgEntitlementLineQTY = objOrderLine.Quantity;
                        }
                        else{
                            Decimal decPriorQTY = objExistingOrgEntitlement.Total_Qunatity__c;
                            if(!boolAmendedOrderLine){
                                decPriorQTY = (objExistingOrgEntitlement.Total_Qunatity__c * decProrateMultipler).round(System.RoundingMode.CEILING);
                                objExistingOrgEntitlement.Total_Qunatity__c = boolLastLine ? (decProrateMultipler * (objExistingOrgEntitlement.Total_Qunatity__c + objOrderLine.Quantity)).round(System.RoundingMode.CEILING) : objExistingOrgEntitlement.Total_Qunatity__c + objOrderLine.Quantity;
                                //To prevent +1 or -1 rounding off issue, we calculate the last OEL quantity = OE total prorated quantity - OE total prorated quantity excluding last OEL
                                decOrgEntitlementLineQTY = boolLastLine ? objExistingOrgEntitlement.Total_Qunatity__c - decPriorQTY : (decProrateMultipler * (objExistingOrgEntitlement.Total_Qunatity__c + objOrderLine.Quantity)).round(System.RoundingMode.CEILING);
                                //decOrgEntitlementLineQTY = objExistingOrgEntitlement.Total_Qunatity__c - decPriorQTY;
                            }
                            else{
                                objExistingOrgEntitlement.Total_Qunatity__c = objOrderLine.Quantity < 0 ? (objExistingOrgEntitlement.Total_Qunatity__c + (decProrateMultipler * objOrderLine.Quantity)).round(System.RoundingMode.FLOOR) : (objExistingOrgEntitlement.Total_Qunatity__c + (decProrateMultipler * objOrderLine.Quantity)).round(System.RoundingMode.CEILING); //<T04>
                                //To prevent +1 or -1 rounding off issue, we calculate the last OEL quantity = OE total prorated quantity - OE total prorated quantity excluding last OEL
                                decOrgEntitlementLineQTY = objExistingOrgEntitlement.Total_Qunatity__c - decPriorQTY;
                            }
                            //objExistingOrgEntitlement.Total_Qunatity__c = objExistingOrgEntitlement.Total_Qunatity__c + (decProrateMultipler * objOrderLine.Quantity).round(System.RoundingMode.CEILING);
                            //To prevent +1 or -1 rounding off issue, we calculate the last OEL quantity = OE total prorated quantity - OE total prorated quantity excluding last OEL
                            //decOrgEntitlementLineQTY = objExistingOrgEntitlement.Total_Qunatity__c - decPriorQTY;
                        }
                        List<Org_Entitlement_Line__c> lstExistingOrgEntitlementLines = !objExistingOrgEntitlementWrapper.lstOrgEntitlementLines.isEmpty() ? objExistingOrgEntitlementWrapper.lstOrgEntitlementLines : new List<Org_Entitlement_Line__c>();
                        lstExistingOrgEntitlementLines.add(getOrgEntitlementLine(objOrderLine, objExistingOrgEntitlement, decOrgEntitlementLineQTY));
                        objExistingOrgEntitlementWrapper.lstOrgEntitlementLines = lstExistingOrgEntitlementLines;
                        decProrateMultipler--;
                    }
                    lineStartDate = objExistingOrgEntitlement.End_Date__c.addDays(1);
                }
            }

            return lstExistingOrgEntitlements;
        }
        else{
            Date lineStartDate = objOrderLine.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c;

            while(decProrateMultipler > 0){

                Org_Entitlement__c objOrgEntitlement = new Org_Entitlement__c();
                objOrgEntitlement.Start_Date__c = lineStartDate;
                objOrgEntitlement.Type__c = objOrderLine.Product2?.GTM_Model__c;
                Decimal decOrgEntitlementLineQTY = decProrateMultipler >= 1 ? objOrderLine.Quantity : (decProrateMultipler * objOrderLine.Quantity).round(System.RoundingMode.CEILING);

                if(decProrateMultipler >= 1){
                    objOrgEntitlement.End_Date__c = objOrderLine.Product2.GTM_Model__c == System.Label.IPU ? lineStartDate.addMonths(1).addDays(-1) : lineStartDate.addYears(1).addDays(-1); //<T03>
                    lineStartDate = objOrderLine.Product2.GTM_Model__c == System.Label.IPU ? lineStartDate.addMonths(1) : lineStartDate.addYears(1); //<T03>
                    objOrgEntitlement.Total_Qunatity__c = objOrderLine.Quantity;
                    decOrgEntitlementLineQTY = objOrderLine.Quantity;
                }else{
                    objOrgEntitlement.End_Date__c = objOrderLine.SBQQ__QuoteLine__r.End_Date_Output_QL__c;
                    if(!boolAmendedOrderLine){
                        objOrgEntitlement.Total_Qunatity__c = boolLastLine ? (decProrateMultipler * objOrderLine.Quantity).round(System.RoundingMode.CEILING) : objOrderLine.Quantity;
                    }
                    else{
                        objOrgEntitlement.Total_Qunatity__c = (decProrateMultipler * objOrderLine.Quantity).round(System.RoundingMode.CEILING);
                    }
                    //objOrgEntitlement.Total_Qunatity__c = (decProrateMultipler * objOrderLine.Quantity).round(System.RoundingMode.CEILING);
                    decOrgEntitlementLineQTY = (decProrateMultipler * objOrderLine.Quantity).round(System.RoundingMode.CEILING);
                }
                objOrgEntitlement.Usage_Summary__c = getUsageSummary(objOrderLine, objOrgEntitlement.Start_Date__c, objOrgEntitlement.End_Date__c);

                Org_Entitlement_Line__c objOrgEntitlementLine = getOrgEntitlementLine(objOrderLine, objOrgEntitlement, decOrgEntitlementLineQTY);
                OrgEntitlement objOrgEntitlementWrapper = new OrgEntitlement();
                objOrgEntitlementWrapper.objOrgEntitlement = objOrgEntitlement;
                objOrgEntitlementWrapper.lstOrgEntitlementLines = new List<Org_Entitlement_Line__c>{objOrgEntitlementLine};
                lstOrgEntitlements.add(objOrgEntitlementWrapper);
                decProrateMultipler--;
            }
        }
        return lstOrgEntitlements;
    }

    /*
     Method Name : getOrgEntitlementLine
     Description : This method sets and returns org entitlement line.
     Parameters  : OrderItem, Called from getOrgEntitlement, objOrderLine Record.
                   Org_Entitlement__c, Called from getOrgEntitlement, objOrgEntitlement Record.
                   Decimal, Called from getOrgEntitlement, decQuantity.
     Return Type : Org_Entitlement_Line__c
     */
    private static Org_Entitlement_Line__c getOrgEntitlementLine(OrderItem objOrderLine, Org_Entitlement__c objOrgEntitlement, Decimal decQuantity){
        Org_Entitlement_Line__c objOrgEntitlementLine = new Org_Entitlement_Line__c();
        objOrgEntitlementLine.Ordered__c = true;
        objOrgEntitlementLine.Order_Line__c = objOrderLine.Id;
        objOrgEntitlementLine.IPUs__c = decQuantity;
        objOrgEntitlementLine.Start_Date__c = objOrgEntitlement.Start_Date__c;
        objOrgEntitlementLine.End_Date__c = objOrgEntitlement.End_Date__c;

        return objOrgEntitlementLine;
    }

    /*
     Method Name : updateFLOnOrgEntitlementLine
     Description : This method updates the corresponding fulfillment line back on org entitlement line.
     Parameters  : Id, Called from updateFLOnOrgEntitlementLine, orderId Record Id.
     Return Type : None
     */
    public static void updateFLOnOrgEntitlementLine(Id orderId){
        Map<Id, Fulfillment_Line__c> orderLineToFulfillmentLine = new Map<Id, Fulfillment_Line__c>();
        Set<Org_Entitlement__c> setOrgEntitlements = new Set<Org_Entitlement__c>();
        List<Org_Entitlement_Line__c> lstOrgEntitlementLines = new List<Org_Entitlement_Line__c>();

        for(Fulfillment_Line__c objFulfillmentLine : [SELECT Id,Org__c,(SELECT Id,Fullfillment_Line__c,Order_Product__c FROM Related_Fullfillment_Lines__r) FROM Fulfillment_Line__c WHERE Fullfillment__r.Order__c =: orderId AND Fullfillment__r.Active__c = true]){
           for(Related_Fulfillment_Line__c objRelatedFulfillmentLine : objFulfillmentLine.Related_Fullfillment_Lines__r){
                if(!orderLineToFulfillmentLine.containsKey(objRelatedFulfillmentLine.Order_Product__c)){
                    orderLineToFulfillmentLine.put(objRelatedFulfillmentLine.Order_Product__c, objFulfillmentLine);
                }
            } 
        }

        for(Org_Entitlement_Line__c objOrgEntitlementLine : [SELECT Id,Order_Line__c,Fulfillment_Line__c,Org_Entilement__c FROM Org_Entitlement_Line__c WHERE Order_Line__r.OrderId =: orderId]){
            if(orderLineToFulfillmentLine.containsKey(objOrgEntitlementLine.Order_Line__c)){
                Fulfillment_Line__c objFulfillmentLine = orderLineToFulfillmentLine.get(objOrgEntitlementLine.Order_Line__c);
                objOrgEntitlementLine.Fulfillment_Line__c = objFulfillmentLine.Id;
                if(objFulfillmentLine?.Org__c != null){
                    setOrgEntitlements.add(new Org_Entitlement__c(Id=objOrgEntitlementLine.Org_Entilement__c, Org_Id__c=objFulfillmentLine.Org__c));
                }
                lstOrgEntitlementLines.add(objOrgEntitlementLine);
            }
        }

        if(!setOrgEntitlements.isEmpty()){
            update new List<Org_Entitlement__c>(setOrgEntitlements);
        }

        if(!lstOrgEntitlementLines.isEmpty()){
            update lstOrgEntitlementLines;
        }
    }

    /*
     Method Name : getUsageSummaries
     Description : This method fetches usage summaries of all order products.
     Parameters  : Id, Called from getUsageSummaries, orderId Record Id.
     Return Type : Map<Id, Map<String, blng__UsageSummary__c>>
     */
    private static Map<Id, Map<String, blng__UsageSummary__c>> getUsageSummaries(Id orderId){
        Map<Id, Map<String, blng__UsageSummary__c>> usageSummaryMap = new Map<Id, Map<String, blng__UsageSummary__c>>();
        
        for(blng__UsageSummary__c objUsageSummary : [SELECT Id,blng__OrderProduct__r.SBQQ__RequiredBy__c,blng__OrderProduct__c,blng__SummaryStartDate__c,blng__SummaryEndDate__c FROM blng__UsageSummary__c WHERE blng__OrderProduct__r.OrderId =: orderId ORDER BY blng__OrderProduct__r.SBQQ__RequiredBy__c ASC]){
            String strUniqueIdentifier = String.valueOf(objUsageSummary.blng__SummaryStartDate__c) +'##'+ String.valueOf(objUsageSummary.blng__SummaryEndDate__c);
            Map<String, blng__UsageSummary__c> uniqueIdentifierToUsageSummary = usageSummaryMap.containsKey(objUsageSummary.blng__OrderProduct__r.SBQQ__RequiredBy__c) ? usageSummaryMap.get(objUsageSummary.blng__OrderProduct__r.SBQQ__RequiredBy__c) : new Map<String, blng__UsageSummary__c>();
            uniqueIdentifierToUsageSummary.put(strUniqueIdentifier, objUsageSummary);
            usageSummaryMap.put(objUsageSummary.blng__OrderProduct__r.SBQQ__RequiredBy__c, uniqueIdentifierToUsageSummary);
        }

        return usageSummaryMap;
    }

    /*
     Method Name : getUsageSummary
     Description : This method fetches the usage summary record id for the org entitlement.
     Parameters  : OrderItem, Called from getUsageSummary, objOrderLine Record.
                   Date, Called from getUsageSummary, startDate term start date.
                   Date, Called from getUsageSummary, endDate term end date.
     Return Type : String
     */
    private static String getUsageSummary(OrderItem objOrderLine, Date startDate, Date endDate){
        String strUsageSummaryRecordId = null;

        if(usageSummaryMap.containsKey(objOrderLine.SBQQ__RequiredBy__c)){
            String strUniqueIdentifier = String.valueOf(startDate) +'##'+ String.valueOf(endDate);
            Map<String, blng__UsageSummary__c> usageSummariesMap = usageSummaryMap.get(objOrderLine.SBQQ__RequiredBy__c);

            if(usageSummariesMap.containsKey(strUniqueIdentifier)){
                strUsageSummaryRecordId = usageSummariesMap.get(strUniqueIdentifier).Id;
            }
        }

        return strUsageSummaryRecordId;
    }

    /*
     Method Name : deleteOrgEntitlements
     Description : This method deletes the Org Entitlement & Org Entitlement Lines created for the given order.
     Parameters  : Id, Called from deleteOrgEntitlements, orderId Record Id.
     Return Type : None
     */
    public static void deleteOrgEntitlements(Id orderId){
        List<Org_Entitlement__c> lstOrgEntitlementsToUpdate = new List<Org_Entitlement__c>();
        List<Org_Entitlement__c> lstOrgEntitlementsToDelete = new List<Org_Entitlement__c>();
        List<Org_Entitlement_Line__c> lstOrgEntitlementLinesToDelete = new List<Org_Entitlement_Line__c>();
        
        for(Org_Entitlement__c objOrgEntitlement : [SELECT Id,Start_Date__c,End_Date__c,Total_Qunatity__c,Type__c,
                                                    (SELECT Id,Start_Date__c,End_Date__c,IPUs__c,Order_Line__c,Order_Line__r.OrderId FROM Org_Entitlement_Lines__r) 
                                                    FROM Org_Entitlement__c WHERE Id IN (SELECT Org_Entilement__c FROM Org_Entitlement_Line__c WHERE Order_Line__r.OrderId = :orderId)]){
            
            Boolean boolDeleteOrgEntitlement = true;
            Decimal decUpdatedQuantity = objOrgEntitlement.Total_Qunatity__c;
            for(Org_Entitlement_Line__c objOrgEntitlementLine : objOrgEntitlement.Org_Entitlement_Lines__r){
                if(objOrgEntitlementLine.Order_Line__r.OrderId != orderId){
                    boolDeleteOrgEntitlement = false;
                }
                else{
                    decUpdatedQuantity = decUpdatedQuantity - objOrgEntitlementLine.IPUs__c;
                    lstOrgEntitlementLinesToDelete.add(objOrgEntitlementLine);
                }
            }

            if(boolDeleteOrgEntitlement){
                lstOrgEntitlementsToDelete.add(objOrgEntitlement);
            }
            else{
                objOrgEntitlement.Total_Qunatity__c = decUpdatedQuantity;
                lstOrgEntitlementsToUpdate.add(objOrgEntitlement);
            }
        }

        if(!lstOrgEntitlementLinesToDelete.isEmpty()){
            delete lstOrgEntitlementLinesToDelete;
        }

        if(!lstOrgEntitlementsToDelete.isEmpty()){
            delete lstOrgEntitlementsToDelete;
        }

        if(!lstOrgEntitlementsToUpdate.isEmpty()){
            update lstOrgEntitlementsToUpdate; //<T01>
        }
    }

    /*Wrapper Objects */
    public class OrgEntitlement{
        public Org_Entitlement__c objOrgEntitlement {get; set;}
        public List<Org_Entitlement_Line__c> lstOrgEntitlementLines {get; set;}
    }
}