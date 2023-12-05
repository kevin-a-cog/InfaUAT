({
    clickAdd: function(component, event, helper) {
            var recids = component.get( "v.recordId" );
            var action = component.get( "c.fetchemails" );
            action.setParam("emailids",recids);
            
            action.setCallback(this, function(response) {  
                var state = response.getState();  
                if ( state === "SUCCESS" ) {  
                    
                    var res = response.getReturnValue();      
                    console.log('response'+response);
                    console.log('res'+res[0].em);
                    var attach = 'path';
                    if(res[0].em!=null && res[0].em!='undefined')
                    {
                        var email = res[0].em.FromAddress;
                        
                        var subject = res[0].em.Subject;
                        var emailBody = res[0].em.HtmlBody;
                        component.set("v.messageBody",emailBody);
                        component.set("v.messagesubject",subject);
                    }
                    
                    var txtval;
                    if(res[0].u != null)
                        txtval = "To:"+  res[0].u.Name + "<"+email+">"+"\n";
                    else 
                        txtval = "To: <"+email+">"+"\n"; 
                    txtval = txtval + "Subject:" + "RE:" + subject + "\n";
                    txtval = txtval + "X-Unsent: 1"+ "\n";
                    txtval = txtval + "Content-Type: text/html" + "\n"; 
                    txtval = txtval + "\n";
                    txtval = txtval + "</p></p></n></n>";
                    if(res[0].u != null)
                        txtval = txtval + "<b> From: </b>" + res[0].u.Name + "<"+email+">"+"</p>";
                    else
                        txtval = txtval + "<b> From: </b>"+email+"</p>";
                    txtval = txtval + "<b> Sent: </b>" + res[0].em.MessageDate + "</p>";
                    txtval = txtval + "<b> To: </b>" + res[0].em.ToAddress + "</p>";
                    txtval = txtval + "<b> Subject: </b>" + res[0].em.Subject + "</p>";
                    
                    
                    txtval = txtval + emailBody 
                    txtval = txtval + "\n";
                    var newlink = document.createElement('a');
                    newlink.setAttribute('download', 'message.eml');
                    newlink.setAttribute('href', 'showSignature(xyz)');
                    newlink.setAttribute("type", "hidden");  
                    newlink.setAttribute('id','downloadlink');
                    
                    newlink.href = helper.makeTextFile(txtval);
                    console.log('afer'+txtval);
                    
                    document.body.appendChild(newlink);
                    document.getElementById('downloadlink').click();
                    
                    component.set("v.downloaded","true");
                      var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                           
                            "duration":'7000',
                            "type": 'success',
                            "mode":"dismissible",
                            "message": 'Downloaded Successfully. Please open downloaded Email to preview it.'
                    });
                        
                      toastEvent.fire(); 
                }  
            });  
            $A.enqueueAction(action);  
             
          window.setTimeout(
            $A.getCallback(function() {
                 $A.get("e.force:closeQuickAction").fire();
                window.location.reload();
            }), 7000
        );
    },
    
    
    
    
    
})