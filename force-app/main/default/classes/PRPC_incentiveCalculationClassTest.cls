@isTest
public class PRPC_incentiveCalculationClassTest {
    @testSetup static void createData(){
         List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
       	Account distrubutorAccount = PRPC_TestDataFactory.createAccount('D', 'North America', 1, false, false).get(0);
        System.debug('Distributor : '+distrubutorAccount);
        List<Account> branchAccounts = new List<Account>();
        branchAccounts.add([Select name,id from Account where parentId=:distrubutorAccount.id limit 1]);
        for(Integer i =1; i<4 ; i++){
            branchAccounts.add(PRPC_TestDataFactory.createBranch(distrubutorAccount, true, i+1));
        }
        for(Integer i=5;i<=8;i++){
            PRPC_TestDataFactory.createServiceDealer(distrubutorAccount,true,i+1);
        }
       	System.debug(branchAccounts.size());
        PRPC_TestDataFactory.addFuncCompToDistributor(distrubutorAccount,2,2020);
        PRPC_TestDataFactory.addKPIsToBranch(branchAccounts, 12, 2019);
        PRPC_TestDataFactory.addKPIsToBranch(branchAccounts, 1, 2020);
        List<Account> allAccounts = [Select id from Account];
        PRPC_TestDataFactory.createTPSDataForAccounts(allAccounts,2020);
        List<PRP_Setup__c> prps = PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2019', 'Distributor', 'December');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2020', 'Distributor', 'January');
        PRPC_TestDataFactory.insertTPSdata(distrubutorAccount.id,'0105','TPS',Date.parse('02/02/2021'));
        System.debug('Size : '+[SELECT Name,Low_Range__c,High_Range__c,Level_Discount__c,PRP_Setup__r.Region__c,PRP_Setup__r.Year__c,PRP_Setup__r.Month__c,Functional_Comp_Range__c FROM PRP_Range_Settings__c].size());
        System.debug('PRP : '+prps);
    }
    testMethod static void testIncentiveClass(){
        list<TPS_Data__C> tpsList = [select id,Parts_Sold_Type__c from TPS_Data__c];
        for(Functional_Comp_Data__c acc : [select id,Invoice_amount__c,Year__c,Month__c from Functional_Comp_Data__c]){
            System.debug(acc);
        }
        Test.startTest();
        PRPC_incentiveCalculationClass inc = new PRPC_incentiveCalculationClass();
        inc.setYear(2020);
        inc.setMonth(1);
        Database.executeBatch(inc);
        PRPC_incentiveCalculationClass inc1 = new PRPC_incentiveCalculationClass();
        inc1.setYear(2020);
        inc1.setMonth(2);
        PRPC_incentiveCalculationClass inc2 = new PRPC_incentiveCalculationClass();
        inc2.setYear(2020);
        inc2.setMonth(3);
        Database.executeBatch(inc2);
        PRPC_incentiveCalculationClass.fakeMethod();
        Test.stopTest();
        
    }
}