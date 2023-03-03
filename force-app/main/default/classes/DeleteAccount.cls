public class DeleteAccount{
 PUBLIC void DeleteAccountmeth(){
 
 list<Account>mylist =new list<account>();
 mylist = [SELECT Exeternal_ID__c FROM Account order by Exeternal_ID__c desc nulls last limit 5];
 delete mylist;
 
 }
}