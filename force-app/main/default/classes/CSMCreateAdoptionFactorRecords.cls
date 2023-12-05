/*
 * Name			:	CSMCreateAdoptionFactorRecords
 * Author		:	Deva M
 * Created Date	: 	30/09/2021
 * Description	:	this Batch will create adoption factor shell records under plan

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description				        	Tag
 **********************************************************************************************************
 Deva M					30/09/2021		AR-1575			Initial version.		        	N/A
 Karthi G               21/09/2022      AR-2919         Added logic to handle Overdue       <T01>
 */
public with sharing class CSMCreateAdoptionFactorRecords {
    public final string ADOPTION_INITIAL_STATUS ='Waiting for CSM Input';
    
    //<T01>
    /*
	 Method Name : handlePAFOverdue
	 Description :This will create shell paf records for due PAF's   (AR-2919)
	 Parameters	 : A list of Adoption_Factor__c, such as List<Adoption_Factor__c>. 
	 Return Type : void
	 */
    public void handlePAFOverdue(List<Adoption_Factor__c> sourceRecords){
        globalApexManager gam = new globalApexManager();
        Adoption_Factor__c objPaf;
        List<Adoption_Factor__c> pafInsertList= new List<Adoption_Factor__c>();
        List<Plan_Comment__c> planCommentInsertList= new List<Plan_Comment__c>();
        Map<Id,Id> oldRecMap= new Map<Id,Id>();

        for(Adoption_Factor__c afObj:sourceRecords){
            oldRecMap.put(afObj.Plan__c,afObj.Id);
            objPaf = new Adoption_Factor__c(Plan__c=afObj.Plan__c,Status__c=ADOPTION_INITIAL_STATUS);
            objPaf.Product__c = afObj.Product__c;
            objPaf.Project__c = afObj.Project__c;
            objPaf.Engagement__c = afObj.Engagement__c;
            objPaf.Impact__c = afObj.Impact__c;
            objPaf.Impact_Reason__c = afObj.Impact_Reason__c;
            objPaf.Prior_Adoption_Factor__c = afObj.Id;
            pafInsertList.add(objPaf);

            String planComment = 'PAF Update is due by CSM <br/> PAF Status: Waiting for CSM\'s Input <br/> PAF Due Update Date: '+afObj.plan__r.Next_Expected_Adoption_Factor_Date__c;
            Plan_Comment__c planCommentRecord = CSMUtilities.createPlanComment(afObj.Plan__c,planComment,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLANHEALTHREASON,false);
            planCommentInsertList.add(planCommentRecord);
        }

        if(pafInsertList.size()>0){
            Database.SaveResult[] saveResultList = Database.insert(pafInsertList, false);
            for (Database.SaveResult sr : saveResultList) {
                if (!sr.isSuccess()) {
                    system.debug(sr);
                    gam.CreateLogs('CLASS: CSMCreateAdoptionFactorRecords | METHOD: handlePAFOverdue | pafInsertList - Insert shell PAF records', JSON.serialize(sr));
                }
            }
        }
        if(planCommentInsertList.size()>0){
            Database.SaveResult[] saveResultList = Database.insert(planCommentInsertList, false);
            for (Database.SaveResult sr : saveResultList) {
                if (!sr.isSuccess()) {
                    system.debug(sr);
                    gam.CreateLogs('CLASS: CSMCreateAdoptionFactorRecords | METHOD: handlePAFOverdue | planCommentInsertList - Insert Plan comments records', JSON.serialize(sr));
                }
            }
        }
    }
    //</T01>
}