trigger countContact on Contact (after insert, after update, after delete) {
    set<id> newAccountId = new set<id> ();
    list<contact> contacts = trigger.isdelete ? trigger.old : trigger.new;
    list<Account> updateAcclist = new list<Account>();
    for(Contact Con: contacts){
        newAccountId.add(Con.accountid);
    } 

    for(AggregateResult Ar: [SELECT  COUNT(id) cot,Accountid acId From Contact GROUP BY Accountid HAVING AccountId IN:newAccountId]){
        Account Acc = new account();
        acc.id = (ID) ar.get('acId');
        acc.Description = (string) ar.get('cot');
        updateAcclist.add(acc);      
            }   
    update updateAcclist; 
}