Trigger AccountAddress2 on Account (After update) {
if (Trigger.isAfter && Trigger.isUpdate ){
CopyAddressAcToConTRI ASA = new CopyAddressAcToConTRI();
ASA.AccountToContact(trigger.new);
}
}