/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Amarender              29-Nov-2021     I2RT-4782           Pre Draft - typed Comments disappear from draft section   T01
                                                            when the component is popped out and popped in 
 Amit             		05-May-2022     I2RT-5967           Fixed the issue											  T02
 balajip          		21-Nov-2022     I2RT-7508           to check if the message is for the given case             T03
 */
({
    handleAddComment: function (component) {
        if (component.get("v.preDraftCommentOriginal")) {
            component.set("v.preDraftComment", component.get("v.preDraftCommentOriginal"));
        	
        }
		component.set("v.preDraftCommentAnother",component.get("v.preDraftComment"));
        component.set("v.isAddComment", true);
    },

    handleCloseCreate: function (component, event, helper) {
        //console.log('@@--->>', JSON.stringify(component.get("v.preDraftComment")));
        component.set("v.isPopout", false);
        component.set("v.isAddComment", false);
       // component.set("v.preDraftComment", null);
        // Deva : start : I2RT-2630 :Commented the code as business dont want to retrieve Pre draft comment
        //<T02> starts
        component.set("v.preDraftCommentAnother",component.get("v.preDraftComment"));
       // helper.handleInit(component, false);
        //<T02> ends
    },

    handleClose: function (component) {
        //T03
        var caseId = component.get('v.recordId');

        component.set("v.isPopout", false);
        component.set("v.isAddComment", false);
        //component.set("v.preDraftComment", null); //<T02>
        component.set("v.preDraftCommentOriginal", null);
        component.find("msgChannel").publish({caseId: caseId}); //T03
         //<T02> starts
        component.set("v.preDraftCommentAnother",component.get("v.preDraftComment"));
       // helper.handleInit(component, false);
        //<T02> ends
    },

    handlePopOut: function (component, event, helper) {
        console.log('handlePopOut.. ', JSON.stringify(component.get("v.preDraftComment")));
        
        component.set("v.isPopout", true);
        //component.set("v.isAddComment", false);
        //component.set("v.preDraftComment", null);
        //component.set("v.toggleValue", false);
        component.set("v.preDraftCommentAnother",component.get("v.preDraftComment"));
        helper.handleInit(component, component.get("v.isAddComment"));
    },

    handlePopin: function (component, event, helper) {
        component.set("v.isPopout", false);
        //component.set("v.isAddComment", false);
        //component.set("v.preDraftComment", null);
        //component.set("v.toggleValue", false);
        component.set("v.preDraftCommentAnother",component.get("v.preDraftComment"));
        helper.handleInit(component, component.get("v.isAddComment"));
    },

    handleMessage: function (component, message, helper) {
        console.log('message', JSON.stringify(message));
        //T03 - check if the message is from the given case and proceed
        if (message != null && message._params && message._params.caseId && message._params.caseId == component.get("v.recordId")) {
            console.log('message', 'case matched');
            if (message._params.messageText && message._params.messageText == 'createCollaboration') {
                if (component.get("v.preDraftCommentOriginal")) {
                    component.set("v.preDraftComment", component.get("v.preDraftCommentOriginal"));
                } 
                if(!$A.util.isUndefinedOrNull(message._params.messageBody)){
                    // <T01>
                    let msgBody = JSON.parse(JSON.stringify(message._params.messageBody));
                    component.set("v.preDraftComment", msgBody);
                    // <T01>
                    component.set("v.isPopout", true);
                }
                component.set("v.isAddComment", true);
            }
            component.set("v.preDraftCommentAnother",component.get("v.preDraftComment"));
        }else{
            console.log('message', 'case not matched');
        }
    },

    onInit: function (component, event, helper) {
        helper.handleInit(component, true);
    },
    // <T01>
    handleCaseCommentUpdate: function(component, event, helper) {
        let caseCommentObj = event.getParam('caseCommentdata');
        component.set("v.preDraftComment", caseCommentObj.fields);
        
    }
    //</T01>
})