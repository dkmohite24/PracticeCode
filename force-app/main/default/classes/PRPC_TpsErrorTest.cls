@isTest
public class PRPC_TpsErrorTest {
	static testMethod void testReport() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount' || rule.Name=='EndCustTrigger' || rule.Name=='TatTurntTrigger') {
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
        List<String> branchId = new List<String>();
        branchId.add(branch.ID);
        PRPC_TestDataFactory.createTpsIntStage(branch.SAP_ID__c);
        PRPC_TestDataFactory.createTpsRetStage(branch.SAP_ID__c);
        PRPC_TestDataFactory.createTpsStage(branch.SAP_ID__c);
        List<Reporting_Type__c> reportType = new List<Reporting_Type__c>();
        reportType.add(PRPC_TestDataFactory.insertReport('TPS Error', 'TPS_International_staging__c', 
                                                           'Month__c,Year__c,Distributor_Ship_To__c,Invoice_Amount__c,Error_Log__c',
                                                         ' ', ' '));
        reportType.add(PRPC_TestDataFactory.insertReport('TPS Error', 'TPS_Staging_Data__c', 
                                                           'Month__c,Year__c,Distributor_Ship_To__c,Invoice_Amount__c,Error_Log__c',
                                                           ' ', ' '));
        reportType.add(PRPC_TestDataFactory.insertReport('TPS Error', 'TPS_Retran_staging__c', 
                                                           'Month__c,Year__c,Distributor_Ship_To__c,Invoice_Amount__c,Error_Log__c',
                                                           ' ', ' '));
		List<String> objectName = new List<String>();
        objectName.add('TPS_International_staging__c');
        objectName.add('TPS_Staging_Data__c');
        objectName.add('TPS_Retran_staging__c');
        
        List<String> months = new List<String>();
            months.add('October');
            months.add('November');
            List<String> years = new List<String>();
            years.add('2020');
            years.add('2021');
		        
        Test.startTest();
        PRPC_TPSError_Report.objectFields('TPS Error');
        List<PRPC_TPSError_Report.pickListWrapper> accounts = new List<PRPC_TPSError_Report.pickListWrapper>();
        List<String> region = new List<String>();
       	region.add('North America');
       	region.add('Latin America');
        region.add('Asia Pacific');
        region.add('EMEA');
        PRPC_TPSError_Report.fetchDistributorsByPartner(region, 'Distributor');
        PRPC_TPSError_Report.FetchBranch(distId);
        PRPC_TPSError_Report.FetchRecordsforTable(distId, 'Distributor', branchId, region,
                                                               'Month__c,Year__c,Distributor_Ship_To__c,Invoice_Amount__c,Error_Log__c',
                                                               objectName, months, years);
        Test.stopTest();
    }
}