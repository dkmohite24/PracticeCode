({
    doInit: function (component, event, helper) {
        // call getLocation apex class method 
        var action = component.get("c.getLocation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // set mapMarkersData attribute values with 'accountLocationWrapper' data 
                component.set('v.mapMarkersData',response.getReturnValue());
                // set the mapCenter location.
                component.set('v.mapCenter', {
                    location: {
                        Country: 'United States'
                    }
                });
                // set map markers title  
                component.set('v.markersTitle', 'Google Office locations.');
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