trigger updateAccountRating on opportunity(after insert,after update)
{
    Set<id> Accountids = new set<id>();
    List<Account> Accounts = new List<Account>();
        if(trigger.new != null)
        {
            for(opportunity opp:trigger.new)
            {
                if(opp.StageName =='Closed Won')
                    {
                      AccountIds.add(opp.AccountId);
                    }
            }
        }
    List<Account> a  = [Select id,Rating from Account where Id IN: AccountIds];
    if(a != null){
        for(Account acc: a)
       {
          acc.Rating ='Hot';
          Accounts.add(acc);
       }
    }
          update Accounts;
}