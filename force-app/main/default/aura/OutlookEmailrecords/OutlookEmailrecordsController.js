({	 
    init : function(component, event, helper) {
        
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Email', fieldName: 'Email', type: 'Email'}            
        ]);
        
    },
    
    handleRowAction : function(component, event, helper){
        
        var selRows = event.getParam('selectedRows');
        var hiddencopy = document.createElement("input");
        var getlistemails = helper.getEmailsFromcopy(selRows);
        hiddencopy.setAttribute("value", getlistemails);
        document.body.appendChild(hiddencopy);          		
        hiddencopy.select();  
        document.execCommand("copy");
        document.body.removeChild(hiddencopy);
    },
    
    fetchPlan : function(component, event, helper) {        
        
        var ret = [];
        var arr=[];
        var subj = component.get("v.subject");
        var body = component.get("v.messageBody");
        var refid = helper.getrefid(body);
        // ret.push(refid);
        var action = component.get("c.fetchContacts");
        action.setParams({"refid":refid,"subj":subj}
                        );
        action.setCallback(this, function (response) {
            var state = response.getState();  
            if ( state === "SUCCESS" ) { 
                var res = JSON.parse(response.getReturnValue());
                if(res!='undefined' && res!=null && res!='[]')
                {
                    component.set("v.condetails",res);
                    if(res[0]!='undefined' && res[0]!='null' && res[0].Type!='undefined' && res[0].Type!='null')
                    {
                        component.set("v.titleType",res[0].Type);                        
                    }
                    
                    arr.push(res);
                    var arrSize=arr.length;
                    component.set("v.listSize",res.length);
                }
                
                
            }
        });
        $A.enqueueAction(action);
    },
    copyemail : function(component, event, helper) {
        var orignalLabel = event.getSource().get("v.label");
        event.getSource().set("v.iconName" , 'utility:check');
        event.getSource().set("v.label" , 'Copied');
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 700);
        
    }
    
})