/****************************************************************************************************************************
 *  @Class Name: PRMProductTableController
 *  @Author: Puneet
 *  @Date: 
 *  @Description:This is a used as controller for visualforce components to send email.
 *****************************************************************************************************************************
ChangeHistory      
****************************************************************************************************************************/
public without sharing class PRMProductTableController {
    
    public Id engagementId{get;set;}
    public Boolean showStatusVf{get;set;}

    public PRMProductTableController() {
    }

    /**
     * @description: method to get product requests
     */
    public List<Product_Request__c> getproducts() {
        List<Product_Request__c> requests = new List<Product_Request__c>();
        List<Engagement__c> engList = 
            [SELECT Id,Name,
                (SELECT Id,Name,Product__c,Product__r.Name,Status__c 
                FROM Product_Requests__r) 
            FROM Engagement__c
            WHERE Id = :engagementId LIMIT 1];
        
        if(!engList.isEmpty()){
            requests = engList[0].Product_Requests__r;
        }
        return requests;
    }

    /**
     * @description: method to get mdm products
     */
    public List<Product_Request__c> getmdmProducts(){
     
        List<Product_Request__c> requests = getProductRequests('MDM', engagementId);
        return requests;
    }

    /**
     * @description: method to get cdgc products
     */
    public List<Product_Request__c> getcdgcProducts(){
     
        List<Product_Request__c> requests = getProductRequests('CDGC', engagementId);
        return requests;
    }

    /**
     * @description: method to get engagement record
     */
    public Engagement__c getengagement(){
        List<Engagement__c> engList = queryAndGetEngagements(engagementId);
            
            if(!engList.isEmpty()){
                return engList[0];
            }
            return null;
    }

    /**
     * @description: method to get engagement
     */
    public static List<Engagement__c> queryAndGetEngagements(Id engId){
        return [SELECT Id,Product_Request_Number__c,Requested_By_Formula__c,Requested_By__r.Email,
                    Requested_By__r.CompanyName,Requested_By__r.Name,Account__r.Name,Account__c,
                    Partner_name_if_any__c,Opportunity_Id__c,Customer_Name__c 
                FROM Engagement__c 
                WHERE Id =:engId];
    }

    /**
     * @description: method to get product requests
     */
    public static List<Product_Request__c> getProductRequests(String familyType, Id engId){
        return [SELECT Id,Name,Product__c,Product__r.Name,Status__c,Training_Completed__c 
                FROM Product_Request__c 
                WHERE Internal_Product_Family__c = :familyType AND Engagement__c = :engId];
    }
}