@IsTest
public class ATI_TAC_API_VehicleInformationTest {
    @TestSetup
    static void setupTestData() {
        // Create test records for any data dependencies
        ATI_TAC_TestDataFactory.createVehicleInformation();
    }

    @IsTest
    static void testPopulateVehicleInformation() {
        // Test data
        String vinNumber = 'VIN1234567890';

        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Results": [{ "ErrorCode": "0", "AxleConfiguration": "2 Axle", "Axles": "2", "BodyCabType": "Regular Cab", "BodyClass": "Sedan", "BusFloorConfigType": "", "BusLength": "", "BusType": "", "CurbWeightLB": "", "DriveType": "", "EngineConfiguration": "", "EngineCycles": "", "EngineCylinders": "4", "EngineHP": "", "EngineHP_to": "", "EngineKW": "", "EngineManufacturer": "", "EngineModel": "", "FuelTypePrimary": "", "GVWR": "", "Manufacturer": "", "ModelYear": "", "OtherBusInfo": "", "PlantCity": "", "PlantCompanyName": "", "PlantCountry": "", "PlantState": "", "SuggestedVIN": "", "VehicleDescriptor": "", "VehicleType": "" }]}');
        mockResponse.setStatusCode(200);

        Test.startTest();

        // Call the method to test
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        ATI_Vehicle_Information__c result = ATI_TAC_API_VehicleInformation.populateVehicleInformation(vinNumber);

        Test.stopTest();

        // Assert the results
        System.assertNotEquals(null, result, 'Expected a Vehicle Information record');
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