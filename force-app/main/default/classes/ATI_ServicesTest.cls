@isTest
public class ATI_ServicesTest {
    @TestSetup
    static void setupTestData() {
        List<Disable_Rules__c> disableRules = ATI_TAC_TestDataFactory.createDisableRules();
        // Create test accounts with different billing addresses in the USA
        List<Account> testAccounts = ATI_TAC_TestDataFactory.createTestAccounts();
        insert testAccounts;
    }
    
    @IsTest
    static void testAccountAddressValidate() {
        // Get the test accounts
        List<Account> testAccounts = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account];
        System.assertEquals(2, testAccounts.size(), 'Test accounts not created successfully.');
        
        // Create a map of old account records
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>();
        for (Account acc : testAccounts) {
            oldAccountsMap.put(acc.Id, new Account(
                Id = acc.Id,
                BillingStreet = acc.BillingStreet,
                BillingCity = acc.BillingCity,
                BillingState = acc.BillingState,
                BillingCountry = acc.BillingCountry,
                BillingPostalCode = acc.BillingPostalCode
            ));
        }
        
        // Change address for one account
        testAccounts[0].BillingStreet = '789 Elm Rd';
        testAccounts[0].BillingCity = 'Newtown';
        testAccounts[0].BillingState = 'CA';
        testAccounts[0].BillingCountry = 'USA';
        testAccounts[0].BillingPostalCode = '98765';
        
        // Invoke the method under test
        Test.startTest();
        ATI_Services.accountAddressValidate(testAccounts);
        ATI_Services.accountAddressValidate(testAccounts, oldAccountsMap);
        Test.stopTest();
        
        // Verify the expected behavior
        List<ATI_Error_Log__c> errorLogs = [SELECT Id FROM ATI_Error_Log__c];
        System.assertEquals(0, errorLogs.size(), 'Unexpected error logs created.');
    }
}