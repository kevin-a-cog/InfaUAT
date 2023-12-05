/*
Class:          CheckMaterialRights
@Author:        Nishit Sardessai
@Created Date:  7 AUG 2022 
@Description:   handler class for SBQQ__Quote__c triggers
*/
/*
Change History
*****************************************************************************************************************************************
ModifiedBy          Date        Ticket No.          Requested By        	  Description                                                 								Tag
Nishit S    07 AUG 2022      I2C-1626            Aug 2022 Build               Material Rights Future Renewals Pricing - Alert Notification                             	<I2C-1626>     
Nishit S	19 SEP 2022		 I2C-1718			 Oct 2022 Build				  License Lines with 0$ should be excluded for Material Rights-Alert Notification		   	<I2C-1718>
*****************************************************************************************************************************************
*/public class CheckMaterialRights {
    public static globalApexManager GAM = new globalApexManager();
    public static boolean futureRun = false;
    
    @invocableMethod(label='Check Material Rights')
    public static List<String> checkmaterialRightsMethod(List<String> recordIdList){
        futureRun = true;
        List<String> returnList;
        //Map<String, List<SBQQ__QuoteLine__c> categoryQLMap = new Map<String, List<SBQQ__QuoteLine__c>();
        Map<String, Double> categoryELPMap = new Map<String, Double>(); //Map for Category -> Extended List Price
        Map<String, Double> categoryNetPriceMap = new Map<String, Double>();
        Map<String, Double> categoryDiscountMap = new Map<String, Double>(); 
        Set<String> revenueCategories = new Set<String>();
        Boolean materialRightsApplicable = false;
        Double totalListPrice = 0.0;
        Map<String,String> materialRightsMap = new  Map<String,String> ();
        String revCat;
        
        for(String str : Label.MaterialRights.split(';'))
        {
            materialRightsMap.put(str.split(':') [0],str.split(':') [1]);
        }
        

        for(SBQQ__QuoteLine__c quoteLine : [SELECT SBQQ__Product__r.Amoritization_Schedule__c, PeopleSoft_Extended_List_Price__c, SBQQ__NetPrice__c, SBQQ__RegularTotal__c,SBQQ__NetTotal__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recordIdList[0] AND SBQQ__Product__r.Amoritization_Schedule__c =: materialRightsMap.keySet()
                                           AND (NOT(SBQQ__Quote__r.SBQQ__Type__c ='Renewal' AND SBQQ__Product__r.CPQ_Product_Type__c  = 'Perpetual' and SBQQ__RenewedSubscription__c != NULL))]){ //I2C-1718 Added the AND NOT to exclude 0$ licenses
                revCat = materialRightsMap.get(quoteLine.SBQQ__Product__r.Amoritization_Schedule__c);
                categoryELPMap.put(revCat, (categoryELPMap.get(revCat) != NULL ? categoryELPMap.get(revCat) : 0) + quoteLine.SBQQ__RegularTotal__c);
                categoryNetPriceMap.put(revCat, (categoryNetPriceMap.get(revCat) != NULL ? categoryNetPriceMap.get(revCat) : 0) + quoteLine.SBQQ__NetTotal__c);
                totalListPrice += quoteLine.SBQQ__RegularTotal__c;
        }
        
        for(String revCategory : categoryELPMap.keySet())
        {
            if(categoryELPMap.get(revCategory) != NULL)
                categoryDiscountMap.put(revCategory, (categoryELPMap.get(revCategory) == 0 ? 0 : 100 * (1 - categoryNetPriceMap.get(revCategory) / categoryELPMap.get(revCategory))));
        }
        
        
        for(Material_Rights_Category__mdt materialRightsTable : [SELECT Label, Revenue_Category__c, List_Price_Tier_Minimum__c, List_Price_Tier_Maximum__c,
                                                                 Discount__c FROM Material_Rights_Category__mdt where isActive__c = true AND Revenue_Category__c IN :categoryELPMap.keySet()
                                                                 ORDER BY Revenue_Category__c]){
                                                                     for(String category : categoryDiscountMap.keySet())
                                                                     {
                                                                         if(materialRightsTable.Revenue_Category__c == category)
                                                                         {
                                                                             if(totalListPrice > materialRightsTable.List_Price_Tier_Minimum__c && totalListPrice <= materialRightsTable.List_Price_Tier_Maximum__c){
                                                                                 if(categoryDiscountMap.get(category) > materialRightsTable.Discount__c)
                                                                                     materialRightsApplicable = true;
                                                                             }
                                                                         }
                                                                         
                                                                         
                                                                     }
                                                                 }
        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = recordIdList[0]);         
        if(materialRightsApplicable){
            quote.Material_Rights_Applicable__c = 'Yes';
            returnList =  new List<String>{'Material Rights are Applicable for the Quote'};
                }
        else{
            quote.Material_Rights_Applicable__c = 'Checked';
            returnList = new List<String>{'Material Rights are Not Applicable for the Quote'};
                }
        SBQQ.TriggerControl.disable();
        update quote;
        SBQQ.TriggerControl.enable();
        return returnList;
        
    }
    @future
    public static void checkmaterialRightsFuture(List<String> quoteIdList){
        try{
            checkmaterialRightsMethod(quoteIdList);
        }
        catch(Exception ex){
            GAM.CreateLogs('CheckMaterialRights.checkmaterialRightsFuture', ex.getStackTraceString());
        }
    }
}