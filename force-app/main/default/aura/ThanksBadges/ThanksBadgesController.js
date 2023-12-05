({
  doInit: function (component) {
    var action = component.get("c.getAllBadgesGivenToMe");
    action.setParams({
      userRecordId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.badges", response.getReturnValue());
      } else if (state === "INCOMPLETE") {
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});