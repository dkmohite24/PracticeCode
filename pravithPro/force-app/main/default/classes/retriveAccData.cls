public with sharing class retriveAccData {
    public retriveAccData() {

    }
    @AuraEnabled(cacheable = true)
    public static list<sobject> getAccLwc(string Name){
        String key = '%'+Name+'%';
        String Query = 'select id ,name , phone from Account Where Name like :key Limit 5';
        return Database.query(Query);
        
    }
    @AuraEnabled(cacheable = true)
    public static list<sobject> getconLwc(string searchCon){
        String key = '%'+searchCon+'%';
        String Query = 'select id ,name , phone from Contact Where Name like :key Limit 5';
        return Database.query(Query);
        
    }
}
