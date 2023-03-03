({
    doInit : function(component, event, helper) {          
        helper.getAccounts(component);          
    },
     
    showPanel : function(component, event, helper){        
        helper.onLoadPage(component); 
    },
     
})