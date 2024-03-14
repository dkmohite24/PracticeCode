@isTest
public class ATI_TAC_TestDataFactory_Test {
    
    @isTest static void testCreateDisableRules() {
        List<Disable_Rules__c> disableRules = ATI_TAC_TestDataFactory.createDisableRules();
        System.assertNotEquals(0, disableRules.size(), 'No Disable Rules created');
        
    }
    
   
    @isTest static void testCreateTestAccount() {
        insert new Disable_Rules__c(Name='PRPC_BranchCount', Disable__c=False);
        Account testAccount = ATI_TAC_TestDataFactory.createTestAccount();
        System.assertNotEquals(null, testAccount.Id, 'Test Account not created');
        
    }
    
    @isTest static void testCreateTestCase() {
		insert new Disable_Rules__c(Name='PRPC_BranchCount', Disable__c=False);
        Account testAccount = ATI_TAC_TestDataFactory.createTestAccount();
        Case testCase = ATI_TAC_TestDataFactory.createTestCase(testAccount);
        System.assertNotEquals(null, testCase.Id, 'Test Case not created');
        
    }
    
    @isTest static void testCreateVehicleInformation() {
        ATI_Vehicle_Information__c vehicleInfo = ATI_TAC_TestDataFactory.createVehicleInformation();
        System.assertNotEquals(null, vehicleInfo.Id, 'Vehicle Information not created');
        
    }
    
    @isTest static void testCreateErrorLogTestData() {
        Test.startTest();
        ATI_TAC_TestDataFactory.createErrorLogTestData();
        Test.stopTest();
        
        List<ATI_Error_Log__c> errorLogs = [SELECT Id FROM ATI_Error_Log__c];
        System.assertEquals(1, errorLogs.size(), 'Error Log not created');
    }
    
    @isTest static void testCreateTestContacts() {
        List<Contact> testContacts = ATI_TAC_TestDataFactory.createTestContacts();
        System.assertEquals(3, testContacts.size(), 'Incorrect number of contacts created');
    }
    
    @isTest static void testCreateTestAccounts() {
        List<Account> testAccounts = ATI_TAC_TestDataFactory.createTestAccounts();
        System.assertEquals(2, testAccounts.size(), 'Incorrect number of accounts created');
    }
    
    @isTest static void testCreateTestDistributorsWithBranches() {
        List<Account> distributorsWithBranches = ATI_TAC_TestDataFactory.createTestDistributorsWithBranches();
        
        System.assertEquals(3, distributorsWithBranches.size(), 'Incorrect number of distributors with branches created');
        // Verify distributor records
        Account distributor = distributorsWithBranches[0];
        System.assertEquals('Test Distributor', distributor.Name);
        System.assertEquals('Distributor', distributor.Type);
        System.assertEquals('North America', distributor.Sales_RegionA__c);
        // Verify distributor branch with parent
        Account distributorBranchWithParent = distributorsWithBranches[1];
        System.assertEquals('Test Distributor Branch with Parent', distributorBranchWithParent.Name);
        System.assertEquals('Distributor Branch', distributorBranchWithParent.Type);
        System.assertEquals('North America', distributorBranchWithParent.Sales_RegionA__c);
        System.assertEquals(distributor.Id, distributorBranchWithParent.ParentId);

        // Verify distributor branch without parent
        Account distributorBranchWithoutParent = distributorsWithBranches[2];
        System.assertEquals('Test Distributor Branch without Parent', distributorBranchWithoutParent.Name);
        System.assertEquals('Distributor Branch', distributorBranchWithoutParent.Type);
        System.assertEquals('North America', distributorBranchWithoutParent.Sales_RegionA__c);

    }
    
    @isTest static void testCreateTestDistributorsForUpdate() {
        List<Account> distributorsForUpdate = ATI_TAC_TestDataFactory.createTestDistributorsForUpdate();
        System.assertEquals(2, distributorsForUpdate.size(), 'Incorrect number of distributors for update created');
        // Add more assertions if needed
    }
    
    @isTest static void testCreateTestDistributorsForDelete() {
        List<Account> distributorsForDelete = ATI_TAC_TestDataFactory.createTestDistributorsForDelete();
        System.assertEquals(1, distributorsForDelete.size(), 'Incorrect number of distributors for delete created');
        
    }
    
    @isTest static void testCreateTestDistributorAccount() {
		insert new Disable_Rules__c(Name='PRPC_BranchCount', Disable__c=False);
        Account distributorAccount = ATI_TAC_TestDataFactory.createTestDistributorAccount();
        System.assertNotEquals(null, distributorAccount.Id, 'Distributor Account not created');
        
    }
    
    @isTest static void testCreateTestDistributorBranchAccount() {
		insert new Disable_Rules__c(Name='PRPC_BranchCount', Disable__c=False);
        Account distributorAccount = ATI_TAC_TestDataFactory.createTestDistributorAccount();
        Account distributorBranchAccount = ATI_TAC_TestDataFactory.createTestDistributorBranchAccount(distributorAccount.Id);
        System.assertNotEquals(null, distributorBranchAccount.Id, 'Distributor Branch Account not created');
        
    }
    
    
    
}