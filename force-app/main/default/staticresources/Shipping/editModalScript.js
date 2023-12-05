//jjQuery = jQuery.noConflict();

(function(){
    jQuery("document").ready(function(){
        console.log('loaded');
        jQuery('#openmodal').click(function(e){
            jQuery('#backdrop').addClass('slds-backdrop--open');
            jQuery('#modal').addClass('slds-fade-in-open');
          });
        
        jQuery('#cancel').click(function(){
            jQuery('#backdrop').removeClass('slds-backdrop--open');
            jQuery('#modal').removeClass('slds-fade-in-open');
        }); 
    });
    
})();

 