/**
 * @description       : 
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : Abhishek Mohapatra
**/
@IsTest
public class ATI_TAC_API_ServicesTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data using the test data factory
        List<Disable_Rules__c> disableRules = ATI_TAC_TestDataFactory.createDisableRules();
        Account acObj = ATI_TAC_TestDataFactory.createTestAccount();
        Case caseObj = ATI_TAC_TestDataFactory.createTestCase(acObj);
        ATI_Vehicle_Information__c vehicleInfo = new ATI_Vehicle_Information__c();
        
        insert vehicleInfo;
    }
    
    
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Token": "MockToken","Expires": "MockExpires","DurationSeconds": "MockDurationSeconds","URL": "MockURL"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    public static void testGetElearntoekn() {
        // Create a test Account with an Account Number
        Account testAccount = new Account(Name = 'Test Account', AccountNumber = '123456');
        insert testAccount;
        
        // Create a test Case related to the Account
        Case testCase = new Case(AccountId = testAccount.Id, Subject = 'Test Case', ATI_TAC_Additional_Contact_Email__c = 'test@test.com');
        insert testCase;
        
        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method within Test.startTest() and Test.stopTest()
        Test.startTest();
        String elearnToken = ATI_TAC_API_Services.getElearntoekn(testCase.Id);
        Test.stopTest();
        
        // Assert the results
        System.assertNotEquals(null, elearnToken, 'Expected a non-null elearn token');
    }
    
    
    
    
    @IsTest
    public static void testConstructor() {
        ATI_TAC_API_Services service = new ATI_TAC_API_Services();
        System.assertNotEquals(null, service, 'Expected non-null instance of ATI_TAC_API_Services');
    }
    
    @IsTest
    public static void testValidGetDealerCasesAPIHandler() {
        // Create test account for the dealer code
        Account testAccount = new Account(
            Name = 'Test Account',
            AccountNumber = '123456' 
        );
        insert testAccount;
        
        // Create a test Case record associated with the test account
        Case testCase = new Case(
            AccountId = testAccount.Id,
            ATI_TAC_Serial_Number__c = 'number',
            ATI_TAC_Resolution_Description__c = 'Test Description',
            ATI_TAC_Additional_Contact_Email__c = 'test@test.com',
            Status = 'Active'
        );
        insert testCase;
        
        // Set the test context with valid JSON request body
        ATI_TAC_API_Services.CaseRequestClass validRequest = new ATI_TAC_API_Services.CaseRequestClass();
        validRequest.dealerCode = '123456';
        validRequest.caseNum = testCase.CaseNumber;
        String validRequestBodyJSON = JSON.serialize(validRequest);
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(validRequestBodyJSON);
        RestContext.response = new RestResponse();
        
        // Call the method to test the valid JSON
        Test.startTest();
        ATI_TAC_API_Services.getDealerCasesAPIHandler('getdealercases', validRequestBodyJSON);
        Test.stopTest();
        
        // Assert the results for the valid request
        RestResponse resValid = RestContext.response;
        System.assertEquals(200, resValid.statusCode, 'Expected status code 200 for valid JSON');
        
    }
    
    
    @IsTest
    public static void testInvalidGetDealerCasesAPIHandler() {
        // Set the test context with invalid JSON request body (missing closing bracket '}')
        String invalidRequestBodyJSON = '{"caseNum":"123456","dealerCode":"7890123"';
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(invalidRequestBodyJSON);
        RestContext.response = new RestResponse();
        
        // Call the method to test the invalid JSON
        Test.startTest();
        ATI_TAC_API_Services.getDealerCasesAPIHandler('getdealercases', invalidRequestBodyJSON);
        Test.stopTest();
        
        // Assert the results for the invalid request
        RestResponse resInvalid = RestContext.response;
        System.assertEquals(500, resInvalid.statusCode, 'Expected status code 500 for invalid JSON format');
        
    }
    
    @IsTest
    public static void testNewCaseDetailsProperties() {
        ATI_TAC_API_Services.NewCaseDetails caseDetails = new ATI_TAC_API_Services.NewCaseDetails();
        caseDetails.caseNumber = 'CASE-123';
        caseDetails.serialNumber = 'SERIAL-456';
        caseDetails.caseStatus = 'Active';
        caseDetails.caseSubStatus = 'Sub Status';
        caseDetails.createdDate = '2023-07-26';
        caseDetails.caseOwner = 'John Doe';
        caseDetails.notes = 'Sample notes';
        
        // Verify the values of the properties
        System.assertEquals('CASE-123', caseDetails.caseNumber, 'Expected case number to match');
        System.assertEquals('SERIAL-456', caseDetails.serialNumber, 'Expected serial number to match');
        System.assertEquals('Active', caseDetails.caseStatus, 'Expected case status to match');
        System.assertEquals('Sub Status', caseDetails.caseSubStatus, 'Expected case sub-status to match');
        System.assertEquals('2023-07-26', caseDetails.createdDate, 'Expected created date to match');
        System.assertEquals('John Doe', caseDetails.caseOwner, 'Expected case owner to match');
        System.assertEquals('Sample notes', caseDetails.notes, 'Expected notes to match');
    }
    
    
    
    @IsTest
    public static void testVehicleInfoIntegrationAPIHandler() {
        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results":[{"ErrorCode": "0","Name":"4567890","VehicleType":"Test","AxleConfiguration":"SomeAxleConfig","Axles":"2","BodyCabType":"SomeCabType","BodyClass":"SomeBodyClass","BusFloorConfigType":"SomeFloorConfig","BusLength":"10","BusType":"SomeBusType","CurbWeightLB":"2000","DriveType":"SomeDriveType","EngineConfiguration":"SomeEngineConfig","EngineCycles":"SomeEngineCycles","EngineCylinders":"4","EngineHP":"100","EngineHP_to":"200","EngineKW":"75","EngineManufacturer":"SomeEngineManufacturer","EngineModel":"SomeEngineModel","FuelTypePrimary":"SomeFuelType","GVWR":"3000","Manufacturer":"SomeManufacturer","ModelYear":"2023","OtherBusInfo":"SomeOtherInfo","PlantCity":"SomeCity","PlantCompanyName":"SomeCompany","PlantCountry":"SomeCountry","PlantState":"SomeState","SuggestedVIN":"SomeSuggestedVIN","VehicleDescriptor":"SomeDescriptor","VehicleType":"SomeVehicleType"}]}');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('success');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_Vehicle_Information__c returnObj = ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(mockResponse, '4567890', requestBodyJSON);
        Test.stopTest();
        
        // Verify the response
        System.assertNotEquals(null, returnObj, 'Expected a Vehicle Information record');
    }
    
    @IsTest
    public static void testVehicleInfoIntegrationAPIHandlerErrorScenarios() {
        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results":[{"ErrorCode": "1","Name":"4567890","VehicleType":"Test"}]}');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('success');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(mockResponse, '4567890', requestBodyJSON);
        Test.stopTest();
    }
    
    @IsTest
    public static void testVehicleInfoIntegrationAPIHandlerSuccess() {
        // Create a mock HTTP response for success scenario
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results":[{"ErrorCode": "1","Name":"4567890","VehicleType":"Test"}]}');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('success');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(mockResponse, '4567890', requestBodyJSON);
        Test.stopTest();
        
        
    }
    
    @IsTest
    public static void testVehicleInfoIntegrationAPIHandlerError() {
        // Create a mock HTTP response for the error scenario
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"ErrorCode":"2","ErrorText":"Test Error"}');
        mockResponse.setStatusCode(400);
        mockResponse.setStatus('error');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_Vehicle_Information__c returnObj = ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(mockResponse, '4567890', requestBodyJSON);
        Test.stopTest();
        
        
        System.assertNotEquals(null, returnObj, 'Expected non-null returnObj');
        
        
        System.debug('### Error Message: ' + mockResponse.getBody());
        System.debug('### ATI_Error_Log__c records: ' + [SELECT Id, ATI_Class_Name__c, ATI_Error_Message__c FROM ATI_Error_Log__c]);
        
    }
    
    
    
    @IsTest
    public static void testVehicleInfoIntegrationAPIHandlerException() {
        // Create a mock HTTP response with a valid body, simulating an exception scenario
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results":[{"ErrorCode": "1","Name":"4567890","VehicleType":"Test"}]}');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('success');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_Vehicle_Information__c returnObj = ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(mockResponse, '4567890', requestBodyJSON);
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testVehicleInfoWrapperErrorProperties() {
        // Create a mock HTTP response for an error scenario
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"ErrorCode": "2","ErrorText":"Test Error","AdditionalErrorText":"Additional Test Error"}');
        mockResponse.setStatusCode(400);
        mockResponse.setStatus('error');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_TAC_API_Services.VehicleInfowrapper wrapper = (ATI_TAC_API_Services.VehicleInfowrapper)JSON.deserialize(mockResponse.getBody(), ATI_TAC_API_Services.VehicleInfowrapper.class);
        Test.stopTest();
        
        // Verify the response
        System.assertEquals('Test Error', wrapper.ErrorText, 'Expected ErrorText to match');
        System.assertEquals('Additional Test Error', wrapper.AdditionalErrorText, 'Expected AdditionalErrorText to match');
    }
    
    @IsTest
    public static void testVehicleInfoIntegrationAPIHandlerElse() {
        // Create a mock HTTP response with a valid body, simulating an exception scenario
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results":[{"ErrorCode": "1","Name":"4567890","VehicleType":"Test"}]}');
        mockResponse.setStatusCode(900);
        mockResponse.setStatus('success');
        
        // Create the request body
        String requestBodyJSON = JSON.serialize('TestingInput');
        
        // Call the vehicleInfoIntegrationAPIHandler method
        Test.startTest();
        ATI_Vehicle_Information__c returnObj = ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(mockResponse, '4567890', requestBodyJSON);
        Test.stopTest();
        
    }
    
    
}