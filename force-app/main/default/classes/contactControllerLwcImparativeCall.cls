public with sharing class contactControllerLwcImparativeCall {
    @AuraEnabled(cacheable=true)
   
    public static List<Contact> findContact(string searchKey){
        String key = '%' + searchKey + '%';
        
        return [
            SELECT Id,FirstName, LastName,  Phone, Email
            FROM Contact
            WHERE Name LIKE :key
            LIMIT 10
        ]; 
        

    }
}