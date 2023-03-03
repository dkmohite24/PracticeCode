public class crossMethodCtrl {

    @AuraEnabled
    public static Opportunity getOppDetail(String recId){
        final String needsAnalys = 'Needs Analysis';
        Opportunity opp = opportunityItemCtrl.getOpportunityList(recId);
        Opportunity returnOpp;
        system.debug('opp ' + opp);        
        if(opp.StageName == constantsCtrl.stageNeedsAnalysis){
             returnOpp = opportunityItemCtrl.getNeedsAnalys(recId, opp.StageName);
            system.debug('returnOppAAA ' + returnOpp);
        }
        return returnOpp;
    }
    
}