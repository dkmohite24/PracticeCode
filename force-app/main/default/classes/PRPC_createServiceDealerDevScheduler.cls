/**
 * @Description: To count numbers service dealers each distributors have at the end of each month.
 * 				 Applicable for North America only.
 * Created:  01/25/2021 – Nitish Gyansys
 * Modified: Akanksha Mondal, Ritu Raj Singh
**/
public class PRPC_createServiceDealerDevScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        List<Service_Dealer_Development__c> allServiceDealerList = new List<Service_Dealer_Development__c>();
        List<Account> parentlist =[SELECT Id ,Name,ParentId,Parent.Name,Type,Sales_RegionA__c,(SELECT Id,Name FROM ChildAccounts WHERE Type = 'Service Dealer' AND Service_Dealer_Development__c = true  )FROM Account WHERE (Sales_RegionA__c = 'North America' AND SAP_ID__c != null AND Type = 'Distributor') OR Name LIKE '%Subparent%' ];
        Map<id,integer> parentmap = new Map<id,integer>();
        Map<id,integer> subparentmap = new Map<id,integer>();
         for(Account a:parentlist){
             if(a.Name.contains('Subparent')){
                 if(!subparentmap.containskey(a.ParentId)){
                       subparentmap.put(a.ParentId,a.ChildAccounts.size());
                 }
                 else{
                     Integer add= subparentmap.get(a.ParentId)+ a.ChildAccounts.size();
                     subparentmap.put(a.ParentId,add);
                 }
            
             }
             else{
                 parentmap.put(a.Id,a.ChildAccounts.size());
             }
            
        }
      for(Id i:subparentmap.keyset()){
            if(parentmap.containsKey(i)) {
                integer d= parentmap.get(i) + subparentmap.get(i);
                parentmap.put(i,d);
            }
        }

        for(Account distributor : [SELECT Id,Name FROM Account WHERE id IN :parentmap.keyset()]) {
            
            Service_Dealer_Development__c drlDev = createRecord(distributor, 'Monthly', String.valueOf(system.today().year()), String.valueOf(system.today().month()),parentmap);
            allServiceDealerList.add(drlDev);
            
            //On the month of december creating for the next year baseline(begining of the year)
            if(system.today().month() == 12) {
                Service_Dealer_Development__c drlDevA = createRecord(distributor, 'Annually', String.valueOf(system.today().year()+1), '1',parentmap);
                allServiceDealerList.add(drlDevA);
            }
        }
        if(allServiceDealerList.size() > 0) {
            INSERT allServiceDealerList;
        }
    }
    
    private static Service_Dealer_Development__c createRecord(Account distributor, String type, String year, String Month,Map<id,integer> parentmap) {
        Service_Dealer_Development__c serviceDealerDev = new Service_Dealer_Development__c();
        serviceDealerDev.Distributor__c = distributor.Id;
        serviceDealerDev.Service_Dealer_Count__c = parentmap.get(distributor.id);
        serviceDealerDev.Type__c = type;
        serviceDealerDev.Year__c = year;
        serviceDealerDev.Month__c = month;
        return serviceDealerDev;
    }
    
}