trigger CreateNewOpportunity on Account (after insert, after update) {
    List<Opportunity> opportunities1 = new List<Opportunity>();
    for(Account acct:Trigger.new){
        if(acct.industry == 'Electronics'){
        Opportunity nopportunity = new Opportunity();
        nopportunity.Name = acct.Name;
        nopportunity.AccountId = acct.Id;
        nopportunity.Amount = 10000;
        nopportunity.StageName = 'Proposal';
        nopportunity.CloseDate = System.today() + 30;

        opportunities1.add(nopportunity);
        }
    }

    if(opportunities1.isEmpty()== false){
       Database.upsert(opportunities1);
    }
}