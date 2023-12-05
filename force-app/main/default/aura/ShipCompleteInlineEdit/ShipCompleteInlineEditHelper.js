({
    saveEdition: function (cmp, draftValues) { 
        var self = this;
            var action = cmp.get("c.updateFulfillments");
            //debugger;
            draftValues.forEach(function(ff){
                Object.keys(ff).forEach(function(ffkey){
                    // for dates transformaftion..
                    if((ffkey.indexOf('Ship_Date__c')>=0 || ffkey.indexOf('Start_date__c')>=0 ) && ff[ffkey]){
                       if(ff[ffkey].indexOf("T")>0)
                          ff[ffkey]=  ff[ffkey].split("T")[0];
                         }

                });
            });
            
            var dataJSON = JSON.stringify(draftValues);
                  action.setParams({ 'fulfillmentLines' :  dataJSON});
                  cmp.set('v.isLoading', true);
           
                  action.setCallback(this, function(response) {
                      var state = response.getState();
                      if (state === "SUCCESS") {
                          var ffTransformed = response.getReturnValue();
                          ffTransformed.forEach(function(ff){
                              ff.id=ff.Id;
                          });
                          debugger;
                          var data =  cmp.get('v.data');
                          var dataIndexedById = _.indexBy(data,"id");
                          ffTransformed.forEach(function(row){
                              if(dataIndexedById.hasOwnProperty(row.Id)){
                                var datarow = dataIndexedById[row.Id];
                                var datarow1= Object.assign({},
                                                   datarow,
                                                   row
                                                   );
                                //dataIndexedById[row.Id] =   datarow1;                
                                var rowIndex = data.indexOf(datarow);
                                data[rowIndex] = datarow1;
                                console.log(row);
                                console.log(data);                   
                              }
                              
                          });
                          cmp.set('v.data',data);
                          //cmp.set('v.data',ffTransformed);
                          console.log('resp: save'+response.getReturnValue());
                          cmp.set('v.errors', []);
                          cmp.set('v.draftValues', []);
                          cmp.set('v.errorMessage', null);
                          cmp.set("v.isLoading",false);
                          cmp.set('v.isLoading', false);
                          
                      }
                      else if (state === "INCOMPLETE") {
                          // do something
                      }
                      else if (state === "ERROR") {
                          debugger;
                          var errors = response.getError();
                          cmp.set('v.errorMessage', errors[0].message);
                          cmp.set('v.isLoading', false);
                          cmp.set('v.draftValues', []);

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
    showRowDetails : function(cmp,row) {
                var relatedLines = row.Related_Fullfillment_Lines__r;
                var relatedLinesTransform = _.map(relatedLines, function(rl){
                    var rlTransformed = {
                                          ProdName: rl.Order_Product__r.Product2.Name,
                                          OrderNumber: rl.Order_Product__r.OrderItemNumber,
                                          Quantity: ''+rl.Quantity__c,
                                          EndDate: rl.Order_Product__r.EndDate, 
                                          StartDate:rl.Order_Product__r.ServiceDate
                                        };
                    return       rlTransformed;              
                });
                cmp.set('v.orderProductsTemp',relatedLinesTransform);
                jQuery('#viewfulfillments').addClass("slds-backdrop");
                jQuery('#manageOrderlines').addClass('slds-fade-in-open');
                
    },
    getOrderItemColumns : function(){
        var columns = [
            {label: 'Product Name', fieldName: 'ProdName', type: 'text', sortable: true},
            {label: 'Order Product Number', fieldName: 'OrderNumber', type: 'text', sortable: true},
            {label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: true},
            
            {
                label: 'Start Date', fieldName: 'StartDate', type: 'date-local', editable: true,
                typeAttributes: {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric'
                }
            },
            {
                label: 'End Date', fieldName: 'EndDate', type: 'date-local', editable: true,
                typeAttributes: {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric'
                }
            }

        ];

        return columns;
            
    },
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'View Order Lines',
            'iconName': 'utility:zoomin',
            'name': 'view_details'
        }];
        var editAction = {
            'label': 'View Detail',
            'iconName': 'utility:view',
            'name': 'view_ff'
        };
        
        if (row.Ship_Status__c==='Ready for Provisioning') { 
            actions.push({
                'label': 'Provisioning Complete',
                'iconName': 'utility:check',
                'name': 'shipcomplete'
            });
            actions.push({
                'label': 'Ship Via Courier',
                'iconName': 'utility:shipment',
                'name': 'couriership'
            });
            // <T01> - Replaced Esd with Eelctronic
            actions.push({
                'label': 'Ship Via Electronic',
                'iconName': 'utility:shipment',
                'name': 'esdship'
            });
            
            
            
        } else {
            /*actions.push({
                'label': 'Undo Ship Complete',
                'iconName': 'utility:undo',
                'name': 'undo'
            });*/
            //editAction.disabled = 'true';
        }

        actions.push(editAction);

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 10);
        return actions;
    },
    shipCompleteRow: function (cmp, row) {
     var self=this;
     var draftValue = {'Ship_Status__c':'Provisioning Complete', 'id':row.Id};
     var draftValues = cmp.get('v.draftValues');
     self.preserveEditedValues(cmp,draftValue,draftValues);
     
    },
    shipCompleteUndo: function (cmp, row) {
        var self=this;
        var draftValue = {'Ship_Status__c':'Ready for Provisioning', 'id':row.Id,'Ship_Date__c':null,'Ship_via__c':'Electronic'};
        var draftValues = cmp.get('v.draftValues');
        self.preserveEditedValues(cmp,draftValue,draftValues);
    },
    shipVia:function(cmp,row, shipvia){
        var self=this;
        var draftValue={'Ship_via__c':shipvia,'id':row.Id}; 
        var draftValues = cmp.get('v.draftValues');
        self.preserveEditedValues(cmp,draftValue,draftValues);
    },
    preserveEditedValues:function(cmp,draftRow,draftValues){
    
     var existingDraft = _.find(draftValues, function(ff){ return ff.id === draftRow.id }) || {};
     var newDraft= Object.assign(
        {},
        draftRow,
        existingDraft
        );
    var filteredDrafts = _.filter(draftValues, function(ff){ return ff.id  !== existingDraft.id });          
    filteredDrafts.push(newDraft);
    cmp.set('v.draftValues',filteredDrafts);

    },
       navigateToSobject:function(recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
                           "recordId": recordId,
                           "slideDevName": "detail"
                        });
        navEvt.fire();
        //window.location.href = 'https://infa--cpqbox.lightning.force.com/lightning/r/Fulfillment_Line__c/'+recordId+'/view';
       },
       resetDraftValues:function(cmp){
        cmp.set('v.draftValues',null);
       },
       triggerError: function (cmp, event, helper) {
        cmp.set('v.errors', {
            rows: {
                "a3c54000000NFJFAA4": {
                    title: 'We found following errors.',
                    messages: [
                        'Enter a future date.',
                        'Verify the email address and try again.'
                    ],
                    fieldNames: ['Ship_Date__c']
                }
            },
            
             table: {
                title: 'Your entry cannot be saved. Fix the errors and try again.',
                messages: [
                    'Row 2 amount must be number',
                    'Row 2 email is invalid'
                ]
            }
        });
    }
       
});