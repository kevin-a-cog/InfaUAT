/*
 * Name			:	EmailMessageHandler
 * Author		:	Monserrat Pedroza
 * Created Date	: 	2/6/2022
 * Description	:	Email Message trigger handler.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		2/6/2022		N/A				Initial version.			N/A
 */
public class EmailMessageHandler {
	
    /*
	 Method Name : beforeInsert
	 Description : This method gets executed on Before Insert.
	 Parameters	 : List, called from beforeInsert, lstNewRecords New records.
	 Return Type : None
	 */
	public static void beforeInsert(List<EmailMessage> lstNewRecords) {

		//We mark as Incoming the corresponding records.
		EmailMessageHelper.setIncomingFlag(lstNewRecords);
	}
}