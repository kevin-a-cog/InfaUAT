({
    
        afterScriptsLoaded: function(cmp,event,helper){
            console.log('scripts loaded.');
            
            /*var results = _sampleData.getData();
            cmp.set('v.data', results);
            var orderProducts = _sampleData.getchildData();
            cmp.set('v.orderProducts',orderProducts);*/
            
            //cmp.set('v.mockdataLibrary',mockdataLibrary);
        },
        init: function (cmp, event, helper) {
            var rowActions = helper.getRowActions.bind(this, cmp);
            cmp.set('v.columns', [
                {label: 'Screen Type', fieldName: 'License_Screen_Type2__c', type: 'text', editable: false, typeAttributes: { required: true }}, 
                {
                    label: 'Ship Date', fieldName: 'Ship_Date__c', type: 'date-local', editable: true,
                    typeAttributes: {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric'
                        //hour: '2-digit',
                        //minute: '2-digit'
                    }
                },
                {
                    label: 'Start Date', fieldName: 'Start_date__c', type: 'date-local', editable: true,
                    typeAttributes: {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric'
                    }
                },
                {label: 'Fulfillment Status', fieldName: 'Ship_Status__c', type: 'text', editable: false },
                {label: 'License Serial Number', fieldName: 'License_Serial_Number__c', type: 'text',  editable: true },
                {label: 'Ship Via', fieldName: 'Ship_via__c', type: 'text', editable: false },
                {label: 'Tracking Number', fieldName: 'Tracking_Number__c', type: 'text',  editable: true },
                { type: 'action', typeAttributes: { rowActions: rowActions } }

            ]);
            cmp.set('v.orderItemColumns',helper.getOrderItemColumns());

            var action = cmp.get("c.getFulfillmentLines");
            action.setParams({ fulfillmentId : cmp.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //debugger;
                    var ffTransformed = response.getReturnValue();
                    ffTransformed.forEach(function(ff){
                        ff.id=ff.Id;
                    });
                       
                    cmp.set('v.data',ffTransformed);
                }
                else if (state === "INCOMPLETE") { 
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();

                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    
            
        },
        handleSaveEdition: function (cmp, event, helper) {
            var draftValues = event.getParam('draftValues');
            //debugger;
            //helper.triggerError(cmp,event,helper);
            helper.saveEdition(cmp, draftValues);
        },
        handleCancelEdition: function (cmp) {
            // do nothing for now...
        },
        handleRowAction: function (cmp, event, helper) {
            //debugger;

            var action = event.getParam('action');
            var row = event.getParam('row');
            var draftValues = event.getParam('draftValues');
            var draftValues1 = cmp.get('v.draftValues');
            debugger;

            switch (action.name) {
                case 'view_details':
                    helper.showRowDetails(cmp,row);
                    break;
                case 'shipcomplete':
                    //debugger;
                    helper.shipCompleteRow(cmp, row, action);
                    break;
                case 'view_ff':
                        helper.navigateToSobject(row.Id);
                        
                    break;  
                case 'undo':   
                        
                        helper.shipCompleteUndo(cmp, row);
                        break; 
                case 'couriership':   
                        
                        helper.shipVia(cmp, row, 'Courier');
                        break;  

                case 'esdship':   
                        // <T01> - Replaced Esd with Eelctronic
                        // 
                        helper.shipVia(cmp, row,'Electronic');
                        break;                
                default:
                    helper.showRowDetails(cmp,row);
                    break;
            }
        },
        handleCellChange: function(cmp,event,helper){
          console.log('onCellChange');  
          var draftCellObjArray=event.getParam('draftValues');
          var draftValuesTemp = cmp.get('v.draftValues');
          helper.preserveEditedValues(cmp,draftCellObjArray[0],draftValuesTemp);
        },
        closeModal : function(cmp,row){
            //debugger;
            jQuery('#viewfulfillments').removeClass("slds-backdrop");
            jQuery('#manageOrderlines').removeClass('slds-fade-in-open');
        },
        handleCancel: function(cmp,event,helper){
           
            helper.resetDraftValues(cmp);
        }
          
          
    })