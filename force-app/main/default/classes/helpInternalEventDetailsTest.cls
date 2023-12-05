@isTest
public class helpInternalEventDetailsTest {
        static testmethod void testmethod1(){
            Event e = new Event();
            e.Description = 'Xygddj';
            e.StartDateTime=system.today();
            e.EndDateTime=system.today()+5;
            e.ActivityDate = System.today();
            e.Type='Meeting';
            e.Event_Type__c = 'External';
            e.Subject = 'Lorem ipsiuk jsddhjdhj';
            e.IsVisibleInSelfService = true;
            insert e;
                        
            /*List<EventRelation> evlist = new List<EventRelation>();
            EventRelation er = new EventRelation();
            er.Eventid = e.Id;
            er.Status = 'Accepted';
            er.RelationId = userinfo.getUserId();
            evlist.add(er);        
            insert evlist;*/
            
            Test.startTest();
            helpInternalEventDetails.eventData();
            helpInternalEventDetails.eventdisplayOnId(e.Id);
            helpInternalEventDetails.createEvent('sub','desc',System.now(), System.now()+5,'loc','type');
            helpInternalEventDetails.modifyEvent(e.id,'sub','desc',System.now(), System.now()+5,'loc','type');
            Test.stopTest();
        }

}