/*
Class:          PartnerProgramTriggerHandlerTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for PartnerRelationshipTriggerHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest(SeeAllData=false)
public class PartnerProgramTriggerHandlerTest {   
    
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();    
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeId1 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('VAD').RecordTypeId;
    static Id PartnerProgramRecTypeId2 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    static Id ChannelProgramLevelRecTypeId = Schema.SObjectType.ChannelProgramLevel.RecordTypeInfosByName.get('AIR').RecordTypeId;
    
    @testSetup
    static void setupObjectTestData() 
    {
		List<User> userList = UtilityTest.createUsersforPRM();
		List<Account> accList = UtilityTest.createAccountforPRM();
		List<User> prtnrUserList = UtilityTest.createPartnerUsersforPRM();
		User adminUser = userList[0];
		User sogUser = userList[1];
		User psmUser = userList[2];
       
        List<ChannelProgram> channelProgList = new List<ChannelProgram>();
        system.runAs(adminUser)
		{
        	/*------------------------------------------------Test Channel Program Creation Start---------------------------------------------------------*/
        	//create ChannelProgram	  
        	UtilityTestData.mChannelProgramData.put('Name','Test Channel Program');
        	UtilityTestData.mChannelProgramData.put('Country__c','United States');
        	sObject channelProgramObj = new ChannelProgram();
        	channelProgramObj = UtilityTest.putFieldRecord(channelProgramObj, UtilityTestData.mChannelProgramData);
        
        	//create ChannelProgram	  
        	UtilityTestData.mChannelProgramData.put('Name','Test Channel Program 1');
        	UtilityTestData.mChannelProgramData.put('Country__c','United States');
        	sObject channelProgramObj1 = new ChannelProgram();
        	channelProgramObj1 = UtilityTest.putFieldRecord(channelProgramObj1, UtilityTestData.mChannelProgramData);
        
        	channelProgList = (List<ChannelProgram>) UtilityTest.makeInsert(new List<sObject>{channelProgramObj,channelProgramObj1});
        
        	/*------------------------------------------------Test Channel Program Creation End---------------------------------------------------------*/        
        	/*------------------------------------------------Test Channel Program Level Creation Start---------------------------------------------------------*/
        	//create ChannelProgramLevel
        	Id ChannelProgramLevelRecTypeId = [SELECT id FROM RecordType where SObjectType='ChannelProgramLevel' and DeveloperName='AIR'].id;
        
        	UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeId);
        	UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[0].id + '');
        
        	sObject channelProgramLevelObj = new ChannelProgramLevel();
        	channelProgramLevelObj = UtilityTest.putFieldRecord(channelProgramLevelObj, UtilityTestData.mChannelProgramLevelData);
		
			UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeId);
        	UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[1].id + '');
        
        	sObject channelProgramLevelObj1 = new ChannelProgramLevel();
        	channelProgramLevelObj1 = UtilityTest.putFieldRecord(channelProgramLevelObj1, UtilityTestData.mChannelProgramLevelData);
        
        	List<ChannelProgramLevel> channelProgLevelList = (List<ChannelProgramLevel>) UtilityTest.makeInsert(new List<sObject>{channelProgramLevelObj,channelProgramLevelObj1});
        
        	/*------------------------------------------------Test Channel Program Level Creation End---------------------------------------------------------*/
        }
    }
    
	
    /* this method updates new Channel Program Member record upon new Partner Program Creation
    *  If Partner Program with Partner and Channel Program already exists, then throw error */
    
	@isTest 
    public static void validateChannelPrgrmLevelMatchChannelPrgrm() {
        List<Account> accList = [Select id  From Account];  
        List<ChannelProgramLevel> channelProgLevelList = [Select id  From ChannelProgramLevel WHERE RecordTypeId=:ChannelProgramLevelRecTypeId];
        List<ChannelProgram> channelProgList = [Select id  From ChannelProgram WHERE Country__c='United States'];
		List<Partner_Program__c> partnerProgList ;
		
		List<ChannelProgram> channelProgLevelList1 = new List<ChannelProgram>([select id, (select id from ChannelProgramLevels) from ChannelProgram where id = :channelProgList[0].id]);
		system.assert(channelProgLevelList1[0].id!=null,'The record not inserted');
        
		//create partner program
        UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
        UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
        UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
        UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
        UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program__c',channelProgList[0].id);
        
        //Create partnerProgObj for accList[1].id
        sObject partnerProgObj = new Partner_Program__c();
        partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
		Test.startTest(); 
		partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj});
		system.assertEquals(partnerProgList.size(),1);
		
		Partner_Program__c toUpdatePartnerProg = partnerProgList[0];
		toUpdatePartnerProg.Channel_Program__c = channelProgList[1].id;
		toUpdatePartnerProg.Channel_Program_Level__c = channelProgLevelList[0].id;
		
		try{
			update toUpdatePartnerProg;
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage().contains(' The Channel Program Level must match selected Channel Program'),true);
		}
        
		Test.stopTest();

	}	
    
    @isTest 
    public static void validateChannelPrgrmLevelWithTrueFlag() {
        PartnerProgramTriggerHandler.flag = true; 
        
        List<Account> accList = [Select id  From Account];  
        List<ChannelProgramLevel> channelProgLevelList = [Select id  From ChannelProgramLevel WHERE RecordTypeId=:ChannelProgramLevelRecTypeId];
        List<ChannelProgram> channelProgList = [Select id  From ChannelProgram WHERE Country__c='United States'];
		List<Partner_Program__c> partnerProgList ;
		
		List<ChannelProgram> channelProgLevelList1 = new List<ChannelProgram>([select id, (select id from ChannelProgramLevels) from ChannelProgram where id = :channelProgList[0].id]);
		system.assert(channelProgLevelList1[0].id!=null,'The record not inserted');
        
		//create partner program
        UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
        UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
        UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
        UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
        UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program__c',channelProgList[0].id);
        UtilityTestData.mPartnerProgramData.put('Country__c','Rest of World');
        //Create partnerProgObj for accList[1].id
        sObject partnerProgObj = new Partner_Program__c();
        partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
		Test.startTest(); 
		try{
			partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj});
            partnerProgList[0].Country__c = 'United States';
			update partnerProgList;      
            
        }
		catch(Exception e)
		{
			system.assertEquals(e.getMessage().contains(' The Channel Program Level must match selected Channel Program'),true);
		}
        
		Test.stopTest();

	}	
    
    
    
    
    @isTest 
    public static void PartnerProgramReturnAfterInsert() {
        List<Account> accList = [Select id  From Account];  
        List<ChannelProgramLevel> channelProgLevelList = [Select id  From ChannelProgramLevel WHERE RecordTypeId=:ChannelProgramLevelRecTypeId];
        List<ChannelProgram> channelProgList = [Select id  From ChannelProgram WHERE Country__c='United States'];
		List<Partner_Program__c> partnerProgList ;
		
		List<ChannelProgram> channelProgLevelList1 = new List<ChannelProgram>([select id, (select id from ChannelProgramLevels) from ChannelProgram where id = :channelProgList[0].id]);
		system.assert(channelProgLevelList1[0].id!=null,'The record not inserted');
        
		//create partner program
        UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
        UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
        UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
        UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
        UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program__c',channelProgList[0].id);
        
        //Create partnerProgObj for accList[1].id
        sObject partnerProgObj = new Partner_Program__c();
        partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
		Test.startTest();
        globalApexManager.avoidRecursion('PartnerProgramAfterInsert');
		partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj});
		
		Test.stopTest();

	}	
    
     
    @isTest 
    public static void PartnerProgramReturnBeforeInsert() {
        List<Account> accList = [Select id  From Account];  
        List<ChannelProgramLevel> channelProgLevelList = [Select id  From ChannelProgramLevel WHERE RecordTypeId=:ChannelProgramLevelRecTypeId];
        List<ChannelProgram> channelProgList = [Select id  From ChannelProgram WHERE Country__c='United States'];
		List<Partner_Program__c> partnerProgList ;
		
		List<ChannelProgram> channelProgLevelList1 = new List<ChannelProgram>([select id, (select id from ChannelProgramLevels) from ChannelProgram where id = :channelProgList[0].id]);
		system.assert(channelProgLevelList1[0].id!=null,'The record not inserted');
        
		//create partner program
        UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
        UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
        UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
        UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
        UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program__c',channelProgList[0].id);
        
        //Create partnerProgObj for accList[1].id
        sObject partnerProgObj = new Partner_Program__c();
        partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
		Test.startTest();
       globalApexManager.avoidRecursion('PartnerProgramBeforeInsert');
		partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj});
		
		Test.stopTest();

	}	
    
    @isTest 
    public static void PartnerProgramReturnBeforeUpdate() {
        List<Account> accList = [Select id  From Account];  
        List<ChannelProgramLevel> channelProgLevelList = [Select id  From ChannelProgramLevel WHERE RecordTypeId=:ChannelProgramLevelRecTypeId];
        List<ChannelProgram> channelProgList = [Select id  From ChannelProgram WHERE Country__c='United States'];
		List<Partner_Program__c> partnerProgList ;
		
		List<ChannelProgram> channelProgLevelList1 = new List<ChannelProgram>([select id, (select id from ChannelProgramLevels) from ChannelProgram where id = :channelProgList[0].id]);
		system.assert(channelProgLevelList1[0].id!=null,'The record not inserted');
        
		//create partner program
        UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
        UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
        UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
        UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
        UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program__c',channelProgList[0].id);
        
        //Create partnerProgObj for accList[1].id
        sObject partnerProgObj = new Partner_Program__c();
        partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
		Test.startTest(); 
		partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj});
		system.assertEquals(partnerProgList.size(),1);
		
		Partner_Program__c toUpdatePartnerProg = partnerProgList[0];
		toUpdatePartnerProg.No_of_projects_registered__c = 1;		
		globalApexManager.avoidRecursion('PartnerProgramBeforeUpdate');
		update toUpdatePartnerProg;
        toUpdatePartnerProg.No_of_projects_registered__c = 2;		
		globalApexManager.avoidRecursion('PartnerProgramBeforeUpdate');
		update toUpdatePartnerProg;
		Test.stopTest();

	}	
    
     /* Method to test PartnerProgramInactiveBatch class and SchedulePartnerProgramInactiveBatch class */
    
	@isTest 
    public static void PartnerProgramInactiveBatchTest() {
        Test.startTest(); 
        List<Account> accList = [Select id  From Account];  
        List<ChannelProgramLevel> channelProgLevelList = [Select id  From ChannelProgramLevel WHERE RecordTypeId=:ChannelProgramLevelRecTypeId];
        List<ChannelProgram> channelProgList = [Select id  From ChannelProgram WHERE Country__c='United States'];
		List<Partner_Program__c> partnerProgList ;
		
		List<ChannelProgram> channelProgLevelList1 = new List<ChannelProgram>([select id, (select id from ChannelProgramLevels) from ChannelProgram where id = :channelProgList[0].id]);
		system.assert(channelProgLevelList1[0].id!=null,'The record not inserted');
        
		//create partner program
        UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
        UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
        UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
        UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-100+'');
        UtilityTestData.mPartnerProgramData.put('End_Date__c',DateTime.now().addDays(-90).format('yyyy-MM-dd')+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
        UtilityTestData.mPartnerProgramData.put('Channel_Program__c',channelProgList[0].id);
         UtilityTestData.mPartnerProgramData.put('Program_Status__c	','Active');
        
        //Create partnerProgObj for accList[1].id
        sObject partnerProgObj = new Partner_Program__c();
        partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
		
		partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj});
		system.assertEquals(partnerProgList.size(),1);         
         PartnerProgramInactiveBatch obj = new PartnerProgramInactiveBatch();      
            DataBase.executeBatch(obj);            
         SchedulePartnerProgramInactiveBatch myClass = new SchedulePartnerProgramInactiveBatch (); 
        String sch = '0 0 23 * * ?';
         system.schedule('Test Sched', sch, myClass);   
		Test.stopTest();
      
         
        
        

	}	
    
    
}