trigger updateStatusTrigger on Contact (after insert) {
   if(trigger.isInsert && trigger.isAfter){
       updateStatusTriggerHelper.afterInsert(trigger.new);
   }
   if(trigger.isupdate && trigger.isAfter){
       updateStatusTriggerHelper.afterUpdate();
   }
   if(trigger.isDelete && trigger.isAfter){
       updateStatusTriggerHelper.afterDelete();
       
   }
   if(trigger.isUnDelete && trigger.isAfter){
       updateStatusTriggerHelper.afterUndelete();
   }
   
}