({
doSave : function(component, event, helper) {
var action = component.get('c.InsertCon');
       action.setParams({
           con : component.get('v.CreateCon'),
           AccountId : component.get('v.accountId')
       });
       action.setCallback(this, function(response){
           var state = response.getState();
           alert(state);
           if(state === 'SUCCESS' || state === 'DRAFT'){
               var responseValue = response.getReturnValue();
               console.log(v.CreateCon.Firstname);
               
           }else if(state === 'INCOMPLETE'){
               
           }else if(state === 'ERROR'){
               var errors = responce.getError();
               console.log('Errors', errors[0].pageErrors);
               console.log('Errors', errors[0].fieldErrors);
               
               if(errors || errors[0].message){
                   
               }
               
 
               
           }
           
       },'ALL');
       $A.enqueueAction(action);
}
})