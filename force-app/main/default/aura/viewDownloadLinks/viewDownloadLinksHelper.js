({
    getFields: function (component, event, helper) {
        var columns = [];
        var columns = [
            { label: 'Fulfillment Line', fieldName: 'Fullfillment_Line__c', sortable: true, type: 'text'},
            { label: 'Install Base', fieldName: 'InstallBase_Name__c', sortable: true, type: 'text'},
            { label: 'Version', fieldName: 'Version__c', sortable: true, type: 'text'},
            { label: 'Download Link', fieldName: 'Download_Link__c', type: 'url', typeAttributes: { label: { fieldName:'Download_Link__c'}, target: '_self'}}
        ];
        component.set("v.fieldarray", columns);
        console.log('completing getFields.....' + JSON.stringify(component.get('v.fieldarray')));
    },

    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.lstRow");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.lstRow", data);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) { return primer(x[field]) } :
            function (x) { return x[field] };
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})