@isTest
public class PRPC_PRPSetupTest {
    @testSetup 
    private static void setup() {
        PRPC_TestDataFactory.insertPRPSetup('North America', '2020', 'Distributor','January');

    }
    
    static testMethod void allRangesTest() {
		
        List<PRP_Range_Settings__c> PRPRangeList = new List<PRP_Range_Settings__c>();
      
        PRPRangeList = [SELECT Id,Name,High_Range__c,Low_Range__c,Level_Discount__c,Functional_Comp_Range__c from PRP_Range_Settings__c];
       
        Test.startTest();
       
        PRPC_PRPSetup.searchAllFields('North America','2020','Distributor','January');
        PRPC_PRPSetup.allRanges(JSON.serialize(PRPRangeList));
        
        Test.stopTest();
    }
}