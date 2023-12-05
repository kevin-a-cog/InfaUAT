({
    onfocus: function (component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if (getInputkeyWord) {
            helper.searchHelper(component, event, getInputkeyWord);
        }
        else {
            getInputkeyWord = '';
            helper.searchHelper(component, event, getInputkeyWord);
        }
    },
    setInitialValue: function (component, event, helper) {
        //console.log('Handling the event.....');
        var params = event.getParam('arguments');
        if (params) {
            var rec = params.initRec;
            //console.log("<><><><><><><><><>rec: " + rec);
            component.set("v.selectedRecord", rec);
            helper.showselected(component);
        }
    },
    onblur: function (component, event, helper) {
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },

    keyPressController: function (component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if (getInputkeyWord.length > 0) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        }
        else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction 
    clear: function (component, event, heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", {});
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function (component, event, helper) {
        // get the selected Account record from the COMPONETN event 

        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord", selectedAccountGetFromEvent);
        helper.showselected(component);


    }


})