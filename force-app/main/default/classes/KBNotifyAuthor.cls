/*
   @created by       : Ranjan
   @created on       : 01/28/2021
   @Purpose          : Helper class used in KnowledgeUpdateBatch class to notify author.
   @Testclass        :
   @JIRA             : I2RT-862


   Change History

 ****************************************************************************************************
 |  Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |   1      |  28-Jan-2021      |   Ranjan                  |    I2RT-862       |   Added changes related to Notify Author
 ****************************************************************************************************

 */
public class KBNotifyAuthor {

	public static String KB_DELETED_RECORD_RECIPIENTS = Label.KB_Deleted_Record_Recipients;

	public static ConnectApi.BatchInput createChatterPostContent(knowledge__kav knwRec, String articleDeletionDate){

		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		// Text content of a chatter body
		ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput4 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput nextLineTextSegment = new ConnectApi.TextSegmentInput();

		// To make the text bold
		ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();

		// To have sentences in next line
		ConnectApi.MarkupBeginSegmentInput paragraphBegin1 = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput paragraphEnd1 = new ConnectApi.MarkupEndSegmentInput();

		// To have the hyperlink of the KB record
		ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
		entityLinkSegmentInput.entityId = knwRec.Id;


		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

		String content1 = '" is pending action from you for more than 35 days and will be deleted on '+articleDeletionDate+'.';

		String content2 = 'To retain the article, please submit it for review at the earliest.';

		String content3 = 'Please note that the deleted article cannot be retrieved.';

		textSegmentInput1.text = '"Article '+ knwRec.ArticleNumber+' - ';
		textSegmentInput2.text = content1;
		textSegmentInput3.text = content2;
		textSegmentInput4.text = content3;
		nextLineTextSegment.text ='&nbsp;';

		// First sentence start
		messageBodyInput.messageSegments.add(textSegmentInput1);
		messageBodyInput.messageSegments.add(entityLinkSegmentInput);
		messageBodyInput.messageSegments.add(textSegmentInput2);
		// First sentence end

		// second sentence start
		paragraphBegin1.markupType = ConnectApi.MarkupType.paragraph;
		paragraphEnd1.markupType = ConnectApi.MarkupType.paragraph;
		messageBodyInput.messageSegments.add(paragraphBegin1);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd1);
		messageBodyInput.messageSegments.add(textSegmentInput3);
		messageBodyInput.messageSegments.add(paragraphBegin1);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd1);
		// second sentence end

		// Third sentence (Bold) start
		markupBeginSegment.markupType = ConnectApi.MarkupType.bold;
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput4);
		markupEndSegment.markupType = ConnectApi.MarkupType.bold;
		messageBodyInput.messageSegments.add(markupEndSegment);
		// Third sentence (Bold) end

		system.debug('messagebody'+messageBodyInput);
		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = knwRec.Created_By__c;

		ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);

		return batchInput;
	}

	public static Messaging.SingleEmailMessage createEmailAlertContent(knowledge__kav knwRec,String kbURL,String articleDeletionDate){

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if(String.isBlank(knwRec.Created_By__c)) {
			mail.setToAddresses(new String[] {knwRec.Created_By__r.Email});
		}else{
			mail.setToAddresses(new String[] {knwRec.Original_Author__r.Email});
		}
		String Subject = ' Article '+knwRec.ArticleNumber+' needs your immediate attention';
		mail.setSubject(Subject);
		String content1 = '"Article '+ knwRec.ArticleNumber+' - <a href="'+kbURL+'/'+knwRec.Id+'/view'+'">'+knwRec.Title+'</a>'+ '" is pending action from you for more than 35 days and will be deleted on '+articleDeletionDate+'.<br/><br/>';
		String content2 = 'To retain the article, please submit it for review at the earliest.<br/><br/><span style="color:red">Please note that the deleted article cannot be retrieved.</span>';

		// Set the HTML mail body
		mail.setHtmlBody(content1+content2);

		return mail;
	}

	public static Messaging.SingleEmailMessage createEmailAlertContentOnDeletion(List<sObject> scopeobject){

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String [] strRecipients = new List<String>();


		for(String element : KB_DELETED_RECORD_RECIPIENTS.split (';')) {
			strRecipients.add(element);
		}

		mail.setToAddresses(strRecipients);

		String Subject = 'Unsubmitted KBs deleted after 45 days';
		mail.setSubject(Subject);
		String strKBDeletionCount = 'Number of articles deleted : '+ String.valueOf(scopeobject.size()) +'<br/><br/>';
		String strKBTableStart = '<table style="width:100%;text-align: center;">';
		String strKBTableRowHeading ='  <tr>' +
		                              '    <th>Article Number</th>' +
		                              '    <th>Title</th>' +
		                              '    <th>Product</th>' +
		                              '    <th>CreatedDate</th>' +
		                              '    <th>LastModifiedDate</th>' +
		                              '    <th>Createdby</th>' +
		                              '    <th>LastModifiedby</th>' +
		                              '  </tr>';

		String strKBTableEnd = '</table>';
		String strKBTableRowContent = '';

		for(sobject s : scopeobject) {
			Knowledge__kav kav = (Knowledge__kav)s;
			strKBTableRowContent += '  <tr>' +
			                        '    <td>'+kav.ArticleNumber+'</td>' +
			                        '    <td>'+kav.Title+'</td>' +
			                        '    <td>'+((String.isBlank(kav.Primary_Product__c)) ? '' : kav.Primary_Product__c )+'</td>' +
			                        '    <td>'+kav.CreatedDate.format()+'</td>' +
			                        '    <td>'+kav.LastModifiedDate.format()+'</td>' +
			                        '    <td>'+((String.isBlank(kav.Created_By__r.Name)) ? '' : kav.Created_By__r.Name )+'</td>' +
			                        '    <td>'+kav.LastModifiedBy.Name+'</td>' +
			                        '  </tr>';
		}

		system.debug('emailcontent'+ strKBDeletionCount + strKBTableStart + strKBTableRowHeading + strKBTableRowContent + strKBTableEnd);

		// Set the HTML mail body
		mail.setHtmlBody(strKBDeletionCount + strKBTableStart + strKBTableRowHeading + strKBTableRowContent + strKBTableEnd);

		return mail;
	}
	public static void sendNotificationContentOnRejection(knowledge__kav knwRec,String strRejectedUserRole){
		try{
			Messaging.CustomNotification notification = new Messaging.CustomNotification();
			Set<String> strRecipients = new Set<String>();
			String strRejectedUser = '';
			String strRejectedUserId = '';

			if(strRejectedUserRole == 'Content Reviewer')
			{
				List<User> lstUserCR = [Select Id, Name From User Where Id = :knwRec.Rejected_By_Content_Reviewer__c];
				if(!lstUserCR.isEmpty())
					strRejectedUser = lstUserCR[0].Name;
				strRejectedUserId = lstUserCR[0].Id;
			}
			else if(strRejectedUserRole == 'Technical Reviewer')
			{
				List<User> lstUserTR = [Select Id, Name From User Where Id = :knwRec.Rejected_By_Technical_Reviewer__c];
				if(!lstUserTR.isEmpty())
					strRejectedUser = lstUserTR[0].Name;
				strRejectedUserId = lstUserTR[0].Id;
			}

			strRecipients.add(knwRec.Original_Author__c);
			strRecipients.add(knwRec.LastModifiedById);
			strRecipients.add(knwRec.Created_By__c);

			List<ProcessInstanceStep> lstProcessInstanceStep = [SELECT Id,Comments,ProcessInstance.Status from ProcessInstanceStep where ProcessInstance.TargetObjectId =: knwRec.Id order by CreatedDate desc limit 1];

			String strProcessInstanceStep = '';

			if(!lstProcessInstanceStep.isEmpty() &&  lstProcessInstanceStep[0].ProcessInstance.Status == 'Rejected' && lstProcessInstanceStep[0].Comments != null)
				strProcessInstanceStep = 'Reason for rejection  : ' + lstProcessInstanceStep[0].Comments + '\n';

			String strTitle ='Article '+ knwRec.ArticleNumber+ ' - has been rejected by ' + strRejectedUserRole +' <' + strRejectedUser + '>.';
			String strTextBodyContent = 'Article ' + knwRec.ArticleNumber+ ' - ' + knwRec.Title + ' has been rejected by ' + strRejectedUserRole +' <' + strRejectedUser + '>.\n' +
			                            ''+'\n'+
			                            ''+ strProcessInstanceStep +
			                            ''+ ((String.isBlank(knwRec.Primary_Product__c)) ? '' : 'Product: ' + knwRec.Primary_Product__c + '\n' ) +
			                            ''+ ((String.isBlank(knwRec.Product_Version__c)) ? '' : 'Product Version: ' + knwRec.Product_Version__c + '\n' ) +
			                            ''+ ((String.isBlank(knwRec.Product_Component__c)) ? '' : 'Product Component: ' + knwRec.Product_Component__c );

			notification.setBody(strTextBodyContent);
			notification.setTitle(strTitle);
			notification.setSenderId(strRejectedUserId);
			CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Notification_Service_Desktop_Mobile'];
			notification.setNotificationTypeId(type.id);
			notification.setTargetId(knwRec.Id);
			if(!Test.isRunningTest()) { notification.send(strRecipients);}
		}
		catch(Exception ex) {
			System.debug('sendNotificationContentOnRejection Method : exception occurred - ' + ex.getMessage());
		}
	}

	public static void sendChatterPostOnRejection(knowledge__kav knwRec, String strRejectedUserRole){

		try {

			String strRejectedUser = '';

			if(strRejectedUserRole == 'Content Reviewer')
			{
				List<User> lstUserCR = [Select Id, Name From User Where Id = :knwRec.Rejected_By_Content_Reviewer__c];
				if(!lstUserCR.isEmpty())
					strRejectedUser = lstUserCR[0].Name;
			}
			else if(strRejectedUserRole == 'Technical Reviewer')
			{				
				List<User> lstUserCR = [Select Id, Name From User Where Id = :knwRec.Rejected_By_Technical_Reviewer__c];
				if(!lstUserCR.isEmpty())
					strRejectedUser = lstUserCR[0].Name;
			}

			ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			// Text content of a chatter body
			ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
			ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
			ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
			ConnectApi.TextSegmentInput textSegmentInput4 = new ConnectApi.TextSegmentInput();
			ConnectApi.TextSegmentInput nextLineTextSegment = new ConnectApi.TextSegmentInput();

			// To make the text bold
			ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
			ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();

			// To have sentences in next line
			ConnectApi.MarkupBeginSegmentInput paragraphBegin1 = new ConnectApi.MarkupBeginSegmentInput();
			ConnectApi.MarkupEndSegmentInput paragraphEnd1 = new ConnectApi.MarkupEndSegmentInput();

			// To have the hyperlink of the KB record
			ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
			entityLinkSegmentInput.entityId = knwRec.Id;


			messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

			String content1 = '"  - has been rejected by ' + strRejectedUserRole +' <' + strRejectedUser + '>.';

			String content2 = ((String.isBlank(knwRec.Primary_Product__c)) ? '' : 'Product: ' + knwRec.Primary_Product__c );

			String content3 = '';

			List<ProcessInstanceStep> lstProcessInstanceStep = [SELECT Id,Comments,ProcessInstance.Status from ProcessInstanceStep where ProcessInstance.TargetObjectId =: knwRec.Id order by CreatedDate desc limit 1];

			if(!lstProcessInstanceStep.isEmpty() &&  lstProcessInstanceStep[0].ProcessInstance.Status == 'Rejected' && lstProcessInstanceStep[0].Comments != null)
				content3 = 'Reason for rejection  : ' + lstProcessInstanceStep[0].Comments;

			textSegmentInput1.text = '"Article '+ knwRec.ArticleNumber +' - ';
			textSegmentInput2.text = content1;
			textSegmentInput3.text = content2;
			textSegmentInput4.text = content3;
			nextLineTextSegment.text ='&nbsp;';

			// First sentence start
			messageBodyInput.messageSegments.add(textSegmentInput1);
			messageBodyInput.messageSegments.add(entityLinkSegmentInput);
			messageBodyInput.messageSegments.add(textSegmentInput2);
			// First sentence end

			// second sentence start
			paragraphBegin1.markupType = ConnectApi.MarkupType.paragraph;
			paragraphEnd1.markupType = ConnectApi.MarkupType.paragraph;
			messageBodyInput.messageSegments.add(paragraphBegin1);
			messageBodyInput.messageSegments.add(nextLineTextSegment);
			messageBodyInput.messageSegments.add(paragraphEnd1);
			messageBodyInput.messageSegments.add(textSegmentInput3);
			messageBodyInput.messageSegments.add(paragraphBegin1);
			messageBodyInput.messageSegments.add(nextLineTextSegment);
			messageBodyInput.messageSegments.add(paragraphEnd1);
			// second sentence end

			// Third sentence (Bold) start
			markupBeginSegment.markupType = ConnectApi.MarkupType.bold;
			messageBodyInput.messageSegments.add(markupBeginSegment);
			messageBodyInput.messageSegments.add(textSegmentInput4);
			markupEndSegment.markupType = ConnectApi.MarkupType.bold;
			messageBodyInput.messageSegments.add(markupEndSegment);
			// Third sentence (Bold) end

			system.debug('messagebody'+messageBodyInput);
			feedItemInput.body = messageBodyInput;
			feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
			feedItemInput.subjectId = knwRec.Created_By__c;


			ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);

			if(!Test.isRunningTest()) { ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), new ConnectApi.BatchInput[] { batchInput });}

		} catch(Exception ex) {
			System.debug('sendNotificationContentOnRejection Method : exception occurred - ' + ex.getMessage());
		}
	}

	public static void sendEmailAlertContentOnRejection(knowledge__kav knwRec,String strRejectedUserRole){

		try {

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> strRecipients = new List<String>();
			String strRejectedUser = '';
			String strRejectedUserEmail = '';


			// if(strRejectedUserRole == 'Content Reviewer')
			// {
			// 	strRejectedUser = knwRec.Rejected_By_Content_Reviewer__c;
			// }
			// else if(strRejectedUserRole == 'Technical Reviewer')
			// {
			// 	strRejectedUser = knwRec.Rejected_By_Technical_Reviewer__c;
			// }

			List<String> lstToAddressUserId = new List<String>();
			if(!String.isBlank(knwRec.Created_By__c))
				lstToAddressUserId.add(knwRec.Created_By__c);
			if(!String.isBlank(knwRec.LastModifiedById))
				lstToAddressUserId.add(knwRec.LastModifiedById);
			if(!String.isBlank(knwRec.Original_Author__c))
				lstToAddressUserId.add(knwRec.Original_Author__c);

			List<User> lstToAddressUser = [SELECT Id,Email from User where Id IN :lstToAddressUserId];
			
			for(User usr : lstToAddressUser) {
				strRecipients.add(usr.Email);
			}

			if(strRecipients.size() > 0)
			{
				List<ProcessInstanceStep> lstProcessInstanceStep = [SELECT Id,Comments,ProcessInstance.Status from ProcessInstanceStep where ProcessInstance.TargetObjectId =: knwRec.Id order by CreatedDate desc limit 1];

				String strProcessInstanceStep = '';

				if(!lstProcessInstanceStep.isEmpty() &&  lstProcessInstanceStep[0].ProcessInstance.Status == 'Rejected' && lstProcessInstanceStep[0].Comments != null)
					strProcessInstanceStep = '<p> Reason for rejection  : ' + lstProcessInstanceStep[0].Comments + '</p>';

				String Subject = 'Article '+ knwRec.ArticleNumber+ ' - has been rejected by ' + strRejectedUser;
				String strHtmlBodyContent = '<p>Article <a href='+ knwRec.URL__c + '/'+ knwRec.Id + '/view>' + knwRec.ArticleNumber + ' - ' +
				                            ''+ knwRec.Title + '</a> has been rejected by ' + strRejectedUser + '.</p>' +
				                            ''+ strProcessInstanceStep +
				                            ''+ ((String.isBlank(knwRec.Primary_Product__c)) ? '' : '<p>Product: '+ knwRec.Primary_Product__c+ '</p>' ) +
				                            ''+ ((String.isBlank(knwRec.Product_Version__c)) ? '' : '<p>Product Version: '+ knwRec.Product_Version__c+ '</p>' ) +
				                            ''+ ((String.isBlank(knwRec.Product_Component__c)) ? '' : '<p>Product Component: '+ knwRec.Product_Component__c+ '</p>' );


				// Set the HTML mail body
				mail.setToAddresses(strRecipients);
				mail.setSubject(Subject);
				mail.setHtmlBody(strHtmlBodyContent);
				mail.setSaveAsActivity(false);
				if(!Test.isRunningTest()) { Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); }
			}
			
		} catch(Exception ex) {
			System.debug('sendEmailAlertContentOnRejection Method : exception occurred - ' + ex.getMessage());
		}
	}
		  
}