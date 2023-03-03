({
    doinit : function(component, event, helper) {  
        var action=  component.get('c.getmymap');  // Calling apex method
      
        action.setCallback(this,function(response)   // getting response back from apex method
                           {
                               var state=response.getState();            // getting the state
                               if(state==='SUCCESS')
                               {
                                   component.set('v.Mapuse',response.getReturnValue());   // setting the value in map attribute
                               }
                           });
        $A.enqueueAction(action);
    }
})