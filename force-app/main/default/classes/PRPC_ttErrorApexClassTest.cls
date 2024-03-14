@isTest
public class PRPC_ttErrorApexClassTest {
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
        PRPC_TestDataFactory.createTat(branch.Id);
        Reporting_Type__c reportType = new Reporting_Type__c();
        Reporting_Type__c reportType1 = new Reporting_Type__c();
        reportType = PRPC_TestDataFactory.insertReport('Survey Data', 'Survey_Data__c', 
                                                           'Customer_Dealer_Id__r.Sales_RegionA__c,Customer_Dealer_Id__r.Distributor__c,Customer_Dealer_Id__r.SAP_ID__c,Survey_Type__c,Customer_Dealer_Id__r.Sold_To_Code__c,Year__c,Month_Name__c,Q1_Value__c,Q2_Value__c,Q3_Value__c,Q4_Value__c,CSI_Score__c','','');
        reportType1 = PRPC_TestDataFactory.insertReport('Service Compliance Turn Time Data', 'TAT_Data__c', 
                                                           'Dealer_Id__r.Sales_RegionA__c,Dealer_Id__r.Name,Dealer_Id__r.Distributor__c,Dealer_Id__r.SAP_ID__c,Dealer_Id__r.Sold_To_Code__c,Date_First_Part_Ordered__c,Claim_Number__c,date_vehicle_first_arrived__c,Repair_Type__c,Year__c,Month_Name__c','','');

        Test.startTest();
        system.runAs(u) {
        	PRPC_ttErrorApexClass.objectFields('Survey Data');
            PRPC_ttErrorApexClass.profileCheck();
            List<PRPC_ttErrorApexClass.pickListWrapper> accounts = new List<PRPC_ttErrorApexClass.pickListWrapper>();
            List<String> region = new List<String>();
            region.add('North America');
        	region.add('Latin America');
        	region.add('Asia Pacific');
        	region.add('EMEA');
            List<String> dist = new List<String>();
            for(PRPC_ttErrorApexClass.pickListWrapper acc : accounts){
                dist.add(acc.Id);
            }
            List<String> sourceList = new List<String>();
            sourceList.add('AWARE');
            sourceList.add('Distributor');
            List<String> branchList = new List<String>();
            branchList.add(branch.Id);
            List<String> months = new List<String>();
            months.add('October');
            months.add('November');
            List<String> years = new List<String>();
            years.add('2020');
            years.add('2021');
            accounts = PRPC_ttErrorApexClass.fetchDistributorsByPartner(region, 'Distributor','Service Compliance Turn Time Data');
            PRPC_ttErrorApexClass.fetchDistributors(region);
            PRPC_ttErrorApexClass.FetchBranchForTPS(dist, 'Survey Data', region, 'Distributor');
            PRPC_ttErrorApexClass.FetchRecordsforTable(sourceList, dist, branchList, region,'Customer_Dealer_Id__r.Sales_RegionA__c,Customer_Dealer_Id__r.Distributor__c,Customer_Dealer_Id__r.SAP_ID__c,Survey_Type__c,Customer_Dealer_Id__r.Sold_To_Code__c,Year__c,Month_Name__c,Q1_Value__c,Q2_Value__c,Q3_Value__c,Q4_Value__c,CSI_Score__c' , 'Survey_Data__c', 'Customer_Dealer_Id__r.', months, years, 'Survey Data', 'Distributor');
            PRPC_ttErrorApexClass.regionList();
            PRPC_ttErrorApexClass.FetchBranch(dist);
            PRPC_ttErrorApexClass.regionList();
        }
        Test.stopTest();
    }
    static testMethod void testReport2() {
    PRPC_ttErrorApexClass.fakeMethod();
    }
}