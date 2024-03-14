@IsTest
private class ATI_ErrorLogServiceTest {

    @TestSetup
    static void setupTestData() {
           }
    
    @IsTest
    public static void testConstructor() {
        ATI_ErrorLogService service = new ATI_ErrorLogService();
        System.assertNotEquals(null, service, 'Expected non-null instance of ATI_ErrorLogService');
    }

    @IsTest
    static void testLogInboundError() {
        // Test LogInboundError method
        String input = 'Sample inbound request data';
        String errorMessage = 'Sample error message';
        String className = 'ATI_API_Services';
        String methodName = 'getDealerCasesAPIHandler';

        Test.startTest();
        ATI_ErrorLogService.errorLogWrapper inboundErr = new ATI_ErrorLogService.errorLogWrapper();
        inboundErr.inputType = true;
        inboundErr.input = input;
        inboundErr.errorMessage = errorMessage;
        inboundErr.className = className;
        inboundErr.methodName = methodName;
        ATI_ErrorLogService.logError(inboundErr);
        Test.stopTest();

        // Assert the log record has been created
        List<ATI_Error_Log__c> errorLogs = [SELECT Id, ATI_Input__c, ATI_Error_Message__c, ATI_Class_Name__c, ATI_Method_Name__c FROM ATI_Error_Log__c];
        System.assertEquals(1, errorLogs.size(), 'One error log record should be created');
        ATI_Error_Log__c errorLog = errorLogs[0];
        System.assertEquals(input, errorLog.ATI_Input__c, 'Input data should be logged for inbound error');
        System.assertEquals(errorMessage, errorLog.ATI_Error_Message__c, 'Error message should be logged');
        System.assertEquals(className, errorLog.ATI_Class_Name__c, 'Class name should be logged');
        System.assertEquals(methodName, errorLog.ATI_Method_Name__c, 'Method name should be logged');
    }

    @IsTest
    static void testLogOutboundError() {
        // Test LogOutboundError method
        String output = 'Sample outbound response data';
        String errorMessage = 'Sample error message';
        String className = 'ATI_API_Services';
        String methodName = 'getDealerCasesAPIHandler';

        Test.startTest();
        ATI_ErrorLogService.errorLogWrapper outboundErr = new ATI_ErrorLogService.errorLogWrapper();
        outboundErr.outputType = true;
        outboundErr.output = output;
        outboundErr.errorMessage = errorMessage;
        outboundErr.className = className;
        outboundErr.methodName = methodName;
        ATI_ErrorLogService.logError(outboundErr);
        Test.stopTest();

        // Assert the log record has been created
        List<ATI_Error_Log__c> errorLogs = [SELECT Id, ATI_Output__c, ATI_Error_Message__c, ATI_Class_Name__c, ATI_Method_Name__c FROM ATI_Error_Log__c];
        System.assertEquals(1, errorLogs.size(), 'One error log record should be created');
        ATI_Error_Log__c errorLog = errorLogs[0];
        System.assertEquals(output, errorLog.ATI_Output__c, 'Output data should be logged for outbound error');
        System.assertEquals(errorMessage, errorLog.ATI_Error_Message__c, 'Error message should be logged');
        System.assertEquals(className, errorLog.ATI_Class_Name__c, 'Class name should be logged');
        System.assertEquals(methodName, errorLog.ATI_Method_Name__c, 'Method name should be logged');
    }
}