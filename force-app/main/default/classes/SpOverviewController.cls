public without sharing class SpOverviewController {

    @AuraEnabled(cacheable=true)
    public static WrapperResult fetchOverViewData(string sPlanId){     
        
        WrapperResult oResult = new WrapperResult();
      // get plan with Customer Account   
     // Plan__c oPlan = [SELECT Id,Account__c,Product_Health_Score__c,Contact__c,Account__r.RecordType.Name,Plan_status_picklist__c,OwnerId,Owner.FirstName,Owner.LastName,Owner.Name,Owner.Email From Plan__c WHERE Id =:sPlanId];
     Plan__c oPlan = [SELECT Id,Account__c,Contact__c,Account__r.RecordType.Name,Plan_status_picklist__c,OwnerId,Owner.FirstName,Owner.LastName,Owner.Name,Owner.Email From Plan__c WHERE Id =:sPlanId];
      
      // get engagement count for support escalation for open enagament 
      Integer OpenEngagementCount = [SELECT COUNT() FROM Engagement__c 
                                      WHERE Plan__c = :oPlan.Id 
                                      AND recordtype.name = 'Support Escalation' 
                                      AND Status__c != 'Closed'];

       // Engagement Level logic        
      Integer PlanCommentsCount =  [SELECT COUNT() FROM Plan_Comment__c
                                    WHERE Visibility__c = 'External'
                                    AND Type__c IN ('External','Inbound') 
                                    AND CreatedDate = LAST_N_DAYS:30 
                                    AND Plan__c =:sPlanId]; 
      system.debug('PlanCommentsCount==> ' + PlanCommentsCount);
      Integer EmailMessageCount = [SELECT COUNT() FROM EmailMessage  
                                                  WHERE RelatedToId =:sPlanId
                                                  AND CreatedDate = LAST_N_DAYS:30];
      system.debug('EmailMessageCount==> ' + EmailMessageCount);
      Integer totalPlanCommentsAndEmailMessageCount =   PlanCommentsCount +  EmailMessageCount;                                                
      system.debug('totalPlanCommentsAndEmailMessageCount==> ' + totalPlanCommentsAndEmailMessageCount);
      string PlanHealthLevel = '';
      string ProductHealthLevel = '';
      string ActiveEngagements = '';
         Adoption_Factor__c pf;
      //ProductHealthLevel = oPlan.Product_Health_Score__c;  
        for(Adoption_Factor__c AF : [SELECT Product__c FROM Adoption_Factor__c 
                                                 WHERE Status__c = 'Final' 
                                                 AND Plan__c = :sPlanId 
                                                 ORDER BY LASTMODIFIEDDATE 
                                                 DESC LIMIT 1]){
            pf = AF;
            
        }
     

      ProductHealthLevel = (pf != null && pf.Product__c != null) ? pf.Product__c : '';  
      PlanHealthLevel = oPlan.Plan_status_picklist__c;  
      
      if(totalPlanCommentsAndEmailMessageCount >= 10){
        ActiveEngagements = 'High';
      }
      else if(totalPlanCommentsAndEmailMessageCount >= 5 && totalPlanCommentsAndEmailMessageCount < 10){
        ActiveEngagements = 'Moderate'; 
      }
      else if(totalPlanCommentsAndEmailMessageCount >= 0 && totalPlanCommentsAndEmailMessageCount < 5){
        ActiveEngagements = 'Passive'; 
      }
        
      oResult.sPlanHealthLevel = PlanHealthLevel;
      oResult.sProductHealthLevel = ProductHealthLevel;
      oResult.iOpenEngagementCount = OpenEngagementCount;
      oResult.sActiveEngagements = ActiveEngagements;
      
      
      oResult.sPlanOwnerName = oPlan.Owner.Name;
      oResult.sPlanOwnerEmail = oPlan.Owner.Email;
      if(string.valueOf(oPlan.OwnerId).startswith('00G')){
        oResult.sPlanOwnerName = Label.Success_Portal_Autopilot_CSM_Name;
        oResult.sPlanOwnerEmail = Label.Success_Portal_Autopilot_Email.contains('@')?Label.Success_Portal_Autopilot_Email:'';
      }
	  oResult.sPlanOwnerAboutMe = '';
	  	for(User objUser : [SELECT AboutMe FROM User WHERE Id = :oPlan.OwnerId AND AboutMe <> NULL]) {
			oResult.sPlanOwnerAboutMe = objUser.AboutMe;
	  	}
      oResult.sPlanOwnerDisplayPic = '/profilephoto/005/T';
       
      
      if(string.valueOf(oPlan.OwnerId).startswith('005')){
          User ouser = [Select Id,SmallPhotoUrl From User Where Id = :oPlan.OwnerId LIMIT 1];
          if(ouser.SmallPhotoUrl != null){
            oResult.sPlanOwnerDisplayPic = ouser.SmallPhotoUrl;
          }          
      }
      return oResult;      
    } 


    public class WrapperResult{
      @AuraEnabled public string sPlanHealthLevel;
      @AuraEnabled public string sProductHealthLevel;
      @AuraEnabled public string sActiveEngagements;

      @AuraEnabled public string sPlanOwnerName;
	  @AuraEnabled public string sPlanOwnerAboutMe;
      @AuraEnabled public string sPlanOwnerEmail;      
      @AuraEnabled public string sPlanOwnerDisplayPic;      
      @AuraEnabled public Integer iOpenEngagementCount;      
      
    }


}