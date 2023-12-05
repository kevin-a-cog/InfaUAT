/*
    Class:          CSMUpdateSuccessPortfolioBatchTest
    @Author:        Karthi Gurusamy
    @Created Date:  24/02/2023
    @Description:   Test class for CSMUpdateSuccessPortfolioBatch
*/
@isTest
private class CSMUpdateSuccessPortfolioBatchTest {
    
    @testSetup
    static void setupObjectTestData() {

        Id customerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        
        List<Territory2Type> territoryType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];

        List<Territory2> terrList = new List<Territory2>();
        
      
        List<String> regionList = new List<String>{'AIK','Middle East','GC','Iberia','Central Strategic','Central Enterprise NA','Northeast Commercial','South LATAM','UKI','Japan','Healthcare Industry','Digital Sales','Central Commercial','West Commercial','South Digital Sales','North Digital Sales','East Enterprise','North LATAM','Retail CPG Industry','BFSI Industry','West Enterprise','Nordics','Central Enterprise EMEA','Southeast Commercial','SLED','Canada','Federal','ANZ','France','Benelux','Italy','Brazil','EMEA Digital Sales','APJ Japan','NA Enterprise','NA Canada','Central Digital Sales EMEA','FedOps','EMEA Emerging Markets','Africa','EE','WW Sales','APJ','EMEA','Americas','EMEA Central','EMEA North','EMEA South','EMEA LATAM','NA Public Sector','NA Industry','NA Commercial','NA Digital Sales','APJ APAC','Rest of SOLA'};

        User usr = [Select Id from User where Id=:Userinfo.getUserId() LIMIT 1];

        system.runAs(usr){
            for(Integer i=0;i<20;i++){            
                Territory2 territoryRec = new Territory2();
                territoryRec.DeveloperName ='AP_AS_AS_MAM_TEST'+i;
                territoryRec.Territory2ModelId = lstTerritoryModel[0].Id;
                territoryRec.Name = 'AP_AS_AS_MAM_TEST'+i;
                territoryRec.Territory2TypeId =territoryType[0].Id;
                territoryRec.Area__c = 'EMEA LATAM';
                territoryRec.Geo__c = 'EMEA';
                territoryRec.Region__c = regionList[i];
                terrList.add(territoryRec);
            }
            insert terrList;
        }
        
        List<Account> accList = new List<Account>(); 
        for(integer i=0;i<20;i++){
            Account acc = new Account();
            acc.RecordTypeId = customerAccountRecType;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            acc.Signature_Success__c = true;
            acc.Geo__c ='EMEA';
            acc.Area__c='EMEA LATAM';
            acc.Health_Score__c =10+i;
            acc.Territory_Name__c =(String)terrList[i].Id;
            acc.Peoplesoft_External_ID__c='1234'+i;
            accList.add(acc);
            
        }
        //accList[0].Geo__c ='NA';//!String.isBlank(label)?label:'NA';
        insert accList;   
        
        // Create Object Territory Association
        List<ObjectTerritory2Association> objTerrAssocList = new List<ObjectTerritory2Association>();
        for(integer i=0;i<accList.size();i++){
            ObjectTerritory2Association objTerrAssocRec = new ObjectTerritory2Association();
            objTerrAssocRec.AssociationCause ='Territory2Manual';
            objTerrAssocRec.ObjectId = accList[i].Id;
            objTerrAssocRec.Territory2Id=accList[i].Territory_Name__c;
            objTerrAssocList.add(objTerrAssocRec);
        }
        insert objTerrAssocList;           

    }  

    static testMethod void testBatch() {
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        Test.startTest();
        CSMSuccessPortfolioSchedular myClass = new CSMSuccessPortfolioSchedular ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
       // Database.executeBatch(new CSMUpdateSuccessPortfolioBatch(), 200);
        Test.stopTest();
    }

}