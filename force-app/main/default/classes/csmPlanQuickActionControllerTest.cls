@istest
public class csmPlanQuickActionControllerTest {
    
    
    @testSetup 
    public static void setup() {
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        //Now we create a Plan.
        Plan__c objPlan = new Plan__c();
        objPlan.Name = 'Test';
        insert objPlan;
        System.runAs(createTestUser('System Administrator', true)) {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        insert validEmailTemplate;
            
        }
        
        //We create a Risk Issue.
        Risk_Issue__c objRiskIssue = new Risk_Issue__c(RecordTypeId=riskRt);
        objRiskIssue.Name = 'Test';
        objRiskIssue.Type__c = 'Adoption ';
        objRiskIssue.Risk_Reason__c = 'Acquisition';
        insert objRiskIssue;
    }
    
    @isTest
    public static void testRecordFetching() {
        
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
        try{
            csmPlanQuickActionController.getEmailBody(objPlan.Id, 'name');
        }catch(Exception e){
		}
        
     		
    }  
    
     @isTest
    static void testRenderTemplate(){
        Id caseId = [Select Id from Plan__c LIMIT 1]?.Id;
       String templateContent = 'Test description of {{{Plan__c.Name}}} and created on {{{Plan__c.CreatedDate}}} for {{{Plan__c.Account__r.Name}}}';
        String timeZoneName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]?.TimeZoneSidKey;
        String formattedDateTime = 'dd-MMMMM-yyyy hh:mm a z';
        Test.startTest();
        csmPlanQuickActionController.renderTemplate(caseId, templateContent, timeZoneName, formattedDateTime);
        Test.stopTest();
    }
    
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        return objTestUser;
    }
}