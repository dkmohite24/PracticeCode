public Class InsertMultipleContact{
    Public static Void InsertMultipleContactMeth(){
    
    List <Contact> listc = New list<Contact>();
    For(integer i=1; i<=100;i++){
    
        Contact c = New Contact();
        c.LastName = 'KAYKAy'+i;
        c.FirstName = 'Menon'+i;
        c.Phone = '9755441115'+i;
        c.LeadSource = 'Web';
        listc.add(c);
    
    }
    
    system.debug('ValueIn listc:'+listc);
    insert listc;
    
    }


}