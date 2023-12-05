/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                                         Tag    
Nishit S                  24 JUN 2021           I2C-1267 & 1268         Finance                      Deleting Ship Date and Manual Allocation fields                                    <T01>
                                                                                                                            
********************************************************************************************************************************************************************************************************************
*/
public class revenueSchedulesController{

    @AuraEnabled
    public static List<blng__RevenueSchedule__c> getRevenueSch(String revAgrId)
    {
    return [Select Id,Name,CurrencyIsoCode,RS_Number__c,Manual_Allocation__c,Allocated_Booking__c,Allocated_Bookings__c,blng__OrderProduct__c,blng__OrderProduct__r.OrderItemNumber,blng__RevenueEndDate__c,blng__RevenueStartDate__c,blng__TotalRevenueAmount__c,Deferred_Revenue_Acct_Date__c,Term__c,Revenue_Category__c,
    Extended_List_Price__c,Parent_RS__c,Product__c,Product__r.Name,Quantity__c,RMCS_Contract_Line_Number__c,Sent_to_RMCS__c,Ship_Date__c,Order_Number__c,blng__OrderProduct__r.PeopleSoft_Extended_List_Price__c,Status__c,Revenue_Agreement__r.Stage__c from blng__RevenueSchedule__c where Revenue_Agreement__c =: revAgrId AND Status__c =: 'Active' ORDER BY RS_Number__c ASC];
    }
    
    @AuraEnabled
    public static String currentUser()
    {
        String userType = 'User';
        if(FeatureManagement.checkPermission('CustomInvoicingCreate')) 
            userType = 'Finance';
        
        return userType;
    }
    
    @AuraEnabled
    public static String updateRevenueSch(String revAgrId,String lstRevenueSchedules)
    {
    system.debug('Inside Apex Class_Entered');
    system.debug(lstRevenueSchedules);
    List<blng__RevenueSchedule__c> listRevSchList = (List<blng__RevenueSchedule__c>)System.JSON.deserialize(lstRevenueSchedules, List<blng__RevenueSchedule__c>.class);
    system.debug(listRevSchList);  
    try 
    { 
        SBQQ.TriggerControl.disable();
        update listRevSchList;
        SBQQ.TriggerControl.enable();
        
    }
    catch(exception e)
    {
        throw new AuraHandledException(e.getMessage());
    }
       
       return revAgrId;
    }
}