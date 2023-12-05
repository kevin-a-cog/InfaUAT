/***************************************************************************
*        Name        :        LogRiskController
*        Author      :        Aishwarya Badri
*        Date        :        19 August 2020
*        Description :        Controller class for Log risk quick action available in Plan layout
****************************************************************************
Change History
************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                 								Tag    
************************************************************************************************************************************
*/

public class LogRiskController {
    
    @AuraEnabled
    public static Boolean validateRisks(String planId, String riskType)
    {
        System.debug('Entry validateRisks: PlanID-->'+planId+'--rISK TYPE--'+riskType);
        Boolean flag=false;
        List<Risk_Issue__c> risksList=new List<Risk_Issue__c>();
        
        risksList=[select Id,Status__c,Type__c,Plan__c from Risk_Issue__c where Plan__c=:planId and Type__c=:riskType and Status__c='Open'];
        System.debug('risksList-->'+risksList);
        
        if(risksList!=null && risksList.size()>0)
        {
            System.debug('Validation true-->throw error');
            flag=true;
        }
        return flag;
    }
     @AuraEnabled
    public static  Map<Id, String> getRiskRecordTypeId()
    {
       /* String recordTypeID= Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        return recordTypeID;*/
          List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get('Risk_Issue__c').getDescribe().getRecordTypeInfos();
        Map<Id, String> recordtypemap = new Map<Id, String>();

        for(RecordTypeInfo rt : recordtypes){
            if (rt.isAvailable()&& !rt.isMaster())
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }
        System.debug('recordtypemap-->'+recordtypemap);
        return recordtypemap;

    }
    @AuraEnabled
    public static  Map<String, String> getRiskTypePicklistValues()
    {
        System.debug('getRiskTypePicklistValues Entry');
        Map<String, String> riskTypeOptions = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Risk_Issue__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            riskTypeOptions.put(p.getValue(), p.getLabel());
        }
        System.debug('riskTypeOptions-->'+riskTypeOptions);
        return riskTypeOptions;
    }
    @AuraEnabled
    public static Boolean hasPlanProducts(String PlanId){
        System.debug('****PlanId'+ PlanId);
        if(!String.isBlank(PlanId)){
           List<Related_Account_Plan__c> lstPlanProduct = [select id from Related_Account_Plan__c where Account_Plan__c = :PlanId];

           if(lstPlanProduct!=null & lstPlanProduct.size()>0){

            System.debug('****lstPlanProduct.size()  '+lstPlanProduct.size());
            return true;

            }else{
                System.debug('****lstPlanProduct else con  '+lstPlanProduct);

                return false;
            }
        }
        else{
            System.debug('****PlanId blank con'+ PlanId);
            return false;
        }
    }
    
    @AuraEnabled
    public static string insertRisk(string riskRec){
            System.debug('***riskRec'+riskRec);
            Risk_Issue__c riskRecordToCreate = (Risk_Issue__c)JSON.deserialize(riskRec, Risk_Issue__c.class);
            riskRecordToCreate.RecordTypeId =label.RiskRecType;
            System.debug('***label'+label.RiskRecType);

            try {
                    insert riskRecordToCreate;
               } catch (System.DmlException e) {
                   system.debug('Exception while creating risk'+e.getmessage());
               }
            return riskRecordToCreate.Id;
    }

}