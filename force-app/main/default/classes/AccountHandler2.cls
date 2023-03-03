Public class AccountHandler2{
public static void InsertMultipleAccont(integer value){
integer n = 1;
list<account>ADlist = new list<account>();
while(n<=value){
Account AD = new Account();
AD.name = 'Acme Inc '+n;
AD.AccountNumber = 'A000 '+n;
n++;
ADlist.add(AD);
}
insert ADlist;
}
}