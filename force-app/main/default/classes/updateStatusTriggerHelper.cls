public class updateStatusTriggerHelper {
   public static void afterInsert(List<Contact> conInsertList){
       
       List<Id> accountIdwithContactField = new List<Id>();
       List<Account> accList = new List<Account>();
       List<Contact> conlistNew = new List<Contact>();
       Set<id> accountId = new Set<id>();
       Set<Id> ContactIds = new Set<Id>();
       for(Contact con:conInsertList) {
           accountId.add(con.AccountId);
       }
       
       List<Account> accConList = [SELECT Name, ( SELECT LastName FROM Contacts ) FROM Account Where id in: accountId];
       accList = [select id,name,(select name, id, email from contacts) from account];
       
           List<Account> accListWithStatus = [select id, name, (select id, name from Contacts) from account Where id in: accountId order by LastModifiedDate desc];
       List<contact> activeUser = new List<Contact>();
       List<contact> inactiveUser = new List<Contact>();
       system.debug('accListWithStatus' + accListWithStatus);
       for(Account singleObject : accListWithStatus) {
           system.debug(singleObject);
           for(Contact childContact : singleObject.Contacts) {
               system.debug('Contact Status: ' + childContact);
               if (childContact.id =='active'){
                   activeUser.add(childContact);
               }else{
                   inactiveUser.add(childContact);
               }
               
           }
                       
       }
       
   }
   public static void afterUpdate(){
       
   }
   public static void afterDelete(){
       
   }
   public static void afterUndelete(){
       
   }
}