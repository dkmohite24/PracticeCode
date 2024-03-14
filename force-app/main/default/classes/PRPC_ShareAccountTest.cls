@isTest
public class PRPC_ShareAccountTest {
	@testSetup 
    private static void setup() {
         List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
        List<Account> allNABranches = new List<Account>();
        allNABranches = [SELECT Id, SAP_ID__c FROM Account WHERE ParentId IN :allNADistributors];        
    }
    
    @isTest
    private static void shareAccountTest(){
        PRPC_ShareAccount sh1 = new PRPC_ShareAccount();
        String sch = '0 0 * * * ? *';
        Test.startTest();
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
}