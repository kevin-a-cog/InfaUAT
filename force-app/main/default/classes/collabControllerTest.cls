@isTest
public class collabControllerTest {
    @isTest
    public static void unitTest(){
        
        Raise_Hand__c oRaiseHand = new Raise_Hand__c();
        oRaiseHand.Status__c = 'Open';
        oRaiseHand.Type__c = 'Handoff';
        oRaiseHand.Acceptance_Date__c = system.today().addDays(1);
        oRaiseHand.Closed_On__c = system.today().addDays(2);
        insert oRaiseHand;
        FeedItem oFeed = new FeedItem();
        oFeed.ParentId = oRaiseHand.Id;
        oFeed.Body = 'test Body';
        insert oFeed;
        oRaiseHand.Feed_Item_Id__c =  oFeed.Id;
        update oRaiseHand;
        
        Test.startTest();
        collabController.cloneCollab(oRaiseHand.Id);
        collabController.updateCollab(oRaiseHand.Id, true);
        Test.stopTest();
        system.assertEquals(system.today().addDays(1), oRaiseHand.Acceptance_Date__c);
    }
}