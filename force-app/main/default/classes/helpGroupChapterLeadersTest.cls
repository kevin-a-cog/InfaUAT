/*
* Name         :   helpGroupChapterLeaders
* Author       :   Saumya Gaikwad
* Created Date :   28/07/2022
* Description  :   Test class for chapter leader section on group details page

Change History
**********************************************************************************************************
Modified By            Date          Jira No.            Description                 Tag
**********************************************************************************************************
Saumya Gaikwad      28/07/2022      I2RT-6758            Initial version.            T3
*/

@isTest
private class helpGroupChapterLeadersTest{
    
@testsetup
static void setupObjectTestData(){
    /* T3 - Displaying chapter leaders name in the Group details widget test method.*/
    CollaborationGroup groupg = new CollaborationGroup(
    Name = 'uniquegrp1',  //Group name must be unique
    CollaborationType = 'Private',
    CanHaveGuests = false,
    IsArchived = false,
    IsAutoArchiveDisabled = true
    );
    
    INSERT groupg;
    
    Profile standardprofile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User user2 = new User(Alias = 'standt', Email='standarduser@testorginformatica.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardprofile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorginformaticatest.com');
            
    INSERT user2;
            
    CollaborationGroupMember gm1 = new CollaborationGroupMember();
    gm1.CollaborationGroupId = groupg.id;
    gm1.CollaborationRole = 'Admin';
    gm1.MemberId = user2.Id;
    
    INSERT gm1; 
  }
  /* T3 - Displaying chapter leaders name in the Group details widget test method.*/
  static testMethod void testcollabagroup(){
      List<CollaborationGroup> cgplist = [SELECT Id FROM CollaborationGroup];
      helpGroupChapterLeaders.getChapterLeader(cgplist[0].Id,UserInfo.getUserId());
  }
}