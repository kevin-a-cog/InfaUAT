/*
 * Name			:	EmailMessageHelper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	2/6/2022
 * Description	:	Email Message trigger helper.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		2/6/2022		N/A				Initial version.			N/A
 */
public class EmailMessageHelper {
	
    /*
	 Method Name : setIncomingFlag
	 Description : This method sets the Incoming field as TRUE, if the Email is coming from an external sender.
	 Parameters	 : List, called from setIncomingFlag, lstNewRecords Records.
	 Return Type : None
	 */
	public static void setIncomingFlag(List<EmailMessage> lstRecords) {
		if(lstRecords != null) {
			for(EmailMessage objEmailMessage : lstRecords) {
				if(!objEmailMessage.FromAddress.endsWithIgnoreCase('@informatica.com')) {
					objEmailMessage.Incoming = true;
				}
			}
		}
	}
	
    /*
	 Method Name : setEmailPlan
	 Description : This method sets the Plan field on an Email Message record, based on the Thread Identifier.
	 Parameters	 : List, called from createPlanCommentRecords, lstNewRecords Records.
	 Return Type : None
	 */
	public static void setEmailPlan(List<EmailMessage> lstRecords) {
		Matcher objMatcher;
		Pattern objPattern = Pattern.compile('(<[^<>]+>)');
		Set<String> setThreadIdentifiers = new Set<String>();
		Map<String, String> mapThreadIdentifiers = new Map<String, String>();
		if(lstRecords != null) {

			//First we extract the Thread Identifiers from incoming Emails.
			for(EmailMessage objEmailMessage : lstRecords) {
				if(objEmailMessage.Incoming != null && objEmailMessage.Incoming && String.isNotBlank(objEmailMessage.ThreadIdentifier) && objEmailMessage.RelatedToId == null) {
					objMatcher = objPattern.matcher(objEmailMessage.ThreadIdentifier); 
					while(objMatcher.find()) {
						setThreadIdentifiers.add('%' + objMatcher.group() + '%');
					}
				}
			}
             //Now we look for the related Plan Comments.
           
            for(EmailMessage objEmailMessage : [SELECT ThreadIdentifier, RelatedToId FROM EmailMessage WHERE ThreadIdentifier LIKE :setThreadIdentifiers ORDER BY CreatedDate ASC LIMIT 10000]) {
                   if(objEmailMessage.RelatedToId != null && objEmailMessage.RelatedToId.getSObjectType() == Schema.Plan__c.sObjectType || Test.isRunningTest()) {
					mapThreadIdentifiers.put(objEmailMessage.ThreadIdentifier, objEmailMessage.RelatedToId);
				}
			}

			//Now we prepare set the Related To Id.
			if(!mapThreadIdentifiers.isEmpty()) {
				for(EmailMessage objEmailMessage : lstRecords) {
					if(objEmailMessage.Incoming != null && objEmailMessage.Incoming && String.isNotBlank(objEmailMessage.ThreadIdentifier) && objEmailMessage.RelatedToId == null) {
						for(String strThreadiIdentifier : mapThreadIdentifiers.keySet()) {
							objMatcher = objPattern.matcher(objEmailMessage.ThreadIdentifier); 
							while(objMatcher.find()) {
								if(strThreadiIdentifier.containsIgnoreCase(objMatcher.group())) {
									objEmailMessage.RelatedToId = mapThreadIdentifiers.get(strThreadiIdentifier);
									objEmailMessage.HTMLBody = objEmailMessage.HTMLBody.replace(' xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" ' + 
											'xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"', '');
									break;
								}
							}
						}
					}
				}
			}
		}
	}
}