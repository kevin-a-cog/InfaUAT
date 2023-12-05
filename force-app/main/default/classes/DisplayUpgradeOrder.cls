/****************************************************************************************************************************
 *  @Class Name: DisplayUpgradeOrder
 *  @Author: Anil
 *  @Date: 8 Nov 2019
 *  @Description: Controller class to DisplayUpgradeOrder Page . 
 ****************************************************************************************************************************/

Public Class DisplayUpgradeOrder
{
    Public Id iid = apexpages.currentpage().getparameters().get('id');
    Public Set<Id> SetCPQOrderIds = new Set<Id>();
    Public Set<Id> SetApttusOrderIds = new Set<Id>();
    Public List<OrderItem> OrderLineItemListCPQ = new List<OrderItem>();
    Public List<Old_Org_Order_Detail__c> OrderLineItemListApttus = new List<Old_Org_Order_Detail__c>();
    Public Map<Id,List<Previous_Order_Detail__c>> MapPreviousOrderDetails = new Map<Id,List<Previous_Order_Detail__c>>();
    Public List<WrappertoDisplay> ListToDisplay {get;set;} 
    Public Map<id,List<WrappertoDisplay>> MapToDisplay {get;set;}
    Public String DisplayMessage {get;set;}
    public static globalApexManager GAM = new globalApexManager();
    
    Public DisplayUpgradeOrder(ApexPages.StandardController controller)
    {
      for(Previous_Order_Detail__c  cs: [Select Id,Name,Previous_Order_Apttus__c,Previous_Order_CPQ__c, Order_Product__c,Previous_Order_Line_Apttus__c,Previous_Order_Line_CPQ__c,Upgrade_Percentage__c,Upgrade_Quantity__c,Order_Product__r.Product2.Name,Previous_Order_Line_CPQ__r.OrderItemNumber,Previous_Order_Line_Apttus__r.Name,Order_Product__r.Id,Order_Product__r.OrderItemNumber,Previous_Order_Line_CPQ__r.Product2.Name,Previous_Order_Line_Apttus__r.SKU_Name__c from Previous_Order_Detail__c  Where     Order__c =: iid])
        {   
            SetCPQOrderIds.add(cs.Previous_Order_CPQ__c); 
            SetApttusOrderIds.add(cs.Previous_Order_Apttus__c);
            if(MapPreviousOrderDetails !=null && MapPreviousOrderDetails.containskey(cs.Previous_Order_Line_CPQ__c))
            {   
                List<Previous_Order_Detail__c> tempList = MapPreviousOrderDetails.get(cs.Previous_Order_Line_CPQ__c);
                tempList.add(cs);
                MapPreviousOrderDetails.put(cs.Previous_Order_Line_CPQ__c,tempList);
            }
            else
            {   
                List<Previous_Order_Detail__c> tempList = new List<Previous_Order_Detail__c>();
                tempList.add(cs);
                MapPreviousOrderDetails.put(cs.Previous_Order_Line_CPQ__c,tempList);
            }
            
            if(MapPreviousOrderDetails !=null && MapPreviousOrderDetails.containskey(cs.Previous_Order_Line_Apttus__c))
            {   
                List<Previous_Order_Detail__c> tempList = MapPreviousOrderDetails.get(cs.Previous_Order_Line_Apttus__c);
                tempList.add(cs);
                MapPreviousOrderDetails.put(cs.Previous_Order_Line_Apttus__c,tempList);
            }
            else
            {   
                List<Previous_Order_Detail__c> tempList = new List<Previous_Order_Detail__c>();
                tempList.add(cs);
                MapPreviousOrderDetails.put(cs.Previous_Order_Line_Apttus__c,tempList);
            }
        }  
        
       for(Previous_Order__c listPreviousOrders : [SELECT Id,Name,Order__c,Previour_Order_CPQ__c,Previous_Order_Apttus__c,Previous_Order_Date__c,Previous_Order_Notes__c FROM Previous_Order__c where Order__c =: iid])
        
        {
            SetCPQOrderIds.add(listPreviousOrders.Previour_Order_CPQ__c);
            SetApttusOrderIds.add(listPreviousOrders.Previous_Order_Apttus__c);
        }
        
        if(SetCPQOrderIds != null)
        {
            OrderLineItemListCPQ = [Select Id,OrderItemNumber,Order.Id,Quantity,Product2.Name,PeopleSoft_Extended_List_Price__c,Order.OrderNumber from OrderItem where Order.Id IN: SetCPQOrderIds  order by OrderItemNumber, Order.Id Desc];
        }
        
        if(SetApttusOrderIds != null)
        {
            OrderLineItemListApttus = [Select Id,Name,Extended_Price__c,SKU_Name__c,Quantity__c,Old_Org_Order_Name__c,Old_Org_Order__c,Old_Org_Order__r.Id from Old_Org_Order_Detail__c Where Old_Org_Order__c IN: SetApttusOrderIds  order by name, Old_Org_Order__c Desc];
        }
            
        ListToDisplay = new List<WrappertoDisplay>();
        MapToDisplay = new Map<id,List<WrappertoDisplay>>();
        if(OrderLineItemListCPQ != null && OrderLineItemListCPQ.size()>0)
        {
            for(OrderItem  od : OrderLineItemListCPQ)
            {
                String  OldProdName;
                String LineNum;
                String  prodName;
                Decimal Qty;
                Decimal Per;
                String  OrderName;
                //
                String oldItemNumber;
                OrderName = od.Order.OrderNumber;
                WrappertoDisplay tempwrapper = new WrappertoDisplay();
                //CPQ Order Products that are linked
                if(MapPreviousOrderDetails.ContainsKey(od.id))
                {   
                  for(Previous_Order_Detail__c temp: MapPreviousOrderDetails.get(od.id))
                  { 
                    OldProdName    =   temp.Previous_Order_Line_CPQ__r.Product2.Name;
                    linenum     =   temp.Order_Product__r.OrderItemNumber;
                    prodName    =   temp.Order_Product__r.Product2.Name;
                    Qty         =   temp.Upgrade_Quantity__c;
                    Per         =   temp.Upgrade_Percentage__c;  
                    tempwrapper = new WrappertoDisplay(OrderName,od.OrderItemNumber,od.PeopleSoft_Extended_List_Price__c,od.Quantity,temp.Previous_Order_Line_CPQ__r.OrderItemNumber,linenum,OldProdName,ProdName,Qty,Per);
                    addtoDisplay(od.order.Id,tempWrapper);    
                  }
                }
                //CPQ Order Products that are not linked
                if(!MapPreviousOrderDetails.ContainsKey(od.id))
                {   
                     OldProdName = od.Product2.Name;
                    tempwrapper = new WrappertoDisplay(OrderName,od.OrderItemNumber,od.PeopleSoft_Extended_List_Price__c,od.Quantity, oldItemNumber,linenum,OldProdName,ProdName,Qty,Per);
                        ListToDisplay.Add(tempWrapper);
                        addtoDisplay(od.order.id,tempWrapper); 
                } 
            }
        }
        
        if(OrderLineItemListApttus != null && OrderLineItemListApttus.size()>0)
        {      
            for(Old_Org_Order_Detail__c  od : OrderLineItemListApttus)
            {   String  OldProdName;
                String LineNum;
                String  prodName;
                Decimal Qty;
                Decimal Per;
                String  OrderName;
                String oldItemNumber;
                OrderName = od.Old_Org_Order_Name__c;
                WrappertoDisplay tempwrapper = new WrappertoDisplay();
                //Apttus Order Products that are linked
                if(MapPreviousOrderDetails.ContainsKey(od.id))
                { 
                    for(Previous_Order_Detail__c temp: MapPreviousOrderDetails.get(od.id))
                    { 
                        OldProdName    =   temp.Previous_Order_Line_Apttus__r.SKU_Name__c;
                        linenum     =   temp.Order_Product__r.OrderItemNumber;
                        prodName    =   temp.Order_Product__r.Product2.Name;
                        Qty         =   temp.Upgrade_Quantity__c;
                        Per         =   temp.Upgrade_Percentage__c;  
                        tempwrapper = new WrappertoDisplay(OrderName,od.name,od.Extended_Price__c,od.Quantity__c,temp.Previous_Order_Line_Apttus__r.Name,linenum,OldProdName,ProdName,Qty,Per);
                        addtoDisplay(od.Old_Org_Order__r.Id,tempWrapper);    
                  }
                } 
                //Apttus Order Products that are not linked
                if(!MapPreviousOrderDetails.ContainsKey(od.id))
                {   OldProdName = od.SKU_Name__c;
                      tempwrapper = new WrappertoDisplay(OrderName,od.name,od.Extended_Price__c,od.Quantity__c, oldItemNumber,linenum,OldProdName,ProdName,Qty,Per);
                        ListToDisplay.Add(tempWrapper);
                        addtoDisplay(od.Old_Org_Order__r.Id,tempWrapper); 
                       
                }
                
            }
        }   
            
        if(MapToDisplay == null || MapToDisplay.IsEmpty()){
            DisplayMessage = 'There are no linked previous order lines for this Quote';        
        }
    }
    
    public Map<Id,List<WrappertoDisplay>> addtoDisplay(Id orderId,WrappertoDisplay tempWrapper)
    {   
        try{
            if(MapToDisplay !=null && MapToDisplay.containskey(orderId))
            {   
                List<WrappertoDisplay> tempOrderList=MapToDisplay.get(orderId);
                tempOrderList.add(tempwrapper);
                MapToDisplay.put(orderId,tempOrderList);
            }
            else
            {   
                List<WrappertoDisplay> tempOrderList=new List<WrappertoDisplay>();
                tempOrderList.add(tempwrapper);
                MapToDisplay.put(orderId,tempOrderList);
               
            }
        }
        Catch(Exception e){
            GAM.CreateExceptionRecords('addtoDisplay', e.GetMessage(),orderId);
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
        }
        return MapToDisplay;
    }
    
    Public Class WrappertoDisplay{
        Public String  OrderName{get;set;}  
        Public String  OrderLineNum{get;set;}
        Public Decimal ExtPrice{get;set;}
        Public Decimal Qty{get;set;}
        Public String  OrderProduct{get;set;}
        Public String  OldProductName{get;set;}
        Public String ProposalUpgradeOrderLine{get;set;}
        Public String  ProposalProduct{get;set;}
        Public Decimal UpgradeQty{get;set;}
        Public Decimal UpgradePercent{get;set;}
        
        Public WrappertoDisplay(){
        }
        
       public  WrappertoDisplay(String OrderName, String odline, Decimal ExtPrice, Decimal Qty, String OrderPrd,String PrpUpgLine, String OldProductName,String PrpProd, Decimal UpgQty, Decimal UpgPer){
       
            this.OrderName           =  OrderName;
            this.OrderLineNum        =  odline;
            this.ExtPrice            =  ExtPrice;
            this.Qty                 =  Qty;
            this.OrderProduct        =  OrderPrd;
            this.OldProductName         =  OldProductName;
            this.ProposalUpgradeOrderLine =  PrpUpgLine;
            this.ProposalProduct     =  PrpProd;
            this.UpgradeQty          =  UpgQty;
            this.UpgradePercent      =  UpgPer;
        }       
    }
}