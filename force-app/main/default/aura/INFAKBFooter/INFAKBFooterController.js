({
      doInit: function (component, event, helper) {          
            try {                                   
                  if (typeof _satellite === 'undefined') {
                  } else {
                        _satellite.pageBottom();
                  }
            } catch (ex) {
                  console.log('Footer error');
                  console.log(ex.message);
            }
      }
});