/*******************************************************************************************
* @Name         ShiftAllocationTriggerHandler 
* @Date         02/20/2021
* @Description  This class is a helper class for Shift Allocation Trigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Shubham            02/20/2021         Initial Creation                                                      
*******************************************************************************************/
public without sharing class ShiftAllocationTriggerHandler {
    
    public static void handleAfterInsert(List<Shift_Allocation__c> newList) {
        calculateApprovedAllocation(newList, null);
    }

    public static void handleAfterUpdate(List<Shift_Allocation__c> newList, Map<Id, Shift_Allocation__c> oldMap) {
        calculateApprovedAllocation(newList, oldMap);
    }

    public static void handleAfterDelete(List<Shift_Allocation__c> oldList) {
        calculateApprovedAllocation(oldList, null);
    }

    /**************************************************************************************
    * @Description  This method is used to update approved Shift Allocation records for a Shift Request
    * @Param		List - List of new records in the trigger
    * @Param        Map - Map of old records in trigger
    **************************************************************************************/
    private static void calculateApprovedAllocation(List<Shift_Allocation__c> newList, Map<Id, Shift_Allocation__c> oldMap) {
        Set<Id> shiftRequestIdSet = new Set<Id>();
        List<Shift_Request__c> srList = new List<Shift_Request__c>();

        for(Shift_Allocation__c all : newList) {
            if(String.isNotBlank(all.Shift_Request__c) 
            && (oldMap == null || oldMap.get(all.Id).Shift_Request__c != all.Shift_Request__c || oldMap.get(all.Id).Status__c != all.Status__c)) {
                shiftRequestIdSet.add(all.Shift_Request__c);
                if(oldMap != null && String.isNotBlank(oldMap.get(all.Id).Shift_Request__c)) {
                    shiftRequestIdSet.add(oldMap.get(all.Id).Shift_Request__c);
                }
            }   
        }
        for (AggregateResult ar : [SELECT Shift_Request__c, Count(Id) 
                                   FROM Shift_Allocation__c 
                                   WHERE Shift_Request__c IN :shiftRequestIdSet 
                                   AND Status__c = 'Approved'
                                   GROUP BY Shift_Request__c]) {
                                    shiftRequestIdSet.remove((Id)ar.get('Shift_Request__c'));
                                    srList.add(new Shift_Request__c(
                                        Id = (Id)ar.get('Shift_Request__c'), 
                                        Total_Approved_Allocation__c = (Decimal)ar.get('expr0')
                                        ));
        }
        for(Id srId : shiftRequestIdSet) {
            srList.add(new Shift_Request__c(
                Id = srId, 
                Total_Approved_Allocation__c = 0
                ));
        }
        update srList;
    }
}