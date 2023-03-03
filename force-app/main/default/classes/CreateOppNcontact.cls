public class CreateOppNcontact{
    public void CreateOppNcontact(list<account> AcNew){
        list<opportunity> Listop = new list<opportunity>();
        list<Contact> Conlist = New list<contact>();
        system.debug('Trigger.new list :'+AcNew);
        system.debug('opportunity list :'+Listop);
        system.debug('Contact list :'+Conlist);
        
        for(account Ac:AcNew){
            
            opportunity Op = new opportunity();
            Op.AccountId = Ac.id;
            Op.name = Ac.name;
            Op.StageName = 'Prospecting';
            Op.CloseDate = Date.Today();
            
            
            Contact C = New Contact();
            C.AccountId = Ac.id;
            C.lastName = Ac.Name;
            
            Listop.add(op);
            conlist.add(C);
            
            
            
        }
        insert Listop;
        insert conlist;
        system.debug('opportunity list New :'+Listop);
        system.debug('Contact list new :'+Conlist);
    }
}