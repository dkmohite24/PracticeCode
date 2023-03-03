({
    
    openModal:function(component, event, helper) {
        var changeType = event.getParams().changeType;
        
        if (changeType === "CHANGED" && (('StageName' in event.getParams().changedFields))) {
            var newStageName = event.getParams().changedFields.StageName.value;
            var oldStageName = event.getParams().changedFields.StageName.oldValue;
            if(newStageName == 'Need Analysis' && oldStageName == 'Closed Won'){
                component.set('v.openModal',true);
            }
        }
    },
    
    handleOk:function(component, event, helper) {
        
        component.set('v.openModal',false);
        
    },
    
    handleCancel : function(component, event, helper) {
        component.set('v.openModal',false);
    }
})