public class opportunityItemCtrl {
    
  public static Opportunity getOpportunityList(String recId){
      SObjectAccessDecision decision = Security.stripInaccessible(
                                       AccessType.READABLE,
                                       [Select Id,Name, StageName, CloseDate, Amount From Opportunity where Id =: recId]);
      system.debug('extractOpportunity' + extractOpportunity(decision));
      return extractOpportunity(decision);   
   }
    
    
    public static Opportunity getNeedsAnalys(String recId, String stage){
      SObjectAccessDecision decision = Security.stripInaccessible(
                                       AccessType.READABLE,
                                       [Select Id,Name, StageName, CloseDate, Amount
                                        from Opportunity where StageName =: stage AND Id =: recId]);
         system.debug('extractOpportunity222' + extractOpportunity(decision));
      return extractOpportunity(decision);   
   }
    
    
    private static Opportunity extractOpportunity(SObjectAccessDecision decision){
        if(!decision.getRecords().isEmpty()){
            return (Opportunity)decision.getRecords()[0];
        }
        else{           
            return new Opportunity();
        }
    }
    
    
}