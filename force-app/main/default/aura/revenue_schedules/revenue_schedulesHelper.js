({
	onLoadHelper : function(component, event, helper) {
    	var action = component.get("c.currentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var userTypeRet = response.getReturnValue() ;
                component.set("v.userType",userTypeRet);
            	helper.revSchHelper(component, event, helper);
            }
        });

        $A.enqueueAction(action);
    },
    
    revSchHelper : function(component, event, helper) {
        console.log('Inside Helper');
		var action1 = component.get("c.getRevenueSch");
          console.log(component.get("v.recordId"));
        action1.setParams({
            revAgrId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.allRevSch", response.getReturnValue());
                component.set("v.showRevSchPage",true);
                var RevSch = response.getReturnValue();
                if(RevSch[0].Revenue_Agreement__r.Stage__c == "Ready" || RevSch[0].Revenue_Agreement__r.Stage__c == "Sent to RMCS" || component.get("v.userType") == "User")
                component.set("v.RSDef",true);
                if(RevSch[0].Revenue_Agreement__r.Stage__c == "Allocation Validated" || RevSch[0].Revenue_Agreement__r.Stage__c == "Ready" || RevSch[0].Revenue_Agreement__r.Stage__c == "Sent to RMCS" || component.get("v.userType") == "User")
                component.set("v.RSAllocate",true);
               	
            }
        });
        $A.enqueueAction(action1);
	},
    
    closeTab: function(component, event, helper) {
        component.set("v.showRevSchPage", false);
        component.set("v.RSPage", false);
        helper.navigateToSObject(component, event, helper);
    },
     
    navigateToSObject : function(component, event, helper){
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
    
    updateAllRSHelper : function(component, event, helper){
        console.log('Inside Update Helper');
        var allRSList = component.get("v.allRevSch");
        var updateRSList = [];
        for(var i = 0; i < allRSList.length; i++){
            if(!allRSList[i].Sent_to_RMCS__c)
             			updateRSList.push(allRSList[i]);
             }
        component.set("v.allRevSchUpd",updateRSList);
        console.log(updateRSList.length);
        var action3 = component.get("c.updateRevenueSch");
        action3.setParams({
            revAgrId : component.get("v.recordId"),
            lstRevenueSchedules : JSON.stringify(component.get("v.allRevSchUpd"))
        });
        action3.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.spinneract",false);
                component.set("v.showRevSchPage", false);
                
                helper.navigateToSObject(component, event, helper);
               
            }
            else
            {
                component.set("v.errorMessage",response.getError()[0].message);
                component.set("v.spinneract",false);
                component.set("v.showRevSchPage", false);
                component.set("v.errMsg",true);
            }
        });
        $A.enqueueAction(action3);
    },
    
    massUpdateRSHelper : function(component, event, helper){
        var valueDefDate = component.find("defDate").get("v.value");
        
        var allRSList = component.get("v.allRevSch");
        if(valueDefDate != null && valueDefDate != "" && valueDefDate != undefined)
        {
            console.log(valueDefDate);
             for(var i = 0; i < allRSList.length; i++){
                  if(!allRSList[i].Sent_to_RMCS__c)
             allRSList[i].Deferred_Revenue_Acct_Date__c = valueDefDate;
             }
            component.set("v.allRevSch",allRSList);
        }
        else{
            console.log('Please select a date');
            
        }
        
        
    },
    
    messageToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})