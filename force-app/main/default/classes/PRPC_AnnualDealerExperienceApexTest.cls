@isTest(SeeAllData=false)
public class PRPC_AnnualDealerExperienceApexTest {
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
    }
    
    @isTest
    private static void findScoreTest(){
        Account acctTest = [SELECT Id FROM Account WHERE Location_Type__c = 'D' LIMIT 1];
        PRPC_AnnualDealerExperienceApex.findScore(2021, 1, acctTest.Id);
    }
    
    @isTest
    private static void saveRecordTest(){
        Account acctTest = [SELECT Id FROM Account WHERE Location_Type__c = 'D' LIMIT 1];
        Survey_Data__c surveyTest = new Survey_Data__c();
        surveyTest.Q1_Value__c = 75;
        surveyTest.Date_Taken__c = System.today();
        surveyTest.Survey_Type__c = 'Dealer';
        surveyTest.Customer_Dealer_Id__c = acctTest.Id;
        PRPC_AnnualDealerExperienceApex.saveRecord(surveyTest);
    }
}