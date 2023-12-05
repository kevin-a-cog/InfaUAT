({
    onInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__sSelectedUserId;
        var name = myPageRef.state.c__sSelectedUserName;
        console.log('id===> ' + id);
        console.log('name===> ' + name);
        component.set('v.sSelectedUserId' , id);
        component.set('v.sSelectedUserName' , name);
        component.find('lwcId').set("v.isTrue" , true);
    }
})