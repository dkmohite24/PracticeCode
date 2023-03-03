trigger AccountTriPhone on Account (before update,before insert) {

    if(trigger.isbefore && trigger.isinsert){
    
    AccountPhoneTRI Phone = new AccountPhoneTRI();
    phone.AccountPhoneTRImeth(trigger.new);
 }
}