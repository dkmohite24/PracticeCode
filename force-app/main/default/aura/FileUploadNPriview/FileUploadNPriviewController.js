({
    /**Open image preview */
    getSelectedFile : function(component,event,helper){
        // display modle and set seletedDocumentId attribute with selected record Id  
        component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id"));
    },
    /**Close preview */
    closeModel: function(component, event, helper) {
        // for Close Model, set the "hasModalOpen" attribute to "FALSE" 
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null);
    },
})