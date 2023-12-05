({
    doInit : function(component, event, helper) { 
        var action = component.get("c.CheckSurveySent");
        action.setParams({
            "planId": component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            console.log('**recId'+component.get("v.recordId"));
            var res = response.getReturnValue();
            console.log('**Res'+ res);
            console.log('res.Onboarding_Survey_Sent__c'+ res.Onboarding_Survey_Sent__c);
            console.log('res.planState', res.Current_State_of_plan__c);  
            //console.log ('onborading check', (res.onBoardingSurveySent),or(res.planState =='Configuration',res.planState =='Implement')));           
             component.set("v.onBoardingSurveySent", res.Onboarding_Survey_Sent__c);
             component.set("v.bizOutcomeSurveySent", res.Business_Outcome_Survey_Sent__c);
             component.set("v.cstSurveySent", res.CST_Survey_Sent__c);
             component.set("v.recTypeName", res.RecordType.DeveloperName);
             component.set("v.planState", res.Current_State_of_plan__c);  
             component.set("v.accid",res.Account__c);
            
        });
        $A.enqueueAction(action);
        
       var action2 = component.get("c.acccontacts");
        action2.setParams({
            "planId": component.get("v.recordId"),
        });
        action2.setCallback(this, function (response) {
            var res = response.getReturnValue();
            component.set("v.lstContacts",res);
            component.set("v.lstContactsSize",component.get("v.lstContacts").length);
            
        });
        $A.enqueueAction(action2);
    },
    handleClick : function (component, event, helper) {
        // debugger; 
        var target = event.target;  
        var selectedContactId = target.getAttribute("data-contact-id");
        
        var pillsList = component.get("v.pillsList");  
        var lstContacts = component.get("v.lstContacts");  
        //alert(lstContacts[0].Name);
        console.log('list of contacts' + component.get("v.lstContacts") );
		console.log('pills list before' + pillsList );
        //To check if list is not empty or null    
        if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){  
            for(var i=0;i<lstContacts.length;i++){
                if(lstContacts[i].Id==selectedContactId)
                {
                    lstContacts[i].Is_Selected__c = Boolean('TRUE');
                    pillsList.push(lstContacts[i]);

                }
            }           
            console.log('@ListContacts'+lstContacts[0].Id);
            component.set("v.lstContacts",lstContacts);
            component.set("v.pillsList",pillsList);
            console.log("@PILLLIST" + pillsList[0].Id);
            console.log("@PILLLIST length" + pillsList.length);
            
        }
    },
    
    onSend: function (component, event, helper) {        
        console.log('sent');
        var action = component.get("c.updatePlanSurveySent");
        action.setParams({
            "acccontacts": component.get("v.pillsList"),
			"planid": component.get("v.recordId"),            
        });
        console.log('called');
        action.setCallback(this, function (response) {
            console.log(response.getError());
            //$A.get("e.force:closeQuickAction").fire();
            component.set("v.surveysent",true);
        });
        $A.enqueueAction(action);
    },
    CloseModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
     searchKeyChange : function(component,event,helper){
        
        var action = component.get("c.findByName");
        action.setParams({
            "accid": component.get("v.accid"),
            "searchKey": component.get("v.searchKeyword"),
        });
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();
             component.set("v.lstContacts", res);             
        });
        $A.enqueueAction(action);
        
     },
    handleRowAction: function(component, event){
         var selRows = event.getParam('selectedRows');
        var obj =[];
        for (var i = 0; i < selRows.length; i++){
            obj.push(selRows[i].Id);
        }
        console.log('selected rows in row select'+obj);
        
         component.set("v.planconids",obj);
    },
     // remove selected records
    handleRemove : function (component, event, helper) {
        // debugger; 
        event.preventDefault();
        //console.log(event.getSource().get("v.value"));
        //console.log(event.getSource().get("v.href"));
        // console.log(event.getSource().get("v.name"));
        var removePillId = event.getSource().get("v.name");
        var pillsList = component.get("v.pillsList");  
        
        for(var i=0;i<pillsList.length;i++){
            if(pillsList[i].Id == removePillId)
            {
                //var index = array.indexOf(removePillId);
                pillsList.splice(i,1);
            }
        }
        if(pillsList.length == 0){      
            component.set("v.disabledSave",true);       
        }
        //console.log(pillsList);
        component.set("v.pillsList",pillsList);
        
        var lstContacts = component.get("v.lstContacts");  
        if(!$A.util.isEmpty(lstContacts) && !$A.util.isUndefined(lstContacts)){  
            for(var i=0;i<lstContacts.length;i++){
                if(lstContacts[i].Id == removePillId)
                {
                    // console.log(lstContacts[i].Is_Selected__c);
                    lstContacts[i].Is_Selected__c = false;
                    // console.log(lstContacts[i].Is_Selected__c);
                }
            }
            //console.log(lstContacts);
            component.set("v.lstContacts",lstContacts);
        }
    }
})