@isTest(seeAllData = true)
public class PRPC_submitToSapClassTest {
    /*
    @testSetup static void testSetupMethod(){
        List<Account> distributor = new List<Account>();
        distributor = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
        List<Incentive__c> IncentiveList = new List<Incentive__c>();
        Incentive__c Inceinst = new Incentive__c();
        Inceinst.IncentiveAcc__c = distributor[0].Id;
        Inceinst.Incentive_Amount__c = 2500.00; 
        Inceinst.PerformanceLevel__c = 'Gold';
        Inceinst.Month__c = 'February';
        IncentiveList.add(Inceinst);
        insert IncentiveList;
    }*/
    @isTest static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new MockCalloutClass());
        test.startTest();
        PRPC_submitToSapClass.submitToSAPFile('2020','February');
        test.stopTest();
    }
}