trigger SendMailToOwner on Account (After insert,Before Insert) {

    If(Trigger.isAfter && Trigger.isinsert){
        SendMailToOwnerTRI ACC = new SendMailToOwnerTRI();
        ACC.sendEmail(trigger.new);
    }

}