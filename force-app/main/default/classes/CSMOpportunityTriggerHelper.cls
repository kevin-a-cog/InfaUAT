/*
 * Name			:	CSMOpportunityTriggerHelper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	5/5/2022
 * Description	:	Send Notification for SMG for Renewal Opportunity closing in 120 days

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description				   Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 Narpavi Prbau          9/6/2022 		AR-2447         Send Notification to SMG Queue and Renewal Opty Owner 120 days ahead of Close Date T01
 Narpavi Prabu          29/6/2022       AR-2798         Added condition to send notification only for the Opty with Active Plan  T02
 */ 
public class CSMOpportunityTriggerHelper {

	/* <T01> : Method invocked from process builer to notificy SMG for Renewal Opportunity closing in 120 days*/

	@InvocableMethod(label='Upcoming Renewal SMG Notify' description='120 days Upcoming Renewal')
    
    public static void renewalOpportunitiesClosingIn120Days(List<Id> OpportunityIds){
        postFeedElementWithMention(OpportunityIds);  //T01- pass full list of optys 
    }


	/*
	 Method Name : renewalOpportunitiesClosingIn120Days
	 Description : This method creates a Chatter Feed Items for those Opportunities where they are expiring in 120 days.
	 Return Type : None
	 */
    public static void postFeedElementWithMention(List<Id> OpportunityIds) {
		Boolean boolHasPlan;
		Id idPlan;
		Id idPlanOwner;
		Id idQueue;
		Date obj120DaysInFuture = Date.today().addDays(120);
		ConnectApi.FeedItemInput objFeedItemInput;
		ConnectApi.MentionSegmentInput objMentionSegmentInput;
		ConnectApi.MessageBodyInput objMessageBodyInput;
		ConnectApi.TextSegmentInput objTextSegmentInput;
		ConnectApi.MarkupBeginSegmentInput objMarkupBeginSegment;
		ConnectApi.MarkupEndSegmentInput objMarkupEndSegment;
		Set<Id> setOpportunityIds = new Set<Id>();
		List<ConnectApi.BatchInput> lstFeedItems = new List<ConnectApi.BatchInput>();
		List<Opportunity>  lstOpportunity = new List<Opportunity>();  // List of renewal optys created/updated

        

			lstOpportunity = [SELECT Id, Name, OwnerId, CloseDate, (SELECT Plan__c, Plan__r.OwnerId,Plan__r.Status__c FROM Related_Opportunity_Plans__r ORDER BY 
			CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Id IN :OpportunityIds] ;

			//Now we make sure the opportunities meet the criteria.
			for(CollaborationGroup objGroup : [SELECT Id FROM CollaborationGroup WHERE Name = 'SMG' LIMIT 1]) {
				idQueue = objGroup.Id;
			}
	
			for(Opportunity objRecord :lstOpportunity ) {
					
				//First we initialize the required variables.
				boolHasPlan = false;
				idPlan = null;
				idPlanOwner = null;
				objFeedItemInput = new ConnectApi.FeedItemInput();
				objMessageBodyInput = new ConnectApi.MessageBodyInput();
				objTextSegmentInput = new ConnectApi.TextSegmentInput();

				
				//Now we make sure we have a Plan associated.
				//<T02> - Added condition to check the opty related plan is active
				if(objRecord.Related_Opportunity_Plans__r != null && !objRecord.Related_Opportunity_Plans__r.isEmpty() && objRecord.Related_Opportunity_Plans__r.get(0).Plan__r != null && 
							objRecord.Related_Opportunity_Plans__r.get(0).Plan__r.OwnerId != null && objRecord.Related_Opportunity_Plans__r.get(0).Plan__r.Status__c == 'Active' ) {

					//We get the ids.
					boolHasPlan = true;
					idPlan = objRecord.Related_Opportunity_Plans__r.get(0).Plan__c;
					idPlanOwner = objRecord.Related_Opportunity_Plans__r.get(0).Plan__r.OwnerId;
				}
				if(boolHasPlan) 
				{
					//We prepare the list of segments.
					objMessageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

					//We add the text of the item - Renewal Opportunity.
					objMarkupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
					objMarkupBeginSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupBeginSegment);
					objTextSegmentInput = new ConnectApi.TextSegmentInput();
					objTextSegmentInput.text = 'Renewal Opportunity: ' + objRecord.Name + ' ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + objRecord.Id + ' is closing in next 120 days.';
					objMessageBodyInput.messageSegments.add(objTextSegmentInput);
					objMarkupEndSegment = new ConnectApi.MarkupEndSegmentInput();
					objMarkupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupEndSegment);

					//We add the text of the item - Close Date.
					objMarkupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
					objMarkupBeginSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupBeginSegment);
					objTextSegmentInput = new ConnectApi.TextSegmentInput();
					objTextSegmentInput.text = 'Close Date: ' + objRecord.CloseDate.format();
					objMessageBodyInput.messageSegments.add(objTextSegmentInput);
					objMarkupEndSegment = new ConnectApi.MarkupEndSegmentInput();
					objMarkupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupEndSegment);

				//We add the text of the item - Casssini.
				
					objMarkupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
					objMarkupBeginSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupBeginSegment);
					objTextSegmentInput = new ConnectApi.TextSegmentInput();
					objTextSegmentInput.text = 'Please connect with CSM on the Plan ' + 'https://cassini.informatica.com/cassini-ui/plan/' + idPlan;
					objMessageBodyInput.messageSegments.add(objTextSegmentInput);
					objMarkupEndSegment = new ConnectApi.MarkupEndSegmentInput();
					objMarkupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupEndSegment);
				

					//We add a blank space to separate the main text from the mentions.
					objMarkupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
					objMarkupBeginSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupBeginSegment);
					objTextSegmentInput = new ConnectApi.TextSegmentInput();
					objTextSegmentInput.text = '.';
					objMessageBodyInput.messageSegments.add(objTextSegmentInput);
					objMarkupEndSegment = new ConnectApi.MarkupEndSegmentInput();
					objMarkupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupEndSegment);

					//We add a mention to the SMG queue.
					objMentionSegmentInput = new ConnectApi.MentionSegmentInput();
					objMentionSegmentInput.id = idQueue;
					if(idQueue != null) {
						objMessageBodyInput.messageSegments.add(objMentionSegmentInput);
					}

					//We add a mention to the Plan Owner				
					objMentionSegmentInput = new ConnectApi.MentionSegmentInput();
					objMentionSegmentInput.id = idPlanOwner;
					objMessageBodyInput.messageSegments.add(objMentionSegmentInput);
				

					//We add a mention to the Opportunity Owner.
					objMentionSegmentInput = new ConnectApi.MentionSegmentInput();
					objMentionSegmentInput.id = objRecord.OwnerId;
					objMessageBodyInput.messageSegments.add(objMentionSegmentInput);

					//Now we prepare the rest of the item.
					objFeedItemInput.body = objMessageBodyInput;
					objFeedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
					objFeedItemInput.subjectId = objRecord.Id;

					//We add it to the list.
					lstFeedItems.add(new ConnectApi.BatchInput(objFeedItemInput));
				}
			}
      
			//If we have feed items, we send them.
			if(!Test.isRunningTest() && !lstFeedItems.isEmpty()) {
				ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstFeedItems);
			}
		
    }
}