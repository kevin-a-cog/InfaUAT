/*
    @created by       : balajip
    @created on       : 12/14/2020
    @Purpose          : 
    @Testclass        : 
    @JIRA             : 
    
Change History
************************************************************************************************************************
ModifiedBy   |   Date       | Requested By   |  Description              				 | Jira No.      | Tag
*************|**************|****************|*******************************************|***************|**************
S. Chouhan   | 01-03-2021   |     NA         | Update Resource Request object field      |				 |
			 |  		    |         	     | value from Opportunity Product field value|	             |			     
Ranjan 		 | 07-June-2021 |	  NA         | changed method return type from void to   |	PSA-1676	 | <T01>
			 |				|				 | string to throw message in UI             |               |
Vivek Warrier| 28-Feb-2022  |     NA         | Update the Requested Bill Rate on the RR  |
             |              |                | if the Milestone is not associated to a   |  PSA-2276     | <T02>
             |              |                | Fixed-fee Project
************************************************************************************************************************
*/   

global with sharing class psa_ResourceRequestController {
    @AuraEnabled
    public static List<OpportunityLineItem> getOpptyProducts(String resourceRequestId){
        System.debug('==resourceRequestId=='+resourceRequestId);
        Set<Id> setOpptyLineItemId = new Set<Id>();

        pse__Resource_Request__c resourceRequest = [Select Id, pse__Project__c, pse__Project__r.pse__Opportunity__c From pse__Resource_Request__c 
                                                        Where Id = :resourceRequestId];
        
        Set<Id> setOpptyId = new Set<Id>(new Map<Id, Opportunity>([Select Id From Opportunity 
                                                                    Where pse__Primary_Project__c = :resourceRequest.pse__Project__c OR PSA_OM_Primary_Project__c = :resourceRequest.pse__Project__c]).keyset());
        setOpptyId.add(resourceRequest.pse__Project__r.pse__Opportunity__c);

        List<psa_Oppty_Product_Selection_Field__mdt> lstOpptyProductFields = [Select Id, Field_Label__c, Field_Name__c, Links_To__c From psa_Oppty_Product_Selection_Field__mdt];
        String fields = '';
        for (psa_Oppty_Product_Selection_Field__mdt opptyProductField : lstOpptyProductFields){
            fields += opptyProductField.Field_Name__c + ', ';
            if(!String.isEmpty(opptyProductField.Links_To__c)){
                fields += opptyProductField.Links_To__c + ', ';
            }
        }
        fields = fields.left(fields.length()-2);

        Set<String> setOfferingType = new Set<String>{'Professional Services', 'Education Services'};

        String soql = 'Select Id,CurrencyIsoCode, ' + fields;
        soql += ' From OpportunityLineItem';
        soql += ' Where OpportunityId in :setOpptyId'; 
        soql += ' And PricebookEntry.Product2.Offering_Type__c in :setOfferingType';

        System.debug('==soql=='+soql);
        List<OpportunityLineItem> lstOpptyLineItem = Database.query(soql);
        System.debug('==lstOpptyLineItem=='+lstOpptyLineItem);
        return lstOpptyLineItem;
    }

    @AuraEnabled
    public static List<psa_Oppty_Product_Selection_Field__mdt> getOpptyProductSelectionFields(){
        return [Select Id, Field_Label__c, Field_Name__c, Links_To__c, Sort_Order__c 
                    From psa_Oppty_Product_Selection_Field__mdt 
                    Order By Sort_Order__c];
    }

    @AuraEnabled
    public static String setOpptyProduct(String resourceRequestId, String opptyProductId){

        String message;
        OpportunityLineItem opptyLineItem = [SELECT Id, PSA_Quantity__c, Purchase_Order_PO_Number__c, ListPrice, 
                                            TotalPrice, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__NetPrice__c
                                            FROM OpportunityLineItem
                                            WHERE Id = :opptyProductId]; 

        pse__Resource_Request__c resourceRequest = [SELECT Id, PSA_Opportunity_Product__c, PSA_OM_Opportunity_Product_Id__c, PSA_OM_Opportunity_Product_List_Price__c, 
                                                    PSA_OM_Opportunity_Product_Total_Price__c, PSA_OM_PO_Number__c, PSA_Quantity__c,pse__Project__r.pse__Billing_Type__c, 
                                                    pse__Milestone__r.pse__Project__r.pse__Billing_Type__c, pse__Requested_Bill_Rate__c 
                                                    FROM pse__Resource_Request__c 
                                                    WHERE Id =: resourceRequestId LIMIT 1][0];//<T02>

        //pse__Resource_Request__c resourceRequest = new pse__Resource_Request__c();
        //resourceRequest.Id = resourceRequestId;
        resourceRequest.PSA_Opportunity_Product__c = opptyProductId;
        resourceRequest.PSA_OM_Opportunity_Product_Id__c = opptyProductId;
        resourceRequest.PSA_OM_Opportunity_Product_List_Price__c = opptyLineItem.SBQQ__QuoteLine__r.SBQQ__NetPrice__c;//<T02> Changing to discounted price
        resourceRequest.PSA_OM_Opportunity_Product_Total_Price__c = opptyLineItem.TotalPrice;
        resourceRequest.PSA_OM_PO_Number__c = opptyLineItem.Purchase_Order_PO_Number__c;
        resourceRequest.PSA_Quantity__c = opptyLineItem.PSA_Quantity__c;
        //<T02>
        if(resourceRequest.pse__Project__r.pse__Billing_Type__c != 'Fixed Price'){
            if(resourceRequest.pse__Milestone__c != null){
                resourceRequest.pse__Requested_Bill_Rate__c = 0.0;
            }
            else if(resourceRequest.pse__Milestone__r.pse__Project__r.pse__Billing_Type__c == 'Fixed Price'){            
                resourceRequest.pse__Requested_Bill_Rate__c = 0.0;
            }
            else{
                if(opptyLineItem.SBQQ__QuoteLine__c != null){
                    resourceRequest.pse__Requested_Bill_Rate__c = opptyLineItem.SBQQ__QuoteLine__r.SBQQ__NetPrice__c;
                }
            }
        }
        //</T02>
        
        try{
            update resourceRequest;   
            message = 'Success:Opportunity Product is associated to the Resource Request successfully.';
        }catch(exception e){
            message = 'Error:'+e.getMessage();
        }
        
        return message; // <T01>
    }
}