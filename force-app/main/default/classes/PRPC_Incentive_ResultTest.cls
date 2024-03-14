@isTest
public class PRPC_Incentive_ResultTest {
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
        List<String> distId = new List<String>();
        List<String> branchLst = new List<String>();//ess
        for(Account a : distributor){
            distId.add(a.Id);
        }
        Account branch = [SELECT ID, SAP_ID__c, Name FROM Account WHERE Type = 'Distributor Branch' LIMIT 1];
        List<String> branchList = new List<String>();
		branchList.add(branch.Id);
        List<Reporting_Type__c> reportType = new List<Reporting_Type__c>();
        reportType.add(PRPC_TestDataFactory.insertReport('Warranty Parts Consumed Data', 'TPS_Data__c', 
                                                         'Customer__r.Sales_RegionA__c,Customer__r.Name,Customer__r.SAP_ID__c,Year__c,Month_Name__c,Invoice_Amount__c',
                                                         ' ', ' '));
        
        reportType.add(PRPC_TestDataFactory.insertReport('Incentive Details', 'Incentive__c', 
                                                         'IncentiveAcc__r.Sales_RegionA__c,IncentiveAcc__r.Sold_To_Code__c,IncentiveAcc__r.Distributor__c,IncentiveAcc__r.SAP_ID__c,IncentiveAcc__r.ShippingCity,Month__c, Year__c,Incentive_Type__c,Sent_To_SAP_Date__c,Incentive_Amount__c',
                                                         ' ', ' '));
        reportType.add(PRPC_TestDataFactory.insertReport('Incentive Summary', 'Incentive__c', 
                                                         'Year__c,IncentiveAcc__r.Sales_RegionA__c,IncentiveAcc__r.Sold_To_Code__c,IncentiveAcc__r.Distributor__c,IncentiveAcc__r.SAP_ID__c,IncentiveAcc__r.City__c,VFC_Amount__c,TRPS_Amount__c,Total_Incentive__c',
                                                         ' ', ' '));
        PRPC_TestDataFactory.insertTPSdata(distributor[0].Id,branch.SAP_ID__c,'WPC', Date.today());
        PRPC_TestDataFactory.createIncentiveRec(branch.Id, 'Gold', 2500, 0);
        List<String> months = new List<String>();
        List<String> mon = new List<String>();
        months.add('October');
        months.add('November');
        List<String> years = new List<String>();
        years.add('2020');
        years.add('2021');
        List<String> region = new List<String>();
        region.add('North America');
        region.add('Latin America');
        region.add('Asia Pacific');
        region.add('EMEA');
        Test.startTest();
        system.runAs(u) {
            PRPC_Incentive_Result.profileCheck();
            PRPC_Incentive_Result.objectFields('Warranty Parts Consumed Data');
            PRPC_Incentive_Result.fetchDistributorsByPartner(region, 'Distributor');
            PRPC_Incentive_Result.FetchBranch(distId);
			
            PRPC_Incentive_Result.FetchRecordsforTable(distId, 'Distributor', branchList, region, 
                                                       'Customer__r.Sales_RegionA__c,Customer__r.Name,Customer__r.SAP_ID__c,Year__c,Month_Name__c,Invoice_Amount__c', 
                                                       'TPS_Data__c', 'Customer__r.', months, years,'PRP Partner', 'Warranty Parts Consumed Data');
            
            PRPC_Incentive_Result.FetchRecordsforTable(distId, 'Distributor', branchList, region, 
                                                       'IncentiveAcc__r.Sales_RegionA__c,IncentiveAcc__r.Sold_To_Code__c,IncentiveAcc__r.Distributor__c,IncentiveAcc__r.SAP_ID__c,IncentiveAcc__r.ShippingCity,Month__c, Year__c,Incentive_Type__c,Sent_To_SAP_Date__c,Incentive_Amount__c', 
                                                       'Incentive__c', 'IncentiveAcc__r.', months, years,'PRP Admin', 'Incentive Details');
            
            PRPC_Incentive_Result.FetchRecordsforTable(distId, 'Distributor', branchList, region, 
                                                       'Year__c,IncentiveAcc__r.Sales_RegionA__c,IncentiveAcc__r.Sold_To_Code__c,IncentiveAcc__r.Distributor__c,IncentiveAcc__r.SAP_ID__c,IncentiveAcc__r.City__c,VFC_Amount__c,TRPS_Amount__c,Total_Incentive__c', 
                                                       'Incentive__c', 'IncentiveAcc__r.', months, years,'PRP Admin','Incentive Summary');
            
            
            PRPC_Incentive_Result.FetchRecordsforTable(distId, 'Distributor', branchLst, region, 
                                                       'IncentiveAcc__r.Sales_RegionA__c,IncentiveAcc__r.Sold_To_Code__c,IncentiveAcc__r.Distributor__c,IncentiveAcc__r.SAP_ID__c,IncentiveAcc__r.ShippingCity,Month__c, Year__c,Incentive_Type__c,Sent_To_SAP_Date__c,Incentive_Amount__c', 
                                                       'Incentive__c', 'IncentiveAcc__r.', months, years,'PRP Admin', 'Incentive Details');
            
            
            PRPC_Incentive_Result.FetchRecordsforTable(distId, 'Distributor', branchList, region, 
                                                       'IncentiveAcc__r.Sales_RegionA__c,IncentiveAcc__r.Sold_To_Code__c,IncentiveAcc__r.Distributor__c,IncentiveAcc__r.SAP_ID__c,IncentiveAcc__r.ShippingCity,Month__c, Year__c,Incentive_Type__c,Sent_To_SAP_Date__c,Incentive_Amount__c', 
                                                       'Incentive__c', 'IncentiveAcc__r.', mon, years,'PRP Admin', 'Incentive Details');
            
        }
        Test.stopTest();
    }
}