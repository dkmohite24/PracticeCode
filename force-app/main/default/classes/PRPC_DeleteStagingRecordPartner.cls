public without sharing class PRPC_DeleteStagingRecordPartner {
    @AuraEnabled
    public static string DeleteRecord(string recId){
        Id RecordId = recId;
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        try{
            string query = 'select id from '+sObjName +' WHERE Id =:recId';
            list<sObject>queryResult = database.query(query);
            delete queryResult;
            return 'success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

}