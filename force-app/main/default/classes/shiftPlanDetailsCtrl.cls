global class shiftPlanDetailsCtrl {

    global String shiftPlanId{get;set;}
    
    
    global List<Shift_Request__c> shiftRequest{
        get{        
            List<Shift_Request__c> posToDisplay = new List<Shift_Request__c>();
            List<Shift_Request__c> reqList = [SELECT Id,Name,Skill__c,Skill__r.Name,(SELECT Id,Name,Service_Resource__c,Service_Resource__r.RelatedRecord.Name,Service_Resource__r.RelatedRecord.GCS_Team__c,Service_Resource__r.RelatedRecord.Phone FROM Shift_Allocations__r) FROM Shift_Request__c WHERE Shift_Plan__c=:shiftPlanId];
            for(Shift_Request__c p:reqList){
                for(Shift_Allocation__c allocation :p.Shift_Allocations__r){
                    posToDisplay.add(p);
                }
            }
            return posToDisplay;
        }
        set;
    }
    
}