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
S. Chouhan   | 01-03-2021   |     NA         |  Update milestone object field value from |				 |
			 |  		    |         	     |	Opportunity Product field value          |			     |
Ranjan 		 | 07-June-2021 |	  NA         |  changed method return type from void to  |	PSA-1676	 | <T01>
			 |				|				 |	string to throw message in UI            |               |

************************************************************************************************************************
*/
global with sharing class psa_MilestoneController {
    @AuraEnabled
    public static List<OpportunityLineItem> getOpptyProducts(String milestoneId){
        Set<Id> setOpptyLineItemId = new Set<Id>();
        
        pse__Milestone__c milestone = [Select Id, pse__Project__c, pse__Project__r.pse__Opportunity__c From pse__Milestone__c 
                                       Where Id = :milestoneId];
        
        Set<Id> setOpptyId = new Set<Id>(new Map<Id, Opportunity>([Select Id From Opportunity 
                                                                   Where pse__Primary_Project__c = :milestone.pse__Project__c OR PSA_OM_Primary_Project__c = :milestone.pse__Project__c]).keyset());
        setOpptyId.add(milestone.pse__Project__r.pse__Opportunity__c);
        
        List<psa_Oppty_Product_Selection_Field__mdt> lstOpptyProductFields = [Select Id,Field_Label__c, Field_Name__c, Links_To__c From psa_Oppty_Product_Selection_Field__mdt];
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
        
        List<OpportunityLineItem> lstOpptyLineItem = Database.query(soql);
        return lstOpptyLineItem;
    }
    
    @AuraEnabled
    public static List<psa_Oppty_Product_Selection_Field__mdt> getOpptyProductSelectionFields(){
        return [Select Id, Field_Label__c, Field_Name__c, Links_To__c, Sort_Order__c 
                From psa_Oppty_Product_Selection_Field__mdt 
                Order By Sort_Order__c];
    }
    
    @AuraEnabled
    public static String setOpptyProduct(String milestoneId, String opptyProductId){
        
        String message;
        
        OpportunityLineItem opptyLineItem = [Select Id,PSA_Quantity__c, Name, Purchase_Order_PO_Number__c, ListPrice, 
                                             TotalPrice From OpportunityLineItem Where Id = :opptyProductId]; 
        
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.Id = milestoneId;
        milestone.PSA_Opportunity_Product__c = opptyProductId;
        milestone.PSA_OM_Opportunity_Product_Id__c = opptyProductId;
        milestone.PSA_OM_Opportunity_Product_List_Price__c = opptyLineItem.ListPrice;
        milestone.PSA_OM_Opportunity_Product_Total_Price__c = opptyLineItem.TotalPrice;
        milestone.PSA_OM_PO_Number__c = opptyLineItem.Purchase_Order_PO_Number__c;
        milestone.PSA_Quantity__c =  opptyLineItem.PSA_Quantity__c;
        try{
            update milestone;   
            message = 'Success:Opportunity Product is associated to the Milestone successfully.';
        }catch(exception e){
            message = 'Error:'+e.getMessage();
        }
        
        return message; // <T01>
    }
}