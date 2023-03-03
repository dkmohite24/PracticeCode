trigger validationOnEmail on Account (Before insert,before update) {


    if(trigger.isbefore && trigger.isinsert){
        
      AccountTriggerClass a = new AccountTriggerClass();
      a.AccountTriggerMeth(trigger.new);
    
    
    }

}