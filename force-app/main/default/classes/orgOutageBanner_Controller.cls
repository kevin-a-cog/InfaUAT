/*
Class:          orgOutageBanner_Controller 
@Author:        Anil Sahu  
@Created Date:  30 apl 2021
@Description:   Controller class for orgOutageBanner Lightning web component
This controller holds method for fetching the Org names for a logged-in users/customer 
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                                Tag
AnilSahu                16jun21      Story#-3035         Baneer should display based on Acc
Vignesh D               03-03-2022   I2RT-5185           Ask an Expert case should be allowed for Signature Select  T01
Vignesh D               23-09-2022   I2RT-6865           Updated method to fetch orgs for Case Lite                 T02
Vignesh D               23-09-2022   I2RT-6865           Updated Class from Without Sharing to With Sharing         T03
Vignesh D               28-04-2023   I2RT-6895           Updated method to use org entitled product junction        T04
                                                         object to fetch the orgs
************************************************************************************************************************************
*/
public with sharing class orgOutageBanner_Controller {
    
    public static globalApexManager GAM = new globalApexManager();
    
    // add the service status name 
    public static Map<String, String> mapStatusName = new Map<String, String>{
        'AWS-USAiics-app1' => 'IICS NA West 1 ServicesOperational',
        'AWS-USAiics-app2' => 'IICS NA East 2 ServicesOperational',
        'AWS-USAiics-app3' => 'IICS US West 3 ServicesOperational',
        'AWS-USAiics-app4' => 'IICS US East 4 ServicesOperational',
        'AWS-USAiics-app5' => 'IICS US West 5 ServicesOperational',
        'AWS-USAiics-app6' => 'IICS US East 6 ServicesOperational',
        'AWS-CANiics-app1' => 'IICS Canada Central 1 ServicesOperational',
        'AWS-EMEAiics-app1' => 'IICS EM West 1 ServicesOperational',
        'AWS-APACiics-app1' => 'IICS AP SouthEast 1 Services ?Operational',
        'AZU-USAiics-app1' => 'IICS US West 1 Azure ServicesOperational',
        'AZU-USAiics-app3' => 'IICS US West 3 Azure ServicesOperational',
        'AZU-APACiics-app1' => 'IICS AP NorthEast 1 Azure ServicesOperational',
        'GCP-USAiics-app1' => 'IICS US West 1 GCP ServicesOperational',
        'WIP1' => 'Data Quality & Governance Cloud ?Operational',
        'WIP2' => 'Informatica Axon Cloud ServicesOperational',
        'WIP2' => 'IICS Sandbox (PRE-RELEASE)Operational',
        'AWS-USAiics-app6' => 'Fake Test Group'
    }; 
    //bind the list with all method names    
    public static List<String> lstMethodname = new List<String>{'Hosted Multi Tenant','Hosted Single Tenant'};
                
    
    /*
    * Method to fetch the Org names for logged in customer.
    * @param Name - String objectName
    * @throws exception -n/a
    * @return list<names> list of service names
    */
    @AuraEnabled(cacheable=true)
    public static List<String> FetchOrgNames(Id accId){ //<T04>
        Set<Id> setSupportAcc = new Set<Id>(); 
        List<String> lstServNames = new List<String>();
        
        try{                                        
            if(!CaseControllerWithoutSharing.isValidUser(null, accId, ''))
                return lstServNames;
            
            String strQuery = 'SELECT Org__r.Id,Org__r.Server_Information__r.Pod_Name__c,Org__r.Server_Information__r.Pod_Region__c FROM Org_Entitled_Product__c WHERE Entitled_Product__r.Support_Account__c = \''+accId+'\' ';
            if(!lstMethodname.isEmpty()){
                strQuery += 'AND Entitled_Product__r.Delivery_Method__c IN ' + '(\''+String.join(lstMethodname,'\',\'')+'\') ';
            }

            List<SObject> lstSobjects = CaseControllerWithoutSharing.getSObjectRecords(strQuery);
            List<Org_Entitled_Product__c> lstOrgEntitledProducts = !lstSobjects.isEmpty() ? (List<Org_Entitled_Product__c>) lstSobjects : new List<Org_Entitled_Product__c>();

            for(Org_Entitled_Product__c objOrgEntitledProduct : lstOrgEntitledProducts){
                String strorginfo = objOrgEntitledProduct.Org__r.Server_Information__r.Pod_Region__c+''+objOrgEntitledProduct.Org__r.Server_Information__r.Pod_Name__c;
                //check the status(Pod name and  region) and get status service name
                if(mapStatusName.get(strorginfo.trim()) != null){
                    // add service names 
                    lstServNames.add(mapStatusName.get(strorginfo.trim()));
                }
            }
            
        } catch(Exception e){
            GAM.CreateExceptionRecords('orgOutageBanner_Controller-FetchOrgNames', e.GetMessage(), userinfo.getUserId());
        }
        return lstServNames; 
    }

    /*
    * Method to fetch the Org names based on OrgID.
    * @param Name - String objectName
    * @throws exception -n/a
    * @return list<names> list of service names
    */
    @AuraEnabled(cacheable=true)
    public static List<String> FetchOrgInfo(Id orgId, Boolean boolIsCaseLite){ //<T02> //<T04>
        Set<Id> setSupportAcc = new Set<Id>();
        List<String> lstServNames = new List<String>();
        List<Org__c> lstOrgs = new List<Org__c>(); //<T02>
        List<Org_Entitled_Product__c> lstOrgEntitledProducts;
        
        try{
            //---------------------------------------<T02>-------------------------------
            if(boolIsCaseLite){
                for(Org__c objOrg : CaseControllerWithoutSharing.getOrgs()){
                    if(objOrg.Support_Lite__c && objOrg.Id == orgId){
                        String strQuery = 'SELECT Id,Server_Information__r.Pod_Name__c,Server_Information__r.Pod_Region__c FROM Org__c WHERE Id = \''+orgId+'\' LIMIT 1';
                        lstOrgs = (List<Org__c>) CaseControllerWithoutSharing.getSObjectRecords(strQuery);
                        break;
                    }
                }
            }
            else{
                if(orgId == null)
                    return lstServNames;
                
                String strQuery = 'SELECT Org__r.Id,Org__r.Server_Information__r.Pod_Name__c,Org__r.Server_Information__r.Pod_Region__c FROM Org_Entitled_Product__c WHERE Org__c = \''+orgId+'\' ';
                if(!lstMethodname.isEmpty()){
                    strQuery += 'AND Entitled_Product__r.Delivery_Method__c IN ' + '(\''+String.join(lstMethodname,'\',\'')+'\') ';
                }

                List<SObject> lstSobjects = CaseControllerWithoutSharing.getSObjectRecords(strQuery);
                lstOrgEntitledProducts = !lstSobjects.isEmpty() ? (List<Org_Entitled_Product__c>) lstSobjects : new List<Org_Entitled_Product__c>();
            }
            //---------------------------------------<T02>-------------------------------                                                                
            
            for(Org_Entitled_Product__c objOrgEntitledProduct : lstOrgEntitledProducts){
                String strorginfo = objOrgEntitledProduct.Org__r.Server_Information__r.Pod_Region__c+''+objOrgEntitledProduct.Org__r.Server_Information__r.Pod_Name__c;
                //check the status(Pod name and  region) and get status service name -
                if(mapStatusName.get(strorginfo.trim()) != null){
                    // add service names 
                    lstServNames.add(mapStatusName.get(strorginfo.trim()));
                }
            }
            
        } catch(Exception e){
            GAM.CreateExceptionRecords('orgOutageBanner_Controller-FetchOrgNames', e.GetMessage(), userinfo.getUserId());
        }
        return lstServNames; 
    }
    

    @AuraEnabled(cacheable=true)
    public static Boolean checkSupportAccountType(Id accId){
        boolean hasAccessonAAE = false;
        // AAE cases should only be created for premium and signature success offerings
        try{                                            
            for(Account acc : [SELECT Id, Success_Offering__c FROM account where id =: accId ]){
                if(acc.Success_Offering__c == 'Premium Success' || acc.Success_Offering__c == 'Signature Success' || acc.Success_Offering__c == 'Signature Select'){ //<T01>
                    hasAccessonAAE = true;
                } 
            }
            
        } catch(Exception e){
            GAM.CreateExceptionRecords('orgOutageBanner_Controller-FetchOrgNames', e.GetMessage(), userinfo.getUserId());
        }
        return hasAccessonAAE; 
    }
}