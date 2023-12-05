/*
 * Name			:	gcsEmailForwardController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/05/2021
 * Description	:	This LWC allows users to send emails, on Forward mode.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/05/2021		N/A				Initial version.			N/A
 */
 ({
	
	/*
	 Method Name : executeAction
	 Description : This method executes the requested action from the LWC.
	 Parameters	 : None
	 Return Type : None
	 */
	executeAction : function() {
        let objCloseQuickAction = $A.get("e.force:closeQuickAction");
        objCloseQuickAction.fire();
    },
})