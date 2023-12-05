/*
Class:          NotifyPONumberUpdateOnIGD

@Author:        Chandana Gowda
@Created Date:  11 NOV 2020
@JIRA : I2C-1083
@Description:   Batch class for populating PO Number and sending chatter notification.
*/

/*
Change History
***********************************************************************************************************************************************************************
ModifiedBy                Date                JIRA                Requested By                    Description                                                                       Tag
Ramya Ravi              18-Feb-2021         I2C-1172            I2C-1172                        Ability to Enter/Update PO# on Multi-Year Quote/Order-Extra functionality of one PO for the whole quote  <T01>
RamEsh M S              08-Apr-2021         I2C-1239            I2C-1239                        Turn off Chatter notification to users <T02> 
***********************************************************************************************************************************************************************
*/
global class NotifyPONumberUpdateOnIGD implements Schedulable, Database.Batchable<Sobject>{
    public static globalApexManager GAM = new globalApexManager();
    public Date nextSixtyDays = System.today().addDays(60);
    public Date nextThirtyDays = System.today().addDays(30);
    public Date nextFiveDays = System.today().addDays(5);    

    global List<Sobject> start(Database.BatchableContext bc){

        /*String query = 'Select Order__c from Invoice_Group_Date__c where LastModifiedDate >= LAST_N_DAYS:1 OR Order__c IN (SELECT OrderId FROM OrderItem '+
                       'WHERE Invoice_Group__c != null AND (blng__NextBillingDate__c = TODAY OR blng__OverrideNextBillingDate__c = TODAY '+
                       'OR blng__NextBillingDate__c = : nextSixtyDays OR blng__OverrideNextBillingDate__c = : nextSixtyDays '+
                       'OR blng__NextBillingDate__c = : nextThirtyDays OR blng__OverrideNextBillingDate__c = : nextThirtyDays '+
                       'OR blng__NextBillingDate__c = NEXT_N_DAYS:5 OR blng__OverrideNextBillingDate__c = NEXT_N_DAYS:5))';
        
        return Database.getQueryLocator(query);*/
        Map<Id,Order> orderMap = new Map<Id,Order> ();
        for(Order o : [Select Id from Order where Id IN (SELECT OrderId FROM OrderItem 
                        WHERE Invoice_Group__c != null AND (blng__NextBillingDate__c = TODAY OR blng__OverrideNextBillingDate__c = TODAY
                        OR blng__NextBillingDate__c = : nextSixtyDays OR blng__OverrideNextBillingDate__c = : nextSixtyDays 
                        OR blng__NextBillingDate__c = : nextThirtyDays OR blng__OverrideNextBillingDate__c = : nextThirtyDays 
                        OR blng__NextBillingDate__c = NEXT_N_DAYS:5 OR blng__OverrideNextBillingDate__c = NEXT_N_DAYS:5))])
        {
            orderMap.put(o.Id,o);
        }
        
        for(Invoice_Group_Date__c IGD : [Select Order__c from Invoice_Group_Date__c where LastModifiedDate >= LAST_N_DAYS:1])
        {
            Order o = new Order (Id = IGD.Order__c);
            orderMap.put(IGD.Order__c,o);
        }
        
        return orderMap.values();
    }
    
    global void execute(SchedulableContext ctx)
    {
        NotifyPONumberUpdateOnIGD postChatterIG = new NotifyPONumberUpdateOnIGD();
        database.executebatch(postChatterIG,1);
    }

    global void execute(Database.BatchableContext bc, List<Order> scope){

        Map<Id,Map<Id,Id>> mapOrderIdInvGrpAndInvGrpDate = new Map<Id,Map<Id,Id>>();
        List<orderItem> oiListQuery = new List<OrderItem> ();
        List<OrderItem> lstOrderItemToUpdate = new List<OrderItem>();
        List<Invoice_Group_Date__c> lstInvoiceGroupDate = new List<Invoice_Group_Date__c> ();
        Set<Id> setInvoiceGroupIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id> ();
        Map<Id,Set<String>> nextBillDatesMap = new Map<Id,Set<String>> ();
        //Map<Id,Id> mapOrderOptyOwner = new Map<Id,Id>(); //<T01>
        /*<T02>
        Map<Id,Id> mapOrderAccOwner = new Map<Id,Id>(); // The Account Owner will be Territory Manager
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        String financeUsers ='';
        //<T01> starts       
        Map<Id,Id> mapAccOwnerManagerId = new Map<Id,Id>();         
          //<T01> ends
          
        List<CollaborationGroupMember> financeGroupUsers = [SELECT Id,MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId IN (SELECT Id FROM CollaborationGroup WHERE Name = 'Finance Users')];
        for(CollaborationGroupMember member:financeGroupUsers){
            financeUsers += '{'+String.valueOf(member.MemberId)+'}';
        }<T02>*/
        
        for(Order o : scope)
            orderIds.add(o.Id);

        //To get the Invoice Group and Invoice Group Date Associated to the Order Product
        for(OrderItem oli:[SELECT Id,blng__NextBillingDate__c,blng__OverrideNextBillingDate__c,Invoice_Group__c,OrderId,Order.Opportunity.OwnerId,Order.Account.OwnerId,Order.Opportunity.Owner.ManagerId,Order.Account.Owner.ManagerId, Purchase_Order_PO_Number__c,Order.Account.PO_Required__c FROM OrderItem
                       WHERE OrderId =: orderIds /*AND (blng__NextBillingDate__c = TODAY OR blng__OverrideNextBillingDate__c = TODAY
                       OR blng__NextBillingDate__c = : nextSixtyDays OR blng__OverrideNextBillingDate__c = : nextSixtyDays 
                       OR blng__NextBillingDate__c = : nextThirtyDays OR blng__OverrideNextBillingDate__c = : nextThirtyDays 
                       OR blng__NextBillingDate__c = NEXT_N_DAYS:5 OR blng__OverrideNextBillingDate__c = NEXT_N_DAYS:5
                       )*/]){
            setInvoiceGroupIds.add(oli.Invoice_Group__c);
            //mapOrderOptyOwner.put(oli.OrderId,oli.Order.Opportunity.OwnerId);//<T01>          
            /*<T02>
            mapOrderAccOwner.put(oli.OrderId,oli.Order.Account.OwnerId);  
            //<T01> starts
            if(!(oli.blng__NextBillingDate__c == nextSixtyDays || oli.blng__OverrideNextBillingDate__c == nextSixtyDays))
            {mapAccOwnerManagerId.put(oli.OrderId,oli.Order.Account.Owner.ManagerId);     }<T02>*/
             //<T01>  ends                
            oiListQuery.add(oli);
        }
       
        orderIds = new Set<Id> ();
        Map<Id,Invoice_Group__c> mapInvoiceGroup = new Map<Id,Invoice_Group__c>([SELECT Id,Name,(SELECT Id,Invoices_Created_Within_End_Date__c,Invoices_Created_Within_Start_Date__c,PO_Number__c FROM Invoice_Group_Dates__r) FROM Invoice_Group__c WHERE Id IN :setInvoiceGroupIds]);
        
        //Updating the PO Number on Order Product
        for(OrderItem oli:oiListQuery)
        {
             
             if(!mapInvoiceGroup.isEmpty())
                 lstInvoiceGroupDate = mapInvoiceGroup.get(oli.Invoice_Group__c).Invoice_Group_Dates__r;
                 system.debug(lstInvoiceGroupDate);
             //Copy the PO Number from the appropriate IGD record to the Order Line Item
                if(!lstInvoiceGroupDate.isEmpty())
                { 
                    for(Invoice_Group_Date__c igd:lstInvoiceGroupDate)
                    {
                           if(oli.blng__OverrideNextBillingDate__c != null && (oli.blng__OverrideNextBillingDate__c >= igd.Invoices_Created_Within_Start_Date__c && oli.blng__OverrideNextBillingDate__c <= igd.Invoices_Created_Within_End_Date__c))
                            {
                                //oli.Purchase_Order_PO_Number__c = (oli.Purchase_Order_PO_Number__c != null && System.today().daysBetween(oli.blng__OverrideNextBillingDate__c) <= 31 && (oli.Purchase_Order_PO_Number__c == igd.PO_Number__c || igd.PO_Number__c == null)) ? oli.Purchase_Order_PO_Number__c : igd.PO_Number__c;
                                oli.Purchase_Order_PO_Number__c = oli.Purchase_Order_PO_Number__c != igd.PO_Number__c ? igd.PO_Number__c : oli.Purchase_Order_PO_Number__c;
                                lstOrderItemToUpdate.add(oli);
                                break;
                            }
                            if(oli.blng__NextBillingDate__c != null && oli.blng__OverrideNextBillingDate__c == null && (oli.blng__NextBillingDate__c >= igd.Invoices_Created_Within_Start_Date__c && oli.blng__NextBillingDate__c <= igd.Invoices_Created_Within_End_Date__c))
                            {
                                //oli.Purchase_Order_PO_Number__c = (oli.Purchase_Order_PO_Number__c != null && System.today().daysBetween(oli.blng__NextBillingDate__c) <= 31 && (oli.Purchase_Order_PO_Number__c == igd.PO_Number__c || igd.PO_Number__c == null)) ? oli.Purchase_Order_PO_Number__c : igd.PO_Number__c;
                                oli.Purchase_Order_PO_Number__c = oli.Purchase_Order_PO_Number__c != igd.PO_Number__c ? igd.PO_Number__c : oli.Purchase_Order_PO_Number__c;
                                lstOrderItemToUpdate.add(oli);
                                break;
                            }
                    }
                }
            
             }
            //Creating a map of OrderId,Invoice Group and Invoice Group Date to be used for Chatter Notification purpose
           /*<T02>
            if(oli.Order.Account.PO_Required__c)
            {
                if(oli.Purchase_Order_PO_Number__c == null && (oli.blng__NextBillingDate__c != null || oli.blng__OverrideNextBillingDate__c != null))
                    orderIds.add(oli.orderId);
                String datetoPrint = oli.blng__OverrideNextBillingDate__c != null ? oli.blng__OverrideNextBillingDate__c.format() : oli.blng__NextBillingDate__c.format();
                if(nextBillDatesMap.get(oli.orderId) != null)
                    nextBillDatesMap.get(oli.orderId).add(datetoPrint);
                else
                    nextBillDatesMap.put(oli.orderId,new Set<String>{datetoPrint});
            }
       
        
        //For Chatter Post
        Map<Id,String> mapObjIdtoMsg=new Map<Id,String>();
        for(Id orderId : orderIds){
            String msg = Label.PONumber_Message + '\n' + '\n' ;
            msg = nextBillDatesMap.get(orderId) != null ? msg + 'Next Billing Date(s) [in MM/DD/YYYY] : ' + nextBillDatesMap.get(orderId) + '\n' + '\n' : msg;
          
            // String mentions = financeUsers+ '{'+String.valueOf(mapOrderOptyOwner.get(orderId))+'}';//<T01>         
           //if(mapOrderOptyOwner.get(orderId) != mapOrderAccOwner.get(orderId))//<T01>
           // { mentions = mentions + '{'+String.valueOf(mapOrderAccOwner.get(orderId))+'}';}//<T01> 
             //<T01> starts
             String mentions = financeUsers+ '{'+String.valueOf(mapOrderAccOwner.get(orderId))+'}'; 
            if(mapAccOwnerManagerId.get(orderId) != null)
            {
              { mentions = mentions + '{'+String.valueOf(mapAccOwnerManagerId.get(orderId))+'}';}
            }
            //<T01> ends                 
             
            msg += mentions;
            mapObjIdtoMsg.put(orderId,msg);
        }

        for(Id objId:mapObjIdtoMsg.keySet()){
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = objId;                
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();                
            body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(mapObjIdtoMsg.get(objId));                   
            input.body = body;
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);                        
        }<T02>*/

        if(!lstOrderItemToUpdate.isEmpty())
        {
            update lstOrderItemToUpdate;
        }
        /*<T02>if(!Test.isRunningTest() &&  batchInputs!=null && batchInputs.size()>0)
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);<T02>*/
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
}