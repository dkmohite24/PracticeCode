public class AccountTocontactTRI{
    public void AccountAdress(list<Account>TriggerNewAc){
        set<ID>AccountID = new set<ID>();
        for(Account IDNEW: TriggerNewAc){
            AccountID.Add(IDNEW.id);
        }
        system.debug('SET OF ACCOUNTID :'+AccountID);
        
        list<contact>NewCon = new list<contact>();
        list<contact>contactAD = new list<contact>();
        
        NewCon = [SELECT AccountId,Email,Id,LastName,Name,OtherStreet FROM Contact where AccountId IN:AccountID];
        system.debug('contact soql :'+NewCon);
        
        for(Account SUB: TriggerNewAc){
            for(contact CON: NewCon){
                con.OtherStreet = SUB.ShippingStreet;
                Con.id = Con.id;
                contactAD.add(con);
                
            }
            
        }
        update contactAD;
    }
}