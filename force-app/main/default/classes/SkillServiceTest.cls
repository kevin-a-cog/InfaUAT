/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for SkillService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class SkillServiceTest {
    public SkillServiceTest() {

    }

    @isTest
    static void testSkillServiceMethods(){

        Test.startTest();
         List<sObject> lstSObj = new List<sObject>();
         sObject sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
        SkillService.getSkillNames(SkillService.TYPE_PRODUCT_SPECIALIST);    
        SkillService.getSkillNames(SkillService.TYPE_PRODUCT_SPECIALIST, 'PowerCenter');    
        SkillService.getSkillByName('PowerCenter - SME'); 
        
        sobj.put('Type__c','test');
        sobj.put('Product_Name__c','PowerCenter - SME');
        SkillService.mapSkillNameToSkill.put('test',(profileSkill)sobj);
        SkillService.getOmniSkill('PowerCenter - SME', 'test'); 
        SkillService.getProductNames('PowerCenter - SME'); 
       // SkillService.getSkillByName('PowerCenter - SME');    
        
        Test.stopTest();
    }
}