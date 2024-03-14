/**
 * @description       : 
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 11-17-2023
 * @last modified by  : Abhishek Mohapatra
**/
@IsTest
public with sharing class ATI_SALES_Incentive_Services_Test {
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
    
    public class MockHttpResponseGeneratorHappyPath implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Message": "Success","SAP_Document_Number": "Testing","DurationSeconds": "MockDurationSeconds","URL": "MockURL"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testSendIncentiveClaim(){
        
        Account testAccount = new Account(Name = 'Test Account', AccountNumber = '123456');
        insert testAccount;

        Opportunity oppty = new Opportunity (Name = 'Testoppty', 
                                            AccountId = testAccount.Id, 
                                            StageName = 'Closed', 
                                            CloseDate = System.today()-100);
        Insert oppty;

        RebateProgram rp = new RebateProgram(Name = 'Test RP', 
                                            ATI_Opportunity_Source__c = oppty.Id, 
                                            Frequency = 'OnDemand', 
                                            StartDate = System.today(), 
                                            EndDate = System.today()+50);
        Insert rp;

        ATI_C_E__c ch = new ATI_C_E__c (Incentive_Proposal__c = rp.Id
                               );
        Insert ch;


        ATI_SALES_API_Services.cls_header hr = new ATI_SALES_API_Services.cls_header();
        hr.vendorCode = '212545';
        hr.SI = '222';

        ATI_SALES_API_Services.cls_items ci = new ATI_SALES_API_Services.cls_items();
        ci.file = 'ndsbd';
        ci.fileType = 'pdf';

        ATI_SALES_API_Services.ClaimApiRes car = new ATI_SALES_API_Services.ClaimApiRes();
        car.invoiceNumber = '212151';
        car.SAP_Document_Number = 'jsjnsdj';

        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


        Test.startTest();
        ATI_SALES_Incentive_Claim_API_Services.sendClaimHeader(new List<String>{ch.Id});
        Test.stopTest();
        
    }
    
    
    @IsTest
    static void testSendIncentiveClaimHappyPath(){

        Account testAccount1 = new Account(Name = 'Test Account', ATI_SALES_Vendor_Code__c = '123456');
        insert testAccount1;

        Opportunity oppty1 = new Opportunity (Name = 'Testoppty', 
                                            AccountId = testAccount1.Id, 
                                            StageName = 'Closed', 
                                            CloseDate = System.today()-100);
        Insert oppty1;

        RebateProgram rp1 = new RebateProgram(Name = 'Test RP', 
                                            ATI_Opportunity_Source__c = oppty1.Id, 
                                            Frequency = 'OnDemand', 
                                            StartDate = System.today(), 
                                            EndDate = System.today()+50);
        Insert rp1;

        ATI_C_E__c ch1 = new ATI_C_E__c (Incentive_Proposal__c = rp1.Id
                               );
        Insert ch1;
        
        Claim_Line_Item__c clmln = new Claim_Line_Item__c(Claim__c = ch1.id, 
                                            Serial_Number__c = '7771231281',
                                            Price__c=1000.00 
                                           );
                                           
                                           Insert clmln;  
                                           
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = rp1.Id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;

        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorHappyPath());


        Test.startTest();
        ATI_SALES_Incentive_Claim_API_Services.sendClaimHeader(new List<String>{ch1.Id});
        Test.stopTest();
        
    }
}