@isTest
public class PRPC_AccountTriggerTest {
    static testMethod void accountTriggerTest() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        Test.startTest();
        	PRPC_TestDataFactory.createAccount('D', 'North America', 1, false, false);
        	List<Account> branch = [SELECT ID, Name FROM Account WHERE Type = 'Distributor Branch'];
        	for(Account acc : branch){
            	acc.Name = acc.Name + 'Test';
        	}
        	UPDATE branch; 
        	DELETE branch;
        Test.stopTest();
    }
}