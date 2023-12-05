/*
 * Name         :   CSMChurnForecastController
 * Author       :   Karthi G
 * Created Date :   31/03/2023
 * Description  :   Controller class for CsmChurnForecast lwc
 * Test Class   :   CSMChurnForecastControllerTest

 Change History
 ********************************************************************************************************************************
 Modified By            Date            Jira No.        Description                                         Tag
 ********************************************************************************************************************************
 Karthi G            31/03/2023        AR-3141         Initial version                                      NA
 Karthi G            22/11/2023        AR-3561         Changing the Opty close date criteria                T1
 */

public with sharing class CSMChurnForecastController {

    /*
	 Method Name : saveChurn
	 Description : This method saves the churn fields.
	 Parameters	 : List<Opportunity>
	 Return Type : void
	 */
    @AuraEnabled
    public static void saveChurnForecast(List<Opportunity> optyList){
        system.debug(optyList);
        CSMUpdateChurnForecast.saveChurn(optyList);
    }

    /*
	 Method Name : getDisplayChurnForecast
	 Description : This method determines eligibility for churn forecast on plan.
	 Parameters	 : Plan Id
	 Return Type : boolean
	 */
    @AuraEnabled(cacheable=true)
    public static Boolean getDisplayChurnForecast(Id planId){
        String query='select count() from Related_Opportunity_Plan__c  where Plan__c =:plan AND (Opportunity__r.CloseDate =NEXT_N_DAYS:365 AND Opportunity__r.CloseDate >NEXT_N_DAYS:120  AND (Opportunity__r.OARR_OnPrem_Subscription1__c>0 OR Opportunity__r.OARR_Cloud1__c>0))';  //T1
        Map<String,Object> bindMap = new Map<String, Object>{'plan'=>planId};
        integer  count= database.countQueryWithBinds(query,bindMap,AccessLevel.USER_MODE);

        return count>0;
    }

    /*
	 Method Name : getOptyRecords
	 Description : This method get the opty records eligible for churn forecast related to plan.
	 Parameters	 : planId
	 Return Type : List<Opportunity>
	 */
    @AuraEnabled(cacheable=true)
    public static List<ChurnWrapper> getOptyRecords(Id planId){
        Map<Id,ChurnWrapper> churnMap= new Map<Id,ChurnWrapper>();

        for(Opportunity opp:[select Id,Name,OARR_Cloud1__c,FORMAT(OARR_Cloud1__c) cloudOARR_format,convertCurrency(OARR_Cloud1__c) cloudOARR_converted,OARR_OnPrem_Subscription1__c, FORMAT(OARR_OnPrem_Subscription1__c) onPremOARR_format,convertCurrency(OARR_OnPrem_Subscription1__c) onPremOARR_converted, CloseDate,Cloud_Churn_Forecast_Percent__c,On_Prem_Churn_Forecast_Percent__c,Cloud_Swing_Forecast_Percent__c,On_Prem_Swing_Forecast_Percent__c,CSM_Comments__c,Cloud_Churn_Forecast__c,FORMAT(Cloud_Churn_Forecast__c) cloudChurn_format, convertCurrency(Cloud_Churn_Forecast__c) cloudChurn_converted,On_Premise_Churn_Forecast__c,FORMAT(On_Premise_Churn_Forecast__c) onPremChurn_format,convertCurrency(On_Premise_Churn_Forecast__c) onPremChurn_converted, Cloud_Swing_Forecast__c,FORMAT(Cloud_Swing_Forecast__c) cloudSwing_format, convertCurrency(Cloud_Swing_Forecast__c) cloudSwing_converted,On_Premise_Swing_Forecast__c, FORMAT(On_Premise_Swing_Forecast__c) onPremSwing_format, convertCurrency(On_Premise_Swing_Forecast__c) onPremSwing_converted,New_Org_Opportunity_Number__c, format(LastModifiedDate) lDate,LastModifiedBy.Name,CurrencyIsoCode from Opportunity where (CloseDate =NEXT_N_DAYS:365  AND CloseDate >NEXT_N_DAYS:120 AND (OARR_OnPrem_Subscription1__c>0 OR OARR_Cloud1__c>0)) AND Id IN (Select Opportunity__c from Related_Opportunity_Plan__c where Plan__c =:planId) WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1000]){ //T1
            ChurnWrapper wrp = new ChurnWrapper();
            wrp.opty=opp;
            churnMap.put(opp.Id,wrp);

        }

        for(AggregateResult arr:[select count(Plan__c) plans,Opportunity__c from Related_Opportunity_Plan__c where Opportunity__c IN :churnMap.keyset() group by Opportunity__c]){
            churnMap.get((Id)arr.get('Opportunity__c')).showMultiplePlanBanner = (Integer)arr.get('plans')>1;
        }

        for(AggregateResult ar:[select Parent_Record_Id__c,CreatedBy.Name cName,FORMAT(Max(CreatedDate)) cDate from Tracked_Details__c where Object_Name__c='Opportunity' AND Parent_Record_Id__c IN :churnMap.keyset() group by  CreatedBy.Name,Parent_Record_Id__c  order by Max(CreatedDate) asc]){
            churnMap.get((Id)ar.get('Parent_Record_Id__c')).lastModifieddate = (String)ar.get('cDate');
            churnMap.get((Id)ar.get('Parent_Record_Id__c')).lastModifiedby = (String)ar.get('cName');
        }

        return churnMap.values();
    }

    @InvocableMethod(label='Notify Churn Updates' description='Notify Churn Updates')
    public static void notifyChurnUpdates(List<Id> ids) {
        globalApexManager GAM = new globalApexManager();
        if(ids.size()<>0){
            
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();       
            for(Opportunity op:[SELECT Id,OwnerId,CSM_Comments__c from Opportunity where Id IN :ids]){                
                    ConnectApi.BatchInput batchInput = getChatterPost(op,'Opportunity'); 
                    batchInputs.add(batchInput);
                
            }
            
            for(Related_Opportunity_Plan__c rop:[Select Plan__c, Plan__r.OwnerId, Opportunity__c, Opportunity__r.CSM_Comments__c from Related_Opportunity_Plan__c where Opportunity__c IN :ids AND Plan__c!=null]){                
                ConnectApi.BatchInput batchInput = getChatterPost(rop,'Plan__c'); 
                batchInputs.add(batchInput);
            
        }
            if(!Test.isRunningTest()){
                try{
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
                }
                catch(Exception e){
                 GAM.CreateExceptionRecords('InvokableGenerateChatterPost.invokeChatterPost() -> ' + e.getCause(),e.getmessage(), ids[0]);
                }
            }
        }
    }

    public static ConnectApi.BatchInput getChatterPost(sObject obj, String objType){
        String message ='';            
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

        message= '\n\r';
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.TextSegmentInput textSegment11 = new ConnectApi.TextSegmentInput();
        textSegment11.text = message;
        body.messageSegments.add(textSegment11);

        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = objType=='Opportunity'?(Id)obj.get('OwnerId'):(Id)obj.getSObject('Plan__r').get('OwnerId');
        body.messageSegments.add(mentionSegmentInput);

        message = '\n\n';
        body = InvokableGenerateChatterPost.getTextParagraph(message,body);
        //chatter body
        if(objType=='Opportunity'){            
            input.subjectId = (Id)obj.get('Id');
            message = 'The churn forecast for this opportunity has been updated with new details.\n';
            body = InvokableGenerateChatterPost.getTextParagraph(message,body);
            message = 'Comment: '+(String)obj.get('CSM_Comments__c')+'\n';
            body = InvokableGenerateChatterPost.getTextParagraph(message,body);
        }
        else if(objType=='Plan__c'){
            
            input.subjectId = (Id)obj.get('Plan__c');
            message = 'The Churn forecast details of the below renewal opportunity related to this Plan is updated.\n';
            body = InvokableGenerateChatterPost.getTextParagraph(message,body);            
            message = 'Comment: '+(String)obj.getSObject('Opportunity__r').get('CSM_Comments__c')+'.\n';
            body = InvokableGenerateChatterPost.getTextParagraph(message,body);
            body.messageSegments.add(ChatterService.inputLink((Id)obj.get('Opportunity__c')));
        }

        input.body = body;
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);

        return batchInput;
    }

    public class ChurnWrapper{
        @AuraEnabled
        public Opportunity opty{get; set;}
        @AuraEnabled
        public boolean showMultiplePlanBanner{get; set;}
        @AuraEnabled
        public String lastModifiedby{get; set;}
        @AuraEnabled
        public String lastModifieddate{get; set;}
    }
}