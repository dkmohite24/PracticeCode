@isTest
public class PRPC_transacErrorApexClassTest {
    static testMethod void testReport1() {
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
     	User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                         LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  		 AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT Id,SAP_ID__c FROM Account WHERE Parent.Id = :u.Contact.AccountId LIMIT 1];
        PRPC_TestDataFactory.insertTPSdata(branch.Id,branch.SAP_ID__c,'TPS',date.today());
        Reporting_Type__c reportType = new Reporting_Type__c();
        reportType = PRPC_TestDataFactory.insertReport('Total Parts Sold Data', 'TPS_Data__c', 
                                                           'Customer__r.Distributor__c,Customer__r.Name,Customer__r.SAP_ID__c,Customer__r.Sales_RegionA__c,Customer__r.Sold_To_Code__c,Year__c,Month_Name__c,Invoice_Amount__c','','');
        Reporting_Type__c reportType1 = new Reporting_Type__c();
        Reporting_Type__c reportType2 = new Reporting_Type__c();
        reportType1 = PRPC_TestDataFactory.insertReport('Training Data', 'Training_Data__c', 
                                                           'Customer__r.Sales_RegionA__c,Customer__r.Distributor__c,Customer__r.SAP_ID__c,Customer__r.Sold_To_Code__c,Customer__r.Name,Two_trained_tech__c,Tech_Complaint_Percent__c,Year__c,Month_Name__c','','');
		reportType1 = PRPC_TestDataFactory.insertReport('ETC Data', 'ETC_Data__c', 
                                                           'Distributor_Code__c,Name, Month__c,PO_Number__c,Retail_Amount_ETC__c,Date__c,Year__c','','');

        Test.startTest();
        system.runAs(u) {
        	PRPC_transacErrorApexClass.objectFields('Total Parts Sold Data');
            PRPC_transacErrorApexClass.profileCheck();
            List<PRPC_transacErrorApexClass.pickListWrapper> accounts = new List<PRPC_transacErrorApexClass.pickListWrapper>();
            List<String> region = new List<String>();
            region.add('North America');
        	region.add('Latin America');
        	region.add('Asia Pacific');
        	region.add('EMEA');
            List<String> dist = new List<String>();
            for(PRPC_transacErrorApexClass.pickListWrapper acc : accounts){
                dist.add(acc.Id);
            }
            List<String> branchList = new List<String>();
            branchList.add(branch.Id);
            List<String> months = new List<String>();
            months.add('October');
            months.add('November');
            List<String> years = new List<String>();
            years.add('2023');
            years.add('2024');
            list<Integer> yer = new List<Integer>();
            yer.add(2023);
            yer.add(2024);
            accounts = PRPC_transacErrorApexClass.fetchDistributorsByPartner(region, 'Distributor');
            PRPC_transacErrorApexClass.FetchBranchForTPS(dist, 'Total Parts Sold Data', region, 'Distributor');
            PRPC_transacErrorApexClass.fetchDistributors(region);
            PRPC_transacErrorApexClass.FetchRecordsforTable(branchList, dist, branchList, branchList, region,'Customer__r.Distributor__c,Customer__r.Name,Customer__r.SAP_ID__c,Customer__r.Sales_RegionA__c,Customer__r.Sold_To_Code__c,Year__c,Month_Name__c,Invoice_Amount__c' , 'TPS_Data__c', 'Customer__r.', months, years, 'Total Parts Sold Data', String.valueOf(Date.today()),  String.valueOf(Date.today()), 'Distributor');
            PRPC_transacErrorApexClass.regionList();
            PRPC_transacErrorApexClass.FetchBranchTraining(dist, 'Distributor Branch', region,'ETC Data');
            PRPC_transacErrorApexClass.FetchBranch(dist, 'Total Parts Sold Data');
            PRPC_transacErrorApexClass.FetchRecordsforTrainingTable('Training Data', dist, branchList, region, 'Two_trained_tech__c,Tech_Complaint_Percent__c,Tech_compliant__c', months, yer, 'Distributor');
            
        }
        Test.stopTest();
    }
    static testMethod void testReport() {
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
     	User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                         LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  		 AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT Id,SAP_ID__c FROM Account WHERE Parent.Id = :u.Contact.AccountId LIMIT 1];
        PRPC_TestDataFactory.insertTPSdata(branch.Id,branch.SAP_ID__c,'TPS',date.today());
        Reporting_Type__c reportType = new Reporting_Type__c();
        reportType = PRPC_TestDataFactory.insertReport('Total Parts Sold Data', 'TPS_Data__c', 
                                                           'Customer__r.Distributor__c,Customer__r.Name,Customer__r.SAP_ID__c,Customer__r.Sales_RegionA__c,Customer__r.Sold_To_Code__c,Year__c,Month_Name__c,Invoice_Amount__c','','');
        Test.startTest();
        system.runAs(u) {
        	PRPC_transacErrorApexClass.objectFields('Total Parts Sold Data');
            PRPC_transacErrorApexClass.profileCheck();
            List<PRPC_transacErrorApexClass.pickListWrapper> accounts = new List<PRPC_transacErrorApexClass.pickListWrapper>();
            List<String> region = new List<String>();
            region.add('North America');
        	region.add('Latin America');
        	region.add('Asia Pacific');
        	region.add('EMEA');
            List<String> dist = new List<String>();
            for(PRPC_transacErrorApexClass.pickListWrapper acc : accounts){
                dist.add(acc.Id);
            }
            List<String> branchList = new List<String>();
            branchList.add(branch.Id);
            List<String> months = new List<String>();
            months.add('October');
            months.add('November');
            List<String> years = new List<String>();
            years.add('2020');
            years.add('2021');
            accounts = PRPC_transacErrorApexClass.fetchDistributorsByPartner(region, 'Distributor');
           PRPC_transacErrorApexClass.FetchBranch(dist, 'Total Parts Sold Data');
        }
        Test.stopTest();
    }
}