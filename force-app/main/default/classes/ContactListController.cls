public class ContactListController {
@AuraEnabled
   public static List<Contact> getContactList(String AccId){
       List<Contact> contactList = new List<contact>([Select Name, Id, Phone, Email From Contact Where AccountID != null AND 
                                                     AccountID=: AccId]);
       return contactList;
   }
    @AuraEnabled
    public static contact InsertCon(Contact con, Id AccountId){
        con.AccountId = AccountId;
        insert con;
        return con;
        	
    }
}