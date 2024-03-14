@isTest
private class ATI_TAC_API_DataServicesTest {
    @TestSetup
    static void setupTestData() {
        // Create test data using the test data factory
    List<Disable_Rules__c> disableRules = ATI_TAC_TestDataFactory.createDisableRules();
    Account acObj = ATI_TAC_TestDataFactory.createTestAccount();
    Case caseObj = ATI_TAC_TestDataFactory.createTestCase(acObj);
        
        Account additionalAccount = new Account();
        additionalAccount.Name = 'Test Account';
        additionalAccount.AccountNumber = '123456'; 
        insert additionalAccount;
    }

    @isTest
    static void testGetCaseListOnDealerCode() {
        Test.startTest();
        // Call the method that retrieves data from the table
        List<Case> retrievedData = ATI_TAC_API_DataServices.getCaseListOnDealerCode('987654');
        Test.stopTest();

        System.assertNotEquals(null, retrievedData, 'Expected case records found');
    }
    
    @IsTest
    public static void testConstructor() {
        ATI_TAC_API_DataServices service = new ATI_TAC_API_DataServices();
        System.assertNotEquals(null, service, 'Expected non-null instance of ATI_TAC_API_DataServices');
    }

    @isTest
    static void testInsertVehicleInformation() {
        // Create test data
        ATI_Vehicle_Information__c testData = new ATI_Vehicle_Information__c();
        testData.Name = 'Test Vehicle Object';
        testData.ATI_Engine_Make__c = 'Lexus';
        testData.ATI_Engine_Model__c = 'Lexus4567';
        testData.ATI_Engine_Year__c = '2023';
               

        Test.startTest();
        // Call the method that inserts data
        String insertedRecordId = ATI_TAC_API_DataServices.insertVehicleInformation(testData);
        Test.stopTest();
		
        // Retrieve the inserted record
        ATI_Vehicle_Information__c insertedRecord = [SELECT Id, Name, ATI_Engine_Make__c FROM ATI_Vehicle_Information__c WHERE Id = :insertedRecordId];
		
        // Perform assertions to validate the inserted data
        System.assertEquals('Test Vehicle Object', insertedRecord.Name);
        System.assertEquals('Lexus', insertedRecord.ATI_Engine_Make__c);
    }

     @isTest
    static void testupdateVehicleInformation(){
        // Create test data
        ATI_Vehicle_Information__c testDataSFDC = new ATI_Vehicle_Information__c();
        testDataSFDC.Name = 'Test Data SFDC';
        testDataSFDC.ATI_Engine_Make__c = 'Test1';
        testDataSFDC.ATI_Engine_Model__c = '';
        String insertRecordSFDC = ATI_TAC_API_DataServices.insertVehicleInformation(testDataSFDC);
            
        ATI_Vehicle_Information__c testDataNHTSA = new ATI_Vehicle_Information__c();
        testDataNHTSA.Name = 'Test Data SFDC';
        testDataNHTSA.ATI_Engine_Make__c = 'Test2';
        testDataNHTSA.ATI_Engine_Model__c = 'Lexus4567';
        testDataNHTSA.Id = insertRecordSFDC;
        //String insertRecordNHTSA = ATI_TAC_API_DataServices.insertVehicleInformation(testDataNHTSA);
        
        
        Test.startTest();
        // Call the method that inserts data
        ATI_TAC_API_DataServices.updateVehicleInformation(testDataNHTSA,testDataSFDC);
        Test.stopTest();
		
        // Retrieve the inserted record
        ATI_Vehicle_Information__c updatedRecord = [SELECT Id, Name, ATI_Engine_Make__c, ATI_Engine_Model__c FROM ATI_Vehicle_Information__c WHERE Id = :insertRecordSFDC];
		System.debug('Data after Update in ENgine make should be Test1'+updatedRecord.ATI_Engine_Make__c);
        System.debug('Data after Update in ENgine model should be Lexus4567'+updatedRecord.ATI_Engine_Model__c);
        
        // Perform assertions to validate the inserted data
        System.assertEquals('Test1', updatedRecord.ATI_Engine_Make__c);
        //System.assertEquals('Lexus', insertedRecord.ATI_Engine_Make__c);
      
    }
    
    
    @isTest
    static void testGetAcountNumber() {
        // Get the Account record created in the setup
        Account testAccount = [SELECT Id, AccountNumber FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
        // Call the method that retrieves data from the table
        String accountNumber = ATI_TAC_API_DataServices.getAcountNumber(testAccount.Id);
        Test.stopTest();

        System.assertEquals('123456', accountNumber, 'Expected Account Number');
    }
    
    @isTest
    static void testGetAcountNumberWithCaseRecord() {
        // Get the Case record created in the setup
        Case testCase = [SELECT Id, AccountId FROM Case LIMIT 1];

        Test.startTest();
        // Call the method that retrieves data from the table with the Case record Id
        String accountNumber = ATI_TAC_API_DataServices.getAcountNumber(testCase.Id);
        Test.stopTest();

        // Retrieve the related Account to the Case
        Account relatedAccount = [SELECT Id, AccountNumber FROM Account WHERE Id = :testCase.AccountId LIMIT 1];

        System.assertEquals(relatedAccount.AccountNumber, accountNumber, 'Expected Account Number');
    }
}