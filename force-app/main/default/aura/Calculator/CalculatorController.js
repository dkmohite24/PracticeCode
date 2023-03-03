({
    DoAdd : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        //alert(parseInt(no1) + parseInt(no2));
        component.set('v.Output',parseInt(no1) + parseInt(no2));
    },
    DoSub : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        
        component.set('v.Output',parseInt(no1) - parseInt(no2));
    },
    DoMult : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
      component.set('v.Output',parseInt(no1) * parseInt(no2));
        //alert(parseInt(no1) * parseInt(no2));
    },
    DoDiv : function(component, event, helper) {
        var no1 = component.get('v.InputNo1');
        var no2 = component.get('v.InputNo2');
        //alert(parseInt(no1) / parseInt(no2));
        component.set('v.Output',parseInt(no1) / parseInt(no2));
    }
})