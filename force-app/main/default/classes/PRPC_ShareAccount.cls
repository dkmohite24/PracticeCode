/* This class is used to share accounts(Distributore & branch) with associated users.*/

global class PRPC_ShareAccount implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Account> allAccount = [SELECT Id, Location_Type__c, SAP_Id__c, Sales_RegionA__c, ParentId FROM Account WHERE SAP_Id__c != null AND Sales_RegionA__c != null AND Type != null ];
        Map<String, Set<String>> acctDistributorMap = new Map<String, Set<String>>();
        Set<String> accountContactSet = new Set<String>();
        Set<String> contactSet = new Set<String>();
        Set<String> accountSet = new Set<String>();
        Map<String, String> contactUserMap = new Map<String, String>();
        Set<String> existingShareSet = new Set<String>();
        for(Account acct : allAccount) {
            accountSet.add(acct.Id);
            if(acct.ParentId == null && !acctDistributorMap.containsKey(acct.Id)) {
                acctDistributorMap.put(acct.Id, new Set<String>());
            }
            if(acct.ParentId != null) {
                if(!acctDistributorMap.containsKey(acct.ParentId)) {
                    acctDistributorMap.put(acct.ParentId, new Set<String>());
                }
                acctDistributorMap.get(acct.ParentId).add(acct.Id);
            }
        }
        
        
        for(AccountContactRelation con : [SELECT Id, contactId, AccountId FROM AccountContactRelation WHERE AccountId IN:acctDistributorMap.keyset() ]) {
            String key = con.AccountId +'-'+con.ContactId;
            accountContactSet.add(key);
            contactSet.add(con.Id);
        }
        
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN:acctDistributorMap.keyset() ]) {
            String key = con.AccountId +'-'+con.Id;
            accountContactSet.add(key);	
            contactSet.add(con.Id);
        }
        for(User usr : [SELECT Id, ContactId FROM USER WHERE ContactId IN :contactSet and isActive = true]) {
            contactUserMap.put(usr.ContactId, usr.Id);
        }
        
        for(AccountShare acctShare: [SELECT Id, userorgroupId, AccountAccessLevel, AccountId FROM AccountShare WHERE AccountId IN:accountSet]) {
            String key = acctShare.AccountId + '-' + acctShare.userorgroupId;
            existingShareSet.add(key);
        }
        List<AccountShare> acctShareList = new List<AccountShare>();
        for(String key : accountContactSet) {
            String acctId = key.split('-')[0];	
            String conId = key.split('-')[1];
            String userKey = acctId +'-'+contactUserMap.get(conId);
            if(!existingShareSet.contains(userKey) && contactUserMap.containsKey(conId)) {
                AccountShare acctShare = new AccountShare();
                acctShare.userorgroupId = contactUserMap.get(conId);
                acctShare.AccountAccessLevel = 'Read';
                acctShare.OpportunityAccessLevel  = 'None';
                acctShare.AccountId = acctId;
                acctShareList.add(acctShare);
            }
            for(String acct : acctDistributorMap.get(acctId)) {
                String newKey = acct +'-'+contactUserMap.get(conId);
                if(!existingShareSet.contains(newKey) && contactUserMap.containsKey(conId)) {
                    AccountShare acctShare1 = new AccountShare();
                    acctShare1.userorgroupId = contactUserMap.get(conId);
                    acctShare1.AccountAccessLevel = 'Read';
                    acctShare1.OpportunityAccessLevel  = 'None';
                    acctShare1.AccountId = acct;
                    acctShareList.add(acctShare1);
                }
            }
        }
        if(acctShareList.size() > 0) {
            INSERT acctShareList;
        }
        
        
    }
}