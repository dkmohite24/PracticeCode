trigger AccountAddress on Account (before update) {
if (Trigger.isUpdate && Trigger.isbefore){
AccountTocontactTRI ASA = new AccountTocontactTRI();
ASA.AccountAdress(trigger.new);
}
}