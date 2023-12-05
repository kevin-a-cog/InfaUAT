/*
Class:          PriceBook_controller

@Author:        Shashank Agarwal
@Created Date:  02/13/2019
@Description:   Controller class for Clone pricebook Component
*/
/*
Change History
***********************************************************************************************************
ModifiedBy               Date        Requested By        Description                                 Tag
Anusha Kocharlakota     6/22/2019     QCA-1258          Updated the line 208,209 to call batch
RamEsh M S              6/29/2020     PNP-153           Made changes in Salesforce to process CLone and Update of PriceBook in IICS.
***********************************************************************************************************
*/

public class PriceBook_controller {
    
    public static Pricebook2 currentPricebook = new Pricebook2();
    public static Pricebook2 currentPricebook1 = new Pricebook2();
        
     /*
    Method Name : getCurrentPricebook,
    * @param PriceBookMap - Pricebook2
    * @return String
    * @throws exception - NA
    * Method to get details of Current Pricebook
  */  
    
    @AuraEnabled
    public static Pricebook2 onLoadCurrent(String priceBookId){
        currentPricebook1 = [Select Id, Name, IsActive, Description, Primary__c, IsStandard, Version__c, Sync_Status__c, End_Date__c, Start_Date__c, Multi_Currency_Master__c, Multi_Currency_Master__r.Name, Cloned_From__c from Pricebook2 Where Id = :priceBookId limit 1];
        
        system.debug('currentPricebook'+currentPricebook1);
        return currentPricebook1;
    }
    
    @AuraEnabled
    public static Pricebook2 getCurrentPriceBook(String priceBookId){
        currentPricebook = [Select Id, Name, IsActive, Description, Primary__c, IsStandard, Version__c, Sync_Status__c, End_Date__c, Start_Date__c, Multi_Currency_Master__c, Multi_Currency_Master__r.Name, Cloned_From__c from Pricebook2 Where Id = :priceBookId limit 1];
        currentPricebook.Start_Date__c = System.today();
        currentPricebook.End_Date__c = System.today().addMonths(12);
        
        
        system.debug('currentPricebook'+currentPricebook);
        return currentPricebook;
    }
    
    @AuraEnabled
    public static boolean checkPriceBookName(String newPricebook){
        
        return [Select Id,Name from Pricebook2 where Name =: newPricebook].size() > 0;
    }
    
    @AuraEnabled
    public static String refreshStandardPB(String priceBookId){
        boolean PBRefreshinSFDC = Boolean.valueOf(Label.PBRefreshinSFDC);
        PriceBook2 standardPB = new PriceBook2 (Id=priceBookId,Sync_Status__c='Update In Progress');
        standardPB.Version__c = getRefreshVersion(onLoadCurrent(priceBookId).Version__c);
        update standardPB ;
        
        /*if(PBRefreshinSFDC)
        {
            updateRefreshPriceBookBatch updatePBBatch = new updateRefreshPriceBookBatch(priceBookId,priceBookId);
            database.executebatch(updatePBBatch,500);
        }*/            
    return priceBookId;
    }
    
    @AuraEnabled
    public static List<Pricebook2> getRefreshAllPB(String priceBookId){
    
    return [Select Id,Name,IsStandard,IsActive,Primary__c,Sync_Status__c,Start_date__c,End_Date__c,Version__c,Last_Run_Summary__c from Pricebook2 where IsActive = TRUE AND Primary__c = TRUE AND Sync_Status__c =: 'Completed' ORDER BY IsStandard DESC];
    }
    
