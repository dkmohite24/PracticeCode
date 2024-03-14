public class PRPC_BranchCount {
    
    public static void forInsert(List<Account> newList){
        Set<Id> dist = new Set<Id>();
        for(Account newB : newList){
            if(newB.Type == 'Distributor Branch' && newB.ParentId !=null)
                dist.add(newB.ParentId);
        }
        if(!dist.isEmpty()){
            map<string,list<string>> DistributorBranchCount = new map<string,list<string>>();
			list<Account> lstOfbranch = new list<Account>([select id,parentId from Account where Type = 'Distributor Branch' and sales_RegionA__C != null and PRP_Participation__c=true AND parentId IN:dist ]);
					for(Account branch: lstOfbranch){		
							if(DistributorBranchCount.containsKey(string.valueof(branch.parentId))){
										list<string>newlst = new list<string>();
										newlst = DistributorBranchCount.get(string.valueof(branch.parentId));
										newlst.add(string.valueof(branch.id));
										DistributorBranchCount.put(string.valueof(branch.parentId),newlst);
							}
							else{
										list<string>DBid = new list<string>();
										DBid.add(string.valueof(branch.id));
										DistributorBranchCount.put(string.valueof(branch.parentId),DBid);
										}
									}
            List<Account> a = [Select id, Number_Of_Active_Branches__c from account where type='Distributor' AND ID IN : dist and sales_RegionA__C != null];
            for(Account acc : a){
                if(DistributorBranchCount.containsKey(acc.id)){
                    Integer d = (DistributorBranchCount.get(acc.id)).size();
                    acc.Number_Of_Active_Branches__c = d;
                    
                }
                 else
                {
                  acc.Number_Of_Active_Branches__c = 0;  
                }
            }
            update a;
        }
    }
    
    public static void forUpdate(List<Account> newList){
        system.debug('INSIDE UPDATE');
        Set<Id> dist = new Set<Id>();
        for(Account newB : newList){
      
            if(newB.Type == 'Distributor Branch' && newB.ParentId !=null)
                dist.add(newB.ParentId);
        }
        if(!dist.isEmpty()){
            map<string,list<string>> DistributorBranchCount = new map<string,list<string>>();
       			list<Account> lstOfbranch = new list<Account>([select id,parentId from Account where Type = 'Distributor Branch' and sales_RegionA__C != null and PRP_Participation__c=true AND parentId IN:dist  ]);
					for(Account branch: lstOfbranch){		
							if(DistributorBranchCount.containsKey(string.valueof(branch.parentId))){
										list<string>newlst = new list<string>();
										newlst = DistributorBranchCount.get(string.valueof(branch.parentId));
										newlst.add(string.valueof(branch.id));
										DistributorBranchCount.put(string.valueof(branch.parentId),newlst);
							}
							else{
										list<string>DBid = new list<string>();
										DBid.add(string.valueof(branch.id));
										DistributorBranchCount.put(string.valueof(branch.parentId),DBid);
										}
									}
            List<Account> a = [Select id, Number_Of_Active_Branches__c from account where type='Distributor' AND ID IN : dist and sales_RegionA__C != null];
            for(Account acc : a){
                if(DistributorBranchCount.containsKey(acc.id)){
                    Integer d = (DistributorBranchCount.get(acc.id)).size();
                    acc.Number_Of_Active_Branches__c = d;
                    
                }
                else{
                   acc.Number_Of_Active_Branches__c = 0; 
                }

            }
            update a;
        }
    }
    
    public static void forDelete(List<Account> oldList){
        Set<Id> dist = new Set<Id>();
        for(Account oldB : oldList){
            if(oldB.Type == 'Distributor Branch' && oldB.ParentId !=null)
                dist.add(oldB.ParentId);
        }
        if(!dist.isEmpty()){
            map<string,list<string>> DistributorBranchCount = new map<string,list<string>>();
			list<Account> lstOfbranch = new list<Account>([select id,parentId from Account where Type = 'Distributor Branch' and sales_RegionA__C != null and PRP_Participation__c=true AND parentId IN:dist ]);
					for(Account branch: lstOfbranch){		
							if(DistributorBranchCount.containsKey(string.valueof(branch.parentId))){
										list<string>newlst = new list<string>();
										newlst = DistributorBranchCount.get(string.valueof(branch.parentId));
										newlst.add(string.valueof(branch.id));
										DistributorBranchCount.put(string.valueof(branch.parentId),newlst);
							}
							else{
										list<string>DBid = new list<string>();
										DBid.add(string.valueof(branch.id));
										DistributorBranchCount.put(string.valueof(branch.parentId),DBid);
										}
									}
            List<Account> a = [Select id, Number_Of_Active_Branches__c from account where type='Distributor' AND ID IN : dist and sales_RegionA__C != null];
            for(Account acc : a){
                if(DistributorBranchCount.containsKey(acc.id)){
                    Integer d = (DistributorBranchCount.get(acc.id)).size();
                    acc.Number_Of_Active_Branches__c = d;
                    
                }
                 else
                {
                  acc.Number_Of_Active_Branches__c = 0;  
                }
            }
            
            update a;
        }
    }
}