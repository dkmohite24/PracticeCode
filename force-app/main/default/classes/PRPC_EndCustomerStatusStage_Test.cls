@isTest
public class PRPC_EndCustomerStatusStage_Test {
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
        List<End_Customer__c> endList = new List<End_Customer__c>();
        endList = PRPC_TestDataFactory.createEndCust(u.Contact.AccountId);
        Reporting_Type__c reportType = new Reporting_Type__c();
        reportType = PRPC_TestDataFactory.insertReport('Turn Time Submission Status', 'Account', 
                                                           'Month__c,Year__c,Sub_Region__c,Sold_To_Code__c,Distributor__c,SAP_ID__c,ShippingCity',
                                                           ' ', ' ');
        Test.startTest();
        system.runAs(u) {
            PRPC_EndCustomerStatusStage.objectFields('Turn Time Submission Status');
            PRPC_EndCustomerStatusStage.profileCheck();
            List<PRPC_EndCustomerStatusStage.pickListWrapper> accounts = new List<PRPC_EndCustomerStatusStage.pickListWrapper>();
            List<String> region = new List<String>();
            region.add('North America');
            region.add('Latin America');
            region.add('Asia Pacific');
            region.add('EMEA');
            accounts = PRPC_EndCustomerStatusStage.fetchDistributorsByPartner(region, 'Distributor');
            List<String> dist = new List<String>();
            for(PRPC_EndCustomerStatusStage.pickListWrapper acc : accounts){
                dist.add(acc.Id);
            }
            List<String> selectedObject = new List<String>();
            selectedObject.add('Account');
            List<String> months = new List<String>();
            months.add('October');
            months.add('November');
            List<String> years = new List<String>();
            years.add('2020');
            years.add('2021');
            PRPC_EndCustomerStatusStage.FetchRecordsforTable(dist, region, 'Distributor', 
                                                               'Month__c,Year__c,Sub_Region__c,Sold_To_Code__c,Distributor__c,SAP_ID__c,ShippingCity',
                                                               selectedObject, months, years, 'Turn Time Submission Status');
        }
        Test.stopTest();
    }
}