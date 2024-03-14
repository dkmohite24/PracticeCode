global class PRPC_DeleteDuplicateAwaareRecordFromReal implements Database.Batchable<sObject>,Database.stateful,Schedulable  {
    
    global static string queryInclude;
    global final set<string> uniqueKey = new set<string>();
    global final list<sobject>deleteDuplicateRec = new list<sObject>();
    public list<Sobject> start(Database.BatchableContext BC) {
        Integer storeMonth = Date.today().month();
        Integer storeYear = Date.today().year();
        integer actualMonth = storeMonth-1;
        
        if(storeMonth == 1){
            storeYear = storeYear -1;
        }
        
        string Query ='SELECT Distributor_Ship_To__c,Claim_Number__c,repair_order_number__c,Year__c FROM TAT_Data__C where Source_Type__c=\'AWARE\'AND Year__c=:storeYear ORDER BY CreatedDate ASC';
        If(Test.isRunningTest()){
           // Query += ' where Real_Object_Api_Name__c=\''+ queryInclude +'\'';
        }
        list<Sobject>returnQuery = Database.query(Query);
        
        return returnQuery;
        
    }
    public void execute(SchedulableContext sc){
            PRPC_DeleteDuplicateAwaareRecordFromReal tatmb =new PRPC_DeleteDuplicateAwaareRecordFromReal();
            Database.executebatch(tatmb);
            }
    
    global void execute(Database.BatchableContext BC, List<TAT_Data__C> ttlist) {
        
        
        system.debug('QueryResults: '+ttlist);
        for( TAT_Data__C tt : ttlist){
                    string unique = string.valueof(tt.Claim_Number__c)+'-'+string.valueof(tt.Distributor_Ship_To__c)+'-'+ string.valueof(tt.repair_order_number__c)+'-'+string.valueof(tt.Year__c);
                if(!uniqueKey.contains(unique)){
                    uniqueKey.add(unique);
                }else{
                    deleteDuplicateRec.add(tt);
                }
            }
       
        
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('SIZE----'+deleteDuplicateRec.size());
        if(deleteDuplicateRec.size()>0){
            system.debug('SIZE----'+deleteDuplicateRec.size());
            Delete deleteDuplicateRec;
        } 
        
    }
    
}