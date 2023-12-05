/****************************************************************************************************************************
 *  @Class Name: LinkToPreviousOrderController
 *  @Author: Anil
 *  @Date: 30 Oct 2019
 *  @Description: Controller class to LinkToPreviousOrder Page . 
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/

public with sharing class LinkToPreviousOrderController {
Public List<Previous_Order__c> PreviousOrderListToInsert;
Public List<Previous_Order__c> PreviousOrderList{get;set;}
Public static Integer SizeofList =Integer.ValueOf(Label.Previous_Order_Page_Size);
Public Id OrderId =  apexpages.currentpage().getparameters().get('id');
public static globalApexManager GAM = new globalApexManager();
   

    Public LinkToPreviousOrderController(ApexPages.StandardController controller) {
           
        PreviousOrderList = new List<Previous_Order__c>();
         
        for(Integer i=0; i<SizeofList; i++){
            Previous_Order__c cs = new Previous_Order__c();
                PreviousOrderList.add(cs);
        }       
    }
    
    /**
    * this method creates previous Order records based on selection on LinkToPreviousOrder Page
    * @param parameter- 
    * @param parameter- 
    * @return return- PageReference to Order
    * @throws exception-captures exception in a debug log
    */
    Public pagereference SaveOrderRecords(){
    
      PreviousOrderListToInsert = new List<Previous_Order__c>(); 
      
        if(PreviousOrderList!= null && PreviousOrderList.size()>0){
            for(Previous_Order__c cn: PreviousOrderList){
                     if(cn.Previour_Order_CPQ__c != null && cn.Previous_Order_Apttus__c!= null){
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select Cpq Order and Apttus Order in separate row'));
                         return null;
                     }
                     if(cn.Previour_Order_CPQ__c!= null || cn.Previous_Order_Apttus__c!= null || cn.Previous_Order_Date__c!=null || cn.Previous_Order_Notes__c!=null){
                        cn.Order__c = OrderId;
                        PreviousOrderListToInsert.add(cn);
               }
               
            }
        }
        
        if(PreviousOrderListToInsert!= null && PreviousOrderListToInsert.size()>0){
            try{
                insert PreviousOrderListToInsert ;
            }
            Catch(Exception e){
                  GAM.CreateExceptionRecords('SaveOrderRecords', e.GetMessage(),OrderId);
                  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
 
                
            }
        }
        return new PageReference('/' + OrderId);   
    }
}