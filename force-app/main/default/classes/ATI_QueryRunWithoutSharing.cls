/**
* (c) 2019 Tavant Technology.
* -------------------------------------------------------------------------------------------------
This class is used to run query without sharing
* --------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
public without sharing class ATI_QueryRunWithoutSharing {
    /*
        Method Name :   runQuery
        Params      :   String query
    */
    public static List<sObject> runQuery(String query) {
        return Database.query(query);
    }
    
    /*
        Method Name :   runQueryWithIds
        Params      :   query, idList
    */
    public static List<sObject> runQueryWithIds(String query,List<Id> idList) {
        return Database.query(query);
    }
    
    
    /*
        Method Name :   runQueryWithIdsStringList
        Params      :   query, idList
    */
    public static List<sObject> runQueryWithIdsStringList(String query,List<String> idList) {
        return Database.query(query);
    }
    
    /*
        Method Name :   save
        Params      :   sobjectList
    */
    public static List<Database.UpsertResult> save(List<sObject> sobjectList) {
        return Database.upsert(sobjectList, false);
    }
    
    /*
        Method Name :   insertData
        Params      :   sobjectList
    */
    public static List<Database.SaveResult> insertData(List<sObject> sobjectList) {
        return Database.insert(sobjectList, false);//
    }
    
    /*
        Method Name :   updateRecordsWithoutSharing
        Params      :   sobjectList, allOrNone -> update if error boolean
    */
    public static List<Database.SaveResult> updateRecordsWithoutSharing(List<sObject> sobjectList,boolean allOrNone) {
        return Database.update(sobjectList, allOrNone);
    }

    /*
        Method Name :   fetchClaimParentAccountForDistributor
        Params      :   fieldsToFetch , claimId
    */
    public static WOD_2__Claim__c fetchClaimParentAccountForDistributor(List<String> fieldsToFetch, String claimId){
        String query = 'SELECT '+String.join(fieldsToFetch,',');
        query += ' from WOD_2__Claim__c where id = :claimId';
        return Database.query(query);    
    }
    
    public static List<Database.DeleteResult> deleteData(List<sObject> sobjectList,boolean allOrNone) {
        return Database.delete(sobjectList, allOrNone);
    }
}