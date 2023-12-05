/*
@created by       : balajip
@created on       : 03/31/2023
@Purpose          : contains the methods that defines the domain logic pertaining to User Object
@Testclass        : UserServiceTest
@JIRA             : I2RT-7839
    
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
Isha B         06-jun-20223  I2RT-8528  T01     Replaced IsAllDayEvent with custom field IsAllDayEvent__c
*/
public with sharing class UserService {
    public static globalApexManager apexManager = new globalApexManager(); 

    public static void updateFTO(){
        //Get all the FTO events for yesterday, today and tomorrow to cover for all Timezones.
        List<Event> lstEventFTO = [Select Id, IsAllDayEvent__c, StartDateTime, ActivityDate, DurationInMinutes, OwnerId 
                                    From Event 
                                    Where Type = 'FTO' And Owner.IsActive = True
                                        And IsAllDayEvent__c = True 
                                        And (
                                                (StartDateTime <= Today And EndDateTime >= Today)
                                                Or (StartDateTime <= YESTERDAY And EndDateTime >= YESTERDAY)
                                                Or (StartDateTime <= TOMORROW And EndDateTime >= TOMORROW)
                                            )
                                ]; //T01 -> replaced IsAllDayEvent with custom field IsAllDayEvent__c

        //get the Id of the users have FTO Events.
        Set<Id> setUserId = new Set<Id>();
        for(Event evnt : lstEventFTO){
            setUserId.add(evnt.OwnerId);
        }
        Map<Id, User> mapUserToUserId = new Map<Id, User>([Select Id, Name, TimeZoneSidKey 
                                                            From User Where Id in :setUserId]);

        apexManager.CreateLogs('UserService - updateFTO', 'current time before conversion, ' + System.now());

        //Loop through each event and check if it is for the current day as per User Timezone
        Set<Id> setUserIdFTOOn = new Set<Id>(); 
        for(Event evnt : lstEventFTO){
            User eventOwner = mapUserToUserId.get(evnt.OwnerId);
            apexManager.CreateLogs('UserService - updateFTO', 'processing the event ' + evnt.Id + ' for user, ' + eventOwner.Name);

            //get the start and end datetime of the event
            DateTime startTime = evnt.StartDateTime;
            DateTime endTime = evnt.StartDateTime.addMinutes(evnt.DurationInMinutes);
            apexManager.CreateLogs('UserService - updateFTO', 'event start time = ' + startTime);
            apexManager.CreateLogs('UserService - updateFTO', 'event end time = ' + endTime);

            //get the Event Owner Timezone
            String sidKey =  (String)eventOwner.TimeZoneSidKey;
            Timezone ownerTZ = Timezone.getTimeZone(sidKey);

            //get the current time and convert it to the Event Owner Timezone
            DateTime curTimeUserTZ = System.now().addSeconds(ownerTZ.getOffset(System.now())/1000);
            apexManager.CreateLogs('UserService - updateFTO', 'current time after conversion, ' + curTimeUserTZ);

            //check if the current time is within the event period.
            if(startTime <= curTimeUserTZ && endTime >= curTimeUserTZ){
                apexManager.CreateLogs('UserService - updateFTO', 'user ' + eventOwner.Name + ' found to be on FTO');
                setUserIdFTOOn.add(evnt.OwnerId);
            }    
        }

        //get the list of Users that needs the FTO Today checkbox either turned On or Off
        List<User> lstUserToUpdate = [Select Id, Name, FTO_Today__c From User 
                                        Where (Id in :setUserIdFTOOn And FTO_Today__c = false)
                                            Or (Id not in :setUserIdFTOOn And FTO_Today__c = true)];
        
        //toggle the FTO_Today__c checkbox
        for(User usr : lstUserToUpdate){
            apexManager.CreateLogs('UserService - updateFTO', 'updating the user ' + usr.Name + ' as FTO ' + !usr.FTO_Today__c);
            usr.FTO_Today__c = !usr.FTO_Today__c;
        }
        
        if(lstUserToUpdate.size() > 0){
            Database.SaveResult[] lstSaveResult = Database.update(lstUserToUpdate, false);
            for (Database.SaveResult saveResult : lstSaveResult) {
                if (!saveResult.isSuccess()){               
                    for(Database.Error err : saveResult.getErrors()) {                  
                        apexManager.CreateExceptionRecords('UserService.updateFTO --> update of User failed', err.getMessage(), saveResult.getId());
                    }
                }
            }
        }
    }
}