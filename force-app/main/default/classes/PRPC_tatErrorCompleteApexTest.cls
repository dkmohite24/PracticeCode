@isTest
public class PRPC_tatErrorCompleteApexTest {
	static testMethod void testReport1() {
       List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
         
        List<Disable_Rules__c> disableRules2 = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules2) {
            if(rule.Name== 'TatTurntTrigger') {
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
        PRPC_TestDataFactory.insertTATturnt(branch.SAP_ID__c);
        Reporting_Type__c reportType = new Reporting_Type__c();
        reportType = PRPC_TestDataFactory.insertReport('TT Error Data - AWAARE', 'TAT_Staging_Data__c', 
                                                           'all_labor_ops__c,customer_notified__c,date_cust_request_service__c,date_vehicle_first_arrived__c,Partner_Code__c,repair_order_number__c,Technician_Name__c,vin__c,Error_Log__c,Reject_Reason__c,Year__c,Month__c','','');
        Reporting_Type__c reportType1 = new Reporting_Type__c();
        reportType1 = PRPC_TestDataFactory.insertReport('TT Error Data - Distributor', 'TAT_Turnt_staging__c', 
                                                           'all_labor_ops__c,customer_notified__c,date_cust_request_service__c,date_vehicle_first_arrived__c,Partner_Code__c,repair_order_number__c,Technician_Name__c,vin__c,Error_Log__c,Reject_Reason__c,Year__c,Month__c','','');

        Test.startTest();
        system.runAs(u) {
        	PRPC_tatErrorCompleteApex.objectFields('TT Error Data - AWAARE');
            PRPC_tatErrorCompleteApex.profileCheck();
            List<PRPC_tatErrorCompleteApex.pickListWrapper> accounts = new List<PRPC_tatErrorCompleteApex.pickListWrapper>();
            List<String> region = new List<String>();
            region.add('North America');
        	region.add('Latin America');
        	region.add('Asia Pacific');
        	region.add('EMEA');
            List<String> dist = new List<String>();
            for(PRPC_tatErrorCompleteApex.pickListWrapper acc : accounts){
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
            accounts = PRPC_tatErrorCompleteApex.fetchDistributorsByPartner(region, 'Distributor');
            PRPC_tatErrorCompleteApex.FetchBranchForTPS(dist, 'TT Error Data - AWAARE', region, 'Distributor');
            PRPC_tatErrorCompleteApex.FetchRecordsforTable(dist, branchList, region,'all_labor_ops__c,customer_notified__c,date_cust_request_service__c,date_vehicle_first_arrived__c,Partner_Code__c,repair_order_number__c,Technician_Name__c,vin__c,Error_Log__c,Reject_Reason__c,Year__c,Month__c' , 'TAT_Staging_Data__c', months, years, 'TT Error Data - AWAARE', 'Distributor');
            PRPC_tatErrorCompleteApex.regionList();
            PRPC_tatErrorCompleteApex.FetchBranch(dist);
            
        }
        Test.stopTest();
    }
   
}