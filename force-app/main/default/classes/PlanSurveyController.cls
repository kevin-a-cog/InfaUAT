/*
Class:          PlanSurveyController 
@Author:        Chandana Gowda
@Created Date:  17/3/2018
@Description:   Controller class for PlanSurvey Lighting component
                This class is used to get and update plan fields when survey is sent                

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag                                                       
*************************************************************************************************************************************
*/
public without sharing class PlanSurveyController {
 
    public static globalApexManager GAM = new globalApexManager();
    /*Method to get the plan data.
    * @param Name - planId
    * @throws exception -n/a
    * @return Plan__c---the plan record
    */
    @AuraEnabled
    public static Plan__c CheckSurveySent(ID planId){
        
        Plan__c plan = [SELECT ID,RecordTypeId,RecordType.Name,
                        Account__c,Current_State_of_plan__c,Business_Outcome_Survey_Sent__c,Onboarding_Survey_Sent__c,CST_Survey_Sent__c,RecordType.DeveloperName FROM Plan__c where Id =:planId LIMIT 1];
                				system.debug('**Plan'+ Plan);
				
                            system.debug('**Plan Onboarding_Survey_Sent__c'+ plan.Onboarding_Survey_Sent__c);
                        System.debug('**Plan RecordType'+ plan.RecordType.DeveloperName);
                        return plan;
    }
    /*Method to get the Account contact data.
    * @param Name - planId
    * @throws exception -n/a
    * @return Contact---the Contact record
    */
    @AuraEnabled
    public static List<Contact> acccontacts(ID planId){
        Plan__c p = [select account__c from Plan__c where id = :planId];
        List<Contact> plancon = new List<Contact>([SELECT ID,Name,Email,Title FROM Contact where AccountId =:p.account__c]);
        return plancon;
    }
    
    
    /*Method to get the plan data.
    * @param Name - planId
    * @throws exception -n/a
    * @return Plan__c---the plan record
    */
    @AuraEnabled
    public static List<Contact> findByName(String searchKey, Id accid) {
        String name = '%' + searchKey + '%';
        return [SELECT id, Name, Email,Title FROM Contact WHERE name LIKE :name and accountid = :accid];
    }
      
    

    /*Method to update the plan.
    * @param Name - planId
    * @throws exception -n/a
    * @return void
    */    

    @AuraEnabled
    public static void updatePlanSurveySent(List<Contact> acccontacts, Id planid){
        List<Plan_Contact__c> updatepc = new List<Plan_Contact__c>();
        List<Plan_Contact__c> insertpc = new List<Plan_Contact__c>();
        Map<Id,Contact> contactmap = new Map<Id,Contact>();
        Map<Id,Plan_Contact__c> pcmap = new Map<Id,Plan_Contact__c>();
        Plan__c pl = [SELECT ID,Current_State_of_plan__c,RecordType.DeveloperName,CST_Survey_Sent__c,Business_Outcome_Survey_Sent__c,Onboarding_Survey_Sent__c from Plan__c where id = :planid];
        system.debug('**RecordType.DeveloperName'+RecordType.DeveloperName);
        for(Contact c: acccontacts){
            contactmap.put(c.id,c);
        }
        for(Plan_Contact__c p: [SELECT ID,Plan__r.Current_State_of_plan__c,Contact__c,Contact_email__c,Plan__r.Business_Outcome_Survey_Sent__c,Plan__r.Onboarding_Survey_Sent__c,Plan__r.CST_Survey_Sent__c FROM Plan_Contact__c where Plan__c = :pl.Id and Contact__c in :contactmap.keyset()]){
          pcmap.put(p.Contact__c,p);
        }
        for(Contact c: contactmap.values()){
            if(pcmap.get(c.Id) != null){
                Plan_Contact__c pc1 = pcmap.get(c.Id);
                if(pl.RecordType.DeveloperName =='CST_Plan'){
                    system.debug('** pl RecordType.DeveloperName'+pl.RecordType.DeveloperName);

                    pc1.CST_Survey_Sent__c = TRUE;
                    pl.CST_Survey_Sent__c = TRUE;
                }
                else if(pl.Current_State_of_plan__c == 'Implement' || pl.Current_State_of_plan__c == 'Configuration'){
                    pc1.Onboarding_Survey_Sent__c = TRUE;
                    pl.Onboarding_Survey_Sent__c = TRUE;
            	}
                else if (pl.Current_State_of_plan__c == 'Optimize/Grow'){
                    pc1.Business_Outcome_Survey_Sent__c = TRUE;
                    pl.Business_Outcome_Survey_Sent__c = TRUE;
                }
                updatepc.add(pc1);
            } else {
                Plan_Contact__c pc2 = new Plan_Contact__c();
                pc2.Contact__c = c.id;
                pc2.Plan__c = planid;
                pc2.Contact_Email__c = c.Email;
                //pc2.Title__c = c.Title;
               // pc2.Name = c.Name;
               if(pl.RecordType.DeveloperName =='CST_Plan'){
                system.debug('** pl RecordType.DeveloperName in else'+pl.RecordType.DeveloperName);

                pc2.CST_Survey_Sent__c = TRUE;
                pl.CST_Survey_Sent__c = TRUE;
                }
                else if(pl.Current_State_of_plan__c == 'Implement' || pl.Current_State_of_plan__c == 'Configuration'){                    
                    pc2.Onboarding_Survey_Sent__c = TRUE;
                    pl.Onboarding_Survey_Sent__c = TRUE;
                }
                else if (pl.Current_State_of_plan__c == 'Optimize/Grow'){
                    pc2.Business_Outcome_Survey_Sent__c = TRUE;
                    pl.Business_Outcome_Survey_Sent__c = TRUE;
                }
                insertpc.add(pc2);
            }
        }
        try{
            //To update existing plan contacts
        	if(updatepc.size() > 0)
            	update updatepc;
   			//To create new plan contacts     	
        	if(insertpc.size() > 0)
            	insert insertpc;
        	//To update survey checkboxes on plan
            if(updatepc.size() > 0 || insertpc.size() > 0 )
                update pl;
            
        }Catch(Exception e){
             GAM.CreateExceptionRecords('Sendsurvey', e.GetMessage(),'Plan_Contact__c');
        }
            
    }
}