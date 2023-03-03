public class NewInsertContact{
    public Static void NewInsertContactMeth(){
    Contact c = New Contact();
    c.LastName = 'kumar';
    c.FirstName = 'kishor';
    c.Phone = '9755441115';
    c.LeadSource = 'Web';
    system.debug('ValueIn c:'+c);
    insert c;
    
    }
    
    
}