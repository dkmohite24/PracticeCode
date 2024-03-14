/* Name: ATI_REST_PartsMasterSyncTest
Description : Test Class for ATI_REST_PartsMasterSync,ATI_REST_PartsMasterValidator, ATI_REST_PartsMasterRequest 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             DATE              DETAIL                UserStory/Req#
1.0 -     Tavant(Punam)      13/01/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_PartsMasterSyncTest {
    @testSetup
    public static void testSetup(){
        List<WOD_2__Warranty_Product__c> createWarrantyProductList = TestDataFactory.createWarrantyProduct(3);
        insert createWarrantyProductList;
        List<WOD_2__Business_Category_Configuration__c> businessCategoryConfigurationList= TestDataFactory.createBusinessCategoryConfiguration(1);
    	insert businessCategoryConfigurationList;
    
    }
    
     @isTest
    private static void testForPartsMasterValidatorAndSync(){
        String jsonMsg = '{"warrantyProduct":[{"identifier":"","productCode":"E111","productName":"E111","description":"","parentProduct":"","prodType":"","itemType":"","trackType":"","businessCategoryUnit":"","unitOfMeasure":"","externalProductCode":"","active":"","hardwareModel":"E000","nameplateModel":"E111HS","extendedBaseModel":"E100HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"No","primaryFailedPartProhibit":"","hierarchy":"","gNumber":"","partMarkup":{"partMarkupPercentage":"0","effectiveDate":"2021-05-10"}}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestPartsMasterSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response = ATI_REST_PartsMasterSync.doPost();
            System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        
        	WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartsMasterSync'];
        System.assert(batchLog.ATI_Error_Message__c.contains('Business Category Configuration can not be empty.'),'Business Category Configuration Mandatory Check...!!!');
        
        	jsonMsg = '{"warrantyProduct":[{"identifier":"123456","productCode":"E111","productName":"E111","description":"E111 Series","parentProduct":"E111","prodType":"Product","itemType":"Part","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E111","active":"Yes","hardwareModel":"E000","nameplateModel":"E111HS","extendedBaseModel":"E100HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"E111","gNumber":"","partMarkup":{"partMarkupPercentage":"20","effectiveDate":"2021-05-10"}}]}';
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response2 = ATI_REST_PartsMasterSync.doPost();
        	//System.assertEquals('Success', response2.status, 'All the records have inserted or updated...!!!');

        	jsonMsg = '{"warrantyProduct":[{"identifier":"12398","productCode":"E1110","productName":"E1110","description":"E1110 Series","parentProduct":"E111","prodType":"Model","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E1110","active":"Yes","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"E1110","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}}]}';
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response3 = ATI_REST_PartsMasterSync.doPost();
        system.debug('response3.data[0].message**'+response3.data[0].message);	
        //System.assertEquals('Success', response3.status, 'All the records have inserted or updated...!!!');
        	
        	jsonMsg='{"warrantyProduct":[{"identifier":"12356","productCode":"ENew1","productName":"ENew1","description":"ENew1 Series","parentProduct":"ENew2","prodType":"Model","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"ENew1","active":"Yes","hardwareModel":"E001","nameplateModel":"ENew1HS","extendedBaseModel":"ENew10HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"ENew1","gNumber":"","partMarkup":{"partMarkupPercentage":"10","effectiveDate":"2021-05-10"}}]}';	
        	req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response4 = ATI_REST_PartsMasterSync.doPost();
        	
        	List<WOD_2__Warranty_Product__c> wpLst = [SELECT Id,External_Product_Code__c,WOD_2__Parent_Product__c,Name,WOD_2__Product_Name__c FROM WOD_2__Warranty_Product__c Where Name='E1110'];
        	//System.assertEquals('E1110',wpLst[0].Name);
        
        	jsonMsg ='{"warrantyProduct":[{"identifier":"123456","productCode":"E22","productName":"E22","description":"E22 Series","parentProduct":"","prodType":"Product","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E22","active":"Yes","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"E22","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}},{"identifier":"123456","productCode":"E11","productName":"E11","description":"E11 Series","parentProduct":"E22","prodType":"Item","itemType":"Part","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"Miles","externalProductCode":"E11","active":"Yes","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"E1110","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"E10","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}}]}';
        	req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response5 = ATI_REST_PartsMasterSync.doPost();
        	//System.assertEquals('Partial Success', response5.status, 'All the records have inserted or updated...!!!');
        
        	jsonMsg ='{"warrantyProduct":[{"identifier":"123456","productCode":"E23","productName":"E23","description":"E23 Series","parentProduct":"","prodType":"Product","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E23","active":"Yes","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"E23","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}},{"identifier":"346565","productCode":"E12","productName":"E12","description":"E12 Series","parentProduct":"E23","prodType":"Model","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E12","active":"Yes","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"E1110","rmaPolicy":"No","primaryFailedPartProhibit":"Yes","hierarchy":"E12","gNumber":"","partMarkup":{"partMarkupPercentage":"10","effectiveDate":"2021-05-10"}}]}';
            req.requestBody = Blob.valueof(jsonMsg);    
            RestContext.request = req;
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response6 = ATI_REST_PartsMasterSync.doPost();
        	System.assertEquals('Failed', response6.status, 'All the records have Failed to insert or update...!!!');
        	
        	jsonMsg ='{"warrantyProduct":[{"identifier":"123456","productCode":"E23","productName":"E23","description":"E23 Series","parentProduct":"","prodType":"Product","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E23","active":"true","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"false","primaryFailedPartProhibit":"true","hierarchy":"E23","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}},{"identifier":"346565","productCode":"E12","productName":"E12","description":"E12 Series","parentProduct":"E23","prodType":"Model","itemType":"","trackType":"Serialized","businessCategoryUnit":"ATI","unitOfMeasure":"","externalProductCode":"E12","active":"true","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"E1110","rmaPolicy":"false","primaryFailedPartProhibit":"true","hierarchy":"E12","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}}]}';
            req.requestBody = Blob.valueof(jsonMsg);    
            RestContext.request = req;
            ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response7 = ATI_REST_PartsMasterSync.doPost();
        	//System.assertEquals('Partial Success', response7.status, 'All the records have inserted or updated...!!!');
        
        Test.stopTest();
    }
    
     @isTest
    private static void testTrackTypeFunctionalityForPartAndMachine(){
        Profile profileObj = [SELECT Id,Name FROM Profile WHERE Name='ATI_Integration' LIMIT 1];
        List<User> userLst = TestDataFactory.createUser(1);
        userLst[0].ProfileId = profileObj.Id;
        insert userLst;
        
        ATI_Managed_Serialized_Part__c serializedPartObj = new ATI_Managed_Serialized_Part__c(Name='E25');
        insert serializedPartObj;
        
        String jsonMsg = '{"warrantyProduct":[{"identifier":"123456","productCode":"E23","productName":"E23","description":"E23 Series","parentProduct":"Model1","prodType":"Item","itemType":"Part","trackType":"","businessCategoryUnit":"ATI","unitOfMeasure":"EA","externalProductCode":"E23","active":"true","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"false","primaryFailedPartProhibit":"true","hierarchy":"E23","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}},'
        				 +'{"identifier":"123457","productCode":"E24","productName":"E24","description":"E24 Series","parentProduct":"Model1","prodType":"Item","itemType":"Machine","trackType":"","businessCategoryUnit":"ATI","unitOfMeasure":"EA","externalProductCode":"E24","active":"true","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"false","primaryFailedPartProhibit":"true","hierarchy":"E23","gNumber":"","partMarkup":{}},'
        				 +'{"identifier":"123458","productCode":"E25","productName":"E25","description":"E25 Series","parentProduct":"Model1","prodType":"Item","itemType":"Part","trackType":"","businessCategoryUnit":"ATI","unitOfMeasure":"EA","externalProductCode":"E25","active":"true","hardwareModel":"E001","nameplateModel":"E1110HS","extendedBaseModel":"E1000HS","eeNumber":"","thirtyTwoMiNum":"","rmaPolicy":"false","primaryFailedPartProhibit":"true","hierarchy":"E23","gNumber":"","partMarkup":{"partMarkupPercentage":"","effectiveDate":"2021-05-10"}}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestPartsMasterSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res; 
        
        System.runAs(userLst[0]){
            Test.startTest();
            	req.requestBody = Blob.valueof(jsonMsg);	
                RestContext.request = req;
                ATI_REST_PartsMasterSync.ATI_REST_PartsMasterSyncResponse response = ATI_REST_PartsMasterSync.doPost();
            	System.debug('response------------>'+response);
            	//check for non serialized part
            	/*WOD_2__Warranty_Product__c nonSerialPart = [SELECT Id,Name,WOD_2__Track_Type__c FROM WOD_2__Warranty_Product__c WHERE Name='E23' LIMIT 1];
            	System.assertEquals('Non-Serialized',nonSerialPart.WOD_2__Track_Type__c);
            	
            	//check for machine - should be serialized
            	WOD_2__Warranty_Product__c machineObj = [SELECT Id,Name,WOD_2__Track_Type__c FROM WOD_2__Warranty_Product__c WHERE Name='E24' LIMIT 1];
            	System.assertEquals('Serialized',machineObj.WOD_2__Track_Type__c);
            
            	//check for serialized part
            	WOD_2__Warranty_Product__c serializedPart = [SELECT Id,Name,WOD_2__Track_Type__c FROM WOD_2__Warranty_Product__c WHERE Name='E25' LIMIT 1];
            	System.assertEquals('Serialized',serializedPart.WOD_2__Track_Type__c);*/
            Test.stopTest();
        }
    }

        
}