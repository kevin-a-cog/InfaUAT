/****************************************************************************************************************
Class:          notesForFullfillmentline
@Author:        chandana gowda
@Created Date:  9/4/2019.
@Description:   Class for consolidating the PDS of all the products associated with the fullfillment Line
******************************************************************************************************************
Change History 
  
*******************************************************************************************************************/
public with sharing class notesForFullfillmentlineQueueable implements Queueable{

    public List<Id> relatedfflineIdList;

    public notesForFullfillmentlineQueueable(List<Id> relatedfflineIdList){
      this.relatedfflineIdList=relatedfflineIdList;
    }

    public void execute(QueueableContext context){
      List<Related_Fulfillment_Line__c> relatedfflineList=[Select Id,Order_Product__c,Fullfillment_Line__c from Related_Fulfillment_Line__c where Id in :relatedfflineIdList];
      List<Id> orderProductIdList=new List<Id>();
      Map<Id,List<Id>> mapFfillmentlinesToOrderproducts = new Map<Id,List<Id>>();
      
      //Creating a map fullfillment lines and order products
      for(Related_Fulfillment_Line__c relatedffline:relatedfflineList){
        if(!orderProductIdList.contains(relatedffline.Order_Product__c)){
          orderProductIdList.add(relatedffline.Order_Product__c);
        }
        if(relatedffline.Fullfillment_Line__c!= NULL && mapFfillmentlinesToOrderproducts.keySet().contains(relatedffline.Fullfillment_Line__c)){
          List<Id> orderProducts = mapFfillmentlinesToOrderproducts.get(relatedffline.Fullfillment_Line__c);
          orderProducts.add(relatedffline.Order_Product__c);
          mapFfillmentlinesToOrderproducts.put(relatedffline.Fullfillment_Line__c, orderProducts);
        }
        else if(relatedffline.Fullfillment_Line__c!= NULL){
          mapFfillmentlinesToOrderproducts.put(relatedffline.Fullfillment_Line__c, new List<Id>{relatedffline.Order_Product__c});
        }
      }
      
      Map<Id,OrderItem> mapIdtoOrderProduct=new Map<Id,OrderItem>([Select Id,Product2Id,product2.Name,product2.Product_Description_Schedule_Text__c from OrderItem where Id in : orderProductIdList ]);
      
      //for adding notes
      List<ContentNote> nte = new List<ContentNote>();
      List<ContentDocumentLink> lnk = new List<ContentDocumentLink>();
      for(Id FulfillmentLine:mapFfillmentlinesToOrderproducts.keySet()){
        String notesBody='';
        for(Id orderProductId:mapFfillmentlinesToOrderproducts.get(FulfillmentLine)){
          notesBody +='<p style="text-align: justify;"><b style="font-family: Arial, sans-serif; font-size: 9pt;"><i><u>'+mapIdtoOrderProduct.get(orderProductId).getSobject('product2').get('Name')+'</u></i></b></p>';
          notesBody +=mapIdtoOrderProduct.get(orderProductId).getSobject('product2').get('Product_Description_Schedule_Text__c')+'<br/>';          
        }
        ContentNote cnt=new ContentNote();
        cnt.Title=(String)FulfillmentLine;
        cnt.Content=Blob.valueOf(notesBody.unescapeHtml4());
        nte.add(cnt);     
      }
      //insert the content notes with title as fullfillment line Id
      Database.insert(nte);
      // [REVIEW] This query is is not required.   
      //List<contentNote> lstContentNote=[Select Id,Title from contentNote where title in:mapFfillmentlinesToOrderproducts.keySet()];

      for(ContentNote cnt:nte){
        ContentDocumentLink clnk = new ContentDocumentLink();
        clnk.LinkedEntityId = cnt.Title;
        clnk.ContentDocumentId = cnt.Id;
        clnk.ShareType = 'V';
        lnk.add(clnk);       
      }
      //Inserting the content document Link
      Database.insert(lnk);

      for(ContentNote cnt:nte){
        cnt.title='Product Description Schedule (PDS)';
      }
      
      Database.update(nte);
    }
}