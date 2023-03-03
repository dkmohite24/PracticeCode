({
    sendtoParent : function(component, event) {
        var cmdEvent = component.getEvent("cmdEvent");
        var sendText = component.get('v.inputValue');
        alert('text to send parent comp is '+sendText);
        cmdEvent.setParams({
            "textToBesent": component.get("v.inputValue")
        });
        
        cmdEvent.fire(); 
    }
})