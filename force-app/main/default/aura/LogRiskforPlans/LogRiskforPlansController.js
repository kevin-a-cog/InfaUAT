({
    doInit: function (component, event, helper) {
        helper.getRiskRecordTypeId(component);
        helper.getRiskTypePickListValues(component);
        helper.getPlanProductCount(component);



    },
    riskTypeOnChange: function (component, event, helper) {

        helper.validateRisks(component);


    },


    handleManageRiskProducts: function (component, event, helper) {
        component.set("v.blManageRisks", true);
        component.set("v.blShowOrHideAll", false);


    },

    //LOGIC TO SEND PLAN DETAILS TO ADD PLAN PRODUCTS COMPONENTS : MAHESH GANTI 08/20/2020
    handleNext : function (component, event, helper) {
        event.preventDefault();
        component.set("v.disableSave", true); /** T01 - Disable Save Button to prevent Duplicate Risk Creation **/
        
        const fields = event.getParam('fields');
        component.set("v.riskRecDetails", JSON.stringify(fields));
        console.log('riskRecDetails-->'+ component.get("v.riskRecDetails"));
        var showadd = component.get("v.blHasPlanProducts");
        if (showadd) {
            component.set("v.blManageRisks", true);
            component.set("v.blShowOrHideAll", false);
        } else {
            var action = component.get("c.insertRisk");
            action.setParams({
                riskRec: component.get("v.riskRecDetails"),
            });
            action.setCallback(this, function (response) {
                var recId = response.getReturnValue();
                var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + recId + '/view';
                location.href = sURL;
            });
            $A.enqueueAction(action);
        }
    },


    handleSuccess: function (component, event, helper) {
        
        console.log('success submit');
        var payload = event.getParams().response;
        console.log('*********' + payload.id);
        var cretedRiskID = payload.id;
        component.set("v.recid", cretedRiskID);

        var navService = component.find("navService");
        var pageReference;
        pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: cretedRiskID,
                objectApiName: "Risk_Issue__c",
                actionName: "view"
            }
        };
        navService.navigate(pageReference);
        $A.get("e.force:closeQuickAction").fire();

    },


    //LOGIC ON CANCEL BUTTON,NAVIGATES BACK TO ACCOUNT LOB RECORD : MAHESH GANTI 08/20/2020
    handleCancel: function (component, event, helper) {
        // var navService = component.find("navService");  
        var recId = component.get("v.recordId");
        var pageReference;
        pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: "Plan__c",
                actionName: "view"
            }
        };
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + recId + '/view';
        console.log('surl' + sURL);
        location.href = sURL;
        //navService.navigate(pageReference); 
        //$A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire(); 
        //$A.get('e.force:refreshView').fire(); 
        //window.location.reload();
    },
})