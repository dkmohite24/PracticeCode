({
	doInitHelper : function(component,event,helper) {
		 var action = component.get("c.getOppDetail");  
        action.setParams({  
            "recId":component.get("v.recordId"),  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();              
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();    
                //alert(' resultAAA ' +  result.Name);
                //alert('result ' + JSON.stringify(result));
                component.set("v.oppListItem",result);  
                component.set("v.oppObj",result);
                var reportCard = component.get("v.oppObj.Report_Cards__r[0].Name");
                //alert('reportCard ' + reportCard);
            }  
        });  
        $A.enqueueAction(action);
	},
})