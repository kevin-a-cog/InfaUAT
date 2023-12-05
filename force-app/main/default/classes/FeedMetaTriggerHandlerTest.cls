@isTest

public class FeedMetaTriggerHandlerTest {
    static testmethod void testmethod1(){
        
        Idea id1 = new Idea();
        id1.Title = 'new idea';
        id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;          
        id1.Body = 'Lorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsumLorem ipsum';
        id1.Status = 'New';
        id1.Categories = 'Cloud Integration';
        insert id1;
        
        Feed_Meta__c fm = new Feed_Meta__c();
        fm.Reference__c = id1.Id;
        insert fm;
        
        fm.Reference_Type__c = 'Ideas';
        update fm;
        
    }

}