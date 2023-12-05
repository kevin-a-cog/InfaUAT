public class PlanProductInvocableNotifyCSM {
    
     
    
     
    @InvocableMethod(label='Notify CSM queue On Churn' description='Notify CSM queue')
    public static void NotifyUsers(List<Id> PlanProductIds){
        system.debug('***NotifyUsers called');
        postFeedElementWithMention(PlanProductIds);  //T01- pass full list of optys 
    }

    

    public static void postFeedElementWithMention(List<Id> PlanProductIds){  
    
    //-----------------------------------------------------------------------------------------<T01>
        Set<Id> AccountIds = new Set<Id> ();
        Map<ID, set<ID>> mapAccountCSM = new map<Id, set<Id>>();  // Map of Account and CSM users assigned to Account      
        List<Related_Account_plan__c>  lstPlanProduct = new List<Related_Account_plan__c>();  // List of Plan Products
        Map<Id,Set<Id>> mapPlanProductUser = new Map<Id,Set<Id>>();
                
        lstPlanproduct = [select id,Name,Account_Plan__c,Contract__c,Contract__r.Name,Opportunity__c,Opportunity__r.Name,Account_Plan__r.Account__c,Account_Plan__r.Account__r.Name,Account_Plan__r.ownerId,Account__c,Account_Plan__r.Name,Forecast_product__c,ARR__c,Previous_ARR__c,CurrencyISOCode from Related_Account_plan__c where Id in :PlanProductIds ];
           
        
        system.debug('**lstPlanproduct'+lstPlanproduct);

        
        Set<id> CSMManagersIds = new Set<id>();
        Group CSMGroup =  [Select Id from Group where type='Queue' and Name=: Label.INFA_CSM_Managers_Queue] ;
        for (GroupMember gm: [Select UserOrGroupId From GroupMember where GroupId =: CSMGroup.id]){
            CSMManagersIds.add(gm.UserOrGroupId);
        }
        
        for(Related_Account_plan__c planproduct : lstPlanproduct){
            if(planproduct.Account_Plan__c!=null){
                system.debug('***planproduct.Account_Plan__r.ownerid'+planproduct.Account_Plan__r.ownerid);
                Set<id> userid= new Set<id>();
                userid.add(planproduct.Account_Plan__r.ownerid);
                mapPlanProductUser.put(planproduct.id,userid );
            }
            else{
                system.debug('***CSMManagersIds'+CSMManagersIds);

                mapPlanProductUser.put(planproduct.id,CSMManagersIds);
            }
        }
         system.debug('****mapPlanProductUser'+mapPlanProductUser);
        // Bulk post to the Plan product feeds.

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

            for (Related_Account_plan__c planproduct : lstPlanproduct) {
                                    
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.subjectId = planproduct.id;
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                                
                String mentions ='';
                for(Id userid :mapPlanProductUser.get(planproduct.id)){
                    system.debug('***userid'+userid);
                    mentions = mentions + returnMentionFormat(userid);
                }
                
                 String AccountName = planproduct.Account_Plan__c!=null && planproduct.Account_Plan__r.Account__c!=null ?planproduct.Account_Plan__r.Account__r.Name : '';
                 Id AccountId = planproduct.Account_Plan__c!=null && planproduct.Account_Plan__r.Account__c!=null ?planproduct.Account_Plan__r.Account__c :Null;
                 String OpportunityName = planproduct.Opportunity__c!=null ? planproduct.Opportunity__r.Name:'';
                 Id OptyId = planproduct.Opportunity__c!=null ?planproduct.Opportunity__c: Null;
                 
                 String postContent = ', There is a churn / ARR change in following products associated with your account'+'\n\n'+
                'Account Name :'+AccountName+'\n'+
				'Account Link :'+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+ AccountId+'\n \n'+
                'Opportunity Name :'+OpportunityName+'\n'+
                'Opportunity Link :'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ OptyId+'\n \n'+
                'Plan Product Name :'+planproduct.Forecast_Product__c+'\n'+
                'Plan Product Link :'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ planproduct.Id+'\n \n'+
                'Current ARR : '+ planproduct.CurrencyISOCode +' '+ planproduct.ARR__c +'\n \n'+
                'Pervious ARR : '+ planproduct.CurrencyISOCode +' '+ planproduct.Previous_ARR__c + '\n\n' ;
        
                String fullbody = mentions+postContent;
               
                //format the textwith mentions 
                body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(fullbody);
                
                input.body = body;

                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
                
                }
            
		system.debug('**batchInputs'+batchInputs);
        if(!Test.isRunningTest() &&  batchInputs!=null && batchInputs.size()>0){
        // API call to post in bulk mode
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    
    //---------------------------------------------------------------------------------------------------------</T01>
    
    }
                
    // Format the id to string
    public static String returnMentionFormat(Id userId){
        return '{'+userId+'} ';
    }

}