({
    eventHandler : function(component, event, helper) {
        // Get value from Event
        var childText = event.getParams("textToBesent");
        component.set("v.textFromChild", childText);
        // component.set("v.chilEvent", 'true');
        component.set("v.isModalOpen", true);
        alert('text to send parent comp is ');
    },
    
    closeModel : function(component, event , helper){
        component.set("v.isModalOpen", false);
    }
    
})