trigger TriggerforAwaare on AWAARE_4WARD__c (after insert, after update) {
  if(!Disable_Rules__c.getInstance('TriggerforAwaare').Disable__c) {  
    if(trigger.isafter && trigger.isinsert)
    { 
 TriggerforAwaareHandler.CreatePartnerUser(Trigger.new);
}

    if(trigger.isafter && trigger.isupdate)
    { 
 TriggerforAwaareHandler.CreatePartnerUser(Trigger.new);
}
   }   
}