({
    doInit : function(component, event, helper) { 
        var action = component.get("c.getUserProfiles"); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retrunRes = response.getReturnValue();
                component.set("v.users" ,retrunRes );
            }
        });
        $A.enqueueAction(action);
    }
})