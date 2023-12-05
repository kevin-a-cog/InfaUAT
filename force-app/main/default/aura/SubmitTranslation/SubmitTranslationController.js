({
	doInit : function(component, event, helper) { 
        var action = component.get("c.validateTranslation");
        var recid = component.get("v.recordId");
        action.setParams({
            "articleId": component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();
            console.log(res.kbrec.IsMasterLanguage);
            console.log(res.kbrec.PublishStatus);
            if(!res.kbrec.IsMasterLanguage){
                component.set("v.notmaster", true);
                component.set("v.validstate", false);
            } else if(res.kbrec.PublishStatus != 'Online'){
                component.set("v.draftart", true);
                component.set("v.validstate", false);
            } 
            if(res.strlist.length==4){
                component.set("v.translatedInAllLangs", true);
                component.set("v.validstate", false);
            }
            for(let i=0,len=res.strlist.length;i<len;i+=1){
                if(res.strlist[i] == 'ja'){
                    component.set("v.validjapan",false);
                }
                if(res.strlist[i] == 'de'){
                    component.set("v.validgerman",false);
                }
                if(res.strlist[i] == 'zh_TW'){
                    component.set("v.validchintrade",false);
                }
                if(res.strlist[i] == 'zh_CN'){
                    component.set("v.validchinsim",false);
                }
			}
                  
            console.log(res);
        });
        $A.enqueueAction(action);      
       
    },
    CloseModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handlesubmit: function (component, event, helper) {
        var listofvalues = component.get("v.langlist");
        console.log(listofvalues);
        
        var action = component.get("c.submittranslation");
        
        action.setParams({
            "lstLanguage": component.get("v.langlist"),
            "kavId" : component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Articles submitted for Translation successfully"            
                });
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);      
    },
    handleChange: function (component, event, helper) {
        component.set("v.hidesubmit",false);
        var listval = component.get("v.langlist");
        listval.push(event.getSource().get("v.value"));
        component.set("v.langlist",listval);
        console.log('list of value'+ event.getSource().get("v.value"));
    }
})