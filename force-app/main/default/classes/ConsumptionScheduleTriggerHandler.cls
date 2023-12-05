/*
        Trigger:        ConsumptionSchedule
        @Author:        Stephanie Viereckl
        @Created Date:  October 14 2021
        @Description:   To default fields on ConsumptionSchedule when record type is "Estimation Schedule" and to create a dummy ConsumptionRate
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Oct 14 2021  IPUE-53                        Initial Create                     
    ********************************************************************************************************************************************

   
*/

public with sharing class ConsumptionScheduleTriggerHandler {
    
    public static void beforeInsert(List<ConsumptionSchedule> newList){
        populateMatchingAttribute(newList);
    }
    
    public static void afterInsert(List<ConsumptionSchedule> newList){
        processEstimationSchedules(newList);
    }

    /************* Helper Methods *************/

    private static void populateMatchingAttribute(List<ConsumptionSchedule> newList){
        for(ConsumptionSchedule schedule : newList){
            if(schedule.Name != null && schedule.MatchingAttribute == null){
                schedule.MatchingAttribute = schedule.Name;
            }
        }
    }

    private static void processEstimationSchedules(List<ConsumptionSchedule> newList){

        Set<Id> recordTypeIds = new Set<Id>();
        Map<String, Id> recordTypeByNameMap = new Map<String, Id>();
        List<ConsumptionRate> ratesToInsert = new List<ConsumptionRate>();
        List<ConsumptionSchedule> schedulesToUpdate = new List<ConsumptionSchedule>();

        // Query out the applicable Record Types
        List<RecordType> recordTypeList = [
            SELECT Id, DeveloperName
            FROM RecordType 
            WHERE DeveloperName = 'Estimation_Schedule'
            OR DeveloperName = 'Estimation_Range'
        ];

        // Create a Map where the Key = Record Type Developer Name, Value = Record Type Id
        for (RecordType recordType : recordTypeList) {
            recordTypeByNameMap.put(recordType.DeveloperName, recordType.Id);
        }

        for (ConsumptionSchedule schedule : newList) {

            // If the Consumption Schedule has the record type of "Estimation Schedule", proceed
            if (schedule.RecordTypeId == recordTypeByNameMap.get('Estimation_Schedule')) {

                // Create a dummy Consumption Rate and populate required fields
                ConsumptionRate rate = new ConsumptionRate();
                rate.ConsumptionScheduleId = schedule.Id;
                rate.RecordTypeId = recordTypeByNameMap.get('Estimation_Range');
                rate.ProcessingOrder = 1;
                rate.LowerBound = 1;
                rate.Price = 0;
                rate.PricingMethod = 'PerUnit';
                ratesToInsert.add(rate);

                // Create a new instance of the Consumption Schedule and activate it
                ConsumptionSchedule updatedSchedule = new ConsumptionSchedule();
                updatedSchedule.Id = schedule.Id;
                updatedSchedule.IsActive = true;
                //populate external ID for deployments based on the ID of the schedule in the org that it was created in.
                if(schedule.IPUE_ExternalID__c == null){
                    updatedSchedule.IPUE_ExternalID__c = schedule.Id;
                }

                schedulesToUpdate.add(updatedSchedule);
            } else {
                // Create a new instance of the Consumption Schedule and activate it
                ConsumptionSchedule updatedSchedule = new ConsumptionSchedule(Id = schedule.Id);
                //populate external ID for deployments based on the ID of the schedule in the org that it was created in.
                if(schedule.IPUE_ExternalID__c == null){
                    updatedSchedule.IPUE_ExternalID__c = schedule.Id;
                }
                schedulesToUpdate.add(updatedSchedule);
            }
        }

        insert ratesToInsert;
        update schedulesToUpdate;

    }

}