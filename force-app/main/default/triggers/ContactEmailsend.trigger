trigger ContactEmailsend on Contact (before insert) {
    if(trigger.isbefore && trigger.isinsert){
        ContactEmailhandller conhadler = new ContactEmailhandller();
        conhadler.BeforeInsert(trigger.new);
    }

}