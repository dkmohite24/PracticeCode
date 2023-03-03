@istest

public class testACtoConAddress {
    @istest
    public static void ConToAcMeth(){
    
    Account Acc = new Account(name = 'testAc', ShippingStreet = 'Abc Streets');
    insert Acc;
    contact Con = new Contact(Lastname = 'Testcon', AccountId = Acc.Id,OtherStreet ='bba');
    Insert con;
    Acc.ShippingStreet= 'AAA';
    update Acc;
    system.debug('Con.OtherStreet'+Con.OtherStreet);
        
    List<Contact> Soql = [select id , account.name , Account.ShippingStreet, OtherStreet from contact];
	System.assertequals(1, Soql.size(),'there is no contact available'); 
    system.debug('Con.OtherStreet'+Soql); 
        
        

    }
}