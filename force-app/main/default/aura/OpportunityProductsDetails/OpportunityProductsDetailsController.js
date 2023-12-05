/* Controller for Main custom related products list for the Hybris deal management(opportunity)*/
({
    
    doInit : function(component, event, helper) {
        var lstOpportunity = component.get("v.oppProdList");
        var oppProdId = component.get("v.recordId");       

        // Call Apex method getOppotunityProductsDetails to get Opp Products Details
        var action = component.get("c.getOppotunityProductsDetails");

        action.setParams({
            'oppProdId' : oppProdId
        });
             
        action.setCallback(this, function(response) {
            debugger; 
            var state = response.getState();
            
            if (state === "SUCCESS"){
                // debugger; 
                var storeResponse = response.getReturnValue();
                component.set("v.oppProdList", storeResponse);

                helper.displayMobileCard (component, event, helper); 

            } else {
                // debugger; 
            }

        });
        $A.enqueueAction(action);

        helper.getOppName (component, event , helper); 
        helper.getTransactionTypeOptions (component, event, helper); 
        helper.getPreviousURL (component, event, helper);
        helper.hideButtons (component, event, helper);
        
	},

    handleOLIDML : function(component , event , helper )
    {
        component.set("v.oliContext" , event.getParam("oli") ) ;
        component.set("v.OLIOperation" , event.getParam("operation"));
        //component.set("v.oppProdList" , event.getParam("retoppProdList"));

        if(event.getParam("operation") == 'edit')
        {
            component.set("v.ModalTitle","Edit Opportunity Product") ;  
            component.find("oliEditModal").changeVisibility(true);

        }else if(event.getParam("operation") == 'delete')
        {
            component.set("v.ModalTitle","Delete Opportunity Product") ; 
            component.find("oliEditModal").changeVisibility(true);

        }
        
    },

    onClickMobileCard : function (component, event, helper) {
        debugger; 
        helper.navigateFullDetailPage (component, event, helper); 
    },

    handleOLIRefresh : function (component, event, helper){
        var eventOperation = event.getParam("operation");

        if(event.getParam("operation") != 'cancel')
        {
            component.set("v.oppProdList" , event.getParam("retoppProdList")) ;    
        }
        
        component.find("oliEditModal").changeVisibility(false);

    },

    navigateEditProduct : function (component, event, helper) {
        helper.goToEditProduct(component, event); 
    }, 

    navigateAddProduct : function (component, event, helper) {
        helper.goToAddProduct(component, event); 
    },

    viewAllOpportunity: function(component, event, helper) {
        helper.goToViewAll(component, event); 
    },

    syncSOP : function (component, event, helper) {
        helper.syncSOPHelper (component, event, helper); 
    },

    syncQuote : function (component, event, helper) {
        helper.syncQuoteHelper (component, event, helper); 
    },

    closeEditDeleteModal : function (component, event, helper) {
        // debugger; 
        component.find("oliEditModal").changeVisibility(false); 

        var eventType = event.getParam("type"); 

        if (eventType === "saveclose") {
            var recId =  component.get("v.recordId");        
            var sURL = $A.get('$Label.c.opportunityProdcutList_URL') + '?source=aloha#/sObject/'+recId+'/view';
            
            var device = $A.get("$Browser.formFactor");

            if (device === "DESKTOP") {
                // window.location.assign(sURL);
                // $A.get('e.force:refreshView').fire();
                window.location.reload(true);

            }
            else {
                var currentURL = window.location.href; 
                sforce.one.navigateToURL(currentURL);
                // $A.get('e.force:refreshView').fire();
                // window.location.reload(true);
            }
        }   
        else {
            debugger; 
        }
    },

    doneRendering : function (component, event, helper) {
        helper.reDrawPage (component, event, helper); 
    },

    showContractProducts: function (component, event, helper) {
        component.set('v.contractProductsFlag', true);
    },
    closeContractProductModal: function (component, event, helper) {
        component.set('v.contractProductsFlag', false);
    }    

    // CloseModalOne : function(component,event,helper){
    //   // for Hide/Close Model,set the "showPopup" attribute to "Fasle"  
    //   //component.set("v.showPopup", false);
    //     var recId =  component.get("v.recordId");
       
    //     var str = window.location.hostname;
    //     var arr = str.split("--");
    //     var sURL = $A.get("$Label.c.OpportunityProdcutsDetails_URL") + '?source=aloha#/sObject/'+recId+'/view';
        
    //     window.location.assign(sURL);
    // }

})