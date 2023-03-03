public class customPathStatusCtrl {
  
     @AuraEnabled
    public static Opportunity stageNamePath(String recId){
        Opportunity stageList = [Select Id, Name, StageName From Opportunity Where Id='0062w000009bFqqAAE'];
        system.debug('stageList ' + stageList);
        return stageList;
    }
     
}