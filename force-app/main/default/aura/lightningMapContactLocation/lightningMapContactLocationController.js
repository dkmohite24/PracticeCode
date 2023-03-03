({
    doInit : function(component, event, helper) {
        let action = component.get("c.fetchContacts");
        action.setParams({
            "accountId":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state =='SUCCESS'){
                let result = response.getReturnValue();
                console.log('Result returned: ' +JSON.stringify(result));
                component.set("v.conObj",result);
                var contacts = component.get("v.conObj");
                helper.loadMap(component,event,helper,contacts);
            }else{
                console.log('Something went wrong! ');
            }
        });
        $A.enqueueAction(action);
    }
})