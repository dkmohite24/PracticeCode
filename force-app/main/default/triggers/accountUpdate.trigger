trigger accountUpdate on Account (before insert) {
    if(trigger.isbefore && trigger.isinsert ){
        accountUpdateHadler ConIns = New accountUpdateHadler();
        ConIns.accountUpdateHadlerMethod(trigger.new);
    }
    
}