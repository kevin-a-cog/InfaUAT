/****************************************************************************************************************************
 *  @Class Name: LinkPreviousOrderDetailsController
 *  @Author: Anil
 *  @Date: 30 Oct 2019
 *  @Description: Controller class to LinkPreviousOrderDetail Page . 
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/

public  class LinkPreviousOrderDetailsController{

Public Id OrderItemId = apexpages.currentpage().getparameters().get('id');
Public OrderItem OrderItem{get;set;}
Public String OrderItemNumber {get;set;}
Public List<Previous_Order_Detail__c> PreviousOrderItemList{get;set;}
Public String ProductName {get;set;}
Public Decimal Quantity {get;set;}
Public String OrderId;
Public List<Previous_Order__c> PreviousOrderList ;
public Set<Id> CPQOrderIds = new Set<Id>(); 
public Set<Id> ApttusOrderIds = new Set<Id>();
Public List<Previous_Order_Detail__c> ExistingPreviousOrderItemList{get;set;}
public list<OrderItem> CPQOrderLineItems{get; set;}
public list<Old_Org_Order_Detail__c> ApttusOrderLineItems{get; set;}
public Map<id,id> mapPreviousItemToOrder = new Map<id,id>();
public static globalApexManager GAM = new globalApexManager();
   

    public LinkPreviousOrderDetailsController(ApexPages.StandardController controller) {
       
           ExistingPreviousOrderItemList=  new List<Previous_Order_Detail__c>();
           ExistingPreviousOrderItemList=  [Select id,Previous_Order_Line_Apttus__c,Previous_Order_Line_CPQ__c,Upgrade_Percentage__c,Upgrade_Quantity__c From Previous_Order_Detail__c where Order_Product__c =: OrderItemId  ];
           
           OrderItem = [Select Id,OrderItemNumber,Product2.Name,Quantity,Order.Id from OrderItem where Id =: OrderItemId];
           OrderItemNumber = OrderItem.OrderItemNumber;
           ProductName = OrderItem.Product2.Name;
           Quantity = OrderItem.Quantity;
           OrderId = OrderItem.Order.Id;
           
        PreviousOrderList = new List<Previous_Order__c>();
        PreviousOrderList = [Select Id, Order__c,Previour_Order_CPQ__c,Previous_Order_Apttus__c from Previous_Order__c Where Order__c=: OrderId];
        
        if(PreviousOrderList!= null && PreviousOrderList.size()>0){
            for(Previous_Order__c ap : PreviousOrderList){
                if(ap.Previour_Order_CPQ__c != null ){
                    CPQOrderIds.add(ap.Previour_Order_CPQ__c);
                }
                if(ap.Previous_Order_Apttus__c != null){
                    ApttusOrderIds.add(ap.Previous_Order_Apttus__c);
                }
            }
        }
        
         CPQOrderLineItems = [Select Id,OrderItemNumber,Order.OrderNumber,Order.Id,Quantity,Product2.Name,PeopleSoft_Extended_List_Price__c from OrderItem Where Order.Id IN: CPQOrderIds];
         ApttusOrderLineItems = [Select Id,Name,Extended_Price__c,SKU_Name__c,Quantity__c,Old_Org_Order_Name__c,Old_Org_Order__c,Old_Org_Order__r.Id from Old_Org_Order_Detail__c Where Old_Org_Order__c IN: ApttusOrderIds];
         
         for(OrderItem oi : CPQOrderLineItems){
             mapPreviousItemToOrder.put(oi.Id,oi.Order.Id);
         }
         
         for(Old_Org_Order_Detail__c oldOI : ApttusOrderLineItems){
             mapPreviousItemToOrder.put(oldOI.Id,oldOi.Old_Org_Order__r.Id);
         }
         
        PreviousOrderItemList= new List<Previous_Order_Detail__c>();
        Previous_Order_Detail__c cs = new Previous_Order_Detail__c();
        PreviousOrderItemList.add(cs);

    }
    
    public void AddPreviousOrderList(){
        Previous_Order_Detail__c cs = new Previous_Order_Detail__c();
        PreviousOrderItemList.add(cs);
    }
    
    
    /**
    * this method creates previous Order Item records based on selection on LinkToPreviousOrderDetail Page
    * @param parameter- 
    * @param parameter- 
    * @return return- PageReference to Order
    * @throws exception-captures exception in a debug log
    */
    public PageReference  SavePreviousOrdersItems(){
        
        if(ExistingPreviousOrderItemList != null && ExistingPreviousOrderItemList.size()>0){
            Update ExistingPreviousOrderItemList;
        }
        
        List<Previous_Order_Detail__c> PreviousOrderItemListToInsert = new List<Previous_Order_Detail__c>(); 
        
        if(PreviousOrderItemList != null && PreviousOrderItemList.size()>0){
            for(Previous_Order_Detail__c cn: PreviousOrderItemList){
                if(cn.Previous_Order_Line_Apttus__c != null || cn.Previous_Order_Line_CPQ__c != null){
                    cn.Linked_By__c = UserInfo.getUserId();
                    cn.Order_Product__c = OrderItemId;
                    cn.Order__c = OrderId;
                    if(cn.Previous_Order_Line_Apttus__c != null && mapPreviousItemToOrder.ContainsKey(cn.Previous_Order_Line_Apttus__c)){
                        cn.Previous_Order_Apttus__c = mapPreviousItemToOrder.get(cn.Previous_Order_Line_Apttus__c);
                    }
                    if(cn.Previous_Order_Line_CPQ__c != null && mapPreviousItemToOrder.ContainsKey(cn.Previous_Order_Line_CPQ__c)){
                        cn.Previous_Order_CPQ__c = mapPreviousItemToOrder.get(cn.Previous_Order_Line_CPQ__c);
                    }
                    
                    PreviousOrderItemListToInsert.add(cn);
                }
            }
        }  
        
        if(PreviousOrderItemListToInsert!= null && PreviousOrderItemListToInsert.size()>0){
            insert PreviousOrderItemListToInsert;
        }
        
        List<OrderItem> orderItemToUpdate = [Select Id, Link_Completed__c,Linked_By__c from OrderItem where Id =:OrderItemId ];
        if(orderItemToUpdate.size() > 0 && orderItemToUpdate != null){
            orderItemToUpdate[0].Link_Completed__c = TRUE;
            orderItemToUpdate[0].Linked_By__c = UserInfo.getUserId();
        }
        
        try{
            update orderItemToUpdate;
        }
        Catch(Exception e){
             GAM.CreateExceptionRecords('SavePreviousOrdersItems', e.GetMessage(),OrderId);
              ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
        }
        
        String str;
        str = '/'+OrderId;
        PageReference p = new PageReference(str);
        return p;
    }
 }