public class UpdateCount {
    list<Account>Con = [select id ,count__c from account order by id Asc limit 20];
    

}