({
    DoCreatemap : function(component, event, helper) {
        var map = []; 
        for(var i=0; i<10;i++){
            map.push({
                key:i,
                value: 'Value'+i
            });
        }
        component.set('v.CreateMap',map);
    },
    doInit : function(component, event, helper) {
        var action = component.get('c.getContactList');
        action.setParams({
            AccId : component.get('v.recordId'),
        });
        action.setCallback(this, function(response){
            var responseValue = response.getReturnValue();
            console.log('responseValue', responseValue);
            component.set('v.contactList',responseValue)
        });
        
        $A.enqueueAction(action, false);
    },
    Doredirect : function(component, event, helper){
        var eventSource = event.getSource();
        var id = eventSource.get('v.name');
        alert(id);
    }
})