    @AuraEnabled
    public static String getCurrencyRates(String priceBookId){
    
    String message;
    Set<String> currencyStandard = new Set<String> ();
    Set<String> currencyCustom = new Set<String> ();
    for(Currency_Conversion_Rates__c CCR : [Select Id,CurrencyIsoCode,Price_Book__c,Price_Book__r.IsStandard from Currency_Conversion_Rates__c where Price_Book__c IN(select Id from Pricebook2 where IsStandard = TRUE OR Id =: priceBookId)])
    {
        if(CCR.Price_Book__r.IsStandard)
           currencyStandard.add(CCR.CurrencyIsoCode);
        else
           currencyCustom.add(CCR.CurrencyIsoCode);  
    }
    boolean containsallCurr = currencyStandard.containsAll(currencyCustom);
   
    boolean CCSize =  [Select Id from Currency_Conversion_Rates__c where Price_Book__c =: priceBookId LIMIT 1].size() > 0;
    
    boolean PBESize = [Select Id from PriceBookEntry where PriceBook2Id =: priceBookId LIMIT 1].size() > 0;
    
    if(!CCSize && !PBESize )
        message = 'There are no Currency Conversion Rates and PriceBook Entries under the PriceBook. So you cannot Clone or Refresh this PriceBook.';
    if(!CCSize && PBESize )
        message = 'There are no Currency Conversion Rates under the PriceBook. So you cannot Clone or Refresh this PriceBook.';
    if(CCSize && !PBESize )
        message = 'Refresh';
    if(CCSize && PBESize )
        message = 'Clone and Refresh';
    if(!currencyStandard.containsAll(currencyCustom))
        message = 'CurrencyNotAvailable';
       
        return message;
    }
    
