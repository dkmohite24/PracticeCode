({
	parentEventAction : function(component, event, helper) {         
        var cmpMsg = event.getParam("cmpMsg"); 
        var popFadeEvnt = event.getParam("popFadeEvnt");  
        //alert('cmpMsg ' + cmpMsg + 'popFadeEvnt ' + popFadeEvnt);
        component.set("v.w3webMsg", cmpMsg);           
        component.set("v.modalFade", 'slds-show');
    },
    
    cancelPopup:function(component, event, helper){        
        component.set("v.modalFade",'slds-hide');
    }
    
})