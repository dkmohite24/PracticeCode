global class PRPC_DeleteStagingRecord implements Schedulable{
    
    public list<TAT_Turnt_staging__c> tatList = new list<TAT_Turnt_staging__c>();
    public string cronName;
    public list<End_Customer_Staging_Data__c> Endlist = new list<End_Customer_Staging_Data__c>();
    global void execute(SchedulableContext SC) {
        try{
        if(tatList.size()>0){
            Delete tatList;
        }else if(Endlist.size()>0){
            Delete Endlist;
        }
        }catch(exception e){
            
        }
        try{
        CronTrigger a = [select id from CronTrigger where CronJobDetail.Name =:cronName] ;
        
        system.abortJob(a.id);
        }catch(exception e){
            
        }
    }
    
}