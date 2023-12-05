@IsTest
public class ScehdulerTestDataFactory {
    
    public static List<ServiceAppointment> createServiceAppointments(Id parentId, Boolean doInsert, Integer numberOfRecords) {
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        Datetime newDatetime = Datetime.now();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            serviceAppointments.add(
                new ServiceAppointment(
                    SchedStartTime = newDatetime,
                    SchedEndTime = newDatetime,
                    ParentRecordId = parentId,
                    Subject = 'SA ' + i,
                    Status = 'None'
                )
            );
        }
        
        if (doInsert) {
            insert serviceAppointments;
        }
        
        return serviceAppointments;
    }
    
    public static List<ServiceTerritory> creatServiceTerritories(Boolean doInsert, Integer numberOfRecords, Id operatingHoursId) {
        List<ServiceTerritory> serviceTerritories = new List<ServiceTerritory>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            serviceTerritories.add(
                new ServiceTerritory(
                    IsActive = true,
                    Name = 'ST Name ' + i,
                    OperatingHoursId = operatingHoursId
                )
            );
        }
        
        if (doInsert) {
            insert serviceTerritories;
        }
        
        return serviceTerritories;
    }
    
    public static List<OperatingHours> creatOperatingHours(Boolean doInsert, Integer numberOfRecords) {
        List<OperatingHours> operatingHours = new List<OperatingHours>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            operatingHours.add(
                new OperatingHours(
                    Name = 'Operating Hours ' + i
                )
            );
        }
        
        if (doInsert) {
            insert operatingHours;
        }
        
        return operatingHours;
    }
    public static List<WorkTypeGroup> createWorkTypeGroups(Boolean doInsert, Integer numberOfRecords) {
        List<WorkTypeGroup> WorkTypeGroups = new List<WorkTypeGroup>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            WorkTypeGroups.add(
                new WorkTypeGroup(
                    Name = 'WTg ' + i,
                    GroupType = 'Default',
                    IsActive = true
                )
            );
        }
        
        if (doInsert) {
            insert WorkTypeGroups;
        }
        
        return WorkTypeGroups;
    }
    
    public static List<WorkType > createWorkTypes(Boolean doInsert, Integer numberOfRecords) {
        List<WorkType> workTypes = new List<WorkType>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            workTypes.add(
                new WorkType(
                    Name = 'WT ' + i,
                    EstimatedDuration = 1
                )
            );
        }
        
        if (doInsert) {
            insert workTypes;
        }
        
        return workTypes;
    }
    
    
    
    
}