/**
 * @description       : Query the 10 Contacts and return the results
**/
public with sharing class exelExportApex {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccountDataToExport(String accId){
        List<Contact> lstContacts = [SELECT Id, FirstName, LastName, Email 
    FROM Contact where AccountId = :accId];
    system.debug(accId+'recordId');
        return lstContacts;
    }
}