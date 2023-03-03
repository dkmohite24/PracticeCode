({
    doInit : function(component, event, helper) {
        var ContractId = component.get("v.recordId");
        var action = component.get("c.getcondata");
        console.log('selectedStep1'+ContractId);
        action.setParams({
                "ContractId" : ContractId,
        });
      /*  action.setCallback(this, function(response){
            var action = component.get("c.getcondata");
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var Con = response.getReturnValue();
                component.set("v.selectedStep", Con[0].Status);
                console.log('selectedStep2'+JSON.stringify(response.getReturnValue()));
                console.log('selectedStep2'+Con[0].Status);
                
            }
            
        });*/
        
        $A.enqueueAction(action);
    },
    handleNext : function(component,event,helper){
        var getselectedStep = component.get("v.selectedStep");
        
        var showModal = component.get('v.showModal');
        if(getselectedStep == "Draft"){
            component.set("v.showModal", "!showModal");
        }
        else if(getselectedStep == "In Approval Process"){
            component.set("v.selectedStep", "Activated");
            var action = component.get("c.updatestatus");
            var selectedstep = component.get("v.selectedStep")
            var ContractId = component.get('v.recordId');
            console.log('selectedStep3'+selectedstep);
            action.setParams({
                "ContractId" : ContractId,
                "selectedStep" : selectedstep,  
            });
            action.setCallback(this, function(response) {          
            $A.get("e.force:refreshView").fire();    
            });
            $A.enqueueAction(action);
            
        }
        
    },
    
    handlePrev : function(component,event,helper){
        var getselectedStep = component.get("v.selectedStep");
        if(getselectedStep == "Activated"){
            alert('You cannt change status');
        }
        else if(getselectedStep == "In Approval Process"){
            component.set("v.selectedStep", "Draft");
            var action = component.get("c.updatestatus");
            var selectedstep = component.get("v.selectedStep")
            console.log('selectedStep4'+selectedstep);
            var ContractId = component.get('v.recordId');
            action.setParams({
                "selectedStep" : selectedstep, 
                "ContractId" : ContractId,
            });
            action.setCallback(this, function(response) {  
                
            $A.get("e.force:refreshView").fire();    
            });
            $A.enqueueAction(action);
        }
    },
    
    closeModal : function(component, event, helper) {
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
    },
    apexcall : function(component, event, helper) {
        var hideModal = component.get('v.showModal');
        var selectedstep = 'In Approval Process'
        component.set("v.selectedStep", "In Approval Process");
        component.set('v.showModal', !hideModal);
        var action = component.get("c.updatestatus");
        console.log('selectedStep  5 '+selectedstep);
        var ContractId = component.get('v.recordId');
        action.setParams({
            "selectedStep" : selectedstep,
            "ContractId" : ContractId,
            
            
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") { 
            component.set("v.selectedStep", "In Approval Process");
            }
            
            
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
        
    },
})