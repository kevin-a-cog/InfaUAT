({
   doInit : function(component,event,helper){
      component.set("v.spinneract",true);       
           helper.searchHelper1(component,event); 
           helper.searchHelper2(component,event); 
      component.set("v.spinneract",false); 
    },
    searchHelper1 : function(component, event, helper){   
        component.set("v.spinneract",true);
        component.set("v.hasError",false);
    	helper.searchHelper1(component,event);   
    },
    searchHelper2 : function(component, event, helper){   
        component.set("v.spinneract",true);
        component.set("v.hasError",false);
    	helper.searchHelper2(component,event);  
    },
    searchHelper3 : function(component, event, helper){   
        
        component.set("v.hasError",false);
    	  
    },
  
    saveRecord : function(component, event, helper){   
        
    	helper.setRenewalOppty(component,event);   
    }, 
    saveRecord1 : function(component, event, helper){   
        
    	helper.setRenewalOppty1(component,event);   
    }, 
    handleCheck : function(component, event, helper) {
        var isChecked = component.find("Dcheckbox").get("v.checked");
        component.set("v.checkbox", isChecked);        
    }  , 
      handleCheck1 : function(component, event, helper) {
        var isChecked = component.find("Dcheckbox1").get("v.checked");
        component.set("v.checkbox1", isChecked);        
    }  ,
      handleCheck2 : function(component, event, helper) {
        var isChecked = component.find("Dcheckbox2").get("v.checked");
        component.set("v.checkbox2", isChecked);        
    }  ,
    searchhelper3 : function(component,event,helper){
      component.set("v.spinneract",true); 
           helper.searchHelper3(component,event);          
      component.set("v.spinneract",false); 
    },
    saveRecord2 : function(component, event, helper){   
        
    	helper.setRenewalOppty2(component,event);   
    }, 
    handleSelectAllContact : function(component, event, helper){   
        
    	helper.handleSelectAllContact(component,event);   
    }, 

})