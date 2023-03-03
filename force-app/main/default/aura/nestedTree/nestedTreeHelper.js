({
    //Fetch the Accounts from the Apex controller
    getAccounts: function(component) {        
        var action = component.get("c.getAccounts");
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set("v.Accounts", actionResult.getReturnValue());            
        });        
        $A.enqueueAction(action);                
    },        
})