/*
 Change History
 *************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                          Tag
 *************************************************************************************************************************************
 Shashikanth			10/19/2023		I2RT-7702		    Added code to redirect to AAE details page                            T01
                                                            after slot booking
 */
({
    init : function (cmp,event,helper) {
        var url_string = window.location.href
        var url = new URL(url_string);
        var c = url.searchParams.get("tab");
        console.log(c);
        if(c == 'ub'){
            cmp.set('v.tabId' , 'upcomingBookings')
        }

      ////  helper.validateSecurityAccess(cmp);


    },

    onUpcomingBookingActive: function (cmp,event,helper) {
        if (history.pushState) {
            var newurl = window.location.href.split('&tab=')[0] +  '&tab=ub';
            window.history.pushState({path:newurl},'',newurl);
        }
        cmp.find('childlwc').getFiredFromAura();

    },
    

  
    onSlotActive : function (cmp,event,helper) {

        var supportAccountId = helper.getParameterByName('supportaccountid'); 
        var rescheduling = helper.getParameterByName('hasRescheduling');
        var existingServiceAppointmentId = helper.getParameterByName('ServiceAppointmentId');

        if (history.pushState) {
            var newurl = window.location.href.split('&tab=')[0]  + '&tab=bs';
            console.log('newurl===> ' + newurl);
            window.history.pushState({path:newurl},'',newurl);
        }

        helper.handleActive(cmp,supportAccountId,rescheduling,existingServiceAppointmentId);
                   
           /*console.log('rescheduling=====> ' + rescheduling);
           console.log('existingServiceAppointmentId=====> ' + existingServiceAppointmentId);
           
           console.log('@@@@@@====> supportAccountId ' + supportAccountId);
       cmp.set("v.bShowSpinner" , true);
        var action = cmp.get("c.fetchAAEResources");
        //action.setParams({ supportAccId : supportAccountId });
        action.setCallback(this, function(response) {
            cmp.set("v.bShowSpinner" , false);
            var state = response.getState();
            if (state === "SUCCESS") {             
                console.log("From server: " + response.getReturnValue());
                var res = response.getReturnValue();
                 console.log('7 resource ids ===> ' + res);
                helper.handleActive(cmp,supportAccountId,rescheduling,existingServiceAppointmentId,res);

                if(!response.getReturnValue()){
                  ////  cmp.find('errMsgId').set("v.isTrue" , false);
                 ////   cmp.find('flowDisplay').set("v.isTrue" , true);
                    
                   
                }else{
             /////     cmp.find('errMsgId').set("v.isTrue" , true);
              /////    cmp.find('flowDisplay').set("v.isTrue" , false);
                }
               
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

       
        $A.enqueueAction(action);*/

          
    },

    cancel : function(cmp,event,helper){
        var eSupport_Community_URL = $A.get("$Label.c.eSupport_Community_URL");
        window.open(eSupport_Community_URL, '_self');
        //window.location.href = '/s/';
    },

    //<T01>
    /*
	 Method Name : handleStatusChange
	 Description : Handles the Flow Status change event
	 Parameters	 : cmp, event,helper
	 Return Type : None
	 */
    handleStatusChange : function (cmp, event,helper) {
        if(event.getParam("status") === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            for(var i = 0; i < outputVariables.length; i++) {
               let outputVar = outputVariables[i];
               if(outputVar.name === "strCaseId") {
                cmp.set("v.bShowSpinner" , true);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/casedetails?caseId="+outputVar.value,
                    "isredirect": "true"
                });
                urlEvent.fire();
               }
            }
         }
     }
     //</T01>
})