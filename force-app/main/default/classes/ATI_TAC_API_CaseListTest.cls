@IsTest
public class ATI_TAC_API_CaseListTest {
    
    @TestSetup
    static void setupTestData() {
        List<Disable_Rules__c> disableRules = ATI_TAC_TestDataFactory.createDisableRules();
        Account acObj = ATI_TAC_TestDataFactory.createTestAccount();
        
    }
    
    @IsTest
    public static void testGetCases() {
        // Create a test REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/caselist/getdealercases';
        req.httpMethod = 'GET';

        // Create the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('dealerCode', '12345');
        String requestBodyJSON = JSON.serialize(requestBody);
        req.requestBody = Blob.valueOf(requestBodyJSON);

        // Set the test context
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the getCases method
        Test.startTest();
        ATI_TAC_API_CaseList.getCases();
        Test.stopTest();

        // Verify the response
        RestResponse res = RestContext.response;
        System.assertEquals(200, res.statusCode, 'Expected status code');
        
    }
}