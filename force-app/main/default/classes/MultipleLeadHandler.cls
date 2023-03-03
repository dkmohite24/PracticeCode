public class MultipleLeadHandler {
    public void createLead (string lastName,string email ,string company ) {
        Lead ld = new lead (LastName =lastName , Email =email , Company = company );
        system.debug('Insert Lead'+ld);
        insert ld;
        
    }
    
    public void updateLead ()
    {
        
        list<Lead> ld1 = [SELECT id, Name,Email FROM lead order by CreatedDate DESC limit 5 ];
        list<Lead> UpadtedLst = new list<Lead>();
        system.debug(ld1);
        for(Lead Ld: ld1){
            Ld.Email= 'Mayu333@gmail.com';
            UpadtedLst.add(Ld);
            
        }
        
        update UpadtedLst;
        system.debug(UpadtedLst);
        
    }
    
    public void deleteLead (){
        list<Lead> ld2 = [SELECT id,Name,Email FROM Lead ORDER BY CreatedDate DESC limit 5];
        System.debug(ld2);
        delete ld2;
        
    }
     
    
    
}