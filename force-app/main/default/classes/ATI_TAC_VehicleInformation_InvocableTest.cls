@IsTest
public class ATI_TAC_VehicleInformation_InvocableTest {
    @TestSetup
    static void setupTestData() {
        // Create test records for any data dependencies
        ATI_TAC_TestDataFactory.createVehicleInformation();
    }

    @IsTest
    static void testCreateVehicleInfo() {
        // Test data
        String vinNumber = '1234567890';

        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results": [{ "ErrorCode": "0", "AxleConfiguration": "2 Axle", "Axles": "2", "BodyCabType": "Regular Cab", "BodyClass": "Sedan", "BusFloorConfigType": "", "BusLength": "", "BusType": "", "CurbWeightLB": "", "DriveType": "", "EngineConfiguration": "", "EngineCycles": "", "EngineCylinders": "4", "EngineHP": "", "EngineHP_to": "", "EngineKW": "", "EngineManufacturer": "", "EngineModel": "", "FuelTypePrimary": "", "GVWR": "", "Manufacturer": "", "ModelYear": "", "OtherBusInfo": "", "PlantCity": "", "PlantCompanyName": "", "PlantCountry": "", "PlantState": "", "SuggestedVIN": "", "VehicleDescriptor": "", "VehicleType": "" }]}');
        mockResponse.setStatusCode(200);

        Test.startTest();

        // Create a mock object for ATI_TAC_API_DataServices
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the method to test
        ATI_TAC_VehicleInformation_Invocable.createVehicleInfo(new List<String>{vinNumber});

        Test.stopTest();

    }

    /*33993- Vehicle Information Create Existing Records changes start*/
    @IsTest
    static void testCreateVehicleInformation() {
        // Test data
        String vinNumber = '127';
        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results": [{ "ErrorCode": "0", "AxleConfiguration": "2 Axle", "Axles": "2", "BodyCabType": "Regular Cab", "BodyClass": "Sedan", "BusFloorConfigType": "", "BusLength": "", "BusType": "", "CurbWeightLB": "", "DriveType": "", "EngineConfiguration": "", "EngineCycles": "", "EngineCylinders": "4", "EngineHP": "", "EngineHP_to": "", "EngineKW": "", "EngineManufacturer": "", "EngineModel": "", "FuelTypePrimary": "", "GVWR": "", "Manufacturer": "", "ModelYear": "", "OtherBusInfo": "", "PlantCity": "", "PlantCompanyName": "", "PlantCountry": "", "PlantState": "", "SuggestedVIN": "", "VehicleDescriptor": "", "VehicleType": "" }]}');
        mockResponse.setStatusCode(200);

        Test.startTest();

        // Create a mock object for ATI_TAC_API_DataServices
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the method to test
        ATI_TAC_VehicleInformation_Invocable.createVehicleInfo(new List<String>{vinNumber});

        Test.stopTest();

    }
/*33993- Vehicle Information Create Existing Records changes end*/
    
    
     @IsTest
    static void testCreateVehicleInfoUpdate() {
        // Test data
        String vinNumber = '123456789';
        
        ATI_Vehicle_Information__c testDataSFDC = new ATI_Vehicle_Information__c();
        testDataSFDC.Name = vinNumber;
        testDataSFDC.ATI_Engine_Make__c = 'Test1';
        testDataSFDC.ATI_Engine_Model__c = 'TestModel';
        String insertRecordSFDC = ATI_TAC_API_DataServices.insertVehicleInformation(testDataSFDC);

        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results": [{ "ErrorCode": "0", "AxleConfiguration": "2 Axle", "Axles": "2", "BodyCabType": "Regular Cab", "BodyClass": "Sedan", "BusFloorConfigType": "", "BusLength": "", "BusType": "", "CurbWeightLB": "", "DriveType": "", "EngineConfiguration": "", "EngineCycles": "", "EngineCylinders": "4", "EngineHP": "", "EngineHP_to": "", "EngineKW": "", "EngineManufacturer": "", "EngineModel": "Model Test", "FuelTypePrimary": "", "GVWR": "", "Manufacturer": "", "ModelYear": "", "OtherBusInfo": "", "PlantCity": "", "PlantCompanyName": "", "PlantCountry": "", "PlantState": "", "SuggestedVIN": "", "VehicleDescriptor": "", "VehicleType": "" }]}');
        mockResponse.setStatusCode(200);

        Test.startTest();

        // Create a mock object for ATI_TAC_API_DataServices
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the method to test
        List<string> ids=  ATI_TAC_VehicleInformation_Invocable.createVehicleInfo(new List<String>{vinNumber});

        Test.stopTest();
	 }
    
@IsTest
    static void testCreateVehicleInfo_ErrorHandling() {
        // Test data
        String vinNumber = '1234567890';

        // Create a mock response with an error
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"errorCode": "500", "message": "Internal Server Error", "EngineCylinders": "100"}');

        Test.startTest();

        // Create a mock object for ATI_TAC_API_DataServices
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the method to test
        try {
            ATI_TAC_VehicleInformation_Invocable.createVehicleInfo(new List<String>{vinNumber});
        } catch (Exception e) {
            // Handle exception
            System.debug('Exception occurred: ' + e.getMessage());
           
        }

        Test.stopTest();

        
    }
   
    
    // Mock HttpCalloutMock to generate a mock HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}