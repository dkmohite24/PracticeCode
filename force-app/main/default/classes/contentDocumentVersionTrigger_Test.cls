@isTest(seeAllData = false)
private class contentDocumentVersionTrigger_Test {
    @testSetup static void setup() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
    }
    
    @isTest static void ContentVersionTriggTest() {
        
        Test.startTest();
        
        Test.stopTest();
        
    }
}