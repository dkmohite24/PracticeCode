public class CheckOpstageHandler {
    Public void BeforeUpdate(list <Account>Trinew){
      set<id> OpIdset = new set<id>(); 
        for(account Ac : Trinew){
            OpIdset.add(Ac.id);
        }
        List<opportunity> RelatedOpp = [select Id, StageName from Opportunity where Id IN: OpIdset];
        for(opportunity op: RelatedOpp){
            if (system.today() > op.createdDate +30){
                op.StageName= 'Closed Lost';
                
            }
            else{
                 op.StageName= 'Closed Won';
            }
            
        }
    }
}