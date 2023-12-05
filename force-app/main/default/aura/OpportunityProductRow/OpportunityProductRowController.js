//Main js for the Child cmp inside OpportunityProductsDetails for the Hybrid deal management(opportunity)
({
    handleMenuSelect: function(component, event, helper) 
    {
  		var compEvent = component.getEvent('OppDMLEvent') ;
      var menuValue = event.detail.menuItem.get("v.value");
      var labelValue = event.detail.menuItem.get("v.label");
      
      if (labelValue == 'Edit')
      {   
          compEvent.setParams(
              {
                  'oli':component.get("v.oppLineItem"),
                  'operation' : 'edit'
              }) ;    
          compEvent.fire() ;  
      }
      else if(labelValue == 'Delete')
      {   
          compEvent.setParams(
              {
                  'oli':component.get("v.oppLineItem"),
                  'operation' : 'delete'
              }) ;    
          compEvent.fire() ;  

      }
    }
})