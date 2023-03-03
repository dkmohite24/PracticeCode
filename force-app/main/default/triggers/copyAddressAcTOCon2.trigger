trigger copyAddressAcTOCon2 on Account (After update){
    list<Contact> Newcon = new list<Contact>();
    set<id>AccountIds = trigger.NewMap.keyset();
    
    /*Trigger.newMap: It is a map of all records in your trigger. 
    The key used in the map is the record ID, and the value is the record itself.
    .keySet() is a method used on maps that returns all the keys of the map. 
    Since the key in the map above is the record ID, you are returned a 
    set of all IDs on your map.*/

     list<contact> ConSoql = [select id,lastname,MailingStreet,MailingCity,MailingState,AccountId,
                         MailingPostalCode,MailingCountry,OtherStreet from contact where AccountId IN:AccountIds ];
  
      account a;
      for(contact C: ConSoql){
      
        a = Trigger.newMap.get(c.AccountId);
        //c.OtherStreet = a.ShippingStreet;
        c.MailingStreet     = a.BillingStreet;
        c.MailingCity       = a.BillingCity;
        c.MailingState      = a.BillingState;
        c.MailingPostalCode = a.BillingPostalCode;
        c.MailingCountry    = a.BillingCountry;
        NewCon.add(c);
    }
    update NewCon;
      

}