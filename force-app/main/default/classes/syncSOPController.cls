/*
Class:          syncSOPController

@Author:        Thejaswini Sattenapalli
@Created Date:  3 August,2017
@Description:   Global class for Sync SOP javaScript button on opportunity
 */
/*
Change History
 ******************************************************************
ModifiedBy          Date        Requested By        Description      
Rupanjana Mitra     11/20/17    Anil Solanki    Added check to calculate unit 
                                                price if either of fields: 
                                                New SOP ACV, Renewal SOP ACV, Upsell SOP is not null

 ******************************************************************
 */
global class syncSOPController {

    public static globalApexManager GAM = new globalApexManager();

    /* this method will recive Opp. Id and update the Order Product field on opportunity Line items, based on Quote Line field. 
     * @param parameter- oppId - Current[context] Opportunity Id
     * @return return- String,return the status of Sync
     * @throws exception- try/catch
     */
    webservice static String syncSOP(String oppId){
        String sResult = Label.Success_Message_Sync;

        try{  
            // create a set of QuoteLine Items Lookup on opportunityLineItems
            set<String> setOfQuoteLine = new set<String>();
            // Create Opportunity Variable    
            Opportunity oOpportunity ;

            //new check where If split opp currency code is different from primary opp currency code, throw error - START
            Opportunity prOpp = [SELECT Id, CurrencyIsoCode, Split_From__c, Split_From__r.Id, Split_From__r.CurrencyIsoCode FROM Opportunity WHERE Id =:oppId];
            //If primary opp
            if(null == prOpp.Split_From__c || prOpp.Id == prOpp.Split_From__r.Id)
            {
                //Fetch corresponding split opp
                List<Opportunity> splitOppList = [SELECT Id, CurrencyIsoCode FROM Opportunity WHERE Split_From__r.Id =:oppId limit 1];
                if(null == splitOppList || splitOppList.size()==0)
                {
                    sResult = Label.Error_Message_No_Split_Opp;
                    return sResult;
                }
                else{
                    Opportunity splitOpp = splitOppList[0];
                    if(null != splitOpp.CurrencyIsoCode && null != prOpp.CurrencyIsoCode && splitOpp.CurrencyIsoCode != prOpp.CurrencyIsoCode)
                    {
                        sResult = Label.Error_Message_Curreny_Code_Mismatch;
                        return sResult;
                    }
                }
            }
            //if split opp
            else if(null != prOpp.Split_From__c && null != prOpp.Split_From__r.CurrencyIsoCode && null != prOpp.CurrencyIsoCode && prOpp.CurrencyIsoCode != prOpp.Split_From__r.CurrencyIsoCode)
            {
                sResult = Label.Error_Message_Curreny_Code_Mismatch;
                return sResult;
            }
            //new check - END

            // play a for loop on Opportunity and query Opportunity with there line items  
            for(opportunity opp: [Select id,Split_Percentage__c,CurrencyIsoCode, Split_From__c, Split_From__r.CurrencyIsoCode,(Select id,Name,Order_Product__c,SBQQ__QuoteLine__c,UnitPrice
                    From opportunityLineItems)
                                  From Opportunity where Id =: oppId]){

                //set the oOpportunity variable with Contaxt Opportunity   
                oOpportunity = opp; 
                // play a for loop on opportunityLineItem and add the SBQQ__QuoteLine__c to the set
                for(opportunityLineItem OLI : oOpportunity.opportunityLineItems){
                    if(OLI.SBQQ__QuoteLine__c != null){
                        setOfQuoteLine.add(OLI.SBQQ__QuoteLine__c);                            
                    }else{
                        sResult = Label.Error_Message_Quote_Line_Item_Missing + OLI.Name;    
                        return sResult;
                    }   

                }                                   
            }
            // check if 'setOfQuoteLine' set size equal to 0, it's mean 'SBQQ__QuoteLine__c' field is null,
            // then set the error msg and return the error masssage  
            if(setOfQuoteLine.size() == 0){
                sResult = Label.Error_Message_Quote_Line_Item_Missing;    
                return sResult;
            }
            // create a map of String [QuoteLine lookup Id] and OrderItem.
            map<String,OrderItem> mapQuoteWiseOrderItem = new map<String,OrderItem>();

            // Play a for loop on OrderItem where SBQQ__QuoteLine__c In set "setOfQuoteLine" 
            // And put the key and value in above Map  
            //Added check to calculate unit price if new SOP ACV is not null OR renewal SOP ACV is not null or Upsell SOP is not Null
            for(OrderItem OI : [Select id,SBQQ__QuoteLine__c,Statement_of_Position_SOP_Amount__c,New_Statement_of_Position_SOP_ACV__c,Renewal_Statement_of_Position_SOP_ACV__c,Upsell_Statement_of_Position_SOP_ACV__c from OrderItem where SBQQ__QuoteLine__c IN:setOfQuoteLine]){
                mapQuoteWiseOrderItem.put(OI.SBQQ__QuoteLine__c, OI);
            }

            // Create a list of OpportunityLineItem for update  
            List<opportunityLineItem> lstOLI = new  List<opportunityLineItem>();
            // play a for loop on opportunityLineItem which is store in oOpportunity variable    
            for(opportunityLineItem OLI : oOpportunity.opportunityLineItems){
                // check 'SBQQ__QuoteLine__c' field in mapQuoteWiseOrderItem map 
                if(mapQuoteWiseOrderItem.containsKey(OLI.SBQQ__QuoteLine__c)){
                    // if contains then get the OrderItem from map by using OrderLineItem Key    
                    OrderItem OI = mapQuoteWiseOrderItem.get(OLI.SBQQ__QuoteLine__c);
                    // set the 'Order_Product__c' field with OrderItem Id   
                    OLI.Order_Product__c = OI.Id;
                    // set the UnitPrice with (Split_Percentage__c * Statement_of_Position_SOP_Amount__c)  
                    //check if fields: New SOP ACV, Renewal SOP ACV, Upsell SOP is not null
                    if(null != OI.New_Statement_of_Position_SOP_ACV__c || null != OI.Renewal_Statement_of_Position_SOP_ACV__c || null != OI.Upsell_Statement_of_Position_SOP_ACV__c)
                    {
                        if(OI.New_Statement_of_Position_SOP_ACV__c == null){
                            OI.New_Statement_of_Position_SOP_ACV__c = 0;
                        }
                        
                        if(OI.Renewal_Statement_of_Position_SOP_ACV__c == null){
                            OI.Renewal_Statement_of_Position_SOP_ACV__c = 0;
                        }
                        
                        if(OI.Upsell_Statement_of_Position_SOP_ACV__c == null){
                            OI.Upsell_Statement_of_Position_SOP_ACV__c = 0;
                        }
                        OLI.UnitPrice = (oOpportunity.Split_Percentage__c * (OI.New_Statement_of_Position_SOP_ACV__c+OI.Renewal_Statement_of_Position_SOP_ACV__c+OI.Upsell_Statement_of_Position_SOP_ACV__c));
                    }
                    else if(oOpportunity.Split_Percentage__c != null && OI.Statement_of_Position_SOP_Amount__c != null)
                    {
                        OLI.UnitPrice = (oOpportunity.Split_Percentage__c * OI.Statement_of_Position_SOP_Amount__c)/100.0;
                    }
                    // add opportunityLineItem to lstOLI for update    
                    lstOLI.add(OLI);
                }                
            }
            // check the size of lstOLI if greter then 0 then update the list  
            if(lstOLI.size() > 0){
                GAM.CreateLogs('syncSOP',lstOLI,'Modified OpportunityLineItem List: ');
                update lstOLI;
            }
        }
        catch (DMLException ex){
            GAM.CreateExceptionRecords('syncSOP', ex.getMessage(), oppId);
            sResult = 'false|' + ex.getdmlMessage(0);

        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('syncSOP', ex.getMessage(), oppId);
            sResult = 'false|' + ex.getMessage();
        }
        GAM.InsertDebugLogs();
        return sResult;   
    }
}