@isTest
public class PRPC_Performance_OverviewTest {
	static testMethod void testDashboard() {
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
        List<Account> distributor2 = new List<Account>();
        distributor2 = PRPC_TestDataFactory.createAccount('D', 'Latin America', 1, false, false);
     	User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                         LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  		 AND Contact.AccountId = :distributor[0].Id and isActive = true Limit 1 ];
        User u1 = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                         LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Admin' and isActive = true
                  		  Limit 1];
        Account branch = [SELECT ID, Name, SAP_ID__c,Type FROM Account where ParentId = :distributor[0].Id LIMIT 1];
        System.debug('branch'+branch);
        Account dist = [SELECT ID, Name, SAP_ID__c FROM Account where Id = :distributor2[0].Id LIMIT 1];
        PRPC_TestDataFactory.insertKpiRec(branch.Id, Integer.valueOf(branch.SAP_ID__c), 'Gold', 'North America');
        KPI__c kpiRecord = PRPC_TestDataFactory.insertKpiRec(branch.Id, Integer.valueOf(branch.SAP_ID__c), 'Gold', 'EMEA');
        kpiRecord.isPartOfPRP__c = false;
        update kpiRecord;
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        PRPC_TestDataFactory.insertPRPSetup('North America', '2020', 'Distributor', 'August');
        PRPC_TestDataFactory.insertPRPSetup('Latin America', '2020', 'Distributor', 'August');
        PRPC_TestDataFactory.insertKpiRec(branch.Id, Double.valueOf(branch.SAP_ID__c), 'Gold', 'North America');
        PRPC_TestDataFactory.insertKpiRec(dist.Id, Double.valueOf(dist.SAP_ID__c), 'Gold', 'Latin America');
        List<KPI__c>kpirec = new LIST<KPI__C>([select id,Period__C,MonthName__c from KPI__C where Customer_SAP_Id__c=:Double.valueOf(dist.SAP_ID__c)]);
        for(KPI__c rec:kpirec){
            rec.Period__C='YTD';
            rec.Month__c=8;
            update rec;
        }
        Test.startTest();
        system.runAs(u) {
            List<String> region = new List<String>();
            region.add('North America');
        	region.add('Latin America');
        	region.add('Asia Pacific');
        	region.add('EMEA');
            PRPC_Performance_Overview.findRegions();
            PRPC_Performance_Overview.getDistributors(region,'Distributor');
            PRPC_Performance_Overview.getBranch(distributor[0].Id);
            PRPC_Performance_Overview.returnDashboardDetails(2020, String.valueof(branch.Id), 'August',distributor2[0].Id,region,'Distributor');
            PRPC_Performance_Overview.profileCheck();
        }
        system.runAs(u1) {
            List<String> region = new List<String>();
            region.add('North America');
        	region.add('Latin America');
        	region.add('Asia Pacific');
        	region.add('EMEA');
            PRPC_Performance_Overview.findRegions();
            PRPC_Performance_Overview.getDistributors(region,'Direct Dealer');
            PRPC_Performance_Overview.getBranch(distributor[0].Id);
            PRPC_Performance_Overview.returnDashboardDetails(2020, String.valueof(branch.Id), 'August',distributor2[0].Id,region,'Direct Dealer');
            PRPC_Performance_Overview.profileCheck();
        }
        Test.stopTest();
    }
}