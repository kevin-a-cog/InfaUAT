public without sharing class CSMObjectiveAndMilestoneViewController {
    /*REquired */
    @AuraEnabled
    public static List<Related_Account_Plan__c> fetchPlanProducts(String planId) {
        return [SELECT Id, Product__c, Forecast_Product__c, Offering_Type__c, Pricing_Business_Model__c, Status__c
                FROM Related_Account_Plan__c 
                WHERE Account_Plan__c = :planId LIMIT 1000];
    }
     /*REquired */

    @AuraEnabled
    public static void createObjectiveProducts(String objectiveId, List<String> selectedProducts) {
        List<Objective_Product__c> opList = new List<Objective_Product__c>();

        for(String prodId : selectedProducts) {
            opList.add(new Objective_Product__c(Objective__c = objectiveId, Plan_Product_Alias__c = prodId));
        }
        insert opList;
    }
/*REquired 
    @AuraEnabled
    public static void createMilestoneWithProducts(String dataStr) {
        List<Milestone__c> milestoneList = new List<Milestone__c>();
        List<MilestoneWithProductWrapper> data = (List<MilestoneWithProductWrapper>)System.JSON.deserialize(dataStr, List<MilestoneWithProductWrapper>.class);

        for(MilestoneWithProductWrapper mpw : data) {
            milestoneList.add(mpw.record);
        }
        upsert milestoneList;

        List<Milestone_Product__c> mpList = new List<Milestone_Product__c>();
        for(MilestoneWithProductWrapper mpw : data) {
            for(String prodId : mpw.productList) {
                mpList.add(new Milestone_Product__c(Milestone__c = mpw.record.Id, Plan_Product__c = prodId));
            }
        }
        insert mpList;
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectiveWrapper> fetchObjectiveWithMilestones(String planId) {
        List<Objective__c> objList = new List<Objective__c>();
        objList = [SELECT Id, Business_Goal__c, Technical_Goal__c,
                   (SELECT Id, Plan_Product__r.Product__c, Plan_Product__r.Forecast_Product__c, Plan_Product__r.Offering_Type__c, 
                   Plan_Product__r.Pricing_Business_Model__c, Plan_Product__r.Status__c FROM Objective_Products__r)
                    FROM Objective__c WHERE Plan__c = :planId ORDER BY CreatedDate DESC];
        
        if(objList.isEmpty()) {
            return new List<ObjectiveWrapper>();
        }

        Map<Id, List<Milestone__c>> objToMilestoneMap = new Map<Id, List<Milestone__c>>();
        for(Milestone__c mi : [SELECT Id, Name, Objective__c, Description__c, Key_Milestone__c, Planned_Completion_Date__c, Progress__c, Status__c,
                               (SELECT Id, Plan_Product__r.Product__c, Plan_Product__r.Forecast_Product__c, Plan_Product__r.Offering_Type__c, 
                               Plan_Product__r.Pricing_Business_Model__c, Plan_Product__r.Status__c FROM Milestone_Products__r) 
                               FROM Milestone__c WHERE Objective__c IN :objList]) {
            if(!objToMilestoneMap.containsKey(mi.Objective__c)) {
                objToMilestoneMap.put(mi.Objective__c, new List<Milestone__c>());
            }
            objToMilestoneMap.get(mi.Objective__c).add(mi);
        }

        List<ObjectiveWrapper> objWrapperList = new List<ObjectiveWrapper>();
        for(Objective__c obj : objList) {
            objWrapperList.add(new ObjectiveWrapper(obj, 
                                objToMilestoneMap.containsKey(obj.Id) 
                                ? objToMilestoneMap.get(obj.Id) 
                                : new List<Milestone__c>()));
        }
        
        return objWrapperList;
    }
*/
    @AuraEnabled
    public static List<Related_Account_Plan__c> fetchObjectiveProducts(String objectiveId) {
        return [SELECT Id, Product__c, Forecast_Product__c, Offering_Type__c, Pricing_Business_Model__c, Status__c
                FROM Related_Account_Plan__c 
                WHERE Id IN (SELECT Plan_Product__c FROM Objective_Product__c WHERE Objective__c = :objectiveId)];
    }
    @AuraEnabled
    public static Boolean checkInternalRecords(String strRecordId) {
        Boolean disableField=false;
        Id strCleanRecordId;
        if(String.isNotBlank(strRecordId)) {
            strCleanRecordId = Id.valueOf(String.escapeSingleQuotes(strRecordId));
            String strObjectName = strCleanRecordId.getSObjectType().getDescribe().getName();
            if(strObjectName.equalsIgnoreCase('Objective__c')){
                Objective__c objObjectiveRecord = [SELECT Plan__r.Is_Internal__c, Is_Internal__c FROM Objective__c WHERE Id=:strCleanRecordId];
                if(objObjectiveRecord.Plan__r.Is_Internal__c){
                    disableField=true;
                }
            }
            if(strObjectName.equalsIgnoreCase('Milestone__c')){
                Milestone__c objMilestoneRecord=[SELECT Id, Objective__c,Objective__r.Is_Internal__c FROM Milestone__c WHERE Id=:strCleanRecordId];
                if(objMilestoneRecord.Objective__r.Is_Internal__c){
                    disableField=true;
                }
            }
        }
        return disableField;
    }
/*
    public class MilestoneWithProductWrapper {
        public List<String> productList{get;set;}
        public Milestone__c record{get;set;}
    }

    public class ObjectiveWrapper {
        @AuraEnabled
        public Objective__c obj {get;set;}
        @AuraEnabled
        public List<Milestone__c> milestoneList {get;set;}

        public ObjectiveWrapper(Objective__c obj, List<Milestone__c> milestoneList) {
            this.obj = obj;
            this.milestoneList = milestoneList;
        }
    }
*/
}