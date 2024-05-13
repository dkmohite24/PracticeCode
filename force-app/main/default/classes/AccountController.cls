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
  @AuraEnabled(cacheable=true)
   public static List<Account> displayAccounts(){
       return [select Id,Name,Site from Account Limit 10];
   }
   @AuraEnabled
   public static List<Account> updateRecord(String accId){
       System.debug('@@@@AccountId@@@'+accId);
       Account acc=[select Id,Name,Site from Account where Id=:accId];
       acc.site='Approved';
       try{
           update acc;
       }
	   catch (Exception e) {
           System.debug('unable to update the record due to'+e.getMessage());
       }
       return displayAccounts();
   }
    

}