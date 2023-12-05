({
    doInit: function (component, event, helper) {
        helper.getFields(component, event, helper);
        var action = component.get("c.getData");
        action.setParams({ fullFillmentId: component.get('v.recordId')});
        action.setCallback(this, function (result) {
            var res = result.getReturnValue();
            if (result.getState() === "SUCCESS") {
                component.set("v.lstRow", res);
                console.log('Returned from server........'+JSON.stringify(component.get('v.lstRow')));
            }
            else {
                debugger;
            }
        });
        $A.enqueueAction(action);
    },

    handleSort: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        var columns = cmp.get("v.fieldarray");
        var sortByCol = columns.find(column => fieldName === column.fieldName);
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },

    goToOrder: function (component, event, helper) {
        var recId = component.get("v.recordId");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/' + recId + '/view';
        var device = $A.get("$Browser.formFactor");

        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    },
})