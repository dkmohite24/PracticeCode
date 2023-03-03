public class AccountPhoneTRI{
    public void AccountPhoneTRImeth(list<account> Accountphonetri){
     system.debug(Accountphonetri);
    for(Account obj:Accountphonetri){
    system.debug(' Debug Starting ' +obj.Phone);
        if(obj.Phone.containsAny('9')){
        system.debug(' Codition If='+obj.Phone);
        Obj.phone.adderror('Phone number should Not Contain Number 9');
        }
    
    
     }
    
    
    
    }
}