    @AuraEnabled
    public static boolean getPriceBookEntries(String priceBookId){
    
    return [Select Id from PriceBookEntry where PriceBook2Id =: priceBookId LIMIT 1].size() > 0;
    }
    
    
    @AuraEnabled
    public static String updateAllPB(List<String> PBIds){
    
        List<Pricebook2> updatePBList = new List<Pricebook2> ();
        for(Pricebook2 PB : [Select Id,Name,Sync_Status__c,IsActive,Primary__c,Version__c from Pricebook2 where Id =: PBIds AND IsActive = TRUE AND Primary__c = TRUE AND Sync_Status__c =: 'Completed'])
        {
            PB.Sync_Status__c = 'Update In Progress';
            PB.Version__c = getRefreshVersion(PB.Version__c);
            
            updatePBList.add(PB);
        }
        try
        {
            if(updatePBList.size() > 0)
                update updatePBList;
        }
        catch(exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
        return currentPricebook1.Id;
    
    }
    
    /*
    Method Name : getPricebookUplifts,
    * @param Pricebook - record id
    * @return PricebookUplift list
    * @throws exception - NA
    * Method to get all Pricebook uplifts of Current Pricebook
  */  
    @AuraEnabled
    public static List<Pricebook_Uplift__c> getPricebookUplifts(String priceBookId){
        List<Pricebook_Uplift__c> pricebookUpliftsList = [Select Id, Delivery_Method__c, Percentage__c, Product_Family__c, Processing_Engine__c, Pricing_Business_Model__c, Round_up_To__c, Family__c, Forecast_Product__c,Priority__c from Pricebook_Uplift__c Where Price_Book__c =: priceBookId];
        return pricebookUpliftsList;
    }
    
    /*
    Method Name : getPage,
    * @param PriceBookMap - None
    * @return type - ProductUpliftWrapperClass: wrapper class of Product Uplift Object
    * @throws exception - NA
    * Method to build the wrapper class for the Product Uplift Object
  */  
    @AuraEnabled
    public static ProductUpliftWrapperClass getPage() {
        ProductUpliftWrapperClass productUpliftWrapper = new ProductUpliftWrapperClass();
        productUpliftWrapper.optionsMap = getFieldsMapPicklists();
        return productUpliftWrapper;
    }
    
    /*
    Method Name : getFieldsMapPicklists,
    * @param PriceBookMap - None
    * @return type - optionsMap: Map<String,Map<String,String>> map of fields and their values and labels
    * @throws exception - NA
    * Method to get fields of product Uplift
  */  
    @AuraEnabled
    public static Map<String,Map<String,String>> getFieldsMapPicklists(){
        Map<String,Map<String,String>> optionsMap = new Map<String,Map<String,String>>();  
        optionsMap.put('Product_Family__c',new Map<String,String>());
        optionsMap.put('Pricing_Business_Model__c',new Map<String,String>());
        optionsMap.put('Processing_Engine__c',new Map<String,String>());
        optionsMap.put('Delivery_Method__c' ,new Map<String, String>());
        optionsMap.put('Family__c', new Map<String, String>());
        optionsMap.put('Forecast_Product__c', new Map<String, String>());
        
        for(Schema.PicklistEntry pickListValFamily : Product2.Product_Family__c.getDescribe().getPicklistValues()){
            optionsMap.get('Product_Family__c').put(pickListValFamily.getvalue(),pickListValFamily.getlabel());
        }
        for(Schema.PicklistEntry pickListValFamily : Product2.Pricing_Business_Model__c.getDescribe().getPicklistValues()){
            optionsMap.get('Pricing_Business_Model__c').put(pickListValFamily.getvalue(),pickListValFamily.getlabel());
        }
        for(Schema.PicklistEntry pickListValFamily : Product2.Processing_Engine__c.getDescribe().getPicklistValues()){
            optionsMap.get('Processing_Engine__c').put(pickListValFamily.getvalue(),pickListValFamily.getlabel());
        }
        for(Schema.PicklistEntry pickListValFamily : Product2.Delivery_Method__c.getDescribe().getPicklistValues()){
            optionsMap.get('Delivery_Method__c').put(pickListValFamily.getvalue(),pickListValFamily.getlabel());
        }
        for(Schema.PicklistEntry pickListValFamily : Product2.Family.getDescribe().getPicklistValues()){
            optionsMap.get('Family__c').put(pickListValFamily.getvalue(),pickListValFamily.getlabel());
        }
        for(Schema.PicklistEntry pickListValFamily : Product2.Forecast_Product__c.getDescribe().getPicklistValues()){
            optionsMap.get('Forecast_Product__c').put(pickListValFamily.getvalue(),pickListValFamily.getlabel());
        }
        system.debug('optionsMap'+optionsMap);
        return optionsMap;
    }
    
    /*
    Method Name : savePricebook,
    * @param - Pricebook2 , List of Pricebook Uplift, 
    * @return type - String 
    * @throws exception - NA
    * Method to save pricebook
  */  
    @AuraEnabled
    public static String savePricebookAddPricebookUplift(Pricebook2 newPricebook, String lstPricebookUpliftString) {
        List<Pricebook_Uplift__c> listPricebookUpliftToInsert = new List<Pricebook_Uplift__c>();
        List<PriceBook2> listPriceBookUpsert = new List<PriceBook2> ();
        Id oldPricebookId = newPricebook.Id;
        Date oldDate = Date.Today();
        system.debug('***newPricebook'+newPricebook);
        String newPricebookId = '';
        try{
            if(newPricebook != null){
                
                oldDate = onLoadCurrent(oldPricebookId).Start_Date__c;
                Decimal version = Decimal.valueOf(newPricebook.Version__c);
                String newVersion = version.intValue() + 1 + '.' + '0';
                
                PriceBook2 oldPB = new PriceBook2 (Id=oldPricebookId,Sync_Status__c='Archive In Progress',Start_Date__c=newPricebook.Start_Date__c,End_Date__c=newPricebook.End_Date__c,Version__c = newVersion);
                update oldPB;
                
                newPricebook.Id = null;
                newPricebook.Cloned_From__c = oldPricebookId;
                newPricebook.Primary__c = FALSE;
                newPricebook.Sync_Status__c = 'Archive In Progress';
                newPricebook.Start_Date__c = Date.Today();
                newPricebook.End_Date__c = Date.Today().addMonths(3);
                //newPricebook.Version__c = ''; as Archived PriceBook will have last version of Primary PB
                insert newPricebook;
                
            }
            system.debug('newPricebook'+newPricebook);
            newPricebookId = savePricebookUplift(oldPricebookId, newPriceBook, lstPricebookUpliftString);
        }catch(Exception e){
            system.debug('Exception'+e.getMessage()+'\nLine number'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return newPricebookId;
    }
    
    /*
    Method Name : savePricebookUplift,
    * @param - Old Pricebook Id, New Pricebook, List of Pricebook Uplifts,
    * @return type - String
    * @throws exception - NA
    * Method to save Pricebook Uplifts
  */  
    /*********************************************************************************
    Method Name     : savePricebookUplift
    Description     : Method to save pricebook uplifts
    Return Type     : None
    Parameter       : none
    *********************************************************************************/
    @AuraEnabled
    public static String savePricebookUplift(String oldPricebookId, Pricebook2 newPricebook, String lstPricebookUpliftString) {
        String cloneType = 'insert';
        List<Pricebook_Uplift__c> listPricebookUpliftToInsert = new List<Pricebook_Uplift__c>();
        List<Pricebook_Uplift__c> listPricebookUplift = (List<Pricebook_Uplift__c>)System.JSON.deserialize(lstPricebookUpliftString, List<Pricebook_Uplift__c>.class);
        List<Pricebook_Uplift__c> listPricebookUpliftDelete = new List<Pricebook_Uplift__c>();
        List<Pricebook_Uplift__c> listExistingPricebookUplift = [Select Id, Delivery_Method__c, Family__c, Forecast_Product__c, Pricing_Business_Model__c, Product_Family__c, Processing_Engine__c from Pricebook_uplift__c Where Price_Book__c =: oldPricebookId];
        try{
            if(newPricebook != null){
                
                newPricebook.Sync_Status__c = newPricebook.Sync_Status__c != 'Archive In Progress' ? 'Update In Progress' : newPricebook.Sync_Status__c;
                newPricebook.Version__c = newPricebook.Sync_Status__c != 'Archive In Progress' ? getRefreshVersion(newPricebook.Version__c) : newPricebook.Version__c;
                
                update newPriceBook;
            }
            for(Pricebook_Uplift__c pricebookUplift : listPricebookUplift){
                pricebookUplift.Price_Book__c = oldPricebookId;
                pricebookUplift.Id = null;
                listPricebookUpliftToInsert.add(pricebookUplift);
            }
            if(!listPricebookUpliftToInsert.isEmpty()){
                insert listPricebookUpliftToInsert;
            }
            if(!listExistingPricebookUplift.isEmpty()){
                delete listExistingPricebookUplift ;
            }
            boolean PBRefreshinSFDC = Boolean.valueOf(Label.PBRefreshinSFDC);
            /*if(PBRefreshinSFDC)
            {
                if(newPricebook.Sync_Status__c == 'Archive In Progress')
                {
                    clonePriceBookBatch clonePBBatch = new clonePriceBookBatch(oldPricebookId,newPricebook.Id);
                    database.executebatch(clonePBBatch,2000);
                }
                else if(newPricebook.Sync_Status__c == 'Update In Progress')
                {
                    Pricebook2 standardPB = [Select Id from Pricebook2 where IsActive = TRUE AND IsStandard = TRUE LIMIT 1];
                    updateRefreshPriceBookBatch updatePBBatch = new updateRefreshPriceBookBatch(standardPB.Id,oldPricebookId);
                    database.executebatch(updatePBBatch,500);
                }
             }*/
               
        }catch(Exception e){
            system.debug('Exception'+e.getMessage()+'\nLine number'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return newPricebook.Id;
    }
    
    /*
    Class Name : ProductUpliftWrapperClass,
    * @param PriceBookMap - None
    * @return - None
    * @throws exception - NA
    * Wrapper class for Pricebook2 and options
  */  
    public class ProductUpliftWrapperClass {
        @AuraEnabled public Pricebook2 product;
        @AuraEnabled public Map<String,Map<String,String>> optionsMap;        
    }
    
    public static String getRefreshVersion (String currVersion)
    {
        String refreshVersion;
        if(currVersion != null)
        {
            Decimal version = Decimal.valueOf(currVersion);
            //refreshVersion = version.intValue() + '.' + ((version - version.intValue()) * Math.pow(10,version.scale()) + 1).intValue();
            refreshVersion = integer.valueOf(currVersion.substringBefore('.')) + '.' + (integer.valueOf(currVersion.substringAfter('.')) + 1);
        }
        else
            refreshVersion = '1.0';
        return refreshVersion;
    }
    
}