@isTest(SeeAllData=false)
public class PRPC_DeleteStagingRecordPartnerTest {
	@testSetup 
    private static void setup() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
        PRPC_TestDataFactory.insertSurveySetup('CSI Parts', 'North America');
        List<Account> allNABranches = new List<Account>();
        allNABranches = [SELECT Id, SAP_ID__c FROM Account WHERE ParentId IN :allNADistributors];
        PRPC_TestDataFactory.insertSurveyData(allNABranches, 'Parts', 5);
    }
    
    @isTest
    private static void DeleteRecordTest(){
        Survey_Data__c record = [SELECT Id FROM Survey_Data__c LIMIT 1];
        Test.startTest();
        PRPC_DeleteStagingRecordPartner.DeleteRecord(record.Id);
        Test.stopTest();
    }

}