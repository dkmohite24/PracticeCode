/* Name: ATI_REST_PartCostSyncTest
Description : Test Class for ATI_REST_PartCostSync,ATI_REST_PartCostValidator, ATI_REST_PartCostRequest 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             DATE              DETAIL                UserStory/Req#
1.0 -     Tavant(Punam)      20/01/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_PartCostSyncTest {
    @testSetup
    public static void testSetup(){
        List<WOD_2__Warranty_Product__c> createWarrantyProductList = TestDataFactory.createWarrantyProduct(50);
        insert createWarrantyProductList;
        List<WOD_2__Business_Category_Configuration__c> businessCategoryConfigurationList= TestDataFactory.createBusinessCategoryConfiguration(1);
    	insert businessCategoryConfigurationList;
        
    }
    @isTest
    private static void testForPartsCostValidatorAndSync(){
        String jsonMsg = '{"PartCost": [{"identifier": "","Item": "","Value": "","Active": "True","EffectiveDate": "","ItemUnit": ""},{"identifier": "","Item": "0611","Value": "110.00","Active": "True","EffectiveDate": "2020-06-20T12:00:00.000","ItemUnit": "ea"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestPartCostSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();   
        	ATI_REST_PartCostSync.ATI_REST_PartCostSyncResponse response = ATI_REST_PartCostSync.doPost();
        	System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        
        	WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartCostSync'];
        	System.assert(batchLog.ATI_Error_Message__c.contains('Item is mandatory'),'Item Validation Check...!!!');
        	
        List<WOD_2__Warranty_Product__c> createWarrantyProductList =[Select Id, Name,WOD_2__Type__c,WOD_2__Track_Type__c,WOD_2__Item_Type__c,Active__c From WOD_2__Warranty_Product__c where WOD_2__Type__c = 'Item' limit 2];
        createWarrantyProductList[0].WOD_2__Item_Type__c = 'Part';
        createWarrantyProductList[0].Active__c = True;
        createWarrantyProductList[1].WOD_2__Item_Type__c = 'Part';
        createWarrantyProductList[1].Active__c = True;
        update createWarrantyProductList;
        jsonMsg = '{"PartCost": [{"identifier": "123456","Item": "'+createWarrantyProductList[0].Name+'","Value": "110.72","Active": "True","EffectiveDate": "2020-06-22","ItemUnit": "ea"},{"identifier": "123456","Item": "'+createWarrantyProductList[1].Name+'","Value": "110.00","Active": "True","EffectiveDate": "2020-06-20","ItemUnit": "ea"}]}';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        ATI_REST_PartCostSync.ATI_REST_PartCostSyncResponse response4 = ATI_REST_PartCostSync.doPost();
        System.assertEquals('Partial Success', response4.status, 'All the records have failed to update...!!!');
        
        	jsonMsg = '{"PartCost": [{"identifier": "123456","Item": "'+createWarrantyProductList[0].Name+'","Value": "110.72","Active": "True","EffectiveDate": "2020-06-22","ItemUnit": "ea"},{"identifier": "23098","Item": "'+createWarrantyProductList[1].Name+'","Value": "110.00","Active": "True","EffectiveDate": "2020-06-20","ItemUnit": "ea"}]}';
        system.debug('jsonMsg ---'+ jsonMsg);
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
        	ATI_REST_PartCostSync.ATI_REST_PartCostSyncResponse response2 = ATI_REST_PartCostSync.doPost();
        	System.assertEquals('Success', response2.status, 'All the records have inserted or updated...!!!');
        
        	//List<WOD_2__Warranty_Product_Pricebook__c> wpPricebookList =[Select Id, Name From WOD_2__Warranty_Product_Pricebook__c limit 2];
        
        	jsonMsg = '{"PartCost": [{"identifier": "123456","Item": "'+createWarrantyProductList[0].Name+'","Value": "120.72","Active": "True","EffectiveDate": "2020-06-22","ItemUnit": "ea"},{"identifier": "123456","Item": "'+createWarrantyProductList[1].Name+'","Value": "111.00","Active": "True","EffectiveDate": "2020-08-20","ItemUnit": "ea"}]}';
			req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
        	ATI_REST_PartCostSync.ATI_REST_PartCostSyncResponse response3 = ATI_REST_PartCostSync.doPost();
        	System.assertEquals('Success', response2.status, 'All the records have inserted or updated...!!!');
        Test.stopTest();
    }
    
    /*@isTest
    private static void testForPartsCostValidatorAndSyncDEMO(){
        List<WOD_2__Warranty_Product__c> createWarrantyProductList =[Select Id, Name From WOD_2__Warranty_Product__c limit 4500];
        String jsonMsg='{"PartCost": [';
        for(Integer count=0;count<createWarrantyProductList.size();count++){
    		jsonMsg = jsonMsg+'{"Item": "'+createWarrantyProductList[count].Name+'","Value": "110.72","Active": "True","EffectiveDate": "2020-06-22","ItemUnit": "ea"},';
         	
        }        
        jsonMsg= jsonMsg.removeEnd(',')+']}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestPartCostSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();   
        	ATI_REST_PartCostSync.ATI_REST_PartCostSyncResponse response = ATI_REST_PartCostSync.doPost();
        	System.assertEquals('Success', response.status, 'All the records have inserted or updated...!!!');
        	System.assertEquals(4500, response.data.size(), 'All the records have inserted or updated...!!!');
        Test.stopTest();
        
    }*/
}