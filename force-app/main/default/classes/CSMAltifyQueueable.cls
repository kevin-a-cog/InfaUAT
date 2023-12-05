/*
 * Name			:	CSMAltifyQueueable
 * Author		:	Manuraj
 * Created Date	: 	07/07/2021
 * Description	:	Quebale class trigger on plan contact insert and create alitify contact if the 
 *                  if the contacts not available

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Manuraj		        07/07/2021	    AR-1560			Initial version.			N/A
 */
public with sharing class CSMAltifyQueueable implements Queueable{
    List<Plan_Contact__c> allPlanContacts;
    public CSMAltifyQueueable(List<Plan_Contact__c> allPlanContacts) {
        this.allPlanContacts=allPlanContacts;
    }
    public void execute(QueueableContext context){
        globalApexManager GAM = new globalApexManager();
        Map<Id,Id> planConIdVsString=new Map<Id,Id>();
        Map<Id,Id> altifyIdvsContact=new Map<Id,Id>();
        Set<Id> allAltfyCon=new Set<Id>();
        List<ALTF__Contact_Map_Details__c> allAltifyConts=new List<ALTF__Contact_Map_Details__c>();
        ALTF__Contact_Map_Details__c  indivAltfConts;
        Set<Id> allPlanIds=new Set<Id>();
        Set<Id> planContactSet = new Set<Id>();
        if(allPlanContacts!=null && allPlanContacts.size()>0){
            //Get Plan Id and contactids of plan contact
            for(Plan_Contact__c planContsIndiv:allPlanContacts ){
                allPlanIds.add(planContsIndiv.Id);
                if(planContsIndiv.Contact__c!=null){
                    planContactSet.add(planContsIndiv.Contact__c); 
                }
            }
            //Query related fields on plan contact like account and pit it in map
            for(Plan_Contact__c getAllIndivPlan:[Select Plan__c, Plan__r.Account__c,Contact__r.Email,Id from Plan_Contact__c where Id IN: allPlanIds] ){
                if(getAllIndivPlan.Plan__c!=null && getAllIndivPlan.Plan__r.Account__c!=null){
                    planConIdVsString.put(getAllIndivPlan.Id,getAllIndivPlan.Plan__r.Account__c);
                }
            }
            //Query exisitng altify contacts associated plan account and conact of plan contact
            if(planConIdVsString.size()>0 && planContactSet.size()>0){
                for(ALTF__Contact_Map_Details__c getIndivAltifyC: [Select ALTF__Contact__c from ALTF__Contact_Map_Details__c where ALTF__Account__c IN : planConIdVsString.values() AND ALTF__Contact__c IN : planContactSet ]){
                    allAltfyCon.add(getIndivAltifyC.ALTF__Contact__c);
                }
            }
            //Create altify contact if the there is no contact related to account and Plan contact 
            for(Plan_Contact__c allPlanConts: allPlanContacts){
                if(allAltfyCon.size()<=0 || !allAltfyCon.contains(allPlanConts.Contact__c)){
                    if(planConIdVsString.get(allPlanConts.Id)!=null){
                        indivAltfConts=new ALTF__Contact_Map_Details__c();
                        indivAltfConts.ALTF__Account__c= planConIdVsString.get(allPlanConts.Id);
                        indivAltfConts.ALTF__Contact__c=allPlanConts.Contact__c;
                        indivAltfConts.Name= allPlanConts.Id;
                        allAltifyConts.add(indivAltfConts);
                    }
                }

            }
            //insert the records
            if(!allAltifyConts.isEmpty()){
                try{
                    Database.insert(allAltifyConts, false);                
                } catch(Exception e){
                    GAM.CreateLogs('CSMAltifyQueueable.execute() -> ' + e.getCause(), allAltifyConts, 'allAltifyConts');
                }
            }
        }
    }
}