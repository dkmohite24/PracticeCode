@isTest
public class PRPC_PRPParticipationTest {
    static testMethod void prpParticipationTest() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> distributor = new List<Account>();
        distributor = PRPC_TestDataFactory.createAccount('D', 'North America', 1, false, false);
        List<String> distId = new List<String>();
        for(Account a : distributor){
            distId.add(a.Id);
        }
        Account branch = [SELECT ID, SAP_ID__c, Name FROM Account WHERE Type = 'Distributor Branch' LIMIT 1];
        List<Account> branchList = new List<Account>();
		branchList.add(branch);
        List<String> branchId = new List<String>();
		branchId.add(branch.Id);
        Test.startTest();
        PRPC_PRPParticipation.Recorddatafetch(distributor[0].Id);
        PRPC_PRPParticipation.updateAccRecord(branchList);
        PRPC_PRPParticipation.RecorddatafetchforDistributer(distributor[0].Id);
        PRPC_PRPParticipation.updateDistributer(distributor[0].Id, true, branchId);
        Test.stopTest();
    }
}