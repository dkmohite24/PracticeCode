public with sharing class AccountController {

    /*
    Method: searchAccount
    Para: Account Name
    here passing the Account Name to Fetching all the releated Accounts
    */
    @AuraEnabled (cacheable = true)
    public static List<Account> searchAccount(String accName) {
        string strAccName = '%'+ accName + '%';
        return [Select Id, Name, Website, Industry, Phone from Account WHERE Name LIKE: strAccName Limit 5];
    }
    

}