Public class InsertAccountContactTRI {
public void InsertAccountContactTRIMeth(List<Account> accounts){
    List<Contact> ct = new list<contact>();
    for(Account acc: accounts){
    Contact c = new Contact();
    c.AccountId = acc.Id;
    
    c.LastName = acc.Name;
    c.Phone = acc.Phone;
    c.Email = acc.Email__c;
    
    ct.Add(c);
}
insert ct;





}


}