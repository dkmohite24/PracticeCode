public with sharing class getAccountRecordsLwc {
    
    @AuraEnabled (cacheable=true)
    public static list <Account> getAccounts(){ 
        try {
            return [select id ,(Select Id ,Name,Email from Contacts),Email, name from account LIMIT 10];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
