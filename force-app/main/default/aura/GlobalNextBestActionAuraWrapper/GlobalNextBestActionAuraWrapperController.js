/*
 * Name			:	GlobalNextBestActionAuraWrapper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/14/2021
 * Description	:	Next Best Action Aura Wrapper Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/14/2021		N/A				Initial version.			N/A
 */
({
	
	/*
	 Method Name : executeAction
	 Description : This method executes the requested action from the LWC.
	 Parameters	 : Object, called from executeAction, objComponent Component of the Aura Bundle.
	 			   Object, called from executeAction, objEvent Event.
	 Return Type : None
	 */
	executeAction : function(objComponent, objEvent) {
        const strActionTarget = objEvent.getParam('strActionTarget');
		const strActionData = objEvent.getParam('strActionData');
		const strActionType = objEvent.getParam('strActionType');
		let objData;
		let objBody;

		//Now we convert the received data into a JSON object.
		try {
			objData = JSON.parse(strActionData);
		} catch(objException) {
			objData = new Object();
		}

		//We add the "on close" action.
		objData.onclose = objComponent.getReference("c.removeDynamicComponent");
		objData.onclosemodal = objComponent.getReference("c.removeDynamicComponent");

		//Now we create the component.
		$A.createComponent(strActionTarget, objData, function(objCreatedComponent, strStatus, strErrorMessage) {
			if(strStatus === "SUCCESS") {
                objBody = objComponent.get("v.body");
                objBody.push(objCreatedComponent);
                objComponent.set("v.body", objBody);

				//Now we define if we need to display the component inside a modal.
				if(strActionType === "Launch Component In Modal") {
					objComponent.set("v.boolIsModalOpen", true);
				} else {
					objComponent.set("v.boolIsModalOpen", false);
				}
                
            } else {
				console.error("Error: " + strErrorMessage);
			}
		});
    },

	/*
	 Method Name : removeDynamicComponent
	 Description : This method removes the component created dynamically.
	 Parameters	 : Object, called from executeAction, objComponent Component of the Aura Bundle.
	 Return Type : None
	 */
    removeDynamicComponent : function(objComponent) {
		objComponent.set("v.body", new Object());

		//If the modal was open, we close it.
		if(objComponent.get("v.boolIsModalOpen")) {
			objComponent.set("v.boolIsModalOpen", false);
		}
    },
  
	/*
	 Method Name : closeModal
	 Description : This method closes the modal and removes the dynamic component.
	 Parameters	 : Object, called from closeModal, objComponent Component of the Aura Bundle.
	 Return Type : None
	 */
	closeModal: function(objComponent) {
		objComponent.set("v.boolIsModalOpen", false);
		objComponent.set("v.body", new Object());
    }
})