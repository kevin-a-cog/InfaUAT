({	
    CloseModalOne : function(component, event, helper){
        // debugger; replace with "v.recordId"
       
        var compEvent = component.getEvent('OppRefreshEvent') ;


       compEvent.setParams(
       {
         
          'operation' : 'cancel'

       }) ;    
       compEvent.fire() ;

    },

    Save : function(component, event, helper) {
        // Prevent save button double click
        var btnClicked = component.get("v.saveBtnClicked");  

        if (btnClicked == false) {
            component.set("v.saveBtnClicked", true); 

            helper.saveRecords(component, event);

            // if(helper.salesPriceValidate(component,event)) {
            //     helper.saveRecords(component, event); 
            // }
        }
    },

    fireDelete : function (component, event, helper) {
        // debugger; 
        
        // var compEvent = component.getEvent('OppRefreshEvent') ;
        var lstOpportunity = component.get("v.oli");
        var action = component.get("c.deleteOpportunityLineItem"); 
        var oliID = String(lstOpportunity.Id); 

        action.setParams({
            "oliId" : oliID
            // "lstOppProdlist" : lstOpportunity,
            // "parentOppId" : component.get("v.oppId") 
        }); 

        action.setCallback(this, function(response){
            var state = response.getState(); 

            if (state === "SUCCESS") {
                // debugger; 
                // var oliDeleteList = response.getReturnValue();

               // compEvent.setParams(
               // {
                 
               //    'operation' : 'delete',
               //    'retoppProdList' : oliDeleteList

               // }) ;    
               // compEvent.fire() ;

                var closeModalEvt = $A.get("e.c:closeModalEvent"); 
                closeModalEvt.setParams({
                    "type" : "saveclose" 
                }); 
                closeModalEvt.fire(); 

            }
            else {
                debugger; 
            }
        }); 

        $A.enqueueAction(action); 

    }


})