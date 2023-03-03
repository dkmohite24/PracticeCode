({
    showHidePanel : function(component, event, helper) {
        var id=component.get("v.acc.Id");        
        var e=document.getElementById(id);      
        if (e.style.display == 'block' || e.style.display==''){
            e.style.display = 'none';
            component.set("v.ext","plus");
        }else{
            e.style.display = 'block';
            component.set("v.ext","minus");
        } 
    },
})