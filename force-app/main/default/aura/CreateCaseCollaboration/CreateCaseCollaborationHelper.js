/*
 Change History
 *******************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                     Tag
 *******************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                                NA
 Vignesh Divakaran      04-May-2022     I2RT-6061           Commenting pre-draft logic as it is not being used currently    T01
 */
({
    handleInit: function (component, isOpenCreate) {
        const getPermission = component.get("c.getPermissionOnObject");
        getPermission.setCallback(this, response => {
            var state = response.getState();
            if (state === "SUCCESS") {
                const returnValue = response.getReturnValue();
            	component.set("v.permissionValue", returnValue);	
            }
        });
        $A.enqueueAction(getPermission);
        /* Commented as part of <T01>
        const getPreDraftCommentAction = component.get("c.getPreDraftComment");
        getPreDraftCommentAction.setParams({ caseRecordId: component.get("v.recordId") });

        getPreDraftCommentAction.setCallback(this, response => {
            var state = response.getState();
            if (state === "SUCCESS") {
                const returnValue = response.getReturnValue();
                console.log('HERE>>' + JSON.stringify(returnValue));
                if (returnValue && returnValue.length > 0) {
                    component.set("v.preDraftCommentOriginal", returnValue[0]);
                    component.set("v.preDraftComment", returnValue[0]);
            		component.set("v.preDraftCommentAnother",returnValue[0]);
                    component.set("v.isAddComment", isOpenCreate);
                }
            } else {
                console.log('ERR>>' + JSON.stringify(response.getError()));
            }
        });

        $A.enqueueAction(getPreDraftCommentAction);*/
    }
})