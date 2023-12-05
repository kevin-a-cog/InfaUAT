/*Helper class for Component to Display the Contract Line records related to a Renewal Quote Design*/
({
    navigateOrderPage : function (component, event, helper) {
        var recId =  component.get("v.recordId");
        var sURL = $A.get("$Label.c.opportunityProdcutList_URL") + '?source=aloha#/sObject/'+recId+'/view';
        var device = $A.get("$Browser.formFactor");
        
        if (device === "DESKTOP") {
            window.location.assign(sURL);
        }
        else {
            sforce.one.navigateToURL(sURL);
        }
    },

    loadAllQuoteLines : function (component, event, helper) {
        var action = component.get("c.getQuoteLinesWrapper"); 
        //console.log('In LoadAllQuoteLines.......'+component.get("v.recordId"));
        action.setParams({
            quoteID : component.get("v.recordId")
        });            
        
        component.set("v.loading", false);
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (state === "SUCCESS") {
                // debugger; 
                
                // Load main asset list
                // ====================================================
                var assetWrapperListServer = response.getReturnValue(); 
                
                 if(assetWrapperListServer.length > 0){
                    // Sort descending order
                /*  assetWrapperListServer.sort(function(a,b){
                        if (a.quoteLineName < b.quoteLineName) return 1; 
                        if (a.quoteLineName > b.quoteLineName) return -1; 
                        return 0; 
                    }); 
                    
                    // Sort ascending order - empty Parent Asset kept at bottom of list
                    assetWrapperListServer.sort(function(a,b){
                        if (a.quoteLineName != "" && b.quoteLineName != "") {
                            if (a.quoteLineName < b.quoteLineName) return -1; 
                            if (a.quoteLineName > b.quoteLineName) return 1; 
                            return 0; 
                        }
                    }); */
                    
                    component.set("v.assetWrapperList", assetWrapperListServer); 
                    //console.log('DATA>>>', JSON.stringify(assetWrapperListServer));

                    if (!$A.util.isEmpty(assetWrapperListServer.length) && !$A.util.isUndefined(assetWrapperListServer.length)) {
                        // Case: There are more than 1 asset wrappers 
                        component.set("v.originSObjectName", assetWrapperListServer[0].OriginSObjectName); 
                    }
                    else {
                        // Case: There is only 1 asset wrappers
                        component.set("v.originSObjectName", assetWrapperListServer.OriginSObjectName); 
                    }
                } else{
                    component.set("v.noAssets", true);
                }
            } 
            else {
                // debugger; 
            }
        }); 
        
        $A.enqueueAction(action); 
    },

    convertToCSV: function (component, event, helper, array) {        
        var str = '';
        
        //converting array to a csv string
        for (var i = 0; i < array.length; i++) {
            var line = '';
            for (var index in array[i]) {
                if (line != '') line += ','
                //To retain preceding zeror in Contract number
                if (i != 0 && (array[0][index] === 'PRIOR CONTRACT' || array[0][index] === 'ORIGINAL CONTRACT'))
                    line += '=\"' +array[i][index] + '\"';
                else
                    line += '"' + array[i][index] + '"';
            }

            str += line + '\r\n';
        }

        //replacing all undefined with "" and returning
        return str.replace(/undefined/g,""); 
    },
    
    exportCSVFile: function (component, event, helper, objArray) {
        //To format the object into a csv String
        var csv = this.convertToCSV(component, event, helper, objArray);

        if (csv == null) { return; }

        //Export the data into a file
        var hiddenElement = document.createElement('a');
        var universalBOM = "\uFEFF"; //To allow special characters in the file
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(universalBOM + csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = component.get("v.QuoteRec").Name + ' Contract lines.csv';  // CSV file Name *do not remove .csv 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();
        document.body.removeChild(hiddenElement);
    },

    getTableheader: function (component, event, helper) {
        var colHeader = []; //To store column header values

        //getting column header info from prior values table
        var t_head = document.getElementById('Prior_Value').querySelectorAll('thead tr');
        var row_ths = t_head[0].querySelectorAll('th');
        if (row_ths.length > 0) {
            for (var i2 = 0; i2 < row_ths.length; i2++) {
                colHeader.push((row_ths[i2].innerText || row_ths[i2].textContent).toUpperCase());
            }
        }
        //getting column header info from original values table
        t_head = document.getElementById('Original_Value').querySelectorAll('thead tr');
        row_ths = t_head[0].querySelectorAll('th');
        if (row_ths.length > 0) {
            for (var i2 = 0; i2 < row_ths.length; i2++) {
                colHeader.push((row_ths[i2].innerText || row_ths[i2].textContent).toUpperCase());
            }
        }
        //Returning only the unique column headers
        return Array.from(new Set(colHeader));
    },

    getTableData: function (component, event, helper) {
        var t_data = []; // will store data from each TD of each row
        var ix = 0; // index of rows in t_data

        //Getting the table headers
        var columnHeaders = this.getTableheader(component, event, helper);
        t_data.push(columnHeaders); ix++;
        
        //Getting table cell data
        var t_PriorRows = component.find('PriorcellData');
        var t_OriginalRows = component.find('OriginalcellData');
        var t_rows = [];
        var noOfRows = (t_PriorRows.length + t_OriginalRows.length) / columnHeaders.length;
        var ip = 0, io = 0; //iterators for prior and original Table cell data

        for (var row = 0; row < noOfRows; row++) {
            t_data[ix] = [];
            //To get values from Prior values table
            for (var col = 0; col < t_PriorRows.length / noOfRows; col++) {
                //check for Product name indentation for child products
                if (t_PriorRows[ip].get("v.class") && (t_PriorRows[ip].get("v.class").toString()).includes('slds-p-left_medium'))
                    t_data[ix].push("      ".concat(t_PriorRows[ip].get("v.value")));                
                else
                    t_data[ix].push(t_PriorRows[ip].get("v.value"));
                ip++;
            }
            //To get values from original values Table
            for (var col = 0; col < t_OriginalRows.length / noOfRows; col++) {
                t_data[ix].push(t_OriginalRows[io].get("v.value")); io++;
            }
            ix++;
        }
        
        this.exportCSVFile(component, event, helper, t_data);
    }
})