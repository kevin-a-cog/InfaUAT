/****************************************************************************************************************
Class:          InterlockInvokableProductsRollup 
@Author:        vsabbella 
@Created Date:  04/25/2018.
@Description:   Rollup Products to Related Opportunity Plan

******************************************************************************************************************
*/
public class InterlockInvokableProductsRollup {
    
 //   InterlockInvokableProductsRollup.invokeAction
 @InvocableMethod(label='Interlock Products rollup' description='Rolls up Engagement products to Interlock.')
  public static void invokeAction(List<ID> ids) {
    rollUpProducts(ids);
    //Add other methods here.  
  }
    
    public static void rollUpProducts(List<ID> ids){
    globalApexManager GAM = new globalApexManager();
    List<String> productNames = new List<String>();
      for(List<Related_Opportunity_Plan__c> ropList: [Select Id,name,
                                                      (select id,name,Product_Name__c from Engagement_Products__r) 
                                                      from Related_Opportunity_Plan__c where Id in :ids ])
      {
          //System.assert(false, 'From for .....');  
          for(Related_Opportunity_Plan__c rop:ropList){
              List<SObject> associatedProducts = rop.getSobjects('Engagement_Products__r');
              String products = '';
              if(associatedProducts!=null){
                  for(SObject sobj:associatedProducts){
                  products+=sobj.get('Product_Name__c')+';';
                 }
              }
              
              rop.put(Schema.Related_Opportunity_Plan__c.Description.Products__c,products);
            }
          
          try{
              List<Database.SaveResult> sr =  Database.update(ropList,false);
          } 
          catch(Exception Ex){
                GAM.CreateExceptionRecords('EngagementProductInvokableRollup ', 'Exception in EngagementProductInvokableRollup',ex.getMessage()); 
          }
          GAM.InsertDebugLogs();
             
      }
    return;
    }  

}