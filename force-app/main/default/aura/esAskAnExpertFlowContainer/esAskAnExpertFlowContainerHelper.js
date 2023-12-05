({
    handleActive : function(cmp,supportAccId,rescheduling,existingServiceAppointmentId/*,strServResourceId*/){

        console.log('supportAccId===> ' + supportAccId);
        console.log('rescheduling===> ' + rescheduling);
        console.log('existingServiceAppointmentId===> ' + existingServiceAppointmentId);
        //console.log('strServResourceId===> ' + strServResourceId);
        

        var flow = cmp.find("flowData");
        console.log('flow ===> ' + flow);
        var inputVariables = [
        {
            name : 'parentRecordId',
            type : 'String',
            value : supportAccId
        },
        /*{
            name : 'serviceResourceId',
            type : 'String',
            value : '0Hn1F000000D5LvSAK'
        },
        {
            name : 'serviceterritoryId',
            type : 'String',
            value : cmp.get("v.serviceterritoryId")
        },

        {
            name : 'serviceResourceIdsAAE',
            type : 'String',
            value : strServResourceId
        },
        {
            name : 'sHasRescheduling',
            type : 'String',
            value : rescheduling != null ? rescheduling : ''
        },

        {
            name : 'existingServiceAppointmentId',
            type : 'String',
            value : existingServiceAppointmentId != null ? existingServiceAppointmentId : ''
        },*/

       /* {
            name : 'workTypeIdForRS',
            type : 'String',
            value : '08qg00000009JI9AAM'
        },*/
   
        
        

        ];
        flow.startFlow("AskAnExpertFlow", inputVariables);

       /* var timer = setInterval(
            function(){ 
                var scriptElm = document.createElement('script');
                var inlineCode = document.createTextNode('document.getElementsByClassName("flowRuntimeV2")[0].getElementsByTagName("h2")[1].innerHTML = "Select Product";');
                scriptElm.appendChild(inlineCode);                 
                document.body.appendChild(scriptElm);
        }, 1000);*/

    },

    getParameterByName : function (name) {
        name = name.replace(/[\[\]]/g, '\\$&');
        var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
            results = regex.exec(window.location.href);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    },

    validateSecurityAccess : function(cmp){
        cmp.set("v.bShowSpinner" , true);
        var supportAccountId = this.getParameterByName('supportaccountid'); 
        console.log('supportAccountId---> ' + supportAccountId);
        var action = cmp.get("c.hasAccessCheck");
        action.setParams({ 'supportAccountId' : supportAccountId });
        action.setCallback(this, function(response) {
            cmp.set("v.bShowSpinner" , false);
            var state = response.getState();
            if (state === "SUCCESS") {             
                var res = response.getReturnValue();       
                console.log("has Access ? : " + res);
                if(!res){
                    window.location.href = '/eSupport/s/';
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
        $A.enqueueAction(action);
    }
})