@isTest
public class PRPC_HomeApexTest {
    static testMethod void homeApexTest() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        List<Account> distributor = new List<Account>();
        distributor = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
        List<Account> distributorONA = new List<Account>();
        distributorONA = PRPC_TestDataFactory.createAccount('D', 'EMEA', 1, true, true);
        User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                  LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  AND Contact.AccountId = :distributor[0].Id Limit 1];
        PRPC_TestDataFactory.insertKpiRec(distributor[0].Id, Double.valueof(distributor[0].SAP_ID__c), 'Gold', string.valueof(distributor[0].Sales_RegionA__C));
        KPI__c KPI = PRPC_TestDataFactory.insertKpiRec(distributorONA[0].Id, Double.valueof(distributorONA[0].SAP_ID__c), 'Gold', string.valueof(distributorONA[0].Sales_RegionA__C));
        KPI.Month__c = 2;
        update KPI;
        system.debug('check15: '+[select id,month__C from KPI__C]);
        //PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);
        Test.startTest();
        system.runAs(u) {
            PRPC_ProgramContacts.findProgramContacts();
            PRPC_PRP_Overall_Performance_Level.testMonth = 1;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 2;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 3;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 4;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 5;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 6;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 7;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 8;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 9;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 10;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 11;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 12;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('EMEA', 'Distributor');
            
            PRPC_PRP_Overall_Performance_Level.testMonth = 1;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('North America', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 2;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('North America', 'Direct Dealer');
            PRPC_PRP_Overall_Performance_Level.testMonth = 3;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('Asia Pacific', 'Distributor');
            PRPC_PRP_Overall_Performance_Level.testMonth = 5;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('Asia Pacific', 'Direct Dealer');
            PRPC_PRP_Overall_Performance_Level.testMonth = 4;
            PRPC_ParticipatingPartner.findAll();
        }
        
        Test.stopTest();
        
    }
    @isTest static void testMethod2() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        List<Account> distributor = new List<Account>();
        distributor = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
        PRPC_TestDataFactory.insertKpiRec(distributor[0].Id, Double.valueof(distributor[0].SAP_ID__c), 'Gold', string.valueof(distributor[0].Sales_RegionA__C));
        system.debug('check60: '+[select id,month__C from KPI__C]);
        Test.startTest();
        
        PRPC_PRP_Overall_Performance_Level.testMonth = 2;
            PRPC_PRP_Overall_Performance_Level.prpCalculation('Asia Pacific', 'Direct Dealer');
        PRPC_PRP_Overall_Performance_Level.prpCalculation('Asia Pacific', 'Distributor');
        Test.stopTest();
    }
}