/**
 * @description       : 
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : Abhishek Mohapatra
**/
public class ATI_TAC_TestDataFactory {
  public static List<Disable_Rules__c> createDisableRules() {
    // Create and return a list of Disable_Rules__c records
    List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
    List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
    for (Disable_Rules__c rule : disableRules) {
      if (rule.Name == 'PRPC_BranchCount') {
        rule.Disable__c = false;
        insertDisableRules.add(rule);
      }
    }
    insert insertDisableRules;

    return insertDisableRules;
  }

  public static Account createTestAccount() {
    // Create and return a test Account record
    Account testAccount = new Account(
      Name = 'Test Account',
      ATI_Sales_External_Id__c = '12345',
      Type = 'Distributor',
      SAP_Id__c = '12345',
      AccountNumber = '123456',
      Sales_RegionA__c = 'North America'
    );
    insert testAccount;

    return testAccount;
  }

  public static Case createTestCase(Account account) {
    // Create and return a test Case record
    Case testCase = new Case(
      ATI_TAC_Serial_Number__c = 'test',
      Status = 'Active',
      ATI_TAC_Additional_Contact_Email__c = 'test@test.com',
      ATI_TAC_Sub_Status__c = 'Waiting for Response',
      CreatedDate = Date.today(),
      ATI_TAC_Resolution_Description__c = 'Resolution description',
      ATI_TAC_Latest_Group_Owner_Name__c = 'Test Owner',
      Description = 'Test description',
      AccountId = account.Id
    );
    insert testCase;

    return testCase;
  }

  public static ATI_Vehicle_Information__c createVehicleInformation() {
    // Create and return a test ATI_Vehicle_Information__c record
    ATI_Vehicle_Information__c vehicleInfo = new ATI_Vehicle_Information__c(
      Name = '1234567890',
      ATI_Engine_Make__c = 'Radial',
      ATI_Engine_Model__c = 'Radial4567',
      ATI_Engine_Year__c = '2023'
    );
    insert vehicleInfo;

    return vehicleInfo;
  }

  public static void createErrorLogTestData() {
    // Create and insert one error log record
    ATI_Error_Log__c errorLog = new ATI_Error_Log__c(
      ATI_Class_Name__c = 'Test Class',
      ATI_Error_Message__c = 'Test Error Message',
      ATI_Input__c = 'Test Input Data',
      ATI_Output__c = 'Test Output Data'
    );
    insert errorLog;
  }

  public static List<Contact> createTestContacts() {
    // Create and return a list of test Contact records
    List<Contact> contacts = new List<Contact>();

    contacts.add(
      new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        MailingStreet = '123 Main St',
        MailingCity = 'Anytown',
        MailingState = 'NY',
        MailingCountry = 'USA',
        MailingPostalCode = '12345'
      )
    );

    contacts.add(
      new Contact(
        FirstName = 'Jane',
        LastName = 'Smith',
        MailingStreet = '456 Oak Ave',
        MailingCity = 'Othertown',
        MailingState = 'CA',
        MailingCountry = 'USA',
        MailingPostalCode = '54321'
      )
    );

    contacts.add(
      new Contact(
        FirstName = 'Test',
        LastName = 'User',
        MailingStreet = '789 Elm Rd',
        MailingCity = 'Newtown',
        MailingState = 'CA',
        MailingCountry = 'USA',
        MailingPostalCode = '98765'
      )
    );

