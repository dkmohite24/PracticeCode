({
    Doinit: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        helper.getObjList(component, pageNumber, pageSize);
    },
    handleFirst: function(component, event, helper) {
        var next = true;
        var prev = true;
        console.log('hi form next '+next);
        var PageNumber = component.get("v.PageNumber"); 
        PageNumber=1;
        var selectedValue = component.get("v.selectedValue");
        var FirstId = component.get("v.FirstId");
        var LastId = component.get("v.LastId");
        var pageSize = component.find("pageSize").get("v.value");
        console.log('next'+PageNumber);
        helper.getAllData(component, selectedValue, PageNumber, pageSize, next, prev, FirstId, LastId);
    },
    
    handleNext: function(component, event, helper) {
        var next = true;
        var prev = false;
        console.log('hi form next '+next);
        var PageNumber = component.get("v.PageNumber"); 
        PageNumber=PageNumber+1;
        var selectedValue = component.get("v.selectedValue");
        var FirstId = component.get("v.FirstId");
        var LastId = component.get("v.LastId");
        var pageSize = component.find("pageSize").get("v.value");
        console.log('next'+PageNumber);
        helper.getAllData(component, selectedValue, PageNumber, pageSize, next, prev, FirstId, LastId);
    },
    
    handlePrev: function(component, event, helper) {
        var next = false;
        var prev = true;
        var PageNumber = component.get("v.PageNumber"); 
        PageNumber=PageNumber-1;
        var selectedValue = component.get("v.selectedValue");
        var pageSize = component.find("pageSize").get("v.value");
        var FirstId = component.get("v.FirstId");
        var LastId = component.get("v.LastId");
        console.log('pre'+PageNumber);
        helper.getAllData(component,selectedValue, PageNumber, pageSize, next, prev, FirstId, LastId);
    },
    handleLast: function(component, event, helper) {
        var next = false;
        var prev = false;
        var PageNumber = component.get("v.PageNumber");
        var totalPages = component.get("v.totalPages");
        PageNumber=totalPages;
        var selectedValue = component.get("v.selectedValue");
        var pageSize = component.find("pageSize").get("v.value");
        var FirstId = component.get("v.FirstId");
        var LastId = component.get("v.LastId");
        console.log('pre'+PageNumber);
        helper.getAllData(component,selectedValue, PageNumber, pageSize, next, prev, FirstId, LastId);
    },
    
    
    onSelectChange: function(component, event, helper) {
        
        var PageNumber = component.get("v.PageNumber");
        var selectedValue = component.get("v.selectedValue");
        var PageSize = component.find("pageSize").get("v.value");
        console.log(PageSize);
        PageNumber =1;
        helper.getAllData(component, selectedValue, PageNumber, PageSize);
    },
    getData: function(component, event, helper) {
        
        var PageNumber = component.get("v.PageNumber");
        var selectedValue = component.get("v.selectedValue");
        var PageSize = component.find("pageSize").get("v.value");
        
        
        helper.getAllData(component, selectedValue, PageNumber, PageSize);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }    
})