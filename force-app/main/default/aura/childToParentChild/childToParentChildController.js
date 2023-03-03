({
	childEvntAction : function(component, event,helper) {         
        var myEvent = component.getEvent("myEvent");         
        myEvent.setParams({
            "cmpMsg" : "Learn Step-by-step Salesforce Tutorial From -- gfhggjgbjhgvds",
            "popFadeEvnt" : "slds-show"
        });        
        myEvent.fire(); 
    }
})