    return contacts;
  }

  public static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();

    // Create test accounts with different billing addresses in the USA
    accounts.add(
      new Account(
        Name = 'Test Account 1',
        ATI_Sales_External_Id__c = '12345',
        Type = 'Distributor',
        SAP_Id__c = '12345',
        AccountNumber = '123456',
        Sales_RegionA__c = 'North America',
        BillingStreet = '123 Main St',
        BillingCity = 'Anytown',
        BillingState = 'NY',
        BillingCountry = 'USA',
        BillingPostalCode = '12345'
      )
    );

    accounts.add(
      new Account(
        Name = 'Test Account 2',
        ATI_Sales_External_Id__c = '67890',
        Type = 'Distributor',
        SAP_Id__c = '67890',
        AccountNumber = '678901',
        Sales_RegionA__c = 'North America',
        BillingStreet = '456 Oak Ave',
        BillingCity = 'Othertown',
        BillingState = 'CA',
        BillingCountry = 'USA',
        BillingPostalCode = '54321'
      )
    );

    // Add more test accounts as needed

    return accounts;
  }

  public static List<Account> createTestDistributorsWithBranches() {
    List<Account> distributorsWithBranches = new List<Account>();

    // Create test data for the distributor

    Account distributor = new Account(
      Name = 'Test Distributor',
      Type = 'Distributor',
      Sales_RegionA__c = 'North America',
      SAP_Id__c = '123456',
      ATI_Sales_External_Id__c = '12345',
      AccountNumber = 'DistributorAccountNumber1'
    );

    distributorsWithBranches.add(distributor);

    // Create test data for the distributor branch with parent

    Account distributorBranchWithParent = new Account(
      Name = 'Test Distributor Branch with Parent',
      Type = 'Distributor Branch',
      Sales_RegionA__c = 'North America',
      SAP_Id__c = '23456',
      ATI_Sales_External_Id__c = '23456',
      AccountNumber = 'BranchAccountNumber1',
      ParentId = distributor.Id
    );

    distributorsWithBranches.add(distributorBranchWithParent);

    // Create test data for the distributor branch without parent

    Account distributorBranchWithoutParent = new Account(
      Name = 'Test Distributor Branch without Parent',
      Type = 'Distributor Branch',
      Sales_RegionA__c = 'North America',
      SAP_Id__c = '34567',
      ATI_Sales_External_Id__c = '34567',
      AccountNumber = 'BranchAccountNumber2'
    );

    distributorsWithBranches.add(distributorBranchWithoutParent);

    return distributorsWithBranches;
  }

  public static List<Account> createTestDistributorsForUpdate() {
    List<Account> distributorsForUpdate = new List<Account>();

    // Create test data for the distributor for update

    Account existingDistributor = new Account(
      Name = 'Existing Distributor',
      Type = 'Distributor',
      Sales_RegionA__c = 'North America',
      SAP_Id__c = '45678',
      ATI_Sales_External_Id__c = '45678',
      AccountNumber = 'ExistingDistributorAccountNumber',
      Number_Of_Active_Branches__c = 0
    );

    distributorsForUpdate.add(existingDistributor);

    // Create test data for the distributor branch with parent for update

    Account existingDistributorBranchWithParent = new Account(
      Name = 'Existing Distributor Branch with Parent',
      Type = 'Distributor Branch',
      Sales_RegionA__c = 'North America',
      SAP_Id__c = '56789',
      ATI_Sales_External_Id__c = '56789',
      AccountNumber = 'ExistingBranchAccountNumber',
      ParentId = existingDistributor.Id
    );

    distributorsForUpdate.add(existingDistributorBranchWithParent);

    return distributorsForUpdate;
  }

  public static List<Account> createTestDistributorsForDelete() {
    List<Account> distributorsForDelete = new List<Account>();

    // Create test data for the distributor branch to delete

    Account existingDistributorBranchToDelete = new Account(
      Name = 'Existing Distributor Branch to Delete',
      Type = 'Distributor Branch',
      Sales_RegionA__c = 'North America',
      SAP_Id__c = '67890',
      ATI_Sales_External_Id__c = '67890',
      AccountNumber = 'BranchToDeleteAccountNumber'
    );

    distributorsForDelete.add(existingDistributorBranchToDelete);

    return distributorsForDelete;
  }

  public static Account createTestDistributorAccount() {
    Account accountRec = new Account(
      Name = 'Test ',
      Type = 'Distributor',
      Location_Type__c = 'D',
      Sales_RegionA__c = 'North America',
      ShippingCity = 'City',
      SAP_ID__c = '0105',
      ShippingCountry = 'Country',
      ShippingState = 'State',
      ShippingPostalCode = '765432',
      ShippingStreet = 'Street',
      PRP_Participation__c = true,
      Number_Of_Active_Branches__c = 5
    );

    insert accountRec;

    return accountRec;
  }

  public static Account createTestDistributorBranchAccount(Id parentAccountId) {
    Account accountRecDis = new Account(
      Name = 'Test Branch ',
      Type = 'Distributor Branch',
      Location_Type__c = 'DB',
      SAP_ID__c = '0105000002',
      Sales_RegionA__c = 'North America',
      ShippingCity = 'City',
      ShippingCountry = 'Country',
      ShippingState = 'State',
      ShippingPostalCode = '765432',
      ShippingStreet = 'Street',
      PRP_Participation__c = true,
      Number_Of_Active_Branches__c = 1,
      ParentId = parentAccountId
    );

    insert accountRecDis;

    return accountRecDis;
  }
}