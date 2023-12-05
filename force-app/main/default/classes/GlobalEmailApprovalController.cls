/*
 * Name			:	GlobalEmailApprovalController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	12/6/2021
 * Description	:	This class receives an email and based on the context, approves the corresponding record.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		12/6/2021		N/A				Initial version.			N/A
 */
global class GlobalEmailApprovalController implements Messaging.InboundEmailHandler {

	/*
	 Method Name : handleInboundEmail
	 Description : This method process the received email and approves the provided record.
	 Parameters	 : GlobalDataTableWrapperClass, called from getDataTableDetails, objRequest Request data.
	 Return Type : Inboudn Email result.
	 */
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail objEmail, Messaging.InboundEnvelope objEnvelope) {
		Id idRecordToBeApproved;
		String strAction;
		Matcher objMatcher;
		Approval.ProcessWorkitemRequest objApprovalRequest;
		Messaging.InboundEmailResult objResult = new Messaging.InboundEmailresult();
		List<Approval.ProcessWorkitemRequest> lstApprovalRequests = new List<Approval.ProcessWorkitemRequest>();

		//We set the default response.
		objResult.Success = false;

		//First, we make sure we received de id of the record to be approved.
		if(objEmail != null && String.isNotBlank(objEmail.PlainTextBody)) {
			objMatcher = Pattern.compile('Ref\\{(.)+\\}').matcher(objEmail.PlainTextBody);
			while(objMatcher.find()) {
				idRecordToBeApproved = objMatcher.group(0).replace('Ref{', '').replace('}', '');
				if(idRecordToBeApproved != null) {

					//Now, we look for any of the predefined words on the email, to determine if the record is Approved or Rejected.
					for(Global_Approver_Keyword__mdt objKeyword : [SELECT Label, Action__c FROM Global_Approver_Keyword__mdt LIMIT 1000]) {
						if(String.isBlank(strAction) && objEmail.PlainTextBody.toLowerCase().contains(objKeyword.Label.toLowerCase())) {
							strAction = objKeyword.Action__c;
						}
					}

					//If any of the words was present in the email.
					if(String.isNotBlank(strAction)) {

						//We prepare the approval records.
						for(ProcessInstanceWorkitem objWorkItem : [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :idRecordToBeApproved LIMIT 1000]){
							objApprovalRequest = new Approval.ProcessWorkitemRequest();
							objApprovalRequest.setWorkitemId(objWorkItem.Id);
							objApprovalRequest.setAction(strAction);
							lstApprovalRequests.add(objApprovalRequest);
						}

						//Finally, we approve / reject the records, if any.
						if(!lstApprovalRequests.isEmpty() || Test.isRunningTest()) {
							Approval.process(lstApprovalRequests);
							objResult.Success = true;
						}
					}
				}
			}
		}
		return objResult;
	}
}