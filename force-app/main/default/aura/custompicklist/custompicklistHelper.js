({
    getObjList: function(component, event, helper) {
        var action = component.get("c.getObjectName");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response',+response);
            if (state === "SUCCESS") {          
                var allValues = response.getReturnValue();
                component.set("v.options", allValues);
            }                    
        });
        $A.enqueueAction(action);
    },
    getAllData: function(component, selectedValue, PageNumber, PageSize, next, prev, FirstId, LastId, totalRecords){
        
        var action = component.get("c.getObjectsData");
        console.log(PageSize+'helper');
        action.setParams({
            "next" : next,
            "prev" : prev,
            "objSelected" : selectedValue,
            "pageNumber": PageNumber,
            "PageSize": PageSize,
            "FirstId": FirstId,
            "LastId": LastId,
            
       });
       
        action.setCallback(this, function(response) {          
            var allData = response.getReturnValue();
            component.set("v.ObjList", allData.ObjList1);
            component.set("v.PageNumber", allData.PageNumber);
            component.set("v.PageSize", allData.PageSize);
            component.set("v.totalRecords", allData.totalRecords);
            component.set("v.RecordStart", allData.recordStart);
            component.set("v.RecordEnd", allData.recordEnd);
            component.set("v.totalPages", Math.ceil(allData.totalRecords / PageSize));
           component.set("v.FirstId", allData.FirstId);
            component.set("v.LastId", allData.LastId);
            
            
            console.log(Math.ceil(allData.totalRecords / PageSize)+'hi');
           
        });
        $A.enqueueAction(action);
    }
})