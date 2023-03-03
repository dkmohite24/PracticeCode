Trigger UpdateAddressOnContact on Account (after update) {

    list<Contact> Newcon = new list<Contact>();
    Set<Id> accountIds = Trigger.newMap.keySet();
    //query contacts related to triggering accounts
    List<Contact> con = [SELECT AccountId,Email,Id,LastName,Name,OtherStreet FROM Contact where AccountId IN:accountIds]; 

    account a;
    for(Contact c : con) {
        a = Trigger.newMap.get(c.accountId);
        c.OtherStreet = a.ShippingStreet;
        /*c.MailingStreet     = a.BillingStreet;
        c.MailingCity       = a.BillingCity;
        c.MailingState      = a.BillingState;
        c.MailingPostalCode = a.BillingPostalCode;
        c.MailingCountry    = a.BillingCountry;*/
        Newcon.add(c);
    }
    update Newcon;
}