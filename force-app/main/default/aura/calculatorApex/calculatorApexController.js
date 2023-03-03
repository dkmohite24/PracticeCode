({
    DoAdd : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        //alert(parseInt(no1) + parseInt(no2));
        var action = component.get('c.calculateSum'); 
        action.setParams({
            "fnumber" : no1,
            "Snumber" : no2});
        action.setCallback(this, function(response){
            var state = response.getState();
            //Checking the state
            if(state === "SUCCESS"){
                //Returns and set the value from the apex to attribute
                component.set("v.Output",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        //component.set('v.Output',parseInt(no1) + parseInt(no2));
    },
    DoSub : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        var action = component.get('c.calculateSub'); 
        action.setParams({
            "fnumber" : no1,
            "Snumber" : no2});
        action.setCallback(this, function(response){
            var state = response.getState();
            //Checking the state
            if(state === "SUCCESS"){
                //Returns and set the value from the apex to attribute
                component.set("v.Output",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        //component.set('v.Output',parseInt(no1) - parseInt(no2));
    },
    DoMult : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        var action = component.get('c.calculateMult'); 
        action.setParams({
            "fnumber" : no1,
            "Snumber" : no2});
        action.setCallback(this, function(response){
            var state = response.getState();
            //Checking the state
            if(state === "SUCCESS"){
                //Returns and set the value from the apex to attribute
                component.set("v.Output",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        // component.set('v.Output',parseInt(no1) * parseInt(no2));
        //alert(parseInt(no1) * parseInt(no2));
    },
    DoDiv : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        var action = component.get('c.calculateDiv'); 
        action.setParams({
            "fnumber" : no1,
            "Snumber" : no2});
        action.setCallback(this, function(response){
            var state = response.getState();
            //Checking the state
            if(state === "SUCCESS"){
                //Returns and set the value from the apex to attribute
                component.set("v.Output",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        //alert(parseInt(no1) / parseInt(no2));
        component.set('v.Output',parseInt(no1) / parseInt(no2));
        
    }
    
})