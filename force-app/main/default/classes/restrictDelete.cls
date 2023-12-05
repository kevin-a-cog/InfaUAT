/********************************************************************************************************************************************
*        Name        :        restrictDelete
*        Author      :        RamEsh M S
*        Date        :        03 November 2020
*        Description :        Handler class for restricting Deletion of record 
*********************************************************************************************************************************************
Change History
**************************************************************************************************************************************************************
ModifiedBy                  Date               Requested By               Description                                                                  Tag
**************************************************************************************************************************************************************    
**************************************************************************************************************************************************************/      
public class restrictDelete{

  public static globalApexManager GAM = new globalApexManager();
  
  public static void restrictDeletion(String objectName, List<sObject> records)
  {
      
      if(FeatureManagement.checkPermission('SystemAdmin') || FeatureManagement.checkPermission('Support_Team') || (FeatureManagement.checkPermission('Product_Admin') && objectName != 'Product Rule' && objectName != 'Price Rule'))
      {
      
      }
      else
      {
          for(sObject obj : records)
          {
              if(!Test.IsRunningTest())
                obj.addError('You do not have permissin to delete records on ' + objectName);
          }
      }
  